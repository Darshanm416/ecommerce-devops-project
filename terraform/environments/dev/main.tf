# environments/dev/main.tf

# --- Data Sources (to get existing Jenkins infrastructure details) ---
# Used to dynamically get the AWS Account ID for IAM ARN construction
data "aws_caller_identity" "current" {}

# Used to dynamically get the Jenkins VPC details for VPC Peering
data "aws_vpc" "jenkins_vpc" {
  id = var.jenkins_vpc_id
}

# Used to dynamically get the Jenkins server's subnet details for route table update
data "aws_subnet" "jenkins_server_subnet" {
  id = var.jenkins_server_subnet_id
}

# Used to dynamically get the Jenkins server's security group details for cross-VPC SG rule
data "aws_security_group" "jenkins_server_sg" {
  id = var.jenkins_server_security_group_id
}


# --- EKS VPC Module ---
# Provisions the VPC infrastructure dedicated to the EKS cluster.
module "vpc" {
  source             = "../../modules/vpc"
  vpc_cidr           = var.eks_vpc_cidr
  public_subnets     = var.eks_public_subnets
  private_subnets    = var.eks_private_subnets
  availability_zones = var.availability_zones
  environment        = var.environment
  cluster_name       = var.cluster_name # Used for subnet tagging for EKS auto-discovery
}

# --- EKS Cluster Module ---
# Deploys the EKS Kubernetes cluster itself and its managed node groups.
# 'map_roles' is intentionally NOT passed here, as aws-auth is managed separately below.
module "eks" {
  source             = "../../modules/eks" # Your local EKS wrapper module
  cluster_name       = var.cluster_name
  cluster_version    = var.cluster_version
  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnet_ids # Passes IDs, not CIDRs, as expected by EKS module
  environment        = var.environment
}

# --- VPC Peering Module ---
# Establishes network connectivity between the Jenkins VPC and the EKS VPC.
module "vpc_peering" {
  source                           = "../../modules/vpc-peering"
  eks_vpc_id                       = module.vpc.vpc_id
  jenkins_vpc_id                   = data.aws_vpc.jenkins_vpc.id
  eks_private_route_table_ids      = module.vpc.private_route_table_ids
  jenkins_route_table_id           = data.aws_route_table.jenkins_server_rt.id
  eks_vpc_cidr                     = module.vpc.vpc_cidr
  jenkins_vpc_cidr                 = data.aws_vpc.jenkins_vpc.cidr_block
  eks_cluster_security_group_id    = module.eks.cluster_security_group_id
  jenkins_server_security_group_id = data.aws_security_group.jenkins_server_sg.id
  environment                      = var.environment
}

# --- Data Source for Jenkins Server's Route Table ---
# Used by the vpc_peering module to identify and update the correct route table in Jenkins VPC.
data "aws_route_table" "jenkins_server_rt" {
  subnet_id = data.aws_subnet.jenkins_server_subnet.id
  vpc_id    = data.aws_vpc.jenkins_vpc.id
}


# --- Kubernetes Provider Configuration ---
# Configures the 'kubernetes' provider to interact with the EKS cluster's API.
# It uses the 'exec' block for secure authentication via AWS CLI's 'get-token'.
provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    args        = ["eks", "get-token", "--cluster-name", module.eks.cluster_name, "--region", var.aws_region]
  }

  # No 'depends_on' here, as it's a provider configuration.
}

# --- AWS Auth ConfigMap for Jenkins Admin Access ---
# This explicitly creates or updates the 'aws-auth' ConfigMap in the 'kube-system' namespace.
# It grants your Jenkins server's IAM Role (Instance Profile) administrative access to the EKS cluster.
resource "kubernetes_config_map_v1" "aws_auth" {
  metadata {
    name      = "aws-auth"
    namespace = "kube-system"
  }

  data = {
    # mapRoles: Maps AWS IAM roles to Kubernetes RBAC groups.
    mapRoles = jsonencode([
      # EKS Worker Node Group Role (Crucial for nodes to join the cluster)
      {
        rolearn  = module.eks.eks_managed_node_groups_default_iam_role_arn
        username = "system:node:{{EC2PrivateDNSName}}" # Dynamic placeholder for node names
        groups   = ["system:bootstrappers", "system:nodes"]
      },
      # Jenkins Server's EC2 Instance Profile Role (for kubectl/helm access from Jenkins)
      {
        rolearn  = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:instance-profile/${var.jenkins_server_role_name}"
        username = "jenkins-eks-admin" # Logical name for Kubernetes logs
        groups   = ["system:masters"]  # Grants full admin permissions in Kubernetes
      }
    ])
    mapUsers = jsonencode([]) # No IAM Users mapped by default
  }

  # This 'depends_on' ensures the ConfigMap is created only after EKS is fully provisioned.
  depends_on = [module.eks]
}


# --- Helm Provider Configuration ---
# Configures the 'helm' provider to deploy Helm charts into the Kubernetes cluster.
provider "helm" {
  kubernetes { # This block tells Helm how to connect to Kubernetes
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "aws"
      args        = ["eks", "get-token", "--cluster-name", module.eks.cluster_name, "--region", var.aws_region]
    }
  }
}


# --- AWS Load Balancer Controller Module ---
# This module deploys the AWS Load Balancer Controller (LBC) into your EKS cluster.
# The LBC will dynamically provision ALBs based on your Kubernetes Ingress resources.
module "aws_load_balancer_controller" {
  source  = "terraform-aws-modules/eks/aws//modules/aws-load-balancer-controller"
  version = "~> 19.0" # Match your EKS module version or compatible.

  cluster_name                   = module.eks.cluster_name
  cluster_endpoint               = module.eks.cluster_endpoint
  cluster_certificate_authority_data = module.eks.cluster_certificate_authority_data
  vpc_id                         = module.vpc.vpc_id
  region                         = var.aws_region
  service_account_name           = "aws-load-balancer-controller"
  namespace                      = "kube-system" # Standard namespace for LBC
  irsa_config = { # Enable IAM Roles for Service Accounts (IRSA) for LBC
    enabled = true
  }
  # LBC needs permission to create ALBs and related resources.
  # The module handles creation of necessary IAM roles and policies.

  # Ensure the LBC is deployed after the EKS cluster and aws-auth ConfigMap are ready.
  depends_on = [
    module.eks,
    kubernetes_config_map_v1.aws_auth,
  ]
}


# --- Frontend Application Module ---
# This module uses the generic 'app-helm-chart' module to deploy your frontend app.
module "frontend_app" {
  source           = "../../modules/app-helm-chart" # Your reusable module for app deployment
  name             = "frontend"
  namespace        = var.app_namespace
  create_namespace = true # Let Terraform create the namespace if it doesn't exist
  chart_path       = "helm-charts/frontend" # Relative path within your repo to frontend chart
  values = {
    image = {
      repository = var.frontend_image_repo
      tag        = var.frontend_image_tag
    }
    service = {
      port = var.frontend_service_port
    }
    ingress = {
      enabled   = true
      className = "alb" # Explicitly tell Ingress to use AWS Load Balancer Controller
      annotations = {
        "alb.ingress.kubernetes.io/scheme"             = "internet-facing" # Publicly accessible ALB
        "alb.ingress.kubernetes.io/target-type"        = "ip"              # Target Kubernetes Pod IPs
        "alb.ingress.kubernetes.io/load-balancer-name" = "${var.environment}-frontend-alb"
        "alb.ingress.kubernetes.io/group.name"         = "${var.environment}-ecommerce-apps" # Group frontend/backend ALBs
        "alb.ingress.kubernetes.io/listen-ports"       = "[{\"HTTP\": 80}]" # Listen on HTTP/80
      }
      hosts = [
        {
          host  = var.frontend_domain_name # e.g., "frontend.backend.local"
          paths = [{ path = "/", pathType = "Prefix" }]
        }
      ]
      tls = [] # You can configure TLS here later if needed (e.g., via ACM cert ARN)
    }
    replicaCount = 2 # Example: number of pods for frontend
  }
  # Ensure app deploys after LBC is ready, as LBC creates the Ingresses/ALBs for the app.
  depends_on = [module.aws_load_balancer_controller]
}

# --- Backend Application Module ---
# This module uses the generic 'app-helm-chart' module to deploy your backend app.
module "backend_app" {
  source           = "../../modules/app-helm-chart" # Your reusable module for app deployment
  name             = "backend"
  namespace        = var.app_namespace
  create_namespace = true # Let Terraform create the namespace if it doesn't exist
  chart_path       = "helm-charts/backend" # Relative path within your repo to backend chart
  values = {
    image = {
      repository = var.backend_image_repo
      tag        = var.backend_image_tag
    }
    service = {
      port = var.backend_service_port
    }
    env = { # Environment variables for backend app
      MONGO_URL = var.backend_mongo_url
    }
    ingress = {
      enabled   = true
      className = "alb" # Explicitly tell Ingress to use AWS Load Balancer Controller
      annotations = {
        "alb.ingress.kubernetes.io/scheme"             = "internet-facing" # Publicly accessible ALB
        "alb.ingress.kubernetes.io/target-type"        = "ip"              # Target Kubernetes Pod IPs
        "alb.ingress.kubernetes.io/load-balancer-name" = "${var.environment}-backend-alb"
        "alb.ingress.kubernetes.io/group.name"         = "${var.environment}-ecommerce-apps" # Group frontend/backend ALBs
        "alb.ingress.kubernetes.io/listen-ports"       = "[{\"HTTP\": 80}]" # Listen on HTTP/80
      }
      hosts = [
        {
          host  = var.backend_domain_name # e.g., "api.backend.local"
          paths = [{ path = "/", pathType = "Prefix" }]
        }
      ]
      tls = [] # You can configure TLS here later if needed
    }
    replicaCount = 2 # Example: number of pods for backend
  }
  # Ensure app deploys after LBC is ready.
  depends_on = [module.aws_load_balancer_controller]
}

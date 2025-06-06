# environments/dev/main.tf

# --- Data Sources (to get existing Jenkins infrastructure details) ---
data "aws_caller_identity" "current" {}

data "aws_vpc" "jenkins_vpc" {
  id = var.jenkins_vpc_id
}

data "aws_subnet" "jenkins_server_subnet" {
  id = var.jenkins_server_subnet_id
}

data "aws_security_group" "jenkins_server_sg" {
  id = var.jenkins_server_security_group_id
}


# --- EKS VPC Module ---
module "vpc" {
  source             = "../../modules/vpc"
  vpc_cidr           = var.eks_vpc_cidr
  public_subnets     = var.eks_public_subnets
  private_subnets    = var.eks_private_subnets
  availability_zones = var.availability_zones
  environment        = var.environment
  cluster_name       = var.cluster_name
}

# --- EKS Cluster Module ---
module "eks" {
  source             = "../../modules/eks" # Your local EKS wrapper module
  cluster_name       = var.cluster_name
  cluster_version    = var.cluster_version
  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnet_ids
  environment        = var.environment
}

# --- VPC Peering Module ---
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
data "aws_route_table" "jenkins_server_rt" {
  subnet_id = data.aws_subnet.jenkins_server_subnet.id
  vpc_id    = data.aws_vpc.jenkins_vpc.id
}


# --- AWS Auth ConfigMap for Jenkins Admin Access ---
# This explicitly creates or updates the 'aws-auth' ConfigMap in the 'kube-system' namespace.
# It grants necessary IAM roles/users access to the Kubernetes cluster.
resource "kubernetes_config_map_v1" "aws_auth" {
  metadata {
    name      = "aws-auth"
    namespace = "kube-system"
  }

  data = {
    mapRoles = jsonencode([
      {
        rolearn  = module.eks.eks_managed_node_groups_default_iam_role_arn
        username = "system:node:{{EC2PrivateDNSName}}"
        groups   = ["system:bootstrappers", "system:nodes"]
      },
      {
        rolearn  = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:instance-profile/${var.jenkins_server_role_name}"
        username = "jenkins-eks-admin"
        groups   = ["system:masters"]
      }
    ])
    mapUsers = jsonencode([])
  }
  depends_on = [module.eks]
}


# --- AWS Load Balancer Controller Module ---
# This module deploys the AWS Load Balancer Controller (LBC) into your EKS cluster.
# The LBC will dynamically provision ALBs based on your Kubernetes Ingress resources.
module "aws_load_balancer_controller" {
  source  = "terraform-aws-modules/aws/aws-load-balancer-controller" # Corrected source
  version = "~> 1.0" # Specify a stable version, e.g., "~> 1.0" or "1.5.0"

  cluster_name                   = module.eks.cluster_name
  cluster_endpoint               = module.eks.cluster_endpoint
  cluster_certificate_authority_data = module.eks.cluster_certificate_authority_data
  vpc_id                         = module.vpc.vpc_id
  region                         = var.aws_region
  service_account_name           = "aws-load-balancer-controller"
  namespace                      = "kube-system"
  irsa_config = {
    enabled = true
  }

  depends_on = [
    module.eks,
    kubernetes_config_map_v1.aws_auth,
  ]
}


# --- Frontend Application Module ---
# This module uses the generic 'app-helm-chart' module to deploy your frontend app.
module "frontend_app" {
  source           = "../../modules/app-helm-chart"
  name             = "frontend"
  namespace        = var.app_namespace
  create_namespace = true
  chart_path       = "helm-charts/frontend"
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
      className = "alb"
      annotations = {
        "alb.ingress.kubernetes.io/scheme"             = "internet-facing"
        "alb.ingress.kubernetes.io/target-type"        = "ip"
        "alb.ingress.kubernetes.io/load-balancer-name" = "${var.environment}-frontend-alb"
        "alb.ingress.kubernetes.io/group.name"         = "${var.environment}-ecommerce-apps"
        "alb.ingress.kubernetes.io/listen-ports"       = "[{\"HTTP\": 80}]"
      }
      hosts = [
        {
          host  = var.frontend_domain_name
          paths = [{ path = "/", pathType = "Prefix" }]
        }
      ]
      tls = []
    }
    replicaCount = 2
  }
  depends_on = [module.aws_load_balancer_controller]
}

# --- Backend Application Module ---
module "backend_app" {
  source           = "../../modules/app-helm-chart"
  name             = "backend"
  namespace        = var.app_namespace
  create_namespace = true
  chart_path       = "helm-charts/backend"
  values = {
    image = {
      repository = var.backend_image_repo
      tag        = var.backend_image_tag
    }
    service = {
      port = var.backend_service_port
    }
    env = {
      MONGO_URL = var.backend_mongo_url
    }
    ingress = {
      enabled   = true
      className = "alb"
      annotations = {
        "alb.ingress.kubernetes.io/scheme"             = "internet-facing"
        "alb.ingress.kubernetes.io/target-type"        = "ip"
        "alb.ingress.kubernetes.io/load-balancer-name" = "${var.environment}-backend-alb"
        "alb.ingress.kubernetes.io/group.name"         = "${var.environment}-ecommerce-apps"
        "alb.ingress.kubernetes.io/listen-ports"       = "[{\"HTTP\": 80}]"
      }
      hosts = [
        {
          host  = var.backend_domain_name
          paths = [{ path = "/", pathType = "Prefix" }]
        }
      ]
      tls = []
    }
    replicaCount = 2
  }
  depends_on = [module.aws_load_balancer_controller]
}

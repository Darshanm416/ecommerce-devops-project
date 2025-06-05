module "vpc" {
  source             = "../../modules/vpc"
  vpc_cidr           = var.vpc_cidr
  public_subnets     = var.public_subnets
  private_subnets    = var.private_subnets
  availability_zones = var.availability_zones
  environment        = var.environment
  cluster_name       = var.cluster_name
}

resource "aws_security_group" "alb" {
  name        = "${var.environment}-alb-sg"
  description = "Security group for ALB"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "Allow HTTP from internet"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.environment}-alb-sg"
  }
}

module "alb" {
  source            = "../../modules/alb"
  environment       = var.environment
  vpc_id            = module.vpc.vpc_id
  public_subnet_ids = module.vpc.public_subnet_ids
  alb_sg_id         = aws_security_group.alb.id
}


module "eks" {
  source          = "../../modules/eks"
  cluster_name    = var.cluster_name
  cluster_version = var.cluster_version
  vpc_id          = module.vpc.vpc_id
  private_subnets = module.vpc.private_subnets
  environment     = var.environment
}

# --- Kubernetes Provider Configuration ---
# This provider allows Terraform to interact with the Kubernetes API
# to manage resources like ConfigMaps.
provider "kubernetes" {
  # These outputs come from your local `modules/eks` wrapper module
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)

  # Use the 'exec' block for robust EKS authentication using AWS CLI.
  # This relies on 'aws' command being available and configured on the machine running Terraform.
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    args        = ["eks", "get-token", "--cluster-name", module.eks.cluster_name, "--region", var.aws_region]
  }

  # Ensure the Kubernetes provider configures ONLY after the EKS cluster is created.
  depends_on = [module.eks]
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
    # mapRoles: Maps AWS IAM roles to Kubernetes RBAC groups.
    # We include both the EKS Node Group Role and your Jenkins Server's IAM Role.
    mapRoles = jsonencode([
      # EKS Worker Node Group Role (Crucial for nodes to join the cluster)
      {
        # The ARN for the default managed node group role created by the EKS module.
        # This output comes from your local `modules/eks` wrapper.
        rolearn  = module.eks.eks_managed_node_groups_default_iam_role_arn 
        username = "system:node:{{EC2PrivateDNSName}}"
        groups   = ["system:bootstrappers", "system:nodes"]
      },
      # Jenkins Server's EC2 Instance Profile Role (for kubectl/helm access from Jenkins)
      {
        # IMPORTANT: Replace YOUR_JENKINS_SERVER_ROLE_NAME with the actual IAM Role Name
        # attached to your Jenkins EC2 instance (e.g., 'jenkins-admin-role').
        # Its full ARN will be: arn:aws:iam::${var.account_id}:instance-profile/YOUR_JENKINS_SERVER_ROLE_NAME
        rolearn  = "arn:aws:iam::${var.account_id}:instance-profile/jenkins-admin-role" 
        username = "jenkins-eks-admin" # Logical name for Kubernetes logs
        groups   = ["system:masters"] # Grants full admin permissions in Kubernetes
      }
    ])
    # mapUsers: (Optional) You can add IAM Users here if needed, but the role is preferred.
    mapUsers = jsonencode([]) 
  }

  # Ensure this ConfigMap is created only after the EKS cluster is fully provisioned.
  depends_on = [module.eks]
}

# --- VPC Peering Module ---
module "vpc_peering" {
  source                  = "../../modules/vpc-peering"
  eks_vpc_id              = module.vpc.vpc_id
  jenkins_vpc_id          = var.jenkins_vpc_id
  eks_route_table_ids     = module.vpc.private_route_table_ids
  jenkins_route_table_id  = var.jenkins_route_table_id
  eks_vpc_cidr            = module.vpc.vpc_cidr
  jenkins_vpc_cidr        = var.jenkins_vpc_cidr
  environment             = var.environment
  # --- ADD THIS NEW ARGUMENT TO THE MODULE CALL ---
  eks_cluster_security_group_id = module.eks.cluster_security_group_id # <--- PASSING THE OUTPUT FROM EKS MODULE
}



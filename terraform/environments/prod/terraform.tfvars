vpc_cidr           = "10.1.0.0/16"
public_subnets     = ["10.1.1.0/24", "10.1.2.0/24"]
availability_zones = ["us-east-1a", "us-east-1b"]
environment        = "prod"
vpc_cidr           = "10.1.0.0/16"
public_subnets     = ["10.1.1.0/24", "10.1.2.0/24"]
availability_zones = ["us-east-1a", "us-east-1b"]
environment        = "prod"

cluster_name       = "ecommerce-eks-prod"
cluster_version    = "1.29"
node_instance_types = ["t3.medium"]
min_size           = 1
max_size           = 3
desired_size       = 2

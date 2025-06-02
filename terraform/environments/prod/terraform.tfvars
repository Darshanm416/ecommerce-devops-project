vpc_cidr           = "10.1.0.0/16"
public_subnets     = ["10.1.1.0/24", "10.1.2.0/24"]
private_subnets    = ["10.1.101.0/24", "10.1.102.0/24"]
availability_zones = ["us-east-1a", "us-east-1b"]
cluster_name       = "ecommerce-prod-eks"
cluster_version    = "1.29"
environment        = "prod"

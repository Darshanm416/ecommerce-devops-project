region                = "us-east-1"
cluster_name          = "ecommerce-eks-dev"
environment           = "dev"
eks_version           = "1.29"

desired_capacity      = 2
min_size              = 1
max_size              = 3
instance_types        = ["t3.medium"]

private_subnet_cidrs  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
public_subnet_cidrs   = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]

tags = {
  Owner       = "devops-team"
  Project     = "ecommerce"
  Environment = "dev"
}

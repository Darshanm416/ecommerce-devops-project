# environments/dev/terraform.tfvars

environment = "dev"
cluster_name = "ecommerce-dev-eks"
cluster_version = "1.29" # Or your desired EKS version
availability_zones = ["us-east-1a", "us-east-1b"] # Or your desired AZs

# EKS VPC Details (ensure these don't overlap with Jenkins VPC)
eks_vpc_cidr = "10.0.0.0/16"
eks_public_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
eks_private_subnets = ["10.0.101.0/24", "10.0.102.0/24"]

# Jenkins Server VPC Details (FILL THESE IN FROM STEP 1)
jenkins_vpc_id = "vpc-0afac25e9d5f745d9"               # YOUR JENKINS VPC ID
jenkins_vpc_cidr = "172.31.0.0/16"                     # YOUR JENKINS VPC CIDR (e.g., 172.31.0.0/16 for default VPC)
jenkins_server_subnet_id = "subnet-071000cc11c216b5c"  # YOUR JENKINS SERVER SUBNET ID
jenkins_server_security_group_id = "sg-0e86dbf3b974d8886" # YOUR JENKINS SERVER SECURITY GROUP ID
jenkins_server_role_name = "jenkins-admin-role" # The NAME of the IAM role (e.g., 'jenkins-admin-role')

aws_region = "us-east-1" # Your AWS Region

# --- APPLICATION-SPECIFIC VALUES (FILL THESE IN!) ---
app_namespace = "ecommerce"

frontend_image_repo = "darshanm416/ecommerce-app-frontend" # REPLACE with your actual frontend Docker image repo
frontend_image_tag = "latest"
frontend_service_port = 80
frontend_domain_name = "frontend.backend.local"

backend_image_repo = "darshanm416/ecommerce-app-backend" # REPLACE with your actual backend Docker image repo
backend_image_tag = "latest"
backend_service_port = 5000
backend_domain_name = "api.backend.local"
backend_mongo_url = "mongodb://mongodb-service:27017/ecommerce"

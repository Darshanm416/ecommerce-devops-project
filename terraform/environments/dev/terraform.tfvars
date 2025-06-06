project             = "sears-devops"
cluster_name        = "sears-eks-cluster"
vpc_cidr            = "10.0.0.0/16"
availability_zones = ["us-east-1a", "us-east-1b"]
public_subnet  = ["10.0.1.0/24", "10.0.2.0/24"]
private_subnet = ["10.0.3.0/24", "10.0.4.0/24"]

kubernetes_version  = "1.29"

jenkins_vpc_id      = "vpc-0afac25e9d5f745d9"
jenkins_vpc_cidr    = "172.31.0.0/16"
jenkins_route_table_ids = ["rtb-093a928b7cbf05ed0"]

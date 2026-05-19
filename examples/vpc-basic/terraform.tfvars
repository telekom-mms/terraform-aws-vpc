// examples/vpc-basic/terraform.tfvars
vpc_cidr            = "10.0.0.0/16"
public_subnet_cidr  = "10.0.1.0/24"
private_subnet_cidr = "10.0.2.0/24"
availability_zone   = "eu-central-1a"
name_prefix         = "example"

tags = {
  Environment = "dev"
  Owner       = "terraform"
  Project     = "vpc-example"
}

enable_flow_logs = false
# flow_log_destination_arn = "arn:aws:logs:eu-central-1:123456789012:log-group:vpc-flow-logs"
# flow_log_iam_role_arn = "arn:aws:iam::123456789012:role/vpc-flow-logs-role"
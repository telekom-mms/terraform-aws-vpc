# Basic VPC Example

This example demonstrates how to use the `terraform-aws-vpc` module to create a basic VPC with public and private subnets.

## Usage

```bash
# Initialize Terraform
terraform init

# Review the plan
terraform plan

# Apply the configuration
terraform apply

# Clean up when done
terraform destroy
```

## Requirements

- Terraform >= 0.13.0
- AWS provider >= 3.0.0
- AWS credentials configured

## Inputs

| Name | Description | Default |
|------|-------------|---------|
| vpc_cidr | CIDR block for the VPC | 10.0.0.0/16 |
| public_subnet_cidr | CIDR block for the public subnet | 10.0.1.0/24 |
| private_subnet_cidr | CIDR block for the private subnet | 10.0.2.0/24 |
| availability_zone | AWS Availability Zone | eu-central-1a |
| name_prefix | Prefix for resource names | example |
| tags | Additional tags for all resources | Environment = "dev", Owner = "terraform", Project = "vpc-example" |
| enable_flow_logs | Enable VPC Flow Logs | false |
| flow_log_destination_arn | ARN of the CloudWatch Log Group for Flow Logs | null |
| flow_log_iam_role_arn | IAM Role ARN for Flow Logs | null |

## Outputs

| Name | Description |
|------|-------------|
| vpc_id | ID of the created VPC |
| public_subnet_id | ID of the public subnet |
| private_subnet_id | ID of the private subnet |
| internet_gateway_id | ID of the Internet Gateway |
| public_route_table_id | ID of the public route table |
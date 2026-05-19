// examples/vpc-basic/variables.tf
variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  description = "CIDR block for the public subnet"
  type        = string
  default     = "10.0.1.0/24"
}

variable "private_subnet_cidr" {
  description = "CIDR block for the private subnet"
  type        = string
  default     = "10.0.2.0/24"
}

variable "availability_zone" {
  description = "AWS Availability Zone"
  type        = string
  default     = "eu-central-1a"
}

variable "name_prefix" {
  description = "Prefix for resource names"
  type        = string
  default     = "example"
}

variable "tags" {
  description = "Additional tags for all resources"
  type        = map(string)
  default = {
    Environment = "dev"
    Owner       = "terraform"
    Project     = "vpc-example"
  }
}

variable "enable_flow_logs" {
  description = "Enable VPC Flow Logs"
  type        = bool
  default     = false
}

variable "flow_log_destination_arn" {
  description = "ARN of the CloudWatch Log Group for Flow Logs"
  type        = string
  default     = null
}

variable "flow_log_iam_role_arn" {
  description = "IAM Role ARN for Flow Logs"
  type        = string
  default     = null
}
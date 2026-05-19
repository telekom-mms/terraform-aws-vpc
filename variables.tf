// variables.tf

variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "environment" {
  description = "Environment (e.g., prod, dev, test)"
  type        = string
}

variable "name_prefix" {
  description = "Prefix for resource names (if not provided, will use project-environment pattern)"
  type        = string
  default     = ""
}


variable "tags" {
  description = "Additional tags for all resources"
  type        = map(string)
  default     = {}
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnets" {
  description = "List of public subnet CIDRs"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnets" {
  description = "List of private subnet CIDRs"
  type        = list(string)
  default     = ["10.0.10.0/24", "10.0.11.0/24"]
}

variable "database_subnets" {
  description = "List of database subnet CIDRs"
  type        = list(string)
  default     = ["10.0.20.0/24", "10.0.21.0/24"]
}

variable "availability_zones" {
  description = "List of availability zones to use"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
}

variable "enable_nat_gateway" {
  description = "Whether to create NAT Gateways for private subnets"
  type        = bool
  default     = true
}

variable "single_nat_gateway" {
  description = "Should be true if you want to provision a single shared NAT Gateway across all of your private networks"
  type        = bool
  default     = false # Best practice: one per AZ for high availability
}

variable "enable_flow_logs" {
  description = "Whether to enable VPC Flow Logs"
  type        = bool
  default     = true # PSA Req 5 (Logging is mandatory)
}

variable "flow_log_retention_days" {
  description = "Retention in days for VPC Flow Logs in CloudWatch"
  type        = number
  default     = 30
}

variable "flow_log_destination_type" {
  description = "Type of destination for flow logs (cloud-watch-logs or s3)"
  type        = string
  default     = "cloud-watch-logs"

  validation {
    condition     = contains(["cloud-watch-logs", "s3"], var.flow_log_destination_type)
    error_message = "flow_log_destination_type must be either cloud-watch-logs or s3."
  }
}

variable "flow_log_destination_arn" {
  description = "ARN of the CloudWatch Logs destination for flow logs (if empty, a CloudWatch Log Group will be created)"
  type        = string
  default     = ""
}

variable "flow_log_s3_bucket_arn" {
  description = "ARN of the S3 bucket for VPC Flow Logs when flow_log_destination_type is s3"
  type        = string
  default     = ""
}

variable "kms_key_arn" {
  description = "KMS key ARN for Flow Logs encryption"
  type        = string
  default     = ""
}

variable "create_database_subnet_group" {
  description = "Whether to create a database subnet group"
  type        = bool
  default     = true
}

variable "enable_dns_hostnames" {
  description = "Whether to enable DNS hostnames in the VPC"
  type        = bool
  default     = true
}

variable "enable_dns_support" {
  description = "Whether to enable DNS support in the VPC"
  type        = bool
  default     = true
}

// examples/vpc-basic/main.tf
provider "aws" {
  region = "eu-central-1"
}

module "vpc" {
  source = "../../"

  vpc_cidr            = var.vpc_cidr
  public_subnet_cidr  = var.public_subnet_cidr
  private_subnet_cidr = var.private_subnet_cidr
  availability_zone   = var.availability_zone
  name_prefix         = var.name_prefix
  tags                = var.tags

  enable_flow_logs         = var.enable_flow_logs
  flow_log_destination_arn = var.flow_log_destination_arn
  flow_log_iam_role_arn    = var.flow_log_iam_role_arn
}
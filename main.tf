// main.tf
# Written by Marc Straubinger - Overhauled for Security-First Best Practices

# VPC
resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = var.enable_dns_support
  enable_dns_hostnames = var.enable_dns_hostnames

  tags = merge(var.tags, {
    "Name"          = "${local.name_prefix}-vpc"
    "PSA-Compliant" = "true"
  })
}

# Public Subnets
resource "aws_subnet" "public" {
  count                   = length(var.public_subnets)
  vpc_id                  = aws_vpc.this.id
  cidr_block              = var.public_subnets[count.index]
  availability_zone       = var.availability_zones[count.index % length(var.availability_zones)]
  map_public_ip_on_launch = false # Security first: don't auto-assign public IPs

  tags = merge(var.tags, {
    "Name"          = "${local.name_prefix}-subnet-public-${count.index + 1}"
    "Type"          = "Public"
    "PSA-Compliant" = "true"
  })
}

# Private Subnets
resource "aws_subnet" "private" {
  count             = length(var.private_subnets)
  vpc_id            = aws_vpc.this.id
  cidr_block        = var.private_subnets[count.index]
  availability_zone = var.availability_zones[count.index % length(var.availability_zones)]

  tags = merge(var.tags, {
    "Name"          = "${local.name_prefix}-subnet-private-${count.index + 1}"
    "Type"          = "Private"
    "PSA-Compliant" = "true"
  })
}

# Database Subnets
resource "aws_subnet" "database" {
  count             = length(var.database_subnets)
  vpc_id            = aws_vpc.this.id
  cidr_block        = var.database_subnets[count.index]
  availability_zone = var.availability_zones[count.index % length(var.availability_zones)]

  tags = merge(var.tags, {
    "Name"          = "${local.name_prefix}-subnet-db-${count.index + 1}"
    "Type"          = "Database"
    "PSA-Compliant" = "true"
  })
}

# Database Subnet Group
resource "aws_db_subnet_group" "database" {
  count      = var.create_database_subnet_group && length(var.database_subnets) > 0 ? 1 : 0
  name       = "${local.name_prefix}-db-subnet-group"
  subnet_ids = aws_subnet.database[*].id

  tags = merge(var.tags, {
    "Name"          = "${local.name_prefix}-db-subnet-group"
    "PSA-Compliant" = "true"
  })
}

# Internet Gateway
resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = merge(var.tags, {
    "Name"          = "${local.name_prefix}-igw"
    "PSA-Compliant" = "true"
  })
}

# NAT Gateway
resource "aws_eip" "nat" {
  count  = var.enable_nat_gateway ? (var.single_nat_gateway ? 1 : length(var.public_subnets)) : 0
  domain = "vpc"

  tags = merge(var.tags, {
    "Name"          = "${local.name_prefix}-nat-eip-${count.index + 1}"
    "PSA-Compliant" = "true"
  })
}

resource "aws_nat_gateway" "this" {
  count         = var.enable_nat_gateway ? (var.single_nat_gateway ? 1 : length(var.public_subnets)) : 0
  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public[count.index].id

  tags = merge(var.tags, {
    "Name"          = "${local.name_prefix}-nat-gw-${count.index + 1}"
    "PSA-Compliant" = "true"
  })

  depends_on = [aws_internet_gateway.this]
}

# Route Tables
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this.id
  }

  tags = merge(var.tags, {
    "Name"          = "${local.name_prefix}-rt-public"
    "PSA-Compliant" = "true"
  })
}

resource "aws_route_table" "private" {
  count  = var.enable_nat_gateway ? (var.single_nat_gateway ? 1 : length(var.private_subnets)) : 1
  vpc_id = aws_vpc.this.id

  dynamic "route" {
    for_each = var.enable_nat_gateway ? [1] : []
    content {
      cidr_block     = "0.0.0.0/0"
      nat_gateway_id = aws_nat_gateway.this[var.single_nat_gateway ? 0 : count.index].id
    }
  }

  tags = merge(var.tags, {
    "Name"          = "${local.name_prefix}-rt-private-${count.index + 1}"
    "PSA-Compliant" = "true"
  })
}

# Route Table Associations
resource "aws_route_table_association" "public" {
  count          = length(var.public_subnets)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private" {
  count          = length(var.private_subnets)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[var.single_nat_gateway ? 0 : count.index].id
}

resource "aws_route_table_association" "database" {
  count          = length(var.database_subnets)
  subnet_id      = aws_subnet.database[count.index].id
  route_table_id = aws_route_table.private[var.single_nat_gateway ? 0 : (count.index % length(aws_route_table.private))].id
}

# VPC Flow Logs
# PSA Compliance: Req 5 (Logging is mandatory)
resource "aws_cloudwatch_log_group" "flow_logs" {
  count             = var.enable_flow_logs && var.flow_log_destination_arn == "" && var.flow_log_destination_type == "cloud-watch-logs" ? 1 : 0
  name              = "/aws/vpc/${local.name_prefix}-flow-logs"
  retention_in_days = var.flow_log_retention_days
  kms_key_id        = var.kms_key_arn

  tags = merge(var.tags, {
    "Name"          = "/aws/vpc/${local.name_prefix}-flow-logs"
    "PSA-Compliant" = "true"
  })
}

resource "aws_iam_role" "flow_logs" {
  count = var.enable_flow_logs && var.flow_log_destination_type == "cloud-watch-logs" ? 1 : 0
  name  = "${local.name_prefix}-flow-logs-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "vpc-flow-logs.amazonaws.com"
        }
      }
    ]
  })

  tags = merge(var.tags, {
    "Name"          = "${local.name_prefix}-flow-logs-role"
    "PSA-Compliant" = "true"
  })
}

resource "aws_iam_role_policy" "flow_logs" {
  count = var.enable_flow_logs && var.flow_log_destination_type == "cloud-watch-logs" ? 1 : 0
  name  = "flow-logs-policy"
  role  = aws_iam_role.flow_logs[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogGroups",
          "logs:DescribeLogStreams"
        ]
        Effect   = "Allow"
        Resource = "*"
      }
    ]
  })
}

resource "aws_flow_log" "this" {
  count                = var.enable_flow_logs ? 1 : 0
  log_destination      = var.flow_log_destination_arn != "" ? var.flow_log_destination_arn : aws_cloudwatch_log_group.flow_logs[0].arn
  log_destination_type = var.flow_log_destination_type
  traffic_type         = "ALL"
  vpc_id               = aws_vpc.this.id
  iam_role_arn         = var.flow_log_destination_type == "cloud-watch-logs" ? aws_iam_role.flow_logs[0].arn : null

  tags = merge(var.tags, {
    "Name"          = "${local.name_prefix}-flow-logs"
    "PSA-Compliant" = "true"
  })
}

# Harden Default Security Group
resource "aws_default_security_group" "default" {
  vpc_id = aws_vpc.this.id

  # No rules defined = Deny all ingress and egress
  # PSA Compliance: Req 6 (Restrictive management access)

  tags = merge(var.tags, {
    "Name"          = "${local.name_prefix}-default-sg"
    "Description"   = "Hardened default SG (deny all)"
    "PSA-Compliant" = "true"
  })
}

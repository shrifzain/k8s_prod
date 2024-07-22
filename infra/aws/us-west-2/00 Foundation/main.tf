################################################################################
#  provider
################################################################################

provider "aws" {
  region = local.region
}


################################################################################
# data
################################################################################

data "aws_partition" "current" {}
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}
data "aws_availability_zones" "available" {}


################################################################################
# locals
################################################################################

locals {
  name = "${var.prefix}${var.name}-infra"
  vpc_cidr = "10.0.0.0/16"
  region = "us-west-2"
  tags = {
    Region      = data.aws_region.current.name
    Environment = var.environment
    Owner       = var.owner
    Project     = "task-widebot-v1"
    Stage       = "NETWORK"
    CostCenter  = "GENERAL"
  }
  azs = slice(data.aws_availability_zones.available.names, 0, 2)
}

################################################################################
# VPC Module
################################################################################

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  version = "~> 4.0"

  name = local.name
  cidr = local.vpc_cidr

  azs                 = local.azs
  private_subnets     = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k)]
  public_subnets      = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k + 4)]
  intra_subnets       = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k + 20)]

  

  

  enable_nat_gateway = true
  single_nat_gateway = true

  

  # VPC Flow Logs (Cloudwatch log group and IAM role will be created)
  enable_flow_log                      = true
  create_flow_log_cloudwatch_log_group = true
  create_flow_log_cloudwatch_iam_role  = true
  flow_log_max_aggregation_interval    = 60

  tags = local.tags
}
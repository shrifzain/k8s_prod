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
data "terraform_remote_state" "vpc"{
  backend ="s3" 
  config = {
    bucket         = "terraform-state-full"       # Replace with your S3 bucket name
    key            = "terraform-foundation/state.tfstate"  # Path to the state file within the bucket
    region         = "us-west-2"                # Replace with your AWS region  
    
  }
    
}


################################################################################
# locals
################################################################################

locals {
  name_prefix = "${var.prefix}-${var.name}-mysql-db"
  vpc_cidr = "10.0.0.0/16"
  region = "us-west-2"
  tags = {
    Region      = data.aws_region.current.name
    Environment = var.environment
    Owner       = var.owner
    Project     = "maagment-user"
    Stage       = "databases"
    CostCenter  = "databases"
  }
}

################################################################################
# VPC Module
################################################################################

module "db" {
  source = "terraform-aws-modules/rds/aws"

  identifier = local.name_prefix

  # All available versions: http://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/CHAP_MySQL.html#MySQL.Concepts.VersionMgmt
  engine               = "mysql"
  engine_version       = "8.0"
  family               = "mysql8.0" # DB parameter group
  major_engine_version = "8.0"      # DB option group
  instance_class       = "db.t3.micro"

  allocated_storage     = 20
  max_allocated_storage = 100

  db_name  = "mangment"
  username = "shrief"
  port     = 3306


  # setting manage_master_user_password_rotation to false after it
  # has been set to true previously disables automatic rotation
  # manage_master_user_password_rotation              = true
  # master_user_password_rotate_immediately           = false
  # master_user_password_rotation_schedule_expression = "rate(30 days)"
  multi_az                                          = false

  create_db_subnet_group      = true
  subnet_ids                  = data.terraform_remote_state.vpc.outputs.private_subnets
  vpc_security_group_ids      = [module.security_group.security_group_id]
  db_subnet_group_name        = local.name_prefix
  

  maintenance_window              = "Mon:00:00-Mon:03:00"
  backup_window                   = "03:00-06:00"
  enabled_cloudwatch_logs_exports = ["general"]
  create_cloudwatch_log_group     = true

  skip_final_snapshot = true
  deletion_protection = false

  performance_insights_enabled          = true
  performance_insights_retention_period = 7
  create_monitoring_role                = true
  monitoring_interval                   = 60

  # parameters = [
  #   {
  #     name  = "character_set_client"
  #     value = "utf8mb4"
  #   },
  #   {
  #     name  = "character_set_server"
  #     value = "utf8mb4"
  #   }
  # ]

  tags = local.tags
  # db_instance_tags = {
  #   "Sensitive" = "high"
  # }
  # db_option_group_tags = {
  #   "Sensitive" = "low"
  # }
  # db_parameter_group_tags = {
  #   "Sensitive" = "low"
  # }
  # db_subnet_group_tags = {
  #   "Sensitive" = "high"
  # }
}
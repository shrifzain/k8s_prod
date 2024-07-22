################################################################################
#  provider
################################################################################

provider "aws" {
  region = local.region
}

provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    # This requires the awscli to be installed locally where Terraform is executed
    args = ["eks", "get-token", "--cluster-name", module.eks.cluster_name]
  }
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
  name_prefix = "${var.prefix}-${var.name}-eks"
  vpc_cidr = "10.0.0.0/16"
  region = "us-west-2"
  tags = {
    Region      = data.aws_region.current.name
    Environment = var.environment
    Owner       = var.owner
    Project     = "task-widebot"
    Stage       = "eks"
    CostCenter  = "eks"
  }
}



################################################################################
# EKS Module
################################################################################
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "20.8.3"

  cluster_name                    = local.name_prefix
  cluster_version                 = "1.28"
  cluster_endpoint_public_access  = true
  cluster_endpoint_private_access = true

  # IPV4
  cluster_ip_family = "ipv4"

  create_cni_ipv6_iam_policy = true

  # cloudwatch_log_group_kms_key_id
  cluster_addons = {
    coredns = {
      most_recent = true
    }
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      most_recent              = true
      before_compute           = true
      service_account_role_arn = module.vpc_cni_irsa_role.iam_role_arn
      configuration_values     = jsonencode({
        env = {
          # Reference docs https://docs.aws.amazon.com/eks/latest/userguide/cni-increase-ip-addresses.html
          ENABLE_PREFIX_DELEGATION = "true"
          WARM_PREFIX_TARGET       = "1"
        }
      })
    }
    aws-ebs-csi-driver = {
      most_recent              = true
      service_account_role_arn = module.ebs_csi_irsa_role.iam_role_arn
    }
  }

  vpc_id                   = data.terraform_remote_state.vpc.outputs.vpc_id
  subnet_ids               = data.terraform_remote_state.vpc.outputs.private_subnets
  control_plane_subnet_ids = data.terraform_remote_state.vpc.outputs.intra_subnets

  eks_managed_node_group_defaults = {
    ami_type                   = "AL2_x86_64"
    instance_types             = ["t3.small"]
    iam_role_attach_cni_policy = true
  }

  eks_managed_node_groups = {
    # Default node group - as provided by AWS EKS
    tf_default_node_group = {
      use_custom_launch_template = false
      min_size                   = "1"
      max_size                   = "2"
      desired_size               = "2"

      disk_size ="20"

      tags = merge(local.tags, {
        Name = "tf-mangment-eks-node-group"
      })
    }
  }

  tags = merge(local.tags, {
    Name = local.name_prefix
  })
  enable_cluster_creator_admin_permissions = true
}
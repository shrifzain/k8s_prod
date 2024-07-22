################################################################################
#  provider
################################################################################

provider "aws" {
  region = local.region
}
provider "kubernetes" {
  host                   = data.terraform_remote_state.eks.outputs.cluster_endpoint
  cluster_ca_certificate = base64decode(data.terraform_remote_state.eks.outputs.cluster_certificate_authority_data)

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    # This requires the awscli to be installed locally where Terraform is executed
    args = ["eks", "get-token", "--cluster-name", data.terraform_remote_state.eks.outputs.cluster_name]
  }
}

provider "helm" {
  kubernetes {
    host                   = data.terraform_remote_state.eks.outputs.cluster_endpoint
    cluster_ca_certificate = base64decode(data.terraform_remote_state.eks.outputs.cluster_certificate_authority_data)
    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      args        = ["eks", "get-token", "--cluster-name", data.terraform_remote_state.eks.outputs.cluster_name]
      command     = "aws"
    }
  }
}

################################################################################
# data
################################################################################

data "aws_partition" "current" {}
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}
data "aws_availability_zones" "available" {}
data "terraform_remote_state" "eks" {
  backend = "s3"
  config = {
    bucket = "terraform-state-full"
    key = "terraform-eks/state.tfstate"
    region = "us-west-2"
  }
}

################################################################################
# locals
################################################################################

locals {
  name = "${var.prefix}${var.name}-infra-app"
  
  region = "us-west-2"
  tags = {
    Region      = data.aws_region.current.name
    Environment = var.environment
    Owner       = var.owner
    Project     = "task-widebot"
    Stage       = "platform_app"
    CostCenter  = "GENERAL"
  }
  azs = slice(data.aws_availability_zones.available.names, 0, 2)
}

###############################################################################
## issuer
###############################################################################
resource "kubernetes_manifest" "clusterissuer" {
  depends_on = [helm_release.cert_manager]
  manifest = {
    "apiVersion" = "cert-manager.io/v1"
    "kind"       = "ClusterIssuer"
    "metadata"   = {
      "name" = "letsencrypt-task"
    }
    "spec" = {
      "acme" = {
        "email"               = "shrifzain85@gmail.com"
        "privateKeySecretRef" = {
          "name" = "letsencrypt-task"
        }
        "server"  = "https://acme-v02.api.letsencrypt.org/directory"
        "solvers" = [
          {
            "http01" = {
              "ingress" = {
                "class" = "nginx"
              }
            }
          },
        ]
      }
    }
  }
}

################################################################################
# helm_app
################################################################################
resource "helm_release" "ingress-nginx" {
  name       = "ingress-nginx"
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"
  version    = "4.10.0"
  values = [
    "${file("helm_values/ingress-nginx.yaml")}"  
    
  ]

  
}
resource "helm_release" "cert_manager" {
  name             = "cert-manager"
  repository       = "https://charts.jetstack.io"
  chart            = "cert-manager"
  namespace        = "cert-manager"
  version          = "1.13.3"
  create_namespace = true

  values = [
    file("helm_values/cert-manager.yaml")
  ]
}

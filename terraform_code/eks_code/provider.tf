terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.46.0"
    }
  }

  required_version = ">= 1.3.0"
}


locals {
  region = "eu-west-2"
  name   = "amazon-prime-cluster"
  vpc_cidr = "10.0.0.0/16"
  azs      = ["eu-west-2a", "eu-west-2b"]
  public_subnets  = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnets = ["10.0.3.0/24", "10.0.4.0/24"]
  intra_subnets   = ["10.0.5.0/24", "10.0.6.0/24"]
  tags = {
    Example = local.name
  }
}

provider "aws" {
  region = "eu-west-2"
}

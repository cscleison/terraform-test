terraform {

  backend "s3" {
    bucket = "node-terraform"
    key    = "node-infra"
    region = "eu-west-1"
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.27"
    }
  }
  required_version = ">= 1.2.0"
}

provider "aws" {
  region     = "eu-west-1"
}

provider "aws" {
  region = "us-east-1"
}

terraform {
  required_version = ">= 1.8"

  backend "local" {
    path = "dev/vpc/terraform.tfstate"
  }

  required_providers {
    aws = {
        source = "hashicorp/aws"
        version = "~> 5.52"
    }
  }
}
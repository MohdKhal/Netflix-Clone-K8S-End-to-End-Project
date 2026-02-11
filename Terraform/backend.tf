terraform {
  required_version = "~> 1.12.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.14.1"
    }
  }

  cloud {
    organization = "ibrahim-khaleel"

    workspaces {
      name = "netflix-clone-project"
    }
  }
}

provider "aws" {
  region = var.aws_region
}


terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  backend "s3" {
    bucket = "artifactsjoao.mangilli"
    region = "us-east-2"
    key = "terraform"
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region = "us-east-2"
}

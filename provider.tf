
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.71.0"
    }
    template = {
      source  = "hashicorp/template"
      version = "~> 2.2.0"
    }
  }
  required_version = "~> 1.1"
}


provider "aws" {
  region = local.config.region

  /*   Reviewing operation here as some resources can not be excluded 
  default_tags {
   tags = {
     Environment = "Dev"
     Owner       = "terraform-networks"
     Project     = "centralised-services"
   }
 } */
}
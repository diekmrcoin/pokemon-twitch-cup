terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.36"
    }
  }
  backend "s3" {
    bucket = "ptc-tf-states"
    key    = "pokemon-twitch-cup-state"
    region = "eu-west-3"
  }
  required_version = "~>1.3.3"
}

provider "aws" {
  region = "eu-west-3"
  default_tags {
    tags = {
      "Deploy"  = "terraform"
      "Project" = "pokemon twitch cup"
    }
  }
}

module "pokemontwitchcup" {
  source = "./pokemontwitchcup.com"
}

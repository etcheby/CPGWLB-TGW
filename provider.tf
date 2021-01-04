terraform {
  backend "remote" {
    organization = ""

    workspaces {
      name = ""
    }
  }
}

provider "aws" {
  region = "us-west-2"
}

provider "aws" {
  region = "us-east-2"
}

terraform {
  required_version = ">=0.13.5"
  # Note: as for the version, the one that is specified is simply the one that was used during development – but
  # setting this to some lower version should probably be fine, as long as it is equal or above 12.X (which introduced
  # quite a lot breaking changes)

  # Note: variables can't be used here.
  backend "s3" {
    region = "us-east-2"
    bucket = "putnet-example-terraform-remote-state"
    key = "putnet-example-terraform-remote-state/terraform.tfstate"
    dynamodb_table = "putnet-example-terraform-remote-state"
    encrypt = true
  }
}



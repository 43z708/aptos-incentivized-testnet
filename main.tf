terraform {
  required_version = "~> 1.1.0"
  backend "s3" {
    bucket = "terraform.aptos-node"
    key    = "state/aptos-node"
    region = "${var.AWS_DEFAULT_REGION}"
  }
}

provider "aws" {
  region = "${var.AWS_DEFAULT_REGION}"
}

module "aptos-node" {
  # download Terraform module from aptos-labs/aptos-core repo
  source        = "github.com/aptos-labs/aptos-core.git//terraform/aptos-node/aws?ref=main"
  region        = "${var.AWS_DEFAULT_REGION}"  # Specify the region
  # zone_id     = "<Route53 zone id>"  # zone id for Route53 if you want to use DNS
  era           = 1              # bump era number to wipe the chain
  chain_id      = 23
  image_tag     = "testnet" # Specify the docker image tag to use
  validator_name = "${var.VALIDATOR_NAME}"
}
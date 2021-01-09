###
# The project is hosted on DigitalOcean, so we need to configure
# terraform to know about their provider.
###

terraform {
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "2.3.0"
    }
  }
}


###
# Load in the secrets so we can log in to DigitalOcean.
###

variable "do_token" {}
variable "do_sp_access" {}
variable "do_sp_secret" {}

provider "digitalocean" {
  token             = var.do_token
  spaces_access_id  = var.do_sp_access
  spaces_secret_key = var.do_sp_secret
}


###
# Configure terraform to use a DigitalOcean 'S3' bucket as the state
# store.
###

terraform {
  backend "s3" {
    bucket                      = "activetravel-inverness-state"
    endpoint                    = "ams3.digitaloceanspaces.com"
    workspace_key_prefix        = "environments"
    key                         = "environment.tfstate"
    skip_credentials_validation = true
    skip_metadata_api_check     = true
    skip_region_validation      = true
    region                      = "ams3"
  }
}

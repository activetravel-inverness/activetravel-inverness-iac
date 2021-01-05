###
# The project is hosted on DigitalOcean, so we need to configure terraform to know about their provider.
###

terraform {
  required_providers {
    digitalocean = {
      source = "digitalocean/digitalocean"
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
  token = var.do_token
  spaces_access_id = var.do_sp_access
  spaces_secret_key = var.do_sp_secret
}


###
# Create a project for all of the resources to live inside.
###

resource "digitalocean_project" "ati" {
  name        = "activetravel-inverness"
  description = ""
  purpose     = "Service or API"
  environment = "Development"
}


###
# Create a DigitalOcean 'S3' bucket to store the terraform state in.
###

resource "digitalocean_spaces_bucket" "ati-tf-state" {
  name   = "activetravel-inverness-tf-state"
  region = "ams3"
  acl = "private"
  force_destroy = false
}
resource "digitalocean_project_resources" "ati-state" {
  project = digitalocean_project.ati.id
  resources = [
    digitalocean_spaces_bucket.ati-tf-state.urn
  ]
}


###
# Configure terraform to use the 's3' bucket as the state store.
###

terraform {
  backend "s3" {
    bucket = "activetravel-inverness-tf-state"    
    endpoint = "ams3.digitaloceanspaces.com"
    key    = "administrative"
    skip_requesting_account_id = true
    skip_credentials_validation = true
    skip_get_ec2_platforms = true
    skip_metadata_api_check = true    
    skip_region_validation = true
    region = "ams3"
  }
}


###
# Tell DigitalOcean to look after our DNS records.
###

resource "digitalocean_domain" "orguk" {
    name = "activetravel-inverness.org.uk"
}
resource "digitalocean_project_resources" "ati-orguk" {
  project = digitalocean_project.ati.id
  resources = [
    digitalocean_domain.orguk.urn
  ]
}

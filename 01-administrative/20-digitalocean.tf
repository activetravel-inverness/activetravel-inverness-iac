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
  name          = "activetravel-inverness-state"
  region        = "ams3"
  acl           = "private"
  force_destroy = false
}
resource "digitalocean_project_resources" "ati-state" {
  project = digitalocean_project.ati.id
  resources = [
    digitalocean_spaces_bucket.ati-tf-state.urn
  ]
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
 

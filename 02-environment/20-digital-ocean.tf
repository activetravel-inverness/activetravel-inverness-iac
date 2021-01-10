###
# Load in information about the project.
###

data "digitalocean_project" "ati" {
  name = "activetravel-inverness"
}


###
# Create an extra storage space for persisting runtime data.
###

resource "digitalocean_volume" "server-storage" {
  region                  = "ams3"
  name                    = "serverstorage"
  size                    = 5
  initial_filesystem_type = "ext4"
}
resource "digitalocean_project_resources" "ati-server-storage" {
  project = data.digitalocean_project.ati.id
  resources = [
    digitalocean_volume.server-storage.urn
  ]
  depends_on = [
    digitalocean_volume.server-storage
  ]
}


###
# Load in information about the SSH Key.
###

data "digitalocean_ssh_key" "ati-key" {
  name = "ActiveTravel Inverness"
}


###
# Read in and parse the cloudinit config.
###

data "template_file" "user_group" {
  template = "${file("cloud-init.yaml")}"
  vars = {
    activetravel_inverness_ssh_public_key = data.digitalocean_ssh_key.ati-key.public_key
  }
}
data "template_cloudinit_config" "user_group" {
  base64_encode = false
  gzip          = false
  part {
    content_type = "text/cloud-config"
    content      = "${data.template_file.user_group.rendered}"
    merge_type   = "list(append)+dict(recurse_array)+str()"
  }
}


###
# Create the app server.
###

resource "digitalocean_droplet" "server" {
  image       = "debian-10-x64"
  name        = "${terraform.workspace}-server"
  region      = "ams3"
  size        = "s-1vcpu-1gb"
  resize_disk = false
  ipv6        = true
  monitoring  = true
  ssh_keys = [
    data.digitalocean_ssh_key.ati-key.id
  ]
  user_data = data.template_cloudinit_config.user_group.rendered
}
resource "digitalocean_project_resources" "ati-server" {
  project = data.digitalocean_project.ati.id
  resources = [
    digitalocean_droplet.server.urn
  ]
  depends_on = [
    digitalocean_droplet.server
  ]
}


###
# Attach the persistence volume to the app server.
###

resource "digitalocean_volume_attachment" "ati-server-storage" {
  droplet_id = digitalocean_droplet.server.id
  volume_id  = digitalocean_volume.server-storage.id
}

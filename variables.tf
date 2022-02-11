variable "image_id" {
  type        = string
  description = "The id of the machine image (AMI) to use for the server."
}

variable "snapshot_identifier_id" {
  type        = string
  description = "The ID of the data base snapshot to be used for provisioning"
}

variable "keypair_name" {
  type        = string
  description = "You need a premade key pair in your region to use to encrypt the Ec2 instaance passwords"
}


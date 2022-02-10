variable "image_id" {
  type        = string
  description = "The id of the machine image (AMI) to use for the server."
}

variable "database_password" {
  type        = string
  description = "The password to be used to connect to the database"
}

variable "keypair_name" {
  type        = string
  description = "The password to be used to connect to the database"
}

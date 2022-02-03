data "terraform_remote_state" "local" {
  backend = "local"

  config = {
    path = "terraform.tfstate"
  }
}

variable "image_id" {
  type        = string
  description = "The id of the machine image (AMI) to use for the server."
}


locals {
  default_tags = {
    provisioner = "terraform"
  }

  tags = merge(var.custom_tags, local.default_tags)


}
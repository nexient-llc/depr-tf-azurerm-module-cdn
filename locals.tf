locals {
  default_tags = {
    provisioner = "terraform"
  }

  # custom_domain_host_name should be <cname_record>.<dns_zone> when enable_custom_domain = true. If dns_zone is empty, then cname_record must be fqdn
  custom_domain_host_name = var.custom_domain.enable_custom_domain ? (coalesce(var.custom_domain.dns_zone, "unset") != "unset" ? "${var.custom_domain.cname_record}.${var.custom_domain.dns_zone}" : var.custom_domain.cname_record) : ""

  tags = merge(var.custom_tags, local.default_tags)


}
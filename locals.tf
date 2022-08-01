locals {
  default_tags = {
    provisioner = "terraform"
  }
  
  # custom_domain_host_name = <cname_record>.<dns_zone>
  custom_domain_host_name = var.cname_record != "" ? "${var.cname_record}.${data.azurerm_dns_zone.dns_zone[0].name}" : ""

  tags = merge(var.custom_tags, local.default_tags)


}
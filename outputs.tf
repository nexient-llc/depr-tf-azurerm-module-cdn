output "cdn_profile_id" {
  description = "The ID of the CDN profile"
  value       = azurerm_cdn_profile.cdn_profile.id
}

output "cdn_endpoint_id" {
  description = "The ID of the CDN Endpoint"
  value       = azurerm_cdn_endpoint.endpoint.id
}

output "cdn_profile_name" {
  description = "The name of the CDN profile"
  value       = azurerm_cdn_profile.cdn_profile.name
}

output "cdn_endpoint_name" {
  description = "The name of the CDN Endpoint"
  value       = azurerm_cdn_endpoint.endpoint.name
}


output "dns_cname_fqdn" {
  description = "The fully quantified domain name of the custom domain attached to the CDN endpoint, if the custom_domain.create_cname_record = true"
  value       = try(azurerm_dns_cname_record.cname_record[0].fqdn, null)
}
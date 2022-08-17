variable "resource_group" {
  description = "target resource group resource mask"
  type = object({
    name     = string
    location = string
  })
  default = {
    name     = "deb-test-devops"
    location = "eastus"
  }
}

variable "cdn_profile_name" {
  description = "Name of the CDN profile"
  type        = string
}

variable "sku" {
  description = "SKU of the CDN profile"
  type        = string
  default     = "Standard_Microsoft"

  validation {
    condition     = (contains(["Standard_Microsoft", "Standard_Akamai", "Standard_ChinaCdn", "Standard_Verizon", "Premium_Verizon"], var.sku))
    error_message = "The sku must be either \"Standard_Microsoft\" or \"Standard_Akamai\" or \"Standard_ChinaCdn\" or \"Standard_Verizon\" or \"Premium_Verizon\"."
  }
}

##### Variables related to endpoint

# Currently supports only 1 endpoint per profile
variable "cdn_endpoint_name" {
  description = "Name of the CDN endpoint"
  type        = string
}

variable "is_http_allowed" {
  description = "Is http allowed for the endpoint"
  type        = bool
  default     = true
}

variable "is_https_allowed" {
  description = "Is https allowed for the endpoint"
  type        = bool
  default     = true
}

variable "querystring_caching_behaviour" {
  description = "Among the values IgnoreQueryString, BypassCaching and UseQueryString"
  type        = string
  default     = "IgnoreQueryString"
  validation {
    condition     = (contains(["IgnoreQueryString", "BypassCaching", "UseQueryString"], var.querystring_caching_behaviour))
    error_message = "The querystring_caching_behaviour must be either \"IgnoreQueryString\" or \"BypassCaching\" or \"UseQueryString\"."
  }
}

variable "optimization_type" {
  description = "Optimization type. Possible values:  DynamicSiteAcceleration, GeneralMediaStreaming, GeneralWebDelivery, LargeFileDownload and VideoOnDemandMediaStreaming"
  type        = string
  default     = "GeneralWebDelivery"

  validation {
    condition     = (contains(["DynamicSiteAcceleration", "GeneralMediaStreaming", "GeneralWebDelivery", "LargeFileDownload", "VideoOnDemandMediaStreaming"], var.optimization_type))
    error_message = "The optimization_type must be either \"DynamicSiteAcceleration\" or \"GeneralMediaStreaming\" or \"GeneralWebDelivery\" or \"LargeFileDownload\" or \"VideoOnDemandMediaStreaming\"."
  }
}

# Currently only single origin is supported by terraform although multi origin is supported by Azure with origin Groups.
variable "origins" {
  description = "A list of allowed Origins. Possible values for hostname are domain name, ipv4 or ipv6 address, Storage account or App Service endpoints. Currently supports only Storage Account or App Service"
  type = list(object({
    name       = string
    hostname   = string
    http_port  = number
    https_port = number
    type       = string
  }))
  validation {
    condition     = (length(var.origins) == 1)
    error_message = "Currently terraform only supports 1 origin."
  }
}

variable "delivery_rules" {
  description = "List of delivery rules for the endpoint. Currently supports only URL Rewrite and Redirect Actions"
  type        = any
  default     = {}
}

# Variables related to custom domain

variable "custom_domain" {
  description = "Inputs related to custom domain. cname_record should be without the zone name. cname_record is required if enable_custom_domain = true. dns_zone and dns_rg are required if cname_record is not fqdn. If create_cname_record = false, user should manually create the cname record in the dns zone in the format <cdn_endpoint_name>.azureedge.net, else dns_zone and dns_rg are required"
  type = object({
    enable_custom_domain = bool
    create_cname_record  = bool
    cname_record         = string
    dns_zone             = string
    dns_rg               = string
  })
  default = {
    enable_custom_domain = false
    create_cname_record  = false
    cname_record         = null
    dns_zone             = null
    dns_rg               = null
  }

  validation {
    condition     = ((var.custom_domain.enable_custom_domain && coalesce(var.custom_domain.cname_record, "notset") != "notset") || !var.custom_domain.enable_custom_domain)
    error_message = "The cname_record cannot be empty when enable_custom_domain = true."
  }

  validation {
    condition     = ((var.custom_domain.create_cname_record && coalesce(var.custom_domain.dns_zone, "notset") != "notset") || !var.custom_domain.create_cname_record)
    error_message = "The dns_zone cannot be empty when create_cname_record = true."
  }

  validation {
    condition     = ((var.custom_domain.create_cname_record && coalesce(var.custom_domain.dns_rg, "notset") != "notset") || !var.custom_domain.create_cname_record)
    error_message = "The dns_rg cannot be empty when create_cname_record = true."
  }
}

# Variables related to TLS

variable "custom_user_managed_https" {
  description = "Inputs related to custom HTTPS. key_vault_name, key_vault_rg and certificate_secret_name are mandatory if enable_custom_https = true. It is mandatory to add the service principal for Microsoft.AzureFrontDoor-Cdn to the Access Policy of KeyVault and grant a get-secret permission for the custom https to work"
  type = object({
    enable_custom_https     = bool
    key_vault_name          = string
    key_vault_rg            = string
    certificate_secret_name = string
  })

  default = {
    enable_custom_https     = false
    key_vault_name          = null
    key_vault_rg            = null
    certificate_secret_name = null
  }

  validation {
    condition     = ((var.custom_user_managed_https.enable_custom_https && coalesce(var.custom_user_managed_https.key_vault_name, "notset") != "notset") || !var.custom_user_managed_https.enable_custom_https)
    error_message = "The key_vault_name cannot be empty when enable_custom_https = true."
  }

  validation {
    condition     = ((var.custom_user_managed_https.enable_custom_https && coalesce(var.custom_user_managed_https.key_vault_rg, "notset") != "notset") || !var.custom_user_managed_https.enable_custom_https)
    error_message = "The key_vault_rg cannot be empty when enable_custom_https = true."
  }

  validation {
    condition     = ((var.custom_user_managed_https.enable_custom_https && coalesce(var.custom_user_managed_https.certificate_secret_name, "notset") != "notset") || !var.custom_user_managed_https.enable_custom_https)
    error_message = "The certificate_secret_name cannot be empty when enable_custom_https = true."
  }
}


variable "custom_tags" {
  description = "Any custom tags to be associated with the resource"
  type        = map(string)
  default     = {}
}
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
  description = "List of delivery rules for the endpoint"
  type        = any
  default     = {}
}

variable "custom_domain" {
  description = "The custom domain name attached to the cdn endpoint"
  type        = string
}

variable "custom_tags" {
  description = "Any custom tags to be associated with the resource"
  type        = map(string)
  default     = {}
}
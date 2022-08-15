resource "azurerm_cdn_profile" "cdn_profile" {
  name                = var.cdn_profile_name
  location            = var.resource_group.location
  resource_group_name = var.resource_group.name
  sku                 = var.sku

  tags = local.tags
}

resource "azurerm_cdn_endpoint" "endpoint" {
  name                = var.cdn_endpoint_name
  location            = var.resource_group.location
  resource_group_name = var.resource_group.name
  profile_name        = azurerm_cdn_profile.cdn_profile.name
  # Only 1 origin supported currently
  origin_host_header            = var.origins[0].hostname
  is_http_allowed               = var.is_http_allowed
  is_https_allowed              = var.is_https_allowed
  querystring_caching_behaviour = var.querystring_caching_behaviour
  optimization_type             = var.optimization_type


  dynamic "origin" {
    # Currently only single origin is supported
    for_each = var.origins
    content {
      name      = origin.value.name
      host_name = origin.value.hostname
    }
  }

  dynamic "delivery_rule" {
    for_each = var.delivery_rules
    content {
      name  = delivery_rule.key
      order = delivery_rule.value.properties.order

      dynamic "request_scheme_condition" {
        for_each = lookup(delivery_rule.value, "request_scheme_condition", null) != null ? [1] : []
        content {
          match_values = delivery_rule.value.request_scheme_condition.match_values
          operator     = delivery_rule.value.request_scheme_condition.operator

        }
      }

      dynamic "request_uri_condition" {
        for_each = lookup(delivery_rule.value, "request_uri_condition", null) != null ? [1] : []
        content {
          negate_condition = delivery_rule.value.request_uri_condition.negate_condition
          operator         = delivery_rule.value.request_uri_condition.operator

        }
      }

      dynamic "url_path_condition" {
        for_each = lookup(delivery_rule.value, "url_path_condition", null) != null ? [1] : []
        content {
          match_values     = delivery_rule.value.url_path_condition.match_values
          negate_condition = delivery_rule.value.url_path_condition.negate_condition
          operator         = delivery_rule.value.url_path_condition.operator

        }
      }

      dynamic "url_redirect_action" {
        for_each = lookup(delivery_rule.value, "url_redirect_action", null) != null ? [1] : []
        content {
          redirect_type = delivery_rule.value.url_redirect_action.redirect_type
          protocol      = delivery_rule.value.url_redirect_action.protocol
          hostname      = delivery_rule.value.url_redirect_action.hostname

        }
      }

      dynamic "url_rewrite_action" {
        for_each = lookup(delivery_rule.value, "url_rewrite_action", null) != null ? [1] : []
        content {
          destination             = delivery_rule.value.url_rewrite_action.destination
          preserve_unmatched_path = delivery_rule.value.url_rewrite_action.preserve_unmatched_path
          source_pattern          = delivery_rule.value.url_rewrite_action.source_pattern

        }
      }
    }
  }

  tags = local.tags
}

resource "azurerm_dns_cname_record" "cname_record" {
  count               = var.custom_domain.enable_custom_domain && var.custom_domain.create_cname_record ? 1 : 0
  name                = var.custom_domain.cname_record
  zone_name           = var.custom_domain.dns_zone
  resource_group_name = var.custom_domain.dns_rg
  ttl                 = 300
  target_resource_id  = azurerm_cdn_endpoint.endpoint.id

  tags = local.tags
}

data "azurerm_key_vault" "key_vault" {
  count = var.custom_user_managed_https.enable_custom_https ? 1 : 0

  name                = var.custom_user_managed_https.key_vault_name
  resource_group_name = var.custom_user_managed_https.key_vault_rg
}

data "azurerm_key_vault_certificate" "custom_https_cert" {
  count = var.custom_user_managed_https.enable_custom_https ? 1 : 0

  name         = var.custom_user_managed_https.certificate_secret_name
  key_vault_id = data.azurerm_key_vault.key_vault[0].id
}

resource "azurerm_cdn_endpoint_custom_domain" "custom_domain" {
  count = var.custom_domain.enable_custom_domain ? 1 : 0

  name            = "custom-domain-${replace(var.custom_domain.cname_record, ".", "-")}"
  cdn_endpoint_id = azurerm_cdn_endpoint.endpoint.id
  host_name       = local.custom_domain_host_name

  dynamic "user_managed_https" {
    for_each = var.custom_user_managed_https.enable_custom_https ? [1] : []

    content {
      key_vault_certificate_id = data.azurerm_key_vault_certificate.custom_https_cert[0].id
      tls_version              = "TLS12"
    }
  }

  depends_on = [
    azurerm_dns_cname_record.cname_record
  ]
}

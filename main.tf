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

  # delivery_rule {
  #   name  = "RedirectRules"
  #   order = 1

  #   request_scheme_condition {
  #     match_values = ["HTTP"]
  #     operator     = "Equal"
  #   }

  #   url_redirect_action {
  #     redirect_type = "PermanentRedirect"
  #     protocol      = "Https"
  #     hostname      = var.custom_domain
  #   }
  # }

  # delivery_rule {
  #   name  = "ReWriteRules"
  #   order = 2

  #   request_uri_condition {
  #     negate_condition = false
  #     operator         = "Any"
  #   }

  #   url_path_condition {
  #     match_values = [
  #       "."
  #     ]
  #     negate_condition = true
  #     operator         = "Contains"
  #   }

  #   url_rewrite_action {
  #     destination             = "/index.html"
  #     preserve_unmatched_path = false
  #     source_pattern          = "/"
  #   }
  # }

  tags = local.tags
}

# resource "null_resource" "origin_group" {
#   count = length(var.origins)
#   provisioner "local-exec" {
#     command = "az cdn origin-group create -n ${var.origins[count.index].name}-origin-group  --endpoint-name ${azurerm_cdn_endpoint.endpoint.name} --profile-name ${azurerm_cdn_profile.cdn_profile.name} -g ${var.resource_group.name} --origins ${var.origins[count.index].name}"
#   }
# }
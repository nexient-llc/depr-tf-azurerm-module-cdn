cdn_profile_name = "demo-eus-dev-000-cdn-000"
cdn_endpoint_name = "demo-eus-dev-000-ep-000"
# The origin should exist ahead of time
origins = [
  {
    name       = "primary"
    hostname   = "debtestwebsite.z13.web.core.windows.net"
    http_port  = 80
    https_port = 443
    type       = "Storage Account"
  }
]

delivery_rules = {
  RedirectRules = {
    properties = {
      name  = "RedirectRules"
      order = 1
    }
    
    request_scheme_condition = {
      match_values = ["HTTP"]
      operator     = "Equal"
    }

    url_redirect_action = {
      redirect_type = "PermanentRedirect"
      protocol      = "Https"
      hostname      = "test1.nexient.com"
    }
  },
  RewriteRules = {
    properties = {
      name  = "ReWriteRules"
      order = 2
    }
    
    request_uri_condition = {
      negate_condition = false
      operator         = "Any"
    }

    url_path_condition = {
      match_values = [
        "."
      ]
      negate_condition = true
      operator         = "Contains"
    }

    url_rewrite_action = {
      destination             = "/index.html"
      preserve_unmatched_path = false
      source_pattern          = "/"
    }
  }
}

custom_domain = {
  enable_custom_domain = false
  create_cname_record = false
  cname_record = ""
  dns_zone = ""
  dns_rg = ""
}

custom_user_managed_https = {
  enable_custom_https = false
  key_vault_name = ""
  key_vault_rg = ""
  certificate_secret_name = ""

}
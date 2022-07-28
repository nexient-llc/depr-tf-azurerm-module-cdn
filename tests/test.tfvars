cdn_profile_name = "demo-cdn-000-eus-000"
cdn_endpoint_name = "demo-cdnep-000-eus-000"
origins = [
  {
    name       = "primary"
    hostname   = "debtestwebsite.z13.web.core.windows.net"
    http_port  = 80
    https_port = 443
    type       = "Storage Account"
  }
]

custom_domain = "test1.vanillavc.com"

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

    #request_scheme_condition = null
  }
}
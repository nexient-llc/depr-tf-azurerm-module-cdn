terraform {
  required_version = ">= 1.1.7"
  experiments      = [module_variable_optional_attrs]

  required_providers {
    azurerm = ">= 3.0.2"
  }
}

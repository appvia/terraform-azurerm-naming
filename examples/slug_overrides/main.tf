terraform {
  required_version = ">= 1.13.0"
}

module "naming" {
  source = "../../"

  suffix = ["dev", "uks"]

  slug_overrides = {
    container_registry = "acr"
    virtual_network    = "network"
  }
}

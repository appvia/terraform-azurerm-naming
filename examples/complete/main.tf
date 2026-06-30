terraform {
  required_version = ">= 1.13.0"
}

module "naming" {
  source = "../../"

  prefix       = ["contoso"]
  prefix_short = ["cto"]

  suffix       = ["production", "uksouth"]
  suffix_short = ["prod", "uks"]

  unique_length = 6

  slug_overrides = {
    container_registry = "acr"
  }
}

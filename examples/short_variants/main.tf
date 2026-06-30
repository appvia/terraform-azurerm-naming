terraform {
  required_version = ">= 1.13.0"
}

module "naming" {
  source = "../../"

  suffix       = ["development", "uksouth"]
  suffix_short = ["dev", "uks"]
}

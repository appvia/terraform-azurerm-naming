terraform {
  required_version = ">= 1.10.0"
}

module "naming" {
  source = "../../"
  suffix = ["dev", "uks"]
}

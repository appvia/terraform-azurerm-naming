terraform {
  required_version = ">= 1.13.0"
}

module "naming" {
  source = "../../"

  suffix        = ["prod", "uks"]
  unique_length = 6
}

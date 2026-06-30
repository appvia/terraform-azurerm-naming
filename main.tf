terraform {
  required_version = ">= 1.13.0"
  required_providers {
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }
}

resource "random_string" "first_letter" {
  length  = 1
  lower   = true
  upper   = false
  numeric = false
  special = false
}

resource "random_string" "main" {
  length  = 60
  lower   = true
  upper   = false
  numeric = var.unique_include_numbers
  special = false
}

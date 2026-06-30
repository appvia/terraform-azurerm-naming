provider "random" {}

# --- slug_overrides changes the slug ---
run "slug_override_applied" {
  command = apply

  variables {
    suffix         = ["dev"]
    slug_overrides = { container_registry = "acr" }
  }

  assert {
    condition     = output.container_registry.slug == "acr"
    error_message = "container_registry slug should be overridden to 'acr', got '${output.container_registry.slug}'"
  }

  assert {
    condition     = output.container_registry.name == "acrdev"
    error_message = "container_registry name should use overridden slug, got '${output.container_registry.name}'"
  }
}

# --- Non-overridden resources keep default slug ---
run "non_overridden_unchanged" {
  command = apply

  variables {
    suffix         = ["dev"]
    slug_overrides = { container_registry = "acr" }
  }

  assert {
    condition     = output.virtual_network.slug == "vnet"
    error_message = "virtual_network slug should remain 'vnet' when not overridden"
  }

  assert {
    condition     = output.storage_account.slug == "st"
    error_message = "storage_account slug should remain 'st' when not overridden"
  }
}

# --- Multiple overrides at once ---
run "multiple_overrides" {
  command = apply

  variables {
    suffix = ["dev"]
    slug_overrides = {
      container_registry = "acr"
      key_vault          = "keyvault"
    }
  }

  assert {
    condition     = output.container_registry.name == "acrdev"
    error_message = "container_registry should use 'acr' slug, got '${output.container_registry.name}'"
  }

  assert {
    condition     = output.key_vault.name == "keyvault-dev"
    error_message = "key_vault should use 'keyvault' slug, got '${output.key_vault.name}'"
  }
}

# --- Override with dashes resource ---
run "override_dashes_resource" {
  command = apply

  variables {
    suffix         = ["dev", "eus2"]
    slug_overrides = { virtual_network = "network" }
  }

  assert {
    condition     = output.virtual_network.name == "network-dev-eus2"
    error_message = "virtual_network should use overridden slug, got '${output.virtual_network.name}'"
  }
}

# --- Empty overrides map has no effect ---
run "empty_overrides" {
  command = apply

  variables {
    suffix         = ["dev"]
    slug_overrides = {}
  }

  assert {
    condition     = output.virtual_network.slug == "vnet"
    error_message = "Empty overrides should not change slugs"
  }
}

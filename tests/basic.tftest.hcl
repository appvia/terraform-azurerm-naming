provider "random" {}

# --- Suffix only ---
run "suffix_only" {
  command = apply

  variables {
    suffix = ["dev", "eus2"]
  }

  # Dashes resource: slug-suffix1-suffix2
  assert {
    condition     = output.virtual_network.name == "vnet-dev-eus2"
    error_message = "Expected virtual_network name 'vnet-dev-eus2', got '${output.virtual_network.name}'"
  }

  # No-dashes resource: slugsuffix1suffix2 (lowercase, no separators)
  assert {
    condition     = output.storage_account.name == "stdeveus2"
    error_message = "Expected storage_account name 'stdeveus2', got '${output.storage_account.name}'"
  }

  assert {
    condition     = output.resource_group.name == "rg-dev-eus2"
    error_message = "Expected resource_group name 'rg-dev-eus2', got '${output.resource_group.name}'"
  }

  assert {
    condition     = output.key_vault.name == "kv-dev-eus2"
    error_message = "Expected key_vault name 'kv-dev-eus2', got '${output.key_vault.name}'"
  }

  assert {
    condition     = output.container_registry.name == "crdeveus2"
    error_message = "Expected container_registry name 'crdeveus2', got '${output.container_registry.name}'"
  }

  assert {
    condition     = output.aks_cluster.name == "aks-dev-eus2"
    error_message = "Expected aks_cluster name 'aks-dev-eus2', got '${output.aks_cluster.name}'"
  }
}

# --- Prefix only ---
run "prefix_only" {
  command = apply

  variables {
    prefix = ["contoso"]
  }

  assert {
    condition     = output.virtual_network.name == "contoso-vnet"
    error_message = "Expected 'contoso-vnet', got '${output.virtual_network.name}'"
  }

  assert {
    condition     = output.storage_account.name == "contosost"
    error_message = "Expected 'contosost', got '${output.storage_account.name}'"
  }
}

# --- Prefix and suffix ---
run "prefix_and_suffix" {
  command = apply

  variables {
    prefix = ["contoso"]
    suffix = ["dev", "eus2"]
  }

  assert {
    condition     = output.virtual_network.name == "contoso-vnet-dev-eus2"
    error_message = "Expected 'contoso-vnet-dev-eus2', got '${output.virtual_network.name}'"
  }

  assert {
    condition     = output.storage_account.name == "contosostdeveus2"
    error_message = "Expected 'contosostdeveus2', got '${output.storage_account.name}'"
  }

  assert {
    condition     = output.key_vault.name == "contoso-kv-dev-eus2"
    error_message = "Expected 'contoso-kv-dev-eus2', got '${output.key_vault.name}'"
  }
}

# --- Empty prefix and suffix produces just the slug ---
run "slug_only" {
  command = apply

  assert {
    condition     = output.virtual_network.name == "vnet"
    error_message = "Expected just 'vnet', got '${output.virtual_network.name}'"
  }

  assert {
    condition     = output.storage_account.name == "st"
    error_message = "Expected just 'st', got '${output.storage_account.name}'"
  }
}

# --- Slug appears in every name ---
run "slug_present_in_names" {
  command = apply

  variables {
    suffix = ["test"]
  }

  assert {
    condition     = strcontains(output.virtual_network.name, "vnet")
    error_message = "virtual_network name should contain slug 'vnet'"
  }

  assert {
    condition     = strcontains(output.storage_account.name, "st")
    error_message = "storage_account name should contain slug 'st'"
  }

  assert {
    condition     = strcontains(output.key_vault.name, "kv")
    error_message = "key_vault name should contain slug 'kv'"
  }

  assert {
    condition     = strcontains(output.aks_cluster.name, "aks")
    error_message = "aks_cluster name should contain slug 'aks'"
  }
}

# --- Output structure contains expected fields ---
run "output_structure" {
  command = apply

  variables {
    suffix = ["dev"]
  }

  assert {
    condition     = output.virtual_network.slug == "vnet"
    error_message = "slug field should be 'vnet'"
  }

  assert {
    condition     = output.virtual_network.dashes == true
    error_message = "virtual_network dashes should be true"
  }

  assert {
    condition     = output.storage_account.dashes == false
    error_message = "storage_account dashes should be false"
  }

  assert {
    condition     = output.virtual_network.max_length == 64
    error_message = "virtual_network max_length should be 64"
  }

  assert {
    condition     = output.storage_account.max_length == 24
    error_message = "storage_account max_length should be 24"
  }

  assert {
    condition     = output.virtual_network.scope == "resource group"
    error_message = "virtual_network scope should be 'resource group'"
  }

  assert {
    condition     = output.storage_account.scope == "global"
    error_message = "storage_account scope should be 'global'"
  }
}

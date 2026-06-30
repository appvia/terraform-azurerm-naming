provider "random" {}

# --- Valid names produce valid_name = true ---
run "valid_names_with_simple_suffix" {
  command = apply

  variables {
    suffix = ["dev"]
  }

  assert {
    condition     = output.virtual_network.valid_name == true
    error_message = "virtual_network 'vnet-dev' should be valid"
  }

  assert {
    condition     = output.storage_account.valid_name == true
    error_message = "storage_account 'stdev' should be valid"
  }

  assert {
    condition     = output.key_vault.valid_name == true
    error_message = "key_vault 'kv-dev' should be valid"
  }

  assert {
    condition     = output.resource_group.valid_name == true
    error_message = "resource_group 'rg-dev' should be valid"
  }

  assert {
    condition     = output.aks_cluster.valid_name == true
    error_message = "aks_cluster 'aks-dev' should be valid"
  }

  assert {
    condition     = output.container_registry.valid_name == true
    error_message = "container_registry 'crdev' should be valid"
  }
}

# --- Validation output contains all resources ---
run "validation_output_completeness" {
  command = apply

  variables {
    suffix = ["dev"]
  }

  assert {
    condition     = contains(keys(output.validation), "virtual_network")
    error_message = "validation output should contain virtual_network"
  }

  assert {
    condition     = contains(keys(output.validation), "storage_account")
    error_message = "validation output should contain storage_account"
  }

  assert {
    condition     = contains(keys(output.validation), "key_vault")
    error_message = "validation output should contain key_vault"
  }
}

# --- Regex field is exposed correctly ---
run "regex_exposed" {
  command = apply

  variables {
    suffix = ["dev"]
  }

  assert {
    condition     = output.storage_account.regex == "^[a-z0-9]{3,24}$"
    error_message = "storage_account regex should be '^[a-z0-9]{3,24}$$', got '${output.storage_account.regex}'"
  }

  assert {
    condition     = output.container_registry.regex == "^[a-zA-Z0-9]{5,50}$"
    error_message = "container_registry regex should be '^[a-zA-Z0-9]{5,50}$$', got '${output.container_registry.regex}'"
  }
}

# --- Names with prefix+suffix still validate ---
run "valid_with_prefix_suffix" {
  command = apply

  variables {
    prefix = ["contoso"]
    suffix = ["dev", "eus2"]
  }

  assert {
    condition     = output.virtual_network.valid_name == true
    error_message = "virtual_network 'contoso-vnet-dev-eus2' should be valid"
  }

  assert {
    condition     = output.resource_group.valid_name == true
    error_message = "resource_group with prefix+suffix should be valid"
  }

  assert {
    condition     = output.aks_cluster.valid_name == true
    error_message = "aks_cluster with prefix+suffix should be valid"
  }
}

# --- Truncated names still validate ---
run "truncated_names_validate" {
  command = apply

  variables {
    prefix = ["longcompany"]
    suffix = ["production", "westeurope"]
  }

  # These will be truncated - they should still validate
  assert {
    condition     = output.virtual_machine.valid_name == true
    error_message = "Truncated virtual_machine name '${output.virtual_machine.name}' should still be valid"
  }

  assert {
    condition     = output.key_vault.valid_name == true
    error_message = "Truncated key_vault name '${output.key_vault.name}' should still be valid"
  }
}

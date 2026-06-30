provider "random" {}

# --- Names respect max_length ---
run "truncation_within_max_length" {
  command = apply

  variables {
    prefix = ["mycompanyname"]
    suffix = ["development", "eastus2", "shared"]
  }

  # storage_account: max 24, no dashes
  assert {
    condition     = length(output.storage_account.name) <= 24
    error_message = "storage_account name '${output.storage_account.name}' exceeds max_length 24 (length: ${length(output.storage_account.name)})"
  }

  # key_vault: max 24, dashes
  assert {
    condition     = length(output.key_vault.name) <= 24
    error_message = "key_vault name '${output.key_vault.name}' exceeds max_length 24 (length: ${length(output.key_vault.name)})"
  }

  # virtual_machine: max 15, dashes
  assert {
    condition     = length(output.virtual_machine.name) <= 15
    error_message = "virtual_machine name '${output.virtual_machine.name}' exceeds max_length 15 (length: ${length(output.virtual_machine.name)})"
  }

  # container_registry: max 50, no dashes
  assert {
    condition     = length(output.container_registry.name) <= 50
    error_message = "container_registry name '${output.container_registry.name}' exceeds max_length 50 (length: ${length(output.container_registry.name)})"
  }

  # name_unique also respects max_length
  assert {
    condition     = length(output.storage_account.name_unique) <= 24
    error_message = "storage_account name_unique '${output.storage_account.name_unique}' exceeds max_length 24"
  }

  assert {
    condition     = length(output.key_vault.name_unique) <= 24
    error_message = "key_vault name_unique '${output.key_vault.name_unique}' exceeds max_length 24"
  }

  assert {
    condition     = length(output.virtual_machine.name_unique) <= 15
    error_message = "virtual_machine name_unique '${output.virtual_machine.name_unique}' exceeds max_length 15"
  }
}

# --- Slug is never truncated ---
run "slug_preserved_during_truncation" {
  command = apply

  variables {
    prefix = ["verylongcompanyname"]
    suffix = ["verylongenvironment", "verylongregion"]
  }

  assert {
    condition     = strcontains(output.storage_account.name, "st")
    error_message = "storage_account slug 'st' should be preserved during truncation"
  }

  assert {
    condition     = strcontains(output.key_vault.name, "kv")
    error_message = "key_vault slug 'kv' should be preserved during truncation"
  }

  assert {
    condition     = strcontains(output.virtual_machine.name, "vm")
    error_message = "virtual_machine slug 'vm' should be preserved during truncation"
  }

  assert {
    condition     = strcontains(output.container_registry.name, "cr")
    error_message = "container_registry slug 'cr' should be preserved during truncation"
  }
}

# --- Elements are equally truncated ---
run "equal_truncation" {
  command = apply

  variables {
    # Two suffix elements of equal length to verify equal truncation
    prefix = ["abcdefghij"]
    suffix = ["abcdefghij"]
  }

  # storage_account: max 24, no dashes, slug "st" (2 chars)
  # Available for user elements: 24 - 2 = 22
  # 2 elements of 10 chars = 20 total, fits within 22
  # So no truncation needed here - use shorter max resource
  #
  # virtual_machine: max 15, dashes, slug "vm" (2 chars)
  # Full name would be: abcdefghij-vm-abcdefghij = 25 chars
  # Available: 15 - 2 (slug) - 2 (separators) = 11
  # Per element budget: floor(11/2) = 5
  # Expected: abcde-vm-abcde = 14 chars
  assert {
    condition     = output.virtual_machine.name == "abcde-vm-abcde"
    error_message = "Expected equal truncation 'abcde-vm-abcde', got '${output.virtual_machine.name}'"
  }
}

# --- Short variants used when provided ---
run "short_variants" {
  command = apply

  variables {
    prefix       = ["mycompanyname"]
    suffix       = ["development", "eastus2"]
    prefix_short = ["myco"]
    suffix_short = ["dev", "eus2"]
  }

  # virtual_network: max 64, dashes
  # Full: mycompanyname-vnet-development-eastus2 = 39 chars (fits)
  assert {
    condition     = output.virtual_network.name == "mycompanyname-vnet-development-eastus2"
    error_message = "Full name should be used when it fits, got '${output.virtual_network.name}'"
  }

  # virtual_machine: max 15, dashes
  # Full: mycompanyname-vm-development-eastus2 = 36 chars (too long)
  # Short: myco-vm-dev-eus2 = 16 chars (still too long)
  # Truncated from short: each of 3 elements gets floor((15-2-3)/3)=floor(10/3)=3
  # myc-vm-dev-eus = ... let me not assert exact value, just check max_length
  assert {
    condition     = length(output.virtual_machine.name) <= 15
    error_message = "virtual_machine should respect max_length 15 even with short variants"
  }

  # key_vault: max 24, dashes
  # Full: mycompanyname-kv-development-eastus2 = 36 chars (too long)
  # Short: myco-kv-dev-eus2 = 16 chars (fits!)
  assert {
    condition     = output.key_vault.name == "myco-kv-dev-eus2"
    error_message = "Short variant should be used for key_vault, got '${output.key_vault.name}'"
  }
}

# --- No truncation when name fits ---
run "no_truncation_when_fits" {
  command = apply

  variables {
    suffix = ["dev"]
  }

  assert {
    condition     = output.virtual_network.name == "vnet-dev"
    error_message = "Short name should not be truncated, got '${output.virtual_network.name}'"
  }

  assert {
    condition     = output.storage_account.name == "stdev"
    error_message = "Short name should not be truncated, got '${output.storage_account.name}'"
  }
}

# --- All resources respect their max_length under heavy load ---
run "all_resources_within_max_length" {
  command = apply

  variables {
    prefix = ["longcompanyname"]
    suffix = ["production", "westeurope", "shared"]
  }

  assert {
    condition = alltrue([
      for k, v in output.validation : length(output.resources[k].name) <= output.resources[k].max_length
    ])
    error_message = "All resource names must be within their max_length"
  }

  assert {
    condition = alltrue([
      for k, v in output.validation : length(output.resources[k].name_unique) <= output.resources[k].max_length
    ])
    error_message = "All resource name_unique values must be within their max_length"
  }
}

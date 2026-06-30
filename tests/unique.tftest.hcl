provider "random" {}

# --- name_unique differs from name ---
run "unique_differs_from_name" {
  command = apply

  variables {
    suffix = ["dev"]
  }

  assert {
    condition     = output.virtual_network.name_unique != output.virtual_network.name
    error_message = "name_unique should differ from name"
  }

  assert {
    condition     = output.storage_account.name_unique != output.storage_account.name
    error_message = "storage_account name_unique should differ from name"
  }
}

# --- name_unique contains the base name ---
run "unique_contains_base" {
  command = apply

  variables {
    suffix = ["dev"]
  }

  # For dashes resources, name_unique starts with the base name
  assert {
    condition     = strcontains(output.virtual_network.name_unique, "vnet")
    error_message = "name_unique should contain the slug"
  }

  assert {
    condition     = strcontains(output.virtual_network.name_unique, "dev")
    error_message = "name_unique should contain the suffix"
  }
}

# --- unique_seed produces deterministic output ---
run "deterministic_with_seed" {
  command = apply

  variables {
    suffix      = ["dev"]
    unique_seed = "abcdefghijklmnop"
  }

  assert {
    condition     = output.virtual_network.name_unique == "vnet-dev-abcd"
    error_message = "With seed 'abcdefghijklmnop' and length 4, unique suffix should be 'abcd', got '${output.virtual_network.name_unique}'"
  }

  assert {
    condition     = output.storage_account.name_unique == "stdevabcd"
    error_message = "storage_account with seed should be 'stdevabcd', got '${output.storage_account.name_unique}'"
  }
}

# --- unique_length controls suffix length ---
run "unique_length_control" {
  command = apply

  variables {
    suffix        = ["dev"]
    unique_seed   = "abcdefghijklmnop"
    unique_length = 8
  }

  assert {
    condition     = output.virtual_network.name_unique == "vnet-dev-abcdefgh"
    error_message = "With length 8, unique suffix should be 'abcdefgh', got '${output.virtual_network.name_unique}'"
  }
}

# --- unique_length = 1 ---
run "unique_length_minimum" {
  command = apply

  variables {
    suffix        = ["dev"]
    unique_seed   = "xyzabc"
    unique_length = 1
  }

  assert {
    condition     = output.virtual_network.name_unique == "vnet-dev-x"
    error_message = "With length 1, unique suffix should be 'x', got '${output.virtual_network.name_unique}'"
  }
}

# --- unique_seed output can be captured for reproducibility ---
run "unique_seed_output" {
  command = apply

  variables {
    suffix      = ["dev"]
    unique_seed = "myseed123"
  }

  assert {
    condition     = output.unique_seed == "myseed123"
    error_message = "unique_seed output should match input when provided"
  }
}

# --- unique_seed output generated when not provided ---
run "unique_seed_generated" {
  command = apply

  variables {
    suffix = ["dev"]
  }

  assert {
    condition     = length(output.unique_seed) > 0
    error_message = "unique_seed output should be generated when not provided"
  }
}

# --- name_unique respects max_length ---
run "unique_respects_max_length" {
  command = apply

  variables {
    prefix      = ["company"]
    suffix      = ["prod", "westeurope"]
    unique_seed = "abcdefghijklmnop"
  }

  assert {
    condition     = length(output.storage_account.name_unique) <= 24
    error_message = "storage_account name_unique must respect max_length 24"
  }

  assert {
    condition     = length(output.key_vault.name_unique) <= 24
    error_message = "key_vault name_unique must respect max_length 24"
  }

  assert {
    condition     = length(output.virtual_machine.name_unique) <= 15
    error_message = "virtual_machine name_unique must respect max_length 15"
  }

  # Unique string should still be present even after truncation
  assert {
    condition     = strcontains(output.storage_account.name_unique, "abcd")
    error_message = "Unique suffix should be preserved in truncated name_unique"
  }
}

# Globally-scoped resources need unique names to avoid collisions.
# name_unique appends a random suffix:
#   storage_account.name_unique => "stproduksabc123"
output "storage_account" {
  description = "The generated unique storage account name."
  value       = module.naming.storage_account.name_unique
}

# Works with dashes too:
#   key_vault.name_unique => "kv-prod-uks-abc123"
output "key_vault" {
  description = "The generated unique key vault name."
  value       = module.naming.key_vault.name_unique
}

# Store the seed to reproduce the same unique names across runs:
output "naming_seed" {
  description = "The seed used for generating unique name suffixes."
  value       = module.naming.unique_seed
}

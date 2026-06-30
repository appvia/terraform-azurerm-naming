# Full names used where they fit within max_length:
#   virtual_network.name => "contoso-vnet-production-uksouth"
output "virtual_network" {
  description = "The generated virtual network name."
  value       = module.naming.virtual_network.name
}

# Short variants kick in for tight limits:
#   key_vault.name => "kv-cto-prod-uks"
output "key_vault" {
  description = "The generated key vault name."
  value       = module.naming.key_vault.name
}

# No-dash resources are lowercased and concatenated:
#   storage_account.name_unique => "stctoproduksabc123"
output "storage_account" {
  description = "The generated unique storage account name."
  value       = module.naming.storage_account.name_unique
}

# Slug override applied:
#   container_registry.name => "acrctoproduks"
output "container_registry" {
  description = "The generated container registry name using the overridden slug."
  value       = module.naming.container_registry.name
}

# Validation check — use this to catch invalid names at plan time:
output "all_names_valid" {
  description = "Whether all generated names pass validation."
  value       = alltrue([for k, v in module.naming.validation : v.valid_name])
}

# Access any resource via the resources map:
output "resource_group_from_map" {
  description = "The generated resource group name accessed via the resources map."
  value       = module.naming.resources["resource_group"].name
}

output "naming_seed" {
  description = "The seed used for generating unique name suffixes."
  value       = module.naming.unique_seed
}

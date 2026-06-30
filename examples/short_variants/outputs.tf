# Resources with generous max_length use the full suffix:
#   virtual_network.name => "vnet-development-uksouth"
output "virtual_network" {
  description = "The generated virtual network name."
  value       = module.naming.virtual_network.name
}

# Resources with tight limits fall back to short variants:
#   key_vault.name => "kv-dev-uks"
output "key_vault" {
  description = "The generated key vault name."
  value       = module.naming.key_vault.name
}

# If even short variants are too long, elements are equally truncated to fit.
output "storage_account" {
  description = "The generated storage account name."
  value       = module.naming.storage_account.name
}

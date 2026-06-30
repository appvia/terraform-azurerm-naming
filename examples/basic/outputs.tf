output "resource_group" {
  description = "The generated resource group name."
  value       = module.naming.resource_group.name
}

output "virtual_network" {
  description = "The generated virtual network name."
  value       = module.naming.virtual_network.name
}

output "storage_account" {
  description = "The generated storage account name."
  value       = module.naming.storage_account.name
}

output "key_vault" {
  description = "The generated key vault name."
  value       = module.naming.key_vault.name
}

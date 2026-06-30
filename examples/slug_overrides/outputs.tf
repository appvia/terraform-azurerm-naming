# Uses the overridden slug "acr" instead of the default "cr":
#   container_registry.name => "acrdevuks"
output "container_registry" {
  description = "The generated container registry name using the overridden slug."
  value       = module.naming.container_registry.name
}

# Uses the overridden slug "network" instead of the default "vnet":
#   virtual_network.name => "network-dev-uks"
output "virtual_network" {
  description = "The generated virtual network name using the overridden slug."
  value       = module.naming.virtual_network.name
}

# Non-overridden resources keep their default slug:
#   resource_group.name => "rg-dev-uks"
output "resource_group" {
  description = "The generated resource group name using the default slug."
  value       = module.naming.resource_group.name
}

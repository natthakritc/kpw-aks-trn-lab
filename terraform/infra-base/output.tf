output "vnet_id" {
  description = "The ID of the spoke VNet"
  value       = azurerm_virtual_network.vnet_aks.id
}

output "vnet_name" {
  description = "The name of the spoke VNet"
  value       = azurerm_virtual_network.vnet_aks.name
}

output "subnet_id" {
  description = "The ID of the data subnet"
  #value       = { for k, s in azurerm_subnet.aks_subnet : k => s.id }
  value =   azurerm_subnet.aks_subnet.id
}

output "subnet_name" {
  description = "The name of the data subnet"
  #value       = { for k, s in azurerm_subnet.aks_subnet : k => s.name }
  value = azurerm_subnet.aks_subnet.name
}

output "resource_group_name" {
  description = "The name of the spoke VNet resource group"
  value       = azurerm_resource_group.rg.name
}

output "resource_group_id" {
  description = "The ID of the spoke VNet resource group"
  value       = azurerm_resource_group.rg.id
}

output "log_analytics_workspace_id" {
  description = "The ID of the Log Analytics Workspace used for AKS monitoring"
  value       = azurerm_log_analytics_workspace.log.id
}
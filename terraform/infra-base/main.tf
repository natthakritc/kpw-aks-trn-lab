locals {
  company             = var.company
  project             = var.project_name
  environment         = var.environment
  location            = var.location
  common_tags         = var.common_tags
  # resource_group_name = var.resource_group_name
  address_space           = var.address_space
  aks_subnet_prefix        = var.aks_subnet_prefix

  tags = merge(
    local.common_tags,
    {
      "Environment" = local.environment
      "Project"     = local.project
      "Company"     = local.company
    }
  )
}

module "naming" {
  source = "Azure/naming/azurerm"
  # suffix = [local.company, local.project, local.environment, local.location == "southeastasia" ? "sea" : local.location]
  suffix = [local.company, local.project, local.environment, local.location == "southeastasia" ? "sea" : "ea"]
}

# Always create a new resource group for the AKS
resource "azurerm_resource_group" "rg" {
  name     = "${module.naming.resource_group.name}-001" 
  location = local.location
  tags = merge(
    local.common_tags,
    {
      "Environment" = local.environment
      "Project"     = local.project
      "Company"     = local.company
    }
  )
}

# Create the spoke virtual network
resource "azurerm_virtual_network" "vnet_aks" {
  name                = "${module.naming.virtual_network.name}-001"
  location            = local.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = [local.address_space]

  tags = merge(
    local.common_tags,
    {
      "Environment" = local.environment
      "Project"     = local.project
      "Company"     = local.company
    }
  )
}

# Create Application subnet
resource "azurerm_subnet" "aks_subnet" {
  name                 = "snet-aks-001"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet_aks.name
  address_prefixes     = [local.aks_subnet_prefix]
}

# Create Network Security Group (NSG) for the vm subnet
resource "azurerm_network_security_group" "nsg_aks" {
  name                = "${module.naming.network_security_group.name}-001"
  location            = local.location
  resource_group_name = azurerm_resource_group.rg.name

  /* security_rule {
    name                       = "AllowRDP"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  } */

  tags = merge(
    local.common_tags,
    {
      "Environment" = local.environment
    }
  )
}

# Associate the NSG with the vm subnet
resource "azurerm_subnet_network_security_group_association" "nsg_association_aks_snet" {
  subnet_id                 = azurerm_subnet.aks_subnet.id
  network_security_group_id = azurerm_network_security_group.nsg_aks.id
}

# Create route table for default route to firewall
resource "azurerm_route_table" "aks_route" {
  name                = "${module.naming.route_table.name}-001"
  location            = local.location
  resource_group_name = azurerm_resource_group.rg.name

/*   route {
    name                   = "default-to-fw"
    address_prefix         = "0.0.0.0/0"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = local.firewall_private_ip
  } */

  tags = merge(
    local.common_tags,
    {
      "Environment" = local.environment
      "Project"     = local.project
      "Company"     = local.company
    }
  )
}

# Associate route table with vm subnet
/* resource "azurerm_subnet_route_table_association" "vm_route_association" {
  subnet_id      = azurerm_subnet.vm_subnet.id
  route_table_id = azurerm_route_table.default_route.id
} */

resource "azurerm_log_analytics_workspace" "log" {
  name                = "${module.naming.log_analytics_workspace.name}-001"
  location            = local.location
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = "PerGB2018"

  tags = merge(
    local.common_tags,
    {
      "Environment" = local.environment
      "Project"     = local.project
      "Company"     = local.company
    }
  )  
}
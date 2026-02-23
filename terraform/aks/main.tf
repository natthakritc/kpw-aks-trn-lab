locals {
  company             = var.company
  project             = var.project_name
  environment         = var.environment
  location            = var.location
  common_tags         = var.common_tags
  resource_group_name = var.resource_group_name
  vnet_subnet_id      = var.vnet_subnet_id
  log_analytics_workspace_id = var.log_analytics_workspace_id
#   address_space           = var.address_space
#   aks_subnet_prefix        = var.aks_subnet_prefix

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
  suffix = [local.company, local.environment, local.location == "southeastasia" ? "sea" : "ea"]
}

data "azurerm_kubernetes_service_versions" "current" {
  location        = var.location
  include_preview = false
}

resource "azurerm_kubernetes_cluster" "poc-aks" {
  name                = "${module.naming.kubernetes_cluster.name}-001"
  location            = local.location
  resource_group_name = local.resource_group_name
  dns_prefix          = "aks-ncd-poc-dns"
  kubernetes_version = data.azurerm_kubernetes_service_versions.current.default_version
  role_based_access_control_enabled = true
  local_account_disabled            = false
  sku_tier = "Free"

  node_resource_group = "MC_${local.resource_group_name}_${module.naming.kubernetes_cluster.name}-001_${local.location == "southeastasia" ? "sea" : "ea"}"

  # automatic_channel_upgrade = none   # rapid / stable / node-image / none
  # node_os_channel_upgrade = "None"  # Unmanaged / NodeImage / None

  automatic_upgrade_channel = null #"none"
  node_os_upgrade_channel = "None"

  image_cleaner_enabled        = true
  image_cleaner_interval_hours = 168

  network_profile {
    network_plugin    = "azure"
    network_policy    = "azure"
    load_balancer_sku = "standard" 
    service_cidr     = "10.0.0.0/16"
    dns_service_ip   = "10.0.0.10"
    outbound_type    = "loadBalancer"
  }
  
  default_node_pool {
    name                = "syspool"
    os_sku              = "Ubuntu"
    type                = "VirtualMachineScaleSets"
    vm_size             = "Standard_D2s_v3" #"Standard_D2pds_v5"
    vnet_subnet_id      = local.vnet_subnet_id
    # enable_auto_scaling = true
    auto_scaling_enabled = true
    min_count           = 1
    max_count           = 2
    node_count          = null
  }

  identity {
    type = "SystemAssigned"
  }

  oms_agent {
  log_analytics_workspace_id = local.log_analytics_workspace_id
  }

  /* monitor_metrics {
    annotations_allowed = null
    labels_allowed = null
  } */

  monitor_metrics {
    annotations_allowed = "app.kubernetes.io/name,app.kubernetes.io/component"
    labels_allowed      = "app,k8s-app"
  }
  

  oidc_issuer_enabled = true
  workload_identity_enabled = true

  tags = merge(
    local.common_tags,
    {
      "Environment" = local.environment
      "Project"     = local.project
      "Company"     = local.company
    }
  )
}

resource "azurerm_kubernetes_cluster_node_pool" "userpool" {
  name                  = "userpool"
  kubernetes_cluster_id = azurerm_kubernetes_cluster.poc-aks.id
  mode                  = "User"

  os_sku            = "Ubuntu"
  vm_size           = "Standard_D2s_v3" #"Standard_D2pds_v5"
  vnet_subnet_id    = local.vnet_subnet_id
  orchestrator_version = azurerm_kubernetes_cluster.poc-aks.kubernetes_version

  # enable_auto_scaling = true
  auto_scaling_enabled = true
  min_count           = 1
  max_count           = 4
  node_count          = null

  tags = merge(
    local.common_tags,
    {
      "Environment" = local.environment
      "Project"     = local.project
      "Company"     = local.company
    }
  )
}

resource "azurerm_monitor_workspace" "amw" {
  name                = "amw-${local.company}-${local.project}-${local.environment}"
  location            = local.location
  resource_group_name = local.resource_group_name
  tags = merge(
    local.common_tags,
    {
      "Environment" = local.environment
      "Project"     = local.project
      "Company"     = local.company
    }
  )
}

resource "azurerm_monitor_data_collection_rule_association" "aks_prometheus" {
  name                    = "prometheus-metrics"
  target_resource_id      = azurerm_kubernetes_cluster.poc-aks.id
  data_collection_rule_id = azurerm_monitor_workspace.amw.default_data_collection_rule_id
}

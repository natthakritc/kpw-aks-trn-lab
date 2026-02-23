locals {
  company             = var.company
  project             = var.project_name
  environment         = var.environment
  location            = var.location
  common_tags         = var.common_tags
  resource_group_name = var.resource_group_name
  subnet_id      = var.subnet_id
  log_analytics_workspace = ({
    id                  = var.log_analytics_workspace_id
    name                = element(split("/", var.log_analytics_workspace_id), 8)
    resource_group_name = var.resource_group_name
  })
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

module "aks" {
    source = "Azure/aks/azurerm"

    prefix              = "aks"
    cluster_name = module.naming.kubernetes_cluster.name
    resource_group_name = local.resource_group_name
    location            = local.location
    kubernetes_version  = data.azurerm_kubernetes_service_versions.current.default_version

    agents_pool_linux_os_configs = [
        {
        transparent_huge_page_enabled = "always"
        sysctl_configs = [
            {
            fs_aio_max_nr               = 65536
            fs_file_max                 = 100000
            fs_inotify_max_user_watches = 1000000
            }
        ]
        }
    ]
    agents_type             = "VirtualMachineScaleSets"
    azure_policy_enabled    = false #true
    host_encryption_enabled = false
    auto_scaling_enabled    = true

    # brown_field_application_gateway_for_ingress = {
    #   id        = local.appgw_id
    #   subnet_id = local.agw_subnet_id
    # }
    # create_role_assignments_for_application_gateway = true

    log_analytics_workspace_enabled                 = true
    log_analytics_workspace                         = local.log_analytics_workspace

    network_plugin                                  = "azure"
    network_policy                                  = "azure"

    private_cluster_enabled                         = false

    # rbac_aad_tenant_id = data.azurerm_client_config.current.tenant_id
    
    role_based_access_control_enabled               = true
    local_account_disabled                          = false

    # rbac_aad                         = true
    # rbac_aad_managed                 = true #unsupport 3.0
    # rbac_aad_azure_rbac_enabled       = true
    # rbac_aad_admin_group_object_ids   = [azuread_group.azure_aks_group.object_id]
    
    sku_tier                          = "Free" #"Standard"
    vnet_subnet = {
        id = var.subnet_id
    }

    #default_node_pool
    os_disk_type                 = var.system_nodepool_os_disk_type
    os_disk_size_gb              = var.system_nodepool_os_disk_size_gb
    agents_size                  = var.agents_size
    agents_min_count             = var.agents_min_count
    agents_max_count             = var.agents_max_count
    agents_count                 = null
    agents_pool_name             = "syspool" #var.agents_pool_name
    agents_max_pods              = var.agents_max_pods
    agents_availability_zones    = var.agents_availability_zones
    agents_labels                = var.agents_labels
    agents_pool_max_surge        = var.agents_pool_max_surge
    only_critical_addons_enabled = true
    agents_tags = merge(
        local.common_tags,
        {
        "Environment" = local.environment
        "Project"     = local.project
        "Company"     = local.company
        }
    )

    # user_node_pool
    # node_pools = var.node_pools
    node_pools = {
        userpool = {
            mode                = "User"
            name                = "userpool"
            os_disk_type        = var.system_nodepool_os_disk_type
            os_disk_size_gb     = var.system_nodepool_os_disk_size_gb
            vm_size             = var.agents_size
            auto_scaling_enabled = true
            min_count           = 1
            max_count           = 4
            node_count          = null
            max_pods            = var.agents_max_pods
            vnet_subnet_id      = var.subnet_id
            tags = merge(
                local.common_tags,
                {
                "Environment" = local.environment
                "Project"     = local.project
                "Company"     = local.company
                }
            )
        }
    }

    # Mantenance
    automatic_channel_upgrade  = var.automatic_channel_upgrade
    maintenance_window         = var.maintenance_window
    maintenance_window_node_os = var.maintenance_window_node_os
    node_os_channel_upgrade    = "None" #var.node_os_channel_upgrade
    image_cleaner_enabled = true
    image_cleaner_interval_hours = 168
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

# Wait for AKS cluster to be fully ready
/* resource "time_sleep" "wait_for_aks" {
  depends_on      = [module.aks]
  create_duration = "60s"
} */

# Role assignment for AKS to pull images from ACR
/* resource "azurerm_role_assignment" "aks_acr_pull" {
  scope                            = var.acr_id
  role_definition_name             = "AcrPull"
  principal_id                     = module.aks.kubelet_identity[0].object_id
  skip_service_principal_aad_check = true
  depends_on                       = [module.aks, time_sleep.wait_for_aks]
}

# Role assignment for AKS to push images to ACR (optional - for CI/CD)
resource "azurerm_role_assignment" "aks_acr_push" {
  scope                            = var.acr_id
  role_definition_name             = "AcrPush"
  principal_id                     = module.aks.kubelet_identity[0].object_id
  skip_service_principal_aad_check = true
  depends_on                       = [module.aks, time_sleep.wait_for_aks]
} */


resource "azuread_group" "azure_aks_group" {
  display_name     = "${local.company}-${local.project}-${local.environment}-ad-group"
  security_enabled = true
}
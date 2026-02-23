include "root" {
    path = find_in_parent_folders("root.hcl")
}

terraform {
    source = "../../../terraform//aks"
}

dependency "infra-base" {
  config_path = "../infra-base"
}

inputs = {
    # Environment
    environment         = "poc"
    resource_group_name = dependency.infra-base.outputs.resource_group_name
    vnet_subnet_id = dependency.infra-base.outputs.subnet_id
    log_analytics_workspace_id = dependency.infra-base.outputs.log_analytics_workspace_id

    # The address space of the spoke VNet, using a different CIDR block than the DR VNet
    # address_space = "10.112.0.0/12"
    
    # Subnet CIDRs - these should be within the VNet's address space
    # aks_subnet_prefix = "10.112.0.0/16"
    
}

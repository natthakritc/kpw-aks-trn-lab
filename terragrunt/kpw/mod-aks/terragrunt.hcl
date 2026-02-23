include "root" {
    path = find_in_parent_folders("root.hcl")
}

terraform {
    source = "../../../terraform//mod-aks"
}

dependency "infra-base" {
  config_path = "../infra-base"
}

# dependencies {
#     paths = ["../vnet_spoke","../vnet_hub", "../agw", "../log", "../acr"]
# }

# dependency "vnet_spoke" {
#     config_path = "../vnet_spoke" 
# }

# dependency "vnet_hub" {
#     config_path = "../vnet_hub"
# }

# dependency "agw" {
#     config_path = "../agw" 
# }

# dependency "log" {
#     config_path = "../log" 
# }

# dependency "acr" {
#     config_path = "../acr" 
# }

inputs = merge({
    resource_group_name = dependency.infra-base.outputs.resource_group_name
    vnet_id = dependency.infra-base.outputs.vnet_id ##
    subnet_id = dependency.infra-base.outputs.subnet_id ##
    
    # aks_identity_id = dependency.akv_spoke.outputs.aks_identity_id
    #appgw_id = dependency.agw.outputs.appgw_id
    #aks_subnet_id= dependency.vnet_spoke.outputs.aks_subnet_id
    #agw_subnet_id= dependency.vnet_hub.outputs.agw_subnet_id
    
    log_analytics_workspace_id = dependency.infra-base.outputs.log_analytics_workspace_id
    
    # agw_identity_id= dependency.akv.outputs.agw_identity_id
    # acr_id= dependency.acr.outputs.acr_id
    # acr_name= dependency.acr.outputs.acr_name
})
include "root" {
    path = find_in_parent_folders("root.hcl")
}

terraform {
    source = "../../../terraform//infra-base"
}

inputs = {
    # Environment
    environment         = "poc"
    # The address space of the spoke VNet, using a different CIDR block than the DR VNet
    address_space = "10.112.0.0/12"
    
    # Subnet CIDRs - these should be within the VNet's address space
    aks_subnet_prefix = "10.112.0.0/16"
    
}

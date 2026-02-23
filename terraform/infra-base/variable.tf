variable "company" {
  description = "Company short name"
  type        = string
}

variable "project_name" {
  description = "Project name"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
}

/* variable "resource_group_name" {
  description = "Override name for the resource group (not typically used as the module always creates a new resource group)"
  type        = string
  default     = null
} */

/* variable "resource_group" {
  type = object({
    create   = bool
    #name     = string
    #location = string
  })
} */

variable "common_tags" {
  description = "Common tags to apply to resources"
  type        = map(string)
  default     = {}
}

/* variable "vnet_name" {
  description = "Name of the spoke VNet (if not provided, a name will be generated)"
  type        = string
  default     = null
  
} */

/* variable "vnet" {
  type = object({
    create   = bool
    #name          = string
    address_space = list(string)
    dns_servers   = optional(list(string))
  })
} */

variable "address_space" {
  description = "Address space for the spoke VNet"
  type        = string
}

variable "aks_subnet_prefix" { 
  description = "Address prefix for the AKS subnet"
  type        = string
}

/*variable "subnets" {
  type = map(object({
    address_prefixes = list(string)

    # service_endpoints                              = optional(list(string))
    # private_endpoint_network_policies_enabled      = optional(bool, true)
    # private_link_service_network_policies_enabled  = optional(bool, true)

    # delegation = optional(object({
    #   name = string
    #   service_delegation = object({
    #     name    = string               # e.g. "Microsoft.Web/serverFarms"
    #     actions = optional(list(string), ["Microsoft.Network/virtualNetworks/subnets/join/action"])
    #   })
    # }))

    nsg = optional(object({
      name  = optional(string)
      rules = optional(list(object({
        name                       = string
        priority                   = number
        direction                  = string   # "Inbound" | "Outbound"
        access                     = string   # "Allow" | "Deny"
        protocol                   = string   # "Tcp" | "Udp" | "*"
        source_port_range          = optional(string, "*")
        destination_port_range     = optional(string, "*")
        source_address_prefix      = optional(string, "*")
        destination_address_prefix = optional(string, "*")
      })), [])
    }))

    route_table = optional(object({
      name   = optional(string)
      routes = list(object({
        name                   = string
        address_prefix         = string
        next_hop_type          = string        # "VirtualAppliance" | ...
        # next_hop_in_ip_address = optional(string)
      }))
    }))
  }))
}*/
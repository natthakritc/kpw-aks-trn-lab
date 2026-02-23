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

variable "common_tags" {
  description = "Common tags to apply to resources"
  type        = map(string)
  default     = {}
}

variable "resource_group_name" {
  description = "Override name for the resource group (not typically used as the module always creates a new resource group)"
  type        = string
  default     = null
  
}

variable "vnet_subnet_id" {
  description = "The subnet ID for the AKS cluster"
  type        = string
}

variable "log_analytics_workspace_id" {
  description = "The Log Analytics Workspace ID for AKS monitoring"
  type        = string
}

/* variable "address_space" {
  description = "Address space for the spoke VNet"
  type        = string
}

variable "aks_subnet_prefix" { 
  description = "Address prefix for the AKS subnet"
  type        = string
} */

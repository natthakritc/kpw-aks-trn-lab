variable "company" {}
variable "project_name" {}
variable "environment" {}
variable "location" {}
variable "resource_group_name" {}
# variable "address_space_spoke" {
#   type = list(string)
# }
# variable "aks_subnet_prefix" {
#   type = list(string)
# }
# variable "owner" {}
# variable "aks_subnet_id" {}
# variable "appgw_id" {}
# variable "agw_subnet_id" {}
variable "log_analytics_workspace_id" {}
# variable "aks_identity_id" {}
# variable "acr_id" {}
# variable "acr_name" {}
variable "subnet_id" {}

variable "system_nodepool_os_disk_type" {
  default = "Ephemeral"
}

variable "system_nodepool_os_disk_size_gb" {
  default = 30
}

variable "agents_size" {
  default = "Standard_D2s_v3"
}

variable "agents_min_count" {
  default = 1
}

variable "agents_max_count" {
  default = 2
}
variable "agents_count" {
  default = 1
}
variable "agents_max_pods" {
  default = 100
}
# variable "agents_pool_name" {
#   default = "system"
# }

# variable "node_pools" {
#   type = map(object({
#     mode                = string
#     name                = string
#     os_disk_type        = string
#     os_disk_size_gb     = string
#     vm_size             = string
#     auto_scaling_enabled = optional(bool, true)
#     min_count           = optional(number)
#     max_count           = optional(number)
#    # node_count          = number
#     max_pods            = number
#     vnet_subnet_id      = string
#     node_labels         = optional(map(string), {})
#   }))
# }
variable "agents_availability_zones" {
  type    = list(string)
  default = []
}
variable "agents_labels" {
  type    = map(string)
  default = {}
}

variable "agents_pool_max_surge" {
  type    = string
  default = "1"
}

variable "automatic_channel_upgrade" {
  type        = string
  default     = null
  description = "(Optional) The upgrade channel for this Kubernetes Cluster. Possible values are `patch`, `rapid`, `node-image` and `stable`. By default automatic-upgrades are turned off. Note that you cannot specify the patch version using `kubernetes_version` or `orchestrator_version` when using the `patch` upgrade channel. See [the documentation](https://learn.microsoft.com/en-us/azure/aks/auto-upgrade-cluster) for more information"

  validation {
    condition = var.automatic_channel_upgrade == null ? true : contains([
      "patch", "stable", "rapid", "node-image"
    ], var.automatic_channel_upgrade)
    error_message = "`automatic_channel_upgrade`'s possible values are `patch`, `stable`, `rapid` or `node-image`."
  }
}

variable "maintenance_window" {
  type = object({
    allowed = list(object({
      day   = string
      hours = set(number)
    })),
    not_allowed = list(object({
      end   = string
      start = string
    })),
  })
  default     = null
  description = "(Optional) Maintenance configuration of the managed cluster."
}


variable "maintenance_window_node_os" {
  type = object({
    day_of_month = optional(number)
    day_of_week  = optional(string)
    duration     = number
    frequency    = string
    interval     = number
    start_date   = optional(string)
    start_time   = optional(string)
    utc_offset   = optional(string)
    week_index   = optional(string)
    not_allowed = optional(set(object({
      end   = string
      start = string
    })))
  })
  default     = null
  description = <<-EOT
 - `day_of_month` -
 - `day_of_week` - (Optional) The day of the week for the maintenance run. Options are `Monday`, `Tuesday`, `Wednesday`, `Thurday`, `Friday`, `Saturday` and `Sunday`. Required in combination with weekly frequency.
 - `duration` - (Required) The duration of the window for maintenance to run in hours.
 - `frequency` - (Required) Frequency of maintenance. Possible options are `Daily`, `Weekly`, `AbsoluteMonthly` and `RelativeMonthly`.
 - `interval` - (Required) The interval for maintenance runs. Depending on the frequency this interval is week or month based.
 - `start_date` - (Optional) The date on which the maintenance window begins to take effect.
 - `start_time` - (Optional) The time for maintenance to begin, based on the timezone determined by `utc_offset`. Format is `HH:mm`.
 - `utc_offset` - (Optional) Used to determine the timezone for cluster maintenance.
 - `week_index` - (Optional) The week in the month used for the maintenance run. Options are `First`, `Second`, `Third`, `Fourth`, and `Last`.
 ---
 `not_allowed` block supports the following:
 - `end` - (Required) The end of a time span, formatted as an RFC3339 string.
 - `start` - (Required) The start of a time span, formatted as an RFC3339 string.
EOT
}


variable "node_os_channel_upgrade" {
  type        = string
  default     = null
  description = " (Optional) The upgrade channel for this Kubernetes Cluster Nodes' OS Image. Possible values are `Unmanaged`, `SecurityPatch`, `NodeImage` and `None`."
}

variable "common_tags" {
  description = "Common tags to apply to resources"
  type        = map(string)
  default     = {}
}
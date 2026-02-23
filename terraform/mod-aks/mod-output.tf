
# AKS Outputs
output "aks_id" {
  description = "AKS cluster ID"
  value       = module.aks.aks_id
}

output "aks_name" {
  description = "AKS cluster name"
  value       = module.aks.aks_name
}

output "kube_config" {
  description = "Kubernetes configuration"
  value       = module.aks.kube_config_raw
  sensitive   = true
}

output "kubelet_identity" {
  description = "AKS kubelet identity"
  value       = module.aks.kubelet_identity
}

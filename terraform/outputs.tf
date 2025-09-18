# Full kubeconfig
output "kube_config" {
  value     = azurerm_kubernetes_cluster.aks.kube_config_raw
  sensitive = true
}

# Frontend LoadBalancer IP (uses try() to avoid errors if IP not ready)
output "frontend_service_ip" {
  value = try(
    kubernetes_service.frontend.status[0].load_balancer[0].ingress[0].ip,
    "Pending"
  )
}

# AKS cluster name
output "aks_name" {
  value = azurerm_kubernetes_cluster.aks.name
}

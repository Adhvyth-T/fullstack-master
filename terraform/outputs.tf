# Full kubeconfig as string
output "kube_config" {
  value     = azurerm_kubernetes_cluster.aks.kube_config_raw
  sensitive = true
}

# Frontend LoadBalancer IP
output "frontend_service_ip" {
  value = kubernetes_service.frontend.status[0].load_balancer[0].ingress[0].ip
}

# AKS cluster name
output "aks_name" {
  value = azurerm_kubernetes_cluster.aks.name
}

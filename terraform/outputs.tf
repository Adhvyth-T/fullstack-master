output "frontend_service_ip" {
  description = "Public IP of the frontend service"
  value       = kubernetes_service.frontend.status[0].load_balancer[0].ingress[0].ip
}

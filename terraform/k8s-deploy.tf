# ----------------------------
# Backend Deployment
# ----------------------------
resource "kubernetes_deployment" "backend" {
  metadata {
    name = "backend"
    labels = { app = "backend" }
  }
  spec {
    replicas = 2
    selector {
      match_labels = { app = "backend" }
    }
    template {
      metadata {
        labels = {
          app     = "backend"
          rollout = timestamp()
        }
      }
      spec {
        container {
          name  = "backend"
          image = "adhvyth/devops-pipeline:backend-latest"
          port {
            container_port = 8080
          }
        }
      }
    }
  }
}

# ----------------------------
# Backend Service
# ----------------------------
resource "kubernetes_service" "backend" {
  metadata {
    name = "backend-svc"
  }
  spec {
    selector = {
      app = kubernetes_deployment.backend.metadata[0].labels["app"]
    }
    port {
      port        = 80
      target_port = 8080
    }
    type = "ClusterIP"
  }
}

# ----------------------------
# Frontend Deployment
# ----------------------------
resource "kubernetes_deployment" "frontend" {
  metadata {
    name = "frontend"
    labels = { app = "frontend" }
  }
  spec {
    replicas = 2
    selector {
      match_labels = { app = "frontend" }
    }
    template {
      metadata {
        labels = {
          app     = "frontend"
          rollout = timestamp()
        }
      }
      spec {
        container {
          name  = "frontend"
          image = "adhvyth/devops-pipeline:frontend-latest"
          port {
            container_port = 80
          }
          env {
            name  = "BACKEND_URL"
            value = "http://backend-svc"
          }
        }
      }
    }
  }
}

# ----------------------------
# Frontend Service
# ----------------------------
resource "kubernetes_service" "frontend" {
  metadata {
    name = "frontend-svc"
  }
  spec {
    selector = {
      app = kubernetes_deployment.frontend.metadata[0].labels["app"]
    }
    port {
      port        = 80
      target_port = 80
    }
    type = "LoadBalancer"
  }
}

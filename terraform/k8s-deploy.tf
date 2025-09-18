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
          rollout = replace(replace(timestamp(), ":", "-"), "Z", "")
        }
      }
      spec {
        container {
          name  = "backend"
          image = "adhvyth/devops-pipeline:backend-latest"
          port {
            container_port = 5003   # ✅ actual backend port
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
      port        = 80       # service port inside cluster
      target_port = 5003     # ✅ backend container port
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
          rollout = replace(replace(timestamp(), ":", "-"), "Z", "")
        }
      }
      spec {
        container {
          name  = "frontend"
          image = "adhvyth/devops-pipeline:frontend-latest"
          port {
            container_port = 3000   # ✅ frontend Dockerfile
          }
          env {
            name  = "BACKEND_URL"
            value = "http://backend-svc:80"   # ✅ cluster DNS
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
      port        = 80       # exposed LB port
      target_port = 3000     # ✅ frontend container port
    }
    type = "LoadBalancer"
  }
}

terraform {
  required_version = ">= 1.3.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.0.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.20.0"
    }
  }
}

provider "azurerm" {
  features {}
}

provider "kubernetes" {
  host                   = azurerm_kubernetes_cluster.aks.kube_config[0].host
  client_certificate     = base64decode(azurerm_kubernetes_cluster.aks.kube_config[0].client_certificate)
  client_key             = base64decode(azurerm_kubernetes_cluster.aks.kube_config[0].client_key)
  cluster_ca_certificate = base64decode(azurerm_kubernetes_cluster.aks.kube_config[0].cluster_ca_certificate)
}

# ✅ Use existing Resource Group
data "azurerm_resource_group" "rg" {
  name = "devops-pipeline-rg"
}

# AKS Cluster
resource "azurerm_kubernetes_cluster" "aks" {
  name                = "devops-pipeline-aks"
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name
  dns_prefix          = "devopspipeline"

  default_node_pool {
    name       = "default"
    node_count = 1
    vm_size    = "Standard_B2s" # ✅ safer size for free/limited subs
  }

  identity {
    type = "SystemAssigned"
  }
}

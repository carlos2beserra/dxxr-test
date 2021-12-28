terraform {
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.0.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.0.1"
    }
  }
}

variable "do_token" {}

provider "digitalocean" {
  token = var.do_token
}

resource "digitalocean_kubernetes_cluster" "k8scluster" {
  name    = "k8sdxxr"
  region  = "nyc3"
  version = "1.21.5-do.0"

  node_pool {
    name       = "worker-nodes"
    size       = "s-1vcpu-2gb"
    node_count = 3
  }
}
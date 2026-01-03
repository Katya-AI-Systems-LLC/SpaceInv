# Terraform Module for DevOps Tools Infrastructure
# Provides comprehensive DevOps tools setup including monitoring, logging, and CI/CD

terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.20"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.10"
    }
    null = {
      source  = "hashicorp/null"
      version = "~> 3.2"
    }
    template = {
      source  = "hashicorp/template"
      version = "~> 2.2"
    }
  }
}

# Provider configuration
provider "aws" {
  region = var.aws_region
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.cluster.token
}

provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.cluster.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority[0].data)
    token                  = data.aws_eks_cluster_auth.cluster.token
  }
}

# Variables
variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "cluster_name" {
  description = "EKS cluster name"
  type        = string
}

variable "namespace" {
  description = "Kubernetes namespace for DevOps tools"
  type        = string
  default     = "devops"
}

variable "enable_monitoring" {
  description = "Enable monitoring stack"
  type        = bool
  default     = true
}

variable "enable_logging" {
  description = "Enable logging stack"
  type        = bool
  default     = true
}

variable "enable_ci_cd" {
  description = "Enable CI/CD tools"
  type        = bool
  default     = true
}

variable "enable_security" {
  description = "Enable security tools"
  type        = bool
  default     = true
}

variable "monitoring_config" {
  description = "Monitoring configuration"
  type        = object({
    prometheus_replicas = number
    grafana_replicas   = number
    alertmanager_replicas = number
    storage_class      = string
    storage_size       = string
  })
  default = {
    prometheus_replicas = 2
    grafana_replicas   = 2
    alertmanager_replicas = 1
    storage_class      = "gp3"
    storage_size       = "100Gi"
  }
}

variable "logging_config" {
  description = "Logging configuration"
  type        = object({
    elasticsearch_replicas = number
    kibana_replicas      = number
    logstash_replicas    = number
    filebeat_replicas    = number
    storage_class        = string
    storage_size         = string
  })
  default = {
    elasticsearch_replicas = 3
    kibana_replicas      = 2
    logstash_replicas    = 2
    filebeat_replicas    = 1
    storage_class        = "gp3"
    storage_size         = "200Gi"
  }
}

# Data sources
data "aws_eks_cluster" "cluster" {
  name = var.cluster_name
}

data "aws_eks_cluster_auth" "cluster" {
  name = var.cluster_name
}

# Local values
locals {
  name_prefix = "devops-tools"
  tags = {
    Environment = "production"
    Project     = "space-invaders"
    ManagedBy   = "terraform"
    Component   = "devops-tools"
  }
}

# Namespace
resource "kubernetes_namespace" "devops" {
  metadata {
    name = var.namespace
    labels = merge(local.tags, {
      Name = var.namespace
    })
  }
  
  depends_on = [data.aws_eks_cluster.cluster]
}

# Monitoring Stack
module "monitoring" {
  count = var.enable_monitoring ? 1 : 0
  source = "./modules/monitoring"
  
  namespace = kubernetes_namespace.devops.metadata[0].name
  config    = var.monitoring_config
  tags      = local.tags
  
  depends_on = [kubernetes_namespace.devops]
}

# Logging Stack
module "logging" {
  count = var.enable_logging ? 1 : 0
  source = "./modules/logging"
  
  namespace = kubernetes_namespace.devops.metadata[0].name
  config    = var.logging_config
  tags      = local.tags
  
  depends_on = [kubernetes_namespace.devops]
}

# CI/CD Tools
module "ci_cd" {
  count = var.enable_ci_cd ? 1 : 0
  source = "./modules/ci-cd"
  
  namespace = kubernetes_namespace.devops.metadata[0].name
  tags      = local.tags
  
  depends_on = [kubernetes_namespace.devops]
}

# Security Tools
module "security" {
  count = var.enable_security ? 1 : 0
  source = "./modules/security"
  
  namespace = kubernetes_namespace.devops.metadata[0].name
  tags      = local.tags
  
  depends_on = [kubernetes_namespace.devops]
}

# Service Accounts and RBAC
resource "kubernetes_service_account" "devops_tools" {
  metadata {
    name      = "devops-tools"
    namespace = kubernetes_namespace.devops.metadata[0].name
    labels = merge(local.tags, {
      Name = "devops-tools"
    })
  }
}

resource "kubernetes_cluster_role" "devops_tools" {
  metadata {
    name = "devops-tools"
    labels = merge(local.tags, {
      Name = "devops-tools"
    })
  }
  
  rule {
    api_groups = [""]
    resources = ["pods", "services", "endpoints", "nodes"]
    verbs     = ["get", "list", "watch"]
  }
  
  rule {
    api_groups = ["apps"]
    resources = ["deployments", "replicasets", "daemonsets", "statefulsets"]
    verbs     = ["get", "list", "watch"]
  }
  
  rule {
    api_groups = ["batch"]
    resources = ["jobs", "cronjobs"]
    verbs     = ["get", "list", "watch"]
  }
}

resource "kubernetes_cluster_role_binding" "devops_tools" {
  metadata {
    name = "devops-tools"
    labels = merge(local.tags, {
      Name = "devops-tools"
    })
  }
  
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role.devops_tools.metadata[0].name
  }
  
  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.devops_tools.metadata[0].name
    namespace = kubernetes_namespace.devops.metadata[0].name
  }
}

# Network Policies
resource "kubernetes_network_policy" "devops_tools" {
  metadata {
    name      = "devops-tools-network-policy"
    namespace = kubernetes_namespace.devops.metadata[0].name
    labels = merge(local.tags, {
      Name = "devops-tools-network-policy"
    })
  }
  
  spec {
    pod_selector {
      match_labels = {
        "app.kubernetes.io/part-of" = "devops-tools"
      }
    }
    
    policy_types = ["Ingress", "Egress"]
    
    ingress {
      from {
        namespace_selector {
          match_labels = {
            name = "default"
          }
        }
      }
      ports {
        protocol = "TCP"
        port     = 80
      }
      ports {
        protocol = "TCP"
        port     = 443
      }
    }
    
    egress {
      to {
        namespace_selector {}
      }
      ports {
        protocol = "TCP"
        port     = 53
      }
      ports {
        protocol = "UDP"
        port     = 53
      }
    }
  }
}

# ConfigMaps for DevOps Tools
resource "kubernetes_config_map" "devops_config" {
  metadata {
    name      = "devops-config"
    namespace = kubernetes_namespace.devops.metadata[0].name
    labels = merge(local.tags, {
      Name = "devops-config"
    })
  }
  
  data = {
    "monitoring-config.yaml" = yamlencode({
      prometheus = {
        retention = "30d"
        scrape_interval = "15s"
        evaluation_interval = "15s"
      }
      grafana = {
        admin_password = "admin123"
        anonymous_access = false
      }
      alertmanager = {
        smtp_host = "smtp.example.com"
        smtp_port = 587
        smtp_user = "alerts@example.com"
      }
    })
    
    "logging-config.yaml" = yamlencode({
      elasticsearch = {
        cluster_name = "devops-logs"
        number_of_replicas = 3
        heap_size = "1g"
      }
      kibana = {
        server_port = 5601
        elasticsearch_hosts = ["http://elasticsearch:9200"]
      }
      logstash = {
        pipeline_workers = 4
        pipeline_batch_size = 125
      }
    })
    
    "security-config.yaml" = yamlencode({
      falco = {
        log_level = "info"
        priority = "Warning"
      }
      trivy = {
        scan_interval = "6h"
        severity = "HIGH,CRITICAL"
      }
      opa = {
        policy_path = "/policies"
        timeout = "5s"
      }
    })
  }
}

# Secrets for DevOps Tools
resource "kubernetes_secret" "devops_secrets" {
  metadata {
    name      = "devops-secrets"
    namespace = kubernetes_namespace.devops.metadata[0].name
    labels = merge(local.tags, {
      Name = "devops-secrets"
    })
  }
  
  type = "Opaque"
  
  data = {
    "grafana-admin-password" = base64encode("admin123")
    "alertmanager-smtp-password" = base64encode("smtp_password")
    "elasticsearch-password" = base64encode("elastic_password")
    "kibana-encryption-key" = base64encode("encryption_key_123")
  }
}

# Persistent Volumes
resource "kubernetes_persistent_volume_claim" "monitoring_storage" {
  count = var.enable_monitoring ? 1 : 0
  metadata {
    name      = "monitoring-storage"
    namespace = kubernetes_namespace.devops.metadata[0].name
    labels = merge(local.tags, {
      Name = "monitoring-storage"
    })
  }
  
  spec {
    access_modes = ["ReadWriteOnce"]
    storage_class_name = var.monitoring_config.storage_class
    resources {
      requests = {
        storage = var.monitoring_config.storage_size
      }
    }
  }
}

resource "kubernetes_persistent_volume_claim" "logging_storage" {
  count = var.enable_logging ? 1 : 0
  metadata {
    name      = "logging-storage"
    namespace = kubernetes_namespace.devops.metadata[0].name
    labels = merge(local.tags, {
      Name = "logging-storage"
    })
  }
  
  spec {
    access_modes = ["ReadWriteOnce"]
    storage_class_name = var.logging_config.storage_class
    resources {
      requests = {
        storage = var.logging_config.storage_size
      }
    }
  }
}

# Ingress for DevOps Tools
resource "kubernetes_ingress" "devops_tools" {
  metadata {
    name      = "devops-tools-ingress"
    namespace = kubernetes_namespace.devops.metadata[0].name
    labels = merge(local.tags, {
      Name = "devops-tools-ingress"
    })
    annotations = {
      "kubernetes.io/ingress.class" = "nginx"
      "cert-manager.io/cluster-issuer" = "letsencrypt-prod"
      "nginx.ingress.kubernetes.io/ssl-redirect" = "true"
      "nginx.ingress.kubernetes.io/force-ssl-redirect" = "true"
    }
  }
  
  spec {
    tls {
      hosts       = ["devops.space-invaders.local"]
      secret_name = "devops-tools-tls"
    }
    
    rule {
      host = "devops.space-invaders.local"
      http {
        path {
          path = "/grafana"
          backend {
            service {
              name = "grafana"
              port {
                number = 3000
              }
            }
          }
        }
        
        path {
          path = "/prometheus"
          backend {
            service {
              name = "prometheus"
              port {
                number = 9090
              }
            }
          }
        }
        
        path {
          path = "/kibana"
          backend {
            service {
              name = "kibana"
              port {
                number = 5601
              }
            }
          }
        }
        
        path {
          path = "/alertmanager"
          backend {
            service {
              name = "alertmanager"
              port {
                number = 9093
              }
            }
          }
        }
      }
    }
  }
}

# Horizontal Pod Autoscalers
resource "kubernetes_horizontal_pod_autoscaler" "prometheus" {
  count = var.enable_monitoring ? 1 : 0
  metadata {
    name      = "prometheus-hpa"
    namespace = kubernetes_namespace.devops.metadata[0].name
    labels = merge(local.tags, {
      Name = "prometheus-hpa"
    })
  }
  
  spec {
    scale_target_ref {
      api_version = "apps/v1"
      kind        = "Deployment"
      name        = "prometheus"
    }
    
    min_replicas = 1
    max_replicas = 5
    
    metric {
      type = "Resource"
      resource {
        name = "cpu"
        target {
          type               = "Utilization"
          average_utilization = 70
        }
      }
    }
    
    metric {
      type = "Resource"
      resource {
        name = "memory"
        target {
          type               = "Utilization"
          average_utilization = 80
        }
      }
    }
  }
}

resource "kubernetes_horizontal_pod_autoscaler" "elasticsearch" {
  count = var.enable_logging ? 1 : 0
  metadata {
    name      = "elasticsearch-hpa"
    namespace = kubernetes_namespace.devops.metadata[0].name
    labels = merge(local.tags, {
      Name = "elasticsearch-hpa"
    })
  }
  
  spec {
    scale_target_ref {
      api_version = "apps/v1"
      kind        = "StatefulSet"
      name        = "elasticsearch"
    }
    
    min_replicas = 2
    max_replicas = 6
    
    metric {
      type = "Resource"
      resource {
        name = "cpu"
        target {
          type               = "Utilization"
          average_utilization = 70
        }
      }
    }
    
    metric {
      type = "Resource"
      resource {
        name = "memory"
        target {
          type               = "Utilization"
          average_utilization = 80
        }
      }
    }
  }
}

# Pod Disruption Budgets
resource "kubernetes_pod_disruption_budget" "prometheus" {
  count = var.enable_monitoring ? 1 : 0
  metadata {
    name      = "prometheus-pdb"
    namespace = kubernetes_namespace.devops.metadata[0].name
    labels = merge(local.tags, {
      Name = "prometheus-pdb"
    })
  }
  
  spec {
    selector {
      match_labels = {
        app = "prometheus"
      }
    }
    
    min_available = 1
  }
}

resource "kubernetes_pod_disruption_budget" "elasticsearch" {
  count = var.enable_logging ? 1 : 0
  metadata {
    name      = "elasticsearch-pdb"
    namespace = kubernetes_namespace.devops.metadata[0].name
    labels = merge(local.tags, {
      Name = "elasticsearch-pdb"
    })
  }
  
  spec {
    selector {
      match_labels = {
        app = "elasticsearch"
      }
    }
    
    min_available = 2
  }
}

# Service Monitors for Prometheus
resource "kubernetes_manifest" "service_monitors" {
  count = var.enable_monitoring ? 1 : 0
  manifest = {
    apiVersion = "monitoring.coreos.com/v1"
    kind       = "ServiceMonitor"
    metadata = {
      name      = "devops-tools-servicemonitor"
      namespace = kubernetes_namespace.devops.metadata[0].name
      labels = merge(local.tags, {
        Name = "devops-tools-servicemonitor"
      })
    }
    spec = {
      selector = {
        matchLabels = {
          "app.kubernetes.io/part-of" = "devops-tools"
        }
      }
      endpoints = [
        {
          port = "http"
          path = "/metrics"
          interval = "30s"
        }
      ]
    }
  }
}

# Outputs
output "namespace" {
  description = "DevOps tools namespace"
  value       = kubernetes_namespace.devops.metadata[0].name
}

output "monitoring_enabled" {
  description = "Monitoring stack enabled"
  value       = var.enable_monitoring
}

output "logging_enabled" {
  description = "Logging stack enabled"
  value       = var.enable_logging
}

output "ci_cd_enabled" {
  description = "CI/CD tools enabled"
  value       = var.enable_ci_cd
}

output "security_enabled" {
  description = "Security tools enabled"
  value       = var.enable_security
}

output "ingress_url" {
  description = "DevOps tools ingress URL"
  value       = "https://devops.space-invaders.local"
}

output "grafana_url" {
  description = "Grafana URL"
  value       = "https://devops.space-invaders.local/grafana"
}

output "prometheus_url" {
  description = "Prometheus URL"
  value       = "https://devops.space-invaders.local/prometheus"
}

output "kibana_url" {
  description = "Kibana URL"
  value       = "https://devops.space-invaders.local/kibana"
}

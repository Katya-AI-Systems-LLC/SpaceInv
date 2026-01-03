# Terraform Module for Monitoring Stack
# Provides Prometheus, Grafana, Alertmanager, and related monitoring tools

terraform {
  required_version = ">= 1.0"
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.20"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.10"
    }
  }
}

# Variables
variable "namespace" {
  description = "Kubernetes namespace"
  type        = string
}

variable "config" {
  description = "Monitoring configuration"
  type        = object({
    prometheus_replicas = number
    grafana_replicas   = number
    alertmanager_replicas = number
    storage_class      = string
    storage_size       = string
  })
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}

# Local values
locals {
  name_prefix = "monitoring"
  merged_tags = merge(var.tags, {
    Component = "monitoring"
  })
}

# Prometheus Helm Chart
resource "helm_release" "prometheus" {
  name       = "prometheus"
  namespace  = var.namespace
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
  version    = "45.0.0"
  
  set {
    name  = "prometheus.prometheusSpec.replicas"
    value = var.config.prometheus_replicas
  }
  
  set {
    name  = "grafana.replicas"
    value = var.config.grafana_replicas
  }
  
  set {
    name  = "alertmanager.alertmanagerSpec.replicas"
    value = var.config.alertmanager_replicas
  }
  
  set {
    name  = "prometheus.prometheusSpec.storageSpec.volumeClaimTemplate.spec.storageClassName"
    value = var.config.storage_class
  }
  
  set {
    name  = "prometheus.prometheusSpec.storageSpec.volumeClaimTemplate.spec.resources.requests.storage"
    value = var.config.storage_size
  }
  
  set {
    name  = "grafana.adminPassword"
    value = "admin123"
  }
  
  set {
    name  = "grafana.service.type"
    value = "ClusterIP"
  }
  
  set {
    name  = "prometheus.service.type"
    value = "ClusterIP"
  }
  
  set {
    name  = "alertmanager.service.type"
    value = "ClusterIP"
  }
  
  set {
    name  = "kube-state-metrics.enabled"
    value = true
  }
  
  set {
    name  = "node-exporter.enabled"
    value = true
  }
  
  set {
    name  = "prometheus-node-exporter.enabled"
    value = true
  }
  
  set {
    name  = "prometheus-operator.enabled"
    value = true
  }
  
  values = [
    yamlencode({
      global = {
        commonLabels = local.merged_tags
      }
      
      prometheus = {
        prometheusSpec = {
          serviceMonitorSelectorNilUsesHelmValues = false
          podMonitorSelectorNilUsesHelmValues = false
          ruleSelectorNilUsesHelmValues = false
          probeSelectorNilUsesHelmValues = false
          
          retention = "30d"
          scrape_interval = "15s"
          evaluation_interval = "15s"
          
          resources = {
            requests = {
              cpu    = "200m"
              memory = "1000Mi"
            }
            limits = {
              cpu    = "1000m"
              memory = "2000Mi"
            }
          }
          
          storageSpec = {
            volumeClaimTemplate = {
              spec = {
                storageClassName = var.config.storage_class
                accessModes      = ["ReadWriteOnce"]
                resources = {
                  requests = {
                    storage = var.config.storage_size
                  }
                }
              }
            }
          }
        }
      }
      
      grafana = {
        adminPassword = "admin123"
        
        service = {
          type = "ClusterIP"
          port = 80
        }
        
        resources = {
          requests = {
            cpu    = "200m"
            memory = "256Mi"
          }
          limits = {
            cpu    = "500m"
            memory = "512Mi"
          }
        }
        
        sidecar = {
          datasources = {
            enabled = true
          }
          dashboards = {
            enabled = true
            provider = {
              allowNamespace = ["monitoring", "default", var.namespace]
            }
          }
        }
        
        grafana.ini = {
          server = {
            domain = "devops.space-invaders.local"
            root_url = "https://devops.space-invaders.local/grafana"
            serve_from_sub_path = true
          }
          
          auth = {
            disable_login_form = false
          }
          
          security = {
            allow_embedding = true
          }
          
          analytics = {
            check_for_updates = false
            reporting_enabled = false
          }
        }
      }
      
      alertmanager = {
        alertmanagerSpec = {
          replicas = var.config.alertmanager_replicas
          
          resources = {
            requests = {
              cpu    = "100m"
              memory = "256Mi"
            }
            limits = {
              cpu    = "500m"
              memory = "512Mi"
            }
          }
          
          storage = {
            volumeClaimTemplate = {
              spec = {
                storageClassName = var.config.storage_class
                accessModes      = ["ReadWriteOnce"]
                resources = {
                  requests = {
                    storage = "10Gi"
                  }
                }
              }
            }
          }
        }
        
        config = {
          global = {
            smtp_smarthost = "smtp.example.com:587"
            smtp_from = "alerts@space-invaders.local"
            smtp_auth_username = "alerts@space-invaders.local"
          }
          
          route = {
            group_by = ["alertname", "cluster", "service"]
            group_wait = "10s"
            group_interval = "10s"
            repeat_interval = "1h"
            receiver = "default"
            
            routes = [
              {
                match = {
                  severity = "critical"
                }
                receiver = "critical"
              },
              {
                match = {
                  severity = "warning"
                }
                receiver = "warning"
              }
            ]
          }
          
          receivers = [
            {
              name = "default"
              email_configs = [
                {
                  to = "admin@space-invaders.local"
                  subject = "[Alert] {{ .GroupLabels.alertname }}"
                  body = "{{ range .Alerts }}{{ .Annotations.description }}{{ end }}"
                }
              ]
            },
            {
              name = "critical"
              email_configs = [
                {
                  to = "critical@space-invaders.local"
                  subject = "[CRITICAL] {{ .GroupLabels.alertname }}"
                  body = "{{ range .Alerts }}{{ .Annotations.description }}{{ end }}"
                }
              ]
            },
            {
              name = "warning"
              email_configs = [
                {
                  to = "warning@space-invaders.local"
                  subject = "[WARNING] {{ .GroupLabels.alertname }}"
                  body = "{{ range .Alerts }}{{ .Annotations.description }}{{ end }}"
                }
              ]
            }
          ]
        }
      }
      
      kube-state-metrics = {
        resources = {
          requests = {
            cpu    = "100m"
            memory = "128Mi"
          }
          limits = {
            cpu    = "200m"
            memory = "256Mi"
          }
        }
      }
      
      node-exporter = {
        resources = {
          requests = {
            cpu    = "100m"
            memory = "128Mi"
          }
          limits = {
            cpu    = "200m"
            memory = "256Mi"
          }
        }
      }
    })
  ]
}

# Additional Grafana Dashboards
resource "kubernetes_config_map" "grafana_dashboards" {
  metadata {
    name      = "grafana-dashboards"
    namespace = var.namespace
    labels = merge(local.merged_tags, {
      Name = "grafana-dashboards"
      grafana_dashboard = "1"
    })
  }
  
  data = {
    "space-invaders-overview.json" = file("${path.module}/dashboards/space-invaders-overview.json")
    "kubernetes-overview.json" = file("${path.module}/dashboards/kubernetes-overview.json")
    "infrastructure-metrics.json" = file("${path.module}/dashboards/infrastructure-metrics.json")
    "application-performance.json" = file("${path.module}/dashboards/application-performance.json")
    "security-monitoring.json" = file("${path.module}/dashboards/security-monitoring.json")
  }
}

# Prometheus Rules
resource "kubernetes_config_map" "prometheus_rules" {
  metadata {
    name      = "prometheus-rules"
    namespace = var.namespace
    labels = merge(local.merged_tags, {
      Name = "prometheus-rules"
      prometheus_rule = "1"
    })
  }
  
  data = {
    "space-invaders-rules.yml" = file("${path.module}/rules/space-invaders-rules.yml")
    "kubernetes-rules.yml" = file("${path.module}/rules/kubernetes-rules.yml")
    "infrastructure-rules.yml" = file("${path.module}/rules/infrastructure-rules.yml")
    "security-rules.yml" = file("${path.module}/rules/security-rules.yml")
  }
}

# Service Account for Monitoring
resource "kubernetes_service_account" "monitoring" {
  metadata {
    name      = "monitoring"
    namespace = var.namespace
    labels = merge(local.merged_tags, {
      Name = "monitoring"
    })
  }
}

# Cluster Role for Monitoring
resource "kubernetes_cluster_role" "monitoring" {
  metadata {
    name = "monitoring"
    labels = merge(local.merged_tags, {
      Name = "monitoring"
    })
  }
  
  rule {
    api_groups = [""]
    resources = ["nodes", "nodes/metrics", "services", "endpoints", "pods"]
    verbs     = ["get", "list", "watch"]
  }
  
  rule {
    api_groups = [""]
    resources = ["configmaps"]
    verbs     = ["get"]
  }
  
  rule {
    api_groups = ["apps"]
    resources = ["deployments", "replicasets", "daemonsets", "statefulsets"]
    verbs     = ["get", "list", "watch"]
  }
  
  rule {
    api_groups = ["batch"]
    resources = ["cronjobs", "jobs"]
    verbs     = ["get", "list", "watch"]
  }
  
  rule {
    api_groups = ["extensions"]
    resources = ["replicasets"]
    verbs     = ["get", "list", "watch"]
  }
  
  rule {
    nonResourceURLs = ["/metrics"]
    verbs          = ["get"]
  }
}

# Cluster Role Binding for Monitoring
resource "kubernetes_cluster_role_binding" "monitoring" {
  metadata {
    name = "monitoring"
    labels = merge(local.merged_tags, {
      Name = "monitoring"
    })
  }
  
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role.monitoring.metadata[0].name
  }
  
  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.monitoring.metadata[0].name
    namespace = var.namespace
  }
}

# Network Policy for Monitoring
resource "kubernetes_network_policy" "monitoring" {
  metadata {
    name      = "monitoring-network-policy"
    namespace = var.namespace
    labels = merge(local.merged_tags, {
      Name = "monitoring-network-policy"
    })
  }
  
  spec {
    pod_selector {
      match_labels = {
        "app.kubernetes.io/part-of" = "kube-prometheus-stack"
      }
    }
    
    policy_types = ["Ingress", "Egress"]
    
    ingress {
      from {
        namespace_selector {}
      }
      ports {
        protocol = "TCP"
        port     = 80
      }
      ports {
        protocol = "TCP"
        port     = 443
      }
      ports {
        protocol = "TCP"
        port     = 9090
      }
      ports {
        protocol = "TCP"
        port     = 3000
      }
      ports {
        protocol = "TCP"
        port     = 9093
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
      ports {
        protocol = "TCP"
        port     = 443
      }
      ports {
        protocol = "TCP"
        port     = 80
      }
    }
  }
}

# Horizontal Pod Autoscaler for Prometheus
resource "kubernetes_horizontal_pod_autoscaler" "prometheus" {
  metadata {
    name      = "prometheus"
    namespace = var.namespace
    labels = merge(local.merged_tags, {
      Name = "prometheus-hpa"
    })
  }
  
  spec {
    scale_target_ref {
      api_version = "apps/v1"
      kind        = "Deployment"
      name        = "prometheus-kube-prometheus-prometheus"
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

# Pod Disruption Budget for Prometheus
resource "kubernetes_pod_disruption_budget" "prometheus" {
  metadata {
    name      = "prometheus"
    namespace = var.namespace
    labels = merge(local.merged_tags, {
      Name = "prometheus-pdb"
    })
  }
  
  spec {
    selector {
      match_labels = {
        "app.kubernetes.io/name" = "prometheus"
        "app.kubernetes.io/part-of" = "kube-prometheus-stack"
      }
    }
    
    min_available = 1
  }
}

# Service Monitor for Custom Applications
resource "kubernetes_manifest" "application_service_monitor" {
  manifest = {
    apiVersion = "monitoring.coreos.com/v1"
    kind       = "ServiceMonitor"
    metadata = {
      name      = "space-invaders-applications"
      namespace = var.namespace
      labels = merge(local.merged_tags, {
        Name = "space-invaders-applications"
      })
    }
    spec = {
      selector = {
        matchLabels = {
          "app.kubernetes.io/name" = "space-invaders"
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
output "prometheus_service" {
  description = "Prometheus service name"
  value       = "prometheus-kube-prometheus-prometheus"
}

output "grafana_service" {
  description = "Grafana service name"
  value       = "prometheus-grafana"
}

output "alertmanager_service" {
  description = "Alertmanager service name"
  value       = "prometheus-kube-prometheus-alertmanager"
}

output "prometheus_url" {
  description = "Prometheus URL"
  value       = "http://prometheus-kube-prometheus-prometheus.${var.namespace}.svc.cluster.local:9090"
}

output "grafana_url" {
  description = "Grafana URL"
  value       = "http://prometheus-grafana.${var.namespace}.svc.cluster.local:3000"
}

output "alertmanager_url" {
  description = "Alertmanager URL"
  value       = "http://prometheus-kube-prometheus-alertmanager.${var.namespace}.svc.cluster.local:9093"
}

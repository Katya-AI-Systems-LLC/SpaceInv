# Terraform Module for Logging Stack
# Provides Elasticsearch, Kibana, Logstash, and Filebeat for centralized logging

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
  description = "Logging configuration"
  type        = object({
    elasticsearch_replicas = number
    kibana_replicas      = number
    logstash_replicas    = number
    filebeat_replicas    = number
    storage_class        = string
    storage_size         = string
  })
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}

# Local values
locals {
  name_prefix = "logging"
  merged_tags = merge(var.tags, {
    Component = "logging"
  })
}

# Elasticsearch Helm Chart
resource "helm_release" "elasticsearch" {
  name       = "elasticsearch"
  namespace  = var.namespace
  repository = "https://helm.elastic.co"
  chart      = "elasticsearch"
  version    = "8.5.1"
  
  set {
    name  = "replicas"
    value = var.config.elasticsearch_replicas
  }
  
  set {
    name  = "volumeClaimTemplate.storageClassName"
    value = var.config.storage_class
  }
  
  set {
    name  = "volumeClaimTemplate.resources.requests.storage"
    value = var.config.storage_size
  }
  
  set {
    name  = "service.type"
    value = "ClusterIP"
  }
  
  set {
    name  = "minimumMasterNodes"
    value = var.config.elasticsearch_replicas
  }
  
  values = [
    yamlencode({
      global = {
        commonLabels = local.merged_tags
      }
      
      clusterName = "devops-logs"
      nodeGroup = "master"
      
      roles = ["master", "data", "ingest"]
      
      replicas = var.config.elasticsearch_replicas
      
      minimumMasterNodes = var.config.elasticsearch_replicas
      
      volumeClaimTemplate = {
        accessModes = ["ReadWriteOnce"]
        storageClassName = var.config.storage_class
        resources = {
          requests = {
            storage = var.config.storage_size
          }
        }
      }
      
      service = {
        type = "ClusterIP"
        port = 9200
      }
      
      resources = {
        requests = {
          cpu    = "500m"
          memory = "2Gi"
        }
        limits = {
          cpu    = "2000m"
          memory = "4Gi"
        }
      }
      
      esConfig = {
        "xpack.security.enabled" = "false"
        "xpack.monitoring.collection.enabled" = "true"
        "cluster.routing.allocation.disk.threshold_enabled" = "true"
        "cluster.routing.allocation.disk.watermark.low" = "85%"
        "cluster.routing.allocation.disk.watermark.high" = "95%"
        "cluster.routing.allocation.disk.watermark.flood_stage" = "95%"
      }
      
      envFrom = [
        {
          configMapRef = {
            name = "elasticsearch-config"
          }
        }
      ]
    })
  ]
}

# Kibana Helm Chart
resource "helm_release" "kibana" {
  name       = "kibana"
  namespace  = var.namespace
  repository = "https://helm.elastic.co"
  chart      = "kibana"
  version    = "8.5.1"
  
  set {
    name  = "replicas"
    value = var.config.kibana_replicas
  }
  
  set {
    name  = "service.type"
    value = "ClusterIP"
  }
  
  set {
    name  = "elasticsearchHosts"
    value = "http://elasticsearch:9200"
  }
  
  values = [
    yamlencode({
      global = {
        commonLabels = local.merged_tags
      }
      
      replicas = var.config.kibana_replicas
      
      service = {
        type = "ClusterIP"
        port = 5601
      }
      
      resources = {
        requests = {
          cpu    = "200m"
          memory = "512Mi"
        }
        limits = {
          cpu    = "1000m"
          memory = "1Gi"
        }
      }
      
      kibanaConfig = {
        "xpack.security.enabled" = "false"
        "xpack.monitoring.collection.enabled" = "true"
        "xpack.reporting.encryptionKey" = "encryption_key_12345678901234567890"
        "server.publicBaseUrl" = "https://devops.space-invaders.local/kibana"
        "server.host" = "0.0.0.0"
        "server.port" = 5601
        "server.rewriteBasePath" = "true"
        "server.basePath" = "/kibana"
        "logging.dest" = "stdout"
        "logging.silent" = "false"
        "logging.quiet" = "false"
        "logging.verbose" = "false"
      }
      
      envFrom = [
        {
          configMapRef = {
            name = "kibana-config"
          }
        },
        {
          secretRef = {
            name = "kibana-secrets"
          }
        }
      ]
      
      ingress = {
        enabled = false  # We'll create our own ingress
      }
    })
  ]
}

# Logstash Helm Chart
resource "helm_release" "logstash" {
  name       = "logstash"
  namespace  = var.namespace
  repository = "https://helm.elastic.co"
  chart      = "logstash"
  version    = "8.5.1"
  
  set {
    name  = "replicas"
    value = var.config.logstash_replicas
  }
  
  set {
    name  = "service.type"
    value = "ClusterIP"
  }
  
  values = [
    yamlencode({
      global = {
        commonLabels = local.merged_tags
      }
      
      replicas = var.config.logstash_replicas
      
      service = {
        type = "ClusterIP"
        ports = [
          {
            name = "http"
            port = 8080
          },
          {
            name = "beats"
            port = 5044
          }
        ]
      }
      
      resources = {
        requests = {
          cpu    = "500m"
          memory = "1Gi"
        }
        limits = {
          cpu    = "2000m"
          memory = "2Gi"
        }
      }
      
      logstashConfig = {
        "http.host" = "0.0.0.0"
        "http.port" = 8080
        "path.data" = "/usr/share/logstash/data"
        "pipeline.workers" = 4
        "pipeline.batch.size" = 125
        "pipeline.batch.delay" = 50
        "config.reload.automatic" = "true"
        "config.reload.interval" = "10s"
      }
      
      logstashPipeline = {
        "input" = {
          "beats" = {
            "port" = 5044
            "host" = "0.0.0.0"
          }
        }
        "filter" = [
          {
            "grok" = {
              "match" = {
                "message" = "%{COMBINEDAPACHELOG}"
              }
            }
          },
          {
            "date" = {
              "match" = ["timestamp", "dd/MMM/yyyy:HH:mm:ss Z"]
            }
          },
          {
            "geoip" = {
              "source" = "clientip"
              "target" = "geoip"
            }
          },
          {
            "useragent" = {
              "source" = "agent"
              "target" = "user_agent"
            }
          }
        ]
        "output" = {
          "elasticsearch" = {
            "hosts" = ["elasticsearch:9200"]
            "index" = "logstash-%{+YYYY.MM.dd}"
          }
        }
      }
      
      extraEnvs = [
        {
          name = "LS_JAVA_OPTS"
          value = "-Xmx1g -Xms1g"
        }
      ]
      
      persistence = {
        enabled = true
        storageClassName = var.config.storage_class
        size = "10Gi"
      }
    })
  ]
}

# Filebeat Helm Chart
resource "helm_release" "filebeat" {
  name       = "filebeat"
  namespace  = var.namespace
  repository = "https://helm.elastic.co"
  chart      = "filebeat"
  version    = "8.5.1"
  
  set {
    name  = "daemonset"
    value = "true"
  }
  
  values = [
    yamlencode({
      global = {
        commonLabels = local.merged_tags
      }
      
      daemonset = {
        true
      }
      
      filebeatConfig = {
        "filebeat.inputs" = [
          {
            "type" = "container"
            "paths" = [
              "/var/log/containers/*.log"
            ]
            "processors" = [
              {
                "add_kubernetes_metadata" = {
                  "host" = "${NODE_NAME}"
                  "matchers" = [
                    {
                      "logs_path" = {
                        "logs_path" = "/var/log/containers/"
                      }
                    }
                  ]
                }
              },
              {
                "add_docker_metadata" = {
                  "host" = "unix:///var/run/docker.sock"
                }
              }
            ]
          }
        ]
        "output.logstash" = {
          "hosts" = ["logstash:5044"]
        }
        "logging.level" = "info"
        "logging.to_files" = "true"
        "logging.files" = {
          "path" = "/var/log/filebeat"
          "name" = "filebeat"
          "keepfiles" = 7
          "permissions" = "0644"
        }
      }
      
      resources = {
        requests = {
          cpu    = "100m"
          memory = "200Mi"
        }
        limits = {
          cpu    = "500m"
          memory = "500Mi"
        }
      }
      
      extraVolumes = [
        {
          "name" = "varlogcontainers"
          "hostPath" = {
            "path" = "/var/log/containers"
          }
        },
        {
          "name" = "vardockerlibcontainers"
          "hostPath" = {
            "path" = "/var/lib/docker/containers"
          }
        },
        {
          "name" = "varrundockersock"
          "hostPath" = {
            "path" = "/var/run/docker.sock"
          }
        }
      ]
      
      extraVolumeMounts = [
        {
          "name" = "varlogcontainers"
          "mountPath" = "/var/log/containers"
          "readOnly" = true
        },
        {
          "name" = "vardockerlibcontainers"
          "mountPath" = "/var/lib/docker/containers"
          "readOnly" = true
        },
        {
          "name" = "varrundockersock"
          "mountPath" = "/var/run/docker.sock"
          "readOnly" = true
        }
      ]
    })
  ]
}

# Elasticsearch ConfigMap
resource "kubernetes_config_map" "elasticsearch_config" {
  metadata {
    name      = "elasticsearch-config"
    namespace = var.namespace
    labels = merge(local.merged_tags, {
      Name = "elasticsearch-config"
    })
  }
  
  data = {
    "elasticsearch.yml" = yamlencode({
      cluster = {
        name = "devops-logs"
      }
      node = {
        name = "elasticsearch"
        master = true
        data = true
        ingest = true
      }
      path = {
        data = "/usr/share/elasticsearch/data"
        logs = "/usr/share/elasticsearch/logs"
      }
      network = {
        host = "0.0.0.0"
      }
      discovery = {
        type = "single-node"
      }
      xpack = {
        security = {
          enabled = false
        }
        monitoring = {
          collection = {
            enabled = true
          }
        }
      }
      indices = {
        lifecycle = {
          poll_interval = "1m"
        }
      }
    })
  }
}

# Kibana ConfigMap
resource "kubernetes_config_map" "kibana_config" {
  metadata {
    name      = "kibana-config"
    namespace = var.namespace
    labels = merge(local.merged_tags, {
      Name = "kibana-config"
    })
  }
  
  data = {
    "kibana.yml" = yamlencode({
      server = {
        host = "0.0.0.0"
        port = 5601
        publicBaseUrl = "https://devops.space-invaders.local/kibana"
        rewriteBasePath = true
        basePath = "/kibana"
      }
      elasticsearch = {
        hosts = ["http://elasticsearch:9200"]
      }
      logging = {
        dest = "stdout"
        silent = false
        quiet = false
        verbose = false
      }
      xpack = {
        security = {
          enabled = false
        }
        monitoring = {
          ui = {
            enabled = true
          }
        }
      }
    })
  }
}

# Kibana Secrets
resource "kubernetes_secret" "kibana_secrets" {
  metadata {
    name      = "kibana-secrets"
    namespace = var.namespace
    labels = merge(local.merged_tags, {
      Name = "kibana-secrets"
    })
  }
  
  type = "Opaque"
  
  data = {
    "encryption-key" = base64encode("encryption_key_12345678901234567890")
    "reporting-encryption-key" = base64encode("reporting_key_12345678901234567890")
  }
}

# Index Templates
resource "kubernetes_config_map" "index_templates" {
  metadata {
    name      = "index-templates"
    namespace = var.namespace
    labels = merge(local.merged_tags, {
      Name = "index-templates"
    })
  }
  
  data = {
    "logstash-template.json" = jsonencode({
      "index_patterns" = ["logstash-*"]
      "template" = {
        "settings" = {
          "number_of_shards" = 1
          "number_of_replicas" = 1
          "index" = {
            "lifecycle" = {
              "name" = "logstash-policy"
              "rollover_alias" = "logstash"
            }
          }
        }
        "mappings" = {
          "properties" = {
            "@timestamp" = {
              "type" = "date"
            }
            "clientip" = {
              "type" = "ip"
            }
            "geoip" = {
              "properties" = {
                "location" = {
                  "type" = "geo_point"
                }
              }
            }
            "user_agent" = {
              "properties" = {
                "os" = {
                  "properties" = {
                    "name" = {
                      "type" = "keyword"
                    }
                  }
                }
                "device" = {
                  "properties" = {
                    "name" = {
                      "type" = "keyword"
                    }
                  }
                }
              }
            }
          }
        }
      }
    })
    
    "application-template.json" = jsonencode({
      "index_patterns" = ["application-*"]
      "template" = {
        "settings" = {
          "number_of_shards" = 1
          "number_of_replicas" = 1
          "index" = {
            "lifecycle" = {
              "name" = "application-policy"
              "rollover_alias" = "application"
            }
          }
        }
        "mappings" = {
          "properties" = {
            "@timestamp" = {
              "type" = "date"
            }
            "level" = {
              "type" = "keyword"
            }
            "message" = {
              "type" = "text"
              "analyzer" = "standard"
            }
            "service" = {
              "type" = "keyword"
            }
            "environment" = {
              "type" = "keyword"
            }
            "trace_id" = {
              "type" = "keyword"
            }
            "span_id" = {
              "type" = "keyword"
            }
          }
        }
      }
    })
  }
}

# Index Lifecycle Policies
resource "kubernetes_config_map" "lifecycle_policies" {
  metadata {
    name      = "lifecycle-policies"
    namespace = var.namespace
    labels = merge(local.merged_tags, {
      Name = "lifecycle-policies"
    })
  }
  
  data = {
    "logstash-policy.json" = jsonencode({
      "policy" = {
        "phases" = {
          "hot" = {
            "actions" = {
              "rollover" = {
                "max_size" = "10GB"
                "max_age" = "1d"
              }
            }
          }
          "warm" = {
            "min_age" = "7d"
            "actions" = {
              "allocate" = {
                "number_of_replicas" = 0
              }
            }
          }
          "cold" = {
            "min_age" = "30d"
            "actions" = {
              "allocate" = {
                "number_of_replicas" = 0
              }
            }
          }
          "delete" = {
            "min_age" = "90d"
          }
        }
      }
    })
    
    "application-policy.json" = jsonencode({
      "policy" = {
        "phases" = {
          "hot" = {
            "actions" = {
              "rollover" = {
                "max_size" = "5GB"
                "max_age" = "1d"
              }
            }
          }
          "warm" = {
            "min_age" = "7d"
            "actions" = {
              "allocate" = {
                "number_of_replicas" = 0
              }
            }
          }
          "cold" = {
            "min_age" = "30d"
            "actions" = {
              "allocate" = {
                "number_of_replicas" = 0
              }
            }
          }
          "delete" = {
            "min_age" = "60d"
          }
        }
      }
    })
  }
}

# Service Account for Logging
resource "kubernetes_service_account" "logging" {
  metadata {
    name      = "logging"
    namespace = var.namespace
    labels = merge(local.merged_tags, {
      Name = "logging"
    })
  }
}

# Cluster Role for Logging
resource "kubernetes_cluster_role" "logging" {
  metadata {
    name = "logging"
    labels = merge(local.merged_tags, {
      Name = "logging"
    })
  }
  
  rule {
    api_groups = [""]
    resources = ["pods", "nodes", "services", "endpoints"]
    verbs     = ["get", "list", "watch"]
  }
  
  rule {
    api_groups = ["apps"]
    resources = ["deployments", "replicasets", "daemonsets", "statefulsets"]
    verbs     = ["get", "list", "watch"]
  }
}

# Cluster Role Binding for Logging
resource "kubernetes_cluster_role_binding" "logging" {
  metadata {
    name = "logging"
    labels = merge(local.merged_tags, {
      Name = "logging"
    })
  }
  
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role.logging.metadata[0].name
  }
  
  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.logging.metadata[0].name
    namespace = var.namespace
  }
}

# Network Policy for Logging
resource "kubernetes_network_policy" "logging" {
  metadata {
    name      = "logging-network-policy"
    namespace = var.namespace
    labels = merge(local.merged_tags, {
      Name = "logging-network-policy"
    })
  }
  
  spec {
    pod_selector {
      match_labels = {
        "app.kubernetes.io/name" = "elasticsearch"
      }
    }
    
    policy_types = ["Ingress", "Egress"]
    
    ingress {
      from {
        namespace_selector {}
      }
      ports {
        protocol = "TCP"
        port     = 9200
      }
      ports {
        protocol = "TCP"
        port     = 9300
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

# Horizontal Pod Autoscaler for Elasticsearch
resource "kubernetes_horizontal_pod_autoscaler" "elasticsearch" {
  metadata {
    name      = "elasticsearch"
    namespace = var.namespace
    labels = merge(local.merged_tags, {
      Name = "elasticsearch-hpa"
    })
  }
  
  spec {
    scale_target_ref {
      api_version = "apps/v1"
      kind        = "StatefulSet"
      name        = "elasticsearch-master"
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

# Pod Disruption Budget for Elasticsearch
resource "kubernetes_pod_disruption_budget" "elasticsearch" {
  metadata {
    name      = "elasticsearch"
    namespace = var.namespace
    labels = merge(local.merged_tags, {
      Name = "elasticsearch-pdb"
    })
  }
  
  spec {
    selector {
      match_labels = {
        "app.kubernetes.io/name" = "elasticsearch"
      }
    }
    
    min_available = 2
  }
}

# Outputs
output "elasticsearch_service" {
  description = "Elasticsearch service name"
  value       = "elasticsearch-master"
}

output "kibana_service" {
  description = "Kibana service name"
  value       = "kibana"
}

output "logstash_service" {
  description = "Logstash service name"
  value       = "logstash"
}

output "elasticsearch_url" {
  description = "Elasticsearch URL"
  value       = "http://elasticsearch-master.${var.namespace}.svc.cluster.local:9200"
}

output "kibana_url" {
  description = "Kibana URL"
  value       = "http://kibana.${var.namespace}.svc.cluster.local:5601"
}

output "logstash_url" {
  description = "Logstash URL"
  value       = "http://logstash.${var.namespace}.svc.cluster.local:8080"
}

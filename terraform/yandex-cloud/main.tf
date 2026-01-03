# Terraform Module for Yandex Cloud Infrastructure
# Provides comprehensive infrastructure setup for Space Invaders game on Yandex Cloud

terraform {
  required_version = ">= 1.0"
  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
      version = "~> 0.100"
    }
  }
}

# Provider configuration
provider "yandex" {
  zone      = var.zone
  folder_id = var.folder_id
  token     = var.token
}

# Variables
variable "token" {
  description = "Yandex Cloud OAuth token"
  type        = string
  sensitive   = true
}

variable "folder_id" {
  description = "Yandex Cloud folder ID"
  type        = string
}

variable "zone" {
  description = "Yandex Cloud zone"
  type        = string
  default     = "ru-central1-a"
}

variable "environment" {
  description = "Environment (dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "subnet_cidrs" {
  description = "CIDR blocks for subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}

variable "instance_count" {
  description = "Number of VM instances"
  type        = number
  default     = 2
}

variable "instance_platform_id" {
  description = "Instance platform ID"
  type        = string
  default     = "standard-v2"
}

variable "instance_cores" {
  description = "Number of CPU cores"
  type        = number
  default     = 2
}

variable "instance_memory" {
  description = "Memory in GB"
  type        = number
  default     = 4
}

variable "instance_disk_size" {
  description = "Disk size in GB"
  type        = number
  default     = 50
}

variable "instance_image_id" {
  description = "Instance image ID"
  type        = string
  default     = "fd827v91f99h0hv8dgc1"
}

variable "ssh_public_key" {
  description = "SSH public key"
  type        = string
  sensitive   = true
}

variable "service_account_id" {
  description = "Service account ID"
  type        = string
}

# Local values
locals {
  name_prefix = "${var.environment}-space-invaders"
  tags = {
    Environment = var.environment
    Project     = "space-invaders"
    ManagedBy   = "terraform"
  }
}

# Service Account
resource "yandex_iam_service_account" "main" {
  name        = "${local.name_prefix}-sa"
  description = "Service account for Space Invaders"
  
  folder_id = var.folder_id
}

# Service Account Roles
resource "yandex_resourcemanager_folder_iam_member" "editor" {
  folder_id = var.folder_id
  role      = "editor"
  member    = "serviceAccount:${yandex_iam_service_account.main.id}"
}

resource "yandex_resourcemanager_folder_iam_member" "vpc_admin" {
  folder_id = var.folder_id
  role      = "vpc.admin"
  member    = "serviceAccount:${yandex_iam_service_account.main.id}"
}

# Static Access Key
resource "yandex_iam_service_account_static_access_key" "main" {
  service_account_id = yandex_iam_service_account.main.id
  description        = "Static access key for Space Invaders"
}

# VPC
resource "yandex_vpc_network" "main" {
  name = "${local.name_prefix}-vpc"
  
  labels = merge(local.tags, {
    Name = "${local.name_prefix}-vpc"
  })
}

# Subnets
resource "yandex_vpc_subnet" "main" {
  count = length(var.subnet_cidrs)
  
  name          = "${local.name_prefix}-subnet-${count.index}"
  description   = "Subnet ${count.index} for Space Invaders"
  vpc_id        = yandex_vpc_network.main.id
  zone          = var.zone
  cidr          = var.subnet_cidrs[count.index]
  
  labels = merge(local.tags, {
    Name = "${local.name_prefix}-subnet-${count.index}"
  })
}

# Security Group
resource "yandex_vpc_security_group" "main" {
  name        = "${local.name_prefix}-sg"
  description = "Security group for Space Invaders"
  network_id  = yandex_vpc_network.main.id
  
  labels = merge(local.tags, {
    Name = "${local.name_prefix}-sg"
  })
  
  egress {
    protocol       = "ANY"
    description    = "Allow all outbound traffic"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 0
  }
  
  ingress {
    protocol       = "TCP"
    description    = "Allow HTTP inbound"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 80
  }
  
  ingress {
    protocol       = "TCP"
    description    = "Allow HTTPS inbound"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 443
  }
  
  ingress {
    protocol       = "TCP"
    description    = "Allow SSH inbound"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 22
  }
}

# Instance Group
resource "yandex_compute_instance_group" "main" {
  name                = "${local.name_prefix}-ig"
  description         = "Instance group for Space Invaders"
  folder_id           = var.folder_id
  service_account_id  = yandex_iam_service_account.main.id
  deletion_protection = false
  
  instance_template {
    platform_id = var.instance_platform_id
    resources {
      cores  = var.instance_cores
      memory = var.instance_memory
    }
    
    boot_disk {
      mode = "READ_WRITE"
      initialize_params {
        size     = var.instance_disk_size
        type     = "network-nvme"
        image_id = var.instance_image_id
      }
    }
    
    network_interface {
      subnet_ids = [yandex_vpc_subnet.main[0].id]
      security_group_ids = [yandex_vpc_security_group.main.id]
      nat       = true
    }
    
    metadata = {
      ssh-keys = "ubuntu:${var.ssh_public_key}"
      user-data = templatefile("${path.module}/user-data.sh", {
        environment = var.environment
      })
    }
    
    labels = merge(local.tags, {
      Name = "${local.name_prefix}-instance"
    })
  }
  
  scale_policy {
    fixed_scale {
      size = var.instance_count
    }
  }
  
  deploy_policy {
    max_unavailable = 1
    max_expansion   = 0
    max_creating   = 0
    max_deleting   = 0
    max_creating   = 0
  }
  
  allocation_policy {
    zones = [var.zone]
  }
  
  labels = merge(local.tags, {
    Name = "${local.name_prefix}-ig"
  })
}

# Load Balancer
resource "yandex_lb_network_load_balancer" "main" {
  name = "${local.name_prefix}-nlb"
  
  listener {
    name = "${local.name_prefix}-listener"
    port = 80
    protocol = "tcp"
    external_address_spec {
      ip_version = "ipv4"
    }
  }
  
  attached_target_group {
    target_group_id = yandex_lb_target_group.main.id
    healthcheck {
      name = "${local.name_prefix}-healthcheck"
      http_options {
        port = 8080
        path = "/health"
      }
      healthy_threshold = 2
      unhealthy_threshold = 2
      timeout = 3
      interval = 5
    }
  }
}

# Target Group
resource "yandex_lb_target_group" "main" {
  name = "${local.name_prefix}-tg"
  
  target {
    subnet_id = yandex_vpc_subnet.main[0].id
    ip_address = yandex_compute_instance_group.main.instances[0].network_interface[0].primary_v4_address.address
  }
}

# Managed PostgreSQL
resource "yandex_mdb_postgresql_cluster" "main" {
  name        = "${local.name_prefix}-pg"
  description = "PostgreSQL cluster for Space Invaders"
  environment = var.environment == "prod" ? "PRODUCTION" : "PRESTABLE"
  network_id  = yandex_vpc_network.main.id
  
  config {
    version = "15"
    resources {
      resource_preset_id = "s2.micro"
      disk_size          = 10
      disk_type          = "network-nvme"
    }
    
    postgresql_config = {
      max_connections = 100
      shared_buffers  = "256MB"
      effective_cache_size = "1GB"
    }
  }
  
  database {
    name  = "spaceinvaders"
    owner = "spaceinvaders"
  }
  
  user {
    name     = "spaceinvaders"
    password = var.postgres_password
    permissions = ["ALL_PRIVILEGES"]
  }
  
  host {
    zone      = var.zone
    subnet_id = yandex_vpc_subnet.main[0].id
  }
  
  labels = merge(local.tags, {
    Name = "${local.name_prefix}-pg"
  })
}

# Managed Redis
resource "yandex_mdb_redis_cluster" "main" {
  name        = "${local.name_prefix}-redis"
  description = "Redis cluster for Space Invaders"
  environment = var.environment == "prod" ? "PRODUCTION" : "PRESTABLE"
  network_id  = yandex_vpc_network.main.id
  
  config {
    version = "7.0"
    resources {
      resource_preset_id = "hm3-c2-m8"
      disk_size          = 16
      disk_type          = "network-nvme"
    }
    
    redis_config = {
      maxmemory_policy = "allkeys-lru"
      timeout          = 300
    }
  }
  
  host {
    zone      = var.zone
    subnet_id = yandex_vpc_subnet.main[0].id
  }
  
  labels = merge(local.tags, {
    Name = "${local.name_prefix}-redis"
  })
}

# Object Storage Bucket
resource "yandex_storage_bucket" "main" {
  name        = "${local.name_prefix}-storage"
  access_key  = yandex_iam_service_account_static_access_key.main.access_key
  secret_key  = yandex_iam_service_account_static_access_key.main.secret_key
  
  default_storage_class = "Standard"
  
  tags = merge(local.tags, {
    Name = "${local.name_prefix}-storage"
  })
}

# Service Account for Object Storage
resource "yandex_iam_service_account_iam_binding" "storage_editor" {
  service_account_id = yandex_iam_service_account.main.id
  role               = "storage.editor"
}

# Cloud Functions
resource "yandex_function" "main" {
  name        = "${local.name_prefix}-function"
  description = "Cloud function for Space Invaders"
  runtime_id  = "python37"
  entrypoint  = "index.handler"
  memory      = 128
  execution_timeout = 60
  
  content {
    zip_filename = "${path.module}/function.zip"
  }
  
  service_account_id = yandex_iam_service_account.main.id
  
  labels = merge(local.tags, {
    Name = "${local.name_prefix}-function"
  })
}

# API Gateway
resource "yandex_api_gateway" "main" {
  name        = "${local.name_prefix}-gateway"
  description = "API Gateway for Space Invaders"
  
  spec = templatefile("${path.module}/gateway-spec.yaml", {
    function_id = yandex_function.main.id
  })
  
  labels = merge(local.tags, {
    Name = "${local.name_prefix}-gateway"
  })
}

# Container Registry
resource "yandex_container_registry" "main" {
  name = "${local.name_prefix}-cr"
  
  labels = merge(local.tags, {
    Name = "${local.name_prefix}-cr"
  })
}

# IAM Policy for Container Registry
resource "yandex_container_registry_iam_binding" "main" {
  registry_id = yandex_container_registry.main.id
  role        = "container-registry.images.puller"
  member      = "serviceAccount:${yandex_iam_service_account.main.id}"
}

# Monitoring Dashboard
resource "yandex_monitoring_dashboard" "main" {
  name        = "${local.name_prefix}-dashboard"
  description = "Monitoring dashboard for Space Invaders"
  folder_id   = var.folder_id
  
  dashboard = templatefile("${path.module}/dashboard.json", {
    environment = var.environment
  })
  
  labels = merge(local.tags, {
    Name = "${local.name_prefix}-dashboard"
  })
}

# Alert Channels
resource "yandex_monitoring_alert_channel" "email" {
  name = "${local.name_prefix}-email-alerts"
  
  email_channel {
    email_addresses = var.alert_emails
  }
  
  labels = merge(local.tags, {
    Name = "${local.name_prefix}-email-alerts"
  })
}

# Alert Templates
resource "yandex_monitoring_alert_template" "main" {
  name = "${local.name_prefix}-alerts"
  
  alert {
    name = "High CPU Usage"
    description = "CPU usage is above threshold"
    condition {
      metric_name = "cpu_util"
      operator     = "GT"
      threshold    = 80
    }
    notification_channels = [yandex_monitoring_alert_channel.email.id]
  }
  
  alert {
    name = "High Memory Usage"
    description = "Memory usage is above threshold"
    condition {
      metric_name = "mem_util"
      operator     = "GT"
      threshold    = 85
    }
    notification_channels = [yandex_monitoring_alert_channel.email.id]
  }
  
  labels = merge(local.tags, {
    Name = "${local.name_prefix}-alerts"
  })
}

# Data Sources
data "yandex_compute_image" "ubuntu" {
  family = "ubuntu-2204-lts"
}

# Outputs
output "vpc_id" {
  description = "VPC ID"
  value       = yandex_vpc_network.main.id
}

output "subnet_ids" {
  description = "Subnet IDs"
  value       = yandex_vpc_subnet.main[*].id
}

output "security_group_id" {
  description = "Security group ID"
  value       = yandex_vpc_security_group.main.id
}

output "instance_group_id" {
  description = "Instance group ID"
  value       = yandex_compute_instance_group.main.id
}

output "instance_group_instances" {
  description = "Instance group instances"
  value       = yandex_compute_instance_group.main.instances
}

output "load_balancer_id" {
  description = "Load balancer ID"
  value       = yandex_lb_network_load_balancer.main.id
}

output "load_balancer_public_ip" {
  description = "Load balancer public IP"
  value       = yandex_lb_network_load_balancer.main.listener[0].external_address_spec[0].address
}

output "postgresql_cluster_id" {
  description = "PostgreSQL cluster ID"
  value       = yandex_mdb_postgresql_cluster.main.id
}

output "redis_cluster_id" {
  description = "Redis cluster ID"
  value       = yandex_mdb_redis_cluster.main.id
}

output "storage_bucket_name" {
  description = "Object storage bucket name"
  value       = yandex_storage_bucket.main.name
}

output "container_registry_id" {
  description = "Container registry ID"
  value       = yandex_container_registry.main.id
}

output "service_account_id" {
  description = "Service account ID"
  value       = yandex_iam_service_account.main.id
}

output "access_key_id" {
  description = "Static access key ID"
  value       = yandex_iam_service_account_static_access_key.main.id
  sensitive   = true
}

output "access_key_secret" {
  description = "Static access key secret"
  value       = yandex_iam_service_account_static_access_key.main.secret_key
  sensitive   = true
}

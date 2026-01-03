# Terraform Configuration for Space Invaders Infrastructure

provider "yandex" {
  token     = var.yandex_cloud_token
  cloud_id  = var.yandex_cloud_id
  folder_id  = var.yandex_folder_id
  zone      = "ru-central1-a"
}

# Variables
variable "yandex_cloud_token" {
  description = "Yandex Cloud API token"
  type        = string
  sensitive   = true
}

variable "yandex_cloud_id" {
  description = "Yandex Cloud ID"
  type        = string
}

variable "yandex_folder_id" {
  description = "Yandex Cloud Folder ID"
  type        = string
}

variable "domain_name" {
  description = "Domain name for the application"
  type        = string
  default     = "space-invaders.com"
}

# Network
resource "yandex_vpc_network" "space_invaders_network" {
  name = "space-invaders-network"
}

resource "yandex_vpc_subnet" "space_invaders_subnet" {
  name           = "space-invaders-subnet"
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.space_invaders_network.id
  v4_cidr_blocks = ["10.0.1.0/24"]
}

# Storage Bucket
resource "yandex_storage_bucket" "space_invaders_bucket" {
  bucket = "space-invaders-static"
  access_key = var.yandex_storage_access_key
  secret_key = var.yandex_storage_secret_key
  
  website {
    index_document = "index.html"
    error_document = "index.html"
  }
  
  acl = "public-read"
}

# CDN
resource "yandex_cdn_origin_group" "space_invaders_origin" {
  name = "space-invaders-origin"
  
  origin {
    source = yandex_storage_bucket.space_invaders_bucket.bucket_domain_name
    origin_group = "primary"
  }
}

resource "yandex_cdn_resource" "space_invaders_cdn" {
  name = "space-invaders-cdn"
  origin_group_id = yandex_cdn_origin_group.space_invaders_origin.id
  
  active = true
  
  options {
    cache_control = "public, max-age=31536000"
    custom_headers = {
      "X-Frame-Options" = "SAMEORIGIN"
      "X-Content-Type-Options" = "nosniff"
      "X-XSS-Protection" = "1; mode=block"
    }
  }
}

# Container Registry
resource "yandex_container_registry" "space_invaders_registry" {
  name = "space-invaders-registry"
}

# Container Repository
resource "yandex_container_repository" "space_invaders_repo" {
  name = "space-invaders"
  registry_id = yandex_container_registry.space_invaders_registry.id
}

# Serverless Function
resource "yandex_function" "space_invaders_function" {
  name        = "space-invaders-function"
  description = "Space Invaders serverless function"
  runtime     = "nodejs16"
  entrypoint  = "index.handler"
  memory      = "512"
  execution_timeout = "10"
  
  content {
    zip_filename = "function.zip"
  }
}

# API Gateway
resource "yandex_api_gateway" "space_invaders_gateway" {
  name        = "space-invaders-gateway"
  description = "Space Invaders API gateway"
  
  spec = <<-EOT
    openapi: 3.0.0
    info:
      title: Space Invaders API
      version: 1.0.0
    paths:
      /api/health:
        get:
          x-yc-apigateway-integration:
            type: cloud_function
            function_id: ${yandex_function.space_invaders_function.id}
  EOT
}

# DNS Records
resource "yandex_dns_recordset" "space_invaders_a" {
  zone_id = var.dns_zone_id
  name    = "@"
  type    = "A"
  data    = [yandex_cdn_resource.space_invaders_cdn.domain]
}

resource "yandex_dns_recordset" "space_invaders_www" {
  zone_id = var.dns_zone_id
  name    = "www"
  type    = "CNAME"
  data    = [yandex_cdn_resource.space_invaders_cdn.domain]
}

# IAM Service Account
resource "yandex_iam_service_account" "space_invaders_sa" {
  name        = "space-invaders-sa"
  description = "Service account for Space Invaders"
}

resource "yandex_resourcemanager_folder_iam_member" "space_invaders_sa_roles" {
  folder_id  = var.yandex_folder_id
  member     = "serviceAccount:${yandex_iam_service_account.space_invaders_sa.id}"
  role       = "editor"
}

# Static Key for Service Account
resource "yandex_iam_service_account_static_key" "space_invaders_sa_key" {
  service_account_id = yandex_iam_service_account.space_invaders_sa.id
  description        = "Static key for Space Invaders service account"
}

# Output
output "bucket_domain_name" {
  value = yandex_storage_bucket.space_invaders_bucket.bucket_domain_name
}

output "cdn_domain" {
  value = yandex_cdn_resource.space_invaders_cdn.domain
}

output "api_gateway_url" {
  value = yandex_api_gateway.space_invaders_gateway.domain
}

output "service_account_key_id" {
  value = yandex_iam_service_account_static_key.space_invaders_sa_key.id
  sensitive = true
}

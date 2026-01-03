# Terraform Module for SberCloud Infrastructure
# Provides comprehensive infrastructure setup for Space Invaders game on SberCloud

terraform {
  required_version = ">= 1.0"
  required_providers {
    sbercloud = {
      source  = "sbercloud/sbercloud"
      version = "~> 1.0"
    }
  }
}

# Provider configuration
provider "sbercloud" {
  region     = var.region
  access_key = var.access_key
  secret_key = var.secret_key
  project_id = var.project_id
}

# Variables
variable "region" {
  description = "SberCloud region"
  type        = string
  default     = "ru-central1"
}

variable "access_key" {
  description = "SberCloud access key"
  type        = string
  sensitive   = true
}

variable "secret_key" {
  description = "SberCloud secret key"
  type        = string
  sensitive   = true
}

variable "project_id" {
  description = "SberCloud project ID"
  type        = string
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
  description = "Number of ECS instances"
  type        = number
  default     = 2
}

variable "instance_flavor" {
  description = "ECS instance flavor"
  type        = string
  default     = "s6.large.2"
}

variable "instance_image" {
  description = "ECS instance image"
  type        = string
  default     = "Ubuntu 20.04 server 64bit"
}

variable "instance_volume_size" {
  description = "ECS instance volume size in GB"
  type        = number
  default     = 50
}

variable "load_balancer_type" {
  description = "Load balancer type"
  type        = string
  default     = "application"
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

# VPC
resource "sbercloud_vpc_v1" "main" {
  name = "${local.name_prefix}-vpc"
  cidr = var.vpc_cidr
  
  tags = merge(local.tags, {
    Name = "${local.name_prefix}-vpc"
  })
}

# Subnets
resource "sbercloud_vpc_subnet_v1" "main" {
  count = length(var.subnet_cidrs)
  
  vpc_id      = sbercloud_vpc_v1.main.id
  name        = "${local.name_prefix}-subnet-${count.index}"
  cidr        = var.subnet_cidrs[count.index]
  gateway_ip  = cidrhost(var.subnet_cidrs[count.index], 1)
  
  tags = merge(local.tags, {
    Name = "${local.name_prefix}-subnet-${count.index}"
  })
}

# Internet Gateway
resource "sbercloud_vpc_eip_v1" "nat" {
  count = 1
  
  publicip {
    type = "5_bgp"
  }
  
  bandwidth {
    name        = "${local.name_prefix}-nat-bandwidth"
    size        = 100
    share_type  = "PER"
    charge_mode = "traffic"
  }
  
  tags = merge(local.tags, {
    Name = "${local.name_prefix}-nat-eip"
  })
}

# NAT Gateway
resource "sbercloud_nat_gateway_v2" "main" {
  name = "${local.name_prefix}-nat"
  
  spec {
    vpc_id    = sbercloud_vpc_v1.main.id
    subnet_id = sbercloud_vpc_subnet_v1.main[0].id
  }
  
  tags = merge(local.tags, {
    Name = "${local.name_prefix}-nat"
  })
}

# NAT Gateway SNAT Rule
resource "sbercloud_nat_snat_rule_v2" "main" {
  nat_gateway_id = sbercloud_nat_gateway_v2.main.id
  
  floating_ip_id = sbercloud_vpc_eip_v1.nat[0].id
  
  spec {
    rule_type   = "SNAT"
    private_ip   = cidrhost(var.subnet_cidrs[0], 1)
  }
}

# Security Group
resource "sbercloud_networking_secgroup_v2" "main" {
  name        = "${local.name_prefix}-sg"
  description = "Security group for Space Invaders"
  
  tags = merge(local.tags, {
    Name = "${local.name_prefix}-sg"
  })
}

# Security Group Rules - HTTP
resource "sbercloud_networking_secgroup_rule_v2" "http_ingress" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 80
  port_range_max    = 80
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = sbercloud_networking_secgroup_v2.main.id
  
  description = "HTTP inbound"
}

# Security Group Rules - HTTPS
resource "sbercloud_networking_secgroup_rule_v2" "https_ingress" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 443
  port_range_max    = 443
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = sbercloud_networking_secgroup_v2.main.id
  
  description = "HTTPS inbound"
}

# Security Group Rules - SSH
resource "sbercloud_networking_secgroup_rule_v2" "ssh_ingress" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 22
  port_range_max    = 22
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = sbercloud_networking_secgroup_v2.main.id
  
  description = "SSH inbound"
}

# Security Group Rules - Egress
resource "sbercloud_networking_secgroup_rule_v2" "egress" {
  direction         = "egress"
  ethertype         = "IPv4"
  protocol          = "any"
  port_range_min    = 0
  port_range_max    = 0
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = sbercloud_networking_secgroup_v2.main.id
  
  description = "All outbound"
}

# Key Pair
resource "sbercloud_compute_keypair_v2" "main" {
  name       = "${local.name_prefix}-keypair"
  public_key = var.public_key
  
  tags = merge(local.tags, {
    Name = "${local.name_prefix}-keypair"
  })
}

# ECS Instances
resource "sbercloud_compute_instance_v2" "main" {
  count = var.instance_count
  
  name              = "${local.name_prefix}-instance-${count.index}"
  image_id          = data.sbercloud_images_image_v2.ubuntu.id
  flavor_id         = data.sbercloud_compute_flavor_v2.main.id
  availability_zone = data.sbercloud_availability_zones_v1.main.names[count.index % length(data.sbercloud_availability_zones_v1.main.names)]
  
  network {
    uuid = sbercloud_vpc_subnet_v1.main[count.index % length(sbercloud_vpc_subnet_v1.main)].id
  }
  
  security_group_ids = [sbercloud_networking_secgroup_v2.main.id]
  
  key_pair = sbercloud_compute_keypair_v2.main.name
  
  tags = merge(local.tags, {
    Name = "${local.name_prefix}-instance-${count.index}"
  })
}

# Root Volume for ECS Instances
resource "sbercloud_compute_volume_v2" "root" {
  count = var.instance_count
  
  name              = "${local.name_prefix}-root-volume-${count.index}"
  size              = var.instance_volume_size
  volume_type       = "SSD"
  availability_zone = data.sbercloud_availability_zones_v1.main.names[count.index % length(data.sbercloud_availability_zones_v1.main.names)]
  
  tags = merge(local.tags, {
    Name = "${local.name_prefix}-root-volume-${count.index}"
  })
}

# Attach root volume to instances
resource "sbercloud_compute_volume_attach_v2" "root" {
  count = var.instance_count
  
  instance_id = sbercloud_compute_instance_v2.main[count.index].id
  volume_id   = sbercloud_compute_volume_v2.root[count.index].id
  device      = "/dev/vda"
}

# Application Load Balancer
resource "sbercloud_lb_loadbalancer_v2" "main" {
  name        = "${local.name_prefix}-alb"
  description = "Application Load Balancer for Space Invaders"
  
  vip_subnet_id = sbercloud_vpc_subnet_v1.main[0].id
  
  tags = merge(local.tags, {
    Name = "${local.name_prefix}-alb"
  })
}

# Load Balancer Listener
resource "sbercloud_lb_listener_v2" "main" {
  name            = "${local.name_prefix}-listener"
  description     = "HTTP listener for Space Invaders"
  protocol        = "HTTP"
  protocol_port   = 80
  loadbalancer_id = sbercloud_lb_loadbalancer_v2.main.id
  
  default_pool {
    id = sbercloud_lb_pool_v2.main.id
  }
  
  tags = merge(local.tags, {
    Name = "${local.name_prefix}-listener"
  })
}

# Load Balancer Pool
resource "sbercloud_lb_pool_v2" "main" {
  name        = "${local.name_prefix}-pool"
  description = "Backend pool for Space Invaders"
  protocol    = "HTTP"
  lb_method   = "ROUND_ROBIN"
  
  loadbalancer_id = sbercloud_lb_loadbalancer_v2.main.id
  
  tags = merge(local.tags, {
    Name = "${local.name_prefix}-pool"
  })
}

# Load Balancer Pool Members
resource "sbercloud_lb_member_v2" "main" {
  count = var.instance_count
  
  address = sbercloud_compute_instance_v2.main[count.index].access_ip_v4
  protocol_port = 8080
  pool_id      = sbercloud_lb_pool_v2.main.id
  
  subnet_id = sbercloud_vpc_subnet_v1.main[count.index % length(sbercloud_vpc_subnet_v1.main)].id
  
  tags = merge(local.tags, {
    Name = "${local.name_prefix}-member-${count.index}"
  })
}

# Health Check
resource "sbercloud_lb_healthcheck_v2" "main" {
  pool_id     = sbercloud_lb_pool_v2.main.id
  protocol    = "HTTP"
  url_path    = "/health"
  delay       = 5
  timeout     = 10
  max_retries = 3
  
  tags = merge(local.tags, {
    Name = "${local.name_prefix}-healthcheck"
  })
}

# Auto Scaling Group
resource "sbercloud_as_group_v1" "main" {
  name = "${local.name_prefix}-asg"
  
  scaling_group_name = "${local.name_prefix}-asg"
  scaling_configuration {
    instance_config {
      flavor          = data.sbercloud_compute_flavor_v2.main.id
      image           = data.sbercloud_images_image_v2.ubuntu.id
      key_pair        = sbercloud_compute_keypair_v2.main.name
      system_disk_type = "SSD"
      system_disk_size = 50
      
      network {
        uuid = sbercloud_vpc_subnet_v1.main[0].id
      }
      
      security_group_ids = [sbercloud_networking_secgroup_v2.main.id]
    }
    
    desire_instance_number = var.instance_count
    min_instance_number    = 1
    max_instance_number    = 10
    cool_down_time         = 300
  }
  
  tags = merge(local.tags, {
    Name = "${local.name_prefix}-asg"
  })
}

# Auto Scaling Policy
resource "sbercloud_as_policy_v1" "scale_up" {
  name = "${local.name_prefix}-scale-up"
  
  scaling_group_id = sbercloud_as_group_v1.main.id
  scaling_policy_name = "${local.name_prefix}-scale-up"
  scaling_policy_type = "ALARM"
  scaling_policy_action {
    operation = "ADD"
    instance_number = 1
  }
  
  alarm_trigger {
    metric_name = "cpu_util"
    metric_value = 80
    condition_operator = ">"
    period = 300
    evaluation_periods = 2
    statistic = "average"
  }
}

resource "sbercloud_as_policy_v1" "scale_down" {
  name = "${local.name_prefix}-scale-down"
  
  scaling_group_id = sbercloud_as_group_v1.main.id
  scaling_policy_name = "${local.name_prefix}-scale-down"
  scaling_policy_type = "ALARM"
  scaling_policy_action {
    operation = "REMOVE"
    instance_number = 1
  }
  
  alarm_trigger {
    metric_name = "cpu_util"
    metric_value = 20
    condition_operator = "<"
    period = 300
    evaluation_periods = 3
    statistic = "average"
  }
}

# Cloud Eye Alarm
resource "sbercloud_ces_alarmrule_v1" "cpu_high" {
  name = "${local.name_prefix}-cpu-high"
  
  alarm_actions {
    type = "notification"
    notification_list = [var.notification_list_id]
  }
  
  alarm_description = "CPU utilization is high"
  metric_name = "cpu_util"
  metric_unit = "%"
  period = 300
  evaluation_periods = 2
  threshold = 80
  comparison_operator = ">"
  statistic = "average"
  
  tags = merge(local.tags, {
    Name = "${local.name_prefix}-cpu-high"
  })
}

# Cloud Eye Alarm
resource "sbercloud_ces_alarmrule_v1" "memory_high" {
  name = "${local.name_prefix}-memory-high"
  
  alarm_actions {
    type = "notification"
    notification_list = [var.notification_list_id]
  }
  
  alarm_description = "Memory utilization is high"
  metric_name = "mem_util"
  metric_unit = "%"
  period = 300
  evaluation_periods = 2
  threshold = 85
  comparison_operator = ">"
  statistic = "average"
  
  tags = merge(local.tags, {
    Name = "${local.name_prefix}-memory-high"
  })
}

# Data Sources
data "sbercloud_availability_zones_v1" "main" {}

data "sbercloud_compute_flavor_v2" "main" {
  flavor_name = var.instance_flavor
}

data "sbercloud_images_image_v2" "ubuntu" {
  name        = var.instance_image
  most_recent = true
}

# Outputs
output "vpc_id" {
  description = "VPC ID"
  value       = sbercloud_vpc_v1.main.id
}

output "subnet_ids" {
  description = "Subnet IDs"
  value       = sbercloud_vpc_subnet_v1.main[*].id
}

output "security_group_id" {
  description = "Security group ID"
  value       = sbercloud_networking_secgroup_v2.main.id
}

output "instance_ids" {
  description = "ECS instance IDs"
  value       = sbercloud_compute_instance_v2.main[*].id
}

output "instance_public_ips" {
  description = "ECS instance public IPs"
  value       = sbercloud_compute_instance_v2.main[*].access_ip_v4
}

output "load_balancer_id" {
  description = "Load balancer ID"
  value       = sbercloud_lb_loadbalancer_v2.main.id
}

output "load_balancer_public_ip" {
  description = "Load balancer public IP"
  value       = sbercloud_lb_loadbalancer_v2.main.public_ip
}

output "auto_scaling_group_id" {
  description = "Auto scaling group ID"
  value       = sbercloud_as_group_v1.main.id
}

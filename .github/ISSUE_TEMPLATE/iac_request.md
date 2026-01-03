---
name: 🚀 Infrastructure as Code (IaC) Request
about: Request for Infrastructure as Code changes, updates, or new resources
title: "[IaC] "
labels: ["infrastructure", "iac", "terraform", "devops"]
assignees: ["devops-team"]
projects: ["space-invaders/1"]

---

## 🏗️ Infrastructure as Code Request

### 📋 Request Type
- [ ] **New Infrastructure** - Create new infrastructure resources
- [ ] **Update Infrastructure** - Modify existing infrastructure
- [ ] **Delete Infrastructure** - Remove infrastructure resources
- [ ] **Migration** - Move infrastructure between environments/providers
- [ ] **Optimization** - Optimize existing infrastructure for cost/performance
- [ ] **Security Hardening** - Enhance infrastructure security
- [ ] **Compliance** - Ensure infrastructure meets compliance requirements

### 🌍 Environment Details
- **Target Environment**: 
  - [ ] Development
  - [ ] Staging
  - [ ] Production
  - [ ] Testing
  - [ ] Other: ___________

- **Cloud Provider**:
  - [ ] AWS
  - [ ] Azure
  - [ ] Google Cloud
  - [ ] SberCloud
  - [ ] Yandex Cloud
  - [ ] VK Cloud
  - [ ] Selectel
  - [ ] On-premises
  - [ ] Other: ___________

### 📦 Infrastructure Components

#### Compute Resources
- [ ] **Virtual Machines**
  - **Type**: [ ] EC2 [ ] VM [ ] Compute Engine [ ] ECS [ ] Other: _________
  - **Instance Type**: ____________________
  - **Count**: _________
  - **Configuration**: ____________________
  
- [ ] **Containers**
  - **Type**: [ ] Docker [ ] Kubernetes [ ] OpenShift [ ] Other: _________
  - **Orchestration**: ____________________
  - **Scaling Requirements**: ____________________

- [ ] **Serverless**
  - **Type**: [ ] Lambda [ ] Cloud Functions [ ] Other: _________
  - **Triggers**: ____________________

#### Storage Resources
- [ ] **Block Storage**
  - **Type**: [ ] EBS [ ] Disk [ ] Persistent Disk [ ] Other: _________
  - **Size**: _________ GB
  - **Performance**: ____________________

- [ ] **Object Storage**
  - **Type**: [ ] S3 [ ] Blob Storage [ ] Cloud Storage [ ] Other: _________
  - **Size**: _________ GB
  - **Access Pattern**: ____________________

- [ ] **Database Storage**
  - **Type**: [ ] RDS [ ] SQL Database [ ] Cloud SQL [ ] Other: _________
  - **Engine**: [ ] PostgreSQL [ ] MySQL [ ] MongoDB [ ] Other: _________
  - **Size**: _________ GB

#### Network Resources
- [ ] **VPC/VNet**
  - **CIDR Block**: ____________________
  - **Subnets**: ____________________
  - **Routing**: ____________________

- [ ] **Load Balancer**
  - **Type**: [ ] Application [ ] Network [ ] Classic [ ] Other: _________
  - **Algorithm**: ____________________
  - **Health Checks**: ____________________

- [ ] **CDN**
  - **Provider**: ____________________
  - **Cache Rules**: ____________________
  - **Geographic Distribution**: ____________________

#### Security Resources
- [ ] **Security Groups/NSG**
  - **Rules**: ____________________
  - **Source/Destination**: ____________________

- [ ] **IAM Roles/Policies**
  - **Permissions**: ____________________
  - **Principals**: ____________________

- [ ] **Certificates**
  - **Type**: [ ] SSL/TLS [ ] Other: _________
  - **Domains**: ____________________

### 🔧 Technical Requirements

#### Infrastructure Configuration
- **Terraform Version**: ____________________
- **Provider Versions**: ____________________
- **Module Structure**: ____________________
- **State Management**: ____________________
- **Remote Backend**: [ ] S3 [ ] Azure Storage [ ] GCS [ ] Other: _________

#### Configuration Details
```hcl
# Example Terraform configuration
provider "aws" {
  region = var.aws_region
}

module "example" {
  source = "./modules/example"
  
  # Configuration parameters
  instance_type = var.instance_type
  instance_count = var.instance_count
}
```

#### Variables
```hcl
variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "instance_count" {
  description = "Number of instances"
  type        = number
  default     = 1
}
```

#### Outputs
```hcl
output "instance_ids" {
  description = "List of instance IDs"
  value       = aws_instance.example[*].id
}
```

### 🔒 Security and Compliance

#### Security Requirements
- [ ] **Encryption at Rest**
- [ ] **Encryption in Transit**
- [ ] **Network Security**
- [ ] **Access Control**
- [ ] **Audit Logging**
- [ ] **Vulnerability Scanning**

#### Compliance Requirements
- [ ] **GDPR**
- [ ] **SOC 2**
- [ ] **ISO 27001**
- [ ] **HIPAA**
- [ ] **PCI DSS**
- [ ] **Federal Law #152-FZ**
- [ ] **Federal Law #149-FZ**

#### Security Controls
```hcl
# Example security configuration
resource "aws_security_group" "example" {
  name        = "example-sg"
  description = "Example security group"
  
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
```

### 💰 Cost and Budget

#### Cost Estimation
- **Estimated Monthly Cost**: $_________
- **Cost Breakdown**:
  - Compute: $_________
  - Storage: $_________
  - Network: $_________
  - Other: $_________

#### Budget Constraints
- **Maximum Monthly Budget**: $_________
- **Cost Optimization Requirements**: ____________________
- **Billing Alerts**: [ ] Enabled [ ] Disabled

#### Resource Tagging
```hcl
# Example tagging strategy
tags = {
  Environment = var.environment
  Project     = "space-invaders"
  Owner       = var.owner
  CostCenter  = var.cost_center
  CreatedBy   = "terraform"
}
```

### 📊 Monitoring and Observability

#### Monitoring Requirements
- [ ] **Resource Monitoring**
- [ ] **Performance Monitoring**
- [ ] **Health Checks**
- [ ] **Alerting**
- [ ] **Log Aggregation**
- [ ] **Metrics Collection**

#### Monitoring Configuration
```hcl
# Example monitoring configuration
resource "aws_cloudwatch_metric_alarm" "example" {
  alarm_name          = "example-alarm"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "120"
  statistic           = "Average"
  threshold           = "80"
  alarm_description   = "This metric monitors ec2 cpu utilization"
}
```

### 🚀 Deployment Strategy

#### Deployment Plan
- **Deployment Method**: 
  - [ ] Terraform Apply
  - [ ] Terraform Import
  - [ ] Blue-Green Deployment
  - [ ] Canary Deployment
  - [ ] Rolling Update

#### Rollback Strategy
- **Rollback Plan**: ____________________
- **Rollback Triggers**: ____________________
- **Rollback Time**: _________ minutes

#### Testing Strategy
- [ ] **Unit Tests**
- [ ] **Integration Tests**
- [ ] **Security Tests**
- [ ] **Performance Tests**
- [ ] **Compliance Tests**

### 📝 Implementation Plan

#### Phases
1. **Phase 1**: ____________________
   - Duration: _________ days
   - Deliverables: ____________________

2. **Phase 2**: ____________________
   - Duration: _________ days
   - Deliverables: ____________________

3. **Phase 3**: ____________________
   - Duration: _________ days
   - Deliverables: ____________________

#### Dependencies
- **External Dependencies**: ____________________
- **Internal Dependencies**: ____________________
- **Blocking Issues**: ____________________

#### Risk Assessment
| Risk | Probability | Impact | Mitigation |
|------|-------------|--------|------------|
| Example Risk | [ ] Low [ ] Medium [ ] High | [ ] Low [ ] Medium [ ] High | ____________________ |

### ✅ Acceptance Criteria

#### Functional Requirements
- [ ] All infrastructure resources are created successfully
- [ ] Resources are accessible and functional
- [ ] Configuration matches requirements
- [ ] Security controls are implemented
- [ ] Monitoring is configured

#### Non-Functional Requirements
- [ ] Performance requirements are met
- [ ] Security requirements are met
- [ ] Compliance requirements are met
- [ ] Cost requirements are met
- [ ] Documentation is complete

#### Testing Criteria
- [ ] Terraform validate passes
- [ ] Terraform plan shows expected changes
- [ ] Terraform apply succeeds
- [ ] Health checks pass
- [ ] Security scans pass

### 📚 Additional Information

#### Context
- **Business Context**: ____________________
- **Technical Context**: ____________________
- **Timeline**: ____________________
- **Priority**: [ ] Low [ ] Medium [ ] High [ ] Critical

#### References
- **Documentation**: ____________________
- **Similar Implementations**: ____________________
- **Best Practices**: ____________________

#### Questions/Concerns
- **Open Questions**: ____________________
- **Concerns**: ____________________
- **Assumptions**: ____________________

---

## 🎯 Success Criteria

### Technical Success
- [ ] Infrastructure is provisioned correctly
- [ ] All resources are operational
- [ ] Security and compliance requirements are met
- [ ] Performance requirements are met
- [ ] Cost requirements are met

### Operational Success
- [ ] Monitoring and alerting are working
- [ ] Documentation is complete and accurate
- [ ] Team is trained on new infrastructure
- [ ] Backup and recovery procedures are tested
- [ ] Incident response procedures are updated

### Business Success
- [ ] Business requirements are met
- [ ] User experience is improved
- [ ] Operational efficiency is improved
- [ ] Cost optimization is achieved
- [ ] Compliance requirements are satisfied

---

## 📋 Checklist

### Pre-Implementation
- [ ] Requirements are clearly defined
- [ ] Design is reviewed and approved
- [ ] Security review is completed
- [ ] Cost estimate is approved
- [ ] Dependencies are identified and resolved

### Implementation
- [ ] Code is written and reviewed
- [ ] Tests are written and passing
- [ ] Documentation is updated
- [ ] Security scanning is completed
- [ ] Compliance checks are passed

### Post-Implementation
- [ ] Infrastructure is deployed successfully
- [ ] Monitoring is configured and working
- [ ] Documentation is published
- [ ] Team training is completed
- [ ] Post-implementation review is conducted

---

**🔔 Additional Notes**: ____________________

**📧 Contact Information**:
- **Requester**: ____________________
- **Technical Contact**: ____________________
- **Business Contact**: ____________________

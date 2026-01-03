---
name: Cloud Native Deployment Request
about: Request a cloud-native deployment or infrastructure change
title: "[Cloud-Native] "
labels: ["cloud-native", "deployment", "infrastructure"]
assignees: ["devops-team"]
---

# Cloud Native Deployment Request

## 📋 Request Information

**Request Type:**
- [ ] New Application Deployment
- [ ] Application Update
- [ ] Infrastructure Scaling
- [ ] Configuration Change
- [ ] Migration
- [ ] Rollback
- [ ] Emergency Deployment
- [ ] Other (please specify)

**Priority:**
- [ ] Critical (Production issue)
- [ ] High (Business impact)
- [ ] Medium (Feature deployment)
- [ ] Low (Maintenance/Improvement)

**Target Environment:**
- [ ] Development
- [ ] Staging
- [ ] Production
- [ ] Disaster Recovery
- [ ] Other (please specify)

## 🏗️ Application Details

**Application Name:**
<!-- Name of the application to be deployed -->

**Application Type:**
- [ ] Web Application
- [ ] API Service
- [ ] Microservice
- [ ] Background Worker
- [ ] Database
- [ ] Message Queue
- [ ] Monitoring Tool
- [ ] Other (please specify)

**Container Image:**
<!-- Docker image URL and tag -->

**Image Registry:**
- [ ] Docker Hub
- [ ] GitHub Container Registry
- [ ] GitLab Container Registry
- [ ] Private Registry
- [ ] Other (please specify)

**Deployment Method:**
- [ ] Helm Chart
- [ ] Kustomize
- [ ] Plain Kubernetes Manifests
- [ ] Operator-based
- [ ] Other (please specify)

## 🚀 Deployment Configuration

**Replica Count:**
<!-- Desired number of replicas -->

**Resource Requirements:**
- **CPU Request:** <!-- e.g., 250m -->
- **CPU Limit:** <!-- e.g., 500m -->
- **Memory Request:** <!-- e.g., 256Mi -->
- **Memory Limit:** <!-- e.g., 512Mi -->

**Auto-scaling Configuration:**
- [ ] Horizontal Pod Autoscaler (HPA)
- [ ] Vertical Pod Autoscaler (VPA)
- [ ] Cluster Autoscaler
- [ ] Custom Autoscaler
- [ ] No Autoscaling

**HPA Settings (if applicable):**
- **Min Replicas:** <!-- e.g., 2 -->
- **Max Replicas:** <!-- e.g., 10 -->
- **Target CPU Utilization:** <!-- e.g., 70% -->
- **Target Memory Utilization:** <!-- e.g., 80% -->
- **Custom Metrics:** <!-- e.g., requests_per_second -->

## 🔧 Configuration Details

**Environment Variables:**
<!-- List key environment variables (sensitive data should use secrets) -->

**ConfigMaps:**
<!-- List ConfigMaps to be created or updated -->

**Secrets:**
<!-- List secrets to be created or updated (do not include actual secret values) -->

**Persistent Storage:**
- [ ] PersistentVolumeClaim (PVC)
- [ ] StorageClass
- [ ] StatefulSet
- [ ] No persistent storage needed

**Storage Requirements (if applicable):**
- **Storage Size:** <!-- e.g., 10Gi -->
- **Storage Class:** <!-- e.g., standard, ssd, custom -->
- **Access Mode:** <!-- e.g., ReadWriteOnce, ReadOnlyMany -->

## 🌐 Networking Configuration

**Service Type:**
- [ ] ClusterIP
- [ ] NodePort
- [ ] LoadBalancer
- [ ] Headless Service
- [ ] ExternalName

**Ingress Configuration:**
- [ ] No Ingress needed
- [ ] HTTP/HTTPS Ingress
- [ ] TLS/SSL required
- [ ] Custom domain
- [ ] Load balancing
- [ ] Rate limiting
- [ ] Authentication

**Ingress Details (if applicable):**
- **Host/Domain:** <!-- e.g., app.space-invaders.local -->
- **Path:** <!-- e.g., /api -->
- **TLS Certificate:** <!-- e.g., letsencrypt-prod, custom-cert -->
- **Annotations:** <!-- e.g., nginx.ingress.kubernetes.io/rate-limit: "100" -->

**Network Policies:**
- [ ] Default deny all
- [ ] Allow specific namespaces
- [ ] Allow specific labels
- [ ] No network policies

## 🔒 Security Configuration

**Security Context:**
- [ ] Run as non-root user
- [ ] Read-only root filesystem
- [ ] Drop all capabilities
- [ ] SecurityContext constraints
- [ ] Pod Security Policy

**Image Security:**
- [ ] Image scanning required
- [ ] Signed images only
- [ ] Private registry only
- [ ] Image pull secrets

**RBAC Configuration:**
- [ ] ServiceAccount required
- [ ] Role needed
- [ ] ClusterRole needed
- [ ] Custom permissions

**Compliance Requirements:**
- [ ] GDPR
- [ ] SOC2
- [ ] ISO27001
- [ ] PCI DSS
- [ ] HIPAA
- [ ] No specific compliance

## 📊 Monitoring and Observability

**Monitoring Requirements:**
- [ ] Prometheus metrics
- [ ] Grafana dashboards
- [ ] Alerting rules
- [ ] Custom metrics
- [ ] No monitoring needed

**Logging Requirements:**
- [ ] Application logs
- [ ] Access logs
- [ ] Error logs
- [ ] Audit logs
- [ ] Structured logging (JSON)

**Tracing Requirements:**
- [ ] Distributed tracing (Jaeger)
- [ ] Request tracing
- [ ] Performance tracing
- [ ] No tracing needed

**Health Checks:**
- [ ] Liveness probe
- [ ] Readiness probe
- [ ] Startup probe
- [ ] Custom health endpoint

**Health Check Configuration:**
- **Liveness Probe:** <!-- e.g., HTTP GET /health, initial delay 30s, period 10s -->
- **Readiness Probe:** <!-- e.g., HTTP GET /ready, initial delay 5s, period 5s -->
- **Startup Probe:** <!-- e.g., HTTP GET /startup, initial delay 10s, period 5s -->

## 🔄 Deployment Strategy

**Deployment Strategy:**
- [ ] Rolling Update
- [ ] Recreate
- [ ] Blue/Green Deployment
- [ ] Canary Deployment
- [ ] A/B Testing
- [ ] Custom strategy

**Rollback Strategy:**
- [ ] Automatic rollback on failure
- [ ] Manual rollback required
- [ ] No rollback needed
- [ ] Custom rollback procedure

**Downtime Requirements:**
- [ ] Zero downtime required
- [ ] Minimal downtime acceptable (< 5 min)
- [ ] Planned downtime acceptable
- [ ] No downtime requirements

**Testing Requirements:**
- [ ] Pre-deployment testing
- [ ] Post-deployment testing
- [ ] Integration testing
- [ ] Performance testing
- [ ] Security testing
- [ ] No testing required

## 📅 Schedule and Dependencies

**Preferred Deployment Window:**
<!-- Date and time for deployment -->

**Deployment Duration:**
<!-- Expected time for deployment -->

**Dependencies:**
<!-- List any dependencies or prerequisites -->

**Stakeholders:**
<!-- List stakeholders who need to be notified -->

**Rollback Contact:**
<!-- Person to contact for rollback -->

## 🎯 Success Criteria

**Deployment Success Criteria:**
<!-- Define what constitutes a successful deployment -->

**Performance Criteria:**
<!-- Define performance expectations -->

**Availability Criteria:**
<!-- Define availability requirements -->

**Monitoring Criteria:**
<!-- Define monitoring expectations -->

## 📝 Additional Information

**Special Requirements:**
<!-- Any special requirements or considerations -->

**Known Issues:**
<!-- Any known issues or limitations -->

**Previous Deployments:**
<!-- Reference to previous deployments or issues -->

**Documentation:**
<!-- Links to relevant documentation -->

**Attachments:**
<!-- Any relevant attachments -->

## ✅ Checklist

**Pre-deployment:**
- [ ] Image built and tested
- [ ] Security scan completed
- [ ] Configuration validated
- [ ] Dependencies verified
- [ ] Stakeholders notified
- [ ] Backup created (if required)
- [ ] Rollback plan prepared

**Post-deployment:**
- [ ] Deployment verified
- [ ] Health checks passed
- [ ] Monitoring configured
- [ ] Alerts configured
- [ ] Documentation updated
- [ ] Stakeholders informed
- [ ] Post-deployment testing completed

---

## 📞 Contact Information

**Requester:**
<!-- Your name and contact information -->

**Team:**
<!-- Your team or department -->

**Approval Required:**
<!-- List who needs to approve this deployment -->

**Emergency Contact:**
<!-- Emergency contact information -->

---

**By submitting this request, I confirm that:**
- All required information has been provided
- The deployment has been tested in a non-production environment
- All security and compliance requirements have been considered
- Appropriate stakeholders have been notified
- A rollback plan is in place if needed
- I understand the potential impact of this deployment

**Requester Signature:** <!-- Type your name to sign -->

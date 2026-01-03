# GitHub Issue Templates for Space Invaders Enhanced Edition

---
name: Infrastructure Issue
about: Report infrastructure, deployment, or cloud provider problems
title: "[INFRASTRUCTURE]: "
labels: ["infrastructure", "status/new"]
assignees: ""
projects: ""
milestone: ""

---

## 🏗️ Infrastructure Issue Report

### 🌐 Infrastructure Component
What infrastructure component is affected?

- [ ] **GitHub Actions** - CI/CD pipeline issues
- [ ] **GitLab CI/CD** - GitLab pipeline problems
- [ ] **Bitbucket Pipelines** - Bitbucket pipeline issues
- [ ] **Yandex Cloud** - Yandex Cloud infrastructure
- [ ] **VK Cloud** - VK Cloud infrastructure
- [ ] **Selectel** - Selectel infrastructure
- [ ] **Docker/Kubernetes** - Container orchestration
- [ ] **Monitoring** - Monitoring and alerting systems
- [ ] **Load Balancer** - Load balancing issues
- [ ] **CDN** - Content delivery network
- [ ] **Database** - Database infrastructure
- [ ] **Storage** - Storage systems
- [ ] **Network** - Network infrastructure
- [ ] **Security** - Security infrastructure
- [ ] **Backup** - Backup and recovery systems

### 🎯 Infrastructure Problem
What specific infrastructure problem are you experiencing?

#### Deployment Issues
- [ ] **Build Failures** - Build process fails
- [ ] **Deployment Failures** - Deployment process fails
- [ ] **Configuration Errors** - Incorrect configuration
- [ ] **Environment Issues** - Environment-specific problems
- [ ] **Resource Limits** - Insufficient resources
- [ ] **Timeout Issues** - Operations timeout
- [ ] **Permission Errors** - Access/permission problems
- [ ] **Network Connectivity** - Network connection issues

#### Performance Issues
- [ ] **Slow Build Times** - Builds taking too long
- [ ] **Slow Deployments** - Deployments taking too long
- [ ] **High Resource Usage** - Excessive resource consumption
- [ ] **Memory Leaks** - Memory consumption increasing
- [ ] **CPU Bottlenecks** - CPU performance issues
- [ ] **I/O Bottlenecks** - Disk/network I/O issues
- [ ] **Database Performance** - Slow database operations
- [ ] **Cache Issues** - Cache performance problems

#### Availability Issues
- [ ] **Service Downtime** - Services unavailable
- [ ] **Partial Outages** - Some services unavailable
- [ ] **Intermittent Failures** - Sporadic failures
- [ ] **Auto-scaling Issues** - Scaling problems
- [ ] **Load Balancer Failures** - Load balancing issues
- [ ] **DNS Issues** - DNS resolution problems
- [ ] **SSL/TLS Issues** - Certificate/encryption problems
- [ ] **Health Check Failures** - Health check problems

#### Security Issues
- [ ] **Access Control** - Authentication/authorization issues
- [ ] **Data Exposure** - Data security problems
- [ ] **Vulnerabilities** - Security vulnerabilities
- [ ] **Compliance Issues** - Regulatory compliance problems
- [ ] **Audit Failures** - Audit trail issues
- [ ] **Encryption Problems** - Data encryption issues
- [ ] **Network Security** - Network security problems
- [ ] **Container Security** - Container security issues

### 🔄 Reproduction Steps
Steps to reproduce the infrastructure issue:
1. 
2. 
3. 
4. 

### 📊 Infrastructure Environment
What is the infrastructure environment?

#### Cloud Provider
- [ ] **Yandex Cloud** - Yandex Cloud infrastructure
- [ ] **VK Cloud** - VK Cloud infrastructure
- [ ] **Selectel** - Selectel infrastructure
- [ ] **AWS** - Amazon Web Services
- [ ] **Azure** - Microsoft Azure
- [ ] **GCP** - Google Cloud Platform
- [ ] **On-premise** - On-premise infrastructure
- [ ] **Hybrid** - Hybrid cloud setup

#### CI/CD Platform
- [ ] **GitHub Actions** - GitHub Actions
- [ ] **GitLab CI/CD** - GitLab CI/CD
- [ ] **Bitbucket Pipelines** - Bitbucket Pipelines
- [ ] **Jenkins** - Jenkins CI/CD
- [ ] **Azure DevOps** - Azure DevOps
- [ ] **CircleCI** - CircleCI
- [ ] **Travis CI** - Travis CI
- [ ] **Custom** - Custom CI/CD solution

#### Container Platform
- [ ] **Docker** - Docker containers
- [ ] **Kubernetes** - Kubernetes orchestration
- [ ] **Docker Swarm** - Docker Swarm
- [ ] **OpenShift** - OpenShift
- [ ] **Rancher** - Rancher
- [ ] **Nomad** - HashiCorp Nomad
- [ ] **ECS** - Amazon ECS
- [ ] **No containers** - No containerization

### 📱 Platform-Specific Details

#### GitHub Actions Issues
- [ ] **Workflow Failures** - Workflow execution failures
- [ ] **Runner Issues** - Self-hosted runner problems
- [ ] **Secret Management** - Secret/credential issues
- [ ] **Cache Issues** - Cache management problems
- [ ] **Artifact Issues** - Artifact storage/retrieval
- [ ] **Rate Limiting** - API rate limiting
- [ ] **Permission Issues** - Repository/organization permissions
- [ ] **Timeout Issues** - Workflow timeouts

#### GitLab CI/CD Issues
- [ ] **Pipeline Failures** - Pipeline execution failures
- [ ] **Runner Issues** - GitLab runner problems
- [ ] **Variable Management** - CI/CD variable issues
- [ ] **Cache Issues** - Cache management problems
- [ ] **Artifact Issues** - Artifact storage/retrieval
- [ ] **Environment Issues** - Environment management
- [ ] **Integration Issues** - Third-party integrations
- [ ] **Performance Issues** - Pipeline performance

#### Russian Cloud Issues
- [ ] **Yandex Cloud Issues** - Yandex Cloud specific problems
- [ ] **VK Cloud Issues** - VK Cloud specific problems
- [ ] **Selectel Issues** - Selectel specific problems
- [ ] **API Issues** - Cloud provider API problems
- [ ] **Authentication Issues** - Cloud authentication problems
- [ ] **Resource Limits** - Cloud resource limitations
- [ ] **Billing Issues** - Cloud billing problems
- [ ] **Compliance Issues** - Russian compliance requirements

### 🔍 Error Messages and Logs
Please provide relevant error messages and logs:

#### Error Messages
```
[Paste error messages here]
```

#### Log Files
```
[Paste relevant log excerpts here]
```

#### Stack Traces
```
[Paste stack traces here]
```

#### Console Output
```
[Paste console output here]
```

### 📊 Impact Assessment
How does this infrastructure issue affect the system?

#### System Impact
- [ ] **Complete Outage** - System completely unavailable
- [ ] **Partial Outage** - Some functionality unavailable
- [ ] **Degraded Performance** - System slow but functional
- [ ] **Data Loss** - Data has been lost or corrupted
- [ ] **Security Breach** - Security has been compromised
- [ ] **Compliance Violation** - Regulatory compliance issues
- [ ] **Financial Impact** - Financial costs incurred
- [ ] **User Impact** - Users are affected

#### Business Impact
- [ ] **Revenue Loss** - Direct revenue impact
- [ ] **Customer Dissatisfaction** - Customer complaints
- [ ] **Reputation Damage** - Brand reputation impact
- [ ] **Legal Issues** - Legal or regulatory issues
- [ ] **Productivity Loss** - Team productivity affected
- [ ] **Development Delays** - Development work delayed
- [ ] **Operational Disruption** - Operations disrupted
- [ ] **Strategic Impact** - Strategic goals affected

### 🛠️ Troubleshooting Steps Taken
What troubleshooting steps have you already taken?

#### Initial Diagnostics
- [ ] **Checked Logs** - Reviewed system logs
- [ ] **Verified Configuration** - Checked configuration files
- [ ] **Tested Connectivity** - Tested network connectivity
- [ ] **Checked Resources** - Verified resource availability
- [ ] **Validated Permissions** - Checked access permissions
- [ ] **Tested Manually** - Manual testing of affected component

#### Recovery Attempts
- [ ] **Restarted Services** - Restarted affected services
- [ ] **Cleared Cache** - Cleared various caches
- [ ] **Updated Configuration** - Updated configuration files
- [ ] **Scaled Resources** - Increased/decreased resources
- [ ] **Rolled Back Changes** - Reverted recent changes
- [ ] **Applied Patches** - Applied security/bug patches

#### Workarounds
- [ ] **Temporary Fix** - Implemented temporary workaround
- [ ] **Manual Process** - Switched to manual process
- [ ] **Alternative Service** - Used alternative service
- [ ] **Reduced Load** - Reduced system load
- [ ] **Disabled Features** - Disabled non-essential features

### 📋 Infrastructure Details
Please provide infrastructure details:

#### Cloud Configuration
- **Cloud Provider**: [Yandex Cloud/VK Cloud/Selectel/AWS/Azure/GCP]
- **Region**: [Cloud region/zone]
- **Resource Type**: [Compute/Storage/Network/Database]
- **Instance Type**: [Instance/machine type]
- **Storage Type**: [Storage class/type]
- **Network Type**: [Network configuration]

#### CI/CD Configuration
- **Platform**: [GitHub Actions/GitLab CI/Bitbucket Pipelines]
- **Runner Type**: [Self-hosted/Cloud-managed]
- **Pipeline Configuration**: [Pipeline configuration details]
- **Environment Variables**: [Environment configuration]
- **Secrets Management**: [Secret/credential management]
- **Cache Configuration**: [Cache setup]

#### Monitoring Configuration
- **Monitoring Tool**: [Prometheus/Grafana/CloudWatch/etc.]
- **Alerting System**: [AlertManager/PagerDuty/etc.]
- **Log Aggregation**: [ELK Stack/FluentD/etc.]
- **Metrics Collection**: [Metrics collection setup]
- **Dashboard Configuration**: [Monitoring dashboards]

### 🎯 Expected Behavior
What should the infrastructure component do?

#### Normal Operation
- [ ] **Builds Complete Successfully** - All builds complete without errors
- [ ] **Deployments Succeed** - All deployments complete successfully
- [ ] **Services Respond** - All services respond to requests
- [ ] **Performance is Acceptable** - Performance meets requirements
- [ ] **Security is Maintained** - Security measures are effective
- [ ] **Monitoring Works** - Monitoring and alerting function properly

#### Recovery Expectations
- [ ] **Automatic Recovery** - System recovers automatically
- [ ] **Manual Recovery** - Manual intervention required
- [ ] **Graceful Degradation** - System degrades gracefully
- [ ] **Failover Works** - Failover mechanisms function
- [ ] **Data is Preserved** - Data integrity is maintained
- [ ] **Service Continuity** - Service continues with minimal disruption

### 📅 Timeline
When did this issue occur and what's the urgency?

#### Issue Timeline
- **First Occurred**: [Date and time]
- **Frequency**: [Once/Occasional/Frequent/Constant]
- **Duration**: [How long has it been occurring]
- **Last Occurrence**: [Most recent occurrence]

#### Urgency Level
- [ ] **Critical** - Immediate action required (system down)
- [ ] **High** - Urgent action required (major impact)
- [ ] **Medium** - Normal priority (moderate impact)
- [ ] **Low** - Low priority (minor impact)

### 🔗 Related Issues
- **Related Issue**: #[issue number]
- **Duplicate of**: #[issue number]
- **Blocks**: #[issue number]
- **Caused by**: #[issue number]

### 👥 Stakeholders
Who should be involved in resolving this issue?

#### Technical Team
- [ ] **DevOps Engineer** - Infrastructure specialist
- [ ] **Cloud Engineer** - Cloud infrastructure expert
- [ ] **Security Engineer** - Security specialist
- [ ] **Database Administrator** - Database expert
- [ ] **Network Engineer** - Network specialist
- [ ] **Site Reliability Engineer** - SRE specialist

#### Business Team
- [ ] **Product Manager** - Product owner
- [ ] **Project Manager** - Project coordinator
- [ ] **Business Analyst** - Business requirements
- [ ] **Customer Support** - Customer support team
- [ ] **Legal Team** - Legal/compliance team
- [ ] **Finance Team** - Financial impact assessment

### 📚 Resources
What resources should be consulted?

#### Documentation
- [ ] **Infrastructure Documentation** - Internal infrastructure docs
- [ ] **Cloud Provider Docs** - Cloud provider documentation
- [ ] **CI/CD Documentation** - CI/CD platform documentation
- [ ] **Security Policies** - Security policies and procedures
- [ ] **Compliance Requirements** - Regulatory compliance docs

#### Tools and Services
- [ ] **Monitoring Tools** - Prometheus, Grafana, CloudWatch
- [ ] **Log Analysis Tools** - ELK Stack, Splunk
- [ ] **Infrastructure as Code** - Terraform, CloudFormation
- [ ] **Configuration Management** - Ansible, Puppet, Chef
- [ ] **Container Orchestration** - Kubernetes, Docker Swarm

### ✅ Checklist
- [ ] I have described the infrastructure issue in detail
- [ ] I have provided reproduction steps
- [ ] I have included error messages and logs
- [ ] I have assessed the impact on the system
- [ ] I have documented troubleshooting steps taken
- [ ] I have provided infrastructure configuration details
- [ ] I have defined expected behavior
- [ ] I have identified relevant stakeholders
- [ ] I have searched for similar infrastructure issues

---

**🏗️ Thank you for helping us improve our infrastructure!**

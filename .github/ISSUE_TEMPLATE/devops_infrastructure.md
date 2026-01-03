# GitHub Issue Templates for Space Invaders Enhanced Edition

---
name: DevOps Infrastructure
about: Report DevOps infrastructure issues or request infrastructure improvements
title: "[DEVOPS]: "
labels: ["devops", "infrastructure", "automation", "status/new"]
assignees: ""
projects: ""
milestone: ""

---

## 🔧 DevOps Infrastructure Request

### 🎯 Infrastructure Component
What DevOps infrastructure component is affected?

#### CI/CD Systems
- [ ] **GitHub Actions** - GitHub Actions workflows and runners
- [ ] **GitLab CI/CD** - GitLab CI/CD pipelines and runners
- [ ] **Bitbucket Pipelines** - Bitbucket pipelines and build agents
- [ ] **Jenkins** - Jenkins pipelines and agents
- [ ] **Azure DevOps** - Azure DevOps pipelines and agents
- [ ] **CircleCI** - CircleCI pipelines and orbs
- [ ] **Travis CI** - Travis CI configuration and builds
- [ ] **TeamCity** - TeamCity configurations and agents

#### Container Infrastructure
- [ ] **Docker** - Docker containers and images
- [ ] **Kubernetes** - Kubernetes clusters and deployments
- [ ] **Docker Swarm** - Docker Swarm clusters
- [ ] **Helm** - Helm charts and releases
- [ ] **Container Registry** - Container image registries
- [ ] **Kubernetes Operators** - Custom operators and controllers
- [ ] **Service Mesh** - Istio, Linkerd, or other service meshes
- [ ] **Container Security** - Container security scanning and policies

#### Cloud Infrastructure
- [ ] **Yandex Cloud** - Yandex Cloud resources and services
- [ ] **VK Cloud** - VK Cloud infrastructure
- [ ] **Selectel** - Selectel cloud services
- [ ] **AWS** - Amazon Web Services (if applicable)
- [ ] **Google Cloud** - Google Cloud Platform (if applicable)
- [ ] **Azure** - Microsoft Azure (if applicable)
- [ ] **DigitalOcean** - DigitalOcean infrastructure
- [ ] **Vultr** - Vultr cloud infrastructure

#### Monitoring and Logging
- [ ] **Prometheus** - Prometheus monitoring and alerting
- [ ] **Grafana** - Grafana dashboards and visualization
- [ ] **ELK Stack** - Elasticsearch, Logstash, Kibana
- [ ] **Fluentd** - Fluentd log collection and processing
- [ ] **Jaeger** - Distributed tracing and monitoring
- [ ] **Zipkin** - Distributed tracing system
- [ ] **Nagios** - Nagios monitoring and alerting
- [ ] **Zabbix** - Zabbix monitoring and alerting

#### Infrastructure as Code
- [ ] **Terraform** - Terraform configurations and state
- [ ] **Ansible** - Ansible playbooks and roles
- [ ] **Puppet** - Puppet manifests and modules
- [ ] **Chef** - Chef cookbooks and recipes
- [ ] **CloudFormation** - AWS CloudFormation templates
- [ ] **ARM Templates** - Azure Resource Manager templates
- [ ] **Pulumi** - Pulumi infrastructure as code
- [ ] **Crossplane** - Crossplane infrastructure management

### 🎯 Issue Type
What type of DevOps infrastructure issue are you experiencing?

#### Infrastructure Problems
- [ ] **Build Failures** - CI/CD build failures
- [ ] **Deployment Failures** - Deployment process failures
- [ ] **Performance Issues** - Infrastructure performance problems
- [ ] **Scaling Issues** - Auto-scaling and capacity issues
- [ ] **Network Issues** - Network connectivity and performance
- [ ] **Storage Issues** - Storage capacity and performance
- [ ] **Security Issues** - Infrastructure security vulnerabilities
- [ ] **Configuration Issues** - Infrastructure configuration problems

#### Automation Issues
- [ ] **Pipeline Failures** - CI/CD pipeline failures
- [ ] **Automation Errors** - Automation script errors
- [ ] **Integration Issues** - Tool integration problems
- [ ] **Workflow Issues** - Workflow and process issues
- [ ] **Trigger Issues** - Pipeline trigger problems
- [ ] **Environment Issues** - Environment setup and configuration
- [ ] **Dependency Issues** - Dependency management problems
- [ ] **Version Control Issues** - Version control integration problems

#### Monitoring and Alerting Issues
- [ ] **Monitoring Gaps** - Missing or inadequate monitoring
- [ ] **False Alerts** - Too many false positive alerts
- [ ] **Missing Alerts** - Critical alerts not configured
- [ ] **Dashboard Issues** - Monitoring dashboard problems
- [ ] **Log Collection Issues** - Log collection and processing problems
- [ ] **Metrics Issues** - Metrics collection and accuracy problems
- [ ] **Alert Fatigue** - Too many alerts overwhelming team
- [ ] **Performance Monitoring** - Performance monitoring gaps

#### Infrastructure as Code Issues
- [ ] **Terraform Issues** - Terraform configuration and state problems
- [ ] **Ansible Issues** - Ansible playbook and role problems
- [ ] **Configuration Drift** - Configuration inconsistencies
- [ ] **State Management** - Infrastructure state management issues
- [ ] **Module Issues** - Reusable module problems
- [ ] **Provider Issues** - Cloud provider integration issues
- [ ] **Version Conflicts** - Infrastructure version conflicts
- [ ] **Planning Issues** - Infrastructure planning and validation issues

### 🔄 Issue Details
Please provide specific details about the DevOps infrastructure issue:

#### Problem Description
- **Issue Summary**: [Brief description of the infrastructure issue]
- **Impact**: [How does this issue affect the system?]
- **Urgency**: [Critical/High/Medium/Low]
- **Affected Services**: [List of affected services]
- **Affected Environments**: [List of affected environments]
- **Business Impact**: [Impact on business operations]
- **Users Affected**: [Number/type of affected users]

#### Technical Details
- **Component**: [Specific infrastructure component]
- **Environment**: [Production/Staging/Development]
- **Region/Zone**: [Cloud region or availability zone]
- **Configuration**: [Relevant configuration details]
- **Error Messages**: [Any error messages or logs]
- **Recent Changes**: [Recent infrastructure changes]
- **Dependencies**: [Dependencies on other components]
- **Resource Usage**: [CPU, memory, storage, network usage]

#### Reproduction Steps
- **Steps to Reproduce**: [Step-by-step reproduction]
- **Expected Behavior**: [What should happen]
- **Actual Behavior**: [What actually happens]
- **Frequency**: [How often does this occur?]
- **First Occurred**: [When did this first happen?]
- **Pattern**: [Any patterns in occurrence]
- **Conditions**: [Specific conditions that trigger the issue]

### 📊 Impact Assessment
How does this infrastructure issue affect the system?

#### System Impact
- [ ] **Build Pipeline** - Affects build and CI pipeline
- [ ] **Deployment Pipeline** - Affects deployment and CD pipeline
- [ ] **Service Availability** - Affects service availability
- [ ] **Performance** - Affects system performance
- [ ] **Scalability** - Affects system scalability
- [ ] **Reliability** - Affects system reliability
- [ ] **Security** - Affects system security
- [ ] **Monitoring** - Affects monitoring and alerting

#### Development Impact
- [ ] **Developer Productivity** - Affects developer productivity
- [ ] **Release Cadence** - Affects release frequency
- [ ] **Code Quality** - Affects code quality checks
- [ ] **Testing Pipeline** - Affects testing pipeline
- [ ] **Feature Delivery** - Affects feature delivery speed
- [ ] **Debugging Capability** - Affects debugging and troubleshooting
- [ ] **Collaboration** - Affects team collaboration
- [ ] **Innovation** - Affects innovation and experimentation

#### Business Impact
- [ ] **Time to Market** - Affects time to market
- [ ] **Operational Costs** - Affects operational costs
- [ ] **Customer Satisfaction** - Affects customer satisfaction
- [ ] **Revenue** - Affects revenue generation
- [ ] **Compliance** - Affects regulatory compliance
- [ ] **Brand Reputation** - Affects brand reputation
- [ ] **Competitive Advantage** - Affects competitive position
- [ ] **Risk Management** - Affects risk management

### 🛠️ Troubleshooting Steps
What troubleshooting steps have been taken?

#### Initial Troubleshooting
- [ ] **Check Logs** - Reviewed system and application logs
- [ ] **Verify Configuration** - Verified infrastructure configuration
- [ ] **Check Resources** - Checked resource utilization
- [ ] **Test Connectivity** - Tested network connectivity
- [ ] **Restart Services** - Restarted affected services
- [ ] **Rollback Changes** - Rolled back recent changes
- [ ] **Check Dependencies** - Verified service dependencies
- [ ] **Review Recent Changes** - Reviewed recent infrastructure changes

#### Advanced Troubleshooting
- [ ] **Deep Dive Analysis** - Performed deep analysis of the issue
- [ ] **Performance Profiling** - Profiled system performance
- [ ] **Network Analysis** - Analyzed network traffic and patterns
- [ ] **Security Audit** - Conducted security audit
- [ ] **Capacity Analysis** - Analyzed capacity requirements
- [ ] **Dependency Analysis** - Analyzed component dependencies
- [ ] **Configuration Audit** - Audited configuration settings
- [ ] **Root Cause Analysis** - Conducted root cause analysis

### 📅 Timeline
When did this infrastructure issue occur and what's the resolution timeline?

#### Issue Timeline
- **First Occurred**: [Date and time when issue first occurred]
- **Detected**: [Date and time when issue was detected]
- **Reported**: [Date and time when issue was reported]
- **Investigation Started**: [Date and time when investigation started]
- **Target Resolution**: [Target resolution date and time]
- **Actual Resolution**: [Actual resolution date and time]
- **Post-Mortem**: [Date and time for post-mortem analysis]

#### Resolution Phases
- [ ] **Phase 1** - Initial assessment and triage
- [ ] **Phase 2** - Investigation and diagnosis
- [ ] **Phase 3** - Implementation of fix
- [ ] **Phase 4** - Testing and validation
- [ ] **Phase 5** - Deployment and monitoring
- [ ] **Phase 6** - Post-implementation review

### 🔗 Related Items
- **Related Issue**: #[issue number]
- **Duplicate of**: #[issue number]
- **Blocks**: #[issue number]
- **Caused by**: #[issue number]
- **Fixes**: #[issue number]
- **Related Pull Request**: #[pull request number]
- **Related Infrastructure**: #[infrastructure component]

### 👥 Stakeholders
Who should be involved in resolving this infrastructure issue?

#### Technical Team
- [ ] **DevOps Engineer** - DevOps and infrastructure team
- [ ] **Site Reliability Engineer** - SRE team
- [ ] **Cloud Architect** - Cloud architecture team
- [ ] **Network Engineer** - Network engineering team
- [ ] **Security Engineer** - Security team
- [ ] **Database Administrator** - Database administration team
- [ ] **Monitoring Engineer** - Monitoring and alerting team
- [ ] **Automation Engineer** - Automation and scripting team

#### Development Team
- [ ] **Backend Developer** - Backend development team
- [ ] **Frontend Developer** - Frontend development team
- [ ] **Mobile Developer** - Mobile development team
- [ ] **QA Engineer** - Quality assurance team
- [ ] **Tech Lead** - Technical leadership
- [ ] **Product Manager** - Product ownership
- [ ] **Project Manager** - Project coordination
- [ ] **Scrum Master** - Agile process management

#### Business Team
- [ ] **Operations Manager** - Operations management
- [ ] **IT Manager** - IT management
- [ ] **Finance Team** - Budget and cost management
- [ ] **Legal Team** - Legal and compliance
- [ ] **Executive Team** - Management stakeholders
- [ ] **Customer Support** - Customer support team
- [ ] **External Vendors** - Third-party service providers
- [ ] **Consultants** - External consultants and advisors

### 📚 Resources
What resources should be consulted?

#### Documentation
- [ ] **Infrastructure Documentation** - System infrastructure docs
- [ ] **Runbooks** - Operational runbooks and procedures
- [ ] **Architecture Documentation** - System architecture docs
- [ ] **Security Policies** - Security policies and procedures
- [ ] **Disaster Recovery** - Disaster recovery plans
- [ ] **Backup Procedures** - Backup and recovery procedures
- [ ] **Monitoring Documentation** - Monitoring and alerting docs
- [ ] **CI/CD Documentation** - Pipeline and automation docs

#### Tools and Systems
- [ ] **Monitoring Dashboards** - Performance monitoring dashboards
- [ ] **Log Analysis Tools** - Log analysis and search tools
- [ ] **Infrastructure Tools** - Infrastructure management tools
- [ ] **Configuration Management** - Infrastructure as code tools
- [ ] **Communication Tools** - Team communication and collaboration
- [ ] **Project Management** - Project management and tracking tools
- [ ] **Security Tools** - Security scanning and analysis tools
- [ ] **Performance Tools** - Performance testing and profiling tools

### ✅ Checklist
- [ ] I have described the infrastructure component and issue type
- [ ] I have provided detailed problem description and technical details
- [ ] I have included reproduction steps and expected behavior
- [ ] I have assessed the impact on system, development, and business
- [ ] I have documented troubleshooting steps taken
- [ ] I have provided issue timeline and resolution phases
- [ ] I have identified relevant stakeholders and resources
- [ ] I have searched for similar infrastructure issues

---

**🔧 Thank you for helping us maintain robust DevOps infrastructure!**

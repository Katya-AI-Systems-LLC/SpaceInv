# GitHub Issue Templates for Space Invaders Enhanced Edition

---
name: Database Issue
about: Report database-related problems or performance issues
title: "[DATABASE]: "
labels: ["database", "status/new"]
assignees: ""
projects: ""
milestone: ""

---

## 🗄️ Database Issue Report

### 🎯 Database Component
What database component is affected?

- [ ] **Primary Database** - Main application database
- [ ] **Replica Database** - Read replica database
- [ ] **Cache Database** - Redis/Memcached cache
- [ ] **Session Store** - Session storage database
- [ ] **Analytics Database** - Analytics and reporting database
- [ ] **Backup Database** - Backup storage database
- [ ] **Migration Scripts** - Database migration files
- [ ] **Connection Pool** - Database connection pool
- [ ] **Query Optimizer** - Database query optimization
- [ ] **Index Management** - Database indexes
- [ ] **Data Sync** - Data synchronization service

### 🎯 Database Issue Type
What specific database problem are you experiencing?

#### Performance Issues
- [ ] **Slow Queries** - Queries taking too long to execute
- [ ] **High CPU Usage** - Database consuming excessive CPU
- [ ] **Memory Issues** - Database memory problems
- [ ] **Disk I/O Bottlenecks** - Disk performance issues
- [ ] **Connection Timeouts** - Database connection timeouts
- [ ] **Lock Contention** - Database locking issues
- [ ] **Deadlocks** - Database deadlock situations
- [ ] **Index Fragmentation** - Index performance degradation

#### Data Issues
- [ ] **Data Corruption** - Corrupted data in database
- [ ] **Data Loss** - Missing or deleted data
- [ ] **Data Inconsistency** - Inconsistent data across tables
- [ ] **Duplicate Data** - Duplicate records in database
- [ ] **Invalid Data** - Invalid or malformed data
- [ ] **Data Migration Issues** - Problems with data migration
- [ ] **Sync Issues** - Data synchronization problems
- [ ] **Backup/Restore Issues** - Backup or restore failures

#### Connectivity Issues
- [ ] **Connection Failures** - Unable to connect to database
- [ ] **Authentication Issues** - Database authentication problems
- [ ] **Network Connectivity** - Network connection issues
- [ ] **Firewall Issues** - Firewall blocking database access
- [ ] **SSL/TLS Issues** - Secure connection problems
- [ ] **Load Balancer Issues** - Database load balancer problems
- [ ] **Failover Issues** - Database failover problems
- [ ] **Replication Issues** - Database replication problems

#### Schema Issues
- [ ] **Schema Migrations** - Database migration failures
- [ ] **Table Creation** - Problems creating tables
- [ ] **Index Creation** - Problems creating indexes
- [ ] **Constraint Issues** - Database constraint problems
- [ ] **Data Type Issues** - Data type mismatches
- [ ] **Foreign Key Issues** - Foreign key constraint problems
- [ ] **Schema Validation** - Schema validation failures
- [ ] **Version Compatibility** - Database version compatibility

### 🔄 Reproduction Steps
Steps to reproduce the database issue:
1. 
2. 
3. 
4. 

### 📊 Database Environment
What is the database environment?

#### Database Type
- [ ] **PostgreSQL** - PostgreSQL database
- [ ] **MySQL** - MySQL database
- [ ] **MongoDB** - MongoDB database
- [ ] **Redis** - Redis cache/database
- [ ] **SQLite** - SQLite database
- [ ] **Yandex Database** - Yandex Cloud database
- [ ] **VK Cloud Database** - VK Cloud database
- [ ] **Selectel Database** - Selectel database

#### Database Version
- [ ] **Latest Stable** - Latest stable version
- [ ] **Specific Version** - [Specify version]
- [ ] **Cloud Managed** - Cloud-managed database
- [ ] **Self-Hosted** - Self-hosted database
- [ ] **Containerized** - Database in container
- [ ] **Clustered** - Database cluster setup

#### Environment
- [ ] **Development** - Development environment
- [ ] **Staging** - Staging environment
- [ ] **Production** - Production environment
- [ ] **Testing** - Testing environment
- [ ] **Local** - Local development
- [ ] **Cloud** - Cloud environment

### 🔍 Query Information
Please provide query details:

#### Problematic Query
```sql
[Paste the problematic SQL query here]
```

#### Query Execution Plan
```
[Paste the query execution plan here]
```

#### Query Performance Metrics
- **Execution Time**: [e.g., 5.2 seconds]
- **Rows Affected**: [e.g., 1000 rows]
- **Memory Usage**: [e.g., 256MB]
- **CPU Usage**: [e.g., 15%]
- **Disk I/O**: [e.g., 50MB/s]

#### Database Logs
```
[Paste relevant database log entries here]
```

### 📱 Platform-Specific Details

#### Yandex Database Issues
- [ ] **YDB Connection Issues** - Yandex Database connection problems
- [ ] **Table API Issues** - YDB Table API problems
- [ ] **Document API Issues** - YDB Document API problems
- [ ] **Query Language Issues** - YQL query problems
- [ ] **Transaction Issues** - YDB transaction problems
- [ ] **Partition Issues** - YDB partition problems
- [ ] **Replication Issues** - YDB replication problems
- [ ] **Backup Issues** - YDB backup problems

#### VK Cloud Database Issues
- [ ] **VK Cloud Connection** - VK Cloud database connection
- [ ] **Managed Database** - VK Cloud managed database
- [ ] **Performance Issues** - VK Cloud performance problems
- [ ] **Scaling Issues** - VK Cloud scaling problems
- [ ] **Backup Issues** - VK Cloud backup problems
- [ ] **Security Issues** - VK Cloud security problems
- [ ] **Monitoring Issues** - VK Cloud monitoring problems
- [ ] **Maintenance Issues** - VK Cloud maintenance problems

#### Selectel Database Issues
- [ ] **Selectel Connection** - Selectel database connection
- [ ] **Cloud Database** - Selectel cloud database
- [ ] **Performance Issues** - Selectel performance problems
- [ ] **Replication Issues** - Selectel replication problems
- [ ] **Backup Issues** - Selectel backup problems
- [ ] **Security Issues** - Selectel security problems
- [ ] **Network Issues** - Selectel network problems
- [ ] **Resource Issues** - Selectel resource limitations

### 📊 Impact Assessment
How does this database issue affect the system?

#### System Impact
- [ ] **Complete Outage** - System completely unavailable
- [ ] **Partial Outage** - Some functionality unavailable
- [ ] **Degraded Performance** - System slow but functional
- [ ] **Data Loss** - Data has been lost or corrupted
- [ ] **Data Inconsistency** - Data is inconsistent
- [ ] **Security Risk** - Security vulnerability
- [ ] **Compliance Issues** - Regulatory compliance problems
- [ ] **User Impact** - Users are affected

#### Business Impact
- [ ] **Revenue Loss** - Direct revenue impact
- [ ] **Customer Dissatisfaction** - Customer complaints
- [ ] **Data Recovery Costs** - Data recovery expenses
- [ ] **Downtime Costs** - System downtime costs
- [ ] **Reputation Damage** - Brand reputation impact
- [ ] **Legal Issues** - Legal or regulatory issues
- [ ] **Productivity Loss** - Team productivity affected
- [ ] **Development Delays** - Development work delayed

### 🛠️ Troubleshooting Steps Taken
What troubleshooting steps have you already taken?

#### Initial Diagnostics
- [ ] **Checked Database Logs** - Reviewed database error logs
- [ ] **Verified Connectivity** - Tested database connectivity
- [ ] **Checked Query Performance** - Analyzed slow queries
- [ ] **Verified Resources** - Checked database resources
- [ ] **Tested Replication** - Tested database replication
- [ ] **Checked Backups** - Verified backup integrity

#### Performance Analysis
- [ ] **Query Optimization** - Optimized problematic queries
- [ ] **Index Analysis** - Analyzed and rebuilt indexes
- [ ] **Resource Monitoring** - Monitored resource usage
- [ ] **Connection Pool Analysis** - Analyzed connection pool
- [ ] **Cache Analysis** - Analyzed cache performance
- [ ] **Lock Analysis** - Analyzed database locks

#### Recovery Attempts
- [ ] **Restarted Database** - Restarted database service
- [ ] **Failed Over** - Failed over to replica
- [ ] **Restored from Backup** - Restored from backup
- [ ] **Rebuilt Indexes** - Rebuilt database indexes
- [ ] **Optimized Configuration** - Optimized database config
- [ ] **Scaled Resources** - Increased database resources

### 📋 Database Configuration
Please provide database configuration details:

#### Connection Configuration
- **Host**: [Database host]
- **Port**: [Database port]
- **Database Name**: [Database name]
- **Username**: [Database username]
- **Connection Pool Size**: [Pool size]
- **Timeout Settings**: [Timeout values]
- **SSL Configuration**: [SSL/TLS settings]

#### Performance Configuration
- **Memory Settings**: [Memory allocation]
- **Cache Settings**: [Cache configuration]
- **Query Timeout**: [Query timeout]
- **Connection Timeout**: [Connection timeout]
- **Max Connections**: [Maximum connections]
- **Work Memory**: [Work memory setting]
- **Maintenance Settings**: [Maintenance configuration]

#### Replication Configuration
- **Replication Type**: [Master-slave/Master-master]
- **Replica Servers**: [Number of replicas]
- **Sync Mode**: [Synchronous/Asynchronous]
- **Failover Mode**: [Automatic/Manual]
- **Lag Threshold**: [Replication lag threshold]
- **Backup Frequency**: [Backup schedule]

### 🎯 Expected Behavior
What should the database component do?

#### Normal Operation
- [ ] **Queries Execute Quickly** - All queries execute within acceptable time
- [ ] **Data is Consistent** - Data remains consistent across operations
- [ ] **Connections Stable** - Database connections remain stable
- [ ] **Replication Works** - Replication functions properly
- [ ] **Backups Complete** - Backups complete successfully
- [ ] **Performance is Acceptable** - Performance meets requirements

#### Recovery Expectations
- [ ] **Automatic Recovery** - Database recovers automatically
- [ ] **Failover Works** - Failover mechanisms function
- [ ] **Data is Preserved** - Data integrity is maintained
- [ ] **Service Continuity** - Service continues with minimal disruption
- [ ] **Performance Restored** - Performance returns to normal
- [ ] **Consistency Maintained** - Data consistency is maintained

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
Who should be involved in resolving this database issue?

#### Technical Team
- [ ] **Database Administrator** - DBA specialist
- [ ] **Backend Developer** - Backend development team
- [ ] **DevOps Engineer** - Infrastructure specialist
- [ ] **Cloud Engineer** - Cloud database expert
- [ ] **Security Engineer** - Security specialist
- [ ] **Performance Engineer** - Performance optimization expert

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
- [ ] **Database Documentation** - Database vendor documentation
- [ ] **Schema Documentation** - Database schema documentation
- [ ] **Migration Scripts** - Database migration scripts
- [ ] **Backup Procedures** - Backup and recovery procedures
- [ ] **Performance Tuning** - Performance tuning guides

#### Tools and Services
- [ ] **Database Monitoring** - Monitoring tools and dashboards
- [ ] **Query Analysis** - Query analysis tools
- [ ] **Performance Profiling** - Performance profiling tools
- [ ] **Backup Tools** - Backup and recovery tools
- [ ] **Security Tools** - Database security tools

### ✅ Checklist
- [ ] I have described the database issue in detail
- [ ] I have provided reproduction steps
- [ ] I have included query details and execution plans
- [ ] I have assessed the impact on the system
- [ ] I have documented troubleshooting steps taken
- [ ] I have provided database configuration details
- [ ] I have defined expected behavior
- [ ] I have identified relevant stakeholders
- [ ] I have searched for similar database issues

---

**🗄️ Thank you for helping us improve our database infrastructure!**

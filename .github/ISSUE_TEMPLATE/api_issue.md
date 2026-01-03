# GitHub Issue Templates for Space Invaders Enhanced Edition

---
name: API Issue
about: Report API-related problems, endpoint issues, or integration problems
title: "[API]: "
labels: ["api", "status/new"]
assignees: ""
projects: ""
milestone: ""

---

## 🔌 API Issue Report

### 🎯 API Component
What API component is affected?

- [ ] **REST API** - RESTful API endpoints
- [ ] **GraphQL API** - GraphQL API endpoints
- [ ] **WebSocket API** - WebSocket connections
- [ ] **Authentication API** - Authentication endpoints
- [ ] **Authorization API** - Authorization endpoints
- [ ] **Payment API** - Payment processing endpoints
- [ ] **Notification API** - Notification endpoints
- [ ] **Analytics API** - Analytics endpoints
- [ ] **File Upload API** - File upload endpoints
- [ ] **Third-party API** - External API integrations
- [ ] **API Gateway** - API gateway configuration
- [ ] **Rate Limiting** - API rate limiting

### 🎯 API Issue Type
What specific API problem are you experiencing?

#### Endpoint Issues
- [ ] **Endpoint Not Found** - 404 errors for endpoints
- [ ] **Method Not Allowed** - 405 errors for HTTP methods
- [ ] **Invalid Parameters** - Parameter validation errors
- [ ] **Missing Parameters** - Required parameters missing
- [ ] **Invalid Response Format** - Response format issues
- [ ] **Incorrect Status Codes** - Wrong HTTP status codes
- [ ] **Response Time Issues** - Slow response times
- [ ] **Timeout Issues** - Request timeouts

#### Authentication/Authorization Issues
- [ ] **Authentication Failures** - Login/authentication problems
- [ ] **Authorization Failures** - Permission/access problems
- [ ] **Token Issues** - JWT token problems
- [ ] **API Key Issues** - API key problems
- [ ] **OAuth Issues** - OAuth authentication problems
- [ ] **Session Issues** - Session management problems
- [ ] **Permission Issues** - Role/permission problems
- [ ] **CORS Issues** - Cross-origin request issues

#### Data Issues
- [ ] **Invalid Request Data** - Invalid request payload
- [ ] **Missing Request Data** - Required data missing
- [ ] **Data Validation Errors** - Data validation failures
- [ ] **Serialization Issues** - JSON serialization problems
- [ ] **Deserialization Issues** - JSON deserialization problems
- [ ] **Data Type Issues** - Data type mismatches
- [ ] **Encoding Issues** - Character encoding problems
- [ ] **Large Payload Issues** - Large request/response issues

#### Integration Issues
- [ ] **Third-party API Failures** - External API problems
- [ ] **Webhook Issues** - Webhook delivery problems
- [ ] **Callback Issues** - Callback URL problems
- [ ] **API Version Issues** - API version compatibility
- [ ] **Deprecated Endpoints** - Deprecated API usage
- [ ] **Breaking Changes** - Breaking API changes
- [ ] **Documentation Mismatch** - API docs vs reality
- [ ] **SDK Issues** - SDK integration problems

### 🔄 Reproduction Steps
Steps to reproduce the API issue:
1. 
2. 
3. 
4. 

### 📊 API Environment
What is the API environment?

#### API Type
- [ ] **Internal API** - Internal application API
- [ ] **Public API** - Public-facing API
- [ ] **Partner API** - Partner integration API
- [ ] **Admin API** - Administrative API
- [ ] **Mobile API** - Mobile application API
- [ ] **Web API** - Web application API

#### Environment
- [ ] **Development** - Development environment
- [ ] **Staging** - Staging environment
- [ ] **Production** - Production environment
- [ ] **Testing** - Testing environment
- [ ] **Local** - Local development
- [ ] **Cloud** - Cloud environment

#### Protocol
- [ ] **HTTP/HTTPS** - HTTP/HTTPS protocol
- [ ] **WebSocket** - WebSocket protocol
- [ ] **gRPC** - gRPC protocol
- [ ] **GraphQL** - GraphQL protocol
- [ ] **REST** - REST protocol
- [ ] **SOAP** - SOAP protocol

### 🔍 API Request Details
Please provide API request details:

#### Request Information
- **Method**: [GET/POST/PUT/DELETE/PATCH]
- **Endpoint**: [API endpoint URL]
- **Headers**: [Request headers]
- **Parameters**: [Query parameters]
- **Request Body**: [Request payload]

#### Request Example
```http
[Paste the complete HTTP request here]
```

#### Request Body (if applicable)
```json
[Paste the request body here]
```

#### Response Information
- **Status Code**: [HTTP status code]
- **Response Headers**: [Response headers]
- **Response Body**: [Response payload]

#### Response Example
```json
[Paste the complete response here]
```

### 📱 Platform-Specific Details

#### Russian Cloud API Issues
- [ ] **Yandex Cloud API** - Yandex Cloud API problems
- [ ] **VK Cloud API** - VK Cloud API problems
- [ ] **Selectel API** - Selectel API problems
- [ ] **API Gateway Issues** - API gateway configuration
- [ ] **Function API** - Cloud function API issues
- [ ] **Storage API** - Cloud storage API issues
- [ ] **Database API** - Cloud database API issues
- [ ] **Monitoring API** - Cloud monitoring API issues

#### Third-party Integration Issues
- [ ] **Payment Gateway** - Payment processing API
- [ ] **Social Media APIs** - Social media integrations
- [ ] **Analytics APIs** - Analytics service APIs
- [ ] **Notification APIs** - Notification services
- [ ] **Storage APIs** - Cloud storage services
- [ ] **Authentication APIs** - Authentication services
- [ ] **Email APIs** - Email service APIs
- [ ] **SMS APIs** - SMS service APIs

### 📊 Impact Assessment
How does this API issue affect the system?

#### System Impact
- [ ] **Complete Outage** - API completely unavailable
- [ ] **Partial Outage** - Some API endpoints unavailable
- [ ] **Degraded Performance** - API slow but functional
- [ ] **Data Loss** - Data lost through API
- [ ] **Security Risk** - Security vulnerability
- [ ] **Integration Failures** - Third-party integrations failing
- [ ] **User Impact** - Users are affected
- [ ] **Business Logic Failures** - Business logic not working

#### Business Impact
- [ ] **Revenue Loss** - Direct revenue impact
- [ ] **Customer Dissatisfaction** - Customer complaints
- [ ] **Integration Costs** - Integration repair costs
- [ ] **Downtime Costs** - API downtime costs
- [ ] **Reputation Damage** - Brand reputation impact
- [ ] **Legal Issues** - Legal or regulatory issues
- [ ] **Productivity Loss** - Team productivity affected
- [ ] **Development Delays** - Development work delayed

### 🛠️ Troubleshooting Steps Taken
What troubleshooting steps have you already taken?

#### Initial Diagnostics
- [ ] **Checked API Logs** - Reviewed API error logs
- [ ] **Tested Endpoint** - Tested specific endpoint
- [ ] **Verified Parameters** - Checked request parameters
- [ ] **Checked Authentication** - Verified authentication
- [ ] **Tested with Different Client** - Tried different API client
- [ ] **Checked Network** - Verified network connectivity

#### API Testing
- [ ] **Postman Testing** - Tested with Postman
- [ ] **Curl Testing** - Tested with curl
- [ ] **Unit Testing** - Ran API unit tests
- [ ] **Integration Testing** - Ran integration tests
- [ ] **Load Testing** - Performed load testing
- [ ] **Security Testing** - Performed security testing

#### Configuration Checks
- [ ] **API Gateway Config** - Checked API gateway settings
- [ ] **Rate Limiting Config** - Verified rate limiting
- [ ] **CORS Config** - Checked CORS settings
- [ ] **Authentication Config** - Verified auth settings
- [ ] **Load Balancer Config** - Checked load balancer
- [ ] **DNS Configuration** - Verified DNS settings

### 📋 API Configuration
Please provide API configuration details:

#### Authentication Configuration
- **Auth Type**: [JWT/OAuth/API Key/Basic]
- **Token Endpoint**: [Token endpoint URL]
- **Scope Requirements**: [Required scopes]
- **Expiration Time**: [Token expiration]
- **Refresh Token**: [Refresh token settings]
- **Rate Limiting**: [Rate limit settings]

#### API Gateway Configuration
- **Gateway URL**: [API gateway URL]
- **Routes**: [API route configuration]
- **Middleware**: [Applied middleware]
- **Rate Limiting**: [Rate limiting rules]
- **CORS Settings**: [CORS configuration]
- **SSL/TLS**: [SSL/TLS configuration]

#### Monitoring Configuration
- **Logging Level**: [Logging configuration]
- **Metrics Collection**: [Metrics settings]
- **Alerting Rules**: [Alert configuration]
- **Health Checks**: [Health check endpoints]
- **Performance Monitoring**: [Performance settings]

### 🎯 Expected Behavior
What should the API component do?

#### Normal Operation
- [ ] **Endpoints Respond** - All endpoints respond correctly
- [ ] **Authentication Works** - Authentication functions properly
- [ ] **Authorization Works** - Authorization functions properly
- [ ] **Data Validation** - Request data is validated properly
- [ ] **Response Format** - Responses are in correct format
- [ ] **Performance Acceptable** - Response times are acceptable

#### Error Handling
- [ ] **Proper Status Codes** - Correct HTTP status codes
- [ ] **Error Messages** - Clear error messages
- [ ] **Validation Errors** - Proper validation error responses
- [ ] **Rate Limiting** - Rate limiting responses
- [ ] **Authentication Errors** - Proper auth error responses
- [ ] **Server Errors** - Proper server error responses

### 📅 Timeline
When did this issue occur and what's the urgency?

#### Issue Timeline
- **First Occurred**: [Date and time]
- **Frequency**: [Once/Occasional/Frequent/Constant]
- **Duration**: [How long has it been occurring]
- **Last Occurrence**: [Most recent occurrence]

#### Urgency Level
- [ ] **Critical** - Immediate action required (API down)
- [ ] **High** - Urgent action required (major impact)
- [ ] **Medium** - Normal priority (moderate impact)
- [ ] **Low** - Low priority (minor impact)

### 🔗 Related Issues
- **Related Issue**: #[issue number]
- **Duplicate of**: #[issue number]
- **Blocks**: #[issue number]
- **Caused by**: #[issue number]

### 👥 Stakeholders
Who should be involved in resolving this API issue?

#### Technical Team
- [ ] **API Developer** - API development team
- [ ] **Backend Developer** - Backend development team
- [ ] **DevOps Engineer** - Infrastructure specialist
- [ ] **Security Engineer** - Security specialist
- [ ] **QA Engineer** - Quality assurance
- [ ] **Frontend Developer** - Frontend development team

#### Business Team
- [ ] **Product Manager** - Product owner
- [ ] **Project Manager** - Project coordinator
- [ ] **Business Analyst** - Business requirements
- [ ] **Customer Support** - Customer support team
- [ ] **Integration Partners** - Third-party partners
- [ ] **Legal Team** - Legal/compliance team

### 📚 Resources
What resources should be consulted?

#### Documentation
- [ ] **API Documentation** - API reference documentation
- [ ] **Integration Guides** - Integration documentation
- [ ] **SDK Documentation** - SDK documentation
- [ ] **Authentication Docs** - Authentication documentation
- [ ] **Error Code Reference** - Error code documentation

#### Tools and Services
- [ ] **API Testing Tools** - Postman, Insomnia, etc.
- [ ] **Monitoring Tools** - API monitoring services
- [ ] **Documentation Tools** - API documentation tools
- [ ] **Testing Frameworks** - API testing frameworks
- [ ] **Security Tools** - API security tools

### ✅ Checklist
- [ ] I have described the API issue in detail
- [ ] I have provided reproduction steps
- [ ] I have included request/response examples
- [ ] I have assessed the impact on the system
- [ ] I have documented troubleshooting steps taken
- [ ] I have provided API configuration details
- [ ] I have defined expected behavior
- [ ] I have identified relevant stakeholders
- [ ] I have searched for similar API issues

---

**🔌 Thank you for helping us improve our API infrastructure!**

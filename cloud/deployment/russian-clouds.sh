# Russian Cloud Deployment Scripts for Space Invaders Enhanced Edition

## Yandex Cloud Deployment Scripts

### Yandex Cloud Functions Deployment
```bash
#!/bin/bash
# deploy-yandex-functions.sh

set -e

# Configuration
FUNCTION_NAME="space-invaders-function"
RUNTIME="nodejs16"
MEMORY="512m"
TIMEOUT="10s"
ENTRY_POINT="index.js"
FOLDER_ID="${YC_FOLDER_ID}"
SERVICE_ACCOUNT_KEY="${YC_SERVICE_ACCOUNT_KEY}"

echo "🚀 Deploying to Yandex Cloud Functions..."

# Setup Yandex Cloud CLI
if ! command -v yc &> /dev/null; then
    echo "📦 Installing Yandex Cloud CLI..."
    curl -sSL https://storage.yandexcloud.net/yandexcloud-yc/install.sh | bash
    export PATH=$PATH:$HOME/yandex-cloud/bin
fi

# Configure Yandex Cloud
echo "🔧 Configuring Yandex Cloud..."
yc config profile create sa-profile
yc config set service-account-key "$SERVICE_ACCOUNT_KEY"
yc config set folder-id "$FOLDER_ID"

# Build function
echo "🔨 Building function..."
npm run build:function

# Create or update function
if yc serverless function get --name "$FUNCTION_NAME" --folder-id "$FOLDER_ID" &> /dev/null; then
    echo "📝 Updating existing function..."
    yc serverless function update \
        --name "$FUNCTION_NAME" \
        --folder-id "$FOLDER_ID"
else
    echo "📝 Creating new function..."
    yc serverless function create \
        --name "$FUNCTION_NAME" \
        --folder-id "$FOLDER_ID" \
        --runtime "$RUNTIME" \
        --entry-point "$ENTRY_POINT" \
        --memory "$MEMORY" \
        --execution-timeout "$TIMEOUT"
fi

# Deploy function code
echo "🚀 Deploying function code..."
yc serverless function version create \
    --function-name "$FUNCTION_NAME" \
    --folder-id "$FOLDER_ID" \
    --runtime "$RUNTIME" \
    --entry-point "$ENTRY_POINT" \
    --memory "$MEMORY" \
    --execution-timeout "$TIMEOUT" \
    --source-path build/

# Get function URL
FUNCTION_URL=$(yc serverless function get --name "$FUNCTION_NAME" --folder-id "$FOLDER_ID" --format json | jq -r '.http_invoke_url')

echo "✅ Function deployed successfully!"
echo "🔗 Function URL: $FUNCTION_URL"

# Set up triggers
echo "⚡ Setting up triggers..."
yc serverless trigger create timer \
    --name "daily-backup" \
    --folder-id "$FOLDER_ID" \
    --cron-expression "0 2 * * *" \
    --payload '{"action": "backup"}' \
    --invoke-function-name "$FUNCTION_NAME" \
    --invoke-function-tag "\$latest"

echo "🎉 Yandex Cloud Functions deployment completed!"
```

### Yandex Cloud Storage Deployment
```bash
#!/bin/bash
# deploy-yandex-storage.sh

set -e

# Configuration
BUCKET_NAME="${YC_BUCKET_NAME}"
FOLDER_ID="${YC_FOLDER_ID}"
SERVICE_ACCOUNT_KEY="${YC_SERVICE_ACCOUNT_KEY}"
CDN_ORIGIN="$BUCKET_NAME.storage.yandexcloud.net"

echo "🚀 Deploying to Yandex Cloud Storage..."

# Setup Yandex Cloud CLI
if ! command -v yc &> /dev/null; then
    echo "📦 Installing Yandex Cloud CLI..."
    curl -sSL https://storage.yandexcloud.net/yandexcloud-yc/install.sh | bash
    export PATH=$PATH:$HOME/yandex-cloud/bin
fi

# Configure Yandex Cloud
echo "🔧 Configuring Yandex Cloud..."
yc config profile create sa-profile
yc config set service-account-key "$SERVICE_ACCOUNT_KEY"
yc config set folder-id "$FOLDER_ID"

# Build web application
echo "🔨 Building web application..."
flutter build web --web-renderer canvaskit --release

# Create bucket if it doesn't exist
if ! yc storage bucket get --name "$BUCKET_NAME" --folder-id "$FOLDER_ID" &> /dev/null; then
    echo "📝 Creating storage bucket..."
    yc storage bucket create \
        --name "$BUCKET_NAME" \
        --folder-id "$FOLDER_ID" \
        --default-storage-class "standard" \
        --acl "public-read"
fi

# Deploy files to storage
echo "🚀 Deploying files to storage..."
yc storage s3 cp \
    --recursive \
    --endpoint-url=https://storage.yandexcloud.net \
    build/web/ \
    s3://$BUCKET_NAME/

# Set up CDN
echo "⚡ Setting up CDN..."
if ! yc cdn resource get --name "space-invaders-cdn" --folder-id "$FOLDER_ID" &> /dev/null; then
    echo "📝 Creating CDN resource..."
    yc cdn resource create \
        --name "space-invaders-cdn" \
        --folder-id "$FOLDER_ID" \
        --origin "$CDN_ORIGIN" \
        --active
else
    echo "📝 Updating CDN resource..."
    yc cdn resource update \
        --name "space-invaders-cdn" \
        --folder-id "$FOLDER_ID" \
        --active
fi

# Invalidate CDN cache
echo "🔄 Invalidating CDN cache..."
yc cdn cache invalidate \
    --folder-id "$FOLDER_ID" \
    --path "/*"

# Get CDN URL
CDN_URL=$(yc cdn resource get --name "space-invaders-cdn" --folder-id "$FOLDER_ID" --format json | jq -r '.domain_name')

echo "✅ Storage deployment completed!"
echo "🔗 Storage URL: https://$CDN_ORIGIN"
echo "🔗 CDN URL: https://$CDN_URL"

echo "🎉 Yandex Cloud Storage deployment completed!"
```

### Yandex Cloud API Gateway Deployment
```bash
#!/bin/bash
# deploy-yandex-api-gateway.sh

set -e

# Configuration
GATEWAY_NAME="space-invaders-api"
FUNCTION_NAME="space-invaders-function"
FOLDER_ID="${YC_FOLDER_ID}"
SERVICE_ACCOUNT_KEY="${YC_SERVICE_ACCOUNT_KEY}"

echo "🚀 Deploying to Yandex Cloud API Gateway..."

# Setup Yandex Cloud CLI
if ! command -v yc &> /dev/null; then
    echo "📦 Installing Yandex Cloud CLI..."
    curl -sSL https://storage.yandexcloud.net/yandexcloud-yc/install.sh | bash
    export PATH=$PATH:$HOME/yandex-cloud/bin
fi

# Configure Yandex Cloud
echo "🔧 Configuring Yandex Cloud..."
yc config profile create sa-profile
yc config set service-account-key "$SERVICE_ACCOUNT_KEY"
yc config set folder-id "$FOLDER_ID"

# Get function ID
FUNCTION_ID=$(yc serverless function get --name "$FUNCTION_NAME" --folder-id "$FOLDER_ID" --format json | jq -r '.id')

# Create API Gateway specification
cat > api-gateway-spec.yaml << EOF
openapi: 3.0.0
info:
  title: Space Invaders API
  version: 1.0.0
paths:
  /api/health:
    get:
      x-yc-apigateway-integration:
        type: cloud_function
        function_id: $FUNCTION_ID
        tag: "\$latest"
        payload_format: "1.0"
      responses:
        '200':
          description: Health check successful
          content:
            application/json:
              schema:
                type: object
                properties:
                  status:
                    type: string
                    example: "healthy"
  /api/score:
    get:
      x-yc-apigateway-integration:
        type: cloud_function
        function_id: $FUNCTION_ID
        tag: "\$latest"
        payload_format: "1.0"
      responses:
        '200':
          description: Score retrieved successfully
          content:
            application/json:
              schema:
                type: object
                properties:
                  scores:
                    type: array
                    items:
                      type: object
                      properties:
                        player:
                          type: string
                        score:
                          type: integer
                        date:
                          type: string
  /api/score:
    post:
      x-yc-apigateway-integration:
        type: cloud_function
        function_id: $FUNCTION_ID
        tag: "\$latest"
        payload_format: "1.0"
      requestBody:
        required: true
        content:
          application/json:
            schema:
              type: object
              properties:
                player:
                  type: string
                score:
                  type: integer
      responses:
        '200':
          description: Score saved successfully
          content:
            application/json:
              schema:
                type: object
                properties:
                  success:
                    type: boolean
                    example: true
EOF

# Create or update API Gateway
if yc api-gateway get --name "$GATEWAY_NAME" --folder-id "$FOLDER_ID" &> /dev/null; then
    echo "📝 Updating existing API Gateway..."
    yc api-gateway update \
        --name "$GATEWAY_NAME" \
        --folder-id "$FOLDER_ID" \
        --spec api-gateway-spec.yaml
else
    echo "📝 Creating new API Gateway..."
    yc api-gateway create \
        --name "$GATEWAY_NAME" \
        --folder-id "$FOLDER_ID" \
        --spec api-gateway-spec.yaml
fi

# Get API Gateway URL
GATEWAY_URL=$(yc api-gateway get --name "$GATEWAY_NAME" --folder-id "$FOLDER_ID" --format json | jq -r '.domain')

echo "✅ API Gateway deployed successfully!"
echo "🔗 API Gateway URL: https://$GATEWAY_URL"

echo "🎉 Yandex Cloud API Gateway deployment completed!"
```

## VK Cloud Deployment Scripts

### VK Cloud Container Registry Deployment
```bash
#!/bin/bash
# deploy-vk-container-registry.sh

set -e

# Configuration
REGISTRY_URL="${VK_CLOUD_REGISTRY}"
IMAGE_NAME="space-invaders"
IMAGE_TAG="${IMAGE_TAG:-latest}"
DEPLOY_URL="${VK_CLOUD_DEPLOY_URL}"
TOKEN="${VK_CLOUD_TOKEN}"

echo "🚀 Deploying to VK Cloud Container Registry..."

# Login to VK Cloud Registry
echo "🔐 Logging in to VK Cloud Registry..."
echo "$TOKEN" | docker login "$REGISTRY_URL" -u "${VK_CLOUD_USERNAME}" --password-stdin

# Build Docker image
echo "🔨 Building Docker image..."
docker build -t "$IMAGE_NAME:$IMAGE_TAG" .

# Tag image for VK Cloud Registry
echo "🏷️ Tagging image for VK Cloud Registry..."
docker tag "$IMAGE_NAME:$IMAGE_TAG" "$REGISTRY_URL/$IMAGE_NAME:$IMAGE_TAG"

# Push image to VK Cloud Registry
echo "📤 Pushing image to VK Cloud Registry..."
docker push "$REGISTRY_URL/$IMAGE_NAME:$IMAGE_TAG"

# Deploy to VK Cloud
echo "🚀 Deploying to VK Cloud..."
curl -X POST "$DEPLOY_URL" \
    -H "Authorization: Bearer $TOKEN" \
    -H "Content-Type: application/json" \
    -d "{\"image\":\"$REGISTRY_URL/$IMAGE_NAME:$IMAGE_TAG\"}"

echo "✅ VK Cloud Container Registry deployment completed!"
echo "🔗 Image URL: $REGISTRY_URL/$IMAGE_NAME:$IMAGE_TAG"

echo "🎉 VK Cloud deployment completed!"
```

### VK Cloud Storage Deployment
```bash
#!/bin/bash
# deploy-vk-storage.sh

set -e

# Configuration
STORAGE_URL="${VK_CLOUD_STORAGE_URL}"
TOKEN="${VK_CLOUD_TOKEN}"

echo "🚀 Deploying to VK Cloud Storage..."

# Build web application
echo "🔨 Building web application..."
flutter build web --web-renderer canvaskit --release

# Deploy files to VK Cloud Storage
echo "📤 Deploying files to VK Cloud Storage..."

# Upload main files
curl -X POST "$STORAGE_URL" \
    -H "Authorization: Bearer $TOKEN" \
    -F "file=@build/web/index.html"

curl -X POST "$STORAGE_URL" \
    -H "Authorization: Bearer $TOKEN" \
    -F "file=@build/web/main.dart.js"

# Upload assets
for file in build/web/assets/*; do
    if [ -f "$file" ]; then
        curl -X POST "$STORAGE_URL" \
            -H "Authorization: Bearer $TOKEN" \
            -F "file=@$file"
    fi
done

# Upload other static files
for file in build/web/*.json build/web/*.ico build/web/*.png; do
    if [ -f "$file" ]; then
        curl -X POST "$STORAGE_URL" \
            -H "Authorization: Bearer $TOKEN" \
            -F "file=@$file"
    fi
done

echo "✅ VK Cloud Storage deployment completed!"

echo "🎉 VK Cloud Storage deployment completed!"
```

## Selectel Cloud Deployment Scripts

### Selectel Cloud Storage Deployment
```bash
#!/bin/bash
# deploy-selectel-storage.sh

set -e

# Configuration
SELECTEL_USERNAME="${SELECTEL_USERNAME}"
SELECTEL_PASSWORD="${SELECTEL_PASSWORD}"
SELECTEL_CONTAINER="${SELECTEL_CONTAINER}"
SELECTEL_TOKEN="${SELECTEL_TOKEN}"

echo "🚀 Deploying to Selectel Cloud Storage..."

# Install Selectel Storage CLI
if ! command -v selectel-storage &> /dev/null; then
    echo "📦 Installing Selectel Storage CLI..."
    pip install selectel-storage-cli
fi

# Create Selectel configuration
echo "🔧 Creating Selectel configuration..."
mkdir -p ~/.config/selectel
cat > ~/.config/selectel/config.yaml << EOF
auth_url: https://api.selcdn.ru
username: $SELECTEL_USERNAME
password: $SELECTEL_PASSWORD
container_name: $SELECTEL_CONTAINER
EOF

# Build web application
echo "🔨 Building web application..."
flutter build web --web-renderer canvaskit --release

# Upload files to Selectel Storage
echo "📤 Uploading files to Selectel Storage..."
selectel-storage upload \
    --source build/web/ \
    --destination / \
    --recursive

# Setup CDN
echo "⚡ Setting up CDN..."
curl -X POST "https://api.selcdn.ru/v1/containers/$SELECTEL_CONTAINER/cdn/invalidate" \
    -H "X-Auth-Token: $SELECTEL_TOKEN" \
    -H "Content-Type: application/json" \
    -d '{"paths": ["/*"]}'

echo "✅ Selectel Cloud Storage deployment completed!"
echo "🔗 Storage URL: https://$SELECTEL_CONTAINER.selcdn.ru"

echo "🎉 Selectel Cloud deployment completed!"
```

### Selectel Cloud Server Deployment
```bash
#!/bin/bash
# deploy-selectel-server.sh

set -e

# Configuration
SERVER_IP="${SELECTEL_SERVER_IP}"
SSH_USER="${SELECTEL_SSH_USER}"
SSH_KEY="${SELECTEL_SSH_KEY}"
DEPLOY_PATH="/var/www/space-invaders"

echo "🚀 Deploying to Selectel Cloud Server..."

# Setup SSH agent
echo "🔐 Setting up SSH agent..."
eval $(ssh-agent -s)
ssh-add "$SSH_KEY"

# Deploy to server
echo "📤 Deploying to server..."
ssh "$SSH_USER@$SERVER_IP" << EOF
    set -e
    
    # Navigate to deployment directory
    cd $DEPLOY_PATH
    
    # Pull latest changes
    git pull origin main
    
    # Install dependencies
    flutter pub get
    
    # Build web application
    flutter build web --web-renderer canvaskit --release
    
    # Restart web server
    sudo systemctl reload nginx
    
    # Check service status
    sudo systemctl status nginx
EOF

# Health check
echo "🏥 Performing health check..."
if curl -f "https://$SERVER_IP/health"; then
    echo "✅ Health check passed!"
else
    echo "❌ Health check failed!"
    exit 1
fi

echo "✅ Selectel Cloud Server deployment completed!"
echo "🔗 Application URL: https://$SERVER_IP"

echo "🎉 Selectel Cloud Server deployment completed!"
```

## Multi-Cloud Deployment Script

### Multi-Cloud Deployment Orchestrator
```bash
#!/bin/bash
# deploy-multi-cloud.sh

set -e

# Configuration
CLOUD_PROVIDERS="${CLOUD_PROVIDERS:-yandex,vk,selectel}"
PARALLEL_DEPLOY="${PARALLEL_DEPLOY:-false}"
HEALTH_CHECK_TIMEOUT="${HEALTH_CHECK_TIMEOUT:-300}"

echo "🚀 Starting multi-cloud deployment..."
echo "📋 Cloud providers: $CLOUD_PROVIDERS"
echo "⚡ Parallel deployment: $PARALLEL_DEPLOY"

# Build web application
echo "🔨 Building web application..."
flutter build web --web-renderer canvaskit --release

# Function to deploy to a specific cloud provider
deploy_to_cloud() {
    local provider=$1
    echo "📤 Deploying to $provider cloud..."
    
    case "$provider" in
        "yandex")
            ./scripts/deploy-yandex-storage.sh
            ;;
        "vk")
            ./scripts/deploy-vk-storage.sh
            ;;
        "selectel")
            ./scripts/deploy-selectel-storage.sh
            ;;
        *)
            echo "❌ Unknown cloud provider: $provider"
            return 1
            ;;
    esac
    
    echo "✅ Deployment to $provider cloud completed!"
}

# Function to perform health check
health_check() {
    local provider=$1
    local url=$2
    local timeout=$3
    
    echo "🏥 Performing health check for $provider..."
    
    local start_time=$(date +%s)
    local end_time=$((start_time + timeout))
    
    while [ $(date +%s) -lt $end_time ]; do
        if curl -f "$url/health" &> /dev/null; then
            echo "✅ Health check passed for $provider!"
            return 0
        fi
        echo "⏳ Waiting for $provider to be healthy..."
        sleep 10
    done
    
    echo "❌ Health check failed for $provider!"
    return 1
}

# Deploy to all cloud providers
if [ "$PARALLEL_DEPLOY" = "true" ]; then
    echo "📤 Deploying to all cloud providers in parallel..."
    
    # Start parallel deployments
    pids=()
    for provider in $(echo "$CLOUD_PROVIDERS" | tr ',' ' '); do
        deploy_to_cloud "$provider" &
        pids+=($!)
    done
    
    # Wait for all deployments to complete
    for pid in "${pids[@]}"; do
        if ! wait "$pid"; then
            echo "❌ One or more deployments failed!"
            exit 1
        fi
    done
    
    echo "✅ All parallel deployments completed!"
else
    echo "📤 Deploying to cloud providers sequentially..."
    
    for provider in $(echo "$CLOUD_PROVIDERS" | tr ',' ' '); do
        deploy_to_cloud "$provider"
    done
    
    echo "✅ All sequential deployments completed!"
fi

# Perform health checks
echo "🏥 Performing health checks..."

# Health check URLs (configure these based on your actual deployment URLs)
declare -A HEALTH_URLS=(
    ["yandex"]="https://space-invaders.yandexcloud.net"
    ["vk"]="https://space-invaders.vkcloud.com"
    ["selectel"]="https://space-invaders.selectel.ru"
)

for provider in $(echo "$CLOUD_PROVIDERS" | tr ',' ' '); do
    if [ -n "${HEALTH_URLS[$provider]}" ]; then
        health_check "$provider" "${HEALTH_URLS[$provider]}" "$HEALTH_CHECK_TIMEOUT"
    else
        echo "⚠️ No health check URL configured for $provider"
    fi
done

# Update DNS records
echo "🌐 Updating DNS records..."
./scripts/update-dns-records.sh

# Setup global CDN
echo "⚡ Setting up global CDN..."
./scripts/setup-global-cdn.sh

# Generate deployment report
echo "📊 Generating deployment report..."
cat > deployment-report.json << EOF
{
  "deployment": {
    "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
    "providers": ["$(echo "$CLOUD_PROVIDERS" | tr ',' '","')"],
    "parallel": $PARALLEL_DEPLOY,
    "status": "success",
    "health_checks": {
EOF

for provider in $(echo "$CLOUD_PROVIDERS" | tr ',' ' '); do
    echo "      \"$provider\": \"passed\"," >> deployment-report.json
done

sed -i '$ s/,$//' deployment-report.json

cat >> deployment-report.json << EOF
    }
  }
}
EOF

echo "✅ Multi-cloud deployment completed!"
echo "📊 Deployment report: deployment-report.json"

echo "🎉 Multi-cloud deployment completed successfully!"
```

## Monitoring and Alerting Scripts

### Multi-Cloud Monitoring
```bash
#!/bin/bash
# monitor-multi-cloud.sh

set -e

# Configuration
CLOUD_PROVIDERS="${CLOUD_PROVIDERS:-yandex,vk,selectel}"
ALERT_WEBHOOK_URL="${ALERT_WEBHOOK_URL}"
CHECK_INTERVAL="${CHECK_INTERVAL:-300}"  # 5 minutes

echo "🔍 Starting multi-cloud monitoring..."
echo "📋 Cloud providers: $CLOUD_PROVIDERS"
echo "⏱️ Check interval: $CHECK_INTERVAL seconds"

# Function to check cloud provider health
check_provider_health() {
    local provider=$1
    local url=$2
    
    echo "🏥 Checking $provider health..."
    
    if curl -f --max-time 30 "$url/health" &> /dev/null; then
        echo "✅ $provider is healthy"
        return 0
    else
        echo "❌ $provider is unhealthy"
        return 1
    fi
}

# Function to send alert
send_alert() {
    local provider=$1
    local status=$2
    local message=$3
    
    echo "🚨 Sending alert for $provider..."
    
    curl -X POST "$ALERT_WEBHOOK_URL" \
        -H "Content-Type: application/json" \
        -d "{
            \"text\": \"🚨 Cloud Provider Alert: $provider\",
            \"attachments\": [{
                \"color\": \"$status\",
                \"fields\": [{
                    \"title\": \"Provider\",
                    \"value\": \"$provider\",
                    \"short\": true
                }, {
                    \"title\": \"Status\",
                    \"value\": \"$message\",
                    \"short\": true
                }, {
                    \"title\": \"Time\",
                    \"value\": \"$(date -u +%Y-%m-%dT%H:%M:%SZ)\",
                    \"short\": true
                }]
            }]
        }"
}

# Health check URLs
declare -A HEALTH_URLS=(
    ["yandex"]="https://space-invaders.yandexcloud.net"
    ["vk"]="https://space-invaders.vkcloud.com"
    ["selectel"]="https://space-invaders.selectel.ru"
)

# Main monitoring loop
while true; do
    echo "🔍 Starting health check cycle..."
    
    for provider in $(echo "$CLOUD_PROVIDERS" | tr ',' ' '); do
        if [ -n "${HEALTH_URLS[$provider]}" ]; then
            if ! check_provider_health "$provider" "${HEALTH_URLS[$provider]}"; then
                send_alert "$provider" "danger" "Health check failed"
            fi
        else
            echo "⚠️ No health check URL configured for $provider"
        fi
    done
    
    echo "💤 Waiting for next check cycle..."
    sleep "$CHECK_INTERVAL"
done
```

### Multi-Cloud Backup
```bash
#!/bin/bash
# backup-multi-cloud.sh

set -e

# Configuration
CLOUD_PROVIDERS="${CLOUD_PROVIDERS:-yandex,vk,selectel}"
BACKUP_TYPE="${BACKUP_TYPE:-full}"
RETENTION_DAYS="${RETENTION_DAYS:-30}"

echo "💾 Starting multi-cloud backup..."
echo "📋 Cloud providers: $CLOUD_PROVIDERS"
echo "📦 Backup type: $BACKUP_TYPE"
echo "🗓️ Retention days: $RETENTION_DAYS"

# Function to backup to cloud provider
backup_to_cloud() {
    local provider=$1
    local backup_file=$2
    
    echo "💾 Backing up to $provider cloud..."
    
    case "$provider" in
        "yandex")
            yc storage s3 cp \
                --endpoint-url=https://storage.yandexcloud.net \
                "$backup_file" \
                s3://space-invaders-backups/
            ;;
        "vk")
            curl -X POST "$VK_CLOUD_STORAGE_URL" \
                -H "Authorization: Bearer $VK_CLOUD_TOKEN" \
                -F "file=@$backup_file"
            ;;
        "selectel")
            selectel-storage upload \
                --source "$backup_file" \
                --destination /backups/
            ;;
        *)
            echo "❌ Unknown cloud provider: $provider"
            return 1
            ;;
    esac
    
    echo "✅ Backup to $provider cloud completed!"
}

# Function to cleanup old backups
cleanup_old_backups() {
    local provider=$1
    
    echo "🧹 Cleaning up old backups for $provider..."
    
    case "$provider" in
        "yandex")
            yc storage s3 ls \
                --endpoint-url=https://storage.yandexcloud.net \
                s3://space-invaders-backups/ | \
            awk '$1 < "'$(date -d "$RETENTION_DAYS days ago" +%Y-%m-%d)'" {print $4}' | \
            xargs -I {} yc storage s3 rm \
                --endpoint-url=https://storage.yandexcloud.net \
                s3://space-invaders-backups/{}
            ;;
        "vk")
            echo "Cleanup for VK Cloud not implemented yet"
            ;;
        "selectel")
            echo "Cleanup for Selectel not implemented yet"
            ;;
    esac
}

# Create backup
echo "📦 Creating backup..."
BACKUP_FILE="backup-$(date +%Y%m%d-%H%M%S).tar.gz"
tar -czf "$BACKUP_FILE" \
    --exclude='.git' \
    --exclude='build' \
    --exclude='.dart_tool' \
    --exclude='.pub-cache' \
    .

# Backup to all cloud providers
for provider in $(echo "$CLOUD_PROVIDERS" | tr ',' ' '); do
    backup_to_cloud "$provider" "$BACKUP_FILE"
    cleanup_old_backups "$provider"
done

# Cleanup local backup
rm "$BACKUP_FILE"

echo "✅ Multi-cloud backup completed!"
echo "🎉 All backups created and old backups cleaned up!"

# Send notification
if [ -n "$NOTIFICATION_WEBHOOK_URL" ]; then
    curl -X POST "$NOTIFICATION_WEBHOOK_URL" \
        -H "Content-Type: application/json" \
        -d "{
            \"text\": \"💾 Multi-cloud backup completed\",
            \"attachments\": [{
                \"color\": \"good\",
                \"fields\": [{
                    \"title\": \"Providers\",
                    \"value\": \"$CLOUD_PROVIDERS\",
                    \"short\": true
                }, {
                    \"title\": \"Backup Type\",
                    \"value\": \"$BACKUP_TYPE\",
                    \"short\": true
                }, {
                    \"title\": \"Time\",
                    \"value\": \"$(date -u +%Y-%m-%dT%H:%M:%SZ)\",
                    \"short\": true
                }]
            }]
        }"
fi
```

## Usage Instructions

### Environment Variables Setup
```bash
# Yandex Cloud
export YC_FOLDER_ID="your-folder-id"
export YC_SERVICE_ACCOUNT_KEY="path/to/service-account-key.json"
export YC_BUCKET_NAME="space-invaders-storage"

# VK Cloud
export VK_CLOUD_REGISTRY="registry.vkcloud.com"
export VK_CLOUD_USERNAME="your-username"
export VK_CLOUD_PASSWORD="your-password"
export VK_CLOUD_TOKEN="your-token"
export VK_CLOUD_STORAGE_URL="https://storage.vkcloud.com/upload"
export VK_CLOUD_DEPLOY_URL="https://deploy.vkcloud.com/api"

# Selectel
export SELECTEL_USERNAME="your-username"
export SELECTEL_PASSWORD="your-password"
export SELECTEL_CONTAINER="space-invaders"
export SELECTEL_TOKEN="your-token"
export SELECTEL_SERVER_IP="your-server-ip"
export SELECTEL_SSH_USER="your-ssh-user"
export SELECTEL_SSH_KEY="path/to/ssh-key"

# Monitoring
export ALERT_WEBHOOK_URL="https://hooks.slack.com/services/..."
export NOTIFICATION_WEBHOOK_URL="https://hooks.slack.com/services/..."
```

### Running Deployment Scripts
```bash
# Make scripts executable
chmod +x scripts/deploy-*.sh

# Deploy to specific cloud
./scripts/deploy-yandex-storage.sh
./scripts/deploy-vk-storage.sh
./scripts/deploy-selectel-storage.sh

# Multi-cloud deployment
export CLOUD_PROVIDERS="yandex,vk,selectel"
export PARALLEL_DEPLOY="true"
./scripts/deploy-multi-cloud.sh

# Monitoring
export CLOUD_PROVIDERS="yandex,vk,selectel"
export CHECK_INTERVAL="300"
./scripts/monitor-multi-cloud.sh

# Backup
export CLOUD_PROVIDERS="yandex,vk,selectel"
export RETENTION_DAYS="30"
./scripts/backup-multi-cloud.sh
```

These scripts provide comprehensive deployment and management capabilities for Russian cloud providers, with automated monitoring, backup, and alerting features.

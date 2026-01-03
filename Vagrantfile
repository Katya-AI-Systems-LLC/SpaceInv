# Vagrant Configuration for Space Invaders Development

Vagrant.configure("2") do |config|
  
  # Base box configuration
  config.vm.box = "ubuntu/focal64"
  config.vm.box_version = "2023.01.11.0"
  
  # Network configuration
  config.vm.network "forwarded_port", guest: 80, host: 8080
  config.vm.network "private_network", ip: "192.168.33.10"
  
  # VirtualBox specific configuration
  config.vm.provider "virtualbox" do |vb|
    vb.name = "space-invaders-dev"
    vb.memory = "4096"
    vb.cpus = "2"
    vb.customize ["modifyvm", :id, "--graphicscontroller", "vmsvga"]
    vb.customize ["modifyvm", :id, "--vram", "128"]
  end
  
  # Provisioning with shell script
  config.vm.provision "shell", inline: <<-SHELL
    # Update system
    sudo apt-get update
    sudo apt-get upgrade -y
    
    # Install required packages
    sudo apt-get install -y \
      curl \
      wget \
      git \
      unzip \
      build-essential \
      nginx \
      docker.io \
      docker-compose \
      python3-pip
    
    # Install Flutter
    sudo snap install flutter --classic
    
    # Install Chrome for testing
    sudo apt-get install -y \
      software-properties-common \
      apt-transport-https \
      ca-certificates \
      gnupg
    
    wget -q -O - https://dl.google.com/linux/linux_signing_key.pub | sudo apt-key add -
    echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" | sudo tee /etc/apt/sources.list.d/google-chrome.list
    sudo apt-get update
    sudo apt-get install -y google-chrome-stable
    
    # Install Node.js for tools
    curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
    sudo apt-get install -y nodejs
    
    # Install development tools
    sudo npm install -g @angular/cli
    sudo npm install -g typescript
    sudo npm install -g firebase-tools
    
    # Configure Docker
    sudo usermod -aG docker vagrant
    
    # Create project directory
    sudo mkdir -p /var/www/space-invaders
    sudo chown vagrant:vagrant /var/www/space-invaders
    
    # Clone the project
    cd /var/www/space-invaders
    git clone https://github.com/your-username/space-invaders.git .
    
    # Install Flutter dependencies
    flutter pub get
    
    # Build the project
    flutter build web --web-renderer canvaskit
    
    # Configure Nginx
    sudo rm /etc/nginx/sites-enabled/default
    sudo tee /etc/nginx/sites-available/space-invaders > /dev/null <<EOF
server {
    listen 80 default_server;
    server_name localhost;
    root /var/www/space-invaders/build/web;
    index index.html;
    
    location / {
        try_files \$uri \$uri/ /index.html;
    }
    
    location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg)$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
    }
}
EOF
    
    sudo ln -s /etc/nginx/sites-available/space-invaders /etc/nginx/sites-enabled/
    sudo nginx -t && sudo systemctl restart nginx
    
    # Create development scripts
    cat > /home/vagrant/dev-scripts.sh <<'EOF'
#!/bin/bash

# Development helper scripts for Space Invaders

# Function to start development server
start_dev() {
    echo "Starting Flutter development server..."
    cd /var/www/space-invaders
    flutter run -d chrome --web-port=3000
}

# Function to build project
build_project() {
    echo "Building Space Invaders..."
    cd /var/www/space-invaders
    flutter clean
    flutter pub get
    flutter build web --web-renderer canvaskit --release
}

# Function to run tests
run_tests() {
    echo "Running tests..."
    cd /var/www/space-invaders
    flutter test
}

# Function to analyze code
analyze_code() {
    echo "Analyzing code..."
    cd /var/www/space-invaders
    flutter analyze
}

# Function to deploy to staging
deploy_staging() {
    echo "Deploying to staging..."
    cd /var/www/space-invaders
    build_project
    sudo cp -r build/web/* /var/www/html/
}

# Function to show logs
show_logs() {
    echo "Showing Nginx logs..."
    sudo tail -f /var/log/nginx/access.log
}

# Function to restart services
restart_services() {
    echo "Restarting services..."
    sudo systemctl restart nginx
    sudo systemctl restart docker
}

# Main menu
case "$1" in
    start)
        start_dev
        ;;
    build)
        build_project
        ;;
    test)
        run_tests
        ;;
    analyze)
        analyze_code
        ;;
    deploy)
        deploy_staging
        ;;
    logs)
        show_logs
        ;;
    restart)
        restart_services
        ;;
    *)
        echo "Usage: $0 {start|build|test|analyze|deploy|logs|restart}"
        echo ""
        echo "Commands:"
        echo "  start    - Start Flutter development server"
        echo "  build    - Build the project"
        echo "  test     - Run tests"
        echo "  analyze  - Analyze code"
        echo "  deploy   - Deploy to staging"
        echo "  logs     - Show Nginx logs"
        echo "  restart  - Restart services"
        ;;
esac
EOF
    
    chmod +x /home/vagrant/dev-scripts.sh
    echo 'alias dev="/home/vagrant/dev-scripts.sh"' >> /home/vagrant/.bashrc
    
    # Create monitoring script
    cat > /home/vagrant/monitor.sh <<'EOF'
#!/bin/bash

# Monitor Space Invaders application

echo "=== Space Invaders Monitor ==="
echo "Time: $(date)"
echo ""

# Check if Nginx is running
if systemctl is-active --quiet nginx; then
    echo "✅ Nginx is running"
else
    echo "❌ Nginx is not running"
fi

# Check if Docker is running
if systemctl is-active --quiet docker; then
    echo "✅ Docker is running"
else
    echo "❌ Docker is not running"
fi

# Check if the application is accessible
if curl -s -o /dev/null -w "%{http_code}" http://localhost | grep -q "200"; then
    echo "✅ Application is accessible"
else
    echo "❌ Application is not accessible"
fi

# Show system resources
echo ""
echo "=== System Resources ==="
echo "CPU Usage: $(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | awk -F'%' '{print $1}')"
echo "Memory Usage: $(free -m | awk 'NR==2{printf "%.1f%%", $3*100/$2}')"
echo "Disk Usage: $(df -h / | awk 'NR==2{print $5}')"

echo ""
echo "=== Docker Containers ==="
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
EOF
    
    chmod +x /home/vagrant/monitor.sh
    echo 'alias monitor="/home/vagrant/monitor.sh"' >> /home/vagrant/.bashrc
    
    echo "✅ Space Invaders development environment setup complete!"
    echo "🚀 Access the application at: http://localhost:8080"
    echo "📝 Use 'dev' command for development scripts"
    echo "📊 Use 'monitor' command for application monitoring"
  SHELL
  
  # Post-provision message
  config.vm.post_up_message = <<-MSG
    🚀 Space Invaders Development Environment Ready!
    
    📍 Access Information:
       Application: http://localhost:8080
       SSH: vagrant@192.168.33.10 (password: vagrant)
    
    🛠️ Development Commands:
       dev start    - Start Flutter development server
       dev build    - Build the project
       dev test     - Run tests
       dev analyze  - Analyze code
       dev deploy   - Deploy to staging
       dev logs     - Show Nginx logs
       dev restart  - Restart services
       
    📊 Monitoring:
       monitor      - Show application status and resources
    
    📁 Project Location:
       /var/www/space-invaders
    
    🎮 Happy coding!
  MSG
end

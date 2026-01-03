# Dockerfile for Space Invaders Enhanced Edition

# Use official Flutter image for building
FROM cirrusci/flutter:3.16.0 as builder

# Set working directory
WORKDIR /app

# Copy pubspec files
COPY pubspec.yaml pubspec.lock ./

# Download dependencies
RUN flutter pub get

# Copy source code
COPY . .

# Build web version
RUN flutter build web --web-renderer canvaskit --release --no-sound-null-safety

# Production stage
FROM nginx:alpine

# Copy built web files to nginx
COPY --from=builder /app/build/web /usr/share/nginx/html

# Copy nginx configuration
COPY nginx.conf /etc/nginx/nginx.conf

# Expose port 80
EXPOSE 80

# Start nginx
CMD ["nginx", "-g", "daemon off;"]

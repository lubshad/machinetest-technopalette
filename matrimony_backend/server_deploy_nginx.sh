#!/bin/bash

# Server Nginx Deployment Script for Umatrimony Backend
# Run this script on your server

set -e

echo "🚀 Deploying Nginx Configuration..."

# Configuration
NGINX_CONFIG_FILE="nginx_configuration.conf"
NGINX_SITES_AVAILABLE="/etc/nginx/sites-available/matrimony_backend"
NGINX_SITES_ENABLED="/etc/nginx/sites-enabled/"
OLD_CONFIG="/etc/nginx/sites-enabled/matrimony_backend"

# Copy configuration
echo "📁 Copying nginx configuration..."
sudo cp "$NGINX_CONFIG_FILE" "$NGINX_SITES_AVAILABLE"

# Remove old symlink
if [ -L "$OLD_CONFIG" ]; then
    echo "🗑️  Removing old symlink..."
    sudo rm "$OLD_CONFIG"
fi

# Create new symlink
echo "🔗 Creating symlink..."
sudo ln -sf "$NGINX_SITES_AVAILABLE" "$NGINX_SITES_ENABLED"

# Test and reload
echo "🧪 Testing nginx configuration..."
sudo nginx -t

echo "🔄 Reloading nginx..."
sudo systemctl reload nginx

echo "✅ Nginx deployment complete!"
echo "Test: curl -I http://matrimony.coreaxissolutions.in/health/"

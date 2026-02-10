#!/bin/bash

# Server Gunicorn Deployment Script for Umatrimony Backend
# Run this script on your server

set -e

echo "🚀 Deploying Gunicorn Configuration..."

# Configuration
GUNICORN_CONFIG_FILE="gunicorn.conf.py"
SOCKET_DIR="/run/matrimony_backend"
SOCKET_FILE="$SOCKET_DIR/gunicorn.sock"
PROJECT_DIR="/home/matrimonyuser/matrimony_backend"

# Create socket directory
echo "📁 Creating socket directory..."
sudo mkdir -p "$SOCKET_DIR"
sudo chown matrimonyuser:matrimonyuser "$SOCKET_DIR"
sudo chmod 755 "$SOCKET_DIR"

# Copy configuration
echo "📁 Copying gunicorn configuration..."
sudo chown matrimonyuser:matrimonyuser "$PROJECT_DIR/$GUNICORN_CONFIG_FILE"

# Copy and enable systemd service and socket files
echo "📁 Setting up systemd service and socket..."
sudo cp gunicorn.service /etc/systemd/system/
sudo cp gunicorn.socket /etc/systemd/system/

# Reload systemd daemon
sudo systemctl daemon-reload

# Enable and start socket
echo "🔌 Enabling and starting gunicorn socket..."
sudo systemctl enable gunicorn.socket
sudo systemctl start gunicorn.socket

# Enable and start service
echo "⚙️ Enabling and starting gunicorn service..."
sudo systemctl enable gunicorn.service
sudo systemctl start gunicorn.service

# Restart gunicorn (if already running)
echo "🔄 Restarting gunicorn..."
sudo systemctl restart gunicorn.service

# Wait for socket creation
sleep 3

# Check socket
if [ -S "$SOCKET_FILE" ]; then
    echo "✅ Socket created: $SOCKET_FILE"
else
    echo "❌ Socket not created - checking status..."
    sudo systemctl status gunicorn.service
    exit 1
fi

# Reload nginx
echo "🔄 Reloading nginx..."
sudo systemctl reload nginx

echo "✅ Gunicorn deployment complete!"
echo "Socket: $SOCKET_FILE"
echo "Test: curl -I http://matrimony.coreaxissolutions.in/health/"

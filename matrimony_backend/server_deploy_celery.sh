#!/bin/bash

# Server Celery Deployment Script for matrimony_backend
# Run this script on your server

set -e

echo "🚀 Deploying Celery Configuration..."

# Configuration
PROJECT_DIR="/home/matrimony/matrimony_backend"

# Copy systemd service file
echo "📁 Setting up systemd service..."
sudo cp celery.service /etc/systemd/system/

# Reload systemd daemon
sudo systemctl daemon-reload

# Enable and start service
echo "⚙️ Enabling and starting celery service..."
sudo systemctl enable celery.service
sudo systemctl start celery.service

# Restart celery (if already running)
echo "🔄 Restarting celery..."
sudo systemctl restart celery.service

# Check status
echo "📊 Checking celery status..."
sudo systemctl status celery.service --no-pager

echo "✅ Celery deployment complete!"

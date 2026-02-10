#!/bin/bash

# Server Celery Beat Deployment Script for matrimony_backend
# Run this script on your server

set -e

echo "🚀 Deploying Celery Beat Configuration..."

# Configuration
PROJECT_DIR="/home/matrimony/matrimony_backend"

# Copy systemd service file
echo "📁 Setting up systemd service..."
sudo cp celery_beat.service /etc/systemd/system/

# Reload systemd daemon
sudo systemctl daemon-reload

# Enable and start service
echo "⚙️ Enabling and starting celery-beat service..."
sudo systemctl enable celery_beat.service
sudo systemctl start celery_beat.service

# Restart celery-beat (if already running)
echo "🔄 Restarting celery-beat..."
sudo systemctl restart celery_beat.service

# Check status
echo "📊 Checking celery-beat status..."
sudo systemctl status celery_beat.service --no-pager

echo "✅ Celery Beat deployment complete!"

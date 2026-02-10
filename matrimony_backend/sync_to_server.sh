#!/bin/bash

# Umatrimony Backend Sync Script
# This script syncs the local Django backend with the remote server

set -e  # Exit on any error

# Configuration
SERVER_HOST="matrimony.coreaxissolutions.in"
SERVER_USER="matrimonyuser"
SSH_KEY="matrimony_key"
REMOTE_PATH="~/matrimony_backend"
LOCAL_PATH="."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to check if SSH key exists
check_ssh_key() {
    if [ ! -f "$SSH_KEY" ]; then
        print_error "SSH key file '$SSH_KEY' not found!"
        print_status "Please ensure your SSH key is in the current directory"
        exit 1
    fi
}

# Function to test SSH connection
test_connection() {
    print_status "Testing SSH connection to $SERVER_USER@$SERVER_HOST..."
    if ssh -i "$SSH_KEY" -o ConnectTimeout=10 -o BatchMode=yes "$SERVER_USER@$SERVER_HOST" "echo 'Connection successful'" >/dev/null 2>&1; then
        print_success "SSH connection successful"
    else
        print_error "SSH connection failed!"
        print_status "Please check your SSH key and server details"
        exit 1
    fi
}

# Function to create remote directory if it doesn't exist
ensure_remote_directory() {
    print_status "Ensuring remote directory exists..."
    ssh -i "$SSH_KEY" "$SERVER_USER@$SERVER_HOST" "mkdir -p $REMOTE_PATH"
    print_success "Remote directory ready"
}

# Function to sync files using rsync
sync_files() {
    print_status "Syncing files to server..."
    
    # Create rsync exclude file
    cat > .rsync_exclude << EOF
# Python
__pycache__/
*.py[cod]
*\$py.class
*.so
.Python
build/
develop-eggs/
dist/
downloads/
eggs/
.eggs/
lib/
lib64/
parts/
sdist/
var/
wheels/
*.egg-info/
.installed.cfg
*.egg
MANIFEST

# Virtual environment
venv/
env/
.venv/
.env/
.env

# IDE
.vscode/
.idea/
*.swp
*.swo
*~

# OS
.DS_Store
Thumbs.db

# Django
*.log
db.sqlite3
db.sqlite3-journal
media/
staticfiles/

# Git
.git/

# Logs
logs/

# Backups
backups/
db_backups/
local_db_backup_*.sql.gz

# Test files
test_*.py

# Temporary files
*.tmp
*.temp

# Deployment scripts (include these)
!server_deploy_nginx.sh
!server_deploy_gunicorn.sh
!server_deploy_celery.sh
EOF

    # Sync files
    rsync -avz --delete \
        --exclude-from=.rsync_exclude \
        --progress \
        -e "ssh -i $SSH_KEY" \
        "$LOCAL_PATH/" \
        "$SERVER_USER@$SERVER_HOST:$REMOTE_PATH/"

    # Clean up exclude file
    rm .rsync_exclude
    
    print_success "Files synced successfully"
}

# Function to install/update dependencies on server
install_dependencies() {
    print_status "Installing/updating Python dependencies on server..."
    ssh -i "$SSH_KEY" "$SERVER_USER@$SERVER_HOST" "
        cd $REMOTE_PATH && 
        if [ -f requirements.txt ]; then
            # Check if virtual environment exists, create if not
            if [ ! -d 'venv' ]; then
                echo 'Creating virtual environment...'
                python3 -m venv venv
            fi
            
            # Activate virtual environment and install dependencies
            source venv/bin/activate && pip install -r requirements.txt --upgrade
        else
            echo 'No requirements.txt found'
        fi
    "
    print_success "Dependencies updated"
}

# Function to run Django migrations
run_migrations() {
    print_status "Running Django migrations on server..."
    ssh -i "$SSH_KEY" "$SERVER_USER@$SERVER_HOST" "
        cd $REMOTE_PATH && 
        source venv/bin/activate && python manage.py migrate --noinput
    "
    print_success "Migrations completed"
}

# Function to collect static files
collect_static() {
    print_status "Collecting static files on server..."
    ssh -i "$SSH_KEY" "$SERVER_USER@$SERVER_HOST" "
        cd $REMOTE_PATH && 
        source venv/bin/activate && python manage.py collectstatic --noinput
    "
    print_success "Static files collected"
}

# Function to restart services
restart_services() {
    print_status "Restarting services on server..."
    ssh -i "$SSH_KEY" "root@$SERVER_HOST" "
        # Restart gunicorn if running
        if systemctl is-active --quiet gunicorn; then
            sudo systemctl restart gunicorn
            echo 'Gunicorn restarted'
        fi
        
        # Restart nginx if running
        if systemctl is-active --quiet nginx; then
            sudo systemctl restart nginx
            echo 'Nginx restarted'
        fi

        # Restart celery if running
        if systemctl is-active --quiet celery; then
            sudo systemctl restart celery
            echo 'Celery restarted'
        fi

        # Restart celery beat if running
        if systemctl is-active --quiet celery_beat; then
            sudo systemctl restart celery_beat
            echo 'Celery beat restarted'
        fi
    "
    print_success "Services restarted"
}

# Function to deploy nginx configuration
deploy_nginx() {
    print_status "Deploying Nginx configuration on server..."
    ssh -i "$SSH_KEY" "$SERVER_USER@$SERVER_HOST" "
        cd $REMOTE_PATH && 
        if [ -f 'server_deploy_nginx.sh' ]; then
            chmod +x server_deploy_nginx.sh
            ./server_deploy_nginx.sh
        else
            echo 'server_deploy_nginx.sh not found'
        fi
    "
    print_success "Nginx deployment completed"
}

# Function to deploy gunicorn configuration
deploy_gunicorn() {
    print_status "Deploying Gunicorn configuration on server..."
    ssh -i "$SSH_KEY" "$SERVER_USER@$SERVER_HOST" "
        cd $REMOTE_PATH && 
        if [ -f 'server_deploy_gunicorn.sh' ]; then
            chmod +x server_deploy_gunicorn.sh
            ./server_deploy_gunicorn.sh
        else
            echo 'server_deploy_gunicorn.sh not found'
        fi
    "
    print_success "Gunicorn deployment completed"
}

# Function to deploy celery configuration
deploy_celery() {
    print_status "Deploying Celery configuration on server..."
    ssh -i "$SSH_KEY" "$SERVER_USER@$SERVER_HOST" "
        cd $REMOTE_PATH && 
        if [ -f 'server_deploy_celery.sh' ]; then
            chmod +x server_deploy_celery.sh
            ./server_deploy_celery.sh
        else
            echo 'server_deploy_celery.sh not found'
        fi
    "
    print_success "Celery deployment completed"
}

# Function to show deployment status
show_status() {
    print_status "Checking deployment status..."
    ssh -i "$SSH_KEY" "$SERVER_USER@$SERVER_HOST" "
        echo '=== Service Status ==='
        systemctl is-active gunicorn && echo 'Gunicorn: Active' || echo 'Gunicorn: Inactive'
        systemctl is-active nginx && echo 'Nginx: Active' || echo 'Nginx: Inactive'
        systemctl is-active celery && echo 'Celery: Active' || echo 'Celery: Inactive'
    "
}

# Main deployment function
deploy() {
    print_status "Starting deployment to $SERVER_HOST..."
    
    check_ssh_key
    test_connection
    ensure_remote_directory
    sync_files
    install_dependencies
    run_migrations
    collect_static
    restart_services
    show_status
    
    print_success "Deployment completed successfully!"
    print_status "Your Django backend is now live on the server"
}

# Function to show help
show_help() {
    echo "Umatrimony Backend Sync Script"
    echo ""
    echo "Usage: $0 [OPTION]"
    echo ""
    echo "Options:"
    echo "  deploy, -d         Full deployment (sync, install, migrate, restart)"
    echo "  sync, -s           Sync files only"
    echo "  install, -i        Install/update dependencies only"
    echo "  migrate, -m         Run migrations only"
    echo "  restart, -r         Restart services only"
    echo "  deploy-nginx, -dn  Deploy nginx configuration only"
    echo "  deploy-gunicorn, -dg Deploy gunicorn configuration only"
    echo "  deploy-celery, -dc  Deploy celery configuration only"
    echo "  status, -st         Show deployment status"
    echo "  help, -h            Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 deploy           # Full deployment"
    echo "  $0 sync             # Sync files only"
    echo "  $0 install          # Install dependencies only"
    echo "  $0 deploy-nginx     # Deploy nginx config only"
    echo "  $0 deploy-gunicorn  # Deploy gunicorn config only"
    echo "  $0 deploy-celery    # Deploy celery config only"
    echo "  $0 status           # Check status"
}

# Parse command line arguments
case "${1:-deploy}" in
    "deploy"|"-d"|"")
        deploy
        ;;
    "sync"|"-s")
        check_ssh_key
        test_connection
        ensure_remote_directory
        sync_files
        print_success "Files synced successfully"
        ;;
    "install"|"-i")
        check_ssh_key
        test_connection
        install_dependencies
        ;;
    "migrate"|"-m")
        check_ssh_key
        test_connection
        run_migrations
        ;;
    "restart"|"-r")
        check_ssh_key
        test_connection
        restart_services
        ;;
    "deploy-nginx"|"-dn")
        check_ssh_key
        test_connection
        ensure_remote_directory
        sync_files
        deploy_nginx
        ;;
    "deploy-gunicorn"|"-dg")
        check_ssh_key
        test_connection
        ensure_remote_directory
        sync_files
        deploy_gunicorn
        ;;
    "deploy-celery"|"-dc")
        check_ssh_key
        test_connection
        ensure_remote_directory
        sync_files
        deploy_celery
        ;;
    "status"|"-st")
        check_ssh_key
        test_connection
        show_status
        ;;
    "help"|"-h")
        show_help
        ;;
    *)
        print_error "Unknown option: $1"
        show_help
        exit 1
        ;;
esac

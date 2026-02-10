#!/bin/bash

# Umatrimony Backend Database Backup Manager Script
# This script handles database backup creation, rotation, and synchronization between server and local

set -e  # Exit on any error

# Configuration
SERVER_HOST="api.matrimony.com"
SERVER_USER="matrimony"
SSH_KEY="matrimony_key"
REMOTE_PATH="~/matrimony_backend"
LOCAL_PATH="."
BACKUP_DIR="backups"
MAX_BACKUPS=30
DB_NAME="matrimony_db"
DB_USER="matrimony_user"
DB_HOST="localhost"
DB_PORT="5432"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
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

print_backup() {
    echo -e "${CYAN}[BACKUP]${NC} $1"
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

# Function to get current timestamp
get_timestamp() {
    date +"%Y%m%d_%H%M%S"
}

# Function to create database backup on server
create_server_db_backup() {
    local timestamp=$(get_timestamp)
    local backup_name="matrimony_db_backup_${timestamp}.sql"
    local remote_backup_path="$REMOTE_PATH/$BACKUP_DIR"
    
    print_backup "Creating database backup on server: $backup_name"
    
    # Create backup directory on server if it doesn't exist
    ssh -i "$SSH_KEY" "$SERVER_USER@$SERVER_HOST" "mkdir -p $remote_backup_path"
    
    # Create PostgreSQL database backup
    ssh -i "$SSH_KEY" "$SERVER_USER@$SERVER_HOST" "
        cd $REMOTE_PATH
        
        # Check if PostgreSQL is available
        if command -v pg_dump >/dev/null 2>&1; then
            echo 'Using PostgreSQL dump...'
            # Use environment variables for database credentials
            export PGPASSWORD=\${DB_PASSWORD:-matrimony_password}
            pg_dump -h $DB_HOST -U $DB_USER -d $DB_NAME > $remote_backup_path/$backup_name
        else
            echo 'PostgreSQL dump tool not found!'
            exit 1
        fi
        
        # Compress the backup
        gzip $remote_backup_path/$backup_name
        echo 'Database backup compressed'
    "
    
    print_success "Server database backup created: $backup_name.gz"
    echo "$backup_name.gz"
}

# Function to rotate database backups on server (keep only MAX_BACKUPS)
rotate_server_backups() {
    print_backup "Rotating server database backups (keeping $MAX_BACKUPS most recent)..."
    
    ssh -i "$SSH_KEY" "$SERVER_USER@$SERVER_HOST" "
        cd $REMOTE_PATH/$BACKUP_DIR
        # Count total backups
        backup_count=\$(ls -1 matrimony_db_backup_*.sql.gz 2>/dev/null | wc -l)
        
        if [ \$backup_count -gt $MAX_BACKUPS ]; then
            # Get list of backups sorted by date (oldest first)
            ls -1t matrimony_db_backup_*.sql.gz | tail -n +\$((MAX_BACKUPS + 1)) | while read backup; do
                echo \"Removing old database backup: \$backup\"
                rm -f \"\$backup\"
            done
            echo \"Database backup rotation completed\"
        else
            echo \"No rotation needed (\$backup_count backups, max: $MAX_BACKUPS)\"
        fi
    "
    
    print_success "Server database backup rotation completed"
}

# Function to list server database backups
list_server_backups() {
    print_status "Listing server database backups..."
    
    ssh -i "$SSH_KEY" "$SERVER_USER@$SERVER_HOST" "
        cd $REMOTE_PATH/$BACKUP_DIR
        echo '=== Server Database Backups ==='
        ls -lh matrimony_db_backup_*.sql.gz 2>/dev/null | sort -k9 -r || echo 'No database backups found'
    "
}

# Function to get latest database backup from server
get_latest_server_backup() {
    ssh -i "$SSH_KEY" "$SERVER_USER@$SERVER_HOST" "
        cd $REMOTE_PATH/$BACKUP_DIR
        ls -1t matrimony_db_backup_*.sql.gz 2>/dev/null | head -n1
    "
}

# Function to sync local database with latest server backup
sync_local_database() {
    local latest_backup=$(get_latest_server_backup)
    
    if [ -z "$latest_backup" ]; then
        print_error "No database backups found on server!"
        return 1
    fi
    
    print_backup "Syncing local database with server backup: $latest_backup"
    
    # Create temporary directory for download
    local temp_dir=$(mktemp -d)
    local temp_backup="$temp_dir/$latest_backup"
    
    # Download backup from server
    scp -i "$SSH_KEY" "$SERVER_USER@$SERVER_HOST:$REMOTE_PATH/$BACKUP_DIR/$latest_backup" "$temp_backup"
    
    print_status "Database backup downloaded to temporary location"
    
    # Extract the backup
    gunzip "$temp_backup"
    local sql_file="${temp_backup%.gz}"
    
    # Backup current local database if it exists
    if command -v pg_dump >/dev/null 2>&1; then
        # Create backups directory if it doesn't exist
        mkdir -p "$BACKUP_DIR"
        
        local current_backup="$BACKUP_DIR/local_db_backup_$(get_timestamp).sql"
        export PGPASSWORD=${DB_PASSWORD:-matrimony_password}
        pg_dump -h $DB_HOST -U $DB_USER -d $DB_NAME > "$current_backup"
        gzip "$current_backup"
        print_status "Current local database backed up as: $current_backup.gz"
    fi
    
    # Restore PostgreSQL database
    if [ -f "$sql_file" ]; then
        print_status "Restoring PostgreSQL database from server backup..."
        
        # Check if psql is available
        if command -v psql >/dev/null 2>&1; then
            # Set password environment variable
            export PGPASSWORD=${DB_PASSWORD:-matrimony_password}
            
            # Drop and recreate database (optional - comment out if you want to keep existing data)
            print_warning "This will replace your local database with server data!"
            read -p "Continue? (y/N): " -n 1 -r
            echo
            
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                # Clear existing data and restore from backup
                # First, drop all tables and recreate them
                print_status "Clearing existing database data..."
                
                # Get list of tables and drop them
                psql -h $DB_HOST -U $DB_USER -d $DB_NAME -c "
                    DO \$\$ DECLARE
                        r RECORD;
                    BEGIN
                        FOR r IN (SELECT tablename FROM pg_tables WHERE schemaname = 'public') LOOP
                            EXECUTE 'DROP TABLE IF EXISTS ' || quote_ident(r.tablename) || ' CASCADE';
                        END LOOP;
                    END \$\$;
                "
                
                # Restore from backup
                print_status "Restoring data from server backup..."
                psql -h $DB_HOST -U $DB_USER -d $DB_NAME < "$sql_file"
                
                print_success "Local PostgreSQL database restored from server backup"
            else
                print_status "Database restore cancelled"
                rm -rf "$temp_dir"
                return 1
            fi
        else
            print_error "PostgreSQL client (psql) not found!"
            rm -rf "$temp_dir"
            return 1
        fi
    else
        print_error "Failed to extract database backup"
        rm -rf "$temp_dir"
        return 1
    fi
    
    # Clean up temporary files
    rm -rf "$temp_dir"
    
    print_success "Database sync completed successfully"
}

# Function to create local database backup (before sync)
create_local_db_backup() {
    local timestamp=$(get_timestamp)
    local backup_name="$BACKUP_DIR/local_db_backup_${timestamp}.sql"
    
    # Create backups directory if it doesn't exist
    mkdir -p "$BACKUP_DIR"
    
    if command -v pg_dump >/dev/null 2>&1; then
        print_backup "Creating local PostgreSQL database backup: $backup_name"
        export PGPASSWORD=${DB_PASSWORD:-matrimony_password}
        pg_dump -h $DB_HOST -U $DB_USER -d $DB_NAME > "$backup_name"
        gzip "$backup_name"
        print_success "Local database backup created: $backup_name.gz"
        echo "$backup_name.gz"
    else
        print_warning "PostgreSQL client not available for local backup"
        return 1
    fi
}

# Function to show database backup status
show_backup_status() {
    print_status "Database Backup Status Summary"
    echo "===================================="
    
    # Server status
    echo -e "\n${CYAN}Server Database Backups:${NC}"
    ssh -i "$SSH_KEY" "$SERVER_USER@$SERVER_HOST" "
        cd $REMOTE_PATH/$BACKUP_DIR 2>/dev/null || echo 'Backup directory not found'
        backup_count=\$(ls -1 matrimony_db_backup_*.sql.gz 2>/dev/null | wc -l)
        echo \"Total server database backups: \$backup_count\"
        if [ \$backup_count -gt 0 ]; then
            echo \"Latest server database backup:\"
            ls -1t matrimony_db_backup_*.sql.gz 2>/dev/null | head -n1
        fi
    "
    
    # Local database status
    echo -e "\n${CYAN}Local Database:${NC}"
    if command -v psql >/dev/null 2>&1; then
        export PGPASSWORD=${DB_PASSWORD:-matrimony_password}
        if psql -h $DB_HOST -U $DB_USER -d $DB_NAME -c "SELECT 1;" >/dev/null 2>&1; then
            echo "PostgreSQL database '$DB_NAME' is accessible"
            echo "Host: $DB_HOST, User: $DB_USER"
        else
            echo "PostgreSQL database '$DB_NAME' not accessible or doesn't exist"
        fi
    else
        echo "PostgreSQL client not available"
    fi
    
    # Local backup files
    if [ -d "$BACKUP_DIR" ]; then
        local backup_count=$(ls -1 "$BACKUP_DIR"/local_db_backup_*.sql.gz 2>/dev/null | wc -l)
        if [ $backup_count -gt 0 ]; then
            echo -e "\n${CYAN}Local Database Backups:${NC}"
            echo "Total local database backups: $backup_count"
            echo "Latest local database backup:"
            ls -1t "$BACKUP_DIR"/local_db_backup_*.sql.gz 2>/dev/null | head -n1
        fi
    fi
}

# Function to show help
show_help() {
    echo "Umatrimony Backend Database Backup Manager"
    echo ""
    echo "Usage: $0 [COMMAND]"
    echo ""
    echo "Commands:"
    echo "  create-server, -cs     Create database backup on server"
    echo "  sync-database, -sd     Sync local database with latest server backup"
    echo "  rotate, -ro            Rotate server backups (keep $MAX_BACKUPS)"
    echo "  list-server, -ls       List server database backups"
    echo "  status, -st            Show database backup status summary"
    echo "  full-sync, -fs         Create server backup + sync to local"
    echo "  help, -h               Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 create-server        # Create database backup on server"
    echo "  $0 sync-database         # Replace local DB with latest server backup"
    echo "  $0 full-sync             # Create server backup and sync to local"
    echo "  $0 status               # Show database backup status"
    echo ""
    echo "Configuration:"
    echo "  Server: $SERVER_USER@$SERVER_HOST"
    echo "  Database: $DB_NAME"
    echo "  Max Backups: $MAX_BACKUPS"
    echo "  Backup Directory: $BACKUP_DIR"
}

# Main function for full database sync process
full_sync() {
    print_status "Starting full database sync process..."
    
    check_ssh_key
    test_connection
    
    # Create server database backup
    local server_backup=$(create_server_db_backup)
    
    # Rotate backups
    rotate_server_backups
    
    # Sync local database with server backup
    sync_local_database
    
    print_success "Full database sync process completed!"
    print_status "Server database backup: $server_backup"
    print_status "Local database synced with server"
}

# Parse command line arguments
case "${1:-help}" in
    "create-server"|"-cs")
        check_ssh_key
        test_connection
        create_server_db_backup
        rotate_server_backups
        ;;
    "sync-database"|"-sd")
        check_ssh_key
        test_connection
        sync_local_database
        ;;
    "rotate"|"-ro")
        check_ssh_key
        test_connection
        rotate_server_backups
        ;;
    "list-server"|"-ls")
        check_ssh_key
        test_connection
        list_server_backups
        ;;
    "status"|"-st")
        check_ssh_key
        test_connection
        show_backup_status
        ;;
    "full-sync"|"-fs")
        full_sync
        ;;
    "help"|"-h")
        show_help
        ;;
    *)
        print_error "Unknown command: $1"
        show_help
        exit 1
        ;;
esac

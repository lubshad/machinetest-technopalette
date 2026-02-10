import multiprocessing
import os
from pathlib import Path

# Get the project base directory
BASE_DIR = Path(__file__).resolve().parent

# Calculate workers based on CPU cores
# Formula: (2 x num_cores) + 1 (recommended for CPU-bound applications)
# For I/O-bound applications, you can use: num_cores + 1
def get_workers():
    """Calculate the number of workers based on CPU cores"""
    cores = multiprocessing.cpu_count()
    # Use (2 x cores) + 1 for CPU-bound applications
    # For I/O-bound applications, use cores + 1
    return (2 * cores) + 1

# Server socket
# Use Unix socket for better performance
bind = "unix:/run/matrimony_backend/gunicorn.sock"
backlog = 2048

# Worker processes
workers = get_workers()
worker_class = "sync"
worker_connections = 1000
max_requests = 1000
max_requests_jitter = 50
preload_app = True
timeout = 30
keepalive = 2

# Logging
accesslog = os.path.join(BASE_DIR, "logs", "gunicorn_access.log")
errorlog = os.path.join(BASE_DIR, "logs", "gunicorn_error.log")
loglevel = "info"
access_log_format = '%(h)s %(l)s %(u)s %(t)s "%(r)s" %(s)s %(b)s "%(f)s" "%(a)s" %(D)s'

# Process naming
proc_name = "matrimony_backend"

# Server mechanics
daemon = False
pidfile = os.path.join(BASE_DIR, "gunicorn.pid")
user = "matrimonyuser"
group = "www-data"
umask = 0o007
tmp_upload_dir = None

# SSL (uncomment if using HTTPS)
# keyfile = "/path/to/keyfile"
# certfile = "/path/to/certfile"

# Worker timeout
graceful_timeout = 30

# Security
limit_request_line = 4094
limit_request_fields = 100
limit_request_field_size = 8190

# Debugging
reload = False
reload_engine = "auto"

# Server hooks
def on_starting(server):
    """Log when the server is starting"""
    server.log.info("Starting Umatrimony Backend server")

def on_reload(server):
    """Log when the server is reloading"""
    server.log.info("Reloading Umatrimony Backend server")

def worker_int(worker):
    """Log when a worker receives SIGINT or SIGQUIT"""
    worker.log.info("Worker received INT or QUIT signal")

def pre_fork(server, worker):
    """Log before forking a worker"""
    server.log.info("Worker spawned (pid: %s)", worker.pid)

def post_fork(server, worker):
    """Log after forking a worker"""
    server.log.info("Worker spawned (pid: %s)", worker.pid)

def post_worker_init(worker):
    """Log after a worker has been initialized"""
    worker.log.info("Worker initialized (pid: %s)", worker.pid)

def worker_abort(worker):
    """Log when a worker is aborted"""
    worker.log.info("Worker aborted (pid: %s)", worker.pid)

def pre_exec(server):
    """Log before exec"""
    server.log.info("Forked child, re-executing.")

def when_ready(server):
    """Log when the server is ready"""
    server.log.info("Server is ready. Spawning workers")

def worker_exit(server, worker):
    """Log when a worker exits"""
    server.log.info("Worker exited (pid: %s)", worker.pid)

def on_exit(server):
    """Log when the server exits"""
    server.log.info("Server exiting")

# Create logs directory if it doesn't exist
os.makedirs(os.path.join(BASE_DIR, "logs"), exist_ok=True)

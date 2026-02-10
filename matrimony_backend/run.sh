#!/usr/bin/env bash
set -Eeuo pipefail

# Move to the project root (directory of this script)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Configurable via env vars
PYTHON_BIN="${PYTHON_BIN:-python3}"
VENV_DIR="${VENV_DIR:-venv}"
HOST="${HOST:-0.0.0.0}"
PORT="${PORT:-8000}"

# Ensure virtual environment exists
if [[ ! -d "$VENV_DIR" ]]; then
  echo "[run.sh] Creating virtual environment at '$VENV_DIR'"
  "$PYTHON_BIN" -m venv "$VENV_DIR"
fi

# Activate virtual environment
source "$VENV_DIR/bin/activate"

# Upgrade pip and install dependencies if requirements exist
python -m pip install --upgrade pip >/dev/null
if [[ -f "requirements.txt" ]]; then
  echo "[run.sh] Installing dependencies from requirements.txt"
  pip install -r requirements.txt
fi

# Run database migrations
echo "[run.sh] Applying database migrations"
python manage.py migrate --noinput

# Determine address to bind
if [[ $# -gt 0 ]]; then
  ADDR="$1"
else
  ADDR="$HOST:$PORT"
fi

echo "[run.sh] Starting Django dev server at http://$ADDR"
exec python manage.py runserver "$ADDR"

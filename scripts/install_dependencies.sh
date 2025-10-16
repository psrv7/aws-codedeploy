#!/usr/bin/env bash
set -euo pipefail

APP_DIR="/opt/flaskdemo"
CODE_DIR="$APP_DIR/current"
VENV_DIR="$APP_DIR/venv"

command -v dnf >/dev/null 2>&1 && sudo dnf -y install python3 python3-pip

sudo mkdir -p "$APP_DIR"
sudo chown -R ec2-user:ec2-user "$APP_DIR"

python3 -m venv "$VENV_DIR"
source "$VENV_DIR/bin/activate"

pip install --upgrade pip
pip install -r "$CODE_DIR/requirements.txt"

sudo mkdir -p /var/log/flaskdemo
sudo chown ec2-user:ec2-user /var/log/flaskdemo

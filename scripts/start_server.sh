#!/usr/bin/env bash
set -euo pipefail

APP_DIR="/opt/flaskdemo"
CODE_DIR="$APP_DIR/current"
VENV_DIR="$APP_DIR/venv"
UNIT="/etc/systemd/system/flaskdemo.service"

sudo bash -c "cat > $UNIT" <<'UNIT'
[Unit]
Description=Gunicorn for Flask Demo
After=network.target

[Service]
Type=simple
User=ec2-user
WorkingDirectory=/opt/flaskdemo/current
ExecStart=/usr/bin/env bash -lc 'source /opt/flaskdemo/venv/bin/activate && exec gunicorn -w 2 -b 0.0.0.0:8000 app:app'
Restart=always
RestartSec=3

[Install]
WantedBy=multi-user.target
UNIT

sudo systemctl daemon-reload
sudo systemctl enable flaskdemo.service
sudo systemctl restart flaskdemo.service

#!/usr/bin/env bash
set -euo pipefail

if systemctl is-active --quiet flaskdemo.service; then
  sudo systemctl stop flaskdemo.service
fi

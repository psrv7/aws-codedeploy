#!/usr/bin/env bash
set -euo pipefail

for i in {1..10}; do
  if curl -fsS http://127.0.0.1:8000/health | grep -q '"ok"'; then
    echo "Service healthy"
    exit 0
  fi
  sleep 2
done

echo "Health check failed"
exit 1

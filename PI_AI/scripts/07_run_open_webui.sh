#!/usr/bin/env bash
# 07_run_open_webui.sh
# Pulls and starts the Open WebUI container, pointed at hailo-ollama.
# Source: https://www.raspberrypi.com/documentation/computers/ai.html#step4-llm
#
# PREREQUISITE: Docker installed (scripts/06_install_docker.sh) and
# hailo-ollama running and reachable on http://127.0.0.1:8000.
#
# Run this ON THE RASPBERRY PI.
set -euo pipefail

echo "== Pulling the Open WebUI image =="
docker pull ghcr.io/open-webui/open-webui:main

if docker ps -a --format '{{.Names}}' | grep -qx open-webui; then
  echo "== Existing 'open-webui' container found, removing it first =="
  docker rm -f open-webui
fi

echo "== Starting Open WebUI =="
docker run -d \
  --name open-webui \
  --network=host \
  --restart=always \
  -e OLLAMA_BASE_URL=http://127.0.0.1:8000 \
  -v open-webui:/app/backend/data \
  ghcr.io/open-webui/open-webui:main

echo
echo "Container starting. Watching logs (Ctrl+C to stop watching — the container keeps running):"
docker logs -f open-webui &
LOGS_PID=$!
sleep 15
kill "${LOGS_PID}" 2>/dev/null || true

echo
echo "Open WebUI should now be reachable at: http://<pi-hostname-or-ip>:8080"
echo "Do NOT port-forward 8080 to the public internet — see docs/05-service-hardening.md."

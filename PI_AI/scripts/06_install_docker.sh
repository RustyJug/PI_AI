#!/usr/bin/env bash
# 06_install_docker.sh
# Installs Docker Engine (Debian/Trixie), needed to run Open WebUI.
# Source: https://docs.docker.com/engine/install/debian/ and
#         https://www.raspberrypi.com/documentation/computers/ai.html#step3-llm
#
# Run this ON THE RASPBERRY PI.
# After it finishes, log out/in (or run `newgrp docker`) before using
# docker without sudo.
set -euo pipefail

echo "== Removing any conflicting old packages (ignore 'not installed' messages) =="
sudo apt remove -y docker.io docker-compose docker-doc podman-docker containerd runc 2>/dev/null || true

echo "== Adding Docker's official GPG key and apt source =="
sudo apt update
sudo apt install -y ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

CODENAME="$(. /etc/os-release && echo "${VERSION_CODENAME}")"
{
  echo "Types: deb"
  echo "URIs: https://download.docker.com/linux/debian"
  echo "Suites: ${CODENAME}"
  echo "Components: stable"
  echo "Signed-By: /etc/apt/keyrings/docker.asc"
} | sudo tee /etc/apt/sources.list.d/docker.sources

echo "== Installing Docker Engine =="
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
sudo systemctl enable --now docker

echo "== Adding $USER to the docker group =="
sudo groupadd docker 2>/dev/null || true
sudo usermod -aG docker "$USER"

echo
echo "Docker installed. Log out and back in (or run: newgrp docker), then verify with:"
echo "  docker run hello-world"
echo "Then continue with scripts/07_run_open_webui.sh"

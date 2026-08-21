# 04 — Docker and Open WebUI

Source: [Raspberry Pi — AI software, Steps 3–4 of "Run LLMs"](https://www.raspberrypi.com/documentation/computers/ai.html#step3-llm)
(official documentation, verified August 2026).

## Why Docker

Raspberry Pi OS Trixie ships Python 3.13. Open WebUI's recommended
install path is not compatible with Python 3.13 on the host, so it runs
in a Docker container instead — this avoids fighting Python versions on
the Pi itself.

## Step 1 — Install Docker Engine

Run `scripts/06_install_docker.sh`, which follows Docker's official
Debian install instructions:

```bash
# Remove old/conflicting packages, if any
sudo apt remove -y docker.io docker-compose docker-doc podman-docker containerd runc 2>/dev/null || true

# Add Docker's official GPG key and apt source
sudo apt update
sudo apt install -y ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

echo \
  "Types: deb
URIs: https://download.docker.com/linux/debian
Suites: $(. /etc/os-release && echo "$VERSION_CODENAME")
Components: stable
Signed-By: /etc/apt/keyrings/docker.asc" | sudo tee /etc/apt/sources.list.d/docker.sources

sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
sudo systemctl enable --now docker

# Let your user run docker without sudo
sudo groupadd docker 2>/dev/null || true
sudo usermod -aG docker "$USER"
```

**After this script finishes, log out and back in (or run `newgrp
docker`)** so your shell picks up the new group membership. Then verify:

```bash
docker run hello-world
```

## Step 2 — Run Open WebUI

Run `scripts/07_run_open_webui.sh`, which executes:

```bash
docker pull ghcr.io/open-webui/open-webui:main

docker run -d \
  --name open-webui \
  --network=host \
  --restart=always \
  -e OLLAMA_BASE_URL=http://127.0.0.1:8000 \
  -v open-webui:/app/backend/data \
  ghcr.io/open-webui/open-webui:main
```

Notes on the flags:

- `--network=host` is required so the container can reach `hailo-ollama`
  on `127.0.0.1:8000` on the Pi itself.
- `-e OLLAMA_BASE_URL=http://127.0.0.1:8000` points Open WebUI at the
  Hailo-Ollama backend instead of a real Ollama install (there isn't
  one — Hailo-Ollama is API-compatible, not the upstream Ollama binary).
- `-v open-webui:/app/backend/data` persists chat history, accounts, and
  settings in a named Docker volume across container restarts/upgrades.
- `--restart=always` brings Open WebUI back up automatically after a
  reboot.

Watch first-time startup (can take up to a minute):

```bash
docker logs -f open-webui
```

## Step 3 — First run

From another device on the same network, browse to:

```
http://<pi-hostname-or-ip>:8080
```

1. Create the first account — on a fresh Open WebUI instance, the first
   account created becomes the administrator.
2. If `hailo-ollama` isn't already running, start it (see
   `docs/05-service-hardening.md` to make this automatic).
3. If no model appears immediately: **Settings → Admin Settings →
   Connections**, add the Ollama API URL `http://localhost:8000`, set
   Connection Type to **Local** and Auth to **None**.
4. Select `qwen2.5-instruct:1.5b` from the model dropdown and send a test
   message.

## Alternative: docker-compose

`docker/docker-compose.yml` in this repo does the same `docker run`
above declaratively, if you'd rather manage it that way:

```bash
cd docker
docker compose up -d
```

Continue to `docs/05-service-hardening.md` to keep both services running
automatically and safely after a reboot.

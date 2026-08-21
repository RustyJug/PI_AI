# 05 — Running as a Service, and Network Safety

## Why this step exists

So far, `hailo-ollama` has been running in a foreground terminal — close
the SSH session and it dies. This step makes it a background service
that starts automatically on boot and restarts if it crashes.

## Step 1 — Find the hailo-ollama binary path

```bash
command -v hailo-ollama
```

Note the path it prints (typically `/usr/bin/hailo-ollama`). The unit
file below assumes this path — edit it if yours differs.

## Step 2 — Install the systemd user service

This repo's `systemd/hailo-ollama.service` is a **user** service (runs as
your own user, not root, since `hailo-ollama` needs no elevated
privileges to talk to the NPU device node once the kernel driver is
loaded).

```bash
mkdir -p ~/.config/systemd/user
cp systemd/hailo-ollama.service ~/.config/systemd/user/
systemctl --user daemon-reload
systemctl --user enable --now hailo-ollama
loginctl enable-linger "$USER"    # lets the service run even with nobody logged in
systemctl --user status hailo-ollama
```

Verify it's actually serving:

```bash
curl --silent http://localhost:8000/hailo/v1/list
```

## Step 3 — Open WebUI already restarts itself

The `docker run` command in `docs/04-docker-and-open-webui.md` included
`--restart=always`, so the container comes back up automatically after a
reboot as long as the Docker daemon itself is enabled — confirm with:

```bash
systemctl is-enabled docker
```

If it prints anything other than `enabled`, run:

```bash
sudo systemctl enable docker
```

## Network exposure — read before going further

**Do not port-forward 8080 (Open WebUI) or 8000 (Hailo-Ollama) through
your router to the public internet.** Open WebUI's own account system is
the only thing standing between the internet and your LLM once exposed,
and the Hailo-Ollama API (port 8000) has **no authentication at all** —
it is meant to be reached only from `localhost` or a trusted LAN.

If you want to reach the chat interface when away from home, use one of:

- **Tailscale** or **WireGuard** — puts your own devices on a private
  virtual network; no public port ever opens.
- **Raspberry Pi Connect** — Raspberry Pi's own remote-access service.

Both keep Open WebUI reachable only to devices you've explicitly
authorized, rather than the open internet.

Continue to `docs/06-verification-and-benchmarking.md`.

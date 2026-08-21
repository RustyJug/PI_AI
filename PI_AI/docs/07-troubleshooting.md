# 07 — Troubleshooting

## `hailortcli` reports no device / times out

- Power off completely (unplug, don't just reboot).
- Reseat the PCIe ribbon cable at both ends — check the retaining clips
  are fully closed and the metallic contacts face the correct direction
  (toward the USB ports at the Pi end).
- Confirm the power supply is the official 27 W unit or an equivalent
  high-quality supply; undervoltage can cause the NPU to fail to
  enumerate.
- Check `lspci | grep -i hailo` — if nothing shows up at all, the issue
  is physical/PCIe, not software.

## `hailo-all` / `hailo-h10-all` conflict

These two packages cannot be installed at the same time. If you're
migrating from an AI Kit or original AI HAT+:

```bash
sudo apt remove -y hailo-all hailo-dkms hailort hailo-tappas-core python3-hailort
sudo apt autoremove -y
sudo apt install -y dkms hailo-h10-all
sudo reboot
```

## Model pull fails or model not found

- Always use a model tag exactly as returned by
  `curl http://localhost:8000/hailo/v1/list` — tags are
  case-sensitive and version-specific (e.g. `qwen2.5-instruct:1.5b`).
- Confirm the Hailo GenAI Model Zoo package actually installed:
  `dpkg -l | grep hailo_gen_ai_model_zoo`.
- Check free disk space: `df -h` — models are 1.5–3 GB each.

## Open WebUI can't reach the backend

- Confirm `hailo-ollama` is actually running:
  `curl --silent http://localhost:8000/hailo/v1/list` from the Pi itself.
- Check container logs: `docker logs open-webui`.
- Confirm the container is using `--network=host` — without it, the
  container's `127.0.0.1` refers to itself, not the Pi, and it will
  never reach `hailo-ollama` on port 8000.
- In Open WebUI, double check **Settings → Admin Settings →
  Connections** has the right URL (`http://localhost:8000`), Connection
  Type **Local**, Auth **None**.

## Port conflicts

Default ports: `8000` (hailo-ollama), `8080` (open-webui). If something
else on the Pi already uses either port, either stop that service or
remap Open WebUI's port, e.g. `-p 8081:8080` instead of `--network=host`
(note: if you don't use host networking, add
`-e OLLAMA_BASE_URL=http://172.17.0.1:8000` or similar so the container
can still reach the host — host networking is simpler and is what the
scripts in this repo use).

## Inference is slow / inconsistent

- Check throttling: `vcgencmd get_throttled` (anything non-zero means
  the Pi hit a power or thermal limit at some point).
- Confirm both heatsinks are fitted (Active Cooler on the Pi, HAT
  heatsink on the AI HAT+ 2) and airflow isn't obstructed.
- Compare against the same prompt/model every time — TPS varies with
  prompt length and content.

## Docker permission denied

If `docker run hello-world` fails with a permissions error after
`scripts/06_install_docker.sh`:

```bash
newgrp docker
```

or fully log out and back in — group membership changes don't apply to
an already-open shell session.

## Still stuck

- Hailo Community Forum: <https://community.hailo.ai/>
- Hailo Developer Zone: <https://hailo.ai/developer-zone/>
- Raspberry Pi Forums: <https://forums.raspberrypi.com/>
- Open WebUI docs: <https://docs.openwebui.com/>

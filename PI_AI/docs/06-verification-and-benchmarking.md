# 06 — Verification and Benchmarking

Run `scripts/99_full_verification.sh` to execute all of the checks below
in sequence, or run them individually.

## Full pipeline checklist

| Check | Command | Expected result |
|---|---|---|
| NPU detected | `hailortcli fw-control identify` | `Device Architecture: HAILO10H` |
| Kernel driver loaded | `dmesg \| grep -i hailo` | Lines showing the driver probing and firmware loading successfully |
| PCIe link present | `lspci \| grep -i hailo` | One PCIe device listed |
| Hailo-Ollama serving | `curl --silent http://localhost:8000/hailo/v1/list` | JSON list of available models |
| Model pulled | Same list, or check `~/usr/share/hailo-ollama/models/blob/` | `qwen2.5-instruct:1.5b` present |
| Chat API working | `curl` to `/api/chat` (see `docs/03-genai-model-and-hailo-ollama.md`) | JSON reply from the model |
| Docker running | `docker ps` | `open-webui` container listed as `Up` |
| Open WebUI reachable | Browse to `http://<pi>:8080` | Chat UI loads, model selectable |
| hailo-ollama survives reboot | `systemctl --user status hailo-ollama` after a reboot | `active (running)` |

## What to record for a real benchmark

A "40 TOPS" headline number tells you nothing about your actual chat
experience. For a meaningful comparison (e.g., against CPU-only
inference, or a future model swap), record all of the following for the
**same prompt** each time:

- Time to first token (TTFT)
- Output tokens per second (TPS)
- Prompt length and output length
- Exact model name and Hailo GenAI Model Zoo package version
  (`dpkg -l | grep hailo_gen_ai_model_zoo`)
- Pi CPU temperature and throttling state during the run:

  ```bash
  watch -n 1 'vcgencmd measure_temp; vcgencmd get_throttled'
  ```

- Idle and load power draw, if you have a USB-C power meter

For reference, Hailo's own published figures for `Qwen2.5-1.5B-Instruct`
at a 2048-token context length are approximately: load time 5.2 s,
time-to-first-token 0.37 s, ~7.4 tokens/sec sustained. Treat these as a
ballpark, not a guarantee — your own run is the only number that matters
for your setup.

## Reading throttling status

`vcgencmd get_throttled` returns a hex bitmask. `0x0` means no issues.
Any non-zero value means the Pi has hit an under-voltage or thermal
limit at some point since boot — see `docs/07-troubleshooting.md` if you
see this during inference.

Continue to `docs/07-troubleshooting.md` for common failure modes, or
`docs/08-git-backup.md` to save this project to git.

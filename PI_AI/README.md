# PI_AI — Local AI Machine on Raspberry Pi 5 + Hailo AI HAT+ 2

A fully local, offline-capable chat AI running on a Raspberry Pi 5 with a
Hailo-10H NPU (Raspberry Pi **AI HAT+ 2**), served through **Hailo-Ollama**
(an Ollama-API-compatible backend) and a browser front end (**Open WebUI**).

> **Scope note:** This repository is a documented set of commands and
> configuration files meant to be run **on the physical Raspberry Pi**.
> Nobody assembling this remotely (including an AI assistant) can execute
> these on your hardware — you run each numbered script/command yourself,
> in order, and check the output against the "expected result" shown in
> each doc before moving on.

## Corrected assumptions (read this first)

The original spec named "Gwen3.2 3B" as the target model. That model name
does not exist anywhere (not in Alibaba's Qwen releases, not in Hailo's
GenAI Model Zoo). Two hard constraints narrow this down:

1. **The Hailo-10H NPU only runs models Hailo has specifically compiled**
   for it (`.hef` files), listed in the [Hailo GenAI Model
   Zoo](https://github.com/hailo-ai/hailo_model_zoo_genai). You cannot
   load an arbitrary GGUF or Hugging Face checkpoint onto the NPU.
2. **There is no 3B-parameter model in that zoo at all**, for any family.
   The largest LLM currently offered is `Qwen3-1.7B-Instruct`; the
   available Qwen2.5 model is `Qwen2.5-1.5B-Instruct`.

Given the choice to "target Qwen2.5" (closest real name to what was
requested), this project targets:

- **Model:** `qwen2.5-instruct:1.5b` (Qwen2.5-1.5B-Instruct, Apache-2.0,
  ~1.64 GB, compiled for Hailo-10H)
- **Confirm before you pull anything:** run `scripts/03_verify_hailo_hardware.sh`
  and then `curl http://localhost:8000/hailo/v1/list` yourself — the model
  list is served live by your installed package version and can change.
  If a 3B (or larger) Qwen model has since been added to the zoo, swap the
  `MODEL_TAG` variable in `scripts/05_pull_and_test_model.sh` for it.

## Hardware in this build

| Component | Notes |
|---|---|
| Raspberry Pi 5 | Any RAM variant; 8 GB+ recommended |
| Raspberry Pi AI HAT+ 2 | On-board **Hailo-10H** NPU, 40 TOPS INT4, 8 GB dedicated LPDDR4X (separate from Pi RAM) |
| Official 27 W USB-C PSU | Or equivalent high-quality supply |
| Raspberry Pi Active Cooler | Recommended, mounts on the Pi 5 |
| AI HAT+ 2 heatsink | Included with the HAT, recommended for sustained inference |
| 64-bit Raspberry Pi OS (Trixie) | Required — AI HAT+ 2 / Hailo-10H is not supported on Bookworm |
| ≥10 GB free storage | OS + Hailo packages + Docker image + model weights |

**Important:** AI HAT+ 2 uses the `Hailo-10H` chip and the `hailo-h10-all`
package. This is a **different, mutually-exclusive** software stack from
the older AI Kit / AI HAT+ (`Hailo-8L`/`Hailo-8`, package `hailo-all`).
If you have ever installed `hailo-all` on this Pi, remove it first (see
`docs/02-os-setup-and-drivers.md`).

## Repository layout

```
PI_AI/
├── README.md                        This file
├── docs/                            Full written documentation, one topic per file
│   ├── 00-overview-and-assumptions.md
│   ├── 01-hardware-assembly.md
│   ├── 02-os-setup-and-drivers.md
│   ├── 03-genai-model-and-hailo-ollama.md
│   ├── 04-docker-and-open-webui.md
│   ├── 05-service-hardening.md
│   ├── 06-verification-and-benchmarking.md
│   ├── 07-troubleshooting.md
│   └── 08-git-backup.md
├── scripts/                         Numbered shell scripts, run in order on the Pi
│   ├── 01_update_system.sh
│   ├── 02_install_hailo_h10_driver.sh
│   ├── 03_verify_hailo_hardware.sh
│   ├── 04_install_hailo_genai_model_zoo.sh
│   ├── 05_pull_and_test_model.sh
│   ├── 06_install_docker.sh
│   ├── 07_run_open_webui.sh
│   └── 99_full_verification.sh
├── systemd/
│   └── hailo-ollama.service         User service so the backend survives reboots
├── docker/
│   └── docker-compose.yml           Alternative to the raw `docker run` in the scripts
└── .gitignore
```

## Quick start

Run these **on the Raspberry Pi itself**, over SSH or a local terminal,
in this exact order. Each script prints what it's doing; read
`docs/0X-*.md` for the full explanation, expected output, and rollback
notes before running the matching script.

```bash
chmod +x scripts/*.sh

./scripts/01_update_system.sh          # OS + firmware update, reboot
./scripts/02_install_hailo_h10_driver.sh   # dkms + hailo-h10-all, reboot
./scripts/03_verify_hailo_hardware.sh      # confirms the NPU is detected
./scripts/04_install_hailo_genai_model_zoo.sh   # installs hailo-ollama
./scripts/05_pull_and_test_model.sh        # pulls qwen2.5-instruct:1.5b, sends a test prompt
./scripts/06_install_docker.sh             # Docker CE (needed for Open WebUI)
./scripts/07_run_open_webui.sh             # starts the Open WebUI container
```

Then open `http://<pi-hostname-or-ip>:8080` from another device on the
same network, create the admin account, and select `qwen2.5-instruct:1.5b`.

Do **not** port-forward 8080 to the public internet — see
`docs/05-service-hardening.md`.

## Backing this project up to a private Git repository

See `docs/08-git-backup.md`. In short, from the Pi (or wherever you have
push access configured):

```bash
git init
git add .
git commit -m "Initial commit: PI_AI local LLM build"
git branch -M main
git remote add origin https://github.com/RustyJug/PI_AI.git
git push -u origin main
```

No credentials, tokens, or SSH keys are embedded anywhere in this repo —
authenticate with your own GitHub account when you push.

## Primary sources used for this documentation

- Raspberry Pi official docs: [AI software](https://www.raspberrypi.com/documentation/computers/ai.html), [AI HATs](https://www.raspberrypi.com/documentation/accessories/ai-hat-plus.html)
- Hailo: [hailo_model_zoo_genai](https://github.com/hailo-ai/hailo_model_zoo_genai), [hailo-apps / Hailo-Ollama + Open WebUI guide](https://github.com/hailo-ai/hailo-apps/blob/main/hailo_apps/python/gen_ai_apps/hailo_ollama/README.md)
- [Open WebUI documentation](https://docs.openwebui.com/)
- [Docker Engine install docs (Debian)](https://docs.docker.com/engine/install/debian/)

All version numbers, package names, and URLs were verified against these
sources at the time this documentation was written (August 2026). Hailo's
model zoo and package versions change; **re-check the official AI software
page before running `scripts/04_install_hailo_genai_model_zoo.sh`** in case
the `.deb` URL or version number has moved on.

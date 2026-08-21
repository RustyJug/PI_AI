# 03 — Hailo GenAI Model Zoo, Hailo-Ollama, and the Qwen2.5 Model

Sources: [Raspberry Pi — AI software, "Run LLMs" section](https://www.raspberrypi.com/documentation/computers/ai.html#LLMs),
[hailo-ai/hailo_model_zoo_genai](https://github.com/hailo-ai/hailo_model_zoo_genai)
(verified August 2026).

## What this installs

The **Hailo GenAI Model Zoo** package provides `hailo-ollama`: a local
REST server (Ollama-API-compatible) that loads Hailo-compiled LLMs and
runs inference on the Hailo-10H NPU.

## Step 1 — Install the Hailo GenAI Model Zoo package

Run `scripts/04_install_hailo_genai_model_zoo.sh`.

This downloads and installs a specific versioned `.deb`:

```bash
wget -O hailo_gen_ai_model_zoo_5.1.1_arm64.deb \
  https://dev-public.hailo.ai/2025_12/Hailo10/hailo_gen_ai_model_zoo_5.1.1_arm64.deb
sudo dpkg -i hailo_gen_ai_model_zoo_5.1.1_arm64.deb
sudo apt --fix-broken install -y
```

**Before running this:** the package version and download URL change
over time. Check the current one at
<https://www.raspberrypi.com/documentation/computers/ai.html#step1-llm>
and update `HAILO_GENAI_DEB_URL` at the top of the script if it differs
from what's hardcoded there. As of this writing, versions 5.1.1, 5.2.0,
and 5.3.0 are all supported; the model list in
`docs/00-overview-and-assumptions.md` reflects the `main` branch of the
model zoo repo, some entries of which need ≥ 5.2.0 or ≥ 5.3.0.

## Step 2 — Start the Hailo-Ollama server

```bash
hailo-ollama
```

This blocks the terminal and listens on `http://localhost:8000`. Leave
it running (Step 4 in `docs/05-service-hardening.md` turns this into a
proper background service so you don't need a dedicated terminal open).

## Step 3 — List available models (do this every time before assuming a tag)

In a second terminal / SSH session:

```bash
curl --silent http://localhost:8000/hailo/v1/list
```

This is the authoritative, current list for your installed package
version — more current than any table in this repo.

## Step 4 — Pull the model

Run `scripts/05_pull_and_test_model.sh`, which executes:

```bash
curl --silent http://localhost:8000/api/pull \
  -H 'Content-Type: application/json' \
  -d '{ "model": "qwen2.5-instruct:1.5b", "stream": true }'
```

Models download to `~/usr/share/hailo-ollama/models/blob/`. The 1.5B
Qwen2.5 model is roughly 1.6 GB — expect a few minutes depending on your
network connection.

## Step 5 — Test the model

Still part of `scripts/05_pull_and_test_model.sh`:

```bash
curl --silent http://localhost:8000/api/chat \
  -H 'Content-Type: application/json' \
  -d '{
        "model": "qwen2.5-instruct:1.5b",
        "messages": [
          {"role": "user", "content": "In one sentence, what is a Raspberry Pi?"}
        ]
      }'
```

Expected result: a JSON response containing the model's reply. If this
works, the NPU pipeline is fully functional end to end and you're ready
for the Open WebUI frontend.

Continue to `docs/04-docker-and-open-webui.md`.

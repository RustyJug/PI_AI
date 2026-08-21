# 00 — Overview and Assumptions

## Goal

Build a self-contained, local AI machine:

- **Hardware:** Raspberry Pi 5 + Raspberry Pi AI HAT+ 2 (Hailo-10H NPU)
- **Inference backend:** Hailo-Ollama (Ollama-API-compatible server, part
  of Hailo's GenAI Model Zoo, running the NPU-compiled model)
- **Model:** `qwen2.5-instruct:1.5b` (Qwen2.5-1.5B-Instruct)
- **Frontend:** Open WebUI (browser-based chat interface, run in Docker)
- **Deliverables:** every command documented, and the whole project backed
  up to a private GitHub repository (`RustyJug/PI_AI`)

## Why "Qwen2.5-1.5B-Instruct" and not a 3B model

The original request named "Gwen3.2 3B." Investigating that name turned up
three separate facts worth recording, since they directly shaped the
model choice:

1. **No model called "Qwen3.2" exists.** Alibaba's Qwen releases jumped
   from Qwen3 (April 2025) to Qwen3.5, Qwen3.6, Qwen3.7, Qwen3.8 — there
   is no 3.1–3.4 generation.
2. **The Hailo-10H cannot run arbitrary models.** It only runs models
   Hailo has quantized and compiled to their `.hef` format, published in
   the [Hailo GenAI Model Zoo](https://github.com/hailo-ai/hailo_model_zoo_genai).
   A generic Hugging Face or GGUF checkpoint — even a real "Qwen3.x 3B" if
   one existed — cannot simply be copied onto the NPU.
3. **No 3B model exists in that zoo, for any model family, as of this
   writing.** The full LLM list (checked live against
   `hailo-ai/hailo_model_zoo_genai/docs/MODELS.rst`, `main` branch) is:

   | Model | Params | Size | Min. package version |
   |---|---|---|---|
   | DeepSeek-R1-Distill-Qwen-1.5B | 1.5B | 2.37 GB | ≥ 5.1.1 |
   | Llama3.2-1B-Instruct | 1B | 1.79 GB | ≥ 5.2.0 |
   | Qwen2-1.5B-Instruct | 1.5B | 1.56 GB | ≥ 5.1.1 |
   | Qwen2-1.5B-Instruct-Function-Calling-v1 | 1.5B | 2.99 GB | ≥ 5.2.0 |
   | **Qwen2.5-1.5B-Instruct** | **1.5B** | **1.64 GB** | **≥ 5.1.1** |
   | Qwen2.5-Coder-1.5B-Instruct | 1.5B | 1.64 GB | ≥ 5.1.1 |
   | Qwen3-1.7B-Instruct | 1.7B | 1.79 GB | ≥ 5.2.0 |
   | Qwen2-VL-2B-Instruct (VLM) | 2B | 2.18 GB | ≥ 5.2.0 |
   | Qwen3-VL-2B-Instruct (VLM) | 2B | 2.18 GB | ≥ 5.3.0 |
   | Whisper-Tiny/Base/Small (ASR) | 39M–244M | 78–388 MB | ≥ 5.2.0 |

   This list **will change** as Hailo adds models. Before pulling
   anything, always run the live list endpoint yourself:

   ```bash
   curl --silent http://localhost:8000/hailo/v1/list
   ```

   If a genuine 3B (or larger) Qwen entry appears there in the future,
   change `MODEL_TAG` in `scripts/05_pull_and_test_model.sh` to match it —
   nothing else in this repo needs to change.

## Hardware assumption

This documentation assumes you are starting from **zero**: no hardware
assembled, no OS installed. If you're further along, skip the
already-completed scripts/docs — each one states its own prerequisites
and how to verify they're already met.

## What this repo does NOT do

- It does not run any command on your behalf — you run the scripts
  yourself, on the Pi.
- It does not embed any credentials, API keys, or GitHub tokens.
- It does not open port 8080 (Open WebUI) to the public internet. See
  `docs/05-service-hardening.md` for why, and what to do if you want
  remote access.

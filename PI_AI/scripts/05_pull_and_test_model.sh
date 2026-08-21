#!/usr/bin/env bash
# 05_pull_and_test_model.sh
# Pulls the target LLM through hailo-ollama and sends one test prompt.
# Source: https://www.raspberrypi.com/documentation/computers/ai.html#step2-llm
#
# PREREQUISITE: hailo-ollama must already be running (in another
# terminal/session, or as the systemd service from
# docs/05-service-hardening.md):
#     hailo-ollama
#
# ** CHECK THIS BEFORE RUNNING **
# MODEL_TAG below is the closest real match to what was originally
# requested ("Gwen3.2 3B" — not a real model). As of August 2026, no 3B
# Qwen model exists in Hailo's GenAI Model Zoo for the Hailo-10H; this
# uses Qwen2.5-1.5B-Instruct instead. Run the list command below FIRST
# and change MODEL_TAG if something more suitable now exists.
set -euo pipefail

MODEL_TAG="qwen2.5-instruct:1.5b"
HAILO_OLLAMA_URL="http://localhost:8000"

echo "== Current available models (verify MODEL_TAG against this list) =="
curl --silent "${HAILO_OLLAMA_URL}/hailo/v1/list" | tee /tmp/hailo_model_list.json
echo
echo "Using MODEL_TAG=${MODEL_TAG}"
echo

echo "== Pulling ${MODEL_TAG} (this can take a few minutes) =="
curl --silent "${HAILO_OLLAMA_URL}/api/pull" \
  -H 'Content-Type: application/json' \
  -d "{\"model\": \"${MODEL_TAG}\", \"stream\": true}"
echo

echo "== Sending a test prompt =="
curl --silent "${HAILO_OLLAMA_URL}/api/chat" \
  -H 'Content-Type: application/json' \
  -d "{\"model\": \"${MODEL_TAG}\", \"messages\": [{\"role\": \"user\", \"content\": \"In one sentence, what is a Raspberry Pi?\"}]}"
echo
echo
echo "If you got a JSON reply above containing model output, the NPU pipeline works end to end."
echo "Continue with scripts/06_install_docker.sh for the Open WebUI frontend."

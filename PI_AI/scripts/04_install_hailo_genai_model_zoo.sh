#!/usr/bin/env bash
# 04_install_hailo_genai_model_zoo.sh
# Installs the Hailo GenAI Model Zoo package, which provides the
# hailo-ollama server and the compiled LLM/VLM/ASR models it can load.
# Source: https://www.raspberrypi.com/documentation/computers/ai.html#step1-llm
#
# ** CHECK THIS BEFORE RUNNING **
# The package version and URL below were current as of August 2026.
# Hailo revises this package; re-check the URL at the source link above
# and edit the two variables below if they've changed.
#
# Run this ON THE RASPBERRY PI, after hardware verification passes.
set -euo pipefail

HAILO_GENAI_DEB_VERSION="5.1.1"
HAILO_GENAI_DEB_URL="https://dev-public.hailo.ai/2025_12/Hailo10/hailo_gen_ai_model_zoo_${HAILO_GENAI_DEB_VERSION}_arm64.deb"
HAILO_GENAI_DEB_FILE="hailo_gen_ai_model_zoo_${HAILO_GENAI_DEB_VERSION}_arm64.deb"

echo "== Downloading ${HAILO_GENAI_DEB_FILE} =="
wget -O "${HAILO_GENAI_DEB_FILE}" "${HAILO_GENAI_DEB_URL}"

echo "== Installing =="
sudo dpkg -i "${HAILO_GENAI_DEB_FILE}"
sudo apt --fix-broken install -y

echo
echo "Install complete. Next:"
echo "  1. In one terminal, run:  hailo-ollama"
echo "  2. In another, run scripts/05_pull_and_test_model.sh"
echo
echo "(scripts/05_pull_and_test_model.sh assumes hailo-ollama is already running in another session)"

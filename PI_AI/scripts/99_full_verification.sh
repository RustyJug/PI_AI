#!/usr/bin/env bash
# 99_full_verification.sh
# Runs every check from docs/06-verification-and-benchmarking.md in
# sequence and prints a pass/fail summary. Safe to re-run any time.
#
# Run this ON THE RASPBERRY PI, after completing all setup scripts.
set -uo pipefail

PASS=0
FAIL=0

check() {
  local desc="$1"; shift
  echo "== ${desc} =="
  if "$@"; then
    echo "PASS: ${desc}"
    PASS=$((PASS+1))
  else
    echo "FAIL: ${desc}"
    FAIL=$((FAIL+1))
  fi
  echo
}

check "NPU detected (hailortcli)" hailortcli fw-control identify
check "PCIe device present" bash -c "lspci | grep -qi hailo"
check "hailo-ollama responding" bash -c "curl --silent --fail http://localhost:8000/hailo/v1/list > /dev/null"
check "Docker daemon running" bash -c "docker info > /dev/null 2>&1"
check "open-webui container up" bash -c "docker ps --format '{{.Names}} {{.Status}}' | grep -q '^open-webui Up'"

echo "=================================="
echo "Passed: ${PASS}   Failed: ${FAIL}"
echo "=================================="
if [[ "${FAIL}" -gt 0 ]]; then
  echo "See docs/07-troubleshooting.md for the failed check(s) above."
  exit 1
fi
echo "All checks passed."

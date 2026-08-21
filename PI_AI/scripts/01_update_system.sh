#!/usr/bin/env bash
# 01_update_system.sh
# Updates Raspberry Pi OS packages and bootloader/EEPROM firmware.
# Source: https://www.raspberrypi.com/documentation/computers/ai.html#update
#
# Run this ON THE RASPBERRY PI. Reboots at the end — reconnect (SSH) after.
set -euo pipefail

echo "== Confirming this is a 64-bit Trixie install =="
ARCH="$(uname -m)"
CODENAME="$(grep -E '^VERSION_CODENAME=' /etc/os-release | cut -d= -f2)"
echo "Architecture: ${ARCH}"
echo "Codename:     ${CODENAME}"
if [[ "${ARCH}" != "aarch64" ]]; then
  echo "WARNING: expected aarch64 (64-bit), got '${ARCH}'. The Hailo-10H stack requires 64-bit Raspberry Pi OS." >&2
fi
if [[ "${CODENAME}" != "trixie" ]]; then
  echo "WARNING: expected 'trixie', got '${CODENAME}'. AI HAT+ 2 / Hailo-10H is not supported on older releases." >&2
fi

echo "== apt update / full-upgrade =="
sudo apt update
sudo apt full-upgrade -y

echo "== Updating bootloader/EEPROM =="
sudo rpi-eeprom-update -a

echo "== Rebooting now. Reconnect and run scripts/02_install_hailo_h10_driver.sh next. =="
sudo reboot

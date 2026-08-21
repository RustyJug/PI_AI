#!/usr/bin/env bash
# 02_install_hailo_h10_driver.sh
# Installs the Hailo-10H kernel driver + HailoRT runtime for AI HAT+ 2.
# Source: https://www.raspberrypi.com/documentation/computers/ai.html#dependencies
#
# IMPORTANT: hailo-h10-all (AI HAT+ 2 / Hailo-10H) and hailo-all
# (AI Kit / AI HAT+, Hailo-8L/Hailo-8) cannot coexist. If hailo-all is
# currently installed, this script will remove it first.
#
# Run this ON THE RASPBERRY PI. Reboots at the end.
set -euo pipefail

if dpkg -l | grep -qw hailo-all; then
  echo "== Detected conflicting 'hailo-all' package (AI Kit / AI HAT+ stack). Removing it first. =="
  sudo apt remove -y hailo-all hailo-dkms hailort hailo-tappas-core python3-hailort || true
  sudo apt autoremove -y
fi

echo "== Installing dkms and hailo-h10-all =="
sudo apt update
sudo apt install -y dkms
sudo apt install -y hailo-h10-all

echo "== Rebooting now. Reconnect and run scripts/03_verify_hailo_hardware.sh next. =="
sudo reboot

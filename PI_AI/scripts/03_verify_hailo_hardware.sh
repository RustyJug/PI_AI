#!/usr/bin/env bash
# 03_verify_hailo_hardware.sh
# Confirms the Hailo-10H NPU is detected after driver installation.
# Source: https://www.raspberrypi.com/documentation/computers/ai.html#verify
#
# Run this ON THE RASPBERRY PI, after 02_install_hailo_h10_driver.sh + reboot.
set -uo pipefail   # not -e: we want to run every check even if one fails

echo "== hailortcli fw-control identify =="
if hailortcli fw-control identify; then
  echo "OK: hailortcli reached a device."
else
  echo "FAIL: hailortcli could not find a device. See docs/07-troubleshooting.md." >&2
fi

echo
echo "== dmesg | grep -i hailo (kernel driver log) =="
dmesg | grep -i hailo || echo "No 'hailo' lines in dmesg — driver may not have loaded."

echo
echo "== lspci | grep -i hailo (PCIe enumeration) =="
lspci | grep -i hailo || echo "No Hailo PCIe device found — check the ribbon cable seating."

echo
echo "Expect 'Device Architecture: HAILO10H' in the fw-control output above."
echo "'<N/A>' for Serial Number / Part Number / Product Name is normal on AI HAT+ 2."
echo
echo "If all three checks look correct, continue with scripts/04_install_hailo_genai_model_zoo.sh"

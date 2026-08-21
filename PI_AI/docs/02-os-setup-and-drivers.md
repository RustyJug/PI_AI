# 02 — OS Setup and Hailo-10H Drivers

Source: [Raspberry Pi — AI software](https://www.raspberrypi.com/documentation/computers/ai.html)
(official documentation, verified August 2026).

## Prerequisite: flash Raspberry Pi OS (Trixie), 64-bit

If the Pi has no OS yet:

1. On another computer, install **Raspberry Pi Imager**
   (<https://www.raspberrypi.com/software/>).
2. Choose **Raspberry Pi 5** as the device and the current
   **Raspberry Pi OS (64-bit)** — this must be the Trixie release; the
   AI HAT+ 2 / Hailo-10H stack is not supported on the older Bookworm
   release.
3. In the Imager's settings (gear icon / Ctrl+Shift+X), set a hostname,
   enable SSH, and set a username/password before writing the image —
   this gives you headless access immediately.
4. Write the image to your SD card or NVMe drive, then boot the Pi.

## Step 1 — Update the OS and firmware

Run `scripts/01_update_system.sh`, which executes:

```bash
sudo apt update
sudo apt full-upgrade -y
sudo rpi-eeprom-update -a
sudo reboot
```

Expected result: the Pi reboots cleanly. SSH back in before continuing.

## Step 2 — Remove any conflicting older Hailo package (if present)

**Skip this if the Pi has never had an AI Kit or original AI HAT+
installed.**

The AI HAT+ 2 (`Hailo-10H`) uses the `hailo-h10-all` package. The older
AI Kit / AI HAT+ (`Hailo-8L`/`Hailo-8`) uses `hailo-all`. These two
packages **cannot coexist**. If `hailo-all` is currently installed:

```bash
sudo apt remove -y hailo-all hailo-dkms hailort hailo-tappas-core python3-hailort
sudo apt autoremove -y
sudo reboot
```

## Step 3 — Install the Hailo-10H driver and runtime

Run `scripts/02_install_hailo_h10_driver.sh`, which executes:

```bash
sudo apt install dkms
sudo apt install hailo-h10-all
sudo reboot
```

This single metapackage installs, for the Hailo-10H:

- The `hailort` runtime library and `hailortcli` command-line tool
- The `hailort-pcie-driver` kernel module (built via dkms for your
  running kernel)
- On-chip firmware
- Python bindings (`python3-hailort`)

## Step 4 — Verify the NPU is detected

Run `scripts/03_verify_hailo_hardware.sh`, which executes:

```bash
hailortcli fw-control identify
dmesg | grep -i hailo
lspci | grep -i hailo
```

Expected `hailortcli` output looks like:

```
Executing on device: 0000:01:00.0
Identifying board
Control Protocol Version: 2
Firmware Version: ...
Board Name: Hailo-10H
Device Architecture: HAILO10H
Serial Number: <N/A>
Part Number: <N/A>
Product Name: <N/A>
```

`<N/A>` for Serial Number / Part Number / Product Name on AI HAT+ 2 is
normal and does not indicate a problem. What matters is that a device
shows up at all, and that `Device Architecture` reads `HAILO10H`.

If `hailortcli` reports no device: power off, reseat the PCIe ribbon
cable (check both ends are fully clipped in with contacts facing the
right way), and check `lspci | grep -i hailo` again. See
`docs/07-troubleshooting.md` if it's still not found.

Continue to `docs/03-genai-model-and-hailo-ollama.md`.

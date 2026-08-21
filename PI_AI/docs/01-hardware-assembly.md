# 01 — Hardware Assembly

Source: [Raspberry Pi — AI HATs, Hardware assembly](https://www.raspberrypi.com/documentation/accessories/ai-hat-plus.html#ai-hat-plus-installation)
(official documentation, verified August 2026).

## Parts checklist

From the AI HAT+ 2 box:

- [ ] AI HAT+ 2 board (Hailo-10H, 8 GB onboard RAM)
- [ ] 4× threaded spacers
- [ ] 4× long screws (spacer → Pi 5)
- [ ] 4× short screws (HAT → spacers)
- [ ] 1× GPIO stacking header
- [ ] 1× PCIe ribbon cable
- [ ] 1× heatsink for the AI HAT+ 2 (with two black push pins)

You also need:

- [ ] Raspberry Pi 5
- [ ] Phillips crosshead screwdriver
- [ ] Raspberry Pi Active Cooler (recommended, sold separately if you
      don't already have one)
- [ ] Official 27 W USB-C power supply

**Disconnect the Raspberry Pi from power before starting, and keep it
disconnected for the entire assembly.**

## Step 1 — Mount the Active Cooler on the Pi 5 (recommended)

Skip if already fitted.

1. Peel the protective paper off the thermal pads on the underside of
   the cooler.
2. Align the two white push pins with the two heatsink mounting holes on
   the Pi 5 (they land over the SoC, PMIC, and wireless radio).
3. Press the cooler down evenly until both white push pins click in.
4. Plug the fan's JST connector into the fan socket on the Pi 5.

## Step 2 — Mount the heatsink on the AI HAT+ 2 (recommended)

Do this to the HAT **before** it goes on the Pi.

1. Peel the protective paper off the heatsink's thermal pads.
2. Align the two black push pins with the two heatsink holes in
   diagonally opposite corners of the AI HAT+ 2 (they land over the power
   regulator, the Hailo NPU, and the SDRAM chip).
3. Press evenly until both black push pins click in.

## Step 3 — Mount the AI HAT+ 2 on the Pi 5

1. **Fit the spacers:** screw the 4 threaded spacers into the Pi 5's
   yellow-marked mounting holes using the 4 long screws.
2. **Fit the GPIO stacking header:** align it with the Pi 5's GPIO pins
   and press straight down until fully seated. Orientation doesn't
   matter as long as every pin lines up.
3. **Detach the ribbon cable from the HAT for now:** slide the retaining
   clips outward on both sides of the PCIe connector on the AI HAT+ 2,
   then gently pull the cable free.
4. **Connect the ribbon cable to the Pi 5:** slide the Pi 5's PCIe
   connector retaining clip upward on both sides, insert the ribbon cable
   with metallic contacts facing inward (toward the USB ports), then
   push the retaining clip back down on both sides to lock it.
5. **Mount the HAT itself:** with the components facing up, line up the
   AI HAT+ 2's mounting holes with the spacers, and secure with the 4
   short screws.
6. **Reconnect the ribbon cable to the HAT:** slide its PCIe retaining
   clip outward on both sides, insert the still-loose end of the ribbon
   cable, then push the clip back in on both sides to lock it.

## Step 4 — Power on

Reconnect the official 27 W USB-C power supply and boot. Do **not**
manually change any PCIe speed setting for the AI HAT+ 2 — unlike the
older M.2-based AI Kit, the HAT+ family negotiates PCIe Gen 3 (8 GT/s)
automatically.

Continue to `docs/02-os-setup-and-drivers.md`.

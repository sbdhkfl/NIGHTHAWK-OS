# NIGHTHAWK OS — Hardware Compatibility

NIGHTHAWK OS publishes separate images for the Orange Pi Zero 3 and x86_64 PCs. Choose the release that matches your hardware.

## Release map

| Release | Device | Image details |
|---|---|---|
| **Release 1** | Orange Pi Zero 3 (ARM64) | Original build without Wi-Fi |
| **Release 2** | Orange Pi Zero 3 (ARM64) | Orange Pi build with Wi-Fi |
| **Release 3** | Intel/AMD 64-bit desktops and laptops (x86_64) | PC image |
| Release 4 | — | **Does not exist** |

Downloads: [NIGHTHAWK OS Releases](https://github.com/sbdhkfl/NIGHTHAWK-OS-RELEASE/releases).

## Orange Pi Zero 3 — ARM64

- Use **Release 1** if you need the no-Wi-Fi version.
- Use **Release 2** for the Wi-Fi-enabled version.
- Both are specific to the Orange Pi Zero 3 / Allwinner H618 platform.
- Do not flash either Orange Pi image to a PC or a different ARM board.

## Intel/AMD desktops and laptops — x86_64

- Use **Release 3**.
- Intended for compatible 64-bit Intel and AMD desktop and laptop computers.
- BIOS/UEFI behavior and peripheral compatibility can vary by machine. Do not assume every model or every Wi-Fi, graphics, audio, Bluetooth, touchpad, or storage device is supported without testing.

## Other devices

Raspberry Pi models, other ARM64 boards, Android devices, and other architectures require their own device-specific images and validation. Do not use the Orange Pi releases on them.

## PC validation checklist

- [ ] BIOS boot test completed and recorded.
- [ ] UEFI boot test completed and recorded.
- [ ] Secure Boot behavior documented.
- [ ] Intel and AMD systems tested.
- [ ] Graphics/display, keyboard, touchpad, audio, Ethernet, Wi-Fi, and Bluetooth checked.
- [ ] Installation/storage behavior checked on representative systems.
- [ ] Known limitations and tested hardware models published.

A successful image build or virtual-machine boot is not proof of universal physical-hardware compatibility.

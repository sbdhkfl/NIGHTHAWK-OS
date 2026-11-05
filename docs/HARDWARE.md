# NIGHTHAWK OS — Hardware Compatibility

NIGHTHAWK OS provides **separate platform images**. An x86_64 PC ISO and an ARM64 Orange Pi image are not interchangeable.

## x86_64 PCs — image generated, validation pending

| Hardware family | Intended image | Status |
|---|---|---|
| Intel 64-bit desktops | PC x86_64 ISO | Image generated; BIOS/UEFI and hardware validation pending |
| Intel 64-bit laptops | PC x86_64 ISO | Image generated; model-specific validation pending |
| AMD 64-bit desktops | PC x86_64 ISO | Image generated; BIOS/UEFI and hardware validation pending |
| AMD 64-bit laptops | PC x86_64 ISO | Image generated; model-specific validation pending |

A 1.63 GiB PC ISO was generated. This does **not** mean every PC is guaranteed to work. Compatibility depends on firmware settings and the exact graphics, Wi-Fi, Bluetooth, audio, touchpad, storage, and other hardware. BIOS and UEFI tests and representative physical-device tests must be documented before claiming broad validated support.

## ARM64 — Orange Pi Zero 3

| Hardware | Image | Status |
|---|---|---|
| Orange Pi Zero 3 (Allwinner H618, ARM64) | [Release 4 image](https://github.com/sbdhkfl/NIGHTHAWK-OS-RELEASE/releases) | Dedicated board image available; follow Release 4 hardware notes |

The Orange Pi image uses a board-specific boot chain, kernel, firmware, and device configuration. **Do not flash it to an Intel/AMD PC or another ARM board.**

## Not covered by these images

- Raspberry Pi models.
- Other ARM64 single-board computers.
- Android phones and tablets.
- Other device families without their own image and validation.

## Validation checklist for PC images

- [ ] BIOS boot test completed and recorded.
- [ ] UEFI boot test completed and recorded.
- [ ] Secure Boot behavior documented.
- [ ] Intel and AMD systems tested.
- [ ] Graphics/display, keyboard, touchpad, audio, Ethernet, Wi-Fi, and Bluetooth checked.
- [ ] Installer/storage behavior checked on representative systems.
- [ ] Known limitations and tested hardware models published.

A successful ISO build or virtual-machine boot is not proof of universal physical-hardware compatibility.

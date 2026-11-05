# NIGHTHAWK OS Multi-Platform Architecture

## Goal

NIGHTHAWK OS maintains separate images for different hardware targets. A single image is not expected to boot on every device because CPU architecture, boot firmware, bootloader, kernel, device tree, drivers, storage layout, graphics, and wireless firmware differ.

## Actual release map

| Release | Target | Architecture | Description |
|---|---|---|---|
| **Release 1** | Orange Pi Zero 3 | ARM64 | Original Orange Pi build without Wi-Fi |
| **Release 2** | Orange Pi Zero 3 | ARM64 | Orange Pi build with Wi-Fi |
| **Release 3** | Intel/AMD desktops and laptops | x86_64 | PC image |
| Release 4 | — | — | **Does not exist** |

All published downloads are in the [NIGHTHAWK OS release repository](https://github.com/sbdhkfl/NIGHTHAWK-OS-RELEASE/releases).

## Platform-specific image rules

- Use Release 1 or 2 only for the Orange Pi Zero 3. Choose based on whether you need the no-Wi-Fi or Wi-Fi build.
- Use Release 3 for compatible Intel/AMD 64-bit desktops and laptops.
- Never flash an ARM64 Orange Pi image to an x86_64 PC.
- Never use the PC image as an Orange Pi board image.
- Other boards and device families need their own image, boot chain, kernel, firmware, and validation.

## Shared NIGHTHAWK layer

These components should remain hardware-independent wherever possible:

- Branding, wallpapers, icons, terminal presentation.
- Desktop defaults and user-facing configuration.
- Defensive security package groups.
- Documentation, first-boot experience, and release metadata.
- Security and privacy defaults.

## Platform adapter layer

Each target owns its hardware-specific configuration:

- Target identifier and CPU architecture.
- Upstream build framework and pinned revision.
- Board/model identifier.
- Bootloader and firmware.
- Kernel and device-tree source.
- Required firmware and drivers.
- Storage layout and image format.
- Device-specific package additions/removals.
- Build and validation commands.

Do not copy an Orange Pi device tree, bootloader, or kernel into the PC image.

## PC compatibility and validation

Release 3 is the PC image for compatible Intel/AMD 64-bit desktops and laptops. BIOS/UEFI support and hardware compatibility must be verified against representative systems. Graphics, Wi-Fi, Bluetooth, audio, touchpad, storage, and firmware vary by model; do not promise universal compatibility without physical testing.

## Future platforms

Raspberry Pi, other ARM64 boards, Android devices, and additional VM formats are not included in Releases 1–3 unless a release explicitly says otherwise. Each future target needs its own image and test evidence.

## Release quality requirements

Every published artifact should include its target, architecture, checksum, build report, source commit, known limitations, and installation instructions. A target should only be called fully validated after successful boot and hardware checks on the exact target model or named VM profile.

## Contribution rule

Contributors should propose one exact device/model, provide its upstream support source, and add a target adapter plus a test report. A new target must not weaken shared security defaults or silently alter another platform's boot configuration.

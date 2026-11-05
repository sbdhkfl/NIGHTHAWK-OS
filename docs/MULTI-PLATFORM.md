# NIGHTHAWK OS Multi-Platform Architecture

## Goal

Keep one NIGHTHAWK user experience and shared configuration while producing a **different, correctly built artifact for each hardware target**.

There is no universal disk image for all devices. CPU architecture alone is not enough: boot firmware, bootloader, kernel, device tree, drivers, storage layout, graphics, wireless firmware, and installer format can differ.

## Current image status

| Target | Current status | Correct artifact |
|---|---|---|
| Intel/AMD 64-bit desktops and laptops | x86_64 ISO generated (1.63 GiB); BIOS/UEFI and hardware validation pending | PC x86_64 ISO |
| Orange Pi Zero 3 | Dedicated ARM64 image available in [Release 4](https://github.com/sbdhkfl/NIGHTHAWK-OS-RELEASE/releases); follow release hardware notes | Orange Pi Zero 3 ARM64 disk image |
| Raspberry Pi family | Not provided | Model-specific ARM64 image required |
| Virtual machines | PC ISO may be evaluated in a VM; dedicated VM artifacts not yet published | Tested guest-specific ISO/disk image |
| Other ARM64 boards | Not provided | Board-specific image required |
| Android phones/tablets | Research only | Device-specific port only where technically supported |

**Image generated** does not mean **fully hardware validated**. The PC ISO still needs BIOS/UEFI and representative physical-device testing. The Orange Pi Release 4 image is board-specific and must not be used on PCs or other boards.

## Architecture layers

### 1. Shared NIGHTHAWK layer

These components should remain hardware-independent wherever possible:

- Branding, wallpapers, icons, terminal presentation.
- Desktop defaults and user-facing configuration.
- Defensive security package groups.
- Documentation, first-boot experience, and release metadata.
- Security and privacy defaults.

Shared files should not assume a specific CPU, network interface, GPU, bootloader, or storage device.

### 2. Platform adapter layer

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

Do not copy an Orange Pi device tree, bootloader, or kernel into another board's image.

### 3. Artifact and release layer

Artifacts should be named predictably:

`NIGHTHAWK-<version>-<target>-<architecture>-<format>`

Examples:

- `NIGHTHAWK-<version>-generic-pc-x86_64.iso`
- `NIGHTHAWK-<version>-orangepi-zero3-arm64.img.xz`

Every published artifact must include a SHA256 checksum, build report, source commit, upstream framework revision, target identifier, and known limitations. Never reuse a checksum between different images.

## Build pipeline design

1. Validate the target registry and reject unknown target IDs.
2. Load the target's adapter/configuration.
3. Build from the correct upstream framework and pinned revision.
4. Apply shared NIGHTHAWK customization.
5. Apply only that target's hardware adapter.
6. Run static checks and inspect image metadata.
7. Boot-test in a matching emulator or virtual machine where possible.
8. Run a physical-device checklist for hardware-specific targets.
9. Publish only artifacts that meet the release gate, with checksums and reports.

The Orange Pi and PC images use separate build paths. The PC ISO has been generated; its boot and hardware validation remain in progress. The Orange Pi Zero 3 ARM64 image is distributed in Release 4.

## Release gates

A target may be marked fully validated only when all of the following exist:

- A reproducible target-specific build configuration.
- A successful build log and artifact checksum.
- Bootloader/kernel/device-tree/firmware compatibility review.
- Successful first boot on the exact target model (or named VM profile).
- Working storage, display/console, networking, and input as applicable.
- A completed target-specific test checklist.
- Installation, recovery, and known-limitations documentation.

Until then, use a precise status such as `image-generated-validation-pending` or `release-available-hardware-validation-pending`.

## Android-specific caution

Android hardware is especially fragmented. An ARM64 Android phone is not automatically able to boot a generic ARM64 Linux image. Bootloader unlock restrictions, verified boot, vendor kernels, device trees, modem/GPU/Wi-Fi drivers, partition layouts, and recovery procedures vary by model. NIGHTHAWK will not provide a generic phone-flashing image. Initial Android work should be research and compatibility inventory only.

## Contribution rule

Contributors should propose one exact device/model, provide its upstream support source, and add a target adapter plus a test report. A new target must not weaken shared security defaults or silently alter another platform's boot configuration.

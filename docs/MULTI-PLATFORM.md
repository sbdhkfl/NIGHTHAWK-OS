# NIGHTHAWK OS Multi-Platform Architecture

## Goal

Keep one NIGHTHAWK user experience and shared configuration while producing a **different, correctly built artifact for each supported hardware target**.

There is no universal disk image for all devices. CPU architecture alone is not enough: boot firmware, bootloader, kernel, device tree, drivers, storage layout, graphics, wireless firmware, and installer format can differ.

## Target status is deliberately explicit

The machine-readable source of truth is [`platforms/targets.json`](../platforms/targets.json).

| Target | Current status | Intended artifact |
|---|---|---|
| Orange Pi Zero 3 | Existing Armbian build configuration; physical validation pending | Board-specific ARM64 disk image |
| Raspberry Pi family | Planned | Model-specific ARM64 image(s) |
| Intel/AMD PCs | Planned | x86_64 UEFI installer/live image |
| Virtual machines | Planned | Architecture-specific virtual disk and/or ISO |
| Other ARM64 boards | Planned, one board at a time | Board-specific image |
| Android phones/tablets | Research only | Device-specific port only where bootloader, kernel, drivers and licensing permit |

**Planned** and **research-only** do not mean downloadable or boot-tested. Never label a target supported until its image has passed automated artifact checks and documented physical or virtual boot tests.

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

Examples (naming examples only; not yet available builds):

- `NIGHTHAWK-1.0-orangepi-zero3-arm64.img.xz`
- `NIGHTHAWK-1.0-raspberry-pi-4-arm64.img.xz`
- `NIGHTHAWK-1.0-generic-pc-x86_64.iso`
- `NIGHTHAWK-1.0-qemu-x86_64.qcow2`

Every published artifact must include a SHA256 checksum, build report, source commit, upstream framework revision, target identifier, and known limitations. Never reuse the Orange Pi 1.0 checksum for another image.

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

The first implementation stage adds a target registry, architecture documentation, and automated registry validation. It does **not** pretend to build six platforms yet. The existing `build.sh` remains the Orange Pi Zero 3 build path until each new adapter is implemented and tested.

## Recommended implementation order

1. **Keep Orange Pi Zero 3 reproducible** and resolve its physical boot validation.
2. **Generic x86_64 PC** using a dedicated Debian live/installer pipeline.
3. **Virtual machines** from the PC pipeline, with qcow2/raw artifacts and tested guest settings.
4. **Raspberry Pi**, starting with one exact model and then expanding.
5. **Other ARM64 boards**, adding one explicit board adapter at a time.
6. **Android devices**, research first; only port specific models with documented bootloader and driver support.

## Release gates

A target may be marked `supported` only when all of the following exist:

- A reproducible target-specific build configuration.
- A successful build log and artifact checksum.
- Bootloader/kernel/device-tree/firmware compatibility review.
- Successful first boot on the exact target model (or named VM profile).
- Working storage, display/console, networking, and input as applicable.
- A completed target-specific test checklist.
- Installation, recovery, and known-limitations documentation.

Until then, use `planned`, `research-only`, or `physical-validation-pending` status.

## Android-specific caution

Android hardware is especially fragmented. An ARM64 Android phone is not automatically able to boot a generic ARM64 Linux image. Bootloader unlock restrictions, verified boot, vendor kernels, device trees, modem/GPU/Wi-Fi drivers, partition layouts, and recovery procedures vary by model. NIGHTHAWK will not provide a generic phone-flashing image or instructions that risk bricking an unspecified device. Initial Android work should be research and compatibility inventory only.

## Contribution rule

Contributors should propose one exact device/model, provide its upstream support source, and add a target adapter plus a test report. A new target must not weaken shared security defaults or silently alter another platform's boot configuration.

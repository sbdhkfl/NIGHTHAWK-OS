# NIGHTHAWK OS — Hardware Compatibility

## Supported hardware

| Hardware | Status |
|---|---|
| Orange Pi Zero 3 — 2GB RAM (primary target) | Supported |
| Orange Pi Zero 3 — 4GB RAM (secondary) | Supported |

SoC: Allwinner H618 (quad-core Cortex-A53, ARM64/AArch64, Mali-G31 MP2 GPU).
Boot medium: microSD (Armbian u-boot / sunxi).
Kernel: Armbian current 6.18.x for H618 (`sun50iw9`).

## Supported features

- HDMI output (micro HDMI, up to 4K @ 60fps on Zero 3).
- Ethernet (Gigabit on Zero 3).
- Onboard Wi-Fi 5 + Bluetooth 5 (H618).
- USB 2.0 host ports.
- CPU temperature monitoring via thermal zone.

## Not supported / out of scope

- Other Allwinner boards (not validated).
- x86_64 desktop PCs (final image is ARM64 only).
- Internal eMMC/SD card installation paths beyond microSD (Armbian image targets SD).

## Known limitations

- 2GB RAM: lightweight-by-design; heavy workloads may swap to zram.
- GPU acceleration for desktop compositing is limited; compositor disabled by default for performance.
- Bluetooth UART bring-up may require firmware blobs (installed via `armbian-firmware`).

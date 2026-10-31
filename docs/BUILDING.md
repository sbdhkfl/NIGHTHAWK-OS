# NIGHTHAWK OS — Build Documentation

This document describes the automated build process for NIGHTHAWK OS.

## Overview

NIGHTHAWK OS is built on the official Armbian build framework:

- Framework: `https://github.com/armbian/build`
- Board: `orangepizero3` (Orange Pi Zero 3, Allwinner H618, ARM64, family `sun50iw9`)
- Userland: Debian 13 `trixie`
- Kernel: Armbian `current` (H618)

## Build inputs

| Source | Purpose |
|---|---|
| `build.sh` | Main build entrypoint (host checks, overlay assembly, Armbian invocation, artifact copy, SHA256, report) |
| `userpatches/config-nighthawk.conf` | Armbian named build configuration (`./compile.sh build nighthawk`) |
| `userpatches/customize-image.sh` | In-chroot image customization (installs packages from `pkg-lists`, applies memory/security tuning) |
| `userpatches/firstboot.conf` | First boot presets (no default accounts/passwords) |
| `userpatches/extensions/preset-firstrun.sh` | Enables Armbian first boot preset extension |
| `userpatches/overlay/` | Assembled overlay: bashrc, motd, banner, profile.d, lightdm, theme, icons, backgrounds, packages, ssh, systemd, sysctl |
| `desktop/` | XFCE theme, GTK config, lightdm config sources |
| `branding/` | Mascot, logo, wallpaper, icons, ASCII banner, PNG generators |
| `browser/` | Firefox ESR policies |
| `security/` | Security toolkit scripts |
| `pkg-lists/` | Authoritative APT package group definitions |

## Build steps performed by `build.sh`

1. Host architecture check (x86_64 / aarch64).
2. Host memory check (needs ≥ ~8 GB free RAM).
3. Host disk space check (clear low-disk-space warning/abort if < ~50 GB free).
4. Required dependency check (git, docker, make, gcc, g++, awk; docker daemon).
5. Armbian build framework clone + userpatches overlay assembly.
6. Armbian image build, streamed to log and tee'd:

   ```bash
   ./compile.sh build nighthawk 2>&1 | tee "${LOG_DIR}/armbian-compile-${IMAGE_DATE}.log"
   ```

   The command explicitly loads `userpatches/config-nighthawk.conf` via the
   `nighthawk` named configuration. All board/release/desktop settings live in
   that file.

7. Collect image (`*.img` / `*.img.gz`, gunzip if needed) and compute checksum:

   ```bash
   sha256sum "${FINAL_IMAGE}" > "${FINAL_SHA256_FILE}"
   ```

   The `.sha256` file is in `sha256sum -c` compatible format.

8. Write build report (`releases/BUILD-REPORT-<date>.md`) including the Armbian
   framework commit used.

## One-command build

```bash
./build.sh
```

## Build host requirements

- Linux x86_64 / aarch64 (native or WSL2 / Docker).
- ≥ 8 GB RAM, ≥ 50 GB free disk.
- Docker Engine + buildx.
- git, make, gcc, g++, bash.

## Outputs

- Image: `releases/NIGHTHAWK-orangepizero3-trixie-<date>.img`
- Checksum: `releases/NIGHTHAWK-orangepizero3-trixie-<date>.img.sha256` (sha256sum -c compatible)
- Report: `releases/BUILD-REPORT-<date>.md`
- Raw Armbian logs: `build/logs/`

## Security-relevant build behavior

- First boot remains interactive; no preset accounts/passwords/keys.
- SSH drop-in: `PermitRootLogin no`, `PubkeyAuthentication yes`; password policy untouched.
- Browser: Firefox ESR policy applied; no automatic launch entry created.

## Troubleshooting build failures

- Docker not running → start dockerd.
- Out of disk → free space ≥ 50 GB.
- Out of memory → ≥ 8 GB free.
- Armbian clone issues → delete `build-workspace/armbian-build` and re-run.

## Testing status vs. build status

- Automated static tests: `tests/run-tests.sh` — all checks pass on the build host.
- Full image build + checksum verification: run `./build.sh` on a suitable Linux host; success requires the build step to complete and the report artifact to be produced.
- Physical hardware testing: separate checklist, `tests/hardware-testing-checklist.md`.

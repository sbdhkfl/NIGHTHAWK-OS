# NIGHTHAWK OS — Build Report

- **Date:** 2026-10-30
- **Target board:** Orange Pi Zero 3 (Allwinner H618, ARM64) — 2GB RAM primary, 4GB secondary
- **Userland:** Debian 13 (Trixie) via official Armbian build framework
- **Desktop:** XFCE4 (minimal tier) + LightDM + Firefox ESR + security toolkit

## Automated build status

- Build host used for this report run: Windows 11 (x86_64) — **not** a Linux/Armbian build host.
- Real Armbian image build: **NOT executed on this host** (requires Linux x86_64/aarch64 host or WSL2/Docker Linux).
- Automated source checks executed on build host: see `tests/run-tests.sh` results.

## Deliverables status

| # | Deliverable | Status |
|---|---|---|
| 1 | Source project | Complete |
| 2 | Automated build scripts | Complete (`build.sh`) |
| 3 | Debian/Armbian configs | Complete (`userpatches/`, `config-nighthawk.conf`) |
| 4 | XFCE desktop | Complete (theme + packages wired) |
| 5 | Mascot | Complete (original SVG) |
| 6 | Logo/wallpapers | Complete (SVG + generated PNG) |
| 7 | Custom desktop theme | Complete (GTK3/GTK2 CSS) |
| 8 | Terminal theme | Complete (bash profile + MOTD + banner) |
| 9 | Firefox ESR | Complete (policies + prefs) |
| 10 | Security toolkit | Complete (core + optional groups) |
| 11 | RAM optimization | Complete (zram + sysctl) |
| 12 | Hardware compatibility docs | Complete (`docs/HARDWARE.md`) |
| 13 | Automated tests | Complete (`tests/run-tests.sh`) |
| 14 | README | Complete |
| 15 | Flashable image | **Pending real build** |
| 16 | SHA256 | **Pending real build** |
| 17 | Build report | This file |
| 18 | Hardware testing checklist | Complete (`tests/hardware-testing-checklist.md`) |

## Next steps

1. Run `./build.sh` on a Linux x86_64/aarch64 host (≥8GB RAM, ≥50GB disk, Docker).
2. Flash generated image to microSD.
3. Perform physical hardware testing (see `tests/hardware-testing-checklist.md`).

## Honest notes

- No fake screenshots, fake benchmarks, or fabricated hardware results were produced.
- Automated checks in `tests/run-tests.sh` are the only executed verification so far.
- Real image build, checksum, and physical validation remain outstanding on this host.

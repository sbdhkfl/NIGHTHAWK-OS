# NIGHTHAWK OS

**A lightweight, black-and-crimson, Debian-based cybersecurity workstation currently built for the Orange Pi Zero 3.**

NIGHTHAWK OS customizes the official Armbian build of **Debian 13 (Trixie) for the Orange Pi Zero 3 (Allwinner H618, ARM64)** into a minimal, security-focused desktop operating system.

The current project is focused exclusively on the Orange Pi Zero 3:

- Official **Armbian** build framework
- **Debian 13 Trixie** ARM64 base
- **XFCE4** minimal desktop with the original **NIGHTHAWK** visual identity
- **Firefox ESR**
- Curated **defensive security toolkit**
- Configuration intended for the board's 2GB and 4GB RAM variants

Other platforms may be explored in future development. **They are not current targets, and no PC, Raspberry Pi, virtual-machine, Android, or other-board image is currently provided or supported.** Any future port will require its own build configuration and hardware testing.

---

## 1. What NIGHTHAWK OS is

NIGHTHAWK OS is a purpose-built security workstation for the **Orange Pi Zero 3** (Allwinner H618, quad-core Cortex-A53, ARM64).

The design goals:

1. Real Debian base (`apt`, `systemd`) — not a custom-from-scratch distro.
2. Minimal XFCE4 desktop — performance over effects.
3. Original NIGHTHAWK branding — black + charcoal + crimson + dark silver.
4. Powerful terminal-first experience.
5. Defensive security toolkit that stays lightweight.
6. Honest, reproducible automated image build.

It deliberately avoids copying Kali's look and feel: no Kali artwork, dragon, or trademarks — only an original hawk mascot designed for NIGHTHAWK.

---

## 2. Hardware compatibility

### Current target

- **Orange Pi Zero 3 — 2GB RAM**
- **Orange Pi Zero 3 — 4GB RAM**

Both variants use the Allwinner H618 ARM64 platform. The 2GB model is the primary configuration target; the 4GB variant still requires its own validation.

### Hardware covered by the current target

- Allwinner H618 processor (quad-core Cortex-A53, ARM64/AArch64).
- Mali-G31 MP2 GPU.
- HDMI output.
- Ethernet.
- Onboard Wi-Fi and Bluetooth.
- USB 2.0 host ports.
- microSD boot.
- CPU temperature monitoring (where exposed by the kernel).

### Not currently supported

- Intel/AMD desktop and laptop PCs.
- Raspberry Pi boards.
- Virtual machines.
- Other ARM64 single-board computers.
- Android phones and tablets.

These may be considered for future development, but each requires a separate device-specific build and validation process. Do not flash the current Orange Pi image to another device.

See [docs/HARDWARE.md](docs/HARDWARE.md) for details.

---

## 3. Future development

The current release and build configuration are for the **Orange Pi Zero 3 only**. Future contributors may help explore ports to additional hardware, but a platform must not be called supported until its dedicated image has been built and tested on the exact target.

See [docs/MULTI-PLATFORM.md](docs/MULTI-PLATFORM.md) for the future-expansion approach and [platforms/targets.json](platforms/targets.json) for planning metadata. These files are planning documentation only; they do not mean additional platform builds exist.

---

## 4. What the image contains

### Base system

- Debian 13 (Trixie) — `systemd`, `apt`.
- Armbian current kernel for H618.
- U-Boot + Allwinner firmware (`armbian-firmware`).

### Desktop (minimal XFCE4)

- XFCE4 session, panel, window manager, settings.
- LightDM + LightDM GTK Greeter.
- File manager: Thunar.
- Terminal: XFCE4 Terminal.
- Settings manager, app launcher (AppFinder), system monitor, power manager,
  screenshot utility.
- NetworkManager for network management.

### Browser

- Firefox ESR (ARM64) from Debian Trixie.
- NIGHTHAWK policies and user preferences.

### Security toolkit (curated)

Core (installed in image): Lynis, UFW, Nmap, Tcpdump, DNS utilities, Python3 + venv,
Git, curl, wget, OpenSSH client/server.

Optional install groups (`pkg-lists/50-security-optional.list`, not included in the image):
nftables, btop, htop, tshark, fail2ban.

---

## 5. Original NIGHTHAWK visual identity

### Mascot and artwork

- `branding/logo.svg` — crimson NIGHTHAWK emblem.
- `branding/mascot.svg` — full hawk mascot.
- `branding/wallpaper.svg` and generated PNG — NIGHTHAWK wallpaper.
- `branding/icons/` — NightHawk icon theme.
- `branding/ascii/nighthawk-banner.txt` — ASCII hawk banner.

### Color palette

- Deep black: `#050507`
- Charcoal gray: `#0a0a0c`
- Crimson red: `#e10613`
- Dark metallic silver: `#1a1a20`
- Red highlights: `#ff3b3b`

---

## 6. Terminal experience

- Bash with a crimson NIGHTHAWK prompt.
- Custom MOTD and ASCII hawk banner.
- Bash, APT, Git, Python3 + venv, Nano, Vim, Curl, Wget, Tmux, SSH, and inspection utilities.
- Helpers: `security/scripts/nighthawk-sysinfo.sh`, `nighthawk-filecheck.sh`.

---

## 7. Security and privacy defaults

- No shared default password; first-boot interactive user setup.
- Root SSH login disabled.
- No default accounts or SSH keys are shipped.
- UFW available; optional nftables package group.
- No telemetry.
- No automatic browser startup.
- No unnecessary listening services enabled by default.

### SSH key-based access

1. Complete first boot and create your user.
2. Generate a key: `ssh-keygen -t ed25519`.
3. Copy the public key with `ssh-copy-id <user>@<board-ip>`.
4. After verifying key-based login, configure SSH to disable password authentication.

---

## 8. Build the Orange Pi image

### Host build requirements

- Linux x86_64 / aarch64 (native or WSL2).
- At least 8 GB RAM and 50 GB free disk.
- Docker Engine + buildx.
- git, make, gcc, g++, bash.

### Build

```bash
./build.sh
```

The script checks the host, obtains the Armbian build framework, applies the NIGHTHAWK configuration for Orange Pi Zero 3, builds the image, and collects the image, SHA256 checksum, and build report.

See [docs/BUILDING.md](docs/BUILDING.md).

### Generated artifacts

- `releases/NIGHTHAWK-orangepizero3-trixie-<date>.img`
- `releases/NIGHTHAWK-orangepizero3-trixie-<date>.img.sha256`
- `releases/BUILD-REPORT-<date>.md`

---

## 9. Test the project

```bash
./tests/run-tests.sh
```

Automated source checks do not replace a real image build or physical testing. A successful release requires a completed build, checksum, and documented hardware validation.

See [tests/hardware-testing-checklist.md](tests/hardware-testing-checklist.md).

---

## 10. Flash and first boot

Flash the generated `.img` to a microSD card using a trusted imaging utility, then insert it into the Orange Pi Zero 3 and power on.

- Complete the interactive first-boot account setup.
- Set locale and timezone.
- Connect Wi-Fi using NetworkManager or `nmtui`.

Do not flash this image to a different board or a PC.

---

## 11. Update and install software

```bash
sudo apt update
sudo apt upgrade -y
sudo apt install <package>
```

Optional security packages are listed in `pkg-lists/50-security-optional.list`.

---

## 12. Known limitations and validation status

- The Orange Pi Zero 3 is the only current build target.
- Physical boot and peripheral validation must be completed and documented before claiming full hardware support.
- The 4GB variant requires validation.
- RAM usage goals are targets, not measured guarantees.
- Audio support depends on the board, kernel, and connected hardware.

---

## 13. Project structure

```
build.sh                     Main build entrypoint
build-workspace/             Cloned Armbian build repo (generated)
build/logs/                  Build logs (generated)
desktop/                     XFCE theme, GTK, LightDM sources
branding/                    Mascot, logo, wallpaper, icons, ASCII
browser/                     Firefox policies and preferences
security/                    Defensive toolkit scripts
pkg-lists/                   APT package group lists
tests/                       Automated tests and hardware checklist
docs/                        Build, hardware, security, and future plans
platforms/                   Future-platform planning metadata
userpatches/                 Armbian configuration and customization
releases/                    Build artifacts and reports
.github/                     CI workflows
```

---

## 14. Contributing and license

Contributions are welcome! You can suggest improvements, fix bugs, improve documentation, or help investigate support for additional hardware. Future platform ports should be proposed as separate, device-specific work and must include build and test evidence.

Please review the repository's [LICENSE](LICENSE) before redistributing or modifying the project.

---

## Honest status note

The current source configuration targets the Orange Pi Zero 3 only. Static checks are not proof of a working image; a completed Armbian build and physical testing are required before describing a release as fully validated.

---

**NIGHTHAWK OS — Deep Black. Crimson Edge.**

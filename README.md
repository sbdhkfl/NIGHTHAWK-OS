# NIGHTHAWK OS

**A lightweight, black-and-crimson, Debian-based cybersecurity operating system with separate images for x86_64 PCs and ARM64 single-board computers.**

NIGHTHAWK OS now has a generated **x86_64 PC ISO build** intended for Intel- and AMD-based desktops and laptops, plus two separate **Orange Pi Zero 3 ARM64 releases** (Release 1 without Wi-Fi and Release 2 with Wi-Fi). The **PC desktop/laptop image is Release 3**. There is no Release 4. These are different platform images: never flash the ARM64 board image to a PC or the PC ISO to an Orange Pi.

### Available image families

- **PC desktops and laptops (x86_64):** use **Release 3** in the [NIGHTHAWK OS releases](https://github.com/sbdhkfl/NIGHTHAWK-OS-RELEASE/releases). This is the PC image for compatible Intel/AMD 64-bit computers. BIOS/UEFI and hardware compatibility still depend on the particular computer.
- **Orange Pi Zero 3 without Wi-Fi (ARM64):** use **Release 1**.
- **Orange Pi Zero 3 with Wi-Fi (ARM64):** use **Release 2**. This is the Wi-Fi-enabled Orange Pi build.

Release 1 and Release 2 are board-specific images for the Orange Pi Zero 3 / Allwinner H618. Release 3 is the PC image. There is no Release 4.

The two architectures require separate images, bootloaders, kernels, firmware, and drivers. Other ARM boards, Raspberry Pi models, and Android devices are not covered by these images.

---

## 1. What NIGHTHAWK OS is

NIGHTHAWK OS is a Debian-based security workstation with dedicated builds for the Orange Pi Zero 3 and x86_64 PCs. The release number determines which platform image to download.

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

### Supported image targets

**Orange Pi Zero 3 (ARM64):** 2GB and 4GB variants using the Allwinner H618 platform. The 2GB model is the primary configuration target; validate each hardware revision separately.

**Intel/AMD PCs and laptops (x86_64):** a separate Debian Trixie live-build ISO is available as Release 3. It is intended for compatible 64-bit desktops, laptops, and virtual machines. Hardware support varies by model; consult the release notes and hardware compatibility guide before installing.

### Orange Pi hardware covered

- Allwinner H618 processor (quad-core Cortex-A53, ARM64/AArch64).
- Mali-G31 MP2 GPU, HDMI, Ethernet, onboard Wi-Fi/Bluetooth, USB 2.0, microSD boot, and CPU temperature monitoring where exposed by the kernel.

### Not currently supported

- Raspberry Pi boards, other ARM64 single-board computers, and Android phones/tablets.

Each target uses its own bootloader, kernel, firmware, and drivers. Never flash an ARM64 image to a PC or the x86_64 ISO to an Orange Pi.

See [docs/HARDWARE.md](docs/HARDWARE.md) for details.

---

## 3. Platform image status

NIGHTHAWK OS maintains separate image paths for **x86_64 PCs** and **ARM64 Orange Pi Zero 3**. The PC desktop/laptop image is **Release 3**; Orange Pi images are **Release 1 (without Wi-Fi)** and **Release 2 (with Wi-Fi)**. See the [release repository](https://github.com/sbdhkfl/NIGHTHAWK-OS-RELEASE/releases).

A generated image is not proof of compatibility with every computer. A platform should only be described as fully validated after its boot tests and hardware checklist are documented. See [docs/MULTI-PLATFORM.md](docs/MULTI-PLATFORM.md) and [platforms/targets.json](platforms/targets.json) for the current status.

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

- Orange Pi images use their documented first-boot account setup.
- PC Release 3 live-session login: username `user`, password `live`.
- The PC live credentials are public defaults for the live session; change the password if you keep/use that account, and create a personal account for an installed system.
- Do not enable password-based root SSH. No SSH keys are pre-shipped.
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

- The PC Release 3 ISO has been generated and booted to the graphical desktop; the live-session credentials are `user` / `live`. BIOS/UEFI and representative physical-hardware validation remain hardware-dependent and should be recorded separately.
- Orange Pi Zero 3 Release 1 is the no-Wi-Fi build; Release 2 is the Wi-Fi build. PC desktop/laptop image is Release 3. No Release 4 exists.
- Neither image guarantees compatibility with every model in its architecture family.
- Physical boot and peripheral validation must be completed and documented before claiming full hardware support.
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

The Orange Pi releases and PC Release 3 are separate platform artifacts. Static checks and ISO generation do not prove compatibility with every device; use the correct release for your hardware and consult its release notes.

---

**NIGHTHAWK OS — Deep Black. Crimson Edge.**

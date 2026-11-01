# NIGHTHAWK OS

**A lightweight, black-and-crimson, Debian-based cybersecurity workstation for the
Orange Pi Zero 3.**

NIGHTHAWK OS turns the official Armbian build of **Debian 13 (Trixie) for the
Orange Pi Zero 3 (Allwinner H618, ARM64)** into a complete, minimal, security-focused
desktop operating system.

It is not a theme pack, not a mockup, and not a collection of scripts. It is a source
project that assembles a real, flashable Linux image:

- Official **Armbian** build framework
- **Debian 13 Trixie** ARM64 base
- **XFCE4** minimal desktop with full **NIGHTHAWK** visual identity
- **Firefox ESR**
- Curated **defensive security toolkit**
- **2GB RAM optimized** configuration

---

## 1. What NIGHTHAWK OS is

NIGHTHAWK OS is a purpose-built security workstation for the
**Orange Pi Zero 3** (Allwinner H618, quad-core Cortex-A53, ARM64).

The design goals:

1. Real Debian base (`apt`, `systemd`) — not a custom-from-scratch distro.
2. Minimal XFCE4 desktop — performance over effects.
3. Original NIGHTHAWK branding — black + charcoal + crimson + dark silver.
4. Powerful terminal first experience.
5. Defensive security toolkit that stays lightweight.
6. Honest, reproducible automated image build.

It deliberately avoids the "Kali look and feel" clone trap: no Kali artwork,
dragon, or trademarks — only an original hawk/raven mascot designed for NIGHTHAWK.

---

## 2. Hardware compatibility

### Primary target

- **Orange Pi Zero 3 — 2GB RAM** (allwinner H618, ARM64).

### Secondary compatibility

- **Orange Pi Zero 3 — 4GB RAM**.

### Supported hardware features

- Allwinner H618 processor (quad-core Cortex-A53, ARM64/AArch64).
- Mali-G31 MP2 GPU.
- **HDMI** output (micro HDMI, up to 4K @ 60fps on Zero 3).
- **Ethernet** (Gigabit on Zero 3).
- **Onboard Wi-Fi 5 + Bluetooth 5**.
- **USB** 2.0 host ports.
- **microSD** boot.
- **CPU temperature monitoring** (thermal zone).

### Out of scope / not supported

- Non-Orange-Pi ARM boards (not validated).
- x86_64 desktop PCs (the produced image is ARM64 only).
- Anything beyond the listed Orange Pi Zero 3 feature set.

See [docs/HARDWARE.md](docs/HARDWARE.md) for details.

---

## Multi-platform roadmap

NIGHTHAWK is being organized as a multi-platform project, but **there is not one universal image**. Each device family needs its own boot chain, kernel, firmware, drivers, and validation.

The target registry and implementation plan are maintained in:
- [Multi-platform architecture](docs/MULTI-PLATFORM.md)
- [Machine-readable target registry](platforms/targets.json)

Initial targets: Orange Pi, Raspberry Pi, Intel/AMD PCs, virtual machines, other ARM64 boards, and Android phones/tablets. The Orange Pi Zero 3 remains the only configured image build at this stage. The other targets are planned or research-only, not currently downloadable or supported. Android devices require model-specific investigation.

The platform registry is checked automatically by the **Validate platform registry** workflow. This check validates metadata only; it does not build or certify operating-system images.

---

## 3. What the image contains

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

- Firefox ESR (ARM64) from Debian trixie.
- NightHawk policies + user preferences (no auto startup, sane network settings).

### Security toolkit (curated)

Core (installed in image): Lynis, UFW, Nmap, Tcpdump, DNS utils, Python3 + venv,
Git, curl, wget, OpenSSH client/server.

Optional install groups (`pkg-lists/50-security-optional.list`, NOT in image):
nftables, btop, htop, tshark, fail2ban.

### Memory & storage

- zram swap configured (`/etc/systemd/zram-generator.conf`).
- sysctl tuning (`vm.swappiness`, cache pressure, dirty ratios).
- Minimal package footprint (`--no-install-recommends`).

---

## 4. Original NIGHTHAWK visual identity

### Mascot

Original NIGHTHAWK mascot: a powerful hawk silhouette with swept-back wings,
dark metallic body, crimson accents and a distinctive glowing red eye.
Designed for NIGHTHAWK OS; **no Kali assets** are used.

### Logo and artwork

- `branding/logo.svg` — crimson NIGHTHAWK emblem.
- `branding/mascot.svg` — full hawk mascot.
- `branding/wallpaper.svg` + generated PNG (`branding/png/nighthawk-wallpaper.png`) — dark
  battlefield-style wallpaper with crimson glow.
- `branding/icons/` — icon theme (`NightHawk`) with app icons.
- `branding/ascii/nighthawk-banner.txt` — ASCII hawk banner.

### Color palette

- Deep black: `#050507`
- Charcoal gray: `#0a0a0c`
- Crimson red: `#e10613`
- Dark metallic silver: `#1a1a20`
- Subtle glowing red highlights: `#ff3b3b`

### Desktop look

- Dark GTK theme (`desktop/xfce/theme/gtk-3.0/gtk.css`).
- Custom LightDM login background/logo.
- Custom MOTD, bash prompt, ASCII banner.
- Minimal panel, themed icons, Firefox branding-neutral.

---

## 5. Terminal experience

- Bash (`/etc/bash.bashrc`, `/etc/profile.d/nighthawk.sh`).
- Crimson NIGHTHAWK prompt (`PS1`).
- Custom MOTD + ASCII hawk banner (`/etc/motd`, `/etc/motd.d/00-nighthawk`).
- Tools: Bash, APT, Git, Python3 + venv, Nano, Vim, Curl, Wget, Tmux, SSH client,
  compression, inspection utilities.
- Helpers: `security/scripts/nighthawk-sysinfo.sh`, `nighthawk-filecheck.sh`.

---

## 6. Security and privacy defaults

- No shared default password; first-boot interactive user setup.
- Root SSH login disabled; public key authentication enabled.
- Password SSH authentication is left enabled until a first user SSH key is
  provisioned (no default accounts/keys are shipped).
- Firewall available (UFW); optional nftables group.
- No telemetry.
- No auto browser startup.
- No unnecessary listening services enabled by default.

### SSH key-based access

1. Complete the interactive first boot and create your user.
2. From a local console/keyboard on the board, generate a key:
   `ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519`
3. Copy the public key to the board:
   `ssh-copy-id <user>@<board-ip>`
4. After a successful key-based login, key-only can be enforced by setting
   `PasswordAuthentication no` in `/etc/ssh/sshd_config.d/99-nighthawk.conf`
   and reloading the SSH service.

---

## 7. Build the image

### Host build requirements

- Linux x86_64 / aarch64 (native or WSL2).
- ≥ 8 GB RAM, ≥ 50 GB free disk.
- Docker Engine + buildx.
- git, make, gcc, g++, bash.

### One-command build

```bash
./build.sh
```

### What the build does

1. Checks host architecture, memory, disk, dependencies.
2. Clones official Armbian build framework.
3. Assembles NIGHTHAWK overlay + userpatches.
4. Runs the Armbian build with the named configuration (loads `userpatches/config-nighthawk.conf`):

   ```bash
   ./compile.sh build nighthawk
   ```

5. Streams build output to the build log via `tee`.
6. Collects image, computes SHA256 (sha256sum -c compatible), writes build report.

### Generated artifacts

- `releases/NIGHTHAWK-orangepizero3-trixie-<date>.img`
- `releases/NIGHTHAWK-orangepizero3-trixie-<date>.img.sha256`
- `releases/BUILD-REPORT-<date>.md`
- `build/logs/`

See [docs/BUILDING.md](docs/BUILDING.md).

---

## 8. Test the image

```bash
./tests/run-tests.sh
```

Automated checks: shell syntax, Armbian config, package lists, branding assets,
GTK theme, terminal, browser policies, security scripts, build script contents,
overlay/baked-in files, SSH and memory configuration.

Only a successfully completed build (Armbian compile step passing, image collected,
SHA256 written) constitutes a successful image build; passing static tests do not
substitute for a real build. Physical hardware testing is still required
([tests/hardware-testing-checklist.md](tests/hardware-testing-checklist.md)).

RAM usage targets (<400 MB idle, <900 MB browser) and hardware compatibility were
targets only and have not been measured on real hardware.

---

## 9. Flash, first boot, and use

### Flash microSD

```bash
# example
sudo dd if=releases/NIGHTHAWK-orangepizero3-trixie-<date>.img of=/dev/sdX bs=4M status=progress
```

### First boot

- Insert microSD, power on.
- Interactive first-boot account setup (no default password).
- Set locale/timezone.

### Connect Wi-Fi

- First boot: no auto network config (secure default); use NetworkManager GUI or
  `nmtui` to connect.

### Use browser

- Launch via app menu / XFCE panel; Firefox ESR.
- Hardware-friendly prefs applied.

### Use terminal

- XFCE4 Terminal → NightHawk profile.
- `nighthawk-sysinfo.sh` for hardware status.

---

## 10. Install additional tools

```bash
sudo apt update
sudo apt install <package>
```

Optional security groups: nftables, btop, htop, tshark, fail2ban.

---

## 11. Update the OS

```bash
sudo apt update
sudo apt upgrade -y
```

---

## 12. RAM optimization

- zram swap (`ram / 4` → 512MB effective on 2GB unit).
- sysctl tuning.
- Minimal packages, no recommends.
- XFCE compositor disabled by default (performance).
- Targets: <400MB idle, <900MB light browser use.

---

## 13. Troubleshooting

- Boot issues: check HDMI, power.
- Thermal: `cat /sys/class/thermal/thermal_zone0/temp`.
- etc. — see docs.

---

## 14. Known limitations

- Real hardware testing pending.
- zram sizing for 4GB variant.
- Audio not enabled by default (task: "Audio where supported").

---

## 15. Physical hardware testing

See [tests/hardware-testing-checklist.md](tests/hardware-testing-checklist.md).

---

## 16. Project structure

```
build.sh                     Main build entrypoint
build-workspace/             Cloned Armbian build repo (generated)
build/logs/                   Build logs (generated)
config/                      (reserved for Armbian board overrides)
desktop/                     XFCE theme, GTK, lightdm sources
branding/                    Mascot, logo, wallpaper, icons, ASCII, PNG gen
browser/                     Firefox policies/prefs
security/                    Toolkit scripts
pkg-lists/                   APT package group lists
tests/                       Automated tests + hardware checklist
docs/                        BUILDING, HARDWARE, SECURITY
userpatches/                 Armbian user patches (config, customize, firstboot, overlay)
releases/                    Build artifacts + reports
.github/                     CI workflow (build dispatch)
```

---

## 17. Contributing / license

N/A — internal project.

---

## Honest status note

As of 2026-10-30 the automated source checks in `tests/run-tests.sh` were executed
on the build host. The actual Armbian ARM64 image build requires a Linux build host
and could not be executed on the current Windows-based host; the build script is
ready to run on a suitable Linux host.

---

**NIGHTHAWK OS — Deep Black. Crimson Edge. No Limits.**

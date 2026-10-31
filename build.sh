#!/usr/bin/env bash
#
# NIGHTHAWK OS - build script for the Orange Pi Zero 3 (Allwinner H618, ARM64)
#
# Produces a flashable Debian 13 (Trixie) based Linux distribution for the
# Orange Pi Zero 3 (2GB / 4GB LPDDR4 variants) with:
#   - Official Armbian build framework (Orange Pi Zero3, sun50iw9 / H618)
#   - Debian 13 Trixie ARM64 base
#   - Minimal XFCE desktop (NightHawk theme)
#   - Firefox ESR
#   - Curated defensive security toolkit
#   - NightHawk visual identity (logo, mascot, wallpaper, terminal, login)
#   - 2GB RAM optimizations (zram, swap tuning, sane defaults)
#
# Usage:
#   ./build.sh
#
# Requirements (build host):
#   - Linux x86_64 or aarch64
#   - >= 8 GB RAM, >= 50 GB free disk
#   - git, docker (engine + buildx), make, gcc, g++
#   - root or sudo
#
# Outputs:
#   build-workspace/armbian-build/build/output/images/*.img
#   releases/NIGHTHAWK-orangepizero3-trixie-<date>.img
#   releases/NIGHTHAWK-orangepizero3-trixie-<date>.sha256
#   releases/BUILD-REPORT-<date>.md

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BUILD_WORKSPACE_DIR="${SCRIPT_DIR}/build-workspace"
ARMBIAN_BUILD_DIR="${BUILD_WORKSPACE_DIR}/armbian-build"
LOG_DIR="${SCRIPT_DIR}/build/logs"
OUTPUT_DIR="${SCRIPT_DIR}/releases"
IMAGE_DATE="$(date -u +%Y%m%d)"

BOARD="${NIGHTHAWK_BOARD:-orangepizero3}"
RELEASE="${NIGHTHAWK_RELEASE:-trixie}"
BRANCH="${NIGHTHAWK_BRANCH:-current}"
DESKTOP_ENVIRONMENT="${NIGHTHAWK_DESKTOP:-xfce}"
DESKTOP_TIER="${NIGHTHAWK_DE_TIER:-minimal}"
IMAGE_NAME="NIGHTHAWK-orangepizero3-trixie"

log() { echo "[nighthawk-build] $(date -u +%Y-%m-%dT%H:%M:%SZ) $*"; }
die() { echo "[nighthawk-build][ERROR] $*" >&2; exit 1; }

mkdir -p "${LOG_DIR}" "${OUTPUT_DIR}"

# ---------------------------------------------------------------- 1. Host checks
log "Step 1/6: checking build host"
HOST_ARCH="$(uname -m)"
case "${HOST_ARCH}" in
  x86_64|aarch64) ;;
  *) die "Unsupported build host architecture '${HOST_ARCH}'. This script must run on an x86_64 or aarch64 Linux host (native or WSL2/Docker)." ;;
esac
log "Host architecture OK: ${HOST_ARCH}"

MEM_TOTAL_KB="$(awk '/^MemTotal:/ {print $2}' /proc/meminfo | awk '{print $1}')"
MEM_AVAIL_KB="$(awk '/^MemAvailable:/ {print $2}' /proc/meminfo | awk '{print $1}')"
MEM_TOTAL_GB="$(awk "BEGIN {printf \"%.2f\", ${MEM_TOTAL_KB}/1048576}")"
MEM_AVAIL_GB="$(awk "BEGIN {printf \"%.2f\", ${MEM_AVAIL_KB}/1048576}")"
log "Memory: total=${MEM_TOTAL_GB}GB available=${MEM_AVAIL_GB}GB"
if [ "${MEM_AVAIL_KB}" -lt 8388608 ]; then
  die "Not enough build host memory: only ${MEM_AVAIL_GB}GB available. Armbian builds require at least ~8GB free RAM."
fi

DISK_FREE_KB="$(df -Pk / 2>/dev/null | awk 'NR==2 {print $4}')"
DISK_FREE_GB="$(awk "BEGIN {printf \"%.1f\", ${DISK_FREE_KB}/1048576}")"
log "Free disk space on /: ${DISK_FREE_GB}GB"
if ! [[ "${DISK_FREE_KB}" =~ ^[0-9]+$ ]]; then
  die "Disk space detection failed: 'df -Pk /' did not return a numeric value (got '${DISK_FREE_KB}')."
fi
DISK_FREE_BYTES=$((DISK_FREE_KB * 1024))
if [ "${DISK_FREE_BYTES}" -lt 52428800 ]; then
  die "LOW DISK SPACE WARNING: only ${DISK_FREE_GB}GB free. Armbian builds require at least ~50GB free. Aborting."
fi

# ---------------------------------------------------------------- 2. Dependencies
log "Step 2/6: checking required build dependencies"
for cmd in git docker make gcc g++ awk; do
  if ! command -v "${cmd}" >/dev/null 2>&1; then
    die "Required build dependency '${cmd}' was not found in PATH."
  fi
done
if ! docker info >/dev/null 2>&1; then
  die "Docker daemon is not running or not accessible. Start Docker and re-run this script."
fi
log "Required build dependencies OK"

# ---------------------------------------------------------------- 3. Armbian framework
log "Step 3/6: preparing official Armbian build framework"
if [ ! -f "${ARMBIAN_BUILD_DIR}/compile.sh" ]; then
  log "Cloning Armbian build framework into ${ARMBIAN_BUILD_DIR}"
  mkdir -p "${BUILD_WORKSPACE_DIR}"
  git clone --depth 1 https://github.com/armbian/build.git "${ARMBIAN_BUILD_DIR}"
fi
if [ ! -f "${ARMBIAN_BUILD_DIR}/userpatches/config-nighthawk.conf" ]; then
  mkdir -p "${ARMBIAN_BUILD_DIR}/userpatches"
  cp -a "${SCRIPT_DIR}/userpatches/." "${ARMBIAN_BUILD_DIR}/userpatches/"
fi

log "Assembling NIGHTHAWK overlay from feature sources"
OVERLAY="${ARMBIAN_BUILD_DIR}/userpatches/overlay"
mkdir -p \
  "${OVERLAY}/etc/profile.d" \
  "${OVERLAY}/etc/motd.d" \
  "${OVERLAY}/etc/sysctl.d" \
  "${OVERLAY}/etc/systemd/system" \
  "${OVERLAY}/etc/systemd/system/nighthawk.service.d" \
  "${OVERLAY}/etc/ssh/sshd_config.d" \
  "${OVERLAY}/etc/lightdm" \
  "${OVERLAY}/usr/share/themes/NightHawk/gtk-3.0" \
  "${OVERLAY}/usr/share/themes/NightHawk/gtk-2.0" \
  "${OVERLAY}/usr/share/icons/NightHawk" \
  "${OVERLAY}/usr/share/applications/nighthawk" \
  "${OVERLAY}/usr/share/backgrounds/nighthawk"
cp -a "${SCRIPT_DIR}/terminal/bashrc" "${OVERLAY}/etc/bash.bashrc"
cp -a "${SCRIPT_DIR}/terminal/motd" "${OVERLAY}/etc/motd"
cp -a "${SCRIPT_DIR}/terminal/banner.txt" "${OVERLAY}/etc/motd.d/00-nighthawk"
cp -a "${SCRIPT_DIR}/terminal/profile.d/nighthawk.sh" "${OVERLAY}/etc/profile.d/nighthawk.sh"
cp -a "${SCRIPT_DIR}/desktop/lightdm/lightdm.conf" "${OVERLAY}/etc/lightdm/lightdm.conf"
cp -a "${SCRIPT_DIR}/desktop/xfce/theme/gtk-3.0/." "${OVERLAY}/usr/share/themes/NightHawk/gtk-3.0/"
cp -a "${SCRIPT_DIR}/desktop/xfce/theme/gtk-2.0/." "${OVERLAY}/usr/share/themes/NightHawk/gtk-2.0/"
cp -a "${SCRIPT_DIR}/branding/icons/." "${OVERLAY}/usr/share/icons/NightHawk/"
cp -a "${SCRIPT_DIR}/branding/png/." "${OVERLAY}/usr/share/backgrounds/nighthawk/"
mkdir -p "${OVERLAY}/nighthawk-packages"
cp -a "${SCRIPT_DIR}/pkg-lists/." "${OVERLAY}/nighthawk-packages/"
printf 'nighthawk\n' > "${OVERLAY}/etc/hostname"
cp -a "${SCRIPT_DIR}/userpatches/overlay/etc/ssh/sshd_config.d/." "${OVERLAY}/etc/ssh/sshd_config.d/"
cp -a "${SCRIPT_DIR}/browser/firefox/policies.json" "${OVERLAY}/etc/firefox-esr/policies.json"
mkdir -p "${OVERLAY}/usr/local/bin"
cp -a "${SCRIPT_DIR}/security/scripts/." "${OVERLAY}/usr/local/bin/"
chmod +x "${OVERLAY}/usr/local/bin/"nighthawk-*.sh
cp -a "${SCRIPT_DIR}/userpatches/overlay/etc/sysctl.d/99-nighthawk.conf" "${OVERLAY}/etc/sysctl.d/99-nighthawk.conf"
cp -a "${SCRIPT_DIR}/userpatches/overlay/etc/systemd/zram-generator.conf" "${OVERLAY}/etc/systemd/zram-generator.conf"
log "NIGHTHAWK overlay assembled"

log "Armbian build framework ready at ${ARMBIAN_BUILD_DIR}"

# ---------------------------------------------------------------- 4. Build
log "Step 4/6: running Armbian build (this can take several hours)"
cd "${ARMBIAN_BUILD_DIR}"
ARMBIAN_BUILD_COMMIT="$(git -C "${ARMBIAN_BUILD_DIR}" rev-parse HEAD)"
./compile.sh build nighthawk 2>&1 | tee "${LOG_DIR}/armbian-compile-${IMAGE_DATE}.log"

# ---------------------------------------------------------------- 5. Collect image + checksum
log "Step 5/6: collecting build artifacts"
mapfile -t IMAGES < <(find "${ARMBIAN_BUILD_DIR}/build/output/images" -maxdepth 1 \( -name '*.img' -o -name '*.img.gz' \) -type f 2>/dev/null | sort)
if [ "${#IMAGES[@]}" -ne 1 ]; then
  die "Expected exactly one Armbian image in build/output/images, found ${#IMAGES[@]}."
fi
SOURCE_IMAGE="${IMAGES[0]}"
case "${SOURCE_IMAGE}" in
  *.img.gz)
    SOURCE_IMAGE="${SOURCE_IMAGE%.img.gz}.img"
    gunzip -c "${IMAGES[0]}" > "${SOURCE_IMAGE}"
    ;;
esac
FINAL_IMAGE="${OUTPUT_DIR}/${IMAGE_NAME}-${IMAGE_DATE}.img"
cp "${SOURCE_IMAGE}" "${FINAL_IMAGE}"
FINAL_SHA256_FILE="${FINAL_IMAGE}.sha256"
sha256sum "${FINAL_IMAGE}" > "${FINAL_SHA256_FILE}"

# ---------------------------------------------------------------- 6. Build report
log "Step 6/6: writing build report"
BUILD_REPORT="${OUTPUT_DIR}/BUILD-REPORT-${IMAGE_DATE}.md"
cat > "${BUILD_REPORT}" <<EOF
# NIGHTHAWK OS Build Report

- **Date:** $(date -u)
- **Board:** Orange Pi Zero 3 (Allwinner H618, ARM64) - \`${BOARD}\`
- **Userland:** Debian ${RELEASE} Trixie
- **Kernel:** Armbian current (H618)
- **Desktop:** XFCE (${DESKTOP_ENVIRONMENT}, tier ${DESKTOP_TIER})
- **Build host:** $(uname -sm)
- **Armbian framework commit:** ${ARMBIAN_BUILD_COMMIT}

## Status

- Host architecture check: PASS (\`${HOST_ARCH}\`)
- Memory check: PASS (total ${MEM_TOTAL_GB}GB, available ${MEM_AVAIL_GB}GB)
- Disk space check: PASS (${DISK_FREE_GB}GB free)
- Dependencies check: PASS
- Armbian build: see \`build/logs/armbian-compile-${IMAGE_DATE}.log\`

## Image

- Source: ${SOURCE_IMAGE}
- Artifact: ${FINAL_IMAGE}
- SHA256: $(cat ${FINAL_SHA256_FILE})

## Notes

- Generated by: \`./build.sh\`
EOF

log "Build artifacts:"
ls -la "${OUTPUT_DIR}"

echo "[nighthawk-build] BUILD OK: ${FINAL_IMAGE}"

#!/bin/bash
#
# NIGHTHAWK OS - Armbian image customization script
#
# Runs inside the target rootfs chroot, right before the Armbian image is
# finalized. Installs the NIGHTHAWK package groups (authoritative definitions
# live in pkg-lists/*.list, copied into the image overlay as
# /tmp/overlay/nighthawk-packages/*.list) and applies baked-in settings.

set -e

export DEBIAN_FRONTEND=noninteractive
OVERLAY="${OVERLAY:-/tmp/overlay}"
PKG_DIR="${OVERLAY}/nighthawk-packages"
LOGDIR="/tmp/nighthawk-customize"
mkdir -p "${LOGDIR}"

log() { echo "[nighthawk-customize] $(date -u +%FT%TZ) $*"; }

log "Updating APT package lists"
apt-get update

log "Installing NIGHTHAWK OS package groups (pkg-lists are authoritative)"
shopt -s nullglob
for list in "${PKG_DIR}"/*.list; do
  base="$(basename "${list}")"
  case "${base}" in
    50-*)
      log "Skipping optional security group ${base}"
      continue
      ;;
  esac
  pkgs="$(grep -vE '^[[:space:]]*(#|$)' "${list}" | tr -d '[:space:]' | tr '\n' ' ')"
  if [ -n "${pkgs}" ]; then
    log "Installing packages from ${base}: ${pkgs}"
    apt-get install -y --no-install-recommends ${pkgs}
  fi
done

log "Installing NIGHTHAWK memory optimizations"
cat > /etc/sysctl.d/99-nighthawk.conf <<'EOF'
# NIGHTHAWK OS - memory tuning (Orange Pi Zero 3, 2GB RAM class)
vm.swappiness = 10
vm.vfs_cache_pressure = 50
vm.dirty_background_ratio = 5
vm.dirty_ratio = 10
EOF
cat > /etc/systemd/zram-generator.conf <<'EOF'
# NIGHTHAWK OS - zram swap configuration
[zram0]
zram-size = ram / 4
EOF

log "Applying NIGHTHAWK security baseline"
mkdir -p /etc/ssh/sshd_config.d
cat > /etc/ssh/sshd_config.d/99-nighthawk.conf <<'EOF'
PermitRootLogin no
PubkeyAuthentication yes
EOF

log "Copying NIGHTHAWK overlay files into image rootfs"
if [ -d "${OVERLAY}" ]; then
  cp -a "${OVERLAY}/." /
else
  log "WARNING: overlay directory ${OVERLAY} not found - skipping overlay copy"
fi

log "NightHawk image customization completed"

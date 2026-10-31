#!/usr/bin/env bash
# NIGHTHAWK OS - automated build/test checks
set -uo pipefail

SRC="${BASH_SOURCE[0]}"
SRC_DIR="${SRC%/*}"
REPO="${SRC_DIR%/tests}"
FAILURES=0

pass() { echo "[nkh-tests] PASS: $*"; }
fail() { echo "[nkh-tests] FAIL: $*" >&2; FAILURES=$((FAILURES + 1)); }

bash_n_check() {
  local f="$1"
  if bash -n "$f" 2>/dev/null; then
    pass "bash syntax OK: $(basename "$f")"
  else
    fail "bash syntax error: ${f}"
  fi
}

# 1. Build script
if [ -f "${REPO}/build.sh" ]; then bash_n_check "${REPO}/build.sh"; else fail "missing ${REPO}/build.sh"; fi

# 2. Armbian userpatches
if [ -f "${REPO}/userpatches/customize-image.sh" ]; then bash_n_check "${REPO}/userpatches/customize-image.sh"; else fail "missing userpatches/customize-image.sh"; fi
if [ -f "${REPO}/userpatches/extensions/preset-firstrun.sh" ]; then bash_n_check "${REPO}/userpatches/extensions/preset-firstrun.sh"; else fail "missing userpatches/extensions/preset-firstrun.sh"; fi
if [ -f "${REPO}/userpatches/firstboot.conf" ]; then pass "firstboot.conf present"; else fail "missing userpatches/firstboot.conf"; fi
if [ -f "${REPO}/userpatches/config-nighthawk.conf" ]; then pass "config-nighthawk.conf present"; else fail "missing userpatches/config-nighthawk.conf"; fi
if grep -q 'BOARD="orangepizero3"' "${REPO}/userpatches/config-nighthawk.conf" 2>/dev/null; then pass "Armbian board = orangepizero3"; else fail "Armbian board mismatch"; fi
if grep -q 'RELEASE="trixie"' "${REPO}/userpatches/config-nighthawk.conf" 2>/dev/null; then pass "Release = trixie"; else fail "Release mismatch"; fi
if grep -q 'DESKTOP_ENVIRONMENT="xfce"' "${REPO}/userpatches/config-nighthawk.conf" 2>/dev/null; then pass "Desktop = xfce"; else fail "Desktop mismatch"; fi

# 3. Package lists
for f in "${REPO}/pkg-lists/"*.list; do
  if [ -s "$f" ]; then pass "package list non-empty: $(basename "$f")"; else fail "package list empty: ${f}"; fi
done
for f in "${REPO}/pkg-lists/"[1-4]*.list; do
  if [ -s "$f" ]; then pass "core package group non-empty: $(basename "$f")"; else fail "core package group empty: ${f}"; fi
done
if [ -f "${REPO}/pkg-lists/50-security-optional.list" ]; then pass "optional security group present"; else fail "missing optional security group"; fi

# 4. Branding
for f in mascot.svg logo.svg wallpaper.svg icons/index.theme; do
  if [ -f "${REPO}/branding/${f}" ]; then pass "branding asset present: ${f}"; else fail "missing branding asset: ${f}"; fi
done
if grep -q '<svg' "${REPO}/branding/mascot.svg" 2>/dev/null; then pass "mascot.svg is SVG"; else fail "mascot.svg invalid"; fi
if grep -q 'Name=NightHawk' "${REPO}/branding/icons/index.theme" 2>/dev/null; then pass "icon theme Name=NightHawk"; else fail "icon theme mismatch"; fi
if [ -f "${REPO}/branding/png/nighthawk-wallpaper.png" ]; then pass "generated wallpaper PNG present"; else fail "missing generated wallpaper PNG"; fi
if [ -f "${REPO}/branding/ascii/nighthawk-banner.txt" ]; then pass "ASCII banner present"; else fail "missing ASCII banner"; fi

# 5. Desktop theme
if grep -q '@define-color accent #e10613' "${REPO}/desktop/xfce/theme/gtk-3.0/gtk.css" 2>/dev/null; then pass "GTK3 accent crimson"; else fail "GTK3 accent missing"; fi
if [ -f "${REPO}/desktop/xfce/theme/gtk-2.0/gtkrc" ]; then pass "GTK2 theme rc present"; else fail "missing GTK2 theme rc"; fi

# 6. Terminal
if grep -q 'PS1=' "${REPO}/terminal/profile.d/nighthawk.sh" 2>/dev/null; then pass "terminal prompt configured"; else fail "terminal prompt missing"; fi
if [ -f "${REPO}/terminal/bashrc" ]; then pass "terminal bashrc present"; else fail "missing terminal bashrc"; fi
if [ -f "${REPO}/terminal/motd" ]; then pass "terminal motd present"; else fail "missing terminal motd"; fi
if [ -f "${REPO}/terminal/banner.txt" ]; then pass "terminal ASCII banner present"; else fail "missing terminal ASCII banner"; fi

# 7. Browser
if grep -q 'browser.startup.homepage' "${REPO}/browser/firefox/user.js" 2>/dev/null; then pass "firefox user.js present"; else fail "firefox user.js missing"; fi
if grep -q 'DisableDefaultBrowserCheck' "${REPO}/browser/firefox/policies.json" 2>/dev/null; then pass "firefox policies present"; else fail "firefox policies missing"; fi
if [ -f "${REPO}/browser/firefox/policies.json" ]; then pass "firefox policies file present"; else fail "missing firefox policies file"; fi

# 8. Security scripts
for f in "${REPO}/security/scripts/"*.sh; do
  if [ -f "$f" ]; then bash_n_check "$f"; else fail "missing security script: ${f}"; fi
done

# 9. Build script content checks
if grep -q 'compile.sh build nighthawk' "${REPO}/build.sh" 2>/dev/null; then pass "build.sh uses ./compile.sh build nighthawk"; else fail "build.sh missing ./compile.sh build nighthawk invocation"; fi
if grep -q 'tee "${LOG_DIR}' "${REPO}/build.sh" 2>/dev/null; then pass "build.sh streams build output via tee"; else fail "build.sh missing tee log streaming"; fi
if grep -q 'sha256sum "${FINAL_IMAGE}" > "${FINAL_SHA256_FILE}"' "${REPO}/build.sh" 2>/dev/null; then pass "build.sh generates sha256sum -c compatible checksum"; else fail "build.sh missing sha256sum -c compatible checksum generation"; fi
if grep -q 'ARMBIAN_BUILD_COMMIT' "${REPO}/build.sh" 2>/dev/null; then pass "build.sh records Armbian framework commit"; else fail "build.sh missing Armbian commit recording"; fi
if grep -q 'gunzip -c' "${REPO}/build.sh" 2>/dev/null; then pass "build.sh handles compressed image outputs"; else fail "build.sh missing compressed image handling"; fi
if grep -q 'nighthawk-packages' "${REPO}/build.sh" 2>/dev/null; then pass "build.sh copies pkg-lists into overlay"; else fail "build.sh missing pkg-lists overlay copy"; fi

# 10. Baked-in configuration files exist
for f in \
  terminal/bashrc \
  terminal/motd \
  terminal/banner.txt \
  terminal/profile.d/nighthawk.sh \
  desktop/lightdm/lightdm.conf \
  desktop/xfce/theme/gtk-3.0/gtk.css \
  desktop/xfce/theme/gtk-2.0/gtkrc \
  branding/icons/index.theme \
  branding/png/nighthawk-wallpaper.png \
  browser/firefox/policies.json \
  userpatches/overlay/etc/ssh/sshd_config.d/99-nighthawk.conf \
  userpatches/overlay/etc/systemd/zram-generator.conf \
  userpatches/overlay/etc/sysctl.d/99-nighthawk.conf; do
  if [ -f "${REPO}/${f}" ]; then pass "baked-in file present: ${f}"; else fail "missing baked-in file: ${f}"; fi
done

# 11. SSH safety configuration
if grep -q 'PermitRootLogin no' "${REPO}/userpatches/overlay/etc/ssh/sshd_config.d/99-nighthawk.conf" 2>/dev/null; then pass "sshd PermitRootLogin no"; else fail "sshd PermitRootLogin missing"; fi
if grep -q 'PubkeyAuthentication yes' "${REPO}/userpatches/overlay/etc/ssh/sshd_config.d/99-nighthawk.conf" 2>/dev/null; then pass "sshd PubkeyAuthentication yes"; else fail "sshd PubkeyAuthentication missing"; fi
if grep -q 'PasswordAuthentication' "${REPO}/userpatches/overlay/etc/ssh/sshd_config.d/99-nighthawk.conf" 2>/dev/null; then fail "sshd must not disable password auth before first key"; else pass "sshd keeps password auth policy untouched"; fi

# 12. Memory optimization configuration
if grep -q 'zram-size' "${REPO}/userpatches/overlay/etc/systemd/zram-generator.conf" 2>/dev/null; then pass "zram-generator configured"; else fail "zram-generator missing"; fi
if grep -q 'vm.swappiness' "${REPO}/userpatches/overlay/etc/sysctl.d/99-nighthawk.conf" 2>/dev/null; then pass "sysctl swappiness tuned"; else fail "sysctl swappiness missing"; fi

# 13. First boot must stay interactive (no preset credentials)
if grep -q 'PRESET_USER_PASSWORD=""' "${REPO}/userpatches/firstboot.conf" 2>/dev/null; then pass "firstboot has no preset user password"; else fail "firstboot preset user password must stay empty"; fi
if grep -q 'PRESET_ROOT_PASSWORD=""' "${REPO}/userpatches/firstboot.conf" 2>/dev/null; then pass "firstboot has no preset root password"; else fail "firstboot preset root password must stay empty"; fi

# 14. Customize script installs from authoritative lists
if grep -q 'nighthawk-packages' "${REPO}/userpatches/customize-image.sh" 2>/dev/null; then pass "customize installs from nighthawk-packages"; else fail "customize missing nighthawk-packages install path"; fi
if grep -q 'apt-get install -y --no-install-recommends' "${REPO}/userpatches/customize-image.sh" 2>/dev/null; then pass "customize uses --no-install-recommends"; else fail "customize missing --no-install-recommends"; fi

echo
if [ "${FAILURES}" -eq 0 ]; then
  echo "[nkh-tests] ALL CHECKS PASSED"
  exit 0
else
  echo "[nkh-tests] ${FAILURES} CHECK(S) FAILED" >&2
  exit 1
fi

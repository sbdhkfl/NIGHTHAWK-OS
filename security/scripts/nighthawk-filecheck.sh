#!/bin/bash
# NIGHTHAWK OS - file integrity helper
# Compares current file hashes against a stored NIGHTHAWK baseline.
# Baseline creation:
#   nighthawk-filecheck.sh --create /etc/nighthawk-baseline.sha256
# Verification:
#   nighthawk-filecheck.sh --verify /etc/nighthawk-baseline.sha256
set -euo pipefail

BASELINE=""
MODE="verify"

usage() {
  echo "Usage: nighthawk-filecheck.sh --create <baseline> | --verify <baseline>"
  exit 2
}

while [ "$#" -gt 0 ]; do
  case "$1" in
    --create) MODE="create"; shift ;;
    --verify) MODE="verify"; shift ;;
    *) usage ;;
  esac
done

[ "$#" -eq 1 ] || usage
BASELINE="$1"

if [ "${MODE}" = "create" ]; then
  find /etc /usr/local /var/lib/nighthawk -type f \
    -not -path '/etc/mtab' -not -path '/etc/ld.so.cache' -not -path '/proc/*' \
    -not -path '/sys/*' -not -path '/dev/*' -not -path '/tmp/*' \
    -exec sha256sum {} + 2>/dev/null | sort -k2 > "${BASELINE}"
  echo "NIGHTHAWK baseline created: ${BASELINE}"
  exit 0
fi

if [ ! -f "${BASELINE}" ];
  then
    echo "Baseline file not found: ${BASELINE}" >&2
    exit 1
fi

find /etc /usr/local /var/lib/nighthawk -type f \
  -not -path '/etc/mtab' -not -path '/etc/ld.so.cache' -not -path '/proc/*' \
  -not -path '/sys/*' -not -path '/dev/*' -not -path '/tmp/*' \
  -exec sha256sum {} + 2>/dev/null | sort -k2 > /tmp/nighthawk-now.sha256

if diff -q "${BASELINE}" /tmp/nighthawk-now.sha256 > /dev/null; then
  echo "NIGHTHAWK integrity check: PASS (no unexpected changes)"
  rm -f /tmp/nighthawk-now.sha256
  exit 0
else
  echo "NIGHTHAWK integrity check: FAIL - files differ from baseline" >&2
  diff "${BASELINE}" /tmp/nighthawk-now.sha256 | head -50 >&2 || true
  rm -f /tmp/nighthawk-now.sha256
  exit 1
fi

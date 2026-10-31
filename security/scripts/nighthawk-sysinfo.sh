#!/bin/bash
# NIGHTHAWK OS - system information helper
# Prints a compact, NIGHTHAWK-styled system status summary.
set -euo pipefail

RED='\033[1;31m'
BLACK='\033[0m'

echo -e "${RED} _  _   _  NIGHTHAWK OS${BLACK}"
echo -e "${RED} | || | | | | ___ / ___| |__  _ __${BLACK}"
echo -e "${RED} | || | | | |/ _ \| |   / _ \| '__|${BLACK}"
echo -e "${RED} | || | | | | (_) | |___| (_) |${BLACK}"
echo -e "${RED} |_| |_|\__,_|\___/ \____|\___/${BLACK}"
echo
uname -a
echo
echo "OS:      $(grep PRETTY_NAME /etc/os-release | cut -d= -f2- | tr -d '"')"
echo "Arch:    $(uname -m)"
echo "Kernel:  $(uname -r)"
echo "Uptime:  $(uptime)"
echo
free -h
echo
df -h
echo
echo "Temperature:"
if [ -r /sys/class/thermal/thermal_zone0/temp ]; then
  cat /sys/class/thermal/thermal_zone0/temp | awk '{printf "CPU temp: %.1f C\n", $1/1000}'
else
  echo "CPU temp: not available"
fi
echo
echo "Load average: $(cat /proc/loadavg)"
echo
echo "Listening services:"
ss -tulpn 2>/dev/null | grep -v -E 'State|State' || echo "  (none)"
echo
echo "NIGHTHAWK quick actions:"
echo "  sudo nighthawk-sysinfo   - full system info"
echo "  sudo lynis                - security audit"
echo "  sudo nmap localhost       - network scan"

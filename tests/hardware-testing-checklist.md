# NIGHTHAWK OS - Physical Hardware Testing Checklist

**Target hardware:** Orange Pi Zero 3, Allwinner H618, ARM64 (AArch64)
**RAM variants covered:** 2GB (primary) and 4GB (secondary)
**Image under test:** NIGHTHAWK OS Armbian build (`NIGHTHAWK-orangepizero3-trixie-*.img`)

This checklist is for testing on real hardware. Automated tests
(`tests/run-tests.sh`) run on the build host; everything below requires the
actual Orange Pi Zero 3.

## Pre-test

- [ ] Image SHA256 matches `releases/*.sha256` and `sha256sum -c` passes.
- [ ] Image written to microSD with `armbian-flasher`/RPi imager-compatible tool.
- [ ] microSD health OK (no corruption), card >= 16GB recommended.
- [ ] Board powered from stable 5V/3A supply (Power over Type-C).
- [ ] HDMI cable + monitor capable of 1080p (or 4K for Zero 3).
- [ ] USB keyboard + mouse (or USB host adapter) connected.
- [ ] Ethernet cable OR configured Wi-Fi credentials ready.

## Test procedure

| # | Item | Expected result | Result |
|---|------|-----------------|--------|
| 1 | Boot from microSD | NIGHTHAWK OS logo / kernel boot, no boot loop | ☐ |
| 2 | HDMI output | Boot console -> XFCE login -> desktop | ☐ |
| 3 | Keyboard | Input works in login, terminal, desktop | ☐ |
| 4 | Mouse | Pointer works, clicks register | ☐ |
| 5 | Ethernet | DHCP link, network manager shows connected | ☐ |
| 6 | Wi-Fi | Onboard Wi-Fi connects to SSID | ☐ |
| 7 | Bluetooth | Agent starts, device pairing works | ☐ |
| 8 | USB | USB mass storage / mouse / keyboard enumeration | ☐ |
| 9 | Browser | Firefox ESR launches, renders page, no crash | ☐ |
| 10 | XFCE | Desktop compositor off (performance), panel present | ☐ |
| 11 | Terminal | bash prompt, NIGHTHAWK banner, `nighthawk-sysinfo.sh` runs | ☐ |
| 12 | RAM usage | Idle < 400MB (2GB unit), < 900MB with browser | ☐ |
| 13 | CPU temperature | Thermal zone readable, no thermal throttling shutdown | ☐ |
| 14 | Shutdown | `sudo shutdown now` powers off cleanly | ☐ |
| 15 | Reboot | `sudo reboot` boots again fine | ☐ |

## Metrics to record

- Idle RAM (after boot, before desktop): ______ MB
- Idle RAM (after XFCE login): ______ MB
- RAM during light Firefox use: ______ MB
- CPU temperature at idle: ______ °C
- CPU temperature under load: ______ °C

## Notes / issues

- ...

---

# Physical hardware test results (fill in after testing)

Date: __________
Tester: __________
Board revision / RAM size (2GB / 4GB): __________
Image version / SHA256: __________
Result summary: __________

Any failures: _____________________________________________________

# NIGHTHAWK OS - APT package groups

- `10-core.list` - always installed (utilities, security core).
- `20-desktop.list` - always installed (XFCE4 desktop, display manager, networking, browser).
- `30-browser.list` - always installed (Firefox ESR).
- `40-security-core.list` - always installed (auditing, diagnostics, security tooling).
- `50-security-optional.list` - optional, NOT installed by default.

Optional security tools are installed explicitly, e.g.:

```bash
sudo apt install nftables btop htop tshark fail2ban
```

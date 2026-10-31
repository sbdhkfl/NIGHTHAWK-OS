# NIGHTHAWK OS — Security Posture

## Defaults applied in the image

- Root password: not preset (interactive first boot).
- Root SSH login: disabled (`/etc/ssh/sshd_config.d/99-nighthawk.conf`).
- SSH password authentication: disabled (public key auth only).
- Firewall: UFW installed; enabled post-first-boot via `sudo ufw enable`.
- No telemetry shipped or enabled by default.
- No automatic browser startup.

## First boot

- Interactive account setup (username, password, real name).
- No default/shared passwords.
- SSH host keys regenerated on first boot by Armbian firstrun.

## Updates

```bash
sudo apt update && sudo apt upgrade -y
sudo apt install --only-upgrade unattended-upgrades  # optional
```

## Security toolkit

Core (installed in image): Lynis, UFW, Nmap, Tcpdump, DNS utils, Python3 + venv, Git, curl/wget, OpenSSH.

Optional groups (`pkg-lists/50-security-optional.list`): nftables, btop, htop, tshark, fail2ban — install explicitly via apt.

## Useful commands

```bash
sudo lynis                # security audit
sudo nmap <target>        # network inventory
sudo tcpdump -i eth0     # packet capture
sudo ufw status           # firewall status
sudo fail2ban-client status  (if installed)
```

## Privacy

- No telemetry.
- No auto network connections beyond NetworkManager managed defaults.

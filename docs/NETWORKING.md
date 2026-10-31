# NIGHTHAWK OS — Networking Guide

## Default state

- NetworkManager manages Ethernet + Wi-Fi interfaces.
- No automatic connections are pre-provisioned (secure default; first boot is interactive).
- No unnecessary listening services are enabled by default.

## Ethernet

```bash
ip link        # check interface exists (eth0 / enp...)
sudo dhclient eth0   # or use NetworkManager: nmtui / nm-connection-edit
```

## Wi-Fi

On first boot (or after creating an account):

```bash
nmtui   # Text-based NetworkManager user interface
# or
nm-connection-edit <SSID>
```

Or via desktop applet.

## Firewall

```bash
sudo ufw status
sudo ufw enable
sudo ufw allow ssh
```

## DNS

- Default via NetworkManager / systemd-resolved (or resolv.conf).
- Manual: edit /etc/resolv.conf or netplan/NetworkManager settings.

## Bluetooth

- Disabled by default service-wise; enable with:

```bash
sudo systemctl enable bluetooth
sudo systemctl start bluetooth
```

## Simple troubleshooting

```bash
sudo systemctl status NetworkManager
sudo iwconfig        # wireless tools
sudo iwlist wlan0 scan
```

See also: [tests/hardware-testing-checklist.md](../tests/hardware-testing-checklist.md) for Wi-Fi bring-up on hardware.

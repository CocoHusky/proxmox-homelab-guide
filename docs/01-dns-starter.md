# 01 - DNS Starter With Pi-hole and Unbound

## Goal

Set up a small first DNS service before the main server build.
This gives you ad blocking, local recursive DNS, and a clean place to point remote devices later.

## What this covers

- Raspberry Pi OS Lite on a small Raspberry Pi
- Pi-hole for DNS filtering
- Unbound as the recursive resolver
- Tailscale for remote DNS access

## What you need

- Raspberry Pi Zero 2 W or similar small single-board computer
- microSD card
- Power supply
- Wi-Fi network details
- A computer on the same network for SSH

## Flash Raspberry Pi OS

Use Raspberry Pi Imager and enable headless access during setup.

Set:

- Hostname: `pihole`
- Username: your admin username
- Password: a strong password
- Wi-Fi SSID and password
- Locale and time zone
- SSH enabled

Give the Pi a few minutes to boot before connecting.

## Connect to the Pi

Try mDNS first:

```bash
ssh <USERNAME>@pihole.local
```

If that does not work, use the Pi's LAN address from your router:

```bash
ssh <USERNAME>@<PI_LAN_IP>
```

Update the Pi:

```bash
sudo apt update
sudo apt upgrade -y
sudo reboot
```

## Install Pi-hole

Install Pi-hole with the official installer:

```bash
curl -sSL https://install.pi-hole.net | bash
```

During setup, choose:

- Static IP or a router reservation
- A temporary upstream DNS provider for now
- Web admin interface enabled
- Web server enabled
- Query logging enabled

Set the Pi-hole password:

```bash
pihole setpassword
```

Open the admin page:

```text
http://pihole.local/admin
```

Or use the LAN IP:

```text
http://<PI_LAN_IP>/admin
```

## Install and configure Unbound

Install Unbound:

```bash
sudo apt install -y unbound
sudo systemctl enable unbound
```

Create the Unbound config:

```bash
sudo nano /etc/unbound/unbound.conf.d/pi-hole.conf
```

Use a local-only resolver on port `5335`:

```conf
server:
    verbosity: 0

    interface: 127.0.0.1
    port: 5335

    do-ip4: yes
    do-udp: yes
    do-tcp: yes

    do-ip6: no
    prefer-ip6: no

    harden-glue: yes
    harden-dnssec-stripped: yes
    use-caps-for-id: no

    edns-buffer-size: 1232
    prefetch: yes
    num-threads: 1

    private-address: 192.168.0.0/16
    private-address: 169.254.0.0/16
    private-address: 172.16.0.0/12
    private-address: 10.0.0.0/8
    private-address: fd00::/8
    private-address: fe80::/10
```

Restart and test:

```bash
sudo unbound-checkconf
sudo systemctl restart unbound
dig pi-hole.net @127.0.0.1 -p 5335
```

In Pi-hole, set the only upstream DNS server to:

```text
127.0.0.1#5335
```

## Tailscale

Install Tailscale:

```bash
curl -fsSL https://tailscale.com/install.sh | sh
```

Bring the Pi online without letting it take DNS settings from Tailscale:

```bash
sudo tailscale up --accept-dns=false
```

Get the Pi's Tailscale IP:

```bash
tailscale ip -4
```

Use that address in the Tailscale admin console as a custom DNS server and enable DNS override.

## Pi-hole interface setting

In Pi-hole, set the interface option so the DNS service accepts requests from your trusted network and Tailscale clients.

## Validation

- Pi-hole admin page loads
- Unbound answers on `127.0.0.1#5335`
- Pi-hole upstream DNS points only to Unbound
- Tailscale shows the Pi as connected
- Another device can resolve through the Pi

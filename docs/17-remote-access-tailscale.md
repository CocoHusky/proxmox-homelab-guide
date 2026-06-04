# 17 - Remote Access With Tailscale

## Purpose

This is the last step in the guide.
Do not do this until the local-network build, backups, and restore checks are already working.

## Where to run this

- VM or CT that you want to reach from outside home: run the install there.
- Proxmox host: use the addon helper if you want Tailscale on a CT.
- A device outside the home network: verify access.

## What to use it for

- Access a VM or CT when you are away from home
- Avoid exposing raw LAN IPs to the internet
- Keep the core lab private and only expose specific services

## Simple remote-access pattern

Use the simplest option that matches the service:

- Full shell access: install Tailscale on the VM or CT and use `tailscale up --ssh`.
- One web app: use `tailscale serve` on that one VM or CT.
- A CT that should stay managed from Proxmox: use the LXC addon helper and then verify the node in the tailnet.

Do not put every VM and CT on Tailscale just because you can. Add only the services you want reachable away from home.

## Install on a VM or CT

Run this inside the VM or CT you want to expose:

```bash
sudo apt update
sudo apt install -y curl
curl -fsSL https://tailscale.com/install.sh | sh
sudo systemctl enable --now tailscaled
sudo tailscale up
sudo tailscale status
sudo tailscale ip -4
```

What this does:

- Installs the Tailscale client
- Starts the daemon
- Joins the device to your tailnet
- Shows the tailnet address you can use to reach it

If you are building this for a friend, have them log in to the tailnet only after the local service works on the LAN. That keeps remote access from hiding an installation problem.

## SSH access

If you want SSH over Tailscale:

```bash
sudo tailscale up --ssh
sudo tailscale status
```

This is useful when you want the device to accept SSH only through Tailscale rather than on the raw LAN interface.

## Browser exposure for one service

```bash
sudo tailscale serve reset
sudo tailscale serve --bg http://127.0.0.1:<APP_PORT>
sudo tailscale serve status
```

Use this when you want the service reachable from your tailnet but not directly exposed on the public internet.

Common patterns:

- Nextcloud or Immich: keep the app listening locally and expose it through Serve only if that matches your remote plan
- Vaultwarden: keep access limited unless you really need remote password access
- Sandbox VMs: usually skip remote exposure entirely

## LXC addon helper

If the target is a CT and you want the addon flow, use the community-scripts helper from the Proxmox host shell:

```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/community-scripts/ProxmoxVE/main/tools/addon/add-tailscale-lxc.sh)"
```

After the addon helper finishes, verify the CT has a tailnet IP and the service still starts normally.

## Suggested rollout order

1. Make the service work on the local network.
2. Add Tailscale only to that one VM or CT.
3. Confirm the tailnet IP or SSH path works.
4. Only then consider exposing the next service.

## Validation

- `tailscale status` shows the node as connected
- `tailscale ip -4` returns a tailnet IP
- The service is reachable from outside the home network
- The local-network path still works
- Only the intended service is reachable over Tailscale

## Final rule

Only add Tailscale to the specific VM or CT you need remotely.
Leave the rest of the lab local-only unless you have a reason to expose it too.

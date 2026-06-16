# 11 - Nginx Proxy Manager Proxy CT

## Purpose

This CT handles host-based routing and TLS termination.
If you want clean hostnames for the lab, this is the layer that makes that happen.

## Where to run this

- Proxmox host: create or inspect the Proxy CT.
- Proxmox host shell: run the community-scripts helper.
- Proxy CT shell: verify the admin UI and proxy host list.
- Browser: create proxy hosts from the local network.

## Current build snapshot

- CT role: Proxy CT
- CTID: `110`
- Known app ports: `80`, `443`, `81`
- This is the ingress layer for LAN-friendly hostnames and TLS. Add it after the core app stack is working so you do not spend time debugging a proxy before the app exists.

## Community script install

Use NPMplus, which is the community-scripts maintained enhanced proxy manager build:

```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/community-scripts/ProxmoxVE/main/ct/npmplus.sh)"
```

If you prefer stock Nginx Proxy Manager, replace the image or helper with your own manual install, but keep the same role and ports.

## Capture the exact CT settings

Run this on the Proxmox host:

```bash
pct config 110 | rg '^(cores|memory|swap|rootfs|mp|net0|features|unprivileged|onboot):'
pct exec 110 -- sh -lc 'docker ps -a 2>/dev/null || true; docker compose ls 2>/dev/null || true'
```

## Install path

1. Create the CT with the helper or through Proxmox.
2. Open the admin UI on port `81`.
3. Change the default admin password if the helper exposes one.
4. Add proxy hosts for the services you want reachable on the LAN.
5. Add TLS certificates when the upstream services are stable.
6. Keep the upstream service on the local network while you are still building the lab.

## Suggested first proxy hosts

Start with the services people actually click:

- `nextcloud.<your-lan-name>`
- `immich.<your-lan-name>`
- `vaultwarden.<your-lan-name>`
- `homarr.<your-lan-name>`

For each proxy host, fill in:

- Domain name
- Scheme (`http` or `https`)
- Forward host or IP
- Forward port
- Websocket support if the app needs it
- SSL settings if the service is public or you have local certificates

If you only want LAN access, you can keep this layer simple and skip public certificate work until you have a real domain strategy.

## Example proxy host flow

1. Open the admin UI.
2. Add a new proxy host.
3. Point it at the app's actual internal IP and port.
4. Save.
5. Open the friendly hostname in a browser.
6. Confirm the app still works after a restart.

## When to add TLS

- Add TLS after the upstream service is stable.
- Add a certificate only when the hostname and path are final.
- Do not debug proxy rewrites and TLS errors at the same time unless you have to.

## Validation

- [ ] Admin UI opens
- [ ] Proxy host entries work
- [ ] Ports `80`, `443`, and `81` are correct
- [ ] The CT config matches `pct config 110`
- [ ] At least one friendly hostname reaches a working service
- [ ] The service still opens after proxying
- [ ] You know which upstream host and port each proxy entry points to

## Next step

After the proxy layer is working, continue to the Dashboard CT in [`./12-homarr-dashboard-ct.md`](./12-homarr-dashboard-ct.md).

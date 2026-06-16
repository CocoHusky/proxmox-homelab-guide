# 15 - Teslamate Telemetry CT

## Purpose

Teslamate stores Tesla telemetry.
It is optional and should come after the rest of the useful lab is already working.

## Where to run this

- Proxmox host: create or inspect the Telemetry CT.
- Telemetry CT shell: install Docker and the Teslamate stack.
- Browser: open the telemetry UI from the local network.

## Current build snapshot

- CT role: Telemetry CT
- CTID: `109`
- Known app port: capture from the container stack after install; document the published port in your local notes
- This service is optional. Treat it as a later add-on after the core lab is stable.

## What the stack usually includes

Teslamate is normally deployed as a small Docker stack, not just one binary:

- Teslamate application
- PostgreSQL for telemetry data
- Mosquitto or another message broker in the typical stack layout
- Grafana for dashboards and charts

Keep every persistent volume on storage that is part of your backup plan.

## Capture the exact CT settings

Run this on the Proxmox host:

```bash
pct config 109 | rg '^(cores|memory|swap|rootfs|mp|net0|features|unprivileged|onboot):'
pct exec 109 -- sh -lc 'docker ps -a 2>/dev/null || true; docker compose ls 2>/dev/null || true'
```

## Install path

1. Create the CT through Proxmox.
2. Install Docker inside the CT.
3. Deploy the Teslamate stack.
4. Keep the data path on storage that is part of your backup plan.
5. If you later expose it, place it behind a proxy or Tailscale rather than publishing a raw port directly.
6. Record the published port and the browser URL in your local notes after the stack is up.

If you want the first setup to stay simple, run the stack locally first, confirm the database and dashboard work, and only then decide whether you want to expose it at all.

## Docker bootstrap

Run this inside the CT if Docker is not already installed:

```bash
apt update
apt install -y ca-certificates curl gnupg docker.io docker-compose-plugin
systemctl enable --now docker
docker version
docker compose version
```

## Validation

- [ ] The telemetry stack starts
- [ ] The data path is on persistent storage
- [ ] The CT config matches `pct config 109`
- [ ] The published port is recorded in local notes
- [ ] The dashboard URL opens from the local network

## Next step

After telemetry, continue to the Sandbox VM in [`./16-sandbox-vm.md`](./16-sandbox-vm.md).

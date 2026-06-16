# 12 - Homarr Dashboard CT

## Purpose

Homarr gives you one dashboard for the lab.
It is useful, but not required for the lab to function.

## Where to run this

- Proxmox host: create or inspect the Dashboard CT.
- Proxmox host shell: run the community-scripts helper.
- Dashboard CT shell: verify the dashboard settings.
- Browser: add your service tiles from the local network.

## Current build snapshot

- CT role: Dashboard CT
- CTID: `104`
- Known app port: `7575`
- This layer is optional, but it becomes useful once you have enough services that remembering every URL is annoying.

## Community script install

Run this on the Proxmox host shell:

```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/community-scripts/ProxmoxVE/main/ct/homarr.sh)"
```

If you use the helper, verify the final CT config with `pct config 104`.

## Capture the exact CT settings

Run this on the Proxmox host:

```bash
pct config 104 | rg '^(cores|memory|swap|rootfs|mp|net0|features|unprivileged|onboot):'
pct exec 104 -- sh -lc 'docker ps -a 2>/dev/null || true; docker compose ls 2>/dev/null || true'
```

## Install path

1. Create the CT with the helper or through Proxmox.
2. Open Homarr in the browser.
3. Add tiles for the services you use most.
4. Keep the dashboard data in your backup plan.
5. Group the tiles by purpose so a new user can understand the lab at a glance.
6. Add links only after the service itself is confirmed working.

## Suggested tile groups

- Core services
  - Nextcloud AIO
  - Immich
  - Uptime Kuma
- Support services
  - Vaultwarden
  - Nginx Proxy Manager
- Optional services
  - Navidrome
  - Jellyfin
  - Teslamate

## Suggested dashboard workflow

1. Create one page for the whole lab.
2. Add the most important services first.
3. Add status colors or badges only after the URL is stable.
4. Put direct links in the dashboard so you can click into the service instead of typing URLs.
5. Keep the dashboard read-only unless you want to maintain a more advanced layout.

## Validation

- [ ] Homarr opens in the browser
- [ ] The dashboard saves and reloads
- [ ] The CT config matches `pct config 104`
- [ ] The important services are grouped clearly
- [ ] New users can understand the dashboard without explanation

## Next step

After the dashboard is in place, continue to the Music CT in [`./13-navidrome-music-ct.md`](./13-navidrome-music-ct.md).

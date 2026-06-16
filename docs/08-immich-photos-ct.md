# 08 - Immich Photos CT

## Purpose

Immich is the photo and video library for the lab.
It is one of the primary user-facing services, so it comes early in the build.

## Where to run this

- Proxmox host: create or inspect the Photos CT.
- Proxmox host shell: run the community-scripts helper.
- Photos CT shell: verify the app and storage paths.
- Browser: open the Immich web UI from the local network.

## Current build snapshot

- CT role: Photos CT
- CTID: `101`
- Known app port: `2283`
- This is the working role shape for the lab. If you choose different helper defaults, keep the same service layout and verify the final CT config before you rely on it.

## Community script install

Run this on the Proxmox host shell:

```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/community-scripts/ProxmoxVE/main/ct/immich.sh)"
```

If you use the helper, accept the defaults that match your lab shape and then verify the final CT config with `pct config 101`.

## Capture the exact CT settings

Run this on the Proxmox host:

```bash
pct config 101 | rg '^(cores|memory|swap|rootfs|mp|net0|features|unprivileged|onboot):'
pct exec 101 -- sh -lc 'docker ps -a 2>/dev/null || true; docker compose ls 2>/dev/null || true'
```

## Install path

1. Create the CT with the helper or through Proxmox.
2. Install Docker if the helper did not already do it.
3. Mount the shared photo library path into the CT.
4. Start Immich.
5. Open the web UI on the local network.
6. Create the first admin account.
7. Point uploads and library storage at the shared path, not the CT boot disk.
8. Decide whether you want external libraries or only uploads from phones and browsers.

## Docker bootstrap if you need it

Run this inside the Photos CT if Docker is not already present:

```bash
apt update
apt install -y ca-certificates curl gnupg docker.io docker-compose-plugin
systemctl enable --now docker
docker version
docker compose version
```

## Shared storage setup

Immich should live on a persistent path that survives container rebuilds.

Example approach:

1. Mount the shared photos dataset on the Proxmox host.
2. Bind that path into the Photos CT with a mount point.
3. Use the mounted path for the library or upload storage.

Example Proxmox mount point pattern:

```bash
pct set 101 -mp0 /mnt/pve/backups,mp=/photos
```

Replace the host path with the actual shared photos path you created for your lab.

If you are not sure whether the mount point is correct, check the CT config from the host:

```bash
pct config 101 | rg '^mp0:|^rootfs:|^net0:'
```

## First-run app setup

When Immich is up:

1. Open the web UI from the local network.
2. Create the first admin user.
3. Confirm the library path points at the mounted storage path.
4. Upload one test photo.
5. Confirm the photo still appears after a service restart.
6. If you use mobile uploads later, connect the phone only after the web UI and library path are stable.

## What to decide early

- Will this CT only store uploads, or also manage an existing photo library?
- Do you need external libraries now or later?
- Do you want the service behind a proxy or only on the local network for now?

## Validation

- [ ] The Immich web UI opens
- [ ] The photo library path is mounted correctly
- [ ] The CT is reachable on the local network
- [ ] The current config matches `pct config 101`
- [ ] The first admin account can log in
- [ ] A test upload survives a restart
- [ ] The mount point is on shared storage, not the CT boot disk

## Next step

After Immich is working, continue to the Monitoring CT in [`./09-uptime-kuma-monitoring-ct.md`](./09-uptime-kuma-monitoring-ct.md).

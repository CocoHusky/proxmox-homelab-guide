# 19 - Maintenance and Updates

## Purpose

This document gives you a simple once-a-month update routine for the Proxmox host, TrueNAS VM, CTs, VMs, and app containers.

The goal is not full blind automation. The goal is a repeatable maintenance path that tells you what is stale, updates the lower-risk operating system packages, and leaves high-risk app upgrades to their supported update flow.

## Where to run this

- Proxmox host: run the monthly maintenance script.
- TrueNAS web UI: update TrueNAS.
- Nextcloud AIO web UI: update Nextcloud AIO.
- App CT shell or app UI: update app-specific releases.
- Browser: verify services after updates.

## What Community Scripts does and does not do

Community Scripts is useful for creating many Proxmox LXCs and sometimes gives those LXCs an app-specific update helper.

If CT was generated using helper scripts from https://community-scripts.org
1. Confirm backups are healthy.
2. Log into the container and run `update`
3. Continue updating other VM and CT using steps bellow if not created with these helper scripts.

## Simple monthly flow

Run this order once a month, or whenever you want to catch up after a while:

1. Confirm backups are healthy.
2. Run the Proxmox maintenance script in report mode.
3. If the report looks normal, apply Proxmox host updates.
4. Reboot the Proxmox host only if updates require it.
5. Update TrueNAS from the TrueNAS web UI.
6. Update normal Linux VMs from inside each VM.
7. Apply CT apt updates only when you are ready for app packages installed through apt to update too.
8. Update app-specific releases one at a time.
9. Verify Uptime Kuma and the main app web UIs.
10. Record anything unusual in your local notes.

## Full update sequence

Use this sequence when you want to update as much as possible.

1. Backups and health checks
2. BIOS and firmware only when needed
3. Proxmox host
4. TrueNAS VM
5. Other VMs
6. CT apt packages
7. App-specific releases
8. Validation

BIOS and firmware are not monthly routine work. Update BIOS, HBA firmware, NIC firmware, or motherboard firmware only when you have a specific fix, security advisory, hardware issue, or planned maintenance window. Firmware updates can reset BIOS settings, so record boot order, virtualization, IOMMU, SATA/storage mode, and passthrough settings before changing firmware.

Proxmox should be updated before CTs and VMs because it owns the virtualization layer. TrueNAS should be updated from its own UI after Proxmox is stable. Normal Linux VMs should be updated from inside the VM. Appliance-style VMs such as TrueNAS and Nextcloud AIO should use their supported update interface, not generic apt commands from the Proxmox host.

CT apt updates can update both operating system packages and app packages installed through apt. For this lab, that can include Jellyfin, OpenResty, Docker, Node.js, PostgreSQL, Redis, Tailscale, and Grafana-related packages. That is why CT updates are separate from Proxmox host updates.

## Monthly command block

Run this from your workstation after confirming backups. Replace the placeholders before use:

- `<REPO_PATH>`: local path to this repo
- `<SSH_KEY>`: SSH key used for Proxmox root access
- `<PROXMOX_HOST>`: Proxmox host name or management IP
- `<IMMICH_CTID>`: CTID to leave for manual Immich updates, if applicable
- `<TESLAMATE_CTID>`: CTID to skip until its Grafana apt key or app-specific update path is fixed, if applicable

```bash
cd <REPO_PATH>

scp -i <SSH_KEY> scripts/proxmox-monthly-maintenance.sh root@<PROXMOX_HOST>:/root/proxmox-monthly-maintenance.sh

ssh -i <SSH_KEY> root@<PROXMOX_HOST> 'chmod +x /root/proxmox-monthly-maintenance.sh'

ssh -i <SSH_KEY> root@<PROXMOX_HOST> '/root/proxmox-monthly-maintenance.sh'

ssh -i <SSH_KEY> root@<PROXMOX_HOST> '/root/proxmox-monthly-maintenance.sh --apply-host'

ssh -i <SSH_KEY> root@<PROXMOX_HOST> 'pveversion -v && qm list && pct list'
```

After host updates, reboot Proxmox if the update output or Proxmox UI indicates a reboot is needed. Then rerun report mode before applying CT updates:

```bash
ssh -i <SSH_KEY> root@<PROXMOX_HOST> '/root/proxmox-monthly-maintenance.sh'
```

If backups are confirmed and you accept that CT apt updates can update apt-installed app packages, run:

```bash
ssh -i <SSH_KEY> root@<PROXMOX_HOST> '/root/proxmox-monthly-maintenance.sh --apply-ct --skip-ct <IMMICH_CTID> --skip-ct <TESLAMATE_CTID>'
```

This skips Immich so you can update it manually, and skips Teslamate until its Grafana apt key or app-specific update path is fixed. If those services are not present, remove the matching `--skip-ct` argument.

## Install the helper script on Proxmox

Run this from your workstation, replacing `<PROXMOX_HOST>` with the host name or IP:

```bash
scp scripts/proxmox-monthly-maintenance.sh root@<PROXMOX_HOST>:/root/proxmox-monthly-maintenance.sh
ssh root@<PROXMOX_HOST> 'chmod +x /root/proxmox-monthly-maintenance.sh'
```

Or open the file in this repo and paste it into `/root/proxmox-monthly-maintenance.sh` on the Proxmox host.

## Monthly report mode

Run this first:

```bash
ssh root@<PROXMOX_HOST> '/root/proxmox-monthly-maintenance.sh'
```

Report mode does this:

- Refreshes Proxmox host package metadata.
- Shows a count of pending Proxmox host packages.
- Lists VMs so you remember what still needs manual updates.
- Checks running LXCs for apt-based package updates.
- Notes CTs that have `/usr/bin/update`.
- Notes CTs that have Docker installed.
- Writes a log under `/root/homelab-maintenance-<timestamp>.log`.

Report mode does not install package updates.

Every run ends with a summary showing:

- Host update status
- VMs detected but not updated
- CT package updates detected
- CTs updated
- CTs skipped
- Failures or blockers
- App-specific notes such as `/usr/bin/update` or Docker Compose stacks

If you want the full package list instead of the shorter summary:

```bash
ssh root@<PROXMOX_HOST> '/root/proxmox-monthly-maintenance.sh --verbose'
```

## Apply Proxmox host updates

After reading the report and confirming backups, update only the Proxmox host first:

```bash
ssh root@<PROXMOX_HOST> '/root/proxmox-monthly-maintenance.sh --apply-host'
```

Host apply mode does this:

- Runs Proxmox host package updates with `apt-get -y dist-upgrade`.
- Leaves Docker apps alone.
- Leaves LXCs alone.
- Leaves VMs alone.
- Leaves TrueNAS alone.

Expect a reboot if kernel, ZFS, QEMU, LXC, or other core Proxmox packages update.

Apply mode asks you to confirm backups before it changes anything. Type `BACKED UP` only after backups and restore readiness are confirmed.

If you have already confirmed backups and want the command to run without a prompt, add `--yes`:

```bash
ssh root@<PROXMOX_HOST> '/root/proxmox-monthly-maintenance.sh --apply-host --yes'
```

## Apply CT apt updates

Only run this after you understand that apt updates inside CTs can include app packages such as Jellyfin, OpenResty, Grafana, Node.js, PostgreSQL, Redis, and Tailscale:

```bash
ssh root@<PROXMOX_HOST> '/root/proxmox-monthly-maintenance.sh --apply-ct'
```

CT apply mode does this:

- Runs `apt-get -y upgrade` inside each running apt-based LXC.
- Leaves stopped CTs alone.
- Leaves non-apt CTs alone.
- Leaves VMs alone.
- Leaves TrueNAS alone.

CT apply mode also asks for backup confirmation unless you pass `--yes`.

For a full catch-up window after backups are confirmed, you can do both:

```bash
ssh root@<PROXMOX_HOST> '/root/proxmox-monthly-maintenance.sh --apply-all'
```

To skip important or broken CTs during a bulk CT update:

```bash
ssh root@<PROXMOX_HOST> '/root/proxmox-monthly-maintenance.sh --apply-ct --skip-ct <MANUAL_APP_CTID> --skip-ct <BROKEN_REPO_CTID>'
```

Use this pattern when you want to leave an important app manual or avoid a known-broken app repository.

## TrueNAS update

Update TrueNAS from the TrueNAS web UI:

1. Open the TrueNAS web UI.
2. Confirm the storage pool is healthy.
3. Download or confirm the current TrueNAS config backup.
4. Open the update page.
5. Stay on the stable train.
6. Apply the update.
7. Reboot if prompted.
8. Confirm pools, datasets, shares, and Proxmox mounts are healthy.

Do not update TrueNAS from the Proxmox host script.

## App update order

Update low-risk apps first and core apps last:

1. Homarr
2. Navidrome
3. Uptime Kuma
4. Jellyfin
5. Nginx Proxy Manager
6. Teslamate
7. Vaultwarden
8. Immich
9. Nextcloud AIO

This order lets you catch general problems before touching the services that are more painful to restore.

Nextcloud AIO is always a manual update through the AIO interface in this guide.

Immich should also be treated as a manual app update unless you have reviewed the Immich release notes and confirmed backups. If you are doing bulk CT apt updates, skip the Immich CTID and come back to Immich in its own maintenance window.

## Docker Compose apps

For a Docker Compose app, use this pattern inside the CT that owns the app:

```bash
cd <APP_COMPOSE_DIRECTORY>
docker compose pull
docker compose up -d
docker compose ps
```

Use the app's real compose directory. Do not guess paths on important services.

## Community Scripts app helpers

Some Community Scripts CTs include an app update helper:

```bash
which update
update
```

Only run `update` after checking the relevant script or app notes. These helpers can update the application, not just the CT operating system.

## Nextcloud AIO

Update Nextcloud AIO from the AIO interface.

Do not use the generic Docker Compose pattern for Nextcloud AIO unless the AIO documentation for your exact version says to do that.

## Immich

Treat Immich updates as higher risk because app, database, and machine-learning container versions can move together.

Before updating Immich:

- Confirm photos are backed up.
- Read the release notes.
- Confirm the compose file and environment file match the target version.
- Update during a window where mobile uploads can be interrupted.

## Vaultwarden

Treat Vaultwarden as important because it stores credentials.

Before updating Vaultwarden:

- Confirm the data path is backed up.
- Confirm you can log in before the update.
- Confirm you can log in after the update.
- Keep admin access restricted.

## Validation checklist

After updates:

- [ ] Proxmox UI opens
- [ ] All expected VMs and CTs are running
- [ ] TrueNAS UI opens
- [ ] TrueNAS pools and shares are healthy
- [ ] Proxmox storage mounts are online
- [ ] Nextcloud opens
- [ ] Immich opens and a recent photo is visible
- [ ] Vaultwarden login works
- [ ] Nginx Proxy Manager opens
- [ ] Uptime Kuma shows core services as healthy

## Rollback notes

If a package update breaks a CT:

1. Stop the broken CT.
2. Restore the latest known-good CT backup to a test CTID if possible.
3. Confirm the restored service opens.
4. Replace the broken CT only after the restore is validated.

If a TrueNAS update breaks something, use the TrueNAS boot environment rollback path.

If a Docker app update breaks something, use the previous image tag or restore the app data from backup.

## Next step

After maintenance is documented, keep this as the recurring monthly operating checklist for the lab.

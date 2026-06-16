# 06 - Storage Pools, Shares, and Proxmox Mounts

## Goal

Build the storage layer in a way that is easy to recreate from scratch:

- Proxmox should have a clean local storage layout.
- TrueNAS should own the disk pool and export the shares.
- The apps should mount the storage they need instead of inventing their own copy of the same files.

This doc is the bridge between the Storage VM and the app VMs/CTs.

## Storage labels used in this guide

- `local-storage`
  - Directory storage at `/var/lib/vz`
  - Used for ISOs, templates, snippets, and small host artifacts
- `local-vm-storage`
  - Thin pool on the main Proxmox system disk
  - Used for the boot-side VM disk pool
- `vm-data`
  - Secondary thin pool on the second NVMe device
  - Used for most VM disks and container root filesystems
- `backups`
  - NFS mount at `/mnt/pve/backups`
  - Used as the external backup target on the separate backup server

## Where to run this

- Proxmox storage inventory commands: on the Proxmox host over SSH from a computer on the local network
- TrueNAS pool and share creation: in the TrueNAS web UI or shell inside the Storage VM
- Mount verification: on the Proxmox host
- App mount binding: on the specific VM or CT that needs the storage

## Current mount model

The Proxmox host mounts the backup export from the separate backup server.

Pattern:

```text
backup server -> NFS export -> Proxmox mount at /mnt/pve/backups
```

## TrueNAS storage notes

Use the Storage VM to manage the data pool and shares.

What to record for your own private notes:

- pool name
- dataset name
- SMB share name
- NFS export path
- ACL or maproot/mapall behavior

Recommended way to structure the pool:

1. Make one TrueNAS pool for the data disks.
2. Create one dataset per use case inside that pool.
3. Share the dataset, not the entire pool, when you can.
4. Keep permissions simple until the app actually needs more control.

Example layout inside a single pool:

```text
<POOL_NAME>
  <DATASET_PHOTOS>
  <DATASET_MEDIA>
  <DATASET_BACKUPS>
```

## Proxmox mount example

Use this pattern when documenting a new NFS mount:

```bash
mount -t nfs -o vers=4 <BACKUP_SERVER_IP>:<EXPORT_PATH> /mnt/pve/backups
```

If you are setting the mount up from scratch on Proxmox, this is the full copy/paste pattern:

```bash
apt update
apt install -y nfs-common
mkdir -p /mnt/pve/backups
pvesm add nfs backups --server <BACKUP_SERVER_IP> --export <EXPORT_PATH> --path /mnt/pve/backups --content backup
pvesm status
findmnt | grep '/mnt/pve/backups'
```

If the mount already exists and you only want to confirm it, run:

```bash
pvesm status
findmnt | grep '/mnt/pve/backups'
```

Verify with:

```bash
findmnt | grep '/mnt/pve/backups'
pvesm status
```

## Example fstab entry

```fstab
<BACKUP_SERVER_IP>:<EXPORT_PATH>  /mnt/pve/backups  nfs  defaults,vers=4,_netdev  0  0
```

Then test:

```bash
umount /mnt/pve/backups
mount -a
```

If you prefer to let Proxmox manage the storage entry instead of fstab, keep the `pvesm add nfs` approach above and do not mix both methods for the same mount.

## Suggested dataset mapping

Use simple dataset names so the apps are easy to understand later. Keep them inside the same pool:

- `photos` for Immich
- `documents` for Nextcloud
- `media` for Jellyfin and Navidrome
- `backups` for archive or export copies

Example:

```text
<POOL_NAME>
  photos
  documents
  media
  backups
```

## Share design rules

- Give each app only the path it needs.
- Prefer one share per use case instead of one giant share for everything.
- Keep read/write access narrow until the app actually needs write access.
- Avoid exposing raw pool paths if a dataset-level share will do the job.

## Using this mount for Immich

If Immich runs on Proxmox as a CT or VM-backed containerized app, point its library storage to the mounted path:

- Host path example: `/mnt/pve/<DATASET_NAME>`
- App-visible path example: `/photos`

For Docker Compose-style deployments, this is typically a bind mount from the host path to the container path.

For a friend following the guide, the decision tree is:

1. Does the app need persistent files?
2. Does that data belong in an existing TrueNAS dataset?
3. Is the dataset mounted into the VM or CT?
4. Is the app reading the shared path and not a throwaway local directory?

## Validation checklist

- [ ] SMB share reachable from a client machine on the local network
- [ ] NFS export reachable from the Proxmox host
- [ ] Proxmox can read and write test files under `/mnt/pve/backups`
- [ ] Mount persists across Proxmox reboot
- [ ] Immich can see and use the mounted photos directory
- [ ] The dataset names are simple and understandable
- [ ] The share permissions are no broader than needed

## Next step

After SMB/NFS and Proxmox mount are validated, continue with the Nextcloud AIO runbook in [`./07-nextcloud-aio-setup.md`](./07-nextcloud-aio-setup.md).

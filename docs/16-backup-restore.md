# 16 - Backup and Restore

## Purpose

This is the last infrastructure step before remote access.
It covers the backup mount, backup target, and restore drill so you know the lab can come back after a failure.

## Where to run this

- Proxmox host: create and verify the backup mount.
- Backup server: expose the export or datastore and hold the attached backup disk.
- TrueNAS: send data-pool snapshot backups to the same backup server when configured.
- Proxmox host and target VM/CT: perform restore checks.

## Current backup shape

- Mount name: `backups`
- Mount path: `/mnt/pve/backups`
- Backing server: separate backup server with SSH and an attached hard drive
- Export path: record privately
- The exact server and export are intentionally not published in this repo.

## Copy/paste setup on the Proxmox host

If you are creating the NFS backup mount for the first time:

```bash
apt update
apt install -y nfs-common
mkdir -p /mnt/pve/backups
pvesm add nfs backups --server <BACKUP_SERVER_IP> --export <BACKUP_EXPORT_PATH> --path /mnt/pve/backups --content backup
pvesm status
findmnt | grep '/mnt/pve/backups'
```

If the backup server already exists, use the mounted path as your backup target in the Proxmox GUI and keep the job name simple, such as `nightly-backup`.
Use the same backup server export for TrueNAS snapshot copies or replication targets when you want both hypervisor backups and TrueNAS data-pool backups on the same machine.

### Suggested backup job shape

- Storage: `backups`
- Mode: `snapshot` if the VM/CT supports it cleanly
- Retention: keep enough restore points to survive a bad update
- Schedule: run it when the lab is least busy
- Notification: pair with your monitoring alerts if possible

## What to back up

- Proxmox host configuration
- TrueNAS configuration
- Each VM/CT config
- Each VM/CT data path that is not disposable
- TrueNAS data-pool snapshots or replication copies

## Backup check

Run this on the Proxmox host:

```bash
pvesm status
findmnt | grep '/mnt/pve/backups'
```

## Restore drill

1. Pick one VM or CT.
2. Restore it into a test ID or test path.
3. Boot it and confirm the app opens.
4. Delete the test copy if it was only for validation.
5. Record the restore time so you know how long recovery takes on this hardware.

## Restore examples

Use the matching command for the VM or CT type:

```bash
qm restore <BACKUP_FILE> <TEST_VMID>
pct restore <TEST_CTID> <BACKUP_FILE>
```

## Validation

- [ ] The backup mount exists
- [ ] The host can read and write the mount
- [ ] At least one restore drill has been completed
- [ ] The backup path is part of your routine maintenance
- [ ] The restore time is known and acceptable for your use case

## Next step

After backup and restore are documented, continue to remote access in [`./17-remote-access-tailscale.md`](./17-remote-access-tailscale.md).

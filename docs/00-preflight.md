# 00 - Rebuild Preflight Checklist

Use this checklist before changing BIOS settings, reinstalling Proxmox, creating storage pools, or moving production data. The goal is to confirm that the rebuild can be completed and rolled back without relying on memory.

Do not commit private IP addresses, real domains, passwords, tokens, recovery keys, or backup credentials to this repository. Keep those values in a password manager or local rebuild notes outside Git.

## 1. Hardware inventory

Confirm the physical build is known before starting:

- [ ] Main server model, motherboard, CPU, RAM amount, and NICs are recorded in private notes.
- [ ] Boot drive, VM/data drives, passthrough drives, and spare drives are identified.
- [ ] Drive bay order and SATA/NVMe/USB port mapping are documented locally.
- [ ] Storage labels match the naming used in this guide: `local-storage`, `local-vm-storage`, `vm-data`, and `backups`.
- [ ] Keyboard, display, Ethernet cable, power cables, and any USB adapters are available.
- [ ] Backup server hardware and attached backup drive are powered and reachable.

Reference docs:

- [`02-hardware-and-wiring.md`](02-hardware-and-wiring.md)
- [`06-storage-and-shares.md`](06-storage-and-shares.md)
- [`17-backup-restore.md`](17-backup-restore.md)

## 2. Install media and recovery tools

Confirm you can install and recover before wiping anything:

- [ ] Proxmox installer USB is prepared and boots on the target server.
- [ ] The intended Proxmox version is noted; this guide was verified against the baseline listed in the README.
- [ ] A second computer is available for reading the docs, downloading packages, and testing network access.
- [ ] Firmware/BIOS access keys are known for the server motherboard.
- [ ] Recovery media or vendor tools are available if the installer cannot see storage or networking.
- [ ] A rollback path is written down before the first destructive step.

Reference docs:

- [`03-bios-and-proxmox-install.md`](03-bios-and-proxmox-install.md)
- [`04-iommu-and-passthrough.md`](04-iommu-and-passthrough.md)

## 3. Network plan

Confirm the local network plan before the host install:

- [ ] Proxmox management interface, bridge name, VLAN plan if used, and gateway/DNS choices are written in private notes.
- [ ] DHCP reservations or static assignments are planned without committing real IPs to Git.
- [ ] DNS starter hostname, upstream behavior, and fallback DNS option are known.
- [ ] Remote access is treated as a final layer, not a dependency for the first local rebuild.
- [ ] Local-only services, Tailscale-accessible services, and reverse-proxied services are separated in private notes.

Reference docs:

- [`01-dns-starter.md`](01-dns-starter.md)
- [`03-bios-and-proxmox-install.md`](03-bios-and-proxmox-install.md)
- [`11-nginx-proxy-manager-proxy-ct.md`](11-nginx-proxy-manager-proxy-ct.md)
- [`18-remote-access-tailscale.md`](18-remote-access-tailscale.md)

## 4. DNS starter status

Confirm the starter service is useful before depending on it:

- [ ] DNS starter is powered, reachable, and running Pi-hole and Unbound.
- [ ] A temporary fallback DNS path exists in case the starter is offline during the rebuild.
- [ ] Any Tailscale dependency is documented locally and does not block basic LAN setup.
- [ ] The DNS starter can be rebuilt independently from the main Proxmox host.

Reference docs:

- [`01-dns-starter.md`](01-dns-starter.md)
- [`18-remote-access-tailscale.md`](18-remote-access-tailscale.md)

## 5. Backup target availability

Confirm backups exist and are reachable before storage changes:

- [ ] Backup server is powered on and reachable over the local network.
- [ ] Backup export or share path is recorded in private notes.
- [ ] At least one recent backup exists for important VM/CT data and shared storage data.
- [ ] A small restore test has been done or is scheduled before trusting the backup set.
- [ ] Irreplaceable files are copied somewhere separate from the rebuild target.

Reference docs:

- [`17-backup-restore.md`](17-backup-restore.md)
- [`19-maintenance-and-updates.md`](19-maintenance-and-updates.md)

## 6. Credentials and secrets

Keep secrets outside the repo and confirm they are accessible:

- [ ] Proxmox root password or recovery path is stored outside Git.
- [ ] TrueNAS, Nextcloud, Immich, Vaultwarden, proxy, and monitoring credentials are stored outside Git.
- [ ] Tailscale, DNS, API tokens, SMTP credentials, and webhook URLs are stored outside Git.
- [ ] Recovery keys, two-factor backup codes, and encryption keys are available from a password manager or offline notes.
- [ ] No private IPs, domains, passwords, tokens, or secrets are copied into Markdown files.

Reference docs:

- [`10-vaultwarden-password-ct.md`](10-vaultwarden-password-ct.md)
- [`11-nginx-proxy-manager-proxy-ct.md`](11-nginx-proxy-manager-proxy-ct.md)
- [`18-remote-access-tailscale.md`](18-remote-access-tailscale.md)

## 7. Storage labels and destructive operations

Do not continue until the storage plan is clear:

- [ ] Every disk that may be wiped is identified by model, serial, size, and physical bay.
- [ ] Drives that must not be wiped are clearly marked in private notes.
- [ ] Planned Proxmox storage names match this guide: `local-storage`, `local-vm-storage`, `vm-data`, and `backups`.
- [ ] TrueNAS passthrough or virtual disk choices are understood before creating pools.
- [ ] Pool names, dataset names, and share names are planned locally without exposing private paths.

Reference docs:

- [`05-truenas-vm-setup.md`](05-truenas-vm-setup.md)
- [`06-storage-and-shares.md`](06-storage-and-shares.md)
- [`17-backup-restore.md`](17-backup-restore.md)

## 8. Rollback notes

Write down how to stop safely before making changes:

- [ ] Last known-good state is described in private notes.
- [ ] Current BIOS settings are photographed or written down before changing them.
- [ ] Existing Proxmox, TrueNAS, and service configuration exports are saved if available.
- [ ] The first point-of-no-return step is identified.
- [ ] A clear pause point is defined after Proxmox networking works but before app services are rebuilt.

Reference docs:

- [`03-bios-and-proxmox-install.md`](03-bios-and-proxmox-install.md)
- [`17-backup-restore.md`](17-backup-restore.md)
- [`19-maintenance-and-updates.md`](19-maintenance-and-updates.md)

## Ready to begin

Start the rebuild only after the checklist above is complete. Then follow the guide in order:

1. [`00-overview.md`](00-overview.md)
2. [`01-dns-starter.md`](01-dns-starter.md)
3. [`02-hardware-and-wiring.md`](02-hardware-and-wiring.md)
4. [`03-bios-and-proxmox-install.md`](03-bios-and-proxmox-install.md)

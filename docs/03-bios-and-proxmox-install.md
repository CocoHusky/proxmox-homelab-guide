# 03 - BIOS and Proxmox Install

## Why this matters

This is the platform layer that everything else depends on.
If the BIOS or Proxmox install is wrong, the VM and container layout will not match the documented build.

## What is essential

- VT-x enabled
- VT-d enabled
- Correct boot mode
- Stable Proxmox install on the boot disk
- Correct network bridge for management and VM/CT traffic

## What is optional

- Cosmetic BIOS tweaks
- Non-essential repository cleanup helpers
- Additional monitoring packages before the core lab is working

## BIOS settings

Record BIOS version and changed settings:

- BIOS version:
- VT-x: Enabled
- VT-d (IOMMU): Enabled
- Secure Boot: record the value used on your host
- SATA mode (AHCI/RAID):
- Boot mode (UEFI/Legacy):

## Why these settings matter

- VT-x allows virtualization to run VM and CT workloads efficiently.
- VT-d allows device isolation and passthrough where needed.
- Boot mode must match the actual installed disk layout.
- SATA mode must match the way disks are intended to be presented to Proxmox or TrueNAS.

## Proxmox install log

- Proxmox version: 9.1.6
- Running kernel: 6.17.13-1-pve
- Install target disk: record the actual disk you used locally
- Filesystem (ext4/ZFS): record the actual choice used on your host
- Network config:
  - Management IP: record the local address used on your network
  - Gateway: record the router address used on your network

## Version baseline

This guide was verified on Proxmox VE `9.1.6` with kernel `6.17.13-1-pve`.
If you are on a newer compatible Proxmox release, keep following this guide as long as the command names and UI labels still match.
If a later release changes a command, use the closest equivalent command on your host and record the difference in your local notes.
The guide is built around a known-good baseline, not an exact-version lock.

## What to verify immediately after install

- `pveversion -v` returns the expected package set.
- The management bridge is up and reachable.
- The host boots from the intended disk.
- The install did not accidentally consume the storage disks reserved for VM/CT data.

## Post-install baseline cleanup (recommended)

If you used a post-install helper to clean up enterprise-only defaults and apply basic host config, document it here.

- Script/tool used:
- Changes applied (example: enterprise repo cleanup, no-subscription repo enablement, package updates):
- Reboot completed:

Example command path (if used):

```bash
# Review script before running, then execute
bash -c "$(wget -qLO - https://github.com/tteck/Proxmox/raw/main/misc/post-pve-install.sh)"
```

## First-boot checks

- [ ] Host reachable via web UI
- [ ] `pveversion -v` captured
- [ ] `lsblk` inventory captured
- [ ] Updates applied
- [ ] Repository baseline verified (if changed)
- [ ] SSH from a second computer on the local network works after the first boot checks pass
- [ ] If a UI label changed in a newer Proxmox release, the closest equivalent step has been captured in local notes

## Commands captured

```bash
pveversion -v
lsblk -o NAME,SIZE,TYPE,MOUNTPOINT,MODEL
ip a
```

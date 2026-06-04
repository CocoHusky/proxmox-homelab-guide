# 15 - Sandbox VM

## Purpose

This VM is for experiments and side projects.
It is the least important part of the lab, so build it only after everything else is stable.

## Where to run this

- Proxmox host: create or inspect the Sandbox VM.
- VM console: install the OS.
- Browser or SSH: manage any app you place in the VM.

## Current build snapshot

- VM role: Sandbox VM
- VMID: `113`
- RAM: `4096 MB`
- Treat this as a small test box, not part of the core lab.

## Proxmox create block

Run this on the Proxmox host to create the VM shell:

```bash
qm create 113 \
  --name sandbox \
  --memory 4096 \
  --cores <YOUR_CAPTURED_CORE_COUNT> \
  --cpu host \
  --machine q35 \
  --bios ovmf \
  --scsihw virtio-scsi-pci \
  --net0 virtio,bridge=vmbr0

qm set 113 --serial0 socket --vga serial0
qm set 113 --boot order=scsi0
```

## Capture the exact VM settings

Run this on the Proxmox host:

```bash
qm config 113 | rg '^(cores|memory|boot|scsi|virtio|net0|agent|machine|bios|cpu):'
qm status 113
```

## Install path

1. Create the VM in Proxmox.
2. Install the OS you want.
3. Keep the VM isolated from the core lab unless a project needs access.
4. Give it only the network access it needs.
5. Do not put important data here unless you include it in backups.
6. Take a snapshot before experiments if the OS and workload support it.

If you do not know the core count yet, choose a small starting value that matches the project you want to test and then verify the final VM config with `qm config 113`.

## Suggested use cases

- Temporary app testing
- Code experiments
- Disposable Linux services
- Short-lived containers or build environments

## Suggested hardening

- Use a separate SSH key for this VM if you expose SSH.
- Keep it off public remote access unless you really need it.
- Rebuild it freely; do not treat it like a production VM.

## Validation

- [ ] The VM boots
- [ ] The network works
- [ ] The config matches `qm config 113`
- [ ] The VM does not contain data you care about losing
- [ ] You can rebuild it without affecting the core lab

## Next step

After the Sandbox VM, move on to backup and restore in [`./16-backup-restore.md`](./16-backup-restore.md).

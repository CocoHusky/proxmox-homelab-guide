# 05 - Storage VM Setup

## Why this matters

TrueNAS is the storage layer that makes the rest of the lab predictable.
It should be built before the media, photo, and document services are finalized.

## What is essential

- Storage VM sizing
- Correct passthrough or disk attachment
- Reachable management IP
- Healthy pool visibility
- Stable storage exports for Proxmox

## Where to run this

- Storage VM creation and hardware assignment: in the Proxmox web UI or console on the host.
- TrueNAS install and initial configuration: inside the Storage VM.
- Storage verification: inside the TrueNAS shell and web UI.

## What is optional

- Extra datasets
- Extra shares
- Fancy user/group structures that are not needed for the core lab

## VM creation

- VM role: Storage VM
- VMID: `100`
- vCPU count: capture with `qm config 100 | rg '^cores:'` before you finalize the VM
- RAM: `16384 MB` in the current build snapshot
- Boot disk: `32 GB` TrueNAS system disk in the current build snapshot
- NIC model: `virtio`, verify with `qm config 100 | rg '^net0:'`

If you are rebuilding from scratch and do not yet know the exact CPU allocation, use the command block below to create the shell and then tune the core count afterward. A good starting point for a small home-lab storage VM is 4 vCPU, then raise it only if the storage workload actually needs more.

### Proxmox create block

Run this on the Proxmox host to create the VM shell before installing TrueNAS:

```bash
qm create 100 \
  --name truenas-scale \
  --memory 16384 \
  --cores <YOUR_CAPTURED_CORE_COUNT> \
  --cpu host \
  --machine q35 \
  --bios ovmf \
  --scsihw virtio-scsi-pci \
  --net0 virtio,bridge=vmbr0

qm set 100 --serial0 socket --vga serial0
qm set 100 --boot order=scsi0
```

If you are using a maintained helper from [community-scripts.org](https://community-scripts.org), use that helper only for the initial VM/bootstrap flow and still verify the final config with `qm config 100`.

If you do not yet know the core count, stop here and capture it from the current working build notes or from your own planned VM size before you create the VM.

## Capture the exact VM settings

Run this on the Proxmox host:

```bash
qm config 100 | rg '^(cores|memory|boot|scsi|virtio|net0|agent|machine|bios|cpu):'
qm status 100
```

## Design goal

The storage VM should own storage management, not the Proxmox host.
The host should mount the storage that TrueNAS exports, then pass selected paths into the app containers.

## Attached storage

- Passed-through controller/device 1: capture with `lspci -nn` on the Proxmox host and keep the exact PCI BDF in your local notes
- Passed-through controller/device 2: capture only if your hardware needs more than one controller
- Additional virtual disk(s): optional if your storage controller is fully passed through

If the machine uses an HBA or SATA controller passthrough, record the controller model, the PCI address, and which physical drive bays it serves. That is the difference between a clean rebuild and a guessing session later.

## TrueNAS install and initial config

- TrueNAS version: record the version you install in the installer and the web UI so you can recreate it later
- Admin setup completed: confirm during first boot
- Network interface assigned: note the interface name you use for management
- Static IP configured: record the static address you assign on your LAN

### Install path on the VM console

1. Mount the TrueNAS ISO in the VM.
2. Boot the VM from the ISO.
3. Install TrueNAS onto the VM system disk.
4. Reboot and complete the first-time wizard.
5. Assign the management IP on your local network.
6. Confirm the web UI is reachable before you move on.
7. Create one storage pool from the physical disks you passed through.
8. Create datasets inside that pool for the data types you actually use.
9. Enable NFS and SMB only if you need them for the lab.

### Suggested datasets

Use simple names that make the layout obvious. Keep them all inside the same pool:

- `photos`
- `documents`
- `media`
- `backups`
- `archives`

You do not need every dataset on day one. Start with the ones that back the services you are actually deploying.

### Example install checks inside TrueNAS

Run these in the TrueNAS shell after the first boot:

```bash
hostname
cat /etc/os-release
midclt call system.info
zpool status
zfs list
```

## Post-install checks

- [ ] TrueNAS web UI reachable
- [ ] All target data disks visible
- [ ] Disk serial numbers match expected hardware
- [ ] Pool created and healthy
- [ ] Core datasets created
- [ ] NFS or SMB shares enabled only for the paths you intend to use

## Why the checks matter

- Web UI reachability confirms the VM is alive and addressable.
- Disk visibility confirms the passthrough or attachment model is correct.
- Serial matching confirms the right physical disks are in the right pool.
- Pool health confirms the disk layout is safe before the rest of the lab depends on it.

## Handoff to storage phase

After the Storage VM installation is stable, continue with SMB/NFS share setup and Proxmox NFS remount workflow in [`./06-storage-and-shares.md`](./06-storage-and-shares.md).

- [ ] SMB/NFS planning complete
- [ ] NFS export target selected for Proxmox-mounted app data (example: Immich photos)

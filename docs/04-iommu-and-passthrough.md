# 04 - IOMMU and Passthrough

## Goal

Pass the storage controller or disks through cleanly to the Storage VM so TrueNAS can manage the data pool directly instead of Proxmox pretending to own the disks.

Use this step only after Proxmox is already installed and reachable over SSH from a second computer on the local network.

## What this step changes

- Turns on IOMMU support in the host boot settings.
- Verifies the storage controller lives in a clean IOMMU group.
- Binds the controller to VFIO so Proxmox stops using it.
- Attaches the controller to the Storage VM.
- Verifies the disks show up inside TrueNAS with SMART access intact.

## Where to run this

- Proxmox host shell: every command in this doc runs there unless the text explicitly says TrueNAS.
- Proxmox UI: attach the PCI device to the Storage VM.
- Storage VM shell / TrueNAS shell: verify the disks after boot.

## Before you start

You need:

- Proxmox installed and booting from the correct system disk
- SSH access to the host from your Mac or another LAN computer
- A clear understanding of which controller or disks belong to storage and which belong to Proxmox boot

If your host boots from SATA and not NVMe, do not blindly blacklist `ahci`. That change is only safe if the boot path does not rely on the controller you are passing through.

## Step 1: confirm IOMMU is active

Run this on the Proxmox host:

```bash
dmesg | grep -Ei 'DMAR|IOMMU|AMD-Vi|vfio'
```

What you want to see:

- `DMAR: IOMMU enabled` on Intel
- `AMD-Vi: IOMMU enabled` on AMD
- No fatal IOMMU errors

If you do not see IOMMU enabled, go back to the BIOS step and make sure virtualization and IOMMU support are on.

## Step 2: identify the controller or disk you want to pass through

Run this on the Proxmox host:

```bash
lspci -nn
lsblk -o NAME,SIZE,TYPE,FSTYPE,MOUNTPOINTS,MODEL,SERIAL
find /sys/kernel/iommu_groups -type l | sort
```

What to record:

- PCI address of the controller, for example `0000:03:00.0`
- The vendor/device ID pair shown by `lspci -nn`
- Which physical drive bays or ports are attached to that controller

If you are unsure, stop here and write the controller details down before editing anything.

## Step 3: choose the correct boot-loader path

Proxmox can be installed in a few layouts. Use the one that matches your host:

- If your host uses GRUB, edit `/etc/default/grub`
- If your host uses Proxmox boot tooling or systemd-boot, edit `/etc/kernel/cmdline`

Use whichever file your install actually relies on. Do not edit both unless you know your host uses both.

## Step 4: add the IOMMU kernel flag

For Intel hosts, add:

```text
intel_iommu=on
```

For AMD hosts, add:

```text
amd_iommu=on
```

If you need both behavior and a verbose debug trail while testing, you can temporarily add:

```text
iommu=pt
```

After editing the boot config:

- GRUB systems: run `update-grub`
- Proxmox boot-tool systems: run `proxmox-boot-tool refresh`

## Step 5: bind the controller to VFIO

Create the VFIO config file on the Proxmox host:

```bash
nano /etc/modprobe.d/vfio.conf
```

Add the controller ID you captured from `lspci -nn`:

```conf
options vfio-pci ids=<PCI_VENDOR:DEVICE_ID>
```

Then load the VFIO modules at boot:

```bash
nano /etc/modules-load.d/vfio.conf
```

Add:

```conf
vfio
vfio_iommu_type1
vfio_pci
vfio_virqfd
```

If your host uses the same controller for the Proxmox boot drive, stop and redesign the hardware layout before proceeding.

## Step 6: rebuild initramfs and reboot

Run this on the Proxmox host:

```bash
update-initramfs -u -k all
reboot
```

After reboot, reconnect over SSH and continue with the checks below.

## Step 7: confirm the controller is no longer owned by the host

Run this on the Proxmox host:

```bash
lspci -nnk -s <PCI_BDF>
lsblk
```

Expected result:

- The controller should report `Kernel driver in use: vfio-pci`
- The host should no longer be mounting the storage disks directly

If the controller still binds to a normal storage driver, go back and re-check the PCI ID and the VFIO config file.

## Step 8: attach the controller to the Storage VM

In the Proxmox UI:

1. Select the Storage VM.
2. Open **Hardware**.
3. Click **Add**.
4. Choose **PCI Device**.
5. Pick the controller by the exact PCI BDF.
6. Check **All Functions** if the device exposes multiple functions.
7. Leave **ROM-Bar** enabled unless your hardware requires otherwise.
8. Do **not** mark it as a primary GPU.

## Step 9: verify TrueNAS sees the disks

Inside the Storage VM, open the shell and run:

```bash
lsblk
smartctl -a /dev/sdb
smartctl -a /dev/sdc
```

What to verify:

- The boot disk and data disks are separate
- The pool disks are visible inside the VM
- SMART data can be read from the pool disks

## Why passthrough instead of virtual disks

For this lab, controller passthrough is the better fit because it:

- preserves disk identity
- gives TrueNAS direct control of the pool
- makes SMART checks easier
- makes future drive replacement less confusing

## Boot parameter documentation

Keep your exact host settings in local notes:

- `/etc/default/grub`
- `/etc/kernel/cmdline`

Record:

- the exact IOMMU flag you used
- whether you used `iommu=pt`
- the PCI BDF of the storage controller
- the date you verified the pass-through

## Validation

- [ ] IOMMU is enabled in `dmesg`
- [ ] The correct PCI controller is identified
- [ ] The controller binds to `vfio-pci`
- [ ] The Storage VM can see the disks
- [ ] SMART data is visible inside the Storage VM

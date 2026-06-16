# 07 - Nextcloud AIO Setup

## Purpose

Nextcloud AIO is the document and collaboration layer in the lab.
Build this before the optional services, but after Proxmox, storage, and the shared mount are working.

## Where to run this

- Proxmox host: create or inspect the Document VM.
- Document VM: install Docker and run the Nextcloud AIO master container.
- Browser: finish the AIO wizard from a computer on the local network.

## Current build snapshot

- VM role: Document VM
- VMID: `108`
- RAM: `25600 MB`
- Boot disk: `64 GB`
- NIC model: `virtio`
- This is the reference shape, not a hard pin. If you are on a newer compatible Proxmox release or choose a slightly different VM size, keep the same service order and record the difference locally.

## What AIO gives you

Nextcloud AIO is not just a single app container. It bundles the pieces that normally turn into a long manual install:

- Nextcloud itself
- Database and cache services
- Optional Nextcloud Office / Collabora
- Optional backup support
- Optional extras like preview and security helpers

That is why this VM comes before the support-only services but after the storage layer.

## Proxmox create block

Run this on the Proxmox host to create the VM shell:

```bash
qm create 108 \
  --name nextcloud-aio \
  --memory 25600 \
  --cores <YOUR_CAPTURED_CORE_COUNT> \
  --cpu host \
  --machine q35 \
  --bios ovmf \
  --scsihw virtio-scsi-pci \
  --net0 virtio,bridge=vmbr0

qm set 108 --serial0 socket --vga serial0
qm set 108 --boot order=scsi0
```

If you use [community-scripts.org](https://community-scripts.org) for VM bootstrap work, use it only for the initial VM shell and still verify the final config with `qm config 108`.

If you do not know the core count yet, pick the value you want the Document VM to run with and then verify it with `qm config 108` after the VM is created.

If you want a simple first-pass size and do not need to match a historical snapshot exactly, 4 to 6 vCPU is a sensible starting range for AIO. Increase it only if you see CPU pressure during real use.

## Capture the exact VM settings

Run this on the Proxmox host:

```bash
qm config 108 | rg '^(cores|memory|boot|scsi|virtio|net0|agent|machine|bios|cpu):'
qm status 108
```

## Install path

1. Create the VM in Proxmox.
2. Install Debian or Ubuntu Server in the VM.
3. Install Docker.
4. Run the Nextcloud AIO master container.
5. Point the data path at shared storage, not the VM boot disk.
6. Finish the wizard in the browser and create the first admin account.
7. Decide whether you want Nextcloud Office in the core lab or only basic file sync.

## Docker install

Run these inside the Document VM:

```bash
apt update
apt install -y ca-certificates curl gnupg
apt install -y docker.io docker-compose-plugin
systemctl enable --now docker
docker volume create nextcloud_aio_mastercontainer
docker run --init --sig-proxy=false --name nextcloud-aio-mastercontainer --restart always \
  --publish 80:80 \
  --publish 8080:8080 \
  --publish 8443:8443 \
  -v nextcloud_aio_mastercontainer:/mnt/docker-aio-config \
  -v /var/run/docker.sock:/var/run/docker.sock:ro \
  -e NEXTCLOUD_DATADIR="/mnt/ncdata" \
  ghcr.io/nextcloud-releases/all-in-one:latest
```

If you already mounted shared storage in the VM, point `NEXTCLOUD_DATADIR` at that mounted path instead of the boot disk. The important part is that the main data path survives VM reinstall or boot-disk replacement.
Set `NEXTCLOUD_DATADIR` before the first AIO startup. If you change it later, treat that as a migration task and follow the AIO datadir migration path instead of editing the running stack blindly.

## Shared storage

The Nextcloud data directory should live on the shared storage layer.
Do not keep the main data set on the Proxmox boot disk.

If you already mounted the storage on Proxmox, bind that path into the VM using the method you prefer for your lab.

### If you need to choose a data path

- Keep the AIO master container config on the VM boot disk
- Put user files and app data on the shared storage mount
- Keep any backup or archive copy on the backup target, not only on the VM disk

### AIO wizard flow

When the AIO master container is running, open the wizard from your local network browser and walk through the setup in this order:

1. Set the AIO admin password.
2. Confirm the domain or local access path you want to use.
3. Choose the optional containers you actually need.
4. Start the stack and wait for the containers to finish initializing.
5. Open the resulting Nextcloud login and create the first admin account there.

Do not create the Nextcloud admin user in a separate Linux account. The admin account lives in the Nextcloud app itself.

## Nextcloud user setup

The first admin account is created in the AIO wizard.
After the wizard is complete:

1. Sign in with the admin account.
2. Create additional users for family members or collaborators if needed.
3. Create groups only when you have a real sharing or permissions need.
4. Put shared folders or team folders on the shared storage-backed data path.
5. Keep the first structure simple: one admin, a few normal users, and only the folders you actually plan to share.

## Nextcloud Office and Collabora

If you want document editing inside Nextcloud, enable Nextcloud Office after the core instance is running.

Use this order:

1. Open the Nextcloud admin settings.
2. Go to the Office or Collabora settings area.
3. Use the AIO-provided Collabora option if you want the simplest supported path.
4. If you are using a reverse proxy, tunnel, or another IP path that does not match the domain, add the WOPI allow list entries required by that path.
5. If you are staying local-only, keep the access path simple and avoid unnecessary allow-list entries.
6. If the wizard or helper offers a domain-validation skip for a local-only build, use that only when you are staying on local-network access.

What to verify:

- The document editor opens from within Nextcloud.
- Users can create and edit documents.
- The Office service remains reachable after a restart.
- The reverse proxy or tunnel path does not break WOPI access if you use one.
- The AIO container list includes Office only if you chose it.
- The office service path matches the browser path you actually plan to use.

## Validation

- [ ] The AIO admin UI opens from the local network
- [ ] The admin login works
- [ ] The data directory is on shared storage
- [ ] The first admin account can log in
- [ ] Additional users can be created if needed
- [ ] Nextcloud Office works if you enabled it
- [ ] `qm config 108` matches the expected VM shape
- [ ] The data directory is not on the VM boot disk
- [ ] The browser path you plan to use is the same one that works for editing documents

## Next step

After Nextcloud is working, move on to the Photos CT runbook in [`./08-immich-photos-ct.md`](./08-immich-photos-ct.md).

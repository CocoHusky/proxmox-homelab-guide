# 00 - Build Overview

## Goal

This document explains the full rebuild path at a glance.
Use it to understand the order of the build before diving into the phase docs.

## Build Architecture

If the diagram below does not render in your viewer, read it as a straight vertical stack:

Hardware -> BIOS -> Proxmox -> Storage VM / TrueNAS -> Shared storage -> Core services -> Support services -> Optional services -> Remote access last

## What matters most

### Required path

If you are rebuilding only the important parts, this is the shortest useful order:

1. Physical hardware and wiring
2. BIOS virtualization settings
3. Proxmox host install
4. Storage VM
5. Shared storage mounts
6. Nextcloud AIO
7. Immich Photos CT
8. Uptime Kuma monitoring CT
9. Vaultwarden password CT
10. Nginx Proxy Manager proxy CT
11. Homarr dashboard CT
12. Navidrome music CT
13. Jellyfin media CT
14. Teslamate telemetry CT
15. Sandbox VM
16. Backup and restore
17. Remote access last

### Optional path

The first six steps are infrastructure. Everything from step 7 onward is the actual lab shape.

## How the lab is layered

- Hardware provides the physical base.
- BIOS enables virtualization and passthrough.
- Proxmox hosts the VM/CT layer.
- The storage VM manages disks, pools, and exports.
- The Proxmox host mounts shared storage from the storage layer.
- Essential VM/CT services provide day-to-day usefulness.
- Support services make the lab easier to use.
- Optional services can be added later without changing the core build.
- Remote access comes last, after the local-only build is working.

## Host summary

- Verified Proxmox VE baseline: `9.1.6`
- Verified kernel baseline: `6.17.13-1-pve`
- Newer compatible releases are fine if the commands and UI labels still match
- Host bridge: `vmbr0`
- Generic storage labels used in this guide:
  - `local-storage`
  - `local-vm-storage`
  - `vm-data`
  - `backups`

## VM/CT summary

### VMs

- Storage VM: TrueNAS SCALE
- Document and collaboration VM: Nextcloud AIO
- Optional sandbox VM

### CTs

- Photos CT: Immich
- Monitoring CT: Uptime Kuma
- Password manager CT: Vaultwarden
- Proxy CT: Nginx Proxy Manager
- Dashboard CT: Homarr
- Music CT: Navidrome
- Media CT: Jellyfin
- Vehicle telemetry CT: Teslamate

## Build sequence

1. Read the overview.
2. Build the hardware.
3. Configure BIOS.
4. Install Proxmox.
5. Build the storage VM.
6. Mount shared storage.
7. Set up Nextcloud AIO.
8. Deploy the Photos CT.
9. Deploy the Monitoring CT.
10. Deploy the Password CT.
11. Deploy the Proxy CT.
12. Deploy the Dashboard CT.
13. Deploy the Music CT.
14. Deploy the Media CT.
15. Deploy the Telemetry CT.
16. Deploy the Sandbox VM if you need one.
17. Set up backup and restore.
18. Add remote access only after the local build is stable.

## Where to run things

- Physical hardware and BIOS changes happen on the server with a keyboard and screen attached.
- Proxmox host checks happen on the server console first, then over SSH from another computer on the local network.
- TrueNAS setup happens in the VM console and the TrueNAS web UI.
- VM/CT service setup happens through the Proxmox UI and then inside each VM/CT shell.
- Remote access setup happens last from a computer on the same local network.

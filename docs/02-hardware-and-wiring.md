# 02 - Hardware and Wiring

## Why this matters

This is the physical foundation for the entire build.
If the hardware, cabling, and drive placement are wrong, everything above it becomes harder to debug later.

## What is essential

- Correct host chassis and motherboard
- Working CPU and RAM
- Boot disk(s) for Proxmox
- Separate storage path for TrueNAS or bulk data
- Stable power delivery
- Correct front-panel and drive wiring

## What is optional

- Custom cable sleeving
- Labeling every wire
- Cosmetic drive trays or mounts
- Non-essential LED or RGB work

## Recommended hardware

These are practical targets for a home-lab build like this. The goal is stability and enough headroom for virtualization, not maximum benchmark scores.

### CPU

- Recommended: modern Intel Core i5 / i7, Intel Xeon E-series, or AMD Ryzen 5 / 7 class CPU
- Good features to look for:
  - Hardware virtualization support
  - IOMMU / VT-d or AMD-Vi support
  - Enough cores for Proxmox plus multiple VM/CT workloads
- Practical baseline:
  - 6 cores / 12 threads minimum
  - 8 cores / 16 threads preferred if you want room for media and side projects

### RAM

- Minimum: `32 GB`
- Recommended: `64 GB`
- Better if you want more room for caching, ZFS, TrueNAS, and multiple services: `128 GB`

### Storage

- Boot / Proxmox drive: fast NVMe SSD
- VM/CT pool: NVMe SSD or SSD mirror if you want better resilience
- Bulk storage: HDDs for media, backups, and large datasets
- Recommended mix for this kind of lab:
  - 1 NVMe for Proxmox boot
  - 1 NVMe or SSD pool for VM/CT disks
  - 2 or more HDDs for TrueNAS or bulk data, sized to your retention target rather than a fixed number

### Reference build target

If you want a build that is close to this lab without buying more hardware than you need, aim for:

- CPU with at least 6 modern cores and hardware virtualization support
- `64 GB` RAM if you want the whole stack to feel comfortable
- 1 boot NVMe in the `500 GB` to `1 TB` range
- 1 SSD or NVMe pool for VM/CT storage
- 2 or more HDDs at `2 TB+` each if you want a practical media and backup starting point
- A GPU only if you need transcoding or another workload that can use it

If your storage plan changes, scale the bulk disks up instead of assuming one fixed size. The guide cares about the role of the disks, not forcing a specific capacity.

### GPU

- Optional unless you need media transcoding or a specific workload
- If you want hardware transcoding for Jellyfin:
  - choose an Intel iGPU with Quick Sync if the CPU supports it
  - or use a low-power discrete GPU that your hardware can pass through cleanly
- If you do not need transcoding, no dedicated GPU is required for Proxmox itself
- Example low-power GPU picks:
  - Intel Quick Sync iGPU on supported Intel CPUs
  - NVIDIA T400 / T600 for compact transcoding setups
  - NVIDIA A2000 if you want more headroom and low-profile support

### Network

- Use a wired gigabit or better NIC
- A dedicated management bridge is enough for most home labs
- Separate storage or backup networking is optional, not required

### Example hardware families

- Dell OptiPlex or Precision small-form-factor systems
- Lenovo ThinkCentre or ThinkStation small-form-factor systems
- HP ProDesk or EliteDesk systems
- Custom mini-ITX or micro-ATX builds with Intel or AMD consumer parts

### Example models to shop for

- Dell OptiPlex 7090 / 7010 / 7000 SFF
- Lenovo ThinkCentre M90q / M90s / M920q / M720q
- HP EliteDesk 800 G6 / G9 or ProDesk 600 series
- Intel NUC-style systems only if you are comfortable with limited expandability
- Custom build example:
  - Intel Core i5-12400 / i5-12500 / i5-13500
  - AMD Ryzen 5 5600G / 5700G / 7600
  - B660 / B760 / B550 / B650 motherboard
  - 32 GB or 64 GB DDR4 or DDR5 depending on platform

### What to avoid

- Very low-RAM systems below `16 GB` unless you are only testing
- Slow spinning disk as the only Proxmox boot device
- Consumer Wi-Fi as the primary management path
- Oversized GPU purchases if you do not actually need transcoding

## Pre-build checklist

- [ ] Confirm all components are recognized physically
- [ ] Install the bulk data disks you plan to dedicate to storage
- [ ] Install NVMe drives in correct slots
- [ ] Confirm PSU/cable compatibility
- [ ] Plan SATA power split (if needed)

## Typical hardware roles

- Boot disk: Proxmox host OS
- VM/CT disk pool: VM disks and container root filesystems
- Bulk disks: storage VM / data pool / shared media
- Network bridge: management and VM/CT traffic on the LAN

## Build notes

Document your exact steps below.

### Chassis and drive mounting

- Step 1: Install the motherboard, CPU, RAM, boot NVMe, and the data disks you actually plan to use.
- Step 2: Mount the drives, connect power and SATA or NVMe cabling, and verify airflow.
- Step 3: Label the disks by role so the boot disk and storage disks are never confused later.

Record the final physical layout so the machine can be rebuilt later without trial and error:

- which bay each disk occupies
- which disk is used for boot
- which disk is reserved for VM storage
- where the SATA or power split is attached
- whether any cable routing affects airflow
- the capacity of each bulk disk so you can scale future growth without guessing

### SATA power split / custom wiring

> If you soldered or customized cabling, document wire colors, pin mapping, and safety checks.

- Source connector:
- Split connector(s):
- Continuity test result:
- Voltage verification:

### Photos to capture

- [ ] Motherboard + installed NVMe drives
- [ ] HDD mounting points
- [ ] Power/data cable routing
- [ ] Final cable management

### Suggested photo set

If you want a reproducible build log, capture these images:

- Front of chassis with drive bays visible
- Rear of chassis with networking and power visible
- Open chassis showing boot disk and bulk data disk locations
- Any controller or adapter card that is being passed through
- Label close-up for any disk or cable you plan to reference later

## Rebuild notes

- Keep a labeled list of drive serials if possible.
- Write down which disk is safe to wipe and which disk is the host boot device.
- If the machine has a removable storage controller or expansion card, document where it lives physically before moving to virtualization setup.
- The physical build phase is done at the server with a keyboard and screen attached.

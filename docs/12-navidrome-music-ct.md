# 12 - Navidrome Music CT

## Purpose

Navidrome is the music service.
It is optional, so build it only after the core lab is working.

## Where to run this

- Proxmox host: create or inspect the Music CT.
- Proxmox host shell: run the community-scripts helper.
- Music CT shell: verify media paths and scan permissions.
- Browser: open the Navidrome UI from the local network.

## Current build snapshot

- CT role: Music CT
- CTID: `102`
- Known app port: `4533`
- This is optional and should stay simple: one music library, one web UI, one backup path.

## Community script install

Run this on the Proxmox host shell:

```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/community-scripts/ProxmoxVE/main/ct/navidrome.sh)"
```

If you use the helper, verify the final CT config with `pct config 102`.

## Capture the exact CT settings

Run this on the Proxmox host:

```bash
pct config 102 | rg '^(cores|memory|swap|rootfs|mp|net0|features|unprivileged|onboot):'
pct exec 102 -- sh -lc 'docker ps -a 2>/dev/null || true; docker compose ls 2>/dev/null || true'
```

## Install path

1. Create the CT with the helper or through Proxmox.
2. Attach the music library from shared storage.
3. Open the UI on port `4533`.
4. Create or confirm the library path.
5. Run the first media scan.
6. Make sure the music files are readable by the service user.

## Library setup

Use a shared storage path for music instead of leaving the collection on the CT boot disk.

Suggested flow:

1. Mount the music dataset into the CT.
2. Point Navidrome at the mounted path.
3. Trigger a library scan.
4. Confirm album art and metadata show up.
5. Add tags or playlists only after the library is stable.

If your music library is read-only, keep it read-only in the mount so an app bug cannot rewrite your files.

## First-run checks

- The UI opens.
- The library path is visible.
- The first scan completes.
- A test album plays.

## Validation

- [ ] The Navidrome UI opens
- [ ] The music library is readable
- [ ] The CT config matches `pct config 102`
- [ ] The first scan completed successfully
- [ ] Audio playback works from the browser

## Next step

After the music service, continue to the Media CT in [`./13-jellyfin-media-ct.md`](./13-jellyfin-media-ct.md).

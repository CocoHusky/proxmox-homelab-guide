# 13 - Jellyfin Media CT

## Purpose

Jellyfin is the media library for movies and TV.
It is optional and belongs after the core lab and the music service.

## Where to run this

- Proxmox host: create or inspect the Media CT.
- Proxmox host shell: run the community-scripts helper.
- Media CT shell: verify storage and hardware acceleration settings.
- Browser: open the Jellyfin UI from the local network.

## Current build snapshot

- CT role: Media CT
- CTID: `103`
- Known app port: `8096`
- This is optional and becomes more useful once the core lab is already stable.

## Community script install

Run this on the Proxmox host shell:

```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/community-scripts/ProxmoxVE/main/ct/jellyfin.sh)"
```

If you use the helper, verify the final CT config with `pct config 103`.

## Capture the exact CT settings

Run this on the Proxmox host:

```bash
pct config 103 | rg '^(cores|memory|swap|rootfs|mp|net0|features|unprivileged|onboot):'
pct exec 103 -- sh -lc 'docker ps -a 2>/dev/null || true; docker compose ls 2>/dev/null || true'
```

## Install path

1. Create the CT with the helper or through Proxmox.
2. Attach media storage from shared storage.
3. Open Jellyfin on port `8096`.
4. Create the first admin account.
5. Add your media libraries.
6. Verify the library and transcoding settings if you use them.
7. Decide whether you need hardware acceleration before exposing it to family or friends.

## Media setup

Use separate library folders for movies and TV if you care about metadata accuracy.

Suggested flow:

1. Mount the shared media dataset.
2. Add the movie library.
3. Add the TV library.
4. Add the music library only if you want Jellyfin to own it as well.
5. Trigger a library scan.
6. Confirm posters and metadata appear correctly.

## Transcoding setup

If you want transcoding:

- Prefer Intel Quick Sync when the host CPU supports it.
- Use a passed-through GPU only if you already know the hardware path.
- Keep a transcode temp directory on fast storage.
- Test one 1080p file before you trust the setup.

If you do not need transcoding, keep the setup simple and skip GPU passthrough entirely.

## First-run checks

- The admin account logs in.
- The media library scans.
- Playback works on a client device.
- Transcoding works if enabled.

## Validation

- [ ] Jellyfin opens in the browser
- [ ] The media library is readable
- [ ] The CT config matches `pct config 103`
- [ ] The admin account can log in
- [ ] At least one media item plays successfully
- [ ] Transcoding works if you enabled it

## Next step

After the media service, continue to the Telemetry CT in [`./14-teslamate-telemetry-ct.md`](./14-teslamate-telemetry-ct.md).

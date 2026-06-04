# 09 - Vaultwarden Password CT

## Purpose

Vaultwarden is the password manager in the lab.
If you use it day to day, treat it as operationally important and back it up carefully.

## Where to run this

- Proxmox host: create or inspect the Password CT.
- Proxmox host shell: run the community-scripts helper.
- Password CT shell: verify storage, bind address, and the app port.
- Browser: open the Vaultwarden web UI on the local network.

## Current build snapshot

- CT role: Password CT
- CTID: `105`
- Known app port: `8000`
- This service is useful enough to treat as core infrastructure if you use it every day.

## Community script install

Run this on the Proxmox host shell:

```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/community-scripts/ProxmoxVE/main/ct/vaultwarden.sh)"
```

If you use the helper, verify the final CT config with `pct config 105`.

## Capture the exact CT settings

Run this on the Proxmox host:

```bash
pct config 105 | rg '^(cores|memory|swap|rootfs|mp|net0|features|unprivileged|onboot):'
pct exec 105 -- sh -lc 'docker ps -a 2>/dev/null || true; docker compose ls 2>/dev/null || true'
```

## Install path

1. Create the CT with the helper or through Proxmox.
2. Open the Vaultwarden web UI on port `8000`.
3. Put the Vaultwarden data path on storage that is part of your backup plan.
4. Decide whether signups are allowed or disabled.
5. Create your first vault entries.
6. Restrict access behind a proxy if you publish it beyond the LAN.

## First-run settings

For a simple home lab:

- Keep signups disabled after the first admin is set up.
- Use a strong admin password.
- Turn on two-factor authentication in the vault itself if you use it daily.
- Store the database and attachments on backed-up storage.
- Expose the admin page only where you actually need it.

If you are using the Docker helper or a compose file, keep the environment variables in your local notes and record the exact values used for:

- `ADMIN_TOKEN`
- `SIGNUPS_ALLOWED`
- `DOMAIN`
- `ROCKET_PORT`

## Suggested local workflow

1. Create the account you will use every day.
2. Import existing passwords from your previous manager if needed.
3. Create collections for family, work, and shared items only if you need them.
4. Verify browser autofill works before you expose the service beyond the LAN.

## Validation

- [ ] Vaultwarden opens in the browser
- [ ] The data path is on backed-up storage
- [ ] The CT config matches `pct config 105`
- [ ] Signups are set the way you intend
- [ ] Two-factor authentication is enabled if you want it
- [ ] The vault can be opened again after a restart

## Next step

After Vaultwarden is working, continue to the Proxy CT in [`./10-nginx-proxy-manager-proxy-ct.md`](./10-nginx-proxy-manager-proxy-ct.md).

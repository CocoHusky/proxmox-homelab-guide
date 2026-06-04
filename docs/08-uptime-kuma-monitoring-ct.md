# 08 - Uptime Kuma Monitoring CT

## Purpose

Uptime Kuma watches the lab and sends alerts when something goes down.
This is one of the core services because it tells you when the rest of the stack fails.

## Where to run this

- Proxmox host: create or inspect the Monitoring CT.
- Proxmox host shell: run the community-scripts helper.
- Monitoring CT shell: configure checks and Telegram alerts.
- Phone or chat client: verify the alert lands where expected.

## Current build snapshot

- CT role: Monitoring CT
- CTID: `106`
- Known app port: `3001`
- This is the reference monitor CT, not a hard pin. If you choose a newer compatible build method, keep the same role and confirm the final CT config with Proxmox.

## Community script install

Run this on the Proxmox host shell:

```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/community-scripts/ProxmoxVE/main/ct/uptimekuma.sh)"
```

If you use the helper, verify the final CT config with `pct config 106`.

## Capture the exact CT settings

Run this on the Proxmox host:

```bash
pct config 106 | rg '^(cores|memory|swap|rootfs|mp|net0|features|unprivileged|onboot):'
pct exec 106 -- sh -lc 'docker ps -a 2>/dev/null || true; docker compose ls 2>/dev/null || true'
```

## Install path

1. Create the CT with the helper or through Proxmox.
2. Open Uptime Kuma on port `3001`.
3. Add a monitor for the Proxmox host first, then add Nextcloud and Immich.
4. Add any supporting services you actually depend on, such as the proxy, password manager, or dashboard.
5. Set the monitor name to the human role, not just the host name, so the alert is readable later.
6. Add Telegram notifications.
7. Send one test alert before moving on.

When you build this for a friend, the first question to ask is: “What would I be unhappy not knowing about right away?” Those services become the first monitors.

## Suggested monitor set

Start with the services you would want to know about immediately if they failed:

- Proxmox host over HTTP or ping
- Storage VM / TrueNAS web UI
- Nextcloud AIO web UI
- Immich web UI
- Nginx Proxy Manager web UI
- Vaultwarden web UI if you use it daily

Add optional services only after the essential ones are in place:

- Homarr
- Navidrome
- Jellyfin
- Teslamate

If you need a very simple first pass, monitor only these three things:

1. Proxmox host reachability
2. Nextcloud AIO availability
3. Immich availability

Then add the rest one by one so the alert list stays useful instead of noisy.

## Telegram notification setup

Use the Telegram option in Uptime Kuma's notification settings.

Suggested setup sequence:

1. In Telegram, create or use a bot token with BotFather.
2. Open a chat with the bot or add it to the group you want notified.
3. In Uptime Kuma, open the notification settings and choose Telegram.
4. Paste the bot token.
5. Paste the chat ID for the chat or group.
6. Save the notification method.
7. Use the built-in test button and make sure the message arrives.

If the bot token works but the chat ID does not, re-check whether you used a direct chat ID or a group chat ID.
If you are using a group, make sure the bot is actually a member of that group.

If you need to discover the chat ID manually, send one message to the bot, then run this from any machine with curl:

```bash
curl -s "https://api.telegram.org/bot<BOT_TOKEN>/getUpdates"
```

Look for the `chat.id` value in the response and paste that into Uptime Kuma.

## What to configure on each monitor

For each monitor:

- Use a short readable name, such as `Proxmox Host` or `Nextcloud AIO`
- Pick the correct monitor type:
  - HTTP(s) for web UIs
  - Ping for host reachability
  - TCP for a specific service port
- Set a reasonable interval, such as 30 seconds for core services and 60 seconds for optional ones
- Add a retry count so one brief network hiccup does not spam you
- Attach the Telegram notification method

Good defaults for the first pass:

- Proxmox host: ping or HTTP check every 30 seconds
- Nextcloud AIO: HTTP check every 30 seconds
- Immich: HTTP check every 30 seconds
- Support services: 60 seconds unless you depend on them all day

Use the public or browser-facing URL for each service, not an internal container port, when the service is meant to be used through a proxy.

## What to verify before you rely on it

- The test Telegram message arrives.
- The monitor status changes correctly when you stop one service.
- The alert names are readable enough that you know what failed without opening the UI.
- The monitor list covers the services you actually care about, not every possible thing in the lab.
- The retry setting prevents a single transient network blip from generating noise.

## Validation

- [ ] Uptime Kuma opens in the browser
- [ ] A test Telegram alert arrives
- [ ] The main lab services are listed as monitors
- [ ] The monitor names are readable and meaningful
- [ ] The retry and interval values are set for the service importance
- [ ] The CT config matches `pct config 106`

## Next step

After monitoring is working, continue to the Password CT in [`./09-vaultwarden-password-ct.md`](./09-vaultwarden-password-ct.md).

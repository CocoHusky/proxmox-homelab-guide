#!/usr/bin/env bash
set -Eeuo pipefail

APPLY_HOST="false"
APPLY_CT="false"
VERBOSE="false"
YES="false"
SKIP_CTS=()
LOG_DIR="/root"
STAMP="$(date +%Y%m%d-%H%M%S)"
LOG_FILE="${LOG_DIR}/homelab-maintenance-${STAMP}.log"
HOST_DETECTED="not checked"
HOST_AFTER="not checked"
HOST_ACTION="not run"
VM_SUMMARY=()
CT_DETECTED=()
CT_UPDATED=()
CT_SKIPPED=()
CT_FAILED=()
CT_APP_NOTES=()
CT_DOCKER_NOTES=()

usage() {
  cat <<'USAGE'
Usage:
  ./proxmox-monthly-maintenance.sh
  ./proxmox-monthly-maintenance.sh --verbose
  ./proxmox-monthly-maintenance.sh --apply-host
  ./proxmox-monthly-maintenance.sh --apply-ct
  ./proxmox-monthly-maintenance.sh --apply-ct --skip-ct <CTID>
  ./proxmox-monthly-maintenance.sh --apply-all
  ./proxmox-monthly-maintenance.sh --apply-host --yes

Default mode reports pending Proxmox host and running LXC package updates.

Use --apply-host to install Proxmox host package updates.
Use --apply-ct to install apt-based updates inside running Debian/Ubuntu-style
LXCs. This can include application packages that are installed from apt repos.
Use --apply-all to do both.

Use --verbose to print the full package list. Without --verbose, the script
prints counts and important package names so the monthly report stays readable.

Use --skip-ct CTID to leave a specific CT alone. Repeat it for multiple CTs.

Apply modes ask for backup confirmation. Use --yes only when backups and
restore readiness have already been confirmed.

This script does not update TrueNAS, Nextcloud AIO, Docker Compose apps, or
apps that are not installed through apt. Handle those through their supported
update UI or app-specific release notes.
USAGE
}

while [[ "$#" -gt 0 ]]; do
  arg="$1"
  case "$arg" in
    --apply)
      APPLY_HOST="true"
      APPLY_CT="true"
      ;;
    --apply-host)
      APPLY_HOST="true"
      ;;
    --apply-ct)
      APPLY_CT="true"
      ;;
    --apply-all)
      APPLY_HOST="true"
      APPLY_CT="true"
      ;;
    --verbose)
      VERBOSE="true"
      ;;
    --yes)
      YES="true"
      ;;
    --skip-ct)
      if [[ -z "${2:-}" || ! "${2:-}" =~ ^[0-9]+$ ]]; then
        echo "--skip-ct requires a numeric CTID." >&2
        exit 2
      fi
      SKIP_CTS+=("$2")
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown argument: $arg" >&2
      usage
      exit 2
      ;;
  esac
  shift
done

if [[ "$(id -u)" -ne 0 ]]; then
  echo "Run this as root on the Proxmox host." >&2
  exit 1
fi

mkdir -p "$LOG_DIR"
exec > >(tee -a "$LOG_FILE") 2>&1

section() {
  printf '\n== %s ==\n' "$1"
}

print_upgrade_summary() {
  local label="$1"
  local upgrades="$2"
  local count
  count="$(printf '%s\n' "$upgrades" | sed '/^$/d' | wc -l | tr -d ' ')"

  echo "${label}: ${count} package(s)"

  if [[ "$count" -eq 0 ]]; then
    return
  fi

  echo "Important-looking packages:"
  printf '%s\n' "$upgrades" \
    | grep -Ei '^(proxmox|pve-|qemu|zfs|lxc|corosync|jellyfin|immich|vaultwarden|navidrome|grafana|teslamate|postgresql|redis|nodejs|openresty|tailscale|docker|containerd|nginx|openssl|openssh|systemd|linux|libc6)' \
    || echo "None matched the important package filter."

  if [[ "$VERBOSE" == "true" ]]; then
    echo
    echo "Full package list:"
    printf '%s\n' "$upgrades"
  else
    echo "Use --verbose to print the full package list."
  fi
}

count_upgrades() {
  local upgrades="$1"
  printf '%s\n' "$upgrades" | sed '/^$/d' | wc -l | tr -d ' '
}

confirm_backups_for_apply() {
  local confirmation

  if [[ "$APPLY_HOST" != "true" && "$APPLY_CT" != "true" ]]; then
    return
  fi

  if [[ "$YES" == "true" ]]; then
    return
  fi

  section "Backup confirmation"
  echo "Apply mode can change the Proxmox host and/or CT operating systems."
  echo "Before continuing, confirm:"
  echo "- Latest Proxmox backup job succeeded"
  echo "- Important CTs/VMs have a current restore point"
  echo "- TrueNAS config backup exists"
  echo "- You are ready to reboot Proxmox if host packages require it"
  echo
  printf 'Type BACKED UP to continue: '
  read -r confirmation

  if [[ "$confirmation" != "BACKED UP" ]]; then
    echo "Backup confirmation was not provided. Exiting without applying updates."
    exit 1
  fi
}

run_or_note() {
  local description="$1"
  shift

  echo "+ ${description}"
  "$@"
}

should_skip_ct() {
  local ct_id="$1"
  local skipped_ct

  for skipped_ct in "${SKIP_CTS[@]}"; do
    if [[ "$ct_id" == "$skipped_ct" ]]; then
      return 0
    fi
  done

  return 1
}

section "Homelab monthly maintenance"
echo "Apply host updates: ${APPLY_HOST}"
echo "Apply CT apt updates: ${APPLY_CT}"
echo "Verbose package lists: ${VERBOSE}"
echo "Skip backup prompt: ${YES}"
if [[ "${#SKIP_CTS[@]}" -gt 0 ]]; then
  echo "Skipped CTIDs: ${SKIP_CTS[*]}"
else
  echo "Skipped CTIDs: none"
fi
echo "Started: $(date -Is)"
echo "Log: ${LOG_FILE}"

confirm_backups_for_apply

section "Safety checks"
echo "Before applying updates, confirm:"
echo "- Latest Proxmox backup job succeeded"
echo "- TrueNAS config backup exists"
echo "- Uptime Kuma or manual checks are ready"
echo "- You have time to reboot if the host kernel updates"

section "Proxmox host package updates"
run_or_note "Refresh host package metadata" apt-get update

echo
HOST_UPGRADES="$(apt list --upgradable 2>/dev/null | sed '1d' || true)"
HOST_DETECTED="$(count_upgrades "$HOST_UPGRADES")"
print_upgrade_summary "Pending host packages" "$HOST_UPGRADES"

if [[ "$APPLY_HOST" == "true" ]]; then
  echo
  run_or_note "Install host package updates" apt-get -y dist-upgrade
  HOST_AFTER="$(count_upgrades "$(apt list --upgradable 2>/dev/null | sed '1d' || true)")"
  HOST_ACTION="updated (${HOST_DETECTED} before, ${HOST_AFTER} after)"
else
  echo
  echo "Host report only. Re-run with --apply-host to install host package updates."
  HOST_ACTION="report only (${HOST_DETECTED} pending)"
fi

section "Virtual machine inventory"
if command -v qm >/dev/null 2>&1; then
  QM_LIST="$(qm list || true)"
  printf '%s\n' "$QM_LIST"
  while read -r vmid name status _; do
    if [[ "$vmid" =~ ^[0-9]+$ ]]; then
      VM_SUMMARY+=("${vmid} ${name} status=${status} not-updated-by-this-script")
    fi
  done <<< "$QM_LIST"
  echo
  echo "VM operating systems are not updated from this host script."
  echo "Update TrueNAS from the TrueNAS UI and other VMs from inside the VM."
else
  echo "qm command not found; skipping VM inventory."
fi

section "LXC operating system updates"
if ! command -v pct >/dev/null 2>&1; then
  echo "pct command not found; skipping LXC updates."
  CT_FAILED+=("pct command not found; no LXC checks ran")
else
  mapfile -t CT_IDS < <(pct list | awk 'NR > 1 {print $1}')

  if [[ "${#CT_IDS[@]}" -eq 0 ]]; then
    echo "No LXCs found."
    CT_SKIPPED+=("no LXCs found")
  fi

  for ct_id in "${CT_IDS[@]}"; do
    ct_status="$(pct status "$ct_id" | awk '{print $2}')"
    ct_name="$(pct config "$ct_id" 2>/dev/null | awk -F': ' '/^hostname:/ {print $2; exit}')"
    ct_name="${ct_name:-unknown}"

    echo
    echo "-- CT ${ct_id} (${ct_name}) status=${ct_status}"

    if should_skip_ct "$ct_id"; then
      echo "Skipping CT because it was listed with --skip-ct."
      CT_SKIPPED+=("${ct_id} ${ct_name}: skipped by --skip-ct")
      continue
    fi

    if [[ "$ct_status" != "running" ]]; then
      echo "Skipping stopped CT."
      CT_SKIPPED+=("${ct_id} ${ct_name}: stopped")
      continue
    fi

    if ! pct exec "$ct_id" -- sh -c 'command -v apt-get >/dev/null 2>&1'; then
      echo "Skipping CT without apt-get."
      CT_SKIPPED+=("${ct_id} ${ct_name}: no apt-get")
      continue
    fi

    if ! pct exec "$ct_id" -- sh -c 'apt-get update >/dev/null'; then
      echo "Failed to refresh package metadata in CT ${ct_id}; skipping this CT."
      CT_FAILED+=("${ct_id} ${ct_name}: apt metadata refresh failed")
      continue
    fi

    CT_UPGRADES="$(pct exec "$ct_id" -- sh -c 'apt list --upgradable 2>/dev/null | sed "1d" || true')"
    CT_BEFORE_COUNT="$(count_upgrades "$CT_UPGRADES")"
    CT_DETECTED+=("${ct_id} ${ct_name}: ${CT_BEFORE_COUNT} pending")
    print_upgrade_summary "Pending CT packages" "$CT_UPGRADES"

    if [[ "$APPLY_CT" == "true" ]]; then
      if ! pct exec "$ct_id" -- sh -c 'DEBIAN_FRONTEND=noninteractive apt-get -y upgrade'; then
        echo "Failed to install package updates in CT ${ct_id}; review this CT manually."
        CT_FAILED+=("${ct_id} ${ct_name}: apt upgrade failed")
      else
        CT_AFTER_UPGRADES="$(pct exec "$ct_id" -- sh -c 'apt list --upgradable 2>/dev/null | sed "1d" || true')"
        CT_AFTER_COUNT="$(count_upgrades "$CT_AFTER_UPGRADES")"
        CT_UPDATED+=("${ct_id} ${ct_name}: updated (${CT_BEFORE_COUNT} before, ${CT_AFTER_COUNT} after)")
      fi
    else
      echo "CT report only. Re-run with --apply-ct to install apt updates inside CTs."
    fi

    if pct exec "$ct_id" -- sh -c 'test -x /usr/bin/update' >/dev/null 2>&1; then
      echo "App note: /usr/bin/update exists in this CT. Review the app docs before running it."
      CT_APP_NOTES+=("${ct_id} ${ct_name}: /usr/bin/update exists")
    fi

    if pct exec "$ct_id" -- sh -c 'command -v docker >/dev/null 2>&1' >/dev/null 2>&1; then
      echo "Docker note: Docker is installed in this CT."
      pct exec "$ct_id" -- sh -c 'docker compose ls 2>/dev/null || true'
      echo "Docker apps are not auto-updated by this script."
      CT_DOCKER_NOTES+=("${ct_id} ${ct_name}: Docker installed; Docker apps not updated")
    fi
  done
fi

section "Run summary"
echo "Host: ${HOST_ACTION}"

echo
echo "VMs detected:"
if [[ "${#VM_SUMMARY[@]}" -eq 0 ]]; then
  echo "- none detected or qm unavailable"
else
  printf -- '- %s\n' "${VM_SUMMARY[@]}"
fi

echo
echo "CT package updates detected:"
if [[ "${#CT_DETECTED[@]}" -eq 0 ]]; then
  echo "- none"
else
  printf -- '- %s\n' "${CT_DETECTED[@]}"
fi

echo
echo "CTs updated:"
if [[ "${#CT_UPDATED[@]}" -eq 0 ]]; then
  echo "- none"
else
  printf -- '- %s\n' "${CT_UPDATED[@]}"
fi

echo
echo "CTs skipped:"
if [[ "${#CT_SKIPPED[@]}" -eq 0 ]]; then
  echo "- none"
else
  printf -- '- %s\n' "${CT_SKIPPED[@]}"
fi

echo
echo "Failures or blockers:"
if [[ "${#CT_FAILED[@]}" -eq 0 ]]; then
  echo "- none"
else
  printf -- '- %s\n' "${CT_FAILED[@]}"
fi

echo
echo "App-specific notes:"
if [[ "${#CT_APP_NOTES[@]}" -eq 0 && "${#CT_DOCKER_NOTES[@]}" -eq 0 ]]; then
  echo "- none"
else
  printf -- '- %s\n' "${CT_APP_NOTES[@]}"
  printf -- '- %s\n' "${CT_DOCKER_NOTES[@]}"
fi

section "Post-update reminders"
echo "- Check Proxmox UI for reboot-required hints or kernel updates."
echo "- Update TrueNAS from the TrueNAS web UI."
echo "- Update Nextcloud AIO from the AIO interface."
echo "- Update Docker Compose apps one at a time after reading release notes."
echo "- Open Uptime Kuma and confirm core services are healthy."
echo "- Keep this log with your maintenance notes: ${LOG_FILE}"
echo "Finished: $(date -Is)"

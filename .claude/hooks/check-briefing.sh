#!/usr/bin/env bash
# PostToolUse hook (Edit|Write): after index.html changes, confirm the IT Project Briefing
# popup is still wired up with the agreed details. Runs on every matching edit, so it does
# not depend on the model remembering. On failure it exits 2 and the message goes back to Claude.

input=$(cat)
case "$input" in
  *index.html*) ;;      # only react to edits of index.html
  *) exit 0 ;;
esac

# Resolve index.html from the project dir the harness provides (fallback: two levels up from this script).
root="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/../.." && pwd)}"
file="$root/index.html"
[ -f "$file" ] || exit 0

problems=""
need() { grep -qF -- "$1" "$file" || problems="$problems\n - $2"; }

need 'id="briefingDialog"'                 'briefing <dialog id="briefingDialog"> is missing'
need 'BRIEFING_DELAY_MS = 10000'           'popup delay must stay at 10 seconds (BRIEFING_DELAY_MS = 10000)'
need 'setTimeout(showBriefing, BRIEFING_DELAY_MS)' 'init() must schedule showBriefing after BRIEFING_DELAY_MS'
need 'date: "2026-10-14"'                  'briefing date must be 2026-10-14 (Wed 14 Oct 2026)'
need 'time: "14:00"'                       'briefing time must be 14:00 (2 PM)'
need 'venue: "Town Hall Meeting Room"'     'briefing venue must be "Town Hall Meeting Room"'
need 'IT Project Briefing'                 'popup title "IT Project Briefing" is missing'

# Project rule: no alert()/confirm() dialogs.
if grep -nE '\b(alert|confirm)\(' "$file" >/dev/null; then
  problems="$problems\n - alert()/confirm() found; use the inline <dialog> instead"
fi

if [ -n "$problems" ]; then
  printf 'Briefing popup check failed in index.html:%b\n' "$problems" >&2
  exit 2
fi
exit 0

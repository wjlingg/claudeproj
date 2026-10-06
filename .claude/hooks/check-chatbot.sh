#!/usr/bin/env bash
# PostToolUse hook (Edit|Write): after index.html changes, confirm the chatbot icon and its
# suggested-queries dialog are still wired up and still respect the project's rules.
# Exits 2 with a message on failure so the feedback goes back to Claude.

input=$(cat)
case "$input" in
  *index.html*) ;;      # only react to edits of index.html
  *) exit 0 ;;
esac

root="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/../.." && pwd)}"
file="$root/index.html"
[ -f "$file" ] || exit 0

problems=""
need() { grep -qF -- "$1" "$file" || problems="$problems\n - $2"; }

need 'id="chatbotBtn"'                        'chatbot icon <button id="chatbotBtn"> is missing'
need 'aria-label="Open IT project assistant"' 'chatbot icon needs aria-label="Open IT project assistant"'
need 'id="chatbotDialog"'                     'chatbot <dialog id="chatbotDialog"> is missing'
need 'id="chatChips"'                         'suggested-query container id="chatChips" is missing'
need 'const SUGGESTED_QUERIES = ['             'SUGGESTED_QUERIES list is missing'
need '$("chatbotBtn").addEventListener("click", openChatbot)' 'clicking the chatbot icon must call openChatbot()'

# At least 5 suggested queries (each entry declares an id and a label).
count=$(grep -cE '^\s*\{ id: "[a-z]+", label: ' "$file")
[ "$count" -ge 5 ] || problems="$problems\n - expected at least 5 suggested queries, found $count"

# Project rules: no alert()/confirm(); the only network call is the FormSubmit fetch.
grep -nE '\b(alert|confirm)\(' "$file" >/dev/null && problems="$problems\n - alert()/confirm() found; use the inline <dialog> instead"
fetches=$(grep -cE '\bfetch\(' "$file")
[ "$fetches" -le 1 ] || problems="$problems\n - $fetches fetch() calls found; the chatbot must answer from state.tasks, with FormSubmit as the only network call"

if [ -n "$problems" ]; then
  printf 'Chatbot check failed in index.html:%b\n' "$problems" >&2
  exit 2
fi
exit 0

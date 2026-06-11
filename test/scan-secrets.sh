#!/bin/sh
# scan-secrets.sh — fail if anything secret-looking lands in harnesses/.
#
# The repo is public and holds personal harness configs. Auth normally lives in
# separate files (Claude credentials store, Codex auth.json, …), so configs are
# secret-free — but a harness could later write a token into a config we track.
# This is the gate. CI runs it; run it before pushing too.

set -eu

REPO="$(cd "$(dirname "$0")/.." && pwd)"
DIR="$REPO/harnesses"
[ -d "$DIR" ] || { echo "no harnesses/ dir — nothing to scan"; exit 0; }

TMP="$(mktemp)"
trap 'rm -f "$TMP"' EXIT INT TERM

# High-signal patterns: real token shapes, private keys, and assignments whose
# VALUE is present and long (so `"token": ""` or a bare key name won't trip it).
echo "Scanning $DIR for secrets…"
while IFS= read -r pat; do
  [ -n "$pat" ] || continue
  grep -rniE "$pat" "$DIR" >> "$TMP" 2>/dev/null || true
done <<'PATTERNS'
sk-[A-Za-z0-9]{20,}
gh[pousr]_[A-Za-z0-9]{20,}
AKIA[0-9A-Z]{16}
xox[baprs]-[A-Za-z0-9-]{10,}
-----BEGIN [A-Z ]*PRIVATE KEY-----
eyJ[A-Za-z0-9_-]{20,}\.[A-Za-z0-9_-]{20,}\.[A-Za-z0-9_-]{10,}
(api[_-]?key|secret|password|passwd|access[_-]?token|bearer)["' ]*[:=]["' ]*[A-Za-z0-9_/+.-]{16,}
PATTERNS

if [ -s "$TMP" ]; then
  echo "POTENTIAL SECRET(S) FOUND in harnesses/ — do not commit:" >&2
  sort -u "$TMP" >&2
  exit 1
fi
echo "OK — no secrets in harnesses/"

#!/bin/sh
# add-skill.sh — vendor a skill INTO this repo using the standard `npx skills` CLI.
#
# The `npx skills add` CLI (https://github.com/vercel-labs/skills) only installs into
# predetermined agent dirs — it can't target this repo's skills/ source folder. This
# wrapper runs it in a scratch dir, then moves the resulting skill into skills/<name>/
# so the repo stays the single source of truth. After importing it validates the skill;
# pass --install to also symlink it into every harness.
#
# Usage:
#   ./scripts/add-skill.sh <source> [--skill NAME ...] [--list] [--force] [--install]
#
#   <source>      author/repo | full GitHub/GitLab/git URL | local path
#   --skill NAME  pick specific skill(s) from the source (forwarded to the CLI; repeatable)
#   --list        list what the source offers, import nothing (forwarded to the CLI)
#   --force       overwrite a skill of the same name already in skills/
#   --install     run ./install.sh after importing, to wire it into your harnesses
#   --help        show this help
#
# Examples:
#   ./scripts/add-skill.sh vercel-labs/skills --list
#   ./scripts/add-skill.sh owner/repo --skill some-skill
#   ./scripts/add-skill.sh owner/repo --skill some-skill --install

set -eu

REPO="$(cd "$(dirname "$0")/.." && pwd)"
SKILLS_DIR="$REPO/skills"

SOURCE="" FORCE=0 INSTALL=0 LIST=0
PASS="" # args forwarded to the CLI (e.g. --skill NAME)
while [ $# -gt 0 ]; do
  case "$1" in
    --force)    FORCE=1 ;;
    --install)  INSTALL=1 ;;
    --list|-l)  LIST=1; PASS="$PASS --list" ;;
    --skill|-s) shift; [ $# -gt 0 ] || { echo "--skill needs a NAME" >&2; exit 2; }
                PASS="$PASS --skill $1" ;;
    --help|-h)  sed -n '2,21p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
    -*)         echo "unknown option: $1 (try --help)" >&2; exit 2 ;;
    *)          if [ -z "$SOURCE" ]; then SOURCE="$1"; else echo "unexpected arg: $1" >&2; exit 2; fi ;;
  esac
  shift
done
[ -n "$SOURCE" ] || { echo "need a <source> (try --help)" >&2; exit 2; }
command -v npx >/dev/null 2>&1 || { echo "npx not found — install Node.js first" >&2; exit 1; }

# --list: just forward to the CLI and stop. Nothing is imported.
if [ "$LIST" -eq 1 ]; then
  # shellcheck disable=SC2086
  exec npx -y skills add "$SOURCE" $PASS
fi

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT INT TERM

echo "Fetching '$SOURCE' via npx skills…"
# Install project-local into the scratch dir as real files (--copy, non-interactive).
# We target one agent (claude-code) just to get the files on disk; destination dir is
# discovered below by locating SKILL.md, so the exact agent layout doesn't matter.
# shellcheck disable=SC2086
( cd "$TMP" && npx -y skills add "$SOURCE" --copy -y -a claude-code $PASS >/dev/null 2>&1 ) || {
  echo "npx skills add failed. Re-run with --list to see what '$SOURCE' offers." >&2
  exit 1
}

# Each imported skill is the directory that directly contains a SKILL.md.
LIST_FILE="$(mktemp)"
trap 'rm -rf "$TMP" "$LIST_FILE"' EXIT INT TERM
find "$TMP" -name SKILL.md -type f > "$LIST_FILE" 2>/dev/null || true

found=0 imported=0 skipped=0
while IFS= read -r skillmd; do
  [ -n "$skillmd" ] || continue
  found=$((found + 1))
  src="$(dirname "$skillmd")"
  name="$(basename "$src")"
  dest="$SKILLS_DIR/$name"
  if [ -e "$dest" ]; then
    if [ "$FORCE" -eq 1 ]; then
      rm -rf "$dest"
    else
      echo "  skip  $name (already in skills/ — use --force to overwrite)"
      skipped=$((skipped + 1)); continue
    fi
  fi
  cp -R "$src" "$dest"
  echo "  added skills/$name"
  imported=$((imported + 1))
done < "$LIST_FILE"

if [ "$found" -eq 0 ]; then
  echo "No SKILL.md found for '$SOURCE'. Re-run with --list to inspect it." >&2
  exit 1
fi
[ "$imported" -gt 0 ] || { echo "Nothing imported ($skipped skipped)."; exit 0; }

echo
echo "Validating…"
"$REPO/test/run.sh"

if [ "$INSTALL" -eq 1 ]; then
  echo
  "$REPO/install.sh"
else
  echo
  echo "Next: review the skill, then './install.sh' to wire it in, and commit."
fi

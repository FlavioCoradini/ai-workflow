#!/bin/sh
# test_install.sh — install.sh collision handling.
#
# Runs install.sh against a throwaway --target dir, with HOME pointed at an empty
# temp dir so the built-in harness table finds nothing and only the target is touched.
# Asserts that install.sh never hijacks a name it doesn't own.

set -eu

REPO="$(cd "$(dirname "$0")/.." && pwd)"
SKILLS_DIR="$REPO/skills"
fail=0
pick() { for d in "$SKILLS_DIR"/*/; do [ -f "$d/SKILL.md" ] && { basename "${d%/}"; return; }; done; }
A="$(pick)"  # an arbitrary real skill name from the repo to use in assertions
[ -n "$A" ] || { echo "no skills in repo to test against" >&2; exit 1; }

check() { # <desc> <expected> <actual>
  if [ "$2" = "$3" ]; then printf '  ok   %s\n' "$1"
  else printf '  FAIL %s\n       expected: %s\n       actual:   %s\n' "$1" "$2" "$3"; fail=1; fi
}

abslink() { readlink "$1" 2>/dev/null || true; }

SANDBOX="$(mktemp -d)"
trap 'rm -rf "$SANDBOX"' EXIT INT TERM
HOMEDIR="$SANDBOX/home"; TARGET="$SANDBOX/skills"
mkdir -p "$HOMEDIR" "$TARGET"

# Three pre-existing entries the installer must respect:
mkdir -p "$TARGET/$A"                              # 1) a real folder (someone's hand-made skill)
ln -s /somewhere/else "$TARGET/foreign-skill"      # 2) a foreign symlink (e.g. from npx skills)
ln -sfn "$SKILLS_DIR/$A" "$TARGET/ours-link"       # 3) one of our own symlinks (idempotent re-run)

echo "== default run (no --force): must not clobber 1 or 2 =="
HOME="$HOMEDIR" "$REPO/install.sh" --target "$TARGET" >/dev/null 2>&1 || true

# 1) real folder of name $A is untouched (still a dir, not a symlink)
[ -d "$TARGET/$A" ] && [ ! -L "$TARGET/$A" ] && r1=kept || r1=clobbered
check "real folder '$A' left alone" "kept" "$r1"

# 2) foreign symlink still points where it did
check "foreign symlink preserved" "/somewhere/else" "$(abslink "$TARGET/foreign-skill")"

# 3) our own symlink got (re)pointed into the repo
case "$(abslink "$TARGET/ours-link")" in "$SKILLS_DIR"/*) r3=repointed ;; *) r3=lost ;; esac
check "our own symlink repointed" "repointed" "$r3"

# a brand-new skill name with nothing in the way should have been linked in
NEW="$(for d in "$SKILLS_DIR"/*/; do n=$(basename "${d%/}"); [ "$n" != "$A" ] && { echo "$n"; break; }; done)"
case "$(abslink "$TARGET/$NEW")" in "$SKILLS_DIR"/*) rn=linked ;; *) rn=missing ;; esac
check "fresh skill '$NEW' linked" "linked" "$rn"

echo "== --force run: foreign entries get replaced =="
HOME="$HOMEDIR" "$REPO/install.sh" --target "$TARGET" --force >/dev/null 2>&1 || true
case "$(abslink "$TARGET/foreign-skill")" in "$SKILLS_DIR"/*) rf=replaced ;; *) rf=untouched ;; esac
# foreign-skill has no matching repo skill, so it should remain untouched even with --force
check "--force ignores names with no repo skill" "untouched" "$rf"
[ -L "$TARGET/$A" ] && rA=replaced || rA=kept
check "--force replaces real folder '$A'" "replaced" "$rA"

echo
if [ "$fail" -ne 0 ]; then echo "FAILED"; exit 1; fi
echo "OK — install collision handling correct"

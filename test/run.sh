#!/bin/sh
# test/run.sh — validate every skill against the Agent Skills open standard.
#
# For each skills/*/SKILL.md, check:
#   - YAML frontmatter exists (opens and closes with ---)
#   - `name` and `description` are present
#   - `name` equals its folder name
#   - `name` matches ^[a-z0-9]+(-[a-z0-9]+)*$ and is <= 64 chars
#   - `description` is <= 1024 chars
#
# Plain POSIX shell, no dependencies. CI runs exactly this.

set -eu

REPO="$(cd "$(dirname "$0")/.." && pwd)"
SKILLS_DIR="$REPO/skills"
fail=0 checked=0 skill_fail=0

err() { printf '  FAIL %s: %s\n' "$1" "$2"; fail=1; skill_fail=1; }

# Read a top-level scalar key out of the frontmatter block (first --- ... ---).
frontmatter_value() { # <file> <key>
  awk -v key="$2" '
    NR==1 && $0=="---" { inblock=1; next }
    inblock && $0=="---" { exit }
    inblock {
      if ($0 ~ "^" key "[ \t]*:") {
        sub("^" key "[ \t]*:[ \t]*", "")
        gsub(/^["'\''"]|["'\''"]$/, "")
        print; exit
      }
    }
  ' "$1"
}

has_frontmatter() { # <file>: opens with --- and has a closing ---
  head -1 "$1" | grep -q '^---$' || return 1
  awk 'NR==1{next} /^---$/{found=1;exit} END{exit !found}' "$1"
}

for dir in "$SKILLS_DIR"/*/; do
  [ -f "$dir/SKILL.md" ] || continue
  checked=$((checked + 1))
  folder="$(basename "${dir%/}")"
  file="$dir/SKILL.md"
  rel="skills/$folder/SKILL.md"
  skill_fail=0

  if ! has_frontmatter "$file"; then
    err "$rel" "missing YAML frontmatter (--- ... ---)"; continue
  fi

  name="$(frontmatter_value "$file" name)"
  desc="$(frontmatter_value "$file" description)"

  [ -n "$name" ] || err "$rel" "frontmatter missing 'name'"
  [ -n "$desc" ] || err "$rel" "frontmatter missing 'description'"

  [ "$name" = "$folder" ] || err "$rel" "name '$name' != folder '$folder'"

  if [ -n "$name" ] && ! printf '%s' "$name" | grep -Eq '^[a-z0-9]+(-[a-z0-9]+)*$'; then
    err "$rel" "name '$name' must be lowercase a-z0-9 with single hyphens"
  fi
  if [ "${#name}" -gt 64 ]; then err "$rel" "name longer than 64 chars"; fi
  if [ "${#desc}" -gt 1024 ]; then err "$rel" "description longer than 1024 chars"; fi

  [ "$skill_fail" -eq 0 ] && printf '  ok   %s\n' "$rel"
done

echo
if [ "$checked" -eq 0 ]; then echo "No skills found under $SKILLS_DIR" >&2; exit 1; fi
if [ "$fail" -ne 0 ]; then echo "FAILED — $checked skill(s) checked"; exit 1; fi
echo "OK — $checked skill(s) valid"

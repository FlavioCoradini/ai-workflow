#!/bin/sh
# setup.sh — one command to wire up everything on a fresh machine:
# skills into every harness, then personal harness configs.
#
# Usage: ./setup.sh [--dry-run]   (flag is passed through to both installers)

set -eu
REPO="$(cd "$(dirname "$0")" && pwd)"
"$REPO/install.sh" "$@"
echo
"$REPO/install-configs.sh" "$@"

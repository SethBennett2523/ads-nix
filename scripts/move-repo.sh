#!/usr/bin/env bash
# Points this repository at its new home after it has been forked or moved:
#
#   scripts/move-repo.sh UWE-FSAI/ads-nix
#
# Rewrites every reference to the current address: the default update
# source, the flake that ads-install writes into each machine's /etc/nixos,
# the templates and the docs. Then commit and push, and every machine
# installed from the new address updates from it.
set -euo pipefail
cd "$(dirname "$0")/.."

new=${1:-}
if ! [[ $new =~ ^[A-Za-z0-9-]+/[A-Za-z0-9._-]+$ ]]; then
  echo "usage: scripts/move-repo.sh <owner>/<repo>   (for example UWE-FSAI/ads-nix)"
  exit 1
fi

# The current address is whatever installed machines are told to follow.
old=$(sed -n 's|.*ads-nix.url = "github:\([^"]*\)".*|\1|p' templates/installed/flake.nix)
[ -n "$old" ] || { echo "can't find the current address in templates/installed/flake.nix"; exit 1; }
if [ "$old" = "$new" ]; then
  echo "Already pointing at $new."
  exit 0
fi

mapfile -t files < <(git grep -l -F "$old" -- . ':!flake.lock')
sed -i "s|$old|$new|g" "${files[@]}"

echo "Repointed $old -> $new in:"
printf '  %s\n' "${files[@]}"
if left=$(git grep -n -F "$old" -- . ':!flake.lock'); then
  echo
  echo "Still mentions $old:"
  echo "$left"
  exit 1
fi
echo
echo "Next: scripts/check.sh, then commit and push."

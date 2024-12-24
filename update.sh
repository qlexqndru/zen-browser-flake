#!/usr/bin/env -S nix shell nixpkgs#jq -c bash
set -euo pipefail
regex="^[0-9]\.[0-9]\.[0-9].*$"
info="info.json"
oldversion=$(jq -rc '.version' "$info")
url="https://api.github.com/repos/zen-browser/desktop/releases?per_page=1"
version="$(curl -s "$url" | jq -rc '.[0].tag_name')"

if [ "$oldversion" != "$version" ] && [[ "$version" =~ $regex ]]; then
  echo "Found new version $version"
  sharedUrl="https://github.com/zen-browser/desktop/releases/download"
  x86_64Url="${sharedUrl}/${version}/zen.linux-x86_64.tar.bz2"
  
  echo "Prefetching file..."
  x86_64Hash=$(nix store prefetch-file "$x86_64Url" --log-format raw --json | jq -rc '.hash')
  
  # New simplified JSON structure
  echo '{
    "version": "'"$version"'",
    "url": "'"$x86_64Url"'",
    "hash": "'"$x86_64Hash"'"
  }' | jq -c . >"$info"
else
  echo "zen is up to date"
fi

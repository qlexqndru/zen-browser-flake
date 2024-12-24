#!/usr/bin/env -S nix shell nixpkgs#jq -c bash
set -euo pipefail
regex="^[0-9]\.[0-9]\.[0-9].*$"
info="info.json"
oldversion=$(jq -rc '.version' "$info")
echo "Old version: $oldversion"
url="https://api.github.com/repos/zen-browser/desktop/releases?per_page=1"
version="$(curl -s "$url" | jq -rc '.[0].tag_name')"
echo "New version: $version"

# Check if the condition is being met
echo "Checking versions..."
echo "Version regex check: $([[ "$version" =~ $regex ]] && echo "true" || echo "false")"
echo "Version comparison: $([[ "$oldversion" != "$version" ]] && echo "different" || echo "same")"

if [ "$oldversion" != "$version" ] && [[ "$version" =~ $regex ]]; then
  echo "Found new version $version"
  sharedUrl="https://github.com/zen-browser/desktop/releases/download"
  x86_64Url="${sharedUrl}/${version}/zen.linux-x86_64.tar.bz2"
  
  echo "Prefetching file..."
  x86_64Hash=$(nix store prefetch-file "$x86_64Url" --log-format raw --json | jq -rc '.hash')
  
  echo "Writing new info.json..."
  echo '{
    "version": "'"$version"'",
    "url": "'"$x86_64Url"'",
    "hash": "'"$x86_64Hash"'"
  }' | jq -c . >"$info"
  echo "Done updating info.json"
else
  echo "zen is up to date"
fi

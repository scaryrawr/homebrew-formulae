#!/usr/bin/env bash
# Load brew environment
if [ -f /home/linuxbrew/.linuxbrew/bin/brew ]; then
  eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
fi

tar_url=$(gh api repos/scaryrawr/sl/releases/latest --jq '.tarball_url')
checksum=$(curl -L "${tar_url}" | sha256sum | awk '{print $1}')
file=${GITHUB_WORKSPACE}/Formula/sl.rb

# Check if the checksum is already present in the formula
if grep -q "${checksum}" "${file}"; then
  echo "Checksum already present in ${file}. No update needed."
  exit 0;
fi

# Update the formula
url_line_number=$(grep -n "url " "${file}" | cut -d: -f1)
sed -i '' "${url_line_number}s|url \".*\"|url \"${tar_url}\"|" "${file}"
sed -i '' "s/sha256 \".*\"/sha256 \"${checksum}\"/g" "${file}"

brew install --build-from-source "${file}"
sl -V
sl -h

version="$(gh api repos/scaryrawr/sl/releases/latest --jq .name)"
new_branch="${version}"
git checkout -b "${new_branch}"
git config user.name "github-actions[bot]"
git config user.email "41898282+github-actions[bot]@users.noreply.github.com"
git config push.autoSetupRemote true
git push
gh pr create -B rawhide --title "Update to ${version}" --body 'Created by Github action' -a scaryrawr

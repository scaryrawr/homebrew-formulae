#!/usr/bin/env bash
# Load brew environment
if [ -f /home/linuxbrew/.linuxbrew/bin/brew ]; then
  eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
fi

command -v sha256sum || brew install coreutils

git config user.name "github-actions[bot]"
git config user.email "41898282+github-actions[bot]@users.noreply.github.com"

# Loop over all formula files in the Formula directory
for file in "${GITHUB_WORKSPACE}"/Formula/*.rb; do
  repo_name=$(awk -F'/' '/homepage/ {printf("%s/%s\n", $(NF-1), substr($NF, 1, length($NF) - 1))}' "${file}")
  version=$(gh api "repos/${repo_name}/releases/latest" --jq '.name')
  tar_url="https://github.com/${repo_name}/archive/refs/tags/${version}.tar.gz"
  checksum=$(curl -L "${tar_url}" | sha256sum | cut -d' ' -f1)

  # Check if the checksum is already present in the formula
  if grep -q "${checksum}" "${file}"; then
    echo "Checksum already present in ${file}. No update needed."
    continue
  fi

  # Update the formula
  url_line_number=$(grep -n "url " "${file}" | cut -d: -f1)
  sed -i '' "${url_line_number}s|url \".*\"|url \"${tar_url}\"|" "${file}"
  sed -i '' "s/sha256 \".*\"/sha256 \"${checksum}\"/g" "${file}"

  brew install --build-from-source "${file}"

  new_branch="${repo_name}-${version}"
  git checkout -b "${new_branch}"
  git add -u
  git commit -m "Update ${repo_name} to ${version}"
  git config push.autoSetupRemote true
  git push
  gh pr create --title "Update formulae" --body 'Created by Github action' -a scaryrawr
done

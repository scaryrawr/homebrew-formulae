#!/usr/bin/env sh

for file in ./Formula/*.rb; do
  # grab the url from the formula
  echo "Updating $file"
  url=$(grep 'url' $file | awk -F'"' '{print $2}')
  echo "Grabbing $url"
  checksum=$(curl -sL $url | sha256sum | awk '{print $1}')
  echo "Setting new checksum $checksum"
  sed -i '' "s/sha256 \".*\"/sha256 \"$checksum\"/g" $file
done

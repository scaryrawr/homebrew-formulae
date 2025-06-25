#!/usr/bin/env python3

import requests
import hashlib
import re
import sys

def get_sha256(url):
    """Download file and calculate SHA256 checksum."""
    response = requests.get(url, stream=True)
    response.raise_for_status()
    
    sha256_hash = hashlib.sha256()
    for chunk in response.iter_content(chunk_size=8192):
        sha256_hash.update(chunk)
    
    return sha256_hash.hexdigest()

def get_latest_release(repo):
    """Get the latest release tag from GitHub."""
    url = f"https://api.github.com/repos/{repo}/releases/latest"
    response = requests.get(url)
    response.raise_for_status()
    return response.json()["tag_name"]

def update_sl_formula():
    """Update the sl formula with latest release."""
    repo = "scaryrawr/sl"
    formula_path = "Formula/sl.rb"
    
    try:
        # Get latest release
        latest_tag = get_latest_release(repo)
        
        # Read current formula
        with open(formula_path, 'r') as f:
            content = f.read()
        
        # Extract current version from URL
        url_match = re.search(r'url "https://github\.com/scaryrawr/sl/archive/refs/tags/([^"]+)\.tar\.gz"', content)
        if not url_match:
            print("Could not find URL in sl.rb")
            return False
        
        current_tag = url_match.group(1)
        
        if current_tag == latest_tag:
            print(f"sl is already up to date at {latest_tag}")
            return False
        
        # Calculate new URL and SHA256
        new_url = f"https://github.com/scaryrawr/sl/archive/refs/tags/{latest_tag}.tar.gz"
        new_sha256 = get_sha256(new_url)
        
        # Update formula
        new_content = re.sub(
            r'url "https://github\.com/scaryrawr/sl/archive/refs/tags/[^"]+\.tar\.gz"',
            f'url "{new_url}"',
            content
        )
        new_content = re.sub(
            r'sha256 "[^"]+"',
            f'sha256 "{new_sha256}"',
            new_content
        )
        
        # Write updated formula
        with open(formula_path, 'w') as f:
            f.write(new_content)
        
        print(f"Updated sl from {current_tag} to {latest_tag}")
        return True
        
    except Exception as e:
        print(f"Error updating sl: {e}")
        return False

if __name__ == "__main__":
    update_sl_formula()
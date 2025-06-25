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

def update_zpiral_formula():
    """Update the zpiral formula with latest release."""
    repo = "scaryrawr/zpiral"
    formula_path = "Formula/zpiral.rb"
    
    try:
        # Get latest release
        latest_tag = get_latest_release(repo)
        
        # Read current formula
        with open(formula_path, 'r') as f:
            content = f.read()
        
        # Extract current version from URL
        url_match = re.search(r'url "https://github\.com/scaryrawr/zpiral/archive/refs/tags/([^"]+)\.tar\.gz"', content)
        if not url_match:
            print("Could not find URL in zpiral.rb")
            return False
        
        current_tag = url_match.group(1)
        
        if current_tag == latest_tag:
            print(f"zpiral is already up to date at {latest_tag}")
            return False
        
        # Calculate new URL and SHA256
        new_url = f"https://github.com/scaryrawr/zpiral/archive/refs/tags/{latest_tag}.tar.gz"
        new_sha256 = get_sha256(new_url)
        
        # Update formula
        new_content = re.sub(
            r'url "https://github\.com/scaryrawr/zpiral/archive/refs/tags/[^"]+\.tar\.gz"',
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
        
        print(f"Updated zpiral from {current_tag} to {latest_tag}")
        return True
        
    except Exception as e:
        print(f"Error updating zpiral: {e}")
        return False

if __name__ == "__main__":
    update_zpiral_formula()
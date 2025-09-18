#!/usr/bin/env python3

import subprocess
import hashlib
import re
import tempfile


def get_sha256(url):
    """Download file and calculate SHA256 checksum using curl."""
    with tempfile.NamedTemporaryFile() as temp_file:
        try:
            subprocess.run(["curl", "-sL", url, "-o", temp_file.name], check=True)

            sha256_hash = hashlib.sha256()
            with open(temp_file.name, "rb") as f:
                for chunk in iter(lambda: f.read(8192), b""):
                    sha256_hash.update(chunk)

            return sha256_hash.hexdigest()
        except subprocess.CalledProcessError as e:
            raise Exception(f"Failed to download {url}: {e}")


def get_latest_release(repo):
    """Get the latest release tag from GitHub using gh CLI."""
    try:
        result = subprocess.run(
            ["gh", "api", f"repos/{repo}/releases/latest", "--jq", ".tag_name"],
            capture_output=True,
            text=True,
            check=True,
        )
        return result.stdout.strip()
    except subprocess.CalledProcessError as e:
        raise Exception(f"Failed to get latest release for {repo}: {e}")


def update_magus_formula():
    """Update the magus formula with latest release."""
    repo = "scaryrawr/magus"
    formula_path = "Formula/magus.rb"

    try:
        # Get latest release
        latest_tag = get_latest_release(repo)

        # Read current formula
        with open(formula_path, "r") as f:
            content = f.read()

        # Extract current version
        version_match = re.search(r'version "([^"]+)"', content)
        if not version_match:
            print("Could not find version in magus.rb")
            return False

        current_version = version_match.group(1)
        latest_version = latest_tag.lstrip("r")  # Remove 'r' prefix if present

        if current_version == latest_version:
            print(f"magus is already up to date at {latest_version}")
            return False

        # Define the platform/architecture combinations
        platforms = [
            ("darwin", "x64"),
            ("darwin", "arm64"),
            ("linux", "x64"),
            ("linux", "arm64"),
        ]

        # Update version
        new_content = re.sub(r'version "[^"]+"', f'version "{latest_version}"', content)

        # Update URLs and SHA256 checksums for each platform
        for platform, arch in platforms:
            new_url = f"https://github.com/scaryrawr/magus/releases/download/{latest_tag}/magus-{platform}-{arch}.tar.gz"

            try:
                new_sha256 = get_sha256(new_url)
                print(f"Updated {platform}-{arch}: {new_sha256}")

                # Find and update the URL for this platform/arch
                url_regex = re.compile(
                    rf'(url "https://github\.com/scaryrawr/magus/releases/download/r[^/]+/magus-{re.escape(platform)}-{re.escape(arch)}\.tar\.gz")',
                    re.MULTILINE,
                )
                new_content = url_regex.sub(f'url "{new_url}"', new_content)

                # Find and update the SHA256 that follows this URL
                # Look for the sha256 line after the specific URL
                lines = new_content.split("\n")
                for i, line in enumerate(lines):
                    if f"magus-{platform}-{arch}.tar.gz" in line and "url" in line:
                        # Find the next sha256 line
                        for j in range(i + 1, min(i + 5, len(lines))):
                            if "sha256" in lines[j]:
                                lines[j] = re.sub(
                                    r'sha256 "[^"]+"',
                                    f'sha256 "{new_sha256}"',
                                    lines[j],
                                )
                                break
                        break

                new_content = "\n".join(lines)

            except Exception as e:
                print(f"Warning: Could not download {platform}-{arch} binary: {e}")
                continue

        # Write updated formula
        with open(formula_path, "w") as f:
            f.write(new_content)

        print(f"Updated magus from {current_version} to {latest_version}")
        return True

    except Exception as e:
        print(f"Error updating magus: {e}")
        return False


if __name__ == "__main__":
    update_magus_formula()

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


def update_navigit_formula():
    """Update the navigit formula with latest release."""
    repo = "scaryrawr/navigit"
    formula_path = "Formula/navigit.rb"

    try:
        latest_tag = get_latest_release(repo)

        with open(formula_path, "r") as f:
            content = f.read()

        version_match = re.search(r'version "([^"]+)"', content)
        if not version_match:
            print("Could not find version in navigit.rb")
            return False

        current_version = version_match.group(1)
        latest_version = latest_tag.lstrip("v")

        if current_version == latest_version:
            print(f"navigit is already up to date at {latest_version}")
            return False

        platforms = [
            ("macos", "arm64"),
            ("linux", "x64"),
            ("linux", "arm64"),
        ]

        new_content = re.sub(r'version "[^"]+"', f'version "{latest_version}"', content)

        for platform, arch in platforms:
            asset_name = f"navigit-{latest_tag}-{platform}-{arch}.tar.gz"
            new_url = (
                f"https://github.com/scaryrawr/navigit/releases/download/{latest_tag}/{asset_name}"
            )

            try:
                new_sha256 = get_sha256(new_url)
                print(f"Updated {platform}-{arch}: {new_sha256}")

                url_regex = re.compile(
                    rf'url "https://github\.com/scaryrawr/navigit/releases/download/[^/]+/navigit-[^"]+-{re.escape(platform)}-{re.escape(arch)}\.tar\.gz"',
                    re.MULTILINE,
                )
                new_content = url_regex.sub(f'url "{new_url}"', new_content)

                lines = new_content.split("\n")
                for i, line in enumerate(lines):
                    if asset_name in line and "url" in line:
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

        with open(formula_path, "w") as f:
            f.write(new_content)

        print(f"Updated navigit from {current_version} to {latest_version}")
        return True

    except Exception as e:
        print(f"Error updating navigit: {e}")
        return False


if __name__ == "__main__":
    update_navigit_formula()

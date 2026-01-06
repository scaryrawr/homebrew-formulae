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


def get_latest_commit(repo):
    """Get the latest commit SHA from GitHub main branch using gh CLI."""
    try:
        result = subprocess.run(
            ["gh", "api", f"repos/{repo}/commits/main", "--jq", ".sha"],
            capture_output=True,
            text=True,
            check=True,
        )
        return result.stdout.strip()
    except subprocess.CalledProcessError as e:
        raise Exception(f"Failed to get latest commit for {repo}: {e}")


def get_upstream_version(upstream_repo):
    """Get the latest rust version tag from upstream openai/codex repository."""
    try:
        result = subprocess.run(
            [
                "gh",
                "api",
                f"repos/{upstream_repo}/tags",
                "--jq",
                '.[] | select(.name | test("^rust-v[0-9]")) | .name',
            ],
            capture_output=True,
            text=True,
            check=True,
        )
        tags = result.stdout.strip().split("\n")
        if tags:
            # Return the first tag (latest) without the "rust-v" prefix
            return tags[0].replace("rust-v", "")
        return "0.0.0"
    except subprocess.CalledProcessError as e:
        raise Exception(f"Failed to get upstream version for {upstream_repo}: {e}")


def update_codex_formula():
    """Update the codex formula with latest commit from scaryrawr/codex."""
    repo = "scaryrawr/codex"
    upstream_repo = "openai/codex"
    formula_path = "Formula/codex.rb"

    try:
        # Get latest commit
        latest_commit = get_latest_commit(repo)
        short_commit = latest_commit[:7]

        # Get upstream version for version numbering
        upstream_version = get_upstream_version(upstream_repo)

        # Read current formula
        with open(formula_path, "r") as f:
            content = f.read()

        # Extract current commit from URL
        url_match = re.search(
            r'url "https://github\.com/scaryrawr/codex/archive/([a-f0-9]+)\.tar\.gz"',
            content,
        )
        if not url_match:
            print("Could not find URL in codex.rb")
            return False

        current_commit = url_match.group(1)

        if current_commit == latest_commit:
            print(f"codex is already up to date at commit {short_commit}")
            return False

        # Calculate new URL and SHA256
        new_url = f"https://github.com/scaryrawr/codex/archive/{latest_commit}.tar.gz"
        new_sha256 = get_sha256(new_url)

        # Update formula with new commit, version, and SHA256
        new_content = re.sub(
            r'url "https://github\.com/scaryrawr/codex/archive/[a-f0-9]+\.tar\.gz"',
            f'url "{new_url}"',
            content,
        )
        new_content = re.sub(r'sha256 "[^"]+"', f'sha256 "{new_sha256}"', new_content)
        new_content = re.sub(
            r'version "[^"]+"',
            f'version "{upstream_version}+{short_commit}"',
            new_content,
        )

        # Write updated formula
        with open(formula_path, "w") as f:
            f.write(new_content)

        current_short = current_commit[:7]
        print(
            f"Updated codex from {current_short} to {short_commit} (version {upstream_version}+{short_commit})"
        )
        return True

    except Exception as e:
        print(f"Error updating codex: {e}")
        return False


if __name__ == "__main__":
    update_codex_formula()

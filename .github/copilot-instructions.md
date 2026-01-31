# Homebrew Formulae Repository

## Testing Commands

```bash
# Test syntax for all formulae
brew test-bot --only-tap-syntax

# Build and install a single formula from source
brew install --build-from-source Formula/<formula>.rb

# Test a formula after installation
brew test <formula>

# Run full test suite (used in CI for PRs)
brew test-bot --only-formulae
```

## Architecture

This is a Homebrew tap with automated version updates:

- **Formula/*.rb** - Homebrew formula definitions (Ruby)
- **scripts/update-*.py** - Python scripts that auto-update each formula by fetching latest releases/commits from GitHub

The update workflow runs daily and creates PRs when new versions are detected. Each update script:
1. Fetches latest version info via `gh` CLI
2. Downloads the tarball and calculates SHA256
3. Updates the formula file with new URL, version, and checksum

## Code Style

- Ruby formulae: 2-space indentation, Homebrew Ruby style
- Python scripts: PEP 8, snake_case naming
- Formula class names: TitleCase matching filename (e.g., `codex.rb` → `class Codex`)
- Always include: HTTPS URLs, SHA256 checksums, `license` field, `test do...end` block

## Formula Structure

Formulae follow this pattern:
```ruby
class FormulaName < Formula
  desc "Short description"
  homepage "https://..."
  url "https://.../<version>.tar.gz"
  version "x.y.z"
  sha256 "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855"
  license "..."

  depends_on "..." => :build  # build-time deps
  depends_on "..."            # runtime deps

  def install
    # installation steps
  end

  test do
    # verification command
    system "true"
  end
end
```

## Update Script Pattern

Update scripts use `gh` CLI for GitHub API access and `curl` for downloads:
```python
subprocess.run(["gh", "api", f"repos/{repo}/releases/latest", "--jq", ".tag_name"], ...)
subprocess.run(["curl", "-sL", url, "-o", temp_file.name], check=True)
```

Always use `check=True` with subprocess and handle `CalledProcessError`.

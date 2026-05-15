# Repository Guidelines

## Purpose and layout

This repository is a Homebrew tap for `scaryrawr/formulae`.

- `Formula/*.rb` contains Homebrew formulae for released tools.
- `scripts/update-*.py` contains one updater per formula. Each updater calls the GitHub API with `gh`, downloads release artifacts with `curl`, computes SHA256 checksums, and rewrites the matching formula.
- `.github/workflows/tests.yml` runs tap syntax checks on pushes and pull requests, and full formula builds on pull requests.
- `.github/workflows/update-formulas.yml` runs the updater scripts daily and opens a PR when formula files change.
- `.github/workflows/publish.yml` publishes bottles only when a pull request is labeled `pr-pull`; treat this `pull_request_target` workflow as security-sensitive.

## Formula conventions

- Use Homebrew Ruby style with 2-space indentation and class names that match the filename in TitleCase (`Formula/sl.rb` -> `class Sl`).
- Prefer HTTPS GitHub release or tag URLs with explicit `sha256` values. Keep platform-specific binary URLs inside `on_macos` / `on_linux` blocks that match the published assets.
- New formulae, and formulae touched beyond a pure version bump, should include a `license` entry and a meaningful `test do` block that exercises the installed binary (`--help`, `help`, `-V`, or equivalent) when possible.
- When changing a URL, version, artifact name, or checksum pattern in a formula, update the paired `scripts/update-<name>.py` file so the daily updater keeps working.
- Use build dependencies only where needed (`depends_on "rust" => :build`, `depends_on "zig" => :build`) and preserve service blocks such as `Formula/zpiral.rb` unless the upstream service behavior changed.

## Update script conventions

- Keep updater scripts Python 3 and standard-library first. Do not add dependencies unless the workflow installs them and the benefit is clear.
- Use `subprocess.run(..., check=True)` for `gh` and `curl` calls, capture GitHub API output with `text=True`, and surface failures instead of silently succeeding.
- Derive the latest version from the release tag consistently with the formula (`latest_tag.lstrip("v")` for formulae that use a separate `version` field).
- If an updater supports multiple platform assets, calculate a checksum for each existing platform URL pattern and preserve per-platform warnings without hiding top-level API or file errors.

## Validation commands

- Syntax check all formulae: `brew test-bot --only-tap-syntax`
- Full CI-style formula build/test: `brew test-bot --only-formulae`
- Build one formula from source or artifact: `brew install --build-from-source Formula/<formula>.rb`
- Test one installed formula: `brew test <formula>`
- Check updater script syntax quickly: `python -m py_compile scripts/update-*.py`
- After running an updater, inspect `git diff` to confirm only the intended formula URL/version/checksum changes were made.

Run the narrowest validation that covers the files changed, and call out any skipped Homebrew validation when the local environment cannot run it.

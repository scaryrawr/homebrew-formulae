---
applyTo: "Formula/*.rb"
name: Homebrew formula guidance
description: Formula-specific rules for this tap.
---

Follow the repository-wide guidance in `AGENTS.md` for architecture, validation, and safety.

When editing formulae, keep the paired `scripts/update-<formula>.py` updater synchronized with any URL, artifact-name, version, or checksum pattern changes. Prefer a real `test do` command that exercises the installed binary, and validate formula changes with `brew test-bot --only-tap-syntax` or a narrower install/test command when practical.

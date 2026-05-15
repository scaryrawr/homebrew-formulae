---
name: validate-tap
description: Choose and run the right validation path for changes in this Homebrew tap.
---

# Validate tap changes

Use this skill after editing formulae, update scripts, or workflows in this repository.

## Inputs

- The changed files from `git diff --name-only`.
- Whether Homebrew is available locally.
- Whether the change is a narrow script-only edit, a formula syntax change, or a full formula behavior change.

## Steps

1. Inspect the diff and map changed files to formula names.
2. For `scripts/update-*.py` changes, run `python -m py_compile scripts/update-*.py`.
3. For formula changes, run `brew test-bot --only-tap-syntax`.
4. For one formula behavior change, run `brew install --build-from-source Formula/<formula>.rb` followed by `brew test <formula>` when the local environment supports it.
5. For PR-level confidence, run `brew test-bot --only-formulae`.
6. If an updater was run, inspect `git diff` and confirm only expected URL, version, and checksum fields changed.

## Exit criteria

Report the commands run, whether they passed, and any validation that could not run because Homebrew or required platform support was unavailable.

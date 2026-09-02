---
name: Update omlx Formula
description: Review the latest scaryrawr/omlx source and update its Homebrew formula when needed
on:
  schedule:
    - cron: "0 6 * * 3,5"
  workflow_dispatch:

permissions:
  contents: read
  pull-requests: read
  copilot-requests: write

engine:
  id: copilot
  copilot-sdk: true

strict: true
timeout-minutes: 45

sandbox:
  agent:
    id: awf

network:
  allowed:
    - defaults
    - github
    - python

tools:
  cli-proxy: false
  edit:
  bash:
    - "brew:*"
    - "curl:*"
    - "gh api:*"
    - "git diff:*"
    - "git status:*"
    - "grep:*"
    - "ruby:*"
    - "shasum:*"

safe-outputs:
  create-pull-request:
    title-prefix: "chore: "
    draft: false
    base-branch: main
    max: 1
    max-patch-files: 1
    max-patch-size: 128
    allowed-files:
      - Formula/omlx.rb
    fallback-as-issue: false
    github-token-for-extra-empty-commit: ${{ secrets.GH_AW_CI_TRIGGER_TOKEN }}
  noop:
---

# Update the omlx Homebrew Formula

Keep `Formula/omlx.rb` compatible with the latest commit on the `main` branch
of `scaryrawr/omlx`.

The formula is intentionally HEAD-only and must remain pointed at the
`scaryrawr/omlx` fork. Do not add a stable release URL or switch it to
`jundot/omlx`.

## Review

1. Read `.github/copilot-instructions.md` and `Formula/omlx.rb`.
2. Fetch the latest `scaryrawr/omlx` commit and inspect changes since the
   formula was last updated.
3. Inspect the latest upstream files that affect installation, including:
   - `pyproject.toml`
   - `setup.py`
   - optional engine dependency metadata
   - `omlx/custom_kernels/`
   - the formula shipped in the omlx repository, when present
4. Compare those requirements with the local formula.

Pay particular attention to:

- Exact `mlx`, `mlx-lm`, `mlx-vlm`, `mlx-audio`, and image-engine pins.
- Compatibility bounds between `mlx` and optional engines such as
  `scaryrawr/mflux`.
- Changes to the native custom-kernel list or build requirements.
- Python version requirements.
- Native dependencies that must remain in `PIP_NO_BINARY` for Homebrew
  linkage rewriting.
- Dependency constraints that require adding, changing, or removing an
  `inreplace` patch.

## Update

If the formula needs changes:

1. Modify only `Formula/omlx.rb`.
2. Keep the change as small as possible.
3. For each updated tarball resource, calculate SHA-256 from the downloaded
   archive rather than copying a checksum from another source.
4. Inspect the pinned resource's dependency metadata before retaining or
   adding compatibility patches.
5. Do not relax an optional engine's MLX bound without a clean resolver check
   and a real smoke test for that engine.

Do not remove packages from `PIP_NO_BINARY` unless the relevant Homebrew
linkage behavior has been retested.

## Validation

Run:

```bash
ruby -c Formula/omlx.rb
git diff --check
```

If Homebrew is available, also run:

```bash
brew test-bot --only-tap-syntax
```

Review the final diff and ensure `Formula/omlx.rb` is the only changed file.
Do not create a pull request when validation fails.

## Result

When an update is required and validation passes, use the
`create_pull_request` safe-output tool.

Use a title such as:

```text
chore: update omlx formula for current HEAD
```

The pull request body must summarize:

- The omlx commit reviewed.
- Dependency or build changes reflected in the formula.
- Checksums recalculated.
- Validation performed and any checks that could not run.

If the formula is already current, use the `noop` safe-output tool and state
which omlx commit was reviewed.

---
applyTo: ".github/workflows/*.md,.github/workflows/*.lock.yml,.github/aw/actions-lock.json"
---

# Agentic workflow compilation

- Edit `update-omlx.md`, then regenerate `update-omlx.lock.yml`; do not hand-edit
  the generated workflow.
- Use the released gh-aw compiler version recorded in the existing lock's
  `compiler_version` metadata and `.github/aw/actions-lock.json` (currently
  `v0.87.10`), unless intentionally upgrading the workflow runtime. Check the
  binary's `version` output before running `compile update-omlx --no-check-update`.
  Use a separately downloaded release binary if the installed extension differs.
- Inspect the generated diff: a permissions-only change should retain the
  SHA-pinned setup action, compiler version, and 168-hour failure-issue retention.
  A `dev` version or unpinned `github/gh-aw` checkout indicates compiler drift.
- Validate with the same binary using
  `compile update-omlx --no-emit --no-check-update`, then `git diff --check`.

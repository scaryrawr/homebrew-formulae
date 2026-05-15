---
applyTo: "scripts/update-*.py"
name: Formula updater guidance
description: Python updater rules for automated formula version bumps.
---

Follow the repository-wide guidance in `AGENTS.md` for architecture, validation, and safety.

Keep updater scripts aligned with their matching formula. Use `gh api` for latest release metadata, `curl -sL` for downloads, `hashlib.sha256()` for checksums, and `subprocess.run(..., check=True)` so release/API failures do not look successful. Validate edits with `python -m py_compile scripts/update-*.py`.

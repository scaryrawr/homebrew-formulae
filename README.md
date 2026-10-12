# Scaryrawr Formulae

## How do I install these formulae?

`brew install scaryrawr/formulae/<formula>`

Or `brew tap scaryrawr/formulae` and then `brew install <formula>`.

Or, in a [`brew bundle`](https://github.com/Homebrew/homebrew-bundle) `Brewfile`:

```ruby
tap "scaryrawr/formulae"
brew "<formula>"
```

## Documentation

`brew help`, `man brew` or check [Homebrew's documentation](https://docs.brew.sh).

## Maintenance

The `magus` formula and its automatic updater have been removed because the
upstream repository and release downloads no longer exist.

`zpiral` uses Zig 0.15, matching its source release. Its install test checks the
executable without starting the hardware-dependent multitouch daemon.

PR CI uses Homebrew's formula-change detection and tests stable formulae with
`brew test-bot`. Head-only `omlx` is built and tested separately on Apple Silicon
macOS runners with `--with-audio`, including when a PR also changes stable
formulae. The formula uses Python 3.11 because Misaki, required for audio, does
not support Python 3.13.

To reinstall head-only `omlx`, use `brew reinstall scaryrawr/formulae/omlx`
without `--HEAD`; Homebrew preserves the installed build options. If virtualenv
creation fails before pip runs, verify the Homebrew Python executable works and
repair an incomplete Python installation with `brew reinstall python@3.11`.

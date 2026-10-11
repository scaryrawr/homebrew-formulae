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
macOS runners, including when a PR also changes stable formulae.

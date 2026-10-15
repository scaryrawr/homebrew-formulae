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

`omlx --with-custom-kernel` builds all five native kernel packages using MLX's
`MetalExtension` builder, which generates its own CMake files. It requires Xcode
and a usable Metal compiler; the formula preserves support for an already mounted
Metal toolchain when Xcode's `xcrun` cannot invoke it. Compiler routing is local to
the build and does not change the system toolchain. Missing kernel sources or
packaged Metal libraries are errors, not a reason to silently disable acceleration.

The installer uses pip, not uv. Set `HOMEBREW_PIP_INDEX_URL` to select a package
index for the formula and its isolated builds; `UV_DEFAULT_INDEX` alone does not
configure pip. The selected feed must contain the exact MLX and native ABI
dependencies pinned by the fork.
Alternatively, a scoped `PIP_FIND_LINKS=/absolute/path/to/wheelhouse` can supply
verified, compatible wheels at those exact versions, including to pip's isolated
builds, without changing the index for other dependencies.

Run the install-stage and toolchain regression fixtures with
`python3 -m unittest discover -s tests`. The fixtures do not install a formula or
restart services; on macOS with Metal available they also compile and link a tiny
test library in a temporary directory.

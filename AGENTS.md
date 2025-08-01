# Homebrew Formulae Repository

## Testing Commands
- Test syntax: `brew test-bot --only-tap-syntax`
- Test single formula: `brew install --build-from-source Formula/<formula>.rb`
- Test formula: `brew test <formula>` (after installation)
- Run all tests: `brew test-bot --only-formulae`

## Code Style Guidelines
- Ruby formulae follow Homebrew's Ruby style
- Use 2-space indentation for Ruby files
- Python scripts use PEP 8 style with snake_case naming
- Formula class names are TitleCase matching the filename
- URLs should use HTTPS when available
- Include SHA256 checksums for all downloads
- Use depends_on for build and runtime dependencies
- Include license field for formulae
- Add test do...end blocks to verify installation

## Error Handling
- Use subprocess.run with check=True for Python scripts
- Handle CalledProcessError exceptions in update scripts
- Validate version strings and URLs before updating
- Use tempfile for secure file operations
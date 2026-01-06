class Codex < Formula
  desc "Lightweight coding agent that runs in your terminal"
  homepage "https://github.com/scaryrawr/codex"
  url "https://github.com/scaryrawr/codex/archive/9a9660afadb9cbea1e89e4e0740e632f1d40b440.tar.gz"
  version "0.78.0-alpha.12+9a9660a"
  sha256 "313d6aa416ec713d62244d338ba457965a4cb880863c6b43a642e858a0ab482e"
  license "MIT"

  depends_on "rust" => :build

  def install
    # Extract the version without the commit suffix for Cargo
    cargo_version = version.to_s.split("+").first

    # Build the codex CLI from the codex-rs workspace
    cd "codex-rs" do
      # Update the workspace version in Cargo.toml to match our version
      inreplace "Cargo.toml", /^version = ".*"$/, "version = \"#{cargo_version}\""

      system "cargo", "install", "--locked", "--root", prefix, "--path", "cli"
    end
  end

  test do
    assert_match version.to_s.split("+").first, shell_output("#{bin}/codex --version")
  end
end

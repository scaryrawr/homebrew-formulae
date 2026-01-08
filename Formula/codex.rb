class Codex < Formula
  desc "Lightweight coding agent that runs in your terminal"
  homepage "https://github.com/scaryrawr/codex"
  url "https://github.com/scaryrawr/codex/archive/5e7241b9de604cc6f4a46c08f93ad1592c2e3fcb.tar.gz"
  version "0.80.0-alpha.3+5e7241b"
  sha256 "a875a547882722faeca64c74e438eb0de38fcf50fc4dbbfdb9f13da69c9fc5e9"
  license "MIT"

  depends_on "rust" => :build
  depends_on "openssl@3"

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

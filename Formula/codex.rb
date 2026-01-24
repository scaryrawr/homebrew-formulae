class Codex < Formula
  desc "Lightweight coding agent that runs in your terminal"
  homepage "https://github.com/scaryrawr/codex"
  url "https://github.com/scaryrawr/codex/archive/bd69259cf0b5e347645b4063f567b15e1cccfc54.tar.gz"
  version "0.90.0-alpha.2+bd69259"
  sha256 "0a7ce00c3727ed108cbff971329e2477d94105b99dfe5c48a70ad6d495c88546"
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

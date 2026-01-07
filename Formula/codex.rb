class Codex < Formula
  desc "Lightweight coding agent that runs in your terminal"
  homepage "https://github.com/scaryrawr/codex"
  url "https://github.com/scaryrawr/codex/archive/053f368164d0682d75ec7b0c5d2a20d203e4a56d.tar.gz"
  version "0.80.0-alpha.1+053f368"
  sha256 "29cdb834cb2340ef6f0140f71fed4c84881d25368ab24e5a3f34b793f5b5e89d"
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

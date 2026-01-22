class Codex < Formula
  desc "Lightweight coding agent that runs in your terminal"
  homepage "https://github.com/scaryrawr/codex"
  url "https://github.com/scaryrawr/codex/archive/e41b1aa1c54b58de4093176258d7d4551c7c025a.tar.gz"
  version "0.89.0-alpha.2+e41b1aa"
  sha256 "5fe8bcc699835b76dd0877c2772301c55fae38386f7836301338ee5c931c773e"
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

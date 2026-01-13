class Codex < Formula
  desc "Lightweight coding agent that runs in your terminal"
  homepage "https://github.com/scaryrawr/codex"
  url "https://github.com/scaryrawr/codex/archive/74bb26f92f6c1bbe49bc025860bd4b2a04dd7ed2.tar.gz"
  version "0.81.0-alpha.3+74bb26f"
  sha256 "b0ed417f241e6ba54a51d8af1097706461f5f7eb752ce96746057e854fd79a7a"
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

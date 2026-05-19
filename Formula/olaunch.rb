class Olaunch < Formula
  desc "Open launcher for local/open model coding agents"
  homepage "https://github.com/scaryrawr/olaunch"
  url "https://github.com/scaryrawr/olaunch/releases/download/v0.0.1/olaunch-v0.0.1-aarch64-apple-darwin.tar.gz"
  version "0.0.1"
  sha256 "1ddd1366a0f0b2e18ffe5a4465190e154472e6962e0dab098996a47b051dd9fb"
  # Upstream v0.0.1 does not publish license metadata.
  license :cannot_represent

  on_macos do
    # Upstream v0.0.1 does not publish an Intel macOS artifact.
    depends_on arch: :arm64
  end

  on_linux do
    if Hardware::CPU.intel? && Hardware::CPU.is_64_bit?
      url "https://github.com/scaryrawr/olaunch/releases/download/v0.0.1/olaunch-v0.0.1-x86_64-unknown-linux-gnu.tar.gz"
      sha256 "5db18842fa5d3e3fa4933ef49910d6a9444b3fc0698f79b7f5d173d398ccb4f2"
    end
    if Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
      url "https://github.com/scaryrawr/olaunch/releases/download/v0.0.1/olaunch-v0.0.1-aarch64-unknown-linux-gnu.tar.gz"
      sha256 "338e1214987855e054592f4f8375a88b8f925e2319845ef1b86fba69c7f18dfb"
    end
  end

  def install
    bin.install "olaunch"
  end

  test do
    output = shell_output("#{bin}/olaunch list integrations", 0)
    assert_match "copilot - GitHub's AI coding agent", output
    assert_match "codex - OpenAI's open-source coding agent", output
  end
end

class Olaunch < Formula
  desc "Open launcher for local/open model coding agents"
  homepage "https://github.com/scaryrawr/olaunch"
  url "https://github.com/scaryrawr/olaunch/releases/download/v0.1.3/olaunch-v0.1.3-aarch64-apple-darwin.tar.gz"
  sha256 "5bbf93339f6c53e7f2d6739fc4382b770200c2d994885ad678e08976bb9978c2"
  # Upstream does not publish license metadata.
  license :cannot_represent

  on_macos do
    # Upstream v0.0.1 does not publish an Intel macOS artifact.
    depends_on arch: :arm64
  end

  on_linux do
    if Hardware::CPU.intel? && Hardware::CPU.is_64_bit?
      url "https://github.com/scaryrawr/olaunch/releases/download/v0.1.3/olaunch-v0.1.3-x86_64-unknown-linux-gnu.tar.gz"
      sha256 "31be5e82f74eee00eb7050e0214e6775d416afaaeef054ed7778159fbd79fa1a"
    end
    if Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
      url "https://github.com/scaryrawr/olaunch/releases/download/v0.1.3/olaunch-v0.1.3-aarch64-unknown-linux-gnu.tar.gz"
      sha256 "806dae8c33245d6e2c49fd72aa05cd2d22a0167ab1c5e46ff1b400add58da0bc"
    end
  end

  def install
    bin.install "olaunch"
  end

  test do
    output = shell_output("#{bin}/olaunch list integrations")
    assert_match "copilot - GitHub's AI coding agent", output
    assert_match "hermes - Self-improving AI agent", output
  end
end

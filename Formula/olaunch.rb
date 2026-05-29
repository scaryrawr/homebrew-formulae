class Olaunch < Formula
  desc "Open launcher for local/open model coding agents"
  homepage "https://github.com/scaryrawr/olaunch"
  url "https://github.com/scaryrawr/olaunch/releases/download/v0.1.2/olaunch-v0.1.2-aarch64-apple-darwin.tar.gz"
  sha256 "153d7005c3eac55835c0f5c74c546b6a0b1224229cc524daee03b0d4a9080c38"
  # Upstream does not publish license metadata.
  license :cannot_represent

  on_macos do
    # Upstream v0.0.1 does not publish an Intel macOS artifact.
    depends_on arch: :arm64
  end

  on_linux do
    if Hardware::CPU.intel? && Hardware::CPU.is_64_bit?
      url "https://github.com/scaryrawr/olaunch/releases/download/v0.1.2/olaunch-v0.1.2-x86_64-unknown-linux-gnu.tar.gz"
      sha256 "bf75d669f42da95ab308dfcbb545e42d80154eae401e616d3339438e84d82e94"
    end
    if Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
      url "https://github.com/scaryrawr/olaunch/releases/download/v0.1.2/olaunch-v0.1.2-aarch64-unknown-linux-gnu.tar.gz"
      sha256 "32ff37dcbbaef0720c2c0297b22d18f879b57bb9d1ad2f4913dac76bfbd93d67"
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

class Olaunch < Formula
  desc "Open launcher for local/open model coding agents"
  homepage "https://github.com/scaryrawr/olaunch"
  url "https://github.com/scaryrawr/olaunch/releases/download/v0.1.1/olaunch-v0.1.1-aarch64-apple-darwin.tar.gz"
  sha256 "de2ecbb476d05512107e66deb71accc460785fe69de01e09774b69426995abf9"
  # Upstream does not publish license metadata.
  license :cannot_represent

  on_macos do
    # Upstream v0.0.1 does not publish an Intel macOS artifact.
    depends_on arch: :arm64
  end

  on_linux do
    if Hardware::CPU.intel? && Hardware::CPU.is_64_bit?
      url "https://github.com/scaryrawr/olaunch/releases/download/v0.1.1/olaunch-v0.1.1-x86_64-unknown-linux-gnu.tar.gz"
      sha256 "0cf8c7dff18c70d9077bd49c585b3b8bff202bdb191fae7ecc1ff729269554a0"
    end
    if Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
      url "https://github.com/scaryrawr/olaunch/releases/download/v0.1.1/olaunch-v0.1.1-aarch64-unknown-linux-gnu.tar.gz"
      sha256 "f9763f5065aab6a40c98704335452ccdd55749a115d497ad1804d7ebb257a415"
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

class Opencode < Formula
  desc "AI coding agent built for the terminal"
  homepage "https://github.com/scaryrawr/opencode"
  version "0.3.20-1"

  on_macos do
    if Hardware::CPU.intel?
      url "https://github.com/scaryrawr/opencode/releases/download/r0.3.20-1/opencode-darwin-x64.tar.gz"
      sha256 "d68da9d853ea8d68575d29a411618f8e974bc69668f136281b0c2f9c76bdd0ed"
    end
    if Hardware::CPU.arm?
      url "https://github.com/scaryrawr/opencode/releases/download/r0.3.20-1/opencode-darwin-arm64.tar.gz"
      sha256 "1175d2ddb5a831f3a24846aae2d81fb0d0601d28f8db5b04264cb151c9eb5489"
    end
  end

  on_linux do
    if Hardware::CPU.intel? && Hardware::CPU.is_64_bit?
      url "https://github.com/scaryrawr/opencode/releases/download/r0.3.20-1/opencode-linux-x64.tar.gz"
      sha256 "f9001667f173da48cc0e95f568f1b1d3bc1db9496f9ce8164bb39eae245bf2b1"
    end
    if Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
      url "https://github.com/scaryrawr/opencode/releases/download/r0.3.20-1/opencode-linux-arm64.tar.gz"
      sha256 "f0573b1fbed1bf05986ec8e305225700073fc9228e510df8f2e97bf91ccc8693"
    end
  end

  def install
    bin.install "bin/opencode"
  end
end

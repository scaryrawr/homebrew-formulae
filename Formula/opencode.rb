class Opencode < Formula
  desc "AI coding agent built for the terminal"
  homepage "https://github.com/scaryrawr/opencode"
  version "0.3.79"

  on_macos do
    if Hardware::CPU.intel?
      url "https://github.com/scaryrawr/opencode/releases/download/r0.3.79/opencode-darwin-x64.tar.gz"
      sha256 "2dd11bfe7befafad7c3ce4ad92b67c56f1870276ac7069b6d791d5186ee127f4"
    end
    if Hardware::CPU.arm?
      url "https://github.com/scaryrawr/opencode/releases/download/r0.3.79/opencode-darwin-arm64.tar.gz"
      sha256 "96cbefa207f1f25c609c347879b5b372593072cf6dde464be58012485ad6a546"
    end
  end

  on_linux do
    if Hardware::CPU.intel? && Hardware::CPU.is_64_bit?
      url "https://github.com/scaryrawr/opencode/releases/download/r0.3.79/opencode-linux-x64.tar.gz"
      sha256 "d9f038b5922170dcb380edc7ceeec494911032120dde3b277d60d83e82ec1061"
    end
    if Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
      url "https://github.com/scaryrawr/opencode/releases/download/r0.3.79/opencode-linux-arm64.tar.gz"
      sha256 "e18b05625dc4f16066064ad23c677b2dddc2296048c62b3d6b5952b3b062feae"
    end
  end

  def install
    bin.install "bin/opencode"
  end
end

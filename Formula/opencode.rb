class Opencode < Formula
  desc "AI coding agent built for the terminal"
  homepage "https://github.com/scaryrawr/opencode"
  version "0.2.27"

  on_macos do
    if Hardware::CPU.intel?
      url "https://github.com/scaryrawr/opencode/releases/download/r0.2.27/opencode-darwin-x64.tar.gz"
      sha256 "fc540d0947d1f2f1daf5d22c68a22f9a19865c39dd79d4bb5238878039c1a5ff"
    end
    if Hardware::CPU.arm?
      url "https://github.com/scaryrawr/opencode/releases/download/r0.2.27/opencode-darwin-arm64.tar.gz"
      sha256 "5416ca09d4e7abc61f944343c72e4aa510ec94806d7a7999a8956b67092149b8"
    end
  end

  on_linux do
    if Hardware::CPU.intel? && Hardware::CPU.is_64_bit?
      url "https://github.com/scaryrawr/opencode/releases/download/r0.2.27/opencode-linux-x64.tar.gz"
      sha256 "17f0b5986f2428a8c8c541f5595ee5d7ada3acdcad57de6fb454735145c031a9"
    end
    if Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
      url "https://github.com/scaryrawr/opencode/releases/download/r0.2.27/opencode-linux-arm64.tar.gz"
      sha256 "6bc60b0bad58373c74f763757dc1592300e60a35f40d667652853b1ae566964d"
    end
  end

  def install
    bin.install "bin/opencode"
  end
end

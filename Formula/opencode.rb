class Opencode < Formula
  desc "AI coding agent built for the terminal"
  homepage "https://github.com/scaryrawr/opencode"
  version "0.2.33-1"

  on_macos do
    if Hardware::CPU.intel?
      url "https://github.com/scaryrawr/opencode/releases/download/r0.2.33-1/opencode-darwin-x64.tar.gz"
      sha256 "6a495ebb9fd6b989eaeeb6c638472ae85a03d396a6b853dbc44d2e414cab1e98"
    end
    if Hardware::CPU.arm?
      url "https://github.com/scaryrawr/opencode/releases/download/r0.2.33-1/opencode-darwin-arm64.tar.gz"
      sha256 "7b141825ce47c97681118406799b6a5738697186e3826720273d3441452ba099"
    end
  end

  on_linux do
    if Hardware::CPU.intel? && Hardware::CPU.is_64_bit?
      url "https://github.com/scaryrawr/opencode/releases/download/r0.2.33-1/opencode-linux-x64.tar.gz"
      sha256 "54f495dd20ccadbb529e9b8e96e5beefb48afaaa4e88f0247f74d586a5f54c04"
    end
    if Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
      url "https://github.com/scaryrawr/opencode/releases/download/r0.2.33-1/opencode-linux-arm64.tar.gz"
      sha256 "d065b21f53f0e48a2a70c453e26aa2049beae5c6103abf9b107e65aa4a27d281"
    end
  end

  def install
    bin.install "bin/opencode"
  end
end

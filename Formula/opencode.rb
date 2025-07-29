class Opencode < Formula
  desc "AI coding agent built for the terminal"
  homepage "https://github.com/scaryrawr/opencode"
  version "0.3.80"

  on_macos do
    if Hardware::CPU.intel?
      url "https://github.com/scaryrawr/opencode/releases/download/r0.3.80/opencode-darwin-x64.tar.gz"
      sha256 "eb6bc3ff8c7393e414c90c13e818c55cc7dc4e900189c9917a1b9e6a2f887689"
    end
    if Hardware::CPU.arm?
      url "https://github.com/scaryrawr/opencode/releases/download/r0.3.80/opencode-darwin-arm64.tar.gz"
      sha256 "1006dcecd6a46424ff64deb920d0502d06e8544120674a74266e86d6da41dcab"
    end
  end

  on_linux do
    if Hardware::CPU.intel? && Hardware::CPU.is_64_bit?
      url "https://github.com/scaryrawr/opencode/releases/download/r0.3.80/opencode-linux-x64.tar.gz"
      sha256 "4350cfaf29ec60cd1fc4deda2c0b8a211d9c2d89f0c2ce896fe81c395863d8db"
    end
    if Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
      url "https://github.com/scaryrawr/opencode/releases/download/r0.3.80/opencode-linux-arm64.tar.gz"
      sha256 "75567aaceff6442e0dfe19bfb343ccc6105519d00c08bc0cfa3b6ad67d4faca6"
    end
  end

  def install
    bin.install "bin/opencode"
  end
end

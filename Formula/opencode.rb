class Opencode < Formula
  desc "AI coding agent built for the terminal"
  homepage "https://github.com/scaryrawr/opencode"
  version "0.3.83-1"

  on_macos do
    if Hardware::CPU.intel?
      url "https://github.com/scaryrawr/opencode/releases/download/r0.3.83-1/opencode-darwin-x64.tar.gz"
      sha256 "8a67d27b34a721f708ecf483dba14c7b962194ccbcd5851bae3c90642c2427b0"
    end
    if Hardware::CPU.arm?
      url "https://github.com/scaryrawr/opencode/releases/download/r0.3.83-1/opencode-darwin-arm64.tar.gz"
      sha256 "134ce9454993dbd3990c3471653b9959822425d0c6494b46fcfca284be5f86e3"
    end
  end

  on_linux do
    if Hardware::CPU.intel? && Hardware::CPU.is_64_bit?
      url "https://github.com/scaryrawr/opencode/releases/download/r0.3.83-1/opencode-linux-x64.tar.gz"
      sha256 "9abefd2d251fabf0c70d768739221deea6128ea72bc2d299409c3e203f4561c8"
    end
    if Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
      url "https://github.com/scaryrawr/opencode/releases/download/r0.3.83-1/opencode-linux-arm64.tar.gz"
      sha256 "06454a51df05f5df0d4c6c920fbc1b60e904b6353cd2c4d1684e64be3f0eb6dd"
    end
  end

  def install
    bin.install "bin/opencode"
  end
end

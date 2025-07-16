class Opencode < Formula
  desc "AI coding agent built for the terminal"
  homepage "https://github.com/scaryrawr/opencode"
  version "0.3.17"

  on_macos do
    if Hardware::CPU.intel?
      url "https://github.com/scaryrawr/opencode/releases/download/r0.3.17/opencode-darwin-x64.tar.gz"
      sha256 "3157ed1a0c50d8a04b8526fa6e08cd0131163cf89e2d10deb2ff8657b01819b4"
    end
    if Hardware::CPU.arm?
      url "https://github.com/scaryrawr/opencode/releases/download/r0.3.17/opencode-darwin-arm64.tar.gz"
      sha256 "659523f603dcf79b092b54a9ba811cea15b4aa8bb36da4947dc6fac180bfe903"
    end
  end

  on_linux do
    if Hardware::CPU.intel? && Hardware::CPU.is_64_bit?
      url "https://github.com/scaryrawr/opencode/releases/download/r0.3.17/opencode-linux-x64.tar.gz"
      sha256 "65225c6afcceeacca8c6fda0069a90282168fd0735b8389e10a65f5c391cfe13"
    end
    if Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
      url "https://github.com/scaryrawr/opencode/releases/download/r0.3.17/opencode-linux-arm64.tar.gz"
      sha256 "0558849a318550196f25088423497f71bf78492d7dd6a6867b9cbd0c49dd6955"
    end
  end

  def install
    bin.install "bin/opencode"
  end
end

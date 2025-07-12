class Opencode < Formula
  desc "AI coding agent built for the terminal"
  homepage "https://github.com/scaryrawr/opencode"
  version "0.2.30"

  on_macos do
    if Hardware::CPU.intel?
      url "https://github.com/scaryrawr/opencode/releases/download/r0.2.30/opencode-darwin-x64.tar.gz"
      sha256 "0ef50ecff00fe378272c5b8149a0136392f00d5d46ed86e0d72f77288d890eed"
    end
    if Hardware::CPU.arm?
      url "https://github.com/scaryrawr/opencode/releases/download/r0.2.30/opencode-darwin-arm64.tar.gz"
      sha256 "407887de9ddc059fe72ae43038eeafd8feca86345925eeaac3f79cb835def4a0"
    end
  end

  on_linux do
    if Hardware::CPU.intel? && Hardware::CPU.is_64_bit?
      url "https://github.com/scaryrawr/opencode/releases/download/r0.2.30/opencode-linux-x64.tar.gz"
      sha256 "50e2365cecae7857ccf0763e66107677bad4be3270112d172d3791590cff033d"
    end
    if Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
      url "https://github.com/scaryrawr/opencode/releases/download/r0.2.30/opencode-linux-arm64.tar.gz"
      sha256 "1277ff190d3982b3ede032f74c88ee66c200e729061b21d4b013df30fbce75f1"
    end
  end

  def install
    bin.install "bin/opencode"
  end
end

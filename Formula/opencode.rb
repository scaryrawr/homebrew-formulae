class Opencode < Formula
  desc "AI coding agent built for the terminal"
  homepage "https://github.com/scaryrawr/opencode"
  version "0.2.27-2"

  on_macos do
    if Hardware::CPU.intel?
      url "https://github.com/scaryrawr/opencode/releases/download/r0.2.27-2/opencode-darwin-x64.tar.gz"
      sha256 "f20210ba0dce4018970811317a43364b02192ed7c0aa245e0e1b9524a3483df8"
    end
    if Hardware::CPU.arm?
      url "https://github.com/scaryrawr/opencode/releases/download/r0.2.27-2/opencode-darwin-arm64.tar.gz"
      sha256 "44089dc2c95c96d2e65186daa154d544b99cac0872e7e08d40f9526b50e6ebdc"
    end
  end

  on_linux do
    if Hardware::CPU.intel? && Hardware::CPU.is_64_bit?
      url "https://github.com/scaryrawr/opencode/releases/download/r0.2.27-2/opencode-linux-x64.tar.gz"
      sha256 "4647500c996820dc8a30fbf6ffd3027f3bf83f2971cfaefef86fda59298efd05"
    end
    if Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
      url "https://github.com/scaryrawr/opencode/releases/download/r0.2.27-2/opencode-linux-arm64.tar.gz"
      sha256 "12d206e60c8519e3ba9ecdc0fbc228809bcbc6ccfcc6ddcf659dc0ec0da6a3c5"
    end
  end

  def install
    bin.install "bin/opencode"
  end
end

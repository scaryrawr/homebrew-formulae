class Opencode < Formula
  desc "AI coding agent built for the terminal"
  homepage "https://github.com/scaryrawr/opencode"
  version "0.3.43-1"

  on_macos do
    if Hardware::CPU.intel?
      url "https://github.com/scaryrawr/opencode/releases/download/r0.3.43-1/opencode-darwin-x64.tar.gz"
      sha256 "22c5893e6b093286cb160763596f44e9a884f84dcbcc2b7260f98ee01e9484f2"
    end
    if Hardware::CPU.arm?
      url "https://github.com/scaryrawr/opencode/releases/download/r0.3.43-1/opencode-darwin-arm64.tar.gz"
      sha256 "91bd22c392d8dc32aa0a2f9a184b16c76a5c3d0177a3f0d13150c0b4fd3983ed"
    end
  end

  on_linux do
    if Hardware::CPU.intel? && Hardware::CPU.is_64_bit?
      url "https://github.com/scaryrawr/opencode/releases/download/r0.3.43-1/opencode-linux-x64.tar.gz"
      sha256 "c0d82d5018a17d0fd6aeb7407615ee06141f0dca92a53c9b7c9cc73c7ddc775e"
    end
    if Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
      url "https://github.com/scaryrawr/opencode/releases/download/r0.3.43-1/opencode-linux-arm64.tar.gz"
      sha256 "5fa88c06da8d229e0c403b48b917d43394d29455ec6dfc0a43e2891ec27449f6"
    end
  end

  def install
    bin.install "bin/opencode"
  end
end

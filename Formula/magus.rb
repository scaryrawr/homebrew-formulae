class Magus < Formula
  desc "AI coding agent built for the terminal"
  homepage "https://github.com/scaryrawr/magus"
  version "v0.0.1"

  on_macos do
    if Hardware::CPU.intel?
      url "https://github.com/scaryrawr/magus/releases/download/v0.0.1/magus-darwin-x64.tar.gz"
      sha256 "e8fa14a5e8ac7f36e480187094e7389b55229b8a27a93c0aaaccc6d98a616a58"
    end
    if Hardware::CPU.arm?
      url "https://github.com/scaryrawr/magus/releases/download/v0.0.1/magus-darwin-arm64.tar.gz"
      sha256 "90ad4984f30821cb6d23be316dd5402a55c48cb413109887ffae481cd0287a6a"
    end
  end

  on_linux do
    if Hardware::CPU.intel? && Hardware::CPU.is_64_bit?
      url "https://github.com/scaryrawr/magus/releases/download/v0.0.1/magus-linux-x64.tar.gz"
      sha256 "65e1e371bb39d596f0a5ac7abd2e91d870902671efde4342a77a9ee1eae5a68e"
    end
    if Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
      url "https://github.com/scaryrawr/magus/releases/download/v0.0.1/magus-linux-arm64.tar.gz"
      sha256 "31de8d30a40fe3683d3b8cfd6bb27185379ee16d2716bb14015fe60f0c0fae7a"
    end
  end

  def install
    bin.install "bin/magus"
  end
end

class Magus < Formula
  desc "AI coding agent built for the terminal"
  homepage "https://github.com/scaryrawr/magus"
  version "0.0.4"

  on_macos do
    if Hardware::CPU.intel?
      url "https://github.com/scaryrawr/magus/releases/download/v0.0.1/magus-darwin-x64.tar.gz"
      sha256 "23f15dd97d01e20367b15a62c6c08a4bc0e0c7213bb6af7a9c59f5c17c3fcfca"
    end
    if Hardware::CPU.arm?
      url "https://github.com/scaryrawr/magus/releases/download/v0.0.1/magus-darwin-arm64.tar.gz"
      sha256 "db9e42e0eb913ff386a32c9de68514c4bf66e96360732ae4551c94f56e332fba"
    end
  end

  on_linux do
    if Hardware::CPU.intel? && Hardware::CPU.is_64_bit?
      url "https://github.com/scaryrawr/magus/releases/download/v0.0.1/magus-linux-x64.tar.gz"
      sha256 "2c06a2806b2a44f3da6a9b52559edbd3b1f800fe87204241bb19e5e1abcfc979"
    end
    if Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
      url "https://github.com/scaryrawr/magus/releases/download/v0.0.1/magus-linux-arm64.tar.gz"
      sha256 "eb055f299e1f052f03a3f7c21affd78824f31d3aa7a47cffa843eced161d972e"
    end
  end

  def install
    bin.install "bin/magus"
  end
end

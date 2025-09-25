class Magus < Formula
  desc "AI coding agent built for the terminal"
  homepage "https://github.com/scaryrawr/magus"
  version "0.0.5"

  on_macos do
    if Hardware::CPU.intel?
      url "https://github.com/scaryrawr/magus/releases/download/v0.0.1/magus-darwin-x64.tar.gz"
      sha256 "6f5cd80b1054fa729a5bb2bca859138ca6e454855685624b30ebffb9e0e24b54"
    end
    if Hardware::CPU.arm?
      url "https://github.com/scaryrawr/magus/releases/download/v0.0.1/magus-darwin-arm64.tar.gz"
      sha256 "1760a963c692150de76c27eae4a7a42bae1b4d4892cda126893392bf4fabca9a"
    end
  end

  on_linux do
    if Hardware::CPU.intel? && Hardware::CPU.is_64_bit?
      url "https://github.com/scaryrawr/magus/releases/download/v0.0.1/magus-linux-x64.tar.gz"
      sha256 "0ea48b5c68f2550598bd89c114ee9ca1abe6d87093751637c7c04145bf3223a0"
    end
    if Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
      url "https://github.com/scaryrawr/magus/releases/download/v0.0.1/magus-linux-arm64.tar.gz"
      sha256 "7f7e6fa66d7a052e7bd6cb52c73d1b6fb466bb1db5efab0477896dae7aad7f10"
    end
  end

  def install
    bin.install "bin/magus"
  end
end

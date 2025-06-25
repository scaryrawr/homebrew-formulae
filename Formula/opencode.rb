class Opencode < Formula
  desc "AI coding agent built for the terminal"
  homepage "https://github.com/scaryrawr/opencode"
  version "0.1.135"

  on_macos do
    if Hardware::CPU.intel?
      url "https://github.com/scaryrawr/opencode/releases/download/r0.1.135/opencode-darwin-x64.tar.gz"
      sha256 "b3c1d8b782e58b270f9810c6c4b816db6a2d441b9f7f6310fc9d85048fb80cc3"
    end
    if Hardware::CPU.arm?
      url "https://github.com/scaryrawr/opencode/releases/download/r0.1.135/opencode-darwin-arm64.tar.gz"
      sha256 "ed98e1a3a8846a1b528070cfb83b680bb5095c05ba0bafaa013b498c236edd84"
    end
  end

  on_linux do
    if Hardware::CPU.intel? && Hardware::CPU.is_64_bit?
      url "https://github.com/scaryrawr/opencode/releases/download/r0.1.135/opencode-linux-x64.tar.gz"
      sha256 "9f93ae2f4da2166213352a6091f449e25b1cc53c5695ae49301c90d98dfd407c"
    end
    if Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
      url "https://github.com/scaryrawr/opencode/releases/download/r0.1.135/opencode-linux-arm64.tar.gz"
      sha256 "8dc66eb587d3bce74d604fd7f8aa672d109fca831ddbf16176343f7dd378bfa8"
    end
  end

  def install
    bin.install "bin/opencode"
  end
end

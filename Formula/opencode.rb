class Opencode < Formula
  desc "AI coding agent built for the terminal"
  homepage "https://github.com/scaryrawr/opencode"
  version "0.3.55"

  on_macos do
    if Hardware::CPU.intel?
      url "https://github.com/scaryrawr/opencode/releases/download/r0.3.55/opencode-darwin-x64.tar.gz"
      sha256 "8d53bb826502827577bbfd0c6e40dc83574c569b5e4f9d9c7a93aed6a807325b"
    end
    if Hardware::CPU.arm?
      url "https://github.com/scaryrawr/opencode/releases/download/r0.3.55/opencode-darwin-arm64.tar.gz"
      sha256 "29409c945f0ed75b412f6148bb8deb587abb31e5b8ff97fc10af91d45fe31c76"
    end
  end

  on_linux do
    if Hardware::CPU.intel? && Hardware::CPU.is_64_bit?
      url "https://github.com/scaryrawr/opencode/releases/download/r0.3.55/opencode-linux-x64.tar.gz"
      sha256 "c9b097ead99f12db682a7960fd176dbf27a27f59dd531d589416e5048d0fb0b0"
    end
    if Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
      url "https://github.com/scaryrawr/opencode/releases/download/r0.3.55/opencode-linux-arm64.tar.gz"
      sha256 "971a77d9148d5408fdb47c285d27f5229ff27c6eaf08de6e6f4146e5d7c86fae"
    end
  end

  def install
    bin.install "bin/opencode"
  end
end

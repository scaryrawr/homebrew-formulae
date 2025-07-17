class Opencode < Formula
  desc "AI coding agent built for the terminal"
  homepage "https://github.com/scaryrawr/opencode"
  version "0.3.17-1"

  on_macos do
    if Hardware::CPU.intel?
      url "https://github.com/scaryrawr/opencode/releases/download/r0.3.17-1/opencode-darwin-x64.tar.gz"
      sha256 "c62e4bcec82ee5560691a7d3912515a015f5051c34a384d4f7b5ed699565a940"
    end
    if Hardware::CPU.arm?
      url "https://github.com/scaryrawr/opencode/releases/download/r0.3.17-1/opencode-darwin-arm64.tar.gz"
      sha256 "e2c43eaaa074a1a11c3e3cdff54f8559d802b2fcb7f4cacd797247497147d269"
    end
  end

  on_linux do
    if Hardware::CPU.intel? && Hardware::CPU.is_64_bit?
      url "https://github.com/scaryrawr/opencode/releases/download/r0.3.17-1/opencode-linux-x64.tar.gz"
      sha256 "d42265d804458b68863a3350778930392143823e0e482059948654be76f7147d"
    end
    if Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
      url "https://github.com/scaryrawr/opencode/releases/download/r0.3.17-1/opencode-linux-arm64.tar.gz"
      sha256 "144e9f89c0bceeca9d30700bc5fd05aa17d2b61a41efe951bf5ebd709d8d05a2"
    end
  end

  def install
    bin.install "bin/opencode"
  end
end

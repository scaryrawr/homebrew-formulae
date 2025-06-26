class Opencode < Formula
  desc "AI coding agent built for the terminal"
  homepage "https://github.com/scaryrawr/opencode"
  version "0.1.144"

  on_macos do
    if Hardware::CPU.intel?
      url "https://github.com/scaryrawr/opencode/releases/download/r0.1.144/opencode-darwin-x64.tar.gz"
      sha256 "445a99ab425b66150bc626e5959f515f3c8224f530e2fb16950b2858026d0e28"
    end
    if Hardware::CPU.arm?
      url "https://github.com/scaryrawr/opencode/releases/download/r0.1.144/opencode-darwin-arm64.tar.gz"
      sha256 "dfedf6efc6bb7e5a393c331eb56ce5f8b542c406886d7147bb6aaeda9f92d5ea"
    end
  end

  on_linux do
    if Hardware::CPU.intel? && Hardware::CPU.is_64_bit?
      url "https://github.com/scaryrawr/opencode/releases/download/r0.1.144/opencode-linux-x64.tar.gz"
      sha256 "e357cc9d79eda1be35676a02556eba05c825999c1f4154b82f81b1f4096b3adc"
    end
    if Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
      url "https://github.com/scaryrawr/opencode/releases/download/r0.1.144/opencode-linux-arm64.tar.gz"
      sha256 "772404248f1bf83d0d81d9245643c677cc9189da19b24bd05e5613ad1d5a2605"
    end
  end

  def install
    bin.install "bin/opencode"
  end
end

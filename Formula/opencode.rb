class Opencode < Formula
  desc "AI coding agent built for the terminal"
  homepage "https://github.com/scaryrawr/opencode"
  version "0.3.5"

  on_macos do
    if Hardware::CPU.intel?
      url "https://github.com/scaryrawr/opencode/releases/download/r0.3.5/opencode-darwin-x64.tar.gz"
      sha256 "e5cb9f1221f1a4d30e81cc4e4aff9f75d7efeaf3c0bd518b7f48e87b7e9f6e1c"
    end
    if Hardware::CPU.arm?
      url "https://github.com/scaryrawr/opencode/releases/download/r0.3.5/opencode-darwin-arm64.tar.gz"
      sha256 "7ee99102906fd75d169ee57b02d9f6faec236f72de4109f1403bf24f238d1a63"
    end
  end

  on_linux do
    if Hardware::CPU.intel? && Hardware::CPU.is_64_bit?
      url "https://github.com/scaryrawr/opencode/releases/download/r0.3.5/opencode-linux-x64.tar.gz"
      sha256 "bc23de2bcbe2aed282ea8c4b84013a6e5ae433ec5b864c0a143774519300815c"
    end
    if Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
      url "https://github.com/scaryrawr/opencode/releases/download/r0.3.5/opencode-linux-arm64.tar.gz"
      sha256 "a28f461d288805c3f6b3dd9ab5d35e9964781e219b29d75e1bf5b03d18833ad7"
    end
  end

  def install
    bin.install "bin/opencode"
  end
end

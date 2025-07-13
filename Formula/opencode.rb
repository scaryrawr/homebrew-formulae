class Opencode < Formula
  desc "AI coding agent built for the terminal"
  homepage "https://github.com/scaryrawr/opencode"
  version "0.2.33-2"

  on_macos do
    if Hardware::CPU.intel?
      url "https://github.com/scaryrawr/opencode/releases/download/r0.2.33-2/opencode-darwin-x64.tar.gz"
      sha256 "a7388e500856a4db0d101349353d4350e624e6dfdf57c07a24ec28cb8f806eb5"
    end
    if Hardware::CPU.arm?
      url "https://github.com/scaryrawr/opencode/releases/download/r0.2.33-2/opencode-darwin-arm64.tar.gz"
      sha256 "9e1639d417c679a024a318e2e2cd67adf2f73f5a694851fb9db45bfb3a64f925"
    end
  end

  on_linux do
    if Hardware::CPU.intel? && Hardware::CPU.is_64_bit?
      url "https://github.com/scaryrawr/opencode/releases/download/r0.2.33-2/opencode-linux-x64.tar.gz"
      sha256 "a75cf824b696045240055b468af5dc79387a6de1a3f9d06fe9d81d905d9c425c"
    end
    if Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
      url "https://github.com/scaryrawr/opencode/releases/download/r0.2.33-2/opencode-linux-arm64.tar.gz"
      sha256 "c3ffe75cae2e40c491850b0153e7a27fd5965313cfdd1e0da8c28c398025ecab"
    end
  end

  def install
    bin.install "bin/opencode"
  end
end

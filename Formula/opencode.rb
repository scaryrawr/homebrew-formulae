class Opencode < Formula
  desc "AI coding agent built for the terminal"
  homepage "https://github.com/scaryrawr/opencode"
  version "0.2.23"

  on_macos do
    if Hardware::CPU.intel?
      url "https://github.com/scaryrawr/opencode/releases/download/r0.2.23/opencode-darwin-x64.tar.gz"
      sha256 "180c8bb997dd06adbfff9794a1ac8c4b201bfac13bd962914ea0dbad4bab845e"
    end
    if Hardware::CPU.arm?
      url "https://github.com/scaryrawr/opencode/releases/download/r0.2.23/opencode-darwin-arm64.tar.gz"
      sha256 "93902a56e8438adbd003abf6cbd543bf2782e40d69c49ee54676b85ec5ce42e2"
    end
  end

  on_linux do
    if Hardware::CPU.intel? && Hardware::CPU.is_64_bit?
      url "https://github.com/scaryrawr/opencode/releases/download/r0.2.23/opencode-linux-x64.tar.gz"
      sha256 "59439f48eaf043755c6c248fa53239a6aac8964db4580649dca3cff966d18915"
    end
    if Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
      url "https://github.com/scaryrawr/opencode/releases/download/r0.2.23/opencode-linux-arm64.tar.gz"
      sha256 "b96627ab1581e84adca59afa3bc1815af4907424b37f36dc6e8cde08a7e8a78f"
    end
  end

  def install
    bin.install "bin/opencode"
  end
end

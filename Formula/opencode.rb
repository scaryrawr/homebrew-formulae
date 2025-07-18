class Opencode < Formula
  desc "AI coding agent built for the terminal"
  homepage "https://github.com/scaryrawr/opencode"
  version "0.3.19"

  on_macos do
    if Hardware::CPU.intel?
      url "https://github.com/scaryrawr/opencode/releases/download/r0.3.19/opencode-darwin-x64.tar.gz"
      sha256 "ade486aa47561b66a824638c9cc0e4b308e3ba01c14857b371ef3835c7907319"
    end
    if Hardware::CPU.arm?
      url "https://github.com/scaryrawr/opencode/releases/download/r0.3.19/opencode-darwin-arm64.tar.gz"
      sha256 "1381d17d8b9112cfc28738d20887e1aa9a94cf7ba0ea458fa027be85b5971311"
    end
  end

  on_linux do
    if Hardware::CPU.intel? && Hardware::CPU.is_64_bit?
      url "https://github.com/scaryrawr/opencode/releases/download/r0.3.19/opencode-linux-x64.tar.gz"
      sha256 "170e4393050d22bd3bef4aeeb8ebc8e6b1c61b20f0d56320761ad775ae2b900c"
    end
    if Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
      url "https://github.com/scaryrawr/opencode/releases/download/r0.3.19/opencode-linux-arm64.tar.gz"
      sha256 "2a3e886de2d4ccc633533cf6c49b2002b2ea5efd5d7d1cb6aa86361cb071b5c1"
    end
  end

  def install
    bin.install "bin/opencode"
  end
end

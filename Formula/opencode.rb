class Opencode < Formula
  desc "AI coding agent built for the terminal"
  homepage "https://github.com/scaryrawr/opencode"
  version "0.3.70"

  on_macos do
    if Hardware::CPU.intel?
      url "https://github.com/scaryrawr/opencode/releases/download/r0.3.70/opencode-darwin-x64.tar.gz"
      sha256 "54fb1d3cca1b7cf7d617a273eb83a1bbf28b50589999c4e67f26d7bf5b4214f6"
    end
    if Hardware::CPU.arm?
      url "https://github.com/scaryrawr/opencode/releases/download/r0.3.70/opencode-darwin-arm64.tar.gz"
      sha256 "404a473c9e1ab5d91fb4b61b6dd7298875617bd8db950823202fa023c36ef57e"
    end
  end

  on_linux do
    if Hardware::CPU.intel? && Hardware::CPU.is_64_bit?
      url "https://github.com/scaryrawr/opencode/releases/download/r0.3.70/opencode-linux-x64.tar.gz"
      sha256 "bcb690e73aa119a7a49a01eab14ddb960398be15b2ad17d439af3adf199ce3ba"
    end
    if Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
      url "https://github.com/scaryrawr/opencode/releases/download/r0.3.70/opencode-linux-arm64.tar.gz"
      sha256 "087d3c75a71a4a8e48e0c9297efe192e2ead1821dddeb47d260e21331c1bbc6d"
    end
  end

  def install
    bin.install "bin/opencode"
  end
end

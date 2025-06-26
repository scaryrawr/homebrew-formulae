class Opencode < Formula
  desc "AI coding agent built for the terminal"
  homepage "https://github.com/scaryrawr/opencode"
  version "0.1.139"

  on_macos do
    if Hardware::CPU.intel?
      url "https://github.com/scaryrawr/opencode/releases/download/r0.1.139/opencode-darwin-x64.tar.gz"
      sha256 "ed26dd55afc36f35a92a7b361d8a09e6909f1fc9963189c98ac5ae6f3bc50532"
    end
    if Hardware::CPU.arm?
      url "https://github.com/scaryrawr/opencode/releases/download/r0.1.139/opencode-darwin-arm64.tar.gz"
      sha256 "f70640eb680f0c3f5d0a09827fa5cb933abb5c59fae3466f80d3f31d53a7f48a"
    end
  end

  on_linux do
    if Hardware::CPU.intel? && Hardware::CPU.is_64_bit?
      url "https://github.com/scaryrawr/opencode/releases/download/r0.1.139/opencode-linux-x64.tar.gz"
      sha256 "ebcaad75462a3f54e2bfc5dea8cf4ea718e701daf76fcb1246155a71ba87be09"
    end
    if Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
      url "https://github.com/scaryrawr/opencode/releases/download/r0.1.139/opencode-linux-arm64.tar.gz"
      sha256 "7f1f199c0c0dca29e426d36fd6d3fef5f8f960d00e77d6c584532faf2faedaa3"
    end
  end

  def install
    bin.install "bin/opencode"
  end
end

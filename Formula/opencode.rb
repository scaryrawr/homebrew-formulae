class Opencode < Formula
  desc "AI coding agent built for the terminal"
  homepage "https://github.com/scaryrawr/opencode"
  version "0.2.16"

  on_macos do
    if Hardware::CPU.intel?
      url "https://github.com/scaryrawr/opencode/releases/download/r0.2.16/opencode-darwin-x64.tar.gz"
      sha256 "17122a5ec422a412e8734900b82572c598ab079156df05c77fee9c2f1a601bb6"
    end
    if Hardware::CPU.arm?
      url "https://github.com/scaryrawr/opencode/releases/download/r0.2.16/opencode-darwin-arm64.tar.gz"
      sha256 "683124029e8334ec3943c193c162dc2bf0eb742df784508c0780024bfdb3467f"
    end
  end

  on_linux do
    if Hardware::CPU.intel? && Hardware::CPU.is_64_bit?
      url "https://github.com/scaryrawr/opencode/releases/download/r0.2.16/opencode-linux-x64.tar.gz"
      sha256 "d50d01d0a7f47ade2b564dd2316b5397e989ffac21dfaaf9808b9c4f5f032f6b"
    end
    if Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
      url "https://github.com/scaryrawr/opencode/releases/download/r0.2.16/opencode-linux-arm64.tar.gz"
      sha256 "fdc4b985fde1ae9a853adf5b790db238f95141b6aeb4286ea2eadf83335cb4fe"
    end
  end

  def install
    bin.install "bin/opencode"
  end
end

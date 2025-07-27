class Opencode < Formula
  desc "AI coding agent built for the terminal"
  homepage "https://github.com/scaryrawr/opencode"
  version "0.3.78"

  on_macos do
    if Hardware::CPU.intel?
      url "https://github.com/scaryrawr/opencode/releases/download/r0.3.78/opencode-darwin-x64.tar.gz"
      sha256 "3160aff8c068fd33a7f4099ee8c06aa148f66b8cd5883622f362e4468dd342d2"
    end
    if Hardware::CPU.arm?
      url "https://github.com/scaryrawr/opencode/releases/download/r0.3.78/opencode-darwin-arm64.tar.gz"
      sha256 "361186e00453bd95b350f9de582ea51a26c1eac5aab01f982596242a00f5364f"
    end
  end

  on_linux do
    if Hardware::CPU.intel? && Hardware::CPU.is_64_bit?
      url "https://github.com/scaryrawr/opencode/releases/download/r0.3.78/opencode-linux-x64.tar.gz"
      sha256 "5350f428149e41ac285b84d468093f05da653fc5a6d0fe3a216de3d57967a042"
    end
    if Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
      url "https://github.com/scaryrawr/opencode/releases/download/r0.3.78/opencode-linux-arm64.tar.gz"
      sha256 "4277684e73d7ad2594f8480ad5a15dc424c5429092def0aedbc141d3658b5fb2"
    end
  end

  def install
    bin.install "bin/opencode"
  end
end

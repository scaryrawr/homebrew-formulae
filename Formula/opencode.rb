class Opencode < Formula
  desc "AI coding agent built for the terminal"
  homepage "https://github.com/scaryrawr/opencode"
  version "0.3.61"

  on_macos do
    if Hardware::CPU.intel?
      url "https://github.com/scaryrawr/opencode/releases/download/r0.3.61/opencode-darwin-x64.tar.gz"
      sha256 "68abe8967bd3bc330440001225f3a385c1c8461b0a0cb6badaca2a14b27a39af"
    end
    if Hardware::CPU.arm?
      url "https://github.com/scaryrawr/opencode/releases/download/r0.3.61/opencode-darwin-arm64.tar.gz"
      sha256 "3a7053a4d34bca9106051a8e0ccbb86c49f5a37e38d0e8255b4f37165caec57c"
    end
  end

  on_linux do
    if Hardware::CPU.intel? && Hardware::CPU.is_64_bit?
      url "https://github.com/scaryrawr/opencode/releases/download/r0.3.61/opencode-linux-x64.tar.gz"
      sha256 "434319b0f65ea7aa9960b5b67b83778c51f8e67037466480b7cca4b93efbc934"
    end
    if Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
      url "https://github.com/scaryrawr/opencode/releases/download/r0.3.61/opencode-linux-arm64.tar.gz"
      sha256 "21eef645c2638daac4d3eb8623a8c512dc5025e2e9d77d57d3c1ae1858f00042"
    end
  end

  def install
    bin.install "bin/opencode"
  end
end

class Opencode < Formula
  desc "AI coding agent built for the terminal."
  homepage "https://github.com/scaryrawr/opencode"
  version "0.1.132"

  on_macos do
    if Hardware::CPU.intel?
      url "https://github.com/scaryrawr/opencode/releases/download/r0.1.132/opencode-darwin-x64.tar.gz"
      sha256 "ff9fbbaa6c41f26e6169ae4bf1aea6236b4e4fe5c21259a619cd607a894aae6f"
    end
    if Hardware::CPU.arm?
      url "https://github.com/scaryrawr/opencode/releases/download/r0.1.132/opencode-darwin-arm64.tar.gz"
      sha256 "8edad46e7f317702afa7bef0d8c496efd11e0a45815517faf3e44306a1fcb0f7"
    end
  end

  on_linux do
    if Hardware::CPU.intel? and Hardware::CPU.is_64_bit?
      url "https://github.com/scaryrawr/opencode/releases/download/r0.1.132/opencode-linux-x64.tar.gz"
      sha256 "64735040633a0bda61adbd31baf15625645c3c4588a1b6721ecc5411571dd69e"
    end
    if Hardware::CPU.arm? and Hardware::CPU.is_64_bit?
      url "https://github.com/scaryrawr/opencode/releases/download/r0.1.132/opencode-linux-arm64.tar.gz"
      sha256 "4ced1d225c3b23a7c7a9b58ed4b90871d7c5a0d2ec33f250484e3807c6142d5e"
    end
  end

  def install
    bin.install "bin/opencode"
  end
end
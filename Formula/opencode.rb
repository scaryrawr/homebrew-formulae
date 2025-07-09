class Opencode < Formula
  desc "AI coding agent built for the terminal"
  homepage "https://github.com/scaryrawr/opencode"
  version "0.2.13-3"

  on_macos do
    if Hardware::CPU.intel?
      url "https://github.com/scaryrawr/opencode/releases/download/r0.2.13-3/opencode-darwin-x64.tar.gz"
      sha256 "c569af933b12a4b25a4c1052888f3af4d51fcca010c28d6b51ea3206805e8629"
    end
    if Hardware::CPU.arm?
      url "https://github.com/scaryrawr/opencode/releases/download/r0.2.13-3/opencode-darwin-arm64.tar.gz"
      sha256 "24980e9ca6e74c821e525ef21e8758dd595cc5d09d8bb0641555617efe7406f5"
    end
  end

  on_linux do
    if Hardware::CPU.intel? && Hardware::CPU.is_64_bit?
      url "https://github.com/scaryrawr/opencode/releases/download/r0.2.13-3/opencode-linux-x64.tar.gz"
      sha256 "2c559fcb9e4de67007ccc1e82cc1f717aa36438b846ae745d3a8a5fa3c4efd71"
    end
    if Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
      url "https://github.com/scaryrawr/opencode/releases/download/r0.2.13-3/opencode-linux-arm64.tar.gz"
      sha256 "09b1c7123a3fced62c985e9220893b9d55e4c6a89614454178b357bacd8398e4"
    end
  end

  def install
    bin.install "bin/opencode"
  end
end

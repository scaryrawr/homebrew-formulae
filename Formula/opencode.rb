class Opencode < Formula
  desc "AI coding agent built for the terminal"
  homepage "https://github.com/scaryrawr/opencode"
  version "0.2.15"

  on_macos do
    if Hardware::CPU.intel?
      url "https://github.com/scaryrawr/opencode/releases/download/r0.2.15/opencode-darwin-x64.tar.gz"
      sha256 "3793649a2d484ddb1b41eb7ccfd9433fd128d26244459956f684c9913d9a2c09"
    end
    if Hardware::CPU.arm?
      url "https://github.com/scaryrawr/opencode/releases/download/r0.2.15/opencode-darwin-arm64.tar.gz"
      sha256 "f469bf6a11a5e538ed51ecd9aa2ae6b578b3dbc23257498f25cc86cd048464fa"
    end
  end

  on_linux do
    if Hardware::CPU.intel? && Hardware::CPU.is_64_bit?
      url "https://github.com/scaryrawr/opencode/releases/download/r0.2.15/opencode-linux-x64.tar.gz"
      sha256 "bd7cf923013bc96712fe211362183bb92f9ca345eb32675132d3b3b7fb990f76"
    end
    if Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
      url "https://github.com/scaryrawr/opencode/releases/download/r0.2.15/opencode-linux-arm64.tar.gz"
      sha256 "77cface721b9f360ad61e8ac0560a9318c4adc44addc50b20e2bc2337cd93ae2"
    end
  end

  def install
    bin.install "bin/opencode"
  end
end

class Opencode < Formula
  desc "AI coding agent built for the terminal"
  homepage "https://github.com/scaryrawr/opencode"
  version "0.3.22"

  on_macos do
    if Hardware::CPU.intel?
      url "https://github.com/scaryrawr/opencode/releases/download/r0.3.22/opencode-darwin-x64.tar.gz"
      sha256 "b1c9974d7782f41ee7358491a3b64c50500f3306836ae1469e0faa94fd306122"
    end
    if Hardware::CPU.arm?
      url "https://github.com/scaryrawr/opencode/releases/download/r0.3.22/opencode-darwin-arm64.tar.gz"
      sha256 "6f364846d893c3ac25677ed28508e9baad6222c8103fc406f980e6fe804436b6"
    end
  end

  on_linux do
    if Hardware::CPU.intel? && Hardware::CPU.is_64_bit?
      url "https://github.com/scaryrawr/opencode/releases/download/r0.3.22/opencode-linux-x64.tar.gz"
      sha256 "f688855dd12f853ad7ba95ed16365f034bac54eb7b08c3857619440d202ba07d"
    end
    if Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
      url "https://github.com/scaryrawr/opencode/releases/download/r0.3.22/opencode-linux-arm64.tar.gz"
      sha256 "42fd1d628f63e21a5deec888afdc7b2a241aee1a3b9f9b8b7ab2e478d1bc8fa2"
    end
  end

  def install
    bin.install "bin/opencode"
  end
end

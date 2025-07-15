class Opencode < Formula
  desc "AI coding agent built for the terminal"
  homepage "https://github.com/scaryrawr/opencode"
  version "0.3.9"

  on_macos do
    if Hardware::CPU.intel?
      url "https://github.com/scaryrawr/opencode/releases/download/r0.3.9/opencode-darwin-x64.tar.gz"
      sha256 "f83edadfe624b106863ffdaaa3bdd1d408c746e46d4559d7d6d11c776cea07e8"
    end
    if Hardware::CPU.arm?
      url "https://github.com/scaryrawr/opencode/releases/download/r0.3.9/opencode-darwin-arm64.tar.gz"
      sha256 "2dcbe8810d8b73dd29b41ca56da4f18f4d1ab6266b21d6458f2298022a275003"
    end
  end

  on_linux do
    if Hardware::CPU.intel? && Hardware::CPU.is_64_bit?
      url "https://github.com/scaryrawr/opencode/releases/download/r0.3.9/opencode-linux-x64.tar.gz"
      sha256 "684924a65f357a6ef5ba22f5ca9532fe1e57d1697c73a4c04ff1fd50a6c7b83b"
    end
    if Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
      url "https://github.com/scaryrawr/opencode/releases/download/r0.3.9/opencode-linux-arm64.tar.gz"
      sha256 "f1e3311b3f57d6d256c9f9806ed8198471e88d56af66a97202177b00611a948e"
    end
  end

  def install
    bin.install "bin/opencode"
  end
end

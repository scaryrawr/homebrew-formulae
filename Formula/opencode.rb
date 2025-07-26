class Opencode < Formula
  desc "AI coding agent built for the terminal"
  homepage "https://github.com/scaryrawr/opencode"
  version "0.3.77-1"

  on_macos do
    if Hardware::CPU.intel?
      url "https://github.com/scaryrawr/opencode/releases/download/r0.3.77-1/opencode-darwin-x64.tar.gz"
      sha256 "9dc22e640a21e39476a5c064bd7699ccce829c0fe657e1802ed468286448e6af"
    end
    if Hardware::CPU.arm?
      url "https://github.com/scaryrawr/opencode/releases/download/r0.3.77-1/opencode-darwin-arm64.tar.gz"
      sha256 "f22f9024977c1b07c6bde1a3b43b6210a4bbed8887a8fb1bf7f045c347302280"
    end
  end

  on_linux do
    if Hardware::CPU.intel? && Hardware::CPU.is_64_bit?
      url "https://github.com/scaryrawr/opencode/releases/download/r0.3.77-1/opencode-linux-x64.tar.gz"
      sha256 "b680eaf13bfdecc8d5f6cb8dc0b2421f78a599716b3347a510a431df674229a3"
    end
    if Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
      url "https://github.com/scaryrawr/opencode/releases/download/r0.3.77-1/opencode-linux-arm64.tar.gz"
      sha256 "85f2714b43f92d1568608d3517d9ee4466c24b3ec844afc086b737b18c2485f9"
    end
  end

  def install
    bin.install "bin/opencode"
  end
end

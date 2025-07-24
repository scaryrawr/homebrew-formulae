class Opencode < Formula
  desc "AI coding agent built for the terminal"
  homepage "https://github.com/scaryrawr/opencode"
  version "0.3.58"

  on_macos do
    if Hardware::CPU.intel?
      url "https://github.com/scaryrawr/opencode/releases/download/r0.3.58/opencode-darwin-x64.tar.gz"
      sha256 "9d323b28914a3b1435d1f9fa0fa103690d3835da5815583f040e3e0ca57f41a6"
    end
    if Hardware::CPU.arm?
      url "https://github.com/scaryrawr/opencode/releases/download/r0.3.58/opencode-darwin-arm64.tar.gz"
      sha256 "5b200457095057fc01bc85d4190fe8b17b5eff96768f41ca58da68f320633cb3"
    end
  end

  on_linux do
    if Hardware::CPU.intel? && Hardware::CPU.is_64_bit?
      url "https://github.com/scaryrawr/opencode/releases/download/r0.3.58/opencode-linux-x64.tar.gz"
      sha256 "6840f11e6765d6bb49ccb9d78c359da35d6658fc1dfb5334f930420d8f77f356"
    end
    if Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
      url "https://github.com/scaryrawr/opencode/releases/download/r0.3.58/opencode-linux-arm64.tar.gz"
      sha256 "c56fe4814ac355b7b58ea4a8ccad5a3728dfc02899bd41796591232f325f9024"
    end
  end

  def install
    bin.install "bin/opencode"
  end
end

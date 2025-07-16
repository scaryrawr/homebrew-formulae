class Opencode < Formula
  desc "AI coding agent built for the terminal"
  homepage "https://github.com/scaryrawr/opencode"
  version "0.3.13"

  on_macos do
    if Hardware::CPU.intel?
      url "https://github.com/scaryrawr/opencode/releases/download/r0.3.13/opencode-darwin-x64.tar.gz"
      sha256 "89565ce83ff4fd668754ed777c508c701328a2be370562ce3361d9c50a873e33"
    end
    if Hardware::CPU.arm?
      url "https://github.com/scaryrawr/opencode/releases/download/r0.3.13/opencode-darwin-arm64.tar.gz"
      sha256 "8a23398841888fa12f7b2044b7f0e5137423e32c0fbd3ee65f40ae384cdb0caf"
    end
  end

  on_linux do
    if Hardware::CPU.intel? && Hardware::CPU.is_64_bit?
      url "https://github.com/scaryrawr/opencode/releases/download/r0.3.13/opencode-linux-x64.tar.gz"
      sha256 "425ffb34c217adcac10cadfb6300c7db89aa1b19a31f8ca8331807504cf1ba5e"
    end
    if Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
      url "https://github.com/scaryrawr/opencode/releases/download/r0.3.13/opencode-linux-arm64.tar.gz"
      sha256 "46999dc1ecadd1e563952bd41e3c9f49d5f01d893debf380a5e03e64c7044c9b"
    end
  end

  def install
    bin.install "bin/opencode"
  end
end

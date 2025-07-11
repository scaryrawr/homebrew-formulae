class Opencode < Formula
  desc "AI coding agent built for the terminal"
  homepage "https://github.com/scaryrawr/opencode"
  version "0.2.27-1"

  on_macos do
    if Hardware::CPU.intel?
      url "https://github.com/scaryrawr/opencode/releases/download/r0.2.27-1/opencode-darwin-x64.tar.gz"
      sha256 "6354ba18eb7273fe8bbbaaf3d008d6c031ce17570d8bcd00cd02ea7e09df06c9"
    end
    if Hardware::CPU.arm?
      url "https://github.com/scaryrawr/opencode/releases/download/r0.2.27-1/opencode-darwin-arm64.tar.gz"
      sha256 "4c27d392d29fff2733248d874eb254ef7af83f9a7c29f603b6b403d55544f0b9"
    end
  end

  on_linux do
    if Hardware::CPU.intel? && Hardware::CPU.is_64_bit?
      url "https://github.com/scaryrawr/opencode/releases/download/r0.2.27-1/opencode-linux-x64.tar.gz"
      sha256 "fecdb66fb64213c6d27bbdac44014ede9e5614ffaf11e75c2173d7b6b9200ef4"
    end
    if Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
      url "https://github.com/scaryrawr/opencode/releases/download/r0.2.27-1/opencode-linux-arm64.tar.gz"
      sha256 "850c2eaf0428d723f31d09abde11a585885cfbbadb7712a904fc4fd707e37bda"
    end
  end

  def install
    bin.install "bin/opencode"
  end
end

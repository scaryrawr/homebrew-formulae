class Opencode < Formula
  desc "AI coding agent built for the terminal"
  homepage "https://github.com/scaryrawr/opencode"
  version "0.3.81"

  on_macos do
    if Hardware::CPU.intel?
      url "https://github.com/scaryrawr/opencode/releases/download/r0.3.81/opencode-darwin-x64.tar.gz"
      sha256 "3996c3ebffa5a21b37a995c09b13be27b64646de524567eb53ce1fed35b61398"
    end
    if Hardware::CPU.arm?
      url "https://github.com/scaryrawr/opencode/releases/download/r0.3.81/opencode-darwin-arm64.tar.gz"
      sha256 "d3999179823fc152a0272487f7875a7fb811c017c5626ea471ee7f631aea2ccc"
    end
  end

  on_linux do
    if Hardware::CPU.intel? && Hardware::CPU.is_64_bit?
      url "https://github.com/scaryrawr/opencode/releases/download/r0.3.81/opencode-linux-x64.tar.gz"
      sha256 "a5e97a1af29ba317eadf1c1d3803c619a9d89b9332c399280471a9ce58f3318f"
    end
    if Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
      url "https://github.com/scaryrawr/opencode/releases/download/r0.3.81/opencode-linux-arm64.tar.gz"
      sha256 "5b5ed8e223c5f7989cec95e8e73a5201eb785e7141aca1dd871fe6fb35ec63d4"
    end
  end

  def install
    bin.install "bin/opencode"
  end
end

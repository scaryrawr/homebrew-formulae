class Claudio < Formula
  desc "LM Studio wrapper around Claude Code"
  homepage "https://github.com/scaryrawr/claudio"
  license "MIT"

  on_macos do
    depends_on arch: :arm64
    url "https://github.com/scaryrawr/claudio/releases/download/v0.0.2/claudio-v0.0.2-aarch64-apple-darwin.tar.gz"
    sha256 "8a6b72962855144096b5ed0bd2b9a795bc839f787fd9968917626944036ab093"
  end

  on_linux do
    if Hardware::CPU.intel? && Hardware::CPU.is_64_bit?
      url "https://github.com/scaryrawr/claudio/releases/download/v0.0.2/claudio-v0.0.2-x86_64-unknown-linux-gnu.tar.gz"
      sha256 "f6cd53dbfa24d3281caaa1dfdb6ffa9f0e1d1027894e9776787e971e3a8c11bd"
    end
    if Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
      url "https://github.com/scaryrawr/claudio/releases/download/v0.0.2/claudio-v0.0.2-aarch64-unknown-linux-gnu.tar.gz"
      sha256 "31f555dfb763390873770b37bc7665e40b7f1f78adc646f2c2a2c676a9cd02b7"
    end
  end

  def install
    bin.install "claudio"
  end

  test do
    system bin/"claudio", "--help"
  end
end

class Claudio < Formula
  desc "LM Studio wrapper around Claude Code"
  homepage "https://github.com/scaryrawr/claudio"
  license "MIT"

  on_macos do
    depends_on arch: :arm64
    on_arm do
      url "https://github.com/scaryrawr/claudio/releases/download/v0.0.3/claudio-v0.0.3-aarch64-apple-darwin.tar.gz"
      sha256 "0884e754f431d6aa78604f96868155b2241a3724aab80437a39c347aa03fc10a"
    end
  end

  on_linux do
    if Hardware::CPU.intel? && Hardware::CPU.is_64_bit?
      url "https://github.com/scaryrawr/claudio/releases/download/v0.0.3/claudio-v0.0.3-x86_64-unknown-linux-gnu.tar.gz"
      sha256 "0bef4ad2d1bedfd16021164db3112f77e8fc669d1484b740873352c48ff1ecbf"
    end
    if Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
      url "https://github.com/scaryrawr/claudio/releases/download/v0.0.3/claudio-v0.0.3-aarch64-unknown-linux-gnu.tar.gz"
      sha256 "83e47deb35a6d42f0c021b394ae139c8b9873164e3c7b3bf0e59dad2e0aa2daa"
    end
  end

  def install
    bin.install "claudio"
  end

  test do
    system bin/"claudio", "--help"
  end
end

class Opencode < Formula
  desc "AI coding agent built for the terminal"
  homepage "https://github.com/scaryrawr/opencode"
  version "0.3.45"

  on_macos do
    if Hardware::CPU.intel?
      url "https://github.com/scaryrawr/opencode/releases/download/r0.3.45/opencode-darwin-x64.tar.gz"
      sha256 "af01a44c40a8c3dfe9b35bc05924998549fb78673af9754637bd7e4bd0519d5d"
    end
    if Hardware::CPU.arm?
      url "https://github.com/scaryrawr/opencode/releases/download/r0.3.45/opencode-darwin-arm64.tar.gz"
      sha256 "4d70a2b4035c7f31956b2aec9982a1da9eba37791d16ee12bf6c71691065eb63"
    end
  end

  on_linux do
    if Hardware::CPU.intel? && Hardware::CPU.is_64_bit?
      url "https://github.com/scaryrawr/opencode/releases/download/r0.3.45/opencode-linux-x64.tar.gz"
      sha256 "fad99fa9a773f77cb56ea58d7d1311e6572ce6d40c448df6d0e799d9f63e4e5b"
    end
    if Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
      url "https://github.com/scaryrawr/opencode/releases/download/r0.3.45/opencode-linux-arm64.tar.gz"
      sha256 "45e178e89ecce87e78f80e8e83c5a2b870b3833838b314656c96dfda7916d1cd"
    end
  end

  def install
    bin.install "bin/opencode"
  end
end

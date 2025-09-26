class Magus < Formula
  desc "AI coding agent built for the terminal"
  homepage "https://github.com/scaryrawr/magus"
  version "0.0.7"

  on_macos do
    if Hardware::CPU.intel?
      url "https://github.com/scaryrawr/magus/releases/download/v0.0.1/magus-darwin-x64.tar.gz"
      sha256 "1288d0e303fa44e8a6a8c46945d5e7596431fb5c6c06e113525c38486f766d3d"
    end
    if Hardware::CPU.arm?
      url "https://github.com/scaryrawr/magus/releases/download/v0.0.1/magus-darwin-arm64.tar.gz"
      sha256 "a231b11333b44545a9ad6a0f0375eac32f4aba228d6bddcdd249541fb4b00cce"
    end
  end

  on_linux do
    if Hardware::CPU.intel? && Hardware::CPU.is_64_bit?
      url "https://github.com/scaryrawr/magus/releases/download/v0.0.1/magus-linux-x64.tar.gz"
      sha256 "843eb0f05ef651ed477d66ee9c071a0c663ea4c1d034d91a8b3339f397d0d163"
    end
    if Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
      url "https://github.com/scaryrawr/magus/releases/download/v0.0.1/magus-linux-arm64.tar.gz"
      sha256 "c4e2570579a02123533ec660a665fc7edc3f191d71bd4f4411b540cad5e7d910"
    end
  end

  def install
    bin.install "bin/magus"
  end
end

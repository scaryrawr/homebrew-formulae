class Opencode < Formula
  desc "AI coding agent built for the terminal"
  homepage "https://github.com/scaryrawr/opencode"
  version "0.3.11"

  on_macos do
    if Hardware::CPU.intel?
      url "https://github.com/scaryrawr/opencode/releases/download/r0.3.11/opencode-darwin-x64.tar.gz"
      sha256 "4747b0a53e59f0ee311bcaf4bf8491cd7304808a4c6b441e77a1635a3d4e412a"
    end
    if Hardware::CPU.arm?
      url "https://github.com/scaryrawr/opencode/releases/download/r0.3.11/opencode-darwin-arm64.tar.gz"
      sha256 "be5fb33d3a63f7f669690ef61a8951a91a6a09dd020bc685ca7b8ae9524b256d"
    end
  end

  on_linux do
    if Hardware::CPU.intel? && Hardware::CPU.is_64_bit?
      url "https://github.com/scaryrawr/opencode/releases/download/r0.3.11/opencode-linux-x64.tar.gz"
      sha256 "0bb6d400faa4fb778c3f814fedcc1caf59046926b3fcdbef57d953a24edef71b"
    end
    if Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
      url "https://github.com/scaryrawr/opencode/releases/download/r0.3.11/opencode-linux-arm64.tar.gz"
      sha256 "c3ed59560a7870b3569391a5376681f4480f3c2800f1f56f55eaa05290e88bd4"
    end
  end

  def install
    bin.install "bin/opencode"
  end
end

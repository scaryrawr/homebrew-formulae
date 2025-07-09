class Opencode < Formula
  desc "AI coding agent built for the terminal"
  homepage "https://github.com/scaryrawr/opencode"
  version "0.2.13-1"

  on_macos do
    if Hardware::CPU.intel?
      url "https://github.com/scaryrawr/opencode/releases/download/r0.2.13-1/opencode-darwin-x64.tar.gz"
      sha256 "aeadaa9ca5bb6b4db1a5907b7f03c6c45203bfeaacbde7c888b4b99e36b860dd"
    end
    if Hardware::CPU.arm?
      url "https://github.com/scaryrawr/opencode/releases/download/r0.2.13-1/opencode-darwin-arm64.tar.gz"
      sha256 "49144162008ba001a0438cdb18b693212cc1f495656c44b544382780a3f44e1a"
    end
  end

  on_linux do
    if Hardware::CPU.intel? && Hardware::CPU.is_64_bit?
      url "https://github.com/scaryrawr/opencode/releases/download/r0.2.13-1/opencode-linux-x64.tar.gz"
      sha256 "bada88f6654123fe9cc24ed53cf5d75a656290d25c14379cb0741dcd7e1728d8"
    end
    if Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
      url "https://github.com/scaryrawr/opencode/releases/download/r0.2.13-1/opencode-linux-arm64.tar.gz"
      sha256 "9dd5c153b5bf48d1450163a324465340d7a39c178936a90d3421a176e5780ca9"
    end
  end

  def install
    bin.install "bin/opencode"
  end
end

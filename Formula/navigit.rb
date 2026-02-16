class Navigit < Formula
  desc "Context-aware Git tool dispatcher"
  homepage "https://github.com/scaryrawr/navigit"
  version "0.0.1"
  license :cannot_represent
  head "https://github.com/scaryrawr/navigit.git", branch: "main"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/scaryrawr/navigit/releases/download/v0.0.1/navigit-v0.0.1-macos-arm64.tar.gz"
      sha256 "f11ed7166246d6a329a7893d5f9122b6d7615aede4b823d0f0803d205069a4e4"
    end
  end

  on_linux do
    if Hardware::CPU.intel? && Hardware::CPU.is_64_bit?
      url "https://github.com/scaryrawr/navigit/releases/download/v0.0.1/navigit-v0.0.1-linux-x64.tar.gz"
      sha256 "15a4a8c60465ed40266651a811d52d298418b36bf2f0a6e407810960675dfe9d"
    end
    if Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
      url "https://github.com/scaryrawr/navigit/releases/download/v0.0.1/navigit-v0.0.1-linux-arm64.tar.gz"
      sha256 "ce00a1d3d590e7f6accf26f652e708480269d986d64ff4d8496ee097fcf7ac87"
    end
  end

  def install
    bin.install "navigit"
  end

  test do
    system bin/"navigit", "help"
  end
end

class Navigit < Formula
  desc "Context-aware Git tool dispatcher"
  homepage "https://github.com/scaryrawr/navigit"
  version "0.0.2"
  license :cannot_represent
  head "https://github.com/scaryrawr/navigit.git", branch: "main"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/scaryrawr/navigit/releases/download/v0.0.2/navigit-v0.0.2-macos-arm64.tar.gz"
      sha256 "51eb0d9dc79b7f3c10ced4249284edfdfcd80f13e7db53980fc2d595f22ea1ac"
    end
  end

  on_linux do
    if Hardware::CPU.intel? && Hardware::CPU.is_64_bit?
      url "https://github.com/scaryrawr/navigit/releases/download/v0.0.2/navigit-v0.0.2-linux-x64.tar.gz"
      sha256 "2b330fc834ccfb48243017450a752888262c9bde9b9299c55eaf3a86d446c982"
    end
    if Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
      url "https://github.com/scaryrawr/navigit/releases/download/v0.0.2/navigit-v0.0.2-linux-arm64.tar.gz"
      sha256 "9845d8582b13cc83080474bb04e5a9fae824eafef8a91c17578351b3bab13b2a"
    end
  end

  def install
    bin.install "navigit"
  end

  test do
    system bin/"navigit", "help"
  end
end

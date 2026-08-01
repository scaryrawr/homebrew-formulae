class Devpod < Formula
  desc "Codespaces-like tool for reproducible developer environments"
  homepage "https://github.com/scaryrawr/devpod"
  version "0.0.5"
  license "MPL-2.0"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/scaryrawr/devpod/releases/download/v0.0.5/devpod-darwin-arm64"
      sha256 "1eea2dc92eb9b342203224ec0bd34261f6dd79d8eb04c4d65b4b355ecca17e9"
    elsif Hardware::CPU.intel?
      url "https://github.com/scaryrawr/devpod/releases/download/v0.0.5/devpod-darwin-amd64"
      sha256 "6f3de5784f788284e5d7fee77cd02bbca440a0881e860d681779955c00378984"
    end
  end

  on_linux do
    if Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
      url "https://github.com/scaryrawr/devpod/releases/download/v0.0.5/devpod-linux-arm64"
      sha256 "ab3aeb126a7027e21a01660e6414734fb989e6da0b5a3153e7a12c5edc288895"
    elsif Hardware::CPU.intel? && Hardware::CPU.is_64_bit?
      url "https://github.com/scaryrawr/devpod/releases/download/v0.0.5/devpod-linux-amd64"
      sha256 "1ed7ac2bc9c1f466a3cf336744d32499d7b20566708b871a901f9c8c900e3615"
    end
  end

  def install
    bin.install Dir["devpod-*"].first => "devpod"
  end

  test do
    system bin/"devpod", "version"
  end
end

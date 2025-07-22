class Opencode < Formula
  desc "AI coding agent built for the terminal"
  homepage "https://github.com/scaryrawr/opencode"
  version "0.3.51"

  on_macos do
    if Hardware::CPU.intel?
      url "https://github.com/scaryrawr/opencode/releases/download/r0.3.51/opencode-darwin-x64.tar.gz"
      sha256 "c1072f0399217160f3e31b8fa8615fb89346894cbf3481a94f39107259b2a47a"
    end
    if Hardware::CPU.arm?
      url "https://github.com/scaryrawr/opencode/releases/download/r0.3.51/opencode-darwin-arm64.tar.gz"
      sha256 "8da66d4dc84d5b40512c16959782fb2599b7cfff6ff5db43b288094ce92f5c57"
    end
  end

  on_linux do
    if Hardware::CPU.intel? && Hardware::CPU.is_64_bit?
      url "https://github.com/scaryrawr/opencode/releases/download/r0.3.51/opencode-linux-x64.tar.gz"
      sha256 "40ff6d47ee87cf8c3bba010c54e0deaf5b536e2862a686d0c9effbe90f034ac5"
    end
    if Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
      url "https://github.com/scaryrawr/opencode/releases/download/r0.3.51/opencode-linux-arm64.tar.gz"
      sha256 "7dc31391ead52c7c25dedfd1885edfdd83605403d758702c8f99fa2a370acfc4"
    end
  end

  def install
    bin.install "bin/opencode"
  end
end

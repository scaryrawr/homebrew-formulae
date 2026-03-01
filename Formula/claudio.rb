class Claudio < Formula
  desc "LM Studio wrapper around Claude Code"
  homepage "https://github.com/scaryrawr/claudio"
  url "https://github.com/scaryrawr/claudio/archive/refs/tags/v0.0.3.tar.gz"
  sha256 "99329e0d1cf480cd6709e8d7605ff8c64e5833e5aa4c6e6a95d15a67fed4273c"
  license "MIT"
  head "https://github.com/scaryrawr/claudio.git", branch: "main"

  depends_on "rust" => :build

  def install
    system "cargo", "install", "--root=#{prefix}", "--locked", "--path=."
  end
end

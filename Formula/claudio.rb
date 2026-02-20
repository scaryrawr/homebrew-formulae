class Claudio < Formula
  desc "LM Studio wrapper around Claude Code"
  homepage "https://github.com/scaryrawr/claudio"
  url "https://github.com/scaryrawr/claudio/archive/refs/tags/v0.0.2.tar.gz"
  sha256 "eacb8339181a1d9c3c13d9b7a048eff3e570b879ba0a7132641217202ffd58ef"
  license "MIT"
  head "https://github.com/scaryrawr/claudio.git", branch: "main"

  depends_on "rust" => :build

  def install
    system "cargo", "install", "--root=#{prefix}", "--locked", "--path=."
  end
end

class Claudio < Formula
  desc "LM Studio wrapper around Claude Code"
  homepage "https://github.com/scaryrawr/claudio"
  url "https://github.com/scaryrawr/claudio/archive/refs/tags/v0.0.1.tar.gz"
  sha256 "87bfa926d31305600c5901ccfc96e0af8e11bdcbd58a1e9e1efd795c2e9a36ee"
  license "MIT"
  head "https://github.com/scaryrawr/claudio.git", branch: "main"

  depends_on "rust" => :build
  depends_on "claude-code" => :optional

  def install
    system "cargo", "install", "--root=#{prefix}", "--locked", "--path=."
  end

  test do
    # Just verify the binary runs and passes args to claude
    output = shell_output("#{bin}/claudio --version 2>&1", 1)
    assert_match "missing dependency: claude", output
  end
end

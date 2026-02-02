class Claudio < Formula
  desc "LM Studio wrapper around Claude Code"
  homepage "https://github.com/scaryrawr/claudio"
  url "https://github.com/scaryrawr/claudio/archive/refs/tags/v0.0.1.tar.gz"
  sha256 "87bfa926d31305600c5901ccfc96e0af8e11bdcbd58a1e9e1efd795c2e9a36ee"
  license "MIT"
  head "https://github.com/scaryrawr/claudio.git", branch: "main"

  depends_on "rust" => :build

  def install
    system "cargo", "install", "--locked", "--root=#{prefix}", "--path=."
  end

  test do
    # Avoid requiring `claude` at test time; this path errors out before exec.
    output = shell_output("#{bin}/claudio -p hi 2>&1", 2)
    assert_match "no --model provided", output
  end
end

class Claudio < Formula
  desc "Wrapper to run Claude Code against LM Studio"
  homepage "https://github.com/scaryrawr/claudio"
  url "https://github.com/scaryrawr/claudio/archive/f07898365f80f59696e119cd3d3a9ba5bc543207.tar.gz"
  version "0.0.0+f078983"
  sha256 "b957988468c68a0e082acc528460f14405631d71f752d297f53c04f4868de1ee"
  license "MIT"

  depends_on "gum"
  depends_on "jq"
  depends_on cask: "claude-code"
  depends_on cask: "lm-studio"

  def install
    bin.install "claudio"
  end

  test do
    system "bash", "-n", bin/"claudio"
  end
end

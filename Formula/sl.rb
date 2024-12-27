class Sl < Formula
  desc "Prints a steam locomotive if you type sl instead of ls"
  homepage "https://github.com/scaryrawr/sl"
  url "https://github.com/scaryrawr/sl/archive/refs/tags/sl-6.12-1.tar.gz"
  sha256 "60c967c355452616dd28df72bdb40aeac66b11cdb033b74c5b77584b3645d982"
  license "MIT"
  head "https://github.com/scaryrawr/sl.git", branch: "main"

  depends_on "rust" => :build
  depends_on "zig" => :build

  conflicts_with "sapling", because: "both install `sl` binaries"

  def install
    ENV["COMPLETIONS_DIR"] = "completions"
    system "cargo", "install", *std_cargo_args

    man1.install "completions/sl.1"
    bash_completion.install "completions/sl.bash"
    fish_completion.install "completions/sl.fish"
    zsh_completion.install "completions/_sl"
  end

  test do
    system bin/"sl", "-h"
    system bin/"sl", "-V"
  end
end

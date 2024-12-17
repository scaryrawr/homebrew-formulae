class Sl < Formula
  desc "Prints a steam locomotive if you type sl instead of ls"
  homepage "https://github.com/scaryrawr/sl"
  url "https://github.com/scaryrawr/sl/archive/refs/tags/sl-6.02-1.tar.gz"
  sha256 "bce2e80a40e09582da0b17850e0f5ed927b6cdb070ac6c31234a443a616a95ad"
  license "MIT"
  head "https://github.com/scaryrawr/sl.git", branch: "main"

  depends_on "cmake" => :build
  depends_on "rust" => :build

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
    system bin/"sl", "-c"
    system bin/"sl", "-h"
    system bin/"sl", "-V"
  end
end

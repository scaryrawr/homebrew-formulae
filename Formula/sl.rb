class Sl < Formula
  desc "Prints a steam locomotive if you type sl instead of ls"
  homepage "https://github.com/scaryrawr/sl"
  url "https://github.com/scaryrawr/sl/archive/refs/tags/sl-6.03-1.tar.gz"
  sha256 "c0623f01f7425b4cff47154ba1fb42115ae96535b8df2239c0d177646c121e01"
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
    system bin/"sl", "-h"
    system bin/"sl", "-V"
  end
end

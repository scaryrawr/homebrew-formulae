class Sl < Formula
  desc "Prints a steam locomotive if you type sl instead of ls"
  homepage "https://github.com/scaryrawr/sl"
  url "https://github.com/scaryrawr/sl/archive/refs/tags/sl-6.13-1.tar.gz"
  sha256 "1fe943c9d2d84dda2e5d92f9f20b1703843e9ccc8d972da3eac1a5a2bec60c07"
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

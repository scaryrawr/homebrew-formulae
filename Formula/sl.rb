class Sl < Formula
  desc "Prints a steam locomotive if you type sl instead of ls"
  homepage "https://github.com/scaryrawr/sl"
  url "https://github.com/scaryrawr/sl/archive/refs/tags/sl-6.15-2.tar.gz"
  sha256 "4fc059694e1996cfd18ddef2339c86e7705103806269e5cbd921d38a8f01ae33"
  license "MIT"
  head "https://github.com/scaryrawr/sl.git", branch: "main"

  depends_on "rust" => :build

  conflicts_with "sapling", because: "both install `sl` binaries"

  def install
    ENV["COMPLETIONS_DIR"] = "completions"
    system "cargo", "install", "--root=#{prefix}", "--locked", "--path=./apps/sl"

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

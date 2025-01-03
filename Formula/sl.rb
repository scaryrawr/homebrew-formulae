class Sl < Formula
  desc "Prints a steam locomotive if you type sl instead of ls"
  homepage "https://github.com/scaryrawr/sl"
  url "https://api.github.com/repos/scaryrawr/sl/tarball/sl-6.14-1"
  sha256 "7cd42c0bf67fe381874284b15ecf9df8451d6e96422ffd8682e1cb6dccf5b87d"
  license "MIT"
  head "https://github.com/scaryrawr/sl.git", branch: "main"

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

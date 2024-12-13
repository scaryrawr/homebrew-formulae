class Sl < Formula
  desc "Prints a steam locomotive if you type sl instead of ls"
  homepage "https://github.com/scaryrawr/sl"
  url "https://github.com/scaryrawr/sl/archive/refs/tags/sl-6.0.0-1.tar.gz"
  sha256 "4fa140458a8e5b9aff6dab24248f9de57bb739d42ad6d695de07d56eb2806db6"
  license "MIT"
  head "https://github.com/scaryrawr/sl.git", branch: "main"

  depends_on "cmake" => :build
  depends_on "rust" => :build

  conflicts_with "sapling", because: "both install `sl` binaries"

  def install
    system "cargo", "install", *std_cargo_args
    man1.install "sl.1"
  end

  test do
    system bin/"sl", "-c"
    system bin/"sl", "-h"
    system bin/"sl", "-V"
  end
end

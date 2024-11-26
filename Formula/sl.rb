class Sl < Formula
  desc "Prints a steam locomotive if you type sl instead of ls"
  homepage "https://github.com/scaryrawr/sl"
  url "https://github.com/scaryrawr/sl/archive/refs/tags/5.06.1.tar.gz"
  sha256 "62a01863082ab8d660785374ee98e55d4e4199fe6578911e0225cd2a401b2a8e"
  license "MIT"
  head "https://github.com/scaryrawr/sl.git", branch: "main"

  depends_on "cmake" => :build
  depends_on "pkgconf" => :build
  depends_on "ncurses"

  conflicts_with "sapling", because: "both install `sl` binaries"

  def install
    system "cmake", "-S", ".", "-B", "build", *std_cmake_args
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"
  end

  test do
    system bin/"sl", "-c"
  end
end

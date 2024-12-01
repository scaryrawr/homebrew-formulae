class Sl < Formula
  desc "Prints a steam locomotive if you type sl instead of ls"
  homepage "https://github.com/scaryrawr/sl"
  url "https://github.com/scaryrawr/sl/archive/refs/tags/sl-5.07-1.tar.gz"
  sha256 "c9c416b14adbc68e5c9cb6e1328144a2fd2f6c32fad202bc86a46a37e23cab5a"
  license "MIT"
  head "https://github.com/scaryrawr/sl.git", branch: "main"

  depends_on "cmake" => :build
  depends_on "pkgconf" => :build
  depends_on "vcpkg" => :build

  depends_on "ncurses"

  conflicts_with "sapling", because: "both install `sl` binaries"

  def install
    system "git", "clone", "https://github.com/microsoft/vcpkg"
    system(
      "cmake",
      "-S", ".",
      "-B", "build",
      "-D", "CMAKE_TOOLCHAIN_FILE=#{buildpath}/vcpkg/scripts/buildsystems/vcpkg.cmake",
      *std_cmake_args
    )
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"
  end

  test do
    system bin/"sl", "-c"
    system bin/"sl", "-h"
    system bin/"sl", "-v"
  end
end

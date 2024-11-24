class Sl < Formula
  desc "SL(1): Cure your bad habit of mistyping"
  homepage "https://github.com/scaryrawr/sl"
  url "https://github.com/scaryrawr/sl/archive/refs/tags/5.06.1.tar.gz"
  sha256 "62a01863082ab8d660785374ee98e55d4e4199fe6578911e0225cd2a401b2a8e"
  license "https://github.com/scaryrawr/sl/blob/main/LICENSE"
  head "https://github.com/scaryrawr/sl.git", branch: "main"

  depends_on "cmake" => :build

  uses_from_macos "ncurses"

  conflicts_with "sapling", because: "both install `sl` binaries"
  conflicts_with "sl", because: "both install `sl` binaries"

  def install
    system "cmake", "-S", ".", "-B", "build", *std_cmake_args
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"
  end

  test do
    system bin/"sl", "-c"
  end
end

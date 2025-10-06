class Zpiral < Formula
  desc "Configurable Multitouch Gestures for macOS"
  homepage "https://github.com/scaryrawr/zpiral"
  url "https://github.com/scaryrawr/zpiral/archive/refs/tags/0.1.1.tar.gz"
  sha256 "c91a081fc525c5a47b80ad44febad3e7656c6abd419e4d59f15c6b94e7341768"
  license "MIT"
  head "https://github.com/scaryrawr/zpiral.git", branch: "main"

  depends_on "zig" => :build
  depends_on :macos

  def install
    system "zig", "build", *std_zig_args
  end

  service do
    run [opt_bin/"zpiral"]
    keep_alive true
    working_dir var
    log_path var/"log/zpiral.log"
    error_log_path var/"log/zpiral.log"
  end
end

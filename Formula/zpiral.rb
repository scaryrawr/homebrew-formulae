class Zpiral < Formula
  desc "Configurable Multitouch Gestures for macOS"
  homepage "https://github.com/scaryrawr/zpiral"
  url "https://github.com/scaryrawr/zpiral/archive/refs/tags/0.1.0.tar.gz"
  sha256 "2103f3369f4ec6532f9b355ef1e47ee8e415348f4d581f41706481c003781c09"
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

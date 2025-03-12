class Zpiral < Formula
  desc "Configurable Multitouch Gestures for macOS"
  homepage "https://github.com/scaryrawr/zpiral"
  url "https://github.com/scaryrawr/zpiral/archive/refs/tags/0.0.0.tar.gz"
  sha256 "f14f7073aab2c1b88ae519b41805d5541d54fe33b882f9c92436ae63972051cf"
  license "MIT"
  head "https://github.com/scaryrawr/zpiral.git", branch: "main"

  depends_on "zig" => :build

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

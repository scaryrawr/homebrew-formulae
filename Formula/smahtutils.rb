class Smahtutils < Formula
  desc "Small LLM/VLM utilities for local development workflows"
  homepage "https://github.com/scaryrawr/smahtutils"
  url "https://github.com/scaryrawr/smahtutils/archive/refs/tags/v0.1.0.tar.gz"
  sha256 "9ef917690c105009b69d5d1f10b02b2b58988242cc3fbbd5a5850f6260942c6e"
  license :cannot_represent
  head "https://github.com/scaryrawr/smahtutils.git", branch: "main"

  depends_on "rust" => :build
  depends_on "python@3.11"

  def install
    system "python3.11", "-m", "venv", libexec
    ENV.append "LDFLAGS", "-Wl,-headerpad_max_install_names"
    ENV.append "RUSTFLAGS", "-C link-arg=-Wl,-headerpad_max_install_names"
    ENV["PIP_NO_CACHE_DIR"] = "1"
    ENV["PIP_NO_BINARY"] = "annoy,jiter,pydantic-core,rpds-py"
    system libexec/"bin/pip", "install", buildpath

    bin.install_symlink libexec/"bin/smahtiepants"
    bin.install_symlink libexec/"bin/smahties"
    bin.install_symlink libexec/"bin/wickedpaste"
  end

  service do
    run [opt_bin/"smahtiepants", "serve"]
    keep_alive true
    working_dir var
    log_path var/"log/smahtiepants.log"
    error_log_path var/"log/smahtiepants.log"
    environment_variables PATH: std_service_path_env
  end

  test do
    assert_match "smahtiepants", shell_output("#{bin}/smahtiepants --help")
    assert_match "smahties", shell_output("#{bin}/smahties --help")
    assert_match "wickedpaste", shell_output("#{bin}/wickedpaste --help")
  end
end

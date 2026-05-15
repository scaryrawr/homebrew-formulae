class Omlx < Formula
  desc "LLM inference server optimized for Apple Silicon"
  homepage "https://github.com/scaryrawr/omlx"
  license "Apache-2.0"
  head "https://github.com/scaryrawr/omlx.git", branch: "main"

  livecheck do
    skip "Head-only formula"
  end

  depends_on "rust" => :build
  depends_on "python@3.13"
  depends_on :macos
  depends_on arch: :arm64

  service do
    run [opt_bin/"omlx", "serve"]
    keep_alive true
    working_dir var
    log_path var/"log/omlx.log"
    error_log_path var/"log/omlx.log"
    environment_variables PATH: std_service_path_env
  end

  def install
    python = Formula["python@3.13"].opt_bin/"python3.13"

    # Create venv with pip so dependency resolution works properly.
    system python, "-m", "venv", libexec

    # Build Rust-based packages from source with headerpad to prevent
    # Homebrew dylib ID fixup failure (Mach-O header too small for absolute paths).
    # tokenizers is excluded: its wheel ships a stable-ABI .abi3.so that does
    # not need Homebrew's dylib ID rewrite, and building from source can fail on
    # macOS 15+ due to PyO3 linker errors (missing Python symbols at link time).
    ENV.append "LDFLAGS", "-Wl,-headerpad_max_install_names"

    # Install omlx from HEAD with mflux-backed image generation/edit support.
    system libexec/"bin/pip", "install", "--no-binary", "pydantic-core,rpds-py,tiktoken", "#{buildpath}[image]"

    bin.install_symlink libexec/"bin/omlx"
  end

  test do
    system bin/"omlx", "--help"
  end
end

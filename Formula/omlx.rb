class Omlx < Formula
  CUSTOM_KERNELS = %w[bonsai decode_fast glm_moe_dsa minimax_m3 qwen35_prefill].freeze

  desc "LLM inference server optimized for Apple Silicon"
  homepage "https://github.com/scaryrawr/omlx"
  license "Apache-2.0"
  head "https://github.com/scaryrawr/omlx.git", branch: "main"

  option "with-audio", "Install mlx-audio support"
  option "with-custom-kernel",
         "Build native custom kernels for Bonsai, GLM-5.2, MiniMax M3 and Qwen3.5/3.6/4 acceleration"
  option "with-grammar", "Install xgrammar for structured output (requires torch, ~2GB)"

  depends_on "rust" => :build
  depends_on arch: :arm64
  depends_on macos: :sequoia
  # Misaki, required by --with-audio, does not support Python 3.13.
  depends_on "python@3.11"

  # Preserve native libraries in the venv from Homebrew's clean pass. This
  # also avoids macOS 27's `strip` corrupting their Mach-O dynamic offsets
  # (llvm/llvm-project#203678).
  skip_clean "libexec"

  # Fetch source separately so the optional audio install stays pinned.
  resource "mlx-audio" do
    url "https://github.com/Blaizzy/mlx-audio/archive/94c7716212b2228f178d2f9c7619a591fd1b0b78.tar.gz"
    sha256 "7150ba2e58b791399d7aefb81f15d206bd1aa018aa99861f90583cf3d58fd507"
  end

  # Kokoro's English G2P path uses misaki + spaCy. Bundle the spaCy
  # language model so the first TTS request does not download at runtime.
  resource "en-core-web-sm" do
    url "https://github.com/explosion/spacy-models/releases/download/" \
        "en_core_web_sm-3.8.0/en_core_web_sm-3.8.0-py3-none-any.whl"
    sha256 "1932429db727d4bff3deed6b34cfc05df17794f4a52eeb26cf8928f7c1a0fb85"
  end

  service do
    run [opt_bin/"omlx", "serve"]
    keep_alive true
    working_dir var
    log_path var/"log/omlx.log"
    error_log_path var/"log/omlx.log"
    environment_variables PATH: std_service_path_env
  end

  def rewrite_install_name(binary, old_name, new_name)
    return unless File.exist?(binary)
    return unless Utils.safe_popen_read("/usr/bin/otool", "-L", binary).include?(old_name)

    system "/usr/bin/install_name_tool", "-change", old_name, new_name, binary
    system "/usr/bin/codesign", "--force", "--sign", "-", binary
  end

  def rewrite_dylib_id(binary, new_name)
    odie "#{binary} not found" unless File.exist?(binary)
    return unless Utils.safe_popen_read("/usr/bin/otool", "-l", binary).include?("cmd LC_ID_DYLIB")
    return if Utils.safe_popen_read("/usr/bin/otool", "-D", binary).include?(new_name)

    system "/usr/bin/install_name_tool", "-id", new_name, binary
    system "/usr/bin/codesign", "--force", "--sign", "-", binary
  end

  def install
    # Homebrew disables user pip configuration inside formula builds. Forward
    # its supported package-index setting to pip and build-isolation subprocesses.
    ENV["PIP_INDEX_URL"] = ENV["HOMEBREW_PIP_INDEX_URL"] if ENV["HOMEBREW_PIP_INDEX_URL"].present?
    # Homebrew's entry-point environment scrub removes ordinary PIP_* variables.
    ENV["PIP_FIND_LINKS"] = ENV["HOMEBREW_PIP_FIND_LINKS"] if ENV["HOMEBREW_PIP_FIND_LINKS"].present?

    setup_custom_kernels if build.with?("custom-kernel")

    # Create venv with pip so dependency resolution works properly.
    system "python3.11", "-m", "venv", libexec

    # Build native extensions from source with headerpad so Homebrew can
    # rewrite Mach-O install names to absolute Cellar/opt paths. Rust/maturin
    # extension builds (cohere_melody, watchfiles) need the linker flag via
    # RUSTFLAGS; C/C++ extension builds use LDFLAGS. Normally, tokenizers is
    # excluded because its stable-ABI wheel does not need Homebrew's dylib ID
    # rewrite and source builds fail on macOS 15+ due to PyO3 linker errors.
    # macOS 27 requires the source-build exception below.
    ENV.append "LDFLAGS", "-Wl,-headerpad_max_install_names"
    ENV.append "RUSTFLAGS", "-C link-arg=-Wl,-headerpad_max_install_names"
    no_binary = "cohere_melody,nh3,pydantic-core,rpds-py,tiktoken,watchfiles"
    if MacOS.version >= :golden_gate
      # macOS 27's dyld rejects prebuilt Rust wheels whose LINKEDIT string
      # pool is only 4-byte aligned. Build tokenizers locally without strip.
      no_binary += ",tokenizers"
      ENV["CARGO_PROFILE_RELEASE_STRIP"] = "false"
      ENV["MATURIN_STRIP"] = "false"
    end
    ENV["PIP_NO_BINARY"] = no_binary
    ENV["PIP_NO_CACHE_DIR"] = "1"

    extras = []
    extras << "grammar" if build.with?("grammar")
    install_spec = extras.empty? ? buildpath.to_s : "#{buildpath}[#{extras.join(",")}]"
    system libexec/"bin/pip", "install", install_spec

    if build.with?("custom-kernel")
      Dir.chdir(libexec) do
        verify_custom_kernels(libexec/"bin/python")
      end
    end

    # Install mlx-audio from the pinned source revision.
    if build.with?("audio")
      # Mirror the fork's bundle dependency set and install mlx-audio itself
      # without deps so it cannot replace oMLX's pinned engine stack.
      system libexec/"bin/pip", "install",
             "scipy>=1.11.0",
             "librosa>=0.10.0",
             "miniaudio>=1.61",
             "numba>=0.59.0",
             "pyloudnorm>=0.1.0",
             "sounddevice>=0.5.3",
             "misaki>=0.9.4",
             "num2words>=0.5.14",
             "spacy>=3.8.4,<3.9.0",
             "phonemizer-fork>=3.3.2",
             "espeakng-loader>=0.2.4",
             "webrtcvad>=2.0.10",
             "zstandard>=0.23.0",
             "setuptools<81",
             "mistral-common[audio]>=1.10",
             "wsproto==1.2.0"
      resource("mlx-audio").stage do
        system libexec/"bin/pip", "install", "--no-deps", "."
      end

      spacy_model_wheel = buildpath/"en_core_web_sm-3.8.0-py3-none-any.whl"
      cp resource("en-core-web-sm").cached_download, spacy_model_wheel
      system libexec/"bin/pip", "install", "--no-deps", spacy_model_wheel
      system libexec/"bin/python", "-c", "import spacy; spacy.load('en_core_web_sm')"
    end

    system libexec/"bin/pip", "check"

    site_packages = Utils.safe_popen_read(libexec/"bin/python", "-c",
      "import site; print(site.getsitepackages()[0])").chomp
    cohere_ext = Dir["#{site_packages}/cohere_melody/cohere_melody*.so"].first
    odie "cohere_melody extension not found" if cohere_ext.nil?
    rewrite_dylib_id cohere_ext, "#{opt_prefix}/#{Pathname.new(cohere_ext).relative_path_from(prefix)}"
    watchfiles_ext = Dir["#{site_packages}/watchfiles/_rust_notify*.so"].first
    if watchfiles_ext
      rewrite_dylib_id watchfiles_ext, "#{opt_prefix}/#{Pathname.new(watchfiles_ext).relative_path_from(prefix)}"
    end
    rewrite_install_name "#{site_packages}/mlx/lib/libmlx.dylib",
                         "@rpath/libjaccl.dylib",
                         "@loader_path/libjaccl.dylib"
    if build.with?("audio")
      rewrite_install_name "#{site_packages}/numba/np/ufunc/omppool.cpython-311-darwin.so",
                           "@rpath/libomp.dylib",
                           "@loader_path/../../../sklearn/.dylibs/libomp.dylib"
    end

    fixups = []
    fixups << "grammar" if build.with?("grammar")
    fixups << "custom-kernel" if build.with?("custom-kernel")
    (libexec/"post-install-fixups").write fixups.join("\n")
    (libexec/"post-install-custom-kernels").write CUSTOM_KERNELS.join("\n")
    (libexec/"post-install.py").write <<~'PYTHON'
      import glob
      import pathlib
      import re
      import site
      import subprocess
      import sys

      libexec = pathlib.Path(__file__).parent
      enabled = set((libexec / "post-install-fixups").read_text().splitlines())
      site_packages = pathlib.Path(site.getsitepackages()[0])

      def output(*args):
          return subprocess.run(args, check=True, text=True, stdout=subprocess.PIPE).stdout

      if "grammar" in enabled:
          print("Patching xgrammar macOS arm64 wheel")
          import tvm_ffi

          tvmlib = pathlib.Path(tvm_ffi.__file__).parent / "lib"
          dylib = site_packages / "xgrammar/libxgrammar_bindings.dylib"
          dist_dirs = glob.glob(str(site_packages / "xgrammar-*.dist-info"))
          if not dylib.is_file():
              raise RuntimeError(f"xgrammar dylib not found at {dylib}")
          if not dist_dirs:
              raise RuntimeError(f"xgrammar dist-info not found under {site_packages}")

          otool_lines = output("/usr/bin/otool", "-l", dylib).splitlines()
          rpaths = []
          for index, line in enumerate(otool_lines):
              if "cmd LC_RPATH" not in line:
                  continue
              path_line = next(
                  (candidate for candidate in otool_lines[index:] if re.match(r"^\s*path ", candidate)),
                  None,
              )
              if path_line:
                  match = re.match(r"^\s*path (.+?) \(offset \d+\)", path_line)
                  if match:
                      rpaths.append(match.group(1))

          if str(tvmlib) not in rpaths:
              subprocess.run(
                  ["/usr/bin/install_name_tool", "-add_rpath", str(tvmlib), str(dylib)],
                  check=True,
              )
              subprocess.run(["/usr/bin/codesign", "--force", "--sign", "-", str(dylib)], check=True)

          record = pathlib.Path(dist_dirs[0]) / "RECORD"
          contents = record.read_text() if record.exists() else ""
          if "libxgrammar_bindings.dylib" not in contents:
              with record.open("a") as file:
                  if contents and not contents.endswith("\n"):
                      file.write("\n")
                  file.write("xgrammar/libxgrammar_bindings.dylib,,\n")

          subprocess.run([sys.executable, "-c", "import xgrammar"], check=True)

      if "custom-kernel" in enabled:
          print("Adding mlx rpath to custom kernel binaries")
          import mlx.core

          mlx_lib = pathlib.Path(mlx.core.__file__).parent / "lib"
          if not mlx_lib.is_dir():
              raise RuntimeError(f"mlx lib dir not found at {mlx_lib}")
          binaries = [
              *site_packages.glob("omlx/custom_kernels/*/_ext*.so"),
              *site_packages.glob("omlx/custom_kernels/*/lib*_kernel_ops.dylib"),
          ]
          if not binaries:
              raise RuntimeError(f"no custom kernel binaries under {site_packages}/omlx/custom_kernels")

          for binary in binaries:
              if str(mlx_lib) in output("/usr/bin/otool", "-l", binary):
                  continue
              subprocess.run(
                  ["/usr/bin/install_name_tool", "-add_rpath", str(mlx_lib), str(binary)],
                  check=True,
              )
              subprocess.run(["/usr/bin/codesign", "--force", "--sign", "-", str(binary)], check=True)

          custom_kernels = (libexec / "post-install-custom-kernels").read_text().splitlines()
          for package in custom_kernels:
              subprocess.run(
                  [
                      sys.executable,
                      "-c",
                      (
                          f"from omlx.custom_kernels.{package} import fast; "
                          "assert fast.is_native_available(), fast.import_error()"
                      ),
                  ],
                  check=True,
              )
    PYTHON

    bin.install_symlink libexec/"bin/omlx"
  end

  def setup_custom_kernels
    CUSTOM_KERNELS.each do |kernel|
      source = buildpath/"omlx/custom_kernels/#{kernel}/csrc"
      odie "--with-custom-kernel requires #{source}/bindings.cpp" unless (source/"bindings.cpp").file?
      odie "--with-custom-kernel requires Metal sources in #{source}" if source.glob("*.metal").empty?
    end

    odie "--with-custom-kernel requires full Xcode with the Metal toolchain" unless MacOS::Xcode.installed?

    developer_dir = MacOS::Xcode.prefix
    toolchain_bin = buildpath/"homebrew-toolchain"
    toolchain_bin.mkpath
    metal_compiler = toolchain_bin/"metal"
    if quiet_system "/usr/bin/env", "DEVELOPER_DIR=#{developer_dir}",
                    "/usr/bin/xcrun", "-sdk", "macosx", "metal", "-help"
      metal_compiler.write <<~SH
        #!/bin/sh
        exec /usr/bin/env #{("DEVELOPER_DIR=" + developer_dir.to_s).shellescape} /usr/bin/xcrun -sdk macosx metal "$@"
      SH
      chmod 0755, metal_compiler
    else
      # Preserve the mounted Metal toolchain fallback when Xcode's xcrun
      # cannot invoke Metal (for example, after an Xcode update).
      user_home = Dir.home(ENV.fetch("USER"))
      metal = Dir[
        "#{user_home}/Library/Developer/DVTDownloads/MetalToolchain/" \
        "mounts/*/Metal.xctoolchain/usr/bin/metal",
      ].select { |candidate| quiet_system candidate, "-help" }.max_by do |candidate|
        File.mtime(candidate)
      end
      odie "Metal compiler not found; install the Metal toolchain in Xcode Settings > Components" if metal.blank?

      ln_s metal, metal_compiler
    end

    # MLX MetalExtension generates its own CMake files and invokes xcrun
    # by name; adapt only this build instead of patching MLX or its sources.
    (toolchain_bin/"xcrun").write <<~SH
      #!/bin/sh
      if [ "$#" -ge 3 ] && [ "$1" = "-sdk" ] && [ "$2" = "macosx" ] && [ "$3" = "metal" ]; then
        shift 3
        exec #{metal_compiler.to_s.shellescape} "$@"
      fi
      for arg do
        if [ "$arg" = "metal" ]; then
          echo "Unsupported oMLX build xcrun Metal invocation: $*" >&2
          exit 64
        fi
      done
      exec /usr/bin/env #{("DEVELOPER_DIR=" + developer_dir.to_s).shellescape} /usr/bin/xcrun "$@"
    SH
    chmod 0755, toolchain_bin/"xcrun"
    ENV.prepend_path "PATH", toolchain_bin
    ENV["OMLX_WITH_CUSTOM_KERNEL"] = "1"
  end

  # These fixups must run after Homebrew's cleaning pass rewrites Mach-O
  # install names and removes wheel RECORD files.
  post_install_steps do
    if_path_exists "{{libexec}}/post-install.py" do
      run "{{libexec}}/bin/python", args: ["{{libexec}}/post-install.py"], writable_paths: ["{{libexec}}"],
                                print_stdout: true
    end
  end

  def verify_custom_kernels(python)
    system python, "-c", <<~PYTHON
      import importlib
      from pathlib import Path

      libraries = {
          "bonsai": "omlx_bonsai_kernels",
          "decode_fast": "omlx_decode_fast_kernels",
          "glm_moe_dsa": "omlx_glm_kernels",
          "minimax_m3": "omlx_minimax_m3_kernels",
          "qwen35_prefill": "omlx_qwen35_prefill_kernels",
      }
      failed = {}
      for package in #{CUSTOM_KERNELS.inspect}:
          fast = importlib.import_module(f"omlx.custom_kernels.{package}.fast")
          metallib = Path(fast.__file__).parent / f"{libraries[package]}.metallib"
          if not metallib.is_file():
              failed[package] = f"Metal library not found: {metallib}"
          if not fast.is_native_available():
              failed[package] = str(fast.import_error())
      assert not failed, failed
    PYTHON
  end

  test do
    assert_match "serve", shell_output("#{bin}/omlx --help")
    system libexec/"bin/python", "-c", "import sys; assert sys.version_info[:2] == (3, 11)"
    system libexec/"bin/python", "-c", "import importlib.metadata; importlib.metadata.version('omlx')"
    if build.with?("audio")
      system libexec/"bin/python", "-c", "from misaki import en; import spacy; spacy.load('en_core_web_sm')"
    end
    verify_custom_kernels(libexec/"bin/python") if build.with?("custom-kernel")
  end
end

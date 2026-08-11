class Omlx < Formula
  CUSTOM_KERNELS = %w[bonsai glm_moe_dsa minimax_m3 qwen35_prefill].freeze

  desc "LLM inference server optimized for Apple Silicon"
  homepage "https://github.com/scaryrawr/omlx"
  license "Apache-2.0"
  head "https://github.com/scaryrawr/omlx.git", branch: "main"

  option "with-image", "Install mflux-backed image support"
  option "with-audio", "Install mlx-audio support"
  option "with-custom-kernel",
         "Build native custom kernels for Bonsai, GLM-5.2, MiniMax M3 and Qwen3.5/3.6 acceleration"
  option "with-grammar", "Install xgrammar for structured output (requires torch, ~2GB)"

  depends_on "rust" => :build
  depends_on arch: :arm64
  depends_on :macos
  depends_on "python@3.11"

  # Preserve native libraries in the venv from Homebrew's clean pass. This
  # also avoids macOS 27's `strip` corrupting their Mach-O dynamic offsets
  # (llvm/llvm-project#203678).
  skip_clean "libexec"

  # Fetch source separately so the optional audio install stays pinned.
  resource "mlx-audio" do
    url "https://github.com/Blaizzy/mlx-audio/archive/d28d68c6ac4e28f7d2d66007f640b06cf3fd8ceb.tar.gz"
    sha256 "3d9742f7ef8ca7a83fe47c0cffc872c5809a1b8f853fa4457b4fb830cd06d7b4"
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

    # Create venv with pip so dependency resolution works properly.
    system "python3.11", "-m", "venv", libexec

    # Build native extensions from source with headerpad so Homebrew can
    # rewrite Mach-O install names to absolute Cellar/opt paths. Rust/maturin
    # extension builds (cohere_melody, watchfiles) need the linker flag via
    # RUSTFLAGS; C/C++ extension builds use LDFLAGS. tokenizers is excluded:
    # its wheel ships a stable-ABI .abi3.so that does not need Homebrew's
    # dylib ID rewrite, and building from source fails on macOS 15+ due to
    # PyO3 linker errors (missing Python symbols at link time).
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

    if build.with?("custom-kernel")
      kernel_sources = CUSTOM_KERNELS.map do |kernel|
        buildpath/"omlx/custom_kernels/#{kernel}/csrc"
      end
      unless kernel_sources.all?(&:directory?)
        odie "--with-custom-kernel requires oMLX custom kernel sources"
      end

      ENV["OMLX_WITH_CUSTOM_KERNEL"] = "1"
      ENV.append "CMAKE_ARGS", "-DPython_EXECUTABLE=#{libexec}/bin/python"
    end

    extras = []
    extras << "image" if build.with?("image")
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
      # mlx-audio's current metadata conflicts with oMLX's newer transformers
      # pin and omits several runtime dependencies, so mirror the fork's
      # bundle dependency set and install mlx-audio itself without deps.
      system libexec/"bin/pip", "install",
             "scipy>=1.11.0",
             "librosa>=0.10.0",
             "miniaudio>=1.61",
             "numba>=0.59.0",
             "pyloudnorm>=0.1.0",
             "sounddevice>=0.5.3",
             "misaki>=0.9.4",
             "num2words>=0.5.14",
             "spacy>=3.8.4",
             "phonemizer-fork>=3.3.2",
             "espeakng-loader>=0.2.4",
             "webrtcvad>=2.0.10",
             "setuptools<81",
             "mistral-common[audio]>=1.10"
      resource("mlx-audio").stage do
        system libexec/"bin/pip", "install", "--no-deps", "."
      end

      spacy_model_wheel = buildpath/"en_core_web_sm-3.8.0-py3-none-any.whl"
      cp resource("en-core-web-sm").cached_download, spacy_model_wheel
      system libexec/"bin/pip", "install", "--no-deps", spacy_model_wheel
      system libexec/"bin/python", "-c", "import spacy; spacy.load('en_core_web_sm')"
    end

    # python-multipart is declared in omlx's [audio] extra, not in mlx-audio.
    system libexec/"bin/pip", "install", "python-multipart>=0.0.5"

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

    bin.install_symlink libexec/"bin/omlx"
  end

  # Both fixups below must run in post_install because Homebrew's cleaning
  # pass rewrites Mach-O install names and removes wheel RECORD files.
  def post_install
    return if build.without?("grammar") && build.without?("custom-kernel")

    python = libexec/"bin/python"
    site = Utils.safe_popen_read(python, "-c",
                                 "import site; print(site.getsitepackages()[0])").chomp
    patch_xgrammar(python, site) if build.with?("grammar")
    fix_custom_kernel_rpaths(python, site) if build.with?("custom-kernel")
  end

  # Patch the macOS arm64 xgrammar wheel so its native binding loads.
  # The 0.1.32+ wheel ships libxgrammar_bindings.dylib with
  # @rpath/libtvm_ffi.dylib but no LC_RPATH pointing at where tvm_ffi
  # installs its native lib, and the dist-info is missing a RECORD
  # entry for the dylib so tvm_ffi's manifest-based lookup fails.
  # Both manifest as RuntimeError("Cannot find library: ...") at
  # `import xgrammar`, which crashes /admin/api/grammar/parsers and
  # hides the Reasoning Parser dropdown.
  def patch_xgrammar(python, site)
    ohai "Patching xgrammar macOS arm64 wheel"
    tvmlib = Utils.safe_popen_read(python, "-c",
      "import os, tvm_ffi; print(os.path.join(os.path.dirname(tvm_ffi.__file__), 'lib'))").chomp
    dylib = "#{site}/xgrammar/libxgrammar_bindings.dylib"
    dist_dirs = Dir["#{site}/xgrammar-*.dist-info"]

    ohai "  site=#{site}"
    ohai "  tvmlib=#{tvmlib}"
    ohai "  dylib=#{dylib} (exists? #{File.exist?(dylib)})"
    ohai "  dist-info=#{dist_dirs.inspect}"

    odie "xgrammar dylib not found at #{dylib}" unless File.exist?(dylib)
    odie "xgrammar dist-info not found under #{site}" if dist_dirs.empty?

    # Patch 1: add tvm_ffi/lib to the dylib's rpath, then re-codesign so
    # macOS will load the modified dylib.
    otool_lines = Utils.safe_popen_read("/usr/bin/otool", "-l", dylib).lines
    rpaths = []
    otool_lines.each_with_index do |line, index|
      next unless line.include?("cmd LC_RPATH")

      path_line = otool_lines[index..].find { |candidate| candidate.match?(/^\s*path /) }
      rpaths << path_line[/^\s*path (.+?) \(offset \d+\)/, 1] if path_line
    end
    if rpaths.include?(tvmlib)
      ohai "  rpath already points at tvm_ffi/lib"
    else
      ohai "  adding rpath -> #{tvmlib}"
      system "/usr/bin/install_name_tool", "-add_rpath", tvmlib, dylib
      system "/usr/bin/codesign", "--force", "--sign", "-", dylib
    end

    # Patch 2: ensure RECORD lists the dylib so tvm_ffi's manifest-based
    # lookup finds it. Brew's clean pass already deleted every RECORD by
    # the time post_install runs, so we always (re)create one.
    record = "#{dist_dirs.first}/RECORD"
    if File.exist?(record) && File.read(record).include?("libxgrammar_bindings.dylib")
      ohai "  RECORD already lists the dylib"
    else
      ohai "  writing dylib entry to #{record}"
      contents = File.exist?(record) ? File.read(record) : ""
      File.open(record, "a") do |f|
        f.write "\n" if !contents.empty? && !contents.end_with?("\n")
        f.puts "xgrammar/libxgrammar_bindings.dylib,,"
      end
    end

    # Verify the patch took. Failing here is much less confusing than
    # the user discovering it later via a 500 from the admin route.
    ohai "  verifying import xgrammar..."
    system python, "-c", "import xgrammar; print('xgrammar import OK')"
  end

  # Homebrew rewrites libmlx's dylib ID after install, so custom kernels need
  # an rpath to the final mlx library directory added after that clean pass.
  def fix_custom_kernel_rpaths(python, site)
    ohai "Adding mlx rpath to custom kernel binaries"
    mlx_lib = Utils.safe_popen_read(python, "-c",
      "import os, mlx.core; print(os.path.join(os.path.dirname(mlx.core.__file__), 'lib'))").chomp
    odie "mlx lib dir not found at #{mlx_lib}" unless File.directory?(mlx_lib)
    binaries = Dir["#{site}/omlx/custom_kernels/*/{_ext*.so,lib*_kernel_ops.dylib}"]
    odie "no custom kernel binaries under #{site}/omlx/custom_kernels" if binaries.empty?

    binaries.each do |binary|
      if Utils.safe_popen_read("/usr/bin/otool", "-l", binary).include?(mlx_lib)
        ohai "  #{File.basename(binary)}: mlx rpath already present"
        next
      end

      ohai "  adding rpath to #{File.basename(binary)}"
      system "/usr/bin/install_name_tool", "-add_rpath", mlx_lib, binary
      system "/usr/bin/codesign", "--force", "--sign", "-", binary
    end

    ohai "  verifying custom kernel imports..."
    verify_custom_kernels(python)
  end

  def verify_custom_kernels(python)
    system python, "-c", <<~PYTHON
      import importlib
      failed = {}
      for package in #{CUSTOM_KERNELS.inspect}:
          fast = importlib.import_module(f"omlx.custom_kernels.{package}.fast")
          if not fast.is_native_available():
              failed[package] = str(fast.import_error())
      assert not failed, failed
    PYTHON
  end

  test do
    assert_match "serve", shell_output("#{bin}/omlx --help")
    system libexec/"bin/python", "-c", "import importlib.metadata; importlib.metadata.version('omlx')"
    system libexec/"bin/python", "-c", "import spacy; spacy.load('en_core_web_sm')" if build.with?("audio")
    verify_custom_kernels(libexec/"bin/python") if build.with?("custom-kernel")
  end
end

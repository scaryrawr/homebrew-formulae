class Omlx < Formula
  desc "LLM inference server optimized for Apple Silicon"
  homepage "https://github.com/scaryrawr/omlx"
  license "Apache-2.0"
  head "https://github.com/scaryrawr/omlx.git", branch: "main"

  option "with-image", "Install mflux-backed image support"
  option "with-audio", "Install mlx-audio support"
  option "with-grammar", "Install xgrammar for structured output (requires torch, ~2GB)"

  depends_on "rust" => :build
  depends_on arch: :arm64
  depends_on :macos
  depends_on "python@3.11"

  # Fetch source separately so the optional audio install stays pinned.
  resource "mlx-audio" do
    url "https://github.com/Blaizzy/mlx-audio/archive/a7ef98604cfd752e9e5c9011bcee8ec8c67228be.tar.gz"
    sha256 "9c3ccf98e7714cc2f0fc6802a311e6f9f1078102195a77e0404ff026f06be78d"
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
    ENV["PIP_NO_BINARY"] = "cohere_melody,nh3,pydantic-core,rpds-py,tiktoken,watchfiles"
    ENV["PIP_NO_CACHE_DIR"] = "1"

    extras = []
    extras << "image" if build.with?("image")
    extras << "grammar" if build.with?("grammar")
    install_spec = extras.empty? ? buildpath.to_s : "#{buildpath}[#{extras.join(",")}]"
    system libexec/"bin/pip", "install", install_spec

    # Install mlx-audio from the pinned source revision.
    if build.with?("audio")
      resource("mlx-audio").stage do
        system libexec/"bin/pip", "install", ".[all]"
      end
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

  # Patch the macOS arm64 xgrammar wheel so its native binding loads.
  # The 0.1.32+ wheel ships libxgrammar_bindings.dylib with
  # @rpath/libtvm_ffi.dylib but no LC_RPATH pointing at where tvm_ffi
  # installs its native lib, and the dist-info is missing a RECORD
  # entry for the dylib so tvm_ffi's manifest-based lookup fails.
  # Both manifest as RuntimeError("Cannot find library: ...") at
  # `import xgrammar`, which crashes /admin/api/grammar/parsers and
  # hides the Reasoning Parser dropdown.
  #
  # Runs in post_install rather than install because Homebrew's
  # post-install "Cleaning" step deletes every dist-info/RECORD file
  # in the keg as part of its relocation pass (RECORD hashes become
  # invalid once brew rewrites Mach-O install names). Anything we
  # write to RECORD inside `def install` is wiped before the user
  # sees it.
  def post_install
    return if build.without?("grammar")

    ohai "Patching xgrammar macOS arm64 wheel"
    py = libexec/"bin/python"
    site = Utils.safe_popen_read(py, "-c",
                                 "import site; print(site.getsitepackages()[0])").chomp
    tvmlib = Utils.safe_popen_read(py, "-c",
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
    system py, "-c", "import xgrammar; print('xgrammar import OK')"
  end

  test do
    assert_match "serve", shell_output("#{bin}/omlx --help")
    system libexec/"bin/python", "-c", "import importlib.metadata; importlib.metadata.version('omlx')"
  end
end

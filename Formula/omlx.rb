class Omlx < Formula
  desc "LLM inference server optimized for Apple Silicon"
  homepage "https://github.com/scaryrawr/omlx"
  url "https://github.com/scaryrawr/omlx/archive/de7f78d49d7cf54b076e87dbf68e3736bf5d5d6f.tar.gz"
  version "0.3.9.dev2"
  sha256 "f0aea2ca2d0a99005c1e10e7ce5a55978c0ef2764edc68e4cd8e2ef50fb60e0a"
  license "Apache-2.0"
  head "https://github.com/scaryrawr/omlx.git", branch: "main"

  livecheck do
    skip "Uses a pinned commit tarball"
  end

  option "with-image", "Install mflux-backed image support"
  option "with-audio", "Install mlx-audio support"
  option "with-grammar", "Install xgrammar for structured output (requires torch, ~2GB)"

  depends_on "rust" => :build
  depends_on arch: :arm64
  depends_on :macos
  depends_on "python@3.11"

  # mlx-audio pins mlx-lm==0.31.1 which conflicts with omlx's git-pinned
  # mlx-lm. Fetch source separately so we can patch the pin before install.
  resource "mlx-audio" do
    url "https://github.com/Blaizzy/mlx-audio/archive/51753266e0a4f766fd5e6fbc46652224efc23981.tar.gz"
    sha256 "7f9297a18f4cfa8a30efde3ba0056b87dfbb5d64747591eef5ff44333f9a19ef"
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

  def install
    # Create venv with pip so dependency resolution works properly.
    system "python3.11", "-m", "venv", libexec

    # Build Rust-based packages from source with headerpad to prevent
    # Homebrew dylib ID fixup failure (Mach-O header too small for absolute paths).
    # tokenizers is excluded: its wheel ships a stable-ABI .abi3.so that does
    # not need Homebrew's dylib ID rewrite, and building from source fails on
    # macOS 15+ due to PyO3 linker errors (missing Python symbols at link time).
    ENV.append "LDFLAGS", "-Wl,-headerpad_max_install_names"
    ENV.append "RUSTFLAGS", "-C link-args=-Wl,-headerpad_max_install_names"
    ENV["PIP_NO_BINARY"] = "nh3,pydantic-core,rpds-py,tiktoken"

    extras = []
    extras << "image" if build.with?("image")
    extras << "grammar" if build.with?("grammar")
    install_spec = extras.empty? ? buildpath.to_s : "#{buildpath}[#{extras.join(",")}]"
    system libexec/"bin/pip", "install", install_spec

    # Install mlx-audio with patched mlx-lm pin to avoid version conflict.
    if build.with?("audio")
      resource("mlx-audio").stage do
        inreplace "pyproject.toml", /"mlx-lm==[\d.]+"/, '"mlx-lm>=0.31.1"'
        inreplace "pyproject.toml", /"misaki>=[\d.]+"/, '"misaki>=0.7.4"'
        system libexec/"bin/pip", "install", ".[all]"
      end
    end

    # python-multipart is declared in omlx's [audio] extra, not in mlx-audio.
    system libexec/"bin/pip", "install", "python-multipart>=0.0.5"

    site_packages = Utils.safe_popen_read(libexec/"bin/python", "-c",
      "import site; print(site.getsitepackages()[0])").chomp
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

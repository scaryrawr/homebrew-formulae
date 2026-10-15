require "fileutils"
require "json"
require "pathname"
require "shellwords"

class Object
  def blank?
    respond_to?(:empty?) ? empty? : !self
  end

  def present?
    !blank?
  end
end

class << ENV
  def append(key, value)
    self[key] = [self[key], value].compact.join(" ")
  end

  def prepend_path(key, value)
    self[key] = "#{value}#{File::PATH_SEPARATOR}#{self[key]}"
  end
end

class Pathname
  def install_symlink(source)
    mkpath
    FileUtils.ln_s(source, self / source.basename)
  end
end

module MacOS
  def self.version
    Object.new.tap do |version|
      def version.>=(other)
        true
      end
    end
  end

  module Xcode
    def self.installed?
      ENV["TEST_XCODE"] != "missing"
    end

    def self.prefix
      Pathname.new("/Applications/Xcode.app/Contents/Developer")
    end
  end
end

module Utils
  def self.safe_popen_read(*args)
    return "#{ENV.fetch('TEST_ROOT')}/prefix/libexec/site-packages\n" if args.include?("-c")

    ""
  end
end

class Formula
  def self.test(&block); end

  def self.method_missing(name, *args)
    # Ignore Homebrew's declarative DSL; execute the formula's real methods.
  end

  include FileUtils

  attr_reader :commands

  def initialize
    @commands = []
  end

  def buildpath
    Pathname.new(ENV.fetch("TEST_ROOT")) / "source"
  end

  def prefix
    Pathname.new(ENV.fetch("TEST_ROOT")) / "prefix"
  end

  def libexec
    prefix / "libexec"
  end

  def opt_prefix
    prefix
  end

  def bin
    prefix / "bin"
  end

  def build
    self
  end

  def with?(option)
    ENV.fetch("TEST_OPTIONS", "").split(",").include?(option)
  end

  def odie(message)
    raise message
  end

  def quiet_system(*args)
    return false if ENV["TEST_COMPILER"] == "missing"

    args.first != "/usr/bin/env" || ENV["TEST_COMPILER"] != "fallback"
  end

  def inreplace(path, old, replacement)
    path.write(path.read.gsub(old, replacement))
  end

  def system(*args)
    @commands << args.map(&:to_s)
    return unless args[1..2] == ["-m", "venv"]

    libexec.mkpath
    site = libexec / "site-packages/cohere_melody"
    site.mkpath
    (site / "cohere_melody.so").write("")
  end

  def resource(name)
    root = Pathname.new(ENV.fetch("TEST_ROOT"))
    Object.new.tap do |resource|
      resource.define_singleton_method(:cached_download) { root / "model.whl" }
      resource.define_singleton_method(:stage) do |&block|
        Dir.chdir(root, &block)
      end
    end
  end
end

if $PROGRAM_NAME == __FILE__
  class << Dir
    def home(user = nil)
      ENV.fetch("TEST_ROOT") + "/home"
    end
  end
  load ARGV.fetch(0)
  formula = Omlx.new
  begin
    formula.public_send(ARGV.fetch(1, "install"))
    puts JSON.generate(commands: formula.commands, path: ENV["PATH"],
                       custom_kernel: ENV["OMLX_WITH_CUSTOM_KERNEL"],
                       cmake_args: ENV["CMAKE_ARGS"],
                       pip_index: ENV["PIP_INDEX_URL"],
                       pip_find_links: ENV["PIP_FIND_LINKS"])
  rescue StandardError => e
    warn JSON.generate(error: e.message, commands: formula.commands)
    exit 1
  end
end

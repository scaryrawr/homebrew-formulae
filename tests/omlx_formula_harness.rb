# typed: strict
# frozen_string_literal: true

require "fileutils"
require "json"
require "shellwords"

autoload :Pathname, "pathname"

# Runs the real formula methods without an installed Homebrew tap.
module OmlxFormulaHarness
  # Supplies the Homebrew presence predicates used by formula methods.
  module ObjectExtensions
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

  # Keeps formula bin links inside the fixture prefix.
  module PathExtensions
    def install_symlink(source)
      mkpath
      FileUtils.ln_s(source, self / source.basename)
    end
  end

  # Models macOS build metadata independently of the host operating system.
  module MacOS
    def self.version
      Object.new.tap do |version|
        version.define_singleton_method(:>=) { |_other| true }
      end
    end

    # Allows real-toolchain tests to select their actual developer directory.
    module Xcode
      def self.installed?
        ENV["TEST_XCODE"] != "missing"
      end

      def self.prefix
        Pathname.new(ENV.fetch("TEST_DEVELOPER_DIR", "/Applications/Xcode.app/Contents/Developer"))
      end
    end
  end

  # Returns fixture paths instead of invoking installed Homebrew utilities.
  module Utils
    def self.safe_popen_read(*args)
      return "#{ENV.fetch("TEST_ROOT")}/prefix/libexec/site-packages\n" if args.include?("-c")

      ""
    end
  end

  # Records install commands while retaining the formula's own control flow.
  class Formula
    [:desc, :homepage, :license, :head, :option, :depends_on, :skip_clean, :resource, :service, :post_install_steps,
     :test].each do |name|
      define_singleton_method(name) { |*_args| nil }
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

    def compiler_available?(*args)
      return false if ENV["TEST_COMPILER"] == "missing"

      args.first != "/usr/bin/env" || ENV["TEST_COMPILER"] != "fallback"
    end

    alias quiet_system compiler_available?

    def inreplace(path, old, replacement)
      path.write(path.read.gsub(old, replacement))
    end

    def system(*args)
      @commands << args.map(&:to_s)
      return if args[1..2] != ["-m", "venv"]

      libexec.mkpath
      site = libexec / "site-packages/cohere_melody"
      site.mkpath
      (site / "cohere_melody.so").write("")
    end

    def resource(_name)
      root = Pathname.new(ENV.fetch("TEST_ROOT"))
      Object.new.tap do |resource|
        resource.define_singleton_method(:cached_download) { root / "model.whl" }
        resource.define_singleton_method(:stage) do |&block|
          Dir.chdir(root, &block)
        end
      end
    end
  end
end

Object.class_eval do
  include OmlxFormulaHarness::ObjectExtensions
end
Pathname.include(OmlxFormulaHarness::PathExtensions)
Object.const_set(:MacOS, OmlxFormulaHarness::MacOS)
Object.const_set(:Utils, OmlxFormulaHarness::Utils)
Object.const_set(:Formula, OmlxFormulaHarness::Formula)

if $PROGRAM_NAME == __FILE__
  class << Dir
    def home(_user = nil)
      "#{ENV.fetch("TEST_ROOT")}/home"
    end
  end
  load ARGV.fetch(0)
  formula = Omlx.new
  begin
    formula.public_send(ARGV.fetch(1, "install"))
    puts JSON.generate(commands: formula.commands, path: ENV.fetch("PATH", nil),
                       custom_kernel: ENV.fetch("OMLX_WITH_CUSTOM_KERNEL", nil),
                       cmake_args: ENV.fetch("CMAKE_ARGS", nil),
                       pip_index: ENV.fetch("PIP_INDEX_URL", nil),
                       pip_find_links: ENV.fetch("PIP_FIND_LINKS", nil))
  rescue => e
    warn JSON.generate(error: e.message, commands: formula.commands)
    exit 1
  end
end

class Opencode < Formula
  desc "AI coding agent built for the terminal"
  homepage "https://github.com/scaryrawr/opencode"
  version "0.3.20"

  on_macos do
    if Hardware::CPU.intel?
      url "https://github.com/scaryrawr/opencode/releases/download/r0.3.20/opencode-darwin-x64.tar.gz"
      sha256 "89f667f46ac7ffe59a9107d68be30802cec19bc7bd8cca8e316c675bff55050a"
    end
    if Hardware::CPU.arm?
      url "https://github.com/scaryrawr/opencode/releases/download/r0.3.20/opencode-darwin-arm64.tar.gz"
      sha256 "dcdd0e7754f13892a499af96439e12c103c77b25b1466dcfcaec4d210ba88710"
    end
  end

  on_linux do
    if Hardware::CPU.intel? && Hardware::CPU.is_64_bit?
      url "https://github.com/scaryrawr/opencode/releases/download/r0.3.20/opencode-linux-x64.tar.gz"
      sha256 "1424c16075f21635e8ed695efef797b4c5a2cab806ad6004a14a6e0346960683"
    end
    if Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
      url "https://github.com/scaryrawr/opencode/releases/download/r0.3.20/opencode-linux-arm64.tar.gz"
      sha256 "6cbe574600755cfe2410aababf44d2b4b63dee8e8fe502fe51301b95cf89a5f1"
    end
  end

  def install
    bin.install "bin/opencode"
  end
end

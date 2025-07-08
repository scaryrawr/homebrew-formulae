class Opencode < Formula
  desc "AI coding agent built for the terminal"
  homepage "https://github.com/scaryrawr/opencode"
  version "0.2.6-1"

  on_macos do
    if Hardware::CPU.intel?
      url "https://github.com/scaryrawr/opencode/releases/download/r0.2.6-1/opencode-darwin-x64.tar.gz"
      sha256 "3f83227e214b42754392b87951b13901e167cad04919debf1a47b527c4307b31"
    end
    if Hardware::CPU.arm?
      url "https://github.com/scaryrawr/opencode/releases/download/r0.2.6-1/opencode-darwin-arm64.tar.gz"
      sha256 "7bb5f2ef6ffba2397b0dbf29794c78e1e4a6324d6c674ad0367d7acf29a01a9c"
    end
  end

  on_linux do
    if Hardware::CPU.intel? && Hardware::CPU.is_64_bit?
      url "https://github.com/scaryrawr/opencode/releases/download/r0.2.6-1/opencode-linux-x64.tar.gz"
      sha256 "428af089a011aa26ede1b4030a137b3344f1a90286f81a9c2981a586ef43adf3"
    end
    if Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
      url "https://github.com/scaryrawr/opencode/releases/download/r0.2.6-1/opencode-linux-arm64.tar.gz"
      sha256 "650e68395645345518b211d4b20704f334860bd1dac382450cf23024470d6ae3"
    end
  end

  def install
    bin.install "bin/opencode"
  end
end

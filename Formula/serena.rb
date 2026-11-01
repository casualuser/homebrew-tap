class Serena < Formula
  desc "Semantic coding MCP toolkit with Astro language server support (w0m beta branch)"
  homepage "https://github.com/webomage/serena"
  url "https://github.com/webomage/serena.git", branch: "beta"
  version "2.1.1-w0m"
  license "GPL-3.0-or-later"

  head "https://github.com/webomage/serena.git", branch: "beta"

  depends_on "rust" => :build
  depends_on "python@3.12"

  skip_clean "libexec"

  def install
    system "python3.12", "-m", "venv", libexec
    system libexec/"bin/pip", "install", "--upgrade", "pip", "setuptools", "wheel", "hatchling"
    system libexec/"bin/pip", "install", buildpath
    bin.install_symlink libexec/"bin/serena"
    bin.install_symlink libexec/"bin/serena-agent"
    bin.install_symlink libexec/"bin/serena-hooks"
  end

  def post_install
    system "find", libexec, "-type", "f", "(", "-name", "*.so", "-o", "-name", "*.dylib", ")", "-exec", "codesign", "--force", "--sign", "-", "{}", "+"
  end

  test do
    assert_match "serena", shell_output("#{bin}/serena --help")
  end
end

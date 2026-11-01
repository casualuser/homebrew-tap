class Graphify < Formula
  desc "AST & semantic knowledge graph builder with global status/sync (w0m beta branch)"
  homepage "https://github.com/webomage/graphify"
  url "https://github.com/webomage/graphify.git", branch: "beta"
  version "0.9.100-w0m"
  license "Apache-2.0"

  head "https://github.com/webomage/graphify.git", branch: "beta"

  depends_on "rust" => :build
  depends_on "python@3.12"

  skip_clean "libexec"

  def install
    system "python3.12", "-m", "venv", libexec
    system libexec/"bin/pip", "install", "--upgrade", "pip", "setuptools", "wheel"
    system libexec/"bin/pip", "install", "#{buildpath}[mcp,sql]"
    bin.install_symlink libexec/"bin/graphify"
    bin.install_symlink libexec/"bin/graphify-mcp"
  end

  def post_install
    system "find", libexec, "-type", "f", "(", "-name", "*.so", "-o", "-name", "*.dylib", ")", "-exec", "codesign", "--force", "--sign", "-", "{}", "+"
  end

  test do
    assert_match "graphify", shell_output("#{bin}/graphify --help")
  end
end

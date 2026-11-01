class LayaMlx < Formula
  desc "Native MLX inference for Laya typed decision models on Apple Silicon (w0m beta)"
  homepage "https://github.com/webomage/laya-mlx"
  url "https://github.com/webomage/laya-mlx.git", branch: "beta"
  version "0.6.0-w0m"
  license "Apache-2.0"

  head "https://github.com/webomage/laya-mlx.git", branch: "beta"

  depends_on "rust" => :build
  depends_on arch: :arm64
  depends_on "python@3.12"

  skip_clean "libexec"

  def install
    system "python3.12", "-m", "venv", libexec
    system libexec/"bin/pip", "install", "--upgrade", "pip", "setuptools", "wheel", "hatchling"
    system libexec/"bin/pip", "install", "#{buildpath}[serve,mcp,structured]"
    Dir[libexec/"bin/laya-*"].each do |script|
      bin.install_symlink script
    end
  end

  def post_install
    system "find", libexec, "-type", "f", "(", "-name", "*.so", "-o", "-name", "*.dylib", ")", "-exec", "codesign", "--force", "--sign", "-", "{}", "+"
  end

  test do
    assert_match "laya", shell_output("#{bin}/laya-mlx --help")
  end
end

class MlxVlm < Formula
  desc "Vision & Omni Language Models on Apple Silicon MLX with TurboQuant dim512 guard (w0m beta)"
  homepage "https://github.com/webomage/mlx-vlm"
  url "https://github.com/webomage/mlx-vlm.git", branch: "beta"
  version "0.7.11-w0m"
  license "MIT"

  head "https://github.com/webomage/mlx-vlm.git", branch: "beta"

  depends_on "rust" => :build
  depends_on arch: :arm64
  depends_on "python@3.12"

  skip_clean "libexec"

  def install
    system "python3.12", "-m", "venv", libexec
    system libexec/"bin/pip", "install", "--upgrade", "pip", "setuptools", "wheel"
    system libexec/"bin/pip", "install", buildpath
    Dir[libexec/"bin/mlx_vlm*"].each do |script|
      bin.install_symlink script
    end
  end

  def post_install
    system "find", libexec, "-type", "f", "(", "-name", "*.so", "-o", "-name", "*.dylib", ")", "-exec", "codesign", "--force", "--sign", "-", "{}", "+"
  end

  test do
    system libexec/"bin/python", "-c", "import mlx_vlm; print(mlx_vlm.__version__)"
  end
end

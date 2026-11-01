class Omlx < Formula
  desc "LLM inference server optimized for Apple Silicon (w0m beta branch)"
  homepage "https://github.com/webomage/omlx"
  url "https://github.com/webomage/omlx.git", branch: "beta"
  version "0.7.3-w0m"
  license "Apache-2.0"

  head "https://github.com/webomage/omlx.git", branch: "beta"

  depends_on "rust" => :build
  depends_on arch: :arm64
  depends_on macos: :sequoia
  depends_on "python@3.12"

  skip_clean "libexec"

  resource "en-core-web-sm" do
    url "https://github.com/explosion/spacy-models/releases/download/" \
        "en_core_web_sm-3.8.0/en_core_web_sm-3.8.0-py3-none-any.whl"
    sha256 "1932429db727d4bff3deed6b34cfc05df17794f4a52eeb26cf8928f7c1a0fb85"
  end

  service do
    run [opt_bin/"omlx", "serve"]
    keep_alive true
    working_dir var
    log_path var/"log/omlx.log"
    error_log_path var/"log/omlx.log"
    environment_variables PATH: std_service_path_env,
                          OMLX_SUPERVISED: "launchd"
  end

  def install
    system "python3.12", "-m", "venv", libexec
    system libexec/"bin/pip", "install", "--upgrade", "pip", "setuptools", "wheel"
    system libexec/"bin/pip", "install", "#{buildpath}[audio]"

    spacy_model_wheel = buildpath/"en_core_web_sm-3.8.0-py3-none-any.whl"
    cp resource("en-core-web-sm").cached_download, spacy_model_wheel
    system libexec/"bin/pip", "install", "--no-deps", spacy_model_wheel

    bin.install_symlink Dir[libexec/"bin/omlx"]
  end

  def post_install
    system "find", libexec, "-type", "f", "(", "-name", "*.so", "-o", "-name", "*.dylib", ")", "-exec", "codesign", "--force", "--sign", "-", "{}", "+"
  end

  test do
    assert_match "0.7", shell_output("#{bin}/omlx --version")
  end
end

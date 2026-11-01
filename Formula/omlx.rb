class Omlx < Formula
  desc "LLM inference server optimized for Apple Silicon (w0m beta branch)"
  homepage "https://github.com/webomage/omlx"
  url "https://github.com/webomage/omlx.git", branch: "beta"
  version "0.7.3-w0m"
  license "Apache-2.0"

  head "https://github.com/webomage/omlx.git", branch: "beta"

  option "with-custom-kernel",
         "Build native custom kernels for Bonsai, GLM-5.2, MiniMax M3 and Qwen3.5/3.6/4 acceleration"
  option "with-grammar", "Install xgrammar for structured output (requires torch, ~2GB)"

  depends_on "rust" => :build
  depends_on arch: :arm64
  depends_on macos: :sequoia
  depends_on "python@3.11"

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
    system "python3.11", "-m", "venv", libexec

    ENV.append "LDFLAGS", "-Wl,-headerpad_max_install_names"
    ENV.append "RUSTFLAGS", "-C link-arg=-Wl,-headerpad_max_install_names"

    no_binary = "cohere_melody,pydantic-core,rpds-py,tiktoken,tokenizers"
    ENV["CARGO_PROFILE_RELEASE_STRIP"] = "false"
    ENV["MATURIN_STRIP"] = "false"
    pip_flags = ["--no-cache-dir"]

    pip_install = [libexec/"bin/pip", "install", *pip_flags, "--no-binary", no_binary]

    install_spec = build.with?("grammar") ? "#{buildpath}[audio,grammar]" : "#{buildpath}[audio]"
    system(*pip_install, install_spec)

    spacy_model_wheel = buildpath/"en_core_web_sm-3.8.0-py3-none-any.whl"
    cp resource("en-core-web-sm").cached_download, spacy_model_wheel
    system libexec/"bin/pip", "install", "--no-deps", spacy_model_wheel
    system libexec/"bin/python", "-c", "import spacy; spacy.load('en_core_web_sm')"

    bin.install_symlink Dir[libexec/"bin/omlx"]
  end

  def post_install
    system "find", libexec, "-type", "f", "(", "-name", "*.so", "-o", "-name", "*.dylib", ")", "-exec", "codesign", "--force", "--sign", "-", "{}", "+"
  end

  test do
    assert_match "0.7", shell_output("#{bin}/omlx --version")
  end
end

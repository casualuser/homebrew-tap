class Headroom < Formula
  desc "Context Optimization Layer for LLM Applications (w0m unified multi-upstream)"
  homepage "https://headroom-docs.vercel.app"
  url "https://github.com/casualuser/headroom.git", branch: "main"
  version "0.37.0-w0m"
  license "Apache-2.0"

  head "https://github.com/casualuser/headroom.git", branch: "main"

  livecheck do
    url "https://api.github.com/repos/headroomlabs-ai/headroom/releases/latest"
    regex(/v?(\d+(?:\.\d+)+)/i)
  end

  depends_on "python@3.12"

  def install
    system "python3.12", "-m", "venv", libexec
    system libexec/"bin/pip", "install", "--upgrade", "pip", "setuptools", "wheel"
    system libexec/"bin/pip", "install", "#{buildpath}[all]"
    bin.install_symlink libexec/"bin/headroom"
  end

  def post_install
    (var/"headroom").mkpath
    (var/"log").mkpath
    # Enforce restrictive loopback-only service permissions (0700 for var, 0600 for logs)
    chmod 0700, var/"headroom"
  end

  service do
    run [
      opt_bin/"headroom", "proxy",
      "--host", "127.0.0.1",
      "--port", "8787",
      "--mode", "cache",
      "--backend", "anthropic",
      "--no-telemetry"
    ]
    keep_alive true
    working_dir var/"headroom"
    log_path var/"log/headroom.log"
    error_log_path var/"log/headroom.log"
    environment_variables PATH: std_service_path_env,
                          HEADROOM_TELEMETRY: "off",
                          OMLX_TARGET_API_URL: "http://127.0.0.1:8888"
  end

  test do
    assert_match "headroom, version", shell_output("#{bin}/headroom --version")
  end
end

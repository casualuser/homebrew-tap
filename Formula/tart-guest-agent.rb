class TartGuestAgent < Formula
  desc "Guest agent for Tart VMs with multi-format clipboard, SPICE filexfer & tray (w0m beta)"
  homepage "https://github.com/webomage/tart-guest-agent"
  url "https://github.com/webomage/tart-guest-agent.git", branch: "beta"
  version "0.15.0-w0m"
  license "Apache-2.0"

  head "https://github.com/webomage/tart-guest-agent.git", branch: "beta"

  depends_on "go" => :build
  depends_on :macos

  def install
    ldflags = %W[
      -s -w
      -X github.com/cirruslabs/tart-guest-agent/internal/version.Version=#{version}
    ]
    ENV["CGO_ENABLED"] = "1"
    system "go", "build", *std_go_args(ldflags:, output: bin/"tart-guest-agent"), "./cmd/main.go"
  end

  def post_install
    system "codesign", "--force", "--sign", "-", "--identifier", "tart-guest-agent", bin/"tart-guest-agent"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/tart-guest-agent --version")
  end
end

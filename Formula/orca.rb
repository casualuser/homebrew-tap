class Orca < Formula
  desc "Orca multi-agent IDE & CLI with ZeroClaw, OFM, deep-links & collaboration locks (w0m beta)"
  homepage "https://github.com/webomage/orca"
  url "https://github.com/webomage/orca.git", branch: "beta"
  version "1.4.245-w0m"
  license "Apache-2.0"

  head "https://github.com/webomage/orca.git", branch: "beta"

  depends_on "node"
  depends_on "pnpm" => :build

  skip_clean "libexec"

  def install
    ENV["CSC_IDENTITY_AUTO_DISCOVERY"] = "false"
    system "pnpm", "install", "--frozen-lockfile"
    system "pnpm", "run", "build:packages"
    system "node", "config/scripts/build-cli.mjs"
    system "node", "config/scripts/verify-cli-bin.mjs", "--fix-executable", "--fix-package-json"
    libexec.install "out/cli", "out/shared", "out/package.json"
    (bin/"orca-w0m").write <<~EOS
      #!/bin/bash
      exec "#{Formula["node"].opt_bin}/node" "#{libexec}/cli/index.js" "$@"
    EOS
    chmod 0755, bin/"orca-w0m"
  end

  test do
    assert_match "orca", shell_output("#{bin}/orca-w0m --help")
  end
end

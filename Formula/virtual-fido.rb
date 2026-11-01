class VirtualFido < Formula
  desc "Virtual FIDO2/CTAP2 USB & VHID security key with air-gapped vault CLI (w0m beta)"
  homepage "https://github.com/webomage/virtual-fido"
  url "https://github.com/webomage/virtual-fido.git", branch: "beta"
  version "0.2.0-w0m"
  license "MIT"

  head "https://github.com/webomage/virtual-fido.git", branch: "beta"

  depends_on "go" => :build
  depends_on :macos

  skip_clean "libexec"

  def install
    system "bash", "transport/vhid/HIDVirtualDevice/build.sh"
    (libexec/"lib").install Dir["transport/vhid/output/*.dylib"]
    ENV["CGO_ENABLED"] = "1"
    system "go", "build", "-tags", "hidvirtual", "-o", libexec/"bin/virtual-fido", "./cmd/virtual-fido"
    system "install_name_tool", "-add_rpath", opt_libexec/"lib", libexec/"bin/virtual-fido"
    bin.install_symlink libexec/"bin/virtual-fido"
  end

  def post_install
    Dir[libexec/"lib/*.dylib"].each do |dylib|
      system "codesign", "--force", "--sign", "-", dylib
    end
    system "codesign", "--force", "--sign", "-", libexec/"bin/virtual-fido"
  end

  test do
    assert_match "virtual-fido", shell_output("#{bin}/virtual-fido --help")
  end
end

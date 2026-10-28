class Tzap < Formula
  desc "Create, list, verify, and extract encrypted recoverable tzap archives"
  homepage "https://github.com/tzap-org/tzap"
  version "0.2.7"
  license "Apache-2.0"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/tzap-org/tzap/releases/download/v0.2.7/tzap-v0.2.7-macos-aarch64.tar.gz"
      sha256 "ecadcc746b588f2d12ab6ab3885e3be294d640375ff0aacbc5cfd486ece4ce64"
    else
      url "https://github.com/tzap-org/tzap/releases/download/v0.2.7/tzap-v0.2.7-macos-x86_64.tar.gz"
      sha256 "d69c7734bb81655cc78833fa91bcf91a9533dc4fb4634db1587b63e5b0e9925f"
    end
  end

  on_linux do
    if Hardware::CPU.intel?
      url "https://github.com/tzap-org/tzap/releases/download/v0.2.7/tzap-v0.2.7-linux-x86_64-musl.tar.gz"
      sha256 "47ef0c4d4d32d665aedb1b09d9d62415705e9a48f4974ee3c3b23613c9f40be1"
    else
      url "https://github.com/tzap-org/tzap/releases/download/v0.2.7/tzap-v0.2.7-linux-aarch64-musl.tar.gz"
      sha256 "c55124a666cb71f0e6a3cec53ca28180e97b385684122cc8cbf683958cae0b39"
    end
  end

  def install
    bin.install "tzap"
  end

  test do
    assert_match "tzap 0.2.7", shell_output("#{bin}/tzap --version")

    (testpath/"input.txt").write "homebrew smoke payload\n"
    archive = testpath/"smoke.tzap"
    outdir = testpath/"out"
    passphrase = "homebrew-smoke-passphrase\n"

    pipe_output(
      "#{bin}/tzap create --password-stdin --argon2-t-cost 1 --argon2-m-cost-kib 8 "       "--argon2-parallelism 1 -o #{archive} #{testpath}/input.txt",
      passphrase,
      0
    )

    assert_match(
      "input.txt",
      pipe_output("#{bin}/tzap list --password-stdin #{archive}", passphrase, 0)
    )

    pipe_output(
      "#{bin}/tzap verify --password-stdin #{archive}",
      passphrase,
      0
    )

    outdir.mkpath

    pipe_output(
      "#{bin}/tzap extract --password-stdin --directory #{outdir} #{archive} input.txt",
      passphrase,
      0
    )

    assert_equal "homebrew smoke payload\n", (outdir/"input.txt").read
  end
end

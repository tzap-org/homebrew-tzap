class Tzap < Formula
  desc "Create, list, verify, and extract encrypted recoverable tzap archives"
  homepage "https://github.com/tzap-org/tzap"
  version "0.2.0"
  license "Apache-2.0"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/tzap-org/tzap/releases/download/v#{version}/tzap-v#{version}-macos-aarch64.tar.gz"
      sha256 "ca7afaadc09a0f5f94e3019f996c8972fe08c0bd0fe12c9e1e757fe353091c38"
    else
      url "https://github.com/tzap-org/tzap/releases/download/v#{version}/tzap-v#{version}-macos-x86_64.tar.gz"
      sha256 "9cbae1e56b3c1b18331fb079bb0409a163ee67d30924ec6435c5739fd2fbfa91"
    end
  end

  on_linux do
    if Hardware::CPU.intel?
      url "https://github.com/tzap-org/tzap/releases/download/v#{version}/tzap-v#{version}-linux-x86_64-musl.tar.gz"
      sha256 "4d32474339916fb75f8f93082f174f9f5bffd543fad02fbf24c653491eba693c"
    else
      url "https://github.com/tzap-org/tzap/releases/download/v#{version}/tzap-v#{version}-linux-aarch64-musl.tar.gz"
      sha256 "173d6d336f7cbef437860779d04a6ff85b26e2daa3701ea686fae71d4b64e2fd"
    end
  end

  def install
    bin.install "tzap"
  end

  test do
    assert_match "tzap #{version}", shell_output("#{bin}/tzap --version")

    (testpath/"input.txt").write "homebrew smoke payload\n"
    archive = testpath/"smoke.tzap"
    outdir = testpath/"out"
    passphrase = "homebrew-smoke-passphrase\n"

    pipe_output(
      "#{bin}/tzap create --password-stdin --argon2-t-cost 1 --argon2-m-cost-kib 8 " \
      "--argon2-parallelism 1 -o #{archive} #{testpath/"input.txt"}",
      passphrase,
      0,
    )
    assert_match "input.txt", pipe_output("#{bin}/tzap list --password-stdin #{archive}", passphrase, 0)
    pipe_output("#{bin}/tzap verify --password-stdin #{archive}", passphrase, 0)
    pipe_output("#{bin}/tzap extract --password-stdin --directory #{outdir} #{archive} input.txt", passphrase, 0)
    assert_equal "homebrew smoke payload\n", (outdir/"input.txt").read
  end
end

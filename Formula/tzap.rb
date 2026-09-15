class Tzap < Formula
  desc "Create, list, verify, and extract encrypted recoverable tzap archives"
  homepage "https://github.com/tzap-org/tzap"
  version "0.2.5"
  license "Apache-2.0"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/tzap-org/tzap/releases/download/v0.2.5/tzap-v0.2.5-macos-aarch64.tar.gz"
      sha256 "4cf40c0e4618f495726c7598a172d8db07c969b9623b53c798b9f042577002eb"
    else
      url "https://github.com/tzap-org/tzap/releases/download/v0.2.5/tzap-v0.2.5-macos-x86_64.tar.gz"
      sha256 "0e894104d5609feac31f07f7011f2b923aa7702f01511ddb6f615d04ce3a5dd6"
    end
  end

  on_linux do
    if Hardware::CPU.intel?
      url "https://github.com/tzap-org/tzap/releases/download/v0.2.5/tzap-v0.2.5-linux-x86_64-musl.tar.gz"
      sha256 "3aadb177e0f8eff1e279e7049a13fdaf0c7e0f1a42550b3e4f7cc7973c1f296b"
    else
      url "https://github.com/tzap-org/tzap/releases/download/v0.2.5/tzap-v0.2.5-linux-aarch64-musl.tar.gz"
      sha256 "134f5409b539d2511fef6e2a7d478dd1faac94cd3c390fcae8190f85d7b5d0fb"
    end
  end

  def install
    bin.install "tzap"
  end

  test do
    assert_match "tzap 0.2.5", shell_output("#{bin}/tzap --version")

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

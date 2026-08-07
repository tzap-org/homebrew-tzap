class Tzap < Formula
  desc "Create, list, verify, and extract encrypted recoverable tzap archives"
  homepage "https://github.com/tzap-org/tzap"
  version "0.2.1"
  license "Apache-2.0"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/tzap-org/tzap/releases/download/v0.2.1/tzap-v0.2.1-macos-aarch64.tar.gz"
      sha256 "afb0120683ff133a00c49bc6b8e2167b6e6fd88506864dd318bf88d563aa4c92"
    else
      url "https://github.com/tzap-org/tzap/releases/download/v0.2.1/tzap-v0.2.1-macos-x86_64.tar.gz"
      sha256 "f876739905cee1d4717464c4adecbdd0c764694b4cdc26485d715b0a0f901e85"
    end
  end

  on_linux do
    if Hardware::CPU.intel?
      url "https://github.com/tzap-org/tzap/releases/download/v0.2.1/tzap-v0.2.1-linux-x86_64-musl.tar.gz"
      sha256 "b0d22cb55cbd6cca3718f88b7aa6db3e0b52a0e1a706e6e5c6c06a652df5a0dd"
    else
      url "https://github.com/tzap-org/tzap/releases/download/v0.2.1/tzap-v0.2.1-linux-aarch64-musl.tar.gz"
      sha256 "38b8d1d160e91d438579723edf7b29d61a69c30677b41e016228d0b2c605c78b"
    end
  end

  def install
    bin.install "tzap"
  end

  test do
    assert_match "tzap 0.2.1", shell_output("#{bin}/tzap --version")

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

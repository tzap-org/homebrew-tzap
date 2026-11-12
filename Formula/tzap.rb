class Tzap < Formula
  desc "Create, list, verify, and extract encrypted recoverable tzap archives"
  homepage "https://github.com/tzap-org/tzap"
  version "0.2.8"
  license "Apache-2.0"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/tzap-org/tzap/releases/download/v0.2.8/tzap-v0.2.8-macos-aarch64.tar.gz"
      sha256 "ad80f8a60aef87ab3fdaaff2835fc1d27eb64a933d91ec9d08315f014dbb5f62"
    else
      url "https://github.com/tzap-org/tzap/releases/download/v0.2.8/tzap-v0.2.8-macos-x86_64.tar.gz"
      sha256 "337f63c65c26350bcf1f4019c45635335ba35f4c11810c34f5349a95a418be7b"
    end
  end

  on_linux do
    if Hardware::CPU.intel?
      url "https://github.com/tzap-org/tzap/releases/download/v0.2.8/tzap-v0.2.8-linux-x86_64-musl.tar.gz"
      sha256 "a9b7210cef525ba757ebc5103415131ea52bb31fdc08572ebc08fb7034380f70"
    else
      url "https://github.com/tzap-org/tzap/releases/download/v0.2.8/tzap-v0.2.8-linux-aarch64-musl.tar.gz"
      sha256 "ba013755a606033db0943047445a805e51c0a263076beba0c76a06ae9b6f0ea8"
    end
  end

  def install
    bin.install "tzap"
  end

  test do
    assert_match "tzap 0.2.8", shell_output("#{bin}/tzap --version")

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

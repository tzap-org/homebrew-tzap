class Tzap < Formula
  desc "Create, list, verify, and extract encrypted recoverable tzap archives"
  homepage "https://github.com/tzap-org/tzap"
  version "0.2.4"
  license "Apache-2.0"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/tzap-org/tzap/releases/download/v0.2.4/tzap-v0.2.4-macos-aarch64.tar.gz"
      sha256 "6b2240e5841387c306df58ceca67e5f1fe98b6a2444330695a53423b85b18dd9"
    else
      url "https://github.com/tzap-org/tzap/releases/download/v0.2.4/tzap-v0.2.4-macos-x86_64.tar.gz"
      sha256 "070a4b0d8f92115f326f71475875589010ceec4177fff72b8f6e4092cdeeb190"
    end
  end

  on_linux do
    if Hardware::CPU.intel?
      url "https://github.com/tzap-org/tzap/releases/download/v0.2.4/tzap-v0.2.4-linux-x86_64-musl.tar.gz"
      sha256 "070d57d1770973f6b1e56489444fc21f02fd8c748e60af149ad67608c5dea19a"
    else
      url "https://github.com/tzap-org/tzap/releases/download/v0.2.4/tzap-v0.2.4-linux-aarch64-musl.tar.gz"
      sha256 "84003640ac48e825d8040cc349fc2510d0379b0acba1840e3a3bcda4298c505d"
    end
  end

  def install
    bin.install "tzap"
  end

  test do
    assert_match "tzap 0.2.4", shell_output("#{bin}/tzap --version")

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

class Tzap < Formula
  desc "Create, list, verify, and extract encrypted recoverable tzap archives"
  homepage "https://github.com/tzap-org/tzap"
  version "0.2.9"
  license "Apache-2.0"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/tzap-org/tzap/releases/download/v0.2.9/tzap-v0.2.9-macos-aarch64.tar.gz"
      sha256 "9155edf071bdda97cbe47b1e32cf8f79d879b6c92aee5fa7b7e3878169a9a95f"
    else
      url "https://github.com/tzap-org/tzap/releases/download/v0.2.9/tzap-v0.2.9-macos-x86_64.tar.gz"
      sha256 "df647f98d378afe9b418a0b72d31a67934b9bcfb6b94ba1da24efbe2c6eff176"
    end
  end

  on_linux do
    if Hardware::CPU.intel?
      url "https://github.com/tzap-org/tzap/releases/download/v0.2.9/tzap-v0.2.9-linux-x86_64-musl.tar.gz"
      sha256 "003b833ef16e98181436d7b7e4b2f40211c24f5e864109b70e6b7862c0deaa8b"
    else
      url "https://github.com/tzap-org/tzap/releases/download/v0.2.9/tzap-v0.2.9-linux-aarch64-musl.tar.gz"
      sha256 "cd21c7bec9d350b162498be13028ec29213d84e2b10a8efa310f3ee2eacfdd07"
    end
  end

  def install
    bin.install "tzap"
    doc.install "OPENSSL-LICENSE.txt", "THIRD-PARTY-NOTICES.txt" if File.exist?("THIRD-PARTY-NOTICES.txt")
  end

  test do
    assert_match "tzap 0.2.9", shell_output("#{bin}/tzap --version")

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

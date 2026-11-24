class Tzap < Formula
  desc "Create, list, verify, and extract encrypted recoverable tzap archives"
  homepage "https://github.com/tzap-org/tzap"
  version "0.3.0"
  license "Apache-2.0"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/tzap-org/tzap/releases/download/v0.3.0/tzap-v0.3.0-macos-aarch64.tar.gz"
      sha256 "36b1a7f03ad3a9b908ce7ea82679e7c3d27e59b0a48a69e7147b176be389bda3"
    else
      url "https://github.com/tzap-org/tzap/releases/download/v0.3.0/tzap-v0.3.0-macos-x86_64.tar.gz"
      sha256 "5d99d2a88e87fb9300a36323f30bb43d55d7e90a5d0879185207df62e3ccc2b8"
    end
  end

  on_linux do
    if Hardware::CPU.intel?
      url "https://github.com/tzap-org/tzap/releases/download/v0.3.0/tzap-v0.3.0-linux-x86_64-musl.tar.gz"
      sha256 "05a55c12a3f19880c2b8dfafd21144f362785d935bafad4a33998ad7c28cc469"
    else
      url "https://github.com/tzap-org/tzap/releases/download/v0.3.0/tzap-v0.3.0-linux-aarch64-musl.tar.gz"
      sha256 "5ca8b3e3e00f3860398a36d09de7115330e5c83de219ab9db27edd363562087a"
    end
  end

  def install
    bin.install "tzap"
    doc.install "OPENSSL-LICENSE.txt", "THIRD-PARTY-NOTICES.txt" if File.exist?("THIRD-PARTY-NOTICES.txt")
  end

  test do
    assert_match "tzap 0.3.0", shell_output("#{bin}/tzap --version")

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

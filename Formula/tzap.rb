class Tzap < Formula
  desc "Create, list, verify, and extract encrypted recoverable tzap archives"
  homepage "https://github.com/tzap-org/tzap"
  version "0.2.3"
  license "Apache-2.0"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/tzap-org/tzap/releases/download/v0.2.3/tzap-v0.2.3-macos-aarch64.tar.gz"
      sha256 "f0f15dc2c28f123cac794ba5f28a2c34d808c4fa234c4abc8468593ed51d48c6"
    else
      url "https://github.com/tzap-org/tzap/releases/download/v0.2.3/tzap-v0.2.3-macos-x86_64.tar.gz"
      sha256 "a5be8f9492e93ce4a9440cb30e1bd6defd14a5d52917623840d58b9285adc1e4"
    end
  end

  on_linux do
    if Hardware::CPU.intel?
      url "https://github.com/tzap-org/tzap/releases/download/v0.2.3/tzap-v0.2.3-linux-x86_64-musl.tar.gz"
      sha256 "0ef9db8323dfa14795b35e4ba17fd38597ec0216ecd79d8f41783c43ae5125b2"
    else
      url "https://github.com/tzap-org/tzap/releases/download/v0.2.3/tzap-v0.2.3-linux-aarch64-musl.tar.gz"
      sha256 "55638a5577f37b4f8559b2bc8e015bfafecfc0690a51eeb9e3f583a10959f82d"
    end
  end

  def install
    bin.install "tzap"
  end

  test do
    assert_match "tzap 0.2.3", shell_output("#{bin}/tzap --version")

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

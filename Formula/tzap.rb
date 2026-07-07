class Tzap < Formula
  desc "Create, list, verify, and extract encrypted recoverable tzap archives"
  homepage "https://github.com/tzap-org/tzap"
  version "0.1.10"
  license "Apache-2.0"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/tzap-org/tzap/releases/download/v#{version}/tzap-v#{version}-macos-aarch64.tar.gz"
      sha256 "076ed59f2a78822ab6ee993f4377f9d556194c6959b2c12ffdf566b5f522c34a"
    else
      url "https://github.com/tzap-org/tzap/releases/download/v#{version}/tzap-v#{version}-macos-x86_64.tar.gz"
      sha256 "95f7b6cdb859508380708ad3a38ac385e18b57dfc410e03c22c7bad912f21218"
    end
  end

  on_linux do
    if Hardware::CPU.intel?
      url "https://github.com/tzap-org/tzap/releases/download/v#{version}/tzap-v#{version}-linux-x86_64-musl.tar.gz"
      sha256 "e463be439a62fdbed7b8cb2d578cd0c1d7320c380de68cc2936e6ac613187d85"
    else
      url "https://github.com/tzap-org/tzap/releases/download/v#{version}/tzap-v#{version}-linux-aarch64-musl.tar.gz"
      sha256 "1123c66c77d53ac4f26f9f260a352d91b83c5ea16fe885338e7e11db73b32985"
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

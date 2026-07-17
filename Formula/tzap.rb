class Tzap < Formula
  desc "Create, list, verify, and extract encrypted recoverable tzap archives"
  homepage "https://github.com/tzap-org/tzap"
  version "0.1.11"
  license "Apache-2.0"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/tzap-org/tzap/releases/download/v#{version}/tzap-v#{version}-macos-aarch64.tar.gz"
      sha256 "a00672bf7667bb8731b33f6190c8da27ad5ae08e015c2f79cb5d8a55efe02ebf"
    else
      url "https://github.com/tzap-org/tzap/releases/download/v#{version}/tzap-v#{version}-macos-x86_64.tar.gz"
      sha256 "0023d55b4fd6deea8dd3c583ffe2445a62ae9eff5aadfb20d7d309a7ab8922ca"
    end
  end

  on_linux do
    if Hardware::CPU.intel?
      url "https://github.com/tzap-org/tzap/releases/download/v#{version}/tzap-v#{version}-linux-x86_64-musl.tar.gz"
      sha256 "d68d5dee383af054ff412c6a089ed9ca0d60702d1ea1bc4438838d9526bd581a"
    else
      url "https://github.com/tzap-org/tzap/releases/download/v#{version}/tzap-v#{version}-linux-aarch64-musl.tar.gz"
      sha256 "37912f4cb582d17e12a38e21753eb4b93429e8a1ae3e4eec096af71b9e1033e1"
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

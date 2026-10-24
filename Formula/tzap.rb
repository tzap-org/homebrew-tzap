class Tzap < Formula
  desc "Create, list, verify, and extract encrypted recoverable tzap archives"
  homepage "https://github.com/tzap-org/tzap"
  version "0.2.6"
  license "Apache-2.0"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/tzap-org/tzap/releases/download/v0.2.6/tzap-v0.2.6-macos-aarch64.tar.gz"
      sha256 "7996aa21cffeaf64e526b6e858726bd1cb9de7b7c9dbdf69e830adcbb19042b0"
    else
      url "https://github.com/tzap-org/tzap/releases/download/v0.2.6/tzap-v0.2.6-macos-x86_64.tar.gz"
      sha256 "bd7bedfa773b6a55f100dde54da6fb8b7376318ccee726b81eef597110c54149"
    end
  end

  on_linux do
    if Hardware::CPU.intel?
      url "https://github.com/tzap-org/tzap/releases/download/v0.2.6/tzap-v0.2.6-linux-x86_64-musl.tar.gz"
      sha256 "c217d301aa7aefb3c65c2f39f030310eae245285f21735f1d2871743f946117a"
    else
      url "https://github.com/tzap-org/tzap/releases/download/v0.2.6/tzap-v0.2.6-linux-aarch64-musl.tar.gz"
      sha256 "4ea69ce363d85a4c73391bb60864b6040228f85d81c7429c4afcaa921d2736d2"
    end
  end

  def install
    bin.install "tzap"
  end

  test do
    assert_match "tzap 0.2.6", shell_output("#{bin}/tzap --version")

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

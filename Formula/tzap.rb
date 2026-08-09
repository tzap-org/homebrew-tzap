class Tzap < Formula
  desc "Create, list, verify, and extract encrypted recoverable tzap archives"
  homepage "https://github.com/tzap-org/tzap"
  version "0.2.2"
  license "Apache-2.0"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/tzap-org/tzap/releases/download/v0.2.2/tzap-v0.2.2-macos-aarch64.tar.gz"
      sha256 "a9cd7bc18ecfee60ff2525b03d0ba78ab26324197d9e31a1e0fb8d791643e5b0"
    else
      url "https://github.com/tzap-org/tzap/releases/download/v0.2.2/tzap-v0.2.2-macos-x86_64.tar.gz"
      sha256 "c486334a1c38cf986de5a5a5803eacf647f0ea08a74db84815a1270bd35ef6c4"
    end
  end

  on_linux do
    if Hardware::CPU.intel?
      url "https://github.com/tzap-org/tzap/releases/download/v0.2.2/tzap-v0.2.2-linux-x86_64-musl.tar.gz"
      sha256 "ff0fb361243577990a788ea93db4bb66dd429be17d0acbc84d9d3f3726bdeb78"
    else
      url "https://github.com/tzap-org/tzap/releases/download/v0.2.2/tzap-v0.2.2-linux-aarch64-musl.tar.gz"
      sha256 "2530a2728eb6d5a13d8b82ffa4ac6e78c6767c0fef66d63661263eda6df542ae"
    end
  end

  def install
    bin.install "tzap"
  end

  test do
    assert_match "tzap 0.2.2", shell_output("#{bin}/tzap --version")

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

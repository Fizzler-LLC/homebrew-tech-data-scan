# homebrew-itartools/Formula/itar-scan.rb
class ItarScan < Formula
  desc     "CLI scanner that detects ITAR-controlled source with a local LLM"
  homepage "https://github.com/Fizzler-LLC/homebrew-tech-data-scan-public"
  version  "0.1.0"
  license  "MIT"                           # ← or whatever license your code uses

  # ─── Binary + LoRA (PyInstaller output) ──────────────────────────
  on_macos do
    if Hardware::CPU.arm?
      url     "https://github.com/brianfrechette3/tech-data-scan-public/releases/download/v0.1.2/itar-scan-macos-arm64.tar.gz"
      sha256  "4bd08c2255adf63f29b30a1b64f2823ce3c13b95114a4fbe405ac5c3e5d6c7ed"
    else
      url     "https://github.com/brianfrechette3/tech-data-scan-public/releases/download/v0.1.2/itar-scan-macos-arm64.tar.gz"
      sha256  "X86_64_SHA"
    end
  end

  # on_linux do
  #   if Hardware::CPU.intel?
  #     url     "https://github.com/yourorg/itar-scan/releases/download/v0.3.0/itarscan-linux-amd64.tar.gz"
  #     sha256  "LINUX_AMD64_SHA"
  #   else
  #     url     "https://github.com/yourorg/itar-scan/releases/download/v0.3.0/itarscan-linux-arm64.tar.gz"
  #     sha256  "LINUX_ARM64_SHA"
  #   end
  # end

  # ─── Resource: base Phi-3 GGUF from Hugging Face ─────────────────
  resource "phi3-base-model" do
    url     "https://huggingface.co/microsoft/Phi-3-mini-4k-instruct-gguf/resolve/main/Phi-3-mini-4k-instruct-q4.gguf"
    sha256  "8a83c7fb9049a9b2e92266fa7ad04933bb53aa1e85136b7b30f1b8000ff2edef"
  end

  # No runtime dependencies: everything needed is baked into the PyInstaller binary.
  # If your code *imports* other shared libs at runtime, declare them here.


  def install
    libexec.install "itar-scan"            # one-dir bundle
    bin.install_symlink libexec/"itar-scan" => "itar-scan"
    (libexec/"models").mkpath
    resource("phi3-base-model").stage { cp_r Dir["*"], libexec/"models" }
  end
  

  def caveats
    <<~EOS
      A pre-quantised Phi-3 model (© Microsoft, MIT licence) was downloaded
      under its own terms from HuggingFace.  If you need to update or
      replace it you can remove:
          #{libexec}/models/Phi-3-mini-4k-instruct-q4.gguf
      and reinstall this formula.
    EOS
  end

  test do
    # The LLM initialisation is expensive; a simple flag is enough to prove the binary works.
    assert_match "Usage:", shell_output("#{bin}/itar-scan --help")
  end
end

class Sfs < Formula
  desc "Solon Product SFS runtime for AI-native product work"
  homepage "https://github.com/MJ-0701/solon-product"

  # AC7.4 — 0.6.0 release. sha256 placeholder is materialized by scripts/cut-release.sh
  # at release-cut time (see AC11 release sequence: tag-push → audit → tap-update).
  url "https://github.com/MJ-0701/solon-product/archive/refs/tags/v0.6.0.tar.gz"
  sha256 "__SHA256_PLACEHOLDER_FOR_RELEASE_CUT__"
  version "0.6.0"

  livecheck do
    url :stable
    regex(/v([\d.]+)\.tar\.gz/i)
    strategy :github_latest
  end

  def install
    libexec.install Dir["*"]
    (bin/"sfs").write <<~SH
      #!/bin/bash
      export SFS_DIST_DIR="#{libexec}"
      exec "#{libexec}/bin/sfs" "$@"
    SH
    chmod 0755, bin/"sfs"
  end

  def post_install
    # 0.5.96-product slash-command zero-file discovery hook.
    # Registers /sfs (Claude Code), sfs (Gemini CLI), $sfs (Codex CLI) under
    # one umbrella — idempotent + graceful (D7=b: failure does not abort).
    hook = libexec/"scripts/install-cli-discovery.sh"
    if hook.exist?
      ENV["SFS_DISCOVERY_SOURCE_DIR"] = libexec.to_s
      system "bash", hook.to_s
      ENV.delete("SFS_DISCOVERY_SOURCE_DIR")
    else
      opoo "cli-discovery hook not found at #{hook} — slash-command discovery skipped"
    end
  end

  def caveats
    <<~EOS
      First-time project setup:
        cd /path/to/your-project
        sfs init --yes
        sfs status
        sfs guide

      Homebrew installs the global sfs CLI. Run `sfs init --yes` once inside
      each project where you want Solon files, state, and agent adapters.
      Later, run `sfs upgrade` inside a project; it self-upgrades the Homebrew
      runtime first, then updates that project's Solon files.

      0.6.0 storage migration:
        sfs upgrade --opt-in 0.6-storage   # migrate 0.5.x sprints to 0.6 schema
      Hard cut: 2026-11-03 (after that, `sfs upgrade` migrates 0.5.x by default).

      Beginner guide:
        https://github.com/MJ-0701/solon-product/blob/main/BEGINNER-GUIDE.md
    EOS
  end

  test do
    system "#{bin}/sfs", "--help"
  end
end

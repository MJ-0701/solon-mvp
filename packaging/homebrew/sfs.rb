# typed: false
# frozen_string_literal: true

# Homebrew formula for the Solon Product SFS global CLI runtime.
class Sfs < Formula
  desc "Solon Product SFS runtime for AI-native product work"
  homepage "https://github.com/MJ-0701/solon-product"

  # AC7.4 — release artifact. version + sha256 placeholders are materialized by
  # scripts/cut-release.sh at release-cut time (see AC11 release sequence:
  # tag-push → audit → tap-update). 0.6.5 hotfix: components order corrected
  # (version before sha256) and livecheck regex broadened (\.t matches both
  # \.tar\.gz and \.tgz mirrors) to satisfy `brew style`.
  url "https://github.com/MJ-0701/solon-product/archive/refs/tags/v0.6.9.tar.gz"
  version "0.6.9"
  sha256 "__SHA256_PLACEHOLDER_FOR_RELEASE_CUT__"

  livecheck do
    url :stable
    regex(/v([\d.]+)\.t/i)
    strategy :github_latest
  end

  def install
    libexec.install Dir["*"]
    libexec.install %w[.gitattributes .gitignore .github .claude-plugin].select { |path| File.exist?(path) }
    (bin/"sfs").write <<~SH
      #!/bin/bash
      export SFS_DIST_DIR="#{libexec}"
      exec "#{libexec}/bin/sfs" "$@"
    SH
    chmod 0755, bin/"sfs"
  end

  def caveats
    <<~EOS
      First-time project setup:
        cd /path/to/your-project
        sfs init --yes
        sfs status
        sfs guide

      Homebrew installs the global sfs CLI. Run `sfs init --yes` once inside
      each project where you want Solon files and state. Project-local
      command/skill adapters are optional: `sfs agent install all`.
      Later, run `sfs upgrade` inside a project; it self-upgrades the Homebrew
      runtime first, then updates that project's Solon files.

      Legacy 0.5.x storage migration:
        sfs upgrade --opt-in 0.6-storage   # migrate 0.5.x sprints to 0.6 schema
      Hard cut: 2026-11-03 (after that, `sfs upgrade` migrates 0.5.x by default).

      Beginner guide:
        https://github.com/MJ-0701/solon-product/blob/main/BEGINNER-GUIDE.md
    EOS
  end

  test do
    system bin/"sfs", "--help"
  end
end

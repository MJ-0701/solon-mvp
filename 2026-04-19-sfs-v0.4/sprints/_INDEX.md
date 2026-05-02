---
doc_id: sprints-index
title: "sprints/ — WU (Work Unit) 파일 목록 (v2)"
visibility: raw-internal
updated: 2026-05-02   # WU-37 완료: /sfs implement 를 code-only 가 아닌 division-aware execution contract 로 확장.
---

# sprints/ — WU 파일 인덱스

> **역할**: WU 파일 (`WU-<id>.md`) SSoT. WU 정의는 `CLAUDE.md §2.1` 참조.
> **진입**: `PROGRESS.md` → `current_wu_path` 로 해당 WU 파일 직행.
> **규율**: 1 파일 ≤ 200 line 기본 (~300 유연), 초과 시 `WU-<id>/` 디렉토리로 sub-step 분리.

---

## 활성 WU (status: in_progress / pending)

| WU | title | status | opened | session_opened | path |
|:--:|:---|:--:|:---|:---|:---|
| — | — | — | — | — | — |

> **24th 세션 결과 (사이클 31번째)**: WU-30 close. 24th 31번째 user-active-deferred run `sleepy-exciting-pasteur` (2026-04-27T21:55+09:00, 사용자 운동 부재 자율 위임 1시간+) — D-C-WU-30 row 5~8 4 micro-step 일괄 진행. row 5 (README.md 3 위치 minimal: 포함 파일 + 스크립트 사용 §A/§B 분리 + Changelog dev-pending entry, WU22-D9 (b) 두 검증기 분리 인용 + cross-call false-positive 경고) → row 6 (dry-run sandbox `/tmp/wu30-row6-dry-$$/` 4 smoke 전부 의도된 결과 PASS — T1 A✕vw0 exit=0 / T2 B✕vinstall exit=0 + 4WARN / **T3 B✕vw0 exit=1 FAIL (WU-21 §F-04(a) verbatim 재현, 분리 결정 정당성 입증)** / **T4 A✕vinstall exit=1 FAIL (산출물 책임 영역 분리 입증)**) → row 7 (WU-30 frontmatter close = status=done + closed_at + final_sha=9fbd999e62f771f1c2dcc2fb14b093c5e5f0e1ec placeholder, WU-24.1 dd30cde 패턴 정합) → row 8 (sprints/_INDEX 활성→완료 이동 + 본 frontmatter `updated` 갱신). row 9 (commit) = 사용자 manual. **WU-30 + WU-31 + WU-21 final_sha 3건 동시 backfill 권장** (release cut 0.3.0-mvp blocker 해소). 다음 priority order = D-D-meta-logs forward (idx=4, P-08-fuse-bypass-cp-a-broken audit-only — file 이미 23rd 사고 직후 신설, learning-logs/_INDEX.md row 추가 필요) > D-D reverse (idx=5, P-09-sandbox-file-clone-isolation 신설) > D-E-meta-retro forward 11th~23rd > D-E reverse > D-F-meta-handoff.

> **24th 세션 결과 (사이클 24~25번째)**: WU-31 close. row 4 (`wizardly-sleepy-brown` 04:33 KST, cut-release.sh 351L 9 smoke) → row 5 (`eager-stoic-pasteur` 05:18 KST, sync-stable-to-dev.sh 335L 10 smoke) → row 6 (`great-kind-turing` 06:11 KST, check-drift.sh 240L 11 smoke) → row 7 (`fervent-sweet-hamilton` 08:54 KST, .visibility-rules.yaml 12→16 + enforcement_active=true) → row 8 (`trusting-funny-volta` 09:03 KST, scripts/_README.md 275L) → row 9 (`nifty-wizardly-bardeen` 09:18 KST, dry-run sandbox 통합 검증 9 smoke + 운영 3 path 재현 + WU-21 final_sha=TBD 잔존 발견) → row 10 (`pensive-exciting-keller` 09:30 KST, WU-31 frontmatter close = status=done + closed_at + final_sha=9fbd999e62f771f1c2dcc2fb14b093c5e5f0e1ec placeholder) → row 11 (`jolly-festive-ramanujan` 10:08~12 KST, sprints/_INDEX 활성→완료 이동 + 본 frontmatter `updated` 2026-04-27 갱신 = 본 row). row 12 (commit) = 사용자 manual. **WU-31 final_sha + WU-21 final_sha=TBD_18TH_COMMIT** 둘 다 사용자 manual commit 후 placeholder 동시 backfill 권장 (release cut 0.3.0-mvp blocker 해소). 다음 priority order = D-D-meta-logs forward P-04 > D-D reverse > D-E-meta-retro forward 11th~23rd > D-E reverse > D-F-meta-handoff > D-C-WU-30 row 5~9 (user-active-only).
> **24th 세션 결과 (사이클 11~12번째)**: WU-24 close. row 11 (`friendly-serene-galileo` 10:13 KST, dry-run sandbox + install.sh gap fix) → row 12 (`great-dazzling-babbage` 10:24 KST 사용자 user-active conversation, frontmatter close status=done) → row 13 (`happy-pensive-davinci` 11:08 KST scheduled run, sprints/_INDEX 갱신 = 본 row). row 14 (commit) = 사용자 manual. WU-24 final_sha 는 사용자 manual commit 후 placeholder backfill (§1.5' 정합). 다음 priority = D-B-WU-31 row 4 (cut-release.sh, cross-dep `D-A.next_step >= 6` 충족 = 9 ≥ 6) 또는 D-C-WU-30 row 1.
> **23rd 세션 결과**: 사용자 결정 = 배포 자동화 옵션 β (로컬 sh 우선, GitHub Action 후속) + 명시 "계획만 만들어 둬" → **WU-31 신설 (frontmatter + spec only)**. 실 bash 3 sh + `.visibility-rules.yaml` 갱신은 다음 세션 또는 사용자 컨펌 후. Phase 1+2 (GitHub Action drift 알림 / tag trigger) 는 후속 WU-32 / WU-33 예약.
> **22nd 세션 결과**: WU-23 §7 사용자 결정 7항목 일괄 resolved (WU22-D3~D9). WU-24 = (당시) current_wu, WU-30 = 신설 (frontmatter + 작업 plan, 실 fix 다음 세션 또는 사용자 컨펌 후).

## 완료 WU (status: done) — v2 네이티브

| WU | title | final_sha | opened | closed | session | path |
|:--:|:---|:---|:---|:---|:---|:---|
| WU-15 | Workflow v2 인프라 설정 | `aa0a354` | 2026-04-21 | 2026-04-21 | relaxed-vibrant-albattani | [WU-15.md](WU-15.md) |
| WU-15.1 | WU-15 sha backfill + README §11.1 glossary | `acfae03` | 2026-04-21 | 2026-04-21 | relaxed-vibrant-albattani | [WU-15.md](WU-15.md) (refresh 전용) |
| WU-16 | 기존 WU (WU-7 ~ WU-14.1) 이관 + sessions/ 3 retrospective | `2b8b69e` | 2026-04-24 | 2026-04-24 | brave-hopeful-euler | [WU-16.md](WU-16.md) |
| WU-16.1 | WU-16 sha backfill + sessions/2026-04-24 retrospective 신설 | `227f900` | 2026-04-24 | 2026-04-24 | brave-hopeful-euler | [WU-16.md](WU-16.md) (refresh 전용) |
| WU-17 | HANDOFF / BRIEFING 축소 (v2 참조 구조 전환, -77.6%) | `083cfe1` | 2026-04-24 | 2026-04-24 | ecstatic-intelligent-brahmagupta | [WU-17.md](WU-17.md) |
| WU-17.1 | WU-17 sha backfill + sprints/_INDEX.md 이동 | `d5681fa` | 2026-04-24 | 2026-04-24 | ecstatic-intelligent-brahmagupta | [WU-17.md](WU-17.md) (refresh 전용) |
| WU-18 | Phase 1 MVP W0 Pre-Arming (templates + plugin-wip + QUICK-START) | `d200299` | 2026-04-24 | 2026-04-24 | ecstatic-intelligent-brahmagupta | [WU-18.md](WU-18.md) |
| WU-18.1 | WU-18 sha backfill + sprints/_INDEX.md 이동 | `12b9a72` | 2026-04-24 | 2026-04-24 | ecstatic-intelligent-brahmagupta | [WU-18.md](WU-18.md) (refresh 전용) |
| WU-19 | Phase 1 MVP W0 Executable Scripts (setup-w0.sh + verify-w0.sh) | `74135cf` | 2026-04-24 | 2026-04-24 | ecstatic-intelligent-brahmagupta | [WU-19.md](WU-19.md) |
| WU-19.1 | WU-19 sha backfill + sprints/_INDEX.md 이동 | `9271f2a` | 2026-04-24 | 2026-04-24 | ecstatic-intelligent-brahmagupta | [WU-19.md](WU-19.md) (refresh 전용) |
| WU-20 | Solon MVP Distribution 설계 + 실체화 (scope pivot) | `3ca7f56` | 2026-04-24 | 2026-04-24 | amazing-happy-hawking → dreamy-busy-tesla → funny-sweet-mayer | [WU-20.md](WU-20.md) |
| WU-20.1 | WU-20 sha backfill 확인 + _INDEX.md row 추가 | `2709fcf` | 2026-04-25 | 2026-04-25 | funny-pensive-hypatia → admiring-nice-faraday (auto-resume 실체화) | [WU-20.1.md](WU-20.1.md) (refresh 전용) |
| WU-21 | Phase 1 킥오프 D-2 dry-run (install.sh + setup-w0.sh sandbox PASS, F-01~F-04 findings) | `cd94f65` | 2026-04-25 | 2026-04-25 | confident-loving-ride | [WU-21.md](WU-21.md) |
| WU-22 | MVP next-feature roadmap & sequencing (8 후보 1-pager + β release grouping 채택) | `a66cf2e` | 2026-04-25 | 2026-04-25 | eager-elegant-bell (open + brainstorm) → epic-brave-galileo (close, hang takeover) → trusting-stoic-archimedes (sha backfill) | [WU-22.md](WU-22.md) |
| WU-23 | #1 sfs slash command detail design (6 명령 minimal contract spec, 3-agent vote V-1 PASS) | `1e0e6f1` | 2026-04-25 | 2026-04-25 | trusting-stoic-archimedes (자율 작업, 사용자 부재 4시간 위임 mode) | [WU-23.md](WU-23.md) |
| WU-24 | #1 sfs slash 구현 part 1 (`/sfs status` + `/sfs start` + sfs-common.sh + 4 templates + sfs.md adapter dispatch + VERSION/CHANGELOG 0.3.0-mvp 예약 + install.sh scaffold gap fix) | `0cb6bee81461d7dd9840536f939488d4a114d1eb` | 2026-04-25 | 2026-04-26 | adoring-trusting-feynman (22nd open) → 24th 사이클 scheduled runs (friendly-magical-galileo / brave-gifted-thompson / relaxed-gallant-maxwell / cool-magical-volta / blissful-modest-goldberg / friendly-serene-galileo) → great-dazzling-babbage (24th-11 close, user-active conversation) | [WU-24.md](WU-24.md) |
| WU-31 | Release tooling Phase 0 — local sh (cut-release.sh 351L + sync-stable-to-dev.sh 335L + check-drift.sh 240L + scripts/_README.md 275L + .visibility-rules.yaml 12→16 패턴 + dry-run sandbox 통합 검증 9 smoke PASS) | `9fbd999e62f771f1c2dcc2fb14b093c5e5f0e1ec` | 2026-04-25 | 2026-04-27 | dazzling-sharp-euler (23rd open, spec only) → 24th 사이클 scheduled runs (wizardly-sleepy-brown / eager-stoic-pasteur / great-kind-turing / fervent-sweet-hamilton / trusting-funny-volta / nifty-wizardly-bardeen) → pensive-exciting-keller (24th-24 frontmatter close) → jolly-festive-ramanujan (24th-25 sprints/_INDEX 이동) | [WU-31.md](WU-31.md) |
| WU-30 | F-04 verify-w0.sh fix (정규식 minimal `[A-Z]{2,}` + 두 검증기 분리: verify-w0.sh 헤더 주석 + verify-install.sh 신설 160L + README.md 두 경로 분리 + dry-run sandbox 4 smoke 통합 검증 PASS) | `9fbd999e62f771f1c2dcc2fb14b093c5e5f0e1ec` | 2026-04-25 | 2026-04-27 | adoring-trusting-feynman (22nd open, frontmatter only) → 24th 사이클 scheduled runs (fervent-determined-bohr 24th-13 row 2 / friendly-funny-planck 24th-14 row 3 / quirky-exciting-clarke 24th-16 row 4) → bold-festive-euler (24th-32 user-active-deferred row 5~8 일괄 close) | [WU-30.md](WU-30.md) |
| WU-25 | #1 sfs slash 구현 part 2 — `/sfs plan` (sfs-plan.sh 170L 7 smoke) + `/sfs review` (sfs-review.sh 225L 15 smoke + gates.md §1 7-enum 검증 + verdict 통합) + sfs-common.sh 보강 (validate_gate_id + infer_last_gate_id + update_frontmatter, +71L 8 smoke) + sprint-templates plan/review +1L 5 smoke + sfs.md adapter dispatch +2 +10L 9 smoke + VERSION/CHANGELOG 0.4.0-mvp 예약 + dry-run sandbox 통합 검증 15 smoke = 누적 59 smoke 0 FAIL | `42be9b9` | 2026-04-28 | 2026-04-28 | brave-gracious-mayer (24th open + continuation 1~5) → 24th 사이클 scheduled runs (hopeful-bold-keller 24th-48 row 4 / amazing-determined-gates 24th-49 row 3 / wizardly-magical-cerf 24th-50 row 5 / cool-practical-goldberg 24th-51 row 6 / fervent-exciting-carson 24th-53 row 8) → gallant-fervent-thompson (24th-54 row 9 frontmatter close) → brave-gracious-mayer continuation 5 (24th-52 row 7 + row 10 active→complete 이동) | [WU-25.md](WU-25.md) |
| WU-27 | #1 sfs slash 구현 part 4 — `/sfs loop` (Ralph Loop + Solon mutex + Solon-wide executor convention `--executor` global flag 신규 도입). **spec close** (sub-task 1+1.5+2~5 = 6 file ~979L 모두 ≤200L 결정 #4 충족, commit `0ba4817`) + **sub-task 6 실 bash 구현 close** (6.1~6.7 = sfs-loop.sh 735L + sfs-common.sh +571L 보강 + sfs.md adapter +1 row, 22 smoke PASS, commit `a6658b5` 25th-1 optimistic-vigilant-bell user-active-deferred 자율) + **sub-task 6.8 buffer close** (26th-1 admiring-compassionate-euler user-active-deferred + 사용자 D′ 결정 = β minimal cleanup + spec/impl drift 1건 + 버그 2건 fix + persona fallback 정책 + schema migration 보류, sfs-common.sh +86L: review_with_persona SFS_LOOP_LLM_LIVE fail-closed + claim_lock mkdir-atomic POSIX-portable + mark_abandoned escalate auto-wire + _builtin_persona_text 신설 + persona fallback known/unknown 분기, 8/8 smoke PASS, decision_points WU27-D6 + WU27-D7 W-24/W-25 deferred 등재, commit TBD 사용자 manual). 결정 #4 1차 적용 사례 + Solon-wide executor convention (named profile claude/gemini/codex + custom string). review gate self-application 2건 (PLANNER PASS + EVALUATOR PASS-with-conditions × 2). 잔여 = 0.5.0-mvp release cut + stable sync (사용자 mac terminal, 다음 cycle). | `0ba4817` (spec) / `a6658b5` (6.1~6.7) / TBD (6.8) | 2026-04-28 | 2026-04-29 | admiring-zealous-newton (25th-1 spec) → optimistic-vigilant-bell (25th-1 6.1~6.7) → admiring-compassionate-euler (26th-1 6.8 buffer) | [WU-27.md](WU-27.md) |
| WU-29 | 0.3.x hotfix — codex review release-blocker 3건 fix (#1 `solon-mvp-dist/install.sh` chmod 700 + #2 `sfs-common.sh` `reverse_lines()` 신설 +28L + 4 호출자 (read_current_wu / read_last_gate / read_last_gate_verdict / infer_last_gate_id) tac → reverse_lines 교체 macOS tac/gtac/tail-r/awk 4-tier 폴백 + #3 `sprint-templates/decision-light.md` 신설 24L ADR-light + `sfs.md` adapter 6-patch dispatch table row 'decision' / brace list / exit code matrix / Read Context 재분류 / Adapter 격상 / authoritative 6 commands) + aux: sfs-decision.sh chmod 700 (finding #1 변종). 사용자 'ㄱㄱ' final approval (β default = 사용자 결정 §1.3). §1.15 self-application: PLANNER PASS-with-cond + EVALUATOR PASS-with-cond. 7-file commit + smoke 7 PASS / 0 FAIL (T1 install exec / T2 reverse_lines tac / T2b read_current_wu='WU-99' + infer_last_gate_id='G4' / T2c awk fallback / T3 decision-light + 6 adapter assertions / T4 tac residual=1 helper-only / pre-flight bash -n). | `e551693` | 2026-04-29 | 2026-04-29 | exciting-festive-cori (25th-4 user-active conversation, lifecycle 100% 1세션) | [WU-29.md](WU-29.md) |
| WU-26 | #1 sfs slash 구현 part 3 — `/sfs decision` (mini-ADR full, sfs-decision.sh 186L + 14 verification, 24th brave-gracious-mayer continuation 5 row 2) + `/sfs retro [--close]` (sprint close + auto commit, sfs-retro.sh 170L 25th-4) + sfs-common.sh 보강 +50L (next_decision_id + sprint_close + auto_commit_close 3 함수, WU-26 §3 verbatim) + decisions-template/ADR-TEMPLATE.md 5 섹션 (ADR-full Context/Decision/Alternatives/Consequences/References) + decisions-template/_INDEX.md (light/full dual 정책 명시) + sprint-templates/retro.md `last_touched_at` placeholder 추가 + sfs.md adapter dispatch +retro row 7-patch (header / dispatch / brace list / exit code matrix / fallback 재분류 / Adapter 격상 / authoritative 7 commands) + install.sh decisions-template/ copy block 추가. **smoke fix 2건 발견 + 적용**: (a) sfs-retro.sh 의 `append_event` 1-arg → 2-arg signature 정합 (sfs-decision.sh / sfs-plan.sh 패턴, events.jsonl JSON valid 보장) / (b) `--close` review 검사 file 기반 → events.jsonl `review_open` event scan 기반 (sfs-start.sh 가 4 templates 모두 cp 하므로 file 검사 무의미 → events 기반 = "review 한번이라도 open" 의도 정합). 1차 smoke 15 + 2차 re-smoke 7 = **22 smoke PASS / 0 FAIL** (full happy path / events.jsonl 9~15 entries all valid JSON / decision auto-id 0001~0099 / decision space-kebab / id override / no-title exit 7 / retro / retro --close / current-sprint cleared / closed_at filled / auto commit `chore(sfs): close sprint <id>` / events 기반 review_open 검사 exit 8 / 2 sprints 누적). α 결정 (WU-26 spec verbatim, full ADR + light fallback dual). 8-file commit (WU-29 와 별도) = sfs-retro/sfs-common/retro.md/sfs.md/install.sh/ADR-TEMPLATE/_INDEX/WU-26.md + PROGRESS heartbeat. | `447d911` | 2026-04-28 | 2026-04-29 | brave-gracious-mayer (24th open + continuation 5 row 1~2) → exciting-festive-cori (25th-4 row 3~12 lifecycle close) | [WU-26.md](WU-26.md) |
| WU-35 | Code Development Team hardening — `/sfs implement` 6-division guardrail model. Root Skill + dist Skill + Claude command + README/GUIDE + implement/log templates now treat backend Transaction discipline as always-on, Security / Infra / DevOps as `light` / `full` / `skip`, and MVP-overkill as `deferred` / `risk-accepted`. | `dd1adf4` | 2026-05-01 | 2026-05-01 | codex-loop queue task `loopq-20260501T135406Z-49797` | [WU-35.md](WU-35.md) |
| WU-34 | Codex CLI SFS invocation policy — Codex CLI official Skill entry = `$sfs ...`; Windows PowerShell direct shell = `sfs.cmd ...`; Codex app `/sfs ...` remains valid only when host passes prompt text through to the model/Skill. | `d359b9f` | 2026-04-30 | 2026-05-02 | codex-desktop-user-active-20260430 → codex-desktop-user-active-20260502 | [WU-34.md](WU-34.md) |
| WU-37 | Implement execution contract hardening — `/sfs implement` now means executing the smallest verified work slice, with code, taxonomy, design handoff, QA evidence, infra/runbook, decisions, and docs all treated as implementation artifacts. | `TBD_WU37_COMMIT` | 2026-05-02 | 2026-05-02 | codex-desktop-user-active-20260502 | [WU-37.md](WU-37.md) |

## 완료 WU (status: done) — v1 → v2 이관 (WU-16 backfill)

> WU-16 에서 `WORK-LOG.md` append-style entry 를 독립 파일로 이관. 본문은 원본 entry 를 거의 그대로 복사 + frontmatter 추가 (Option β minimal).

| WU | title | final_sha | opened | closed | session | path |
|:--:|:---|:---|:---|:---|:---|:---|
| WU-7 | plugin.json 샘플 분리 (Option β skeleton+sample) | `ec263c5` | 2026-04-21 | 2026-04-21 | serene-fervent-wozniak | [WU-7.md](WU-7.md) |
| WU-7.1 | WU-7 sha backfill | `af306e0` | 2026-04-21 | 2026-04-21 | serene-fervent-wozniak | [WU-7.1.md](WU-7.1.md) |
| WU-10 | branches/*.yaml 6 본부 schema 정합성 (Option β) | `3c8cac0` | 2026-04-21 | 2026-04-21 | serene-fervent-wozniak | [WU-10.md](WU-10.md) |
| WU-10.1 | WU-10 sha backfill | `ed0ac37` | 2026-04-21 | 2026-04-21 | serene-fervent-wozniak | [WU-10.1.md](WU-10.1.md) |
| WU-13 | NEXT-SESSION-BRIEFING.md 신설 (9-섹션) | `101030f` | 2026-04-20 | 2026-04-20 | funny-compassionate-wright | [WU-13.md](WU-13.md) |
| WU-13.1 | WU-13 sha backfill | `899643a` | 2026-04-20 | 2026-04-21 | funny-compassionate-wright | [WU-13.1.md](WU-13.1.md) |
| WU-14 | context-reset 대비 infrastructure (tmp/ + PROGRESS.md v1) | `42e3719` | 2026-04-21 | 2026-04-21 | serene-fervent-wozniak | [WU-14.md](WU-14.md) |
| WU-14.1 | WU-14 sha backfill | `853373f` | 2026-04-21 | 2026-04-21 | serene-fervent-wozniak | [WU-14.1.md](WU-14.1.md) |

## 완료 WU (status: done) — v1 형식 (WORK-LOG.md 원본 유지, 추후 확장 이관 대기)

> 아래 WU 들은 `WORK-LOG.md` 의 append-style entry 로만 존재. 본 인덱스에서는 sha 만 참조. 독립 파일 이관은 WU-16b (필요 시) 에서.

| WU | final_sha | WORK-LOG entry |
|:--:|:---|:---|
| WU-0 (backfill) | `d034d0d` | L55-L77 |
| WU-1 | `92c2f54` | L42-L54 |
| WU-1.1 | (backfill) | — |
| WU-2 | (entry) | L78-L94 |
| WU-3 | (entry) | L95-L116 |
| WU-8 | (entry) | L117-L140 |
| WU-8.1 | (entry) | (WORK-LOG append) |
| WU-11 | `4cd07e6` | L141-L171 |
| WU-11.1 | `eed4dd1` | L172-L185 |
| WU-11.2 | `6527252` | L186-L198 |
| WU-12 | `7f8a635` | L199-L237 |
| WU-12.1 | `ff89ea1` | L238-L251 |
| WU-12.2 | `8ab660c` | L252-L269 |
| WU-12.3 | `b77fcb2` | L270-L297 |
| WU-4 | `7d982dc` | L298-L325 |
| WU-4.1 | `1c375aa` | L326-L339 |
| WU-5 | `20c3474` | L340-L363 |
| WU-5.1 | `9c4d6c0` | L364-L378 |
| WU-9 | `816d751` | L379-L408 |
| WU-9.1 | `6884bbd` | L409-L423 |

## BLOCKED

| WU | 사유 | 해결 조건 |
|:--:|:---|:---|
| WU-6 | claude-shared-config/.git IP 경계 재정리 | 사용자 결정 필요 (HANDOFF §0 참조) |

## Phase 2

| WU | 조건 |
|:--:|:---|
| WU-11 B | Phase 1 Claude 구현 안정화 후 재검토 (Claude-specific layer: 필드) |
| WU-11 C | Phase 2 Go/No-Go 결정 후 (Codex / Gemini-CLI 어댑터) |

---

## 명명 규칙

- 파일: `WU-<id>.md` (id 는 순차 번호, 예: `WU-15.md`)
- 200 line 초과 시: `WU-<id>/` 디렉토리 생성 + `step-1.md`, `step-2.md`, ... 로 분리 + `_meta.md` (frontmatter 집중)
- Refresh WU: `WU-<id>.1.md` (forward sha backfill 전용, squash 제외)

## Frontmatter 필수 필드

`CLAUDE.md §5` 참조. 필수: `wu_id · title · status · opened_at/closed_at · session_opened/session_closed · final_sha · visibility · entry_point · depends_on_reads · files_touched · decision_points · learning_patterns_emitted · sub_steps_split`.

**WU-16 migration 추가 필드**: `migrated_from` (WORK-LOG.md 원본 line range) · `migrated_by` (이관 WU id). 추후 확장 이관 시 동일 패턴 사용.

---
phase: retro
gate_id: G5
sprint_id: sfs-doc-tidy-release-notes
goal: "SFS doc tidy command + update awareness + release notes policy"
created_at: "2026-05-01T18:27:08+09:00"
last_touched_at: 2026-05-01T12:54:11+00:00
closed_at: 2026-05-01T12:54:11+00:00
---

# Retro — SFS doc tidy command + update awareness + release notes policy

> Sprint **G5 — Sprint Retro** 산출물. 학습 루프 (정성, N PDCA 집계).
> `/sfs retro --close` 로 본 sprint 의 `closed_at` 을 frontmatter 에 기록 + `.sfs-local/events.jsonl` 의 `sprint_close` event append.
> SSoT: `gates.md §1` (G5) + `05-gate-framework.md §5.1.3` (Sprint Retro).
> 생명주기: `retro.md` 는 history/learning 을 보존하는 문서다. 실제 작업 결과는 close 전
> `report.md` 로 정리하고, workbench/tmp 산출물 원문은 archive 로 이동해 보존한다.

---

## §1. KPT (Keep / Problem / Try)

### Keep — 잘 된 것 (계속)

- Workbench cleanup을 삭제가 아니라 archive-first lifecycle 로 잡은 결정이
  좋았다. `tidy`, `report --compact`, `retro --close` 가 같은 helper를 쓰면서
  사용자의 “정리하되 원본은 남긴다” 요구와 구현 regularity가 같이 맞았다.
- G4에서 partial을 억지로 통과시키지 않고, reviewer가 실제로 보는 evidence
  bundle의 한계를 찾아 `log.md`/`review.md` 앞부분에 검증 근거를 올린 것이
  효과적이었다.
- Release cut preflight를 `--apply`에서 막도록 한 덕분에 dry-run/검토 흐름은
  유지하면서 실배포 누락만 차단했다.

### Problem — 안 된 것 / 막힌 것

- 첫 G4 리뷰는 구현 diff가 이미 merge된 상태라 실제 구현이 prompt에 보이지
  않았다. `implement.md`에 증거를 보강했지만 evaluator bundle은 이를 읽지 않아
  한 번 더 partial이 났다.
- review executor는 `codex`만 ready였고 `claude`/`gemini`는 missing이었다.
  cross-instance 검증은 했지만 cross-vendor 독립성은 확보하지 못했다.
- 같은 working tree에 unrelated `0.5.51-product` adopt 변경이 존재해서,
  close/commit 시 payload 분리가 필요하다.

### Try — 다음 sprint 시도

- Review prompt가 어떤 artifact를 embed하는지 sprint 초반에 확인하고, G4용
  smoke 증거는 `log.md`처럼 evaluator가 반드시 보는 위치에 적는다.
- Queue/loop follow-up은 작은 backlog item으로 쪼개서, lifecycle/emit/audit/smoke
  성격이 섞이지 않게 진행한다.
- close 전에는 `git status`를 기준으로 unrelated dirty file을 먼저 구분한다.

## §2. PDCA 학습

- **Plan**: AC 자체는 맞았지만, “무엇을 구현했는가”보다 “reviewer가 어떤 증거를
  볼 수 있는가”가 별도 리스크였다.
- **Do**: archive helper를 공유함으로써 새 명령과 기존 close/compact 경로의
  동작을 하나로 맞췄다.
- **Check**: G4는 두 차례 partial 후 pass. 최종 pass 근거는 dry-run 무변경,
  apply archive/recovery, report/retro regression, release-note preflight 증거다.
- **Act**: 이후 G4 evidence는 command/stdout/exit/before-after tree를
  `log.md`에 먼저 기록하고, report에는 최종 요약만 남긴다.

## §3. 정량 메트릭 (선택)

- **AC 통과율**: AC1~AC7 전부 충족, G4 final verdict `pass`.
- **G4 리뷰 분포**: skipped 1회, executor failure 1회, partial 3회, pass 1회.
- **검증 smoke**: syntax 1개, dry-run/current/named smoke 3개, apply smoke 1개,
  report compact regression 1개, retro close regression 1개, release preflight 1개.

## §4. 다음 sprint 인계

- **이어가는 항목**: 없음. `sfs-doc-tidy-release-notes` 자체는 close 가능.
- **분기되는 WU/sprint**:
  - queue lifecycle split / retro-light backlog.
  - events emit restoration.
  - adapter/dispatch docs audit.
  - loop queue multi-worker smoke.
- **결정 대기 (W10 후보)**: archive restore/explore UX는 실제 사용자가 필요를
  느낄 때 별도 decision으로 분리한다.

## §5. G5 close 체크

- [x] G4 CPO review final verdict = `pass`
- [x] `report.md` final summary 작성
- [ ] `closed_at` frontmatter 기록 (`/sfs retro --close` 가 자동 채움)
- [ ] Workbench/tmp artifact archive 이동 확인

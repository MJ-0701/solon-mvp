---
wu_id: WU-7
title: "07-plugin-distribution.md §7.2 plugin.json 예시 → appendix/samples/plugin.json.sample 분리"
status: done
opened_at: 2026-04-21T00:00:00+09:00   # 5번째 세션 serene-fervent-wozniak 사용자 취침 전 자율 진행
closed_at: 2026-04-21T00:30:00+09:00
session_opened: serene-fervent-wozniak
session_closed: serene-fervent-wozniak
final_sha: ec263c5
refresh_wu: WU-7.1
visibility: raw-internal
entry_point: |
  본 WU 는 WORK-LOG.md L467-L494 entry 를 sprints/ 로 이관한 backfill 파일.
  원본 본문은 그대로 유지, frontmatter 만 추가 (WU-16 이관 작업, Option β minimal).
depends_on_reads:
  - 07-plugin-distribution.md §7.2    # 분리 대상 본문
  - cross-ref-audit.md §1.2 / §5      # 실물 파일 인벤토리 + Sanity verdict
  - INDEX.md §1 Appendix              # Hooks & Tooling 확장 지점
files_touched:
  - 2026-04-19-sfs-v0.4/appendix/samples/plugin.json.sample   # 신규, 84 lines (_meta 블록 포함)
  - 2026-04-19-sfs-v0.4/07-plugin-distribution.md             # §7.2 블록 교체 (70 inline → 28 skeleton)
  - 2026-04-19-sfs-v0.4/INDEX.md                              # §1 Appendix "Hooks & Tooling (2)" → "Hooks & Tooling & Samples (3)"
  - 2026-04-19-sfs-v0.4/cross-ref-audit.md                    # §1.2 / §5 동기화 (20+ → 21+)
  - 2026-04-19-sfs-v0.4/WORK-LOG.md                           # WU-7 entry + Changelog v1.14
decision_points:
  - { type: Option β, summary: "skeleton+sample split (B)", alternatives: "A full extract / C inline 유지", rationale: "SSoT 경계 명확 + W13 재사용 가능" }
learning_patterns_emitted: []
sub_steps_split: false
migrated_from: WORK-LOG.md L467-L494
migrated_by: WU-16
---

# WU-7 · 07-plugin-distribution.md §7.2 plugin.json 예시 → `appendix/samples/plugin.json.sample` 분리

- **성격**: asset (Phase 1 W13 Plugin Packaging 재사용 자산 선제 생성) + docs (07 §7.2 본문 slim)
- **intent**: 다음 세션 브리핑 §2 에 명시된 Track B 큐 next_blocking. 07 본문에 inline 으로 박혀 있던 ~70 라인 JSON 블록을 별도 파일로 분리하여 Phase 1 W13 Plugin Packaging 시점에 `claude plugin install solon` 의 seed 매니페스트로 직접 재사용 가능하게 함. 동시에 07 §7.2 본문은 top-level 필드 구조 skeleton 만 남겨 SSoT (필드 **의미**) 역할을 유지 (§7.2.1 표 + §7.2.2 env 규칙).
- **Option β 선택 (minimal cleanup)**:
  - A (full extract): 전체 값 + peerDep 설명까지 분리. 07 본문을 stub 로 → 과잉, SSoT 경계 불명확.
  - **B (skeleton + sample split, 채택)**: 07 은 top-level 필드만 보여주는 skeleton + sample 파일이 완전본 보유. `$schema` / `_meta` 메타 필드는 샘플에만 추가, 본문 SSoT 는 §7.2.1/§7.2.2 의 필드 의미.
  - C (inline 유지 + 링크만 추가): 분리 목적 (W13 재사용) 미달성.
- **commit**: `ec263c5`
- **pushed**: pending (user terminal) → 2026-04-22~23 사이 사용자 push 완료 (WU-16 진입 시점 ahead 0 확인)
- **notes**:
  - **SSoT 경계**: 07 §7.2.1 (필드 의미 표) + §7.2.2 (env optional 규칙) = 필드 **의미** 의 SSoT. 샘플 파일 = 그 구조를 따르는 현 시점 **값** 스냅샷. 필드 추가/삭제 순서는 "07 §7.2.1 표 먼저 → 샘플 파일 동기화" 로 고정 (역방향 금지 명시).
  - **`_meta` / `$schema`**: 샘플 파일 자체 documentation 용으로 추가 (JSON 주석 불가 대응). release 시점 packaging 스크립트가 이 두 필드를 strip (plugin 매니페스트 런타임은 해석하지 않음). 이 규칙도 `_meta.strip_meta_on_package` 필드에 자기 기술.
  - **원칙 2 (self-validation-forbidden) 회피**: inline → 파일 분리는 **구조 변경** 이지 설계 결정 아님 (값 동일). 의미 재해석 없음.
  - **Phase 1 W13 경로**: 풀스펙 §10.4 W13 Plugin Packaging 착수 시 이 sample 을 `sfs-plugin/plugin.json` 으로 복사 + strip script + 버전/engines 치환 + `peerDependencies` validation. Track C (조기 상향 여지) 트리거 시에도 본 파일이 1차 진입점.
  - **cross-ref-audit.md §1.2 / §5**: 실물 파일 인벤토리 증가 반영. §4 pending TODO 에는 영향 없음 (이 파일은 Phase 1 pending 이 아닌 WU-7 실존 파일).
  - **WU-7.1 계획**: sha backfill + HANDOFF frontmatter 갱신 + NEXT-SESSION-BRIEFING.md §1 refresh.
  - Track B 큐에서 WU-7 제거 → **WU-10** 가 next_blocking.

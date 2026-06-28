# Solon 제품 릴리스 노트

**언어**: 한국어 / 영어 문서 예정

이 문서는 사용자가 새 버전에서 무엇을 체감하게 되는지 짧게 정리합니다.
세부 구현 기록은 [CHANGELOG.md](./CHANGELOG.md) 에 따로 둡니다.

---

## Next

다음 release cut 에 포함될 변경은 아직 확정되지 않았습니다.

---

## 0.8.56

블로그 인사이트 배치: **인간-에이전트 팀 운영 원칙**과 **에이전트 자기-신원(구획 단위 권한) 접근 모델**을 라우티드 컨텍스트로 승격합니다 (Claude 블로그 2026-06-24; 벤더 제품/채널 UI·Enterprise RBAC·JIT 크리덴셜 로드맵은 by-reference 보류). 일반화 원칙만 반영했고 인용한 벤더 기능을 전부 제거해도 원칙은 그대로 성립합니다.

체감 변화 (운영자 관점):

- **팀 로스터 = 명시 산출물**: 각 사람/에이전트의 owns/scope/tools 를 durable 표면에 선언 — 역할 미명시로 개인 AI 가 난립하고 컨텍스트가 쪼개지는 것을 막습니다.
- **North star + 능동 제안 권한**: `operator-context.md` 에 야심 목표와 "능동 제안 가능한 에이전트"를 적어두면, 검증-신뢰 게이트를 통과한 범위에서 에이전트가 다음 작업을 먼저 제안합니다 (gate 우회 아님, suggest-only).
- **인간 주의 = 희소자원**: 질문 batch, 핵심 컨텍스트 반복, 1회 노출 항목 제한, 작업량 guardrail.
- **에이전트가 자기 신원으로 행동**: 사용자 대행 대신 service account 로, 신원 폐기 시 모든 접근이 한 번에 종료.
- **권한은 구획(작업 경계) 단위**: baseline 상속 + 경계별 override, 경계 넘는 메모리 비누설 — 1인 운영자라면 개인 도셋 vs 회사 프로젝트 경계에 적용.
- **감사 기반 grant 라이프사이클**: 넓게 시작 → `events.jsonl`/`tool_call` 감사 추적 확인 → 정당한 grant 한 개씩 좁히기.

---

## 0.8.55

0.8.54 의 Windows ps1 bash bridge 수정을 실 Windows 에서 smoke 검증된 형태(`exec bash "$@"`, `-lc` 아닌 `-c`)와 byte 단위로 일치시킵니다. 동작은 0.8.54 와 동일(POSIX `/usr/bin:/bin` 을 PATH 앞에 붙여 mktemp/dirname/timeout 정상 해석)하며, 공식 배포본과 검증된 hotpatch 의 소스 발산을 막는 정합성 정리입니다.

체감 변화:

- **Windows**: `scoop update sfs` 로 0.8.55 교체 후 `sfs.cmd team show` / `sfs.cmd team resolve-runtime researcher` 가 동일하게 정상 동작 (issue #9).
- **macOS / Linux / Git Bash**: 변화 없음.

---

## 0.8.54

Windows 에서 `sfs.cmd team` / `auth` / `report-bug` 같은 명령이 PATH 나 `SFS_COMMAND_TIMEOUT_SEC=0` 우회를 몰라도 바로 동작합니다. 그동안 Windows PowerShell/Codex 에서 bash core 가 Git for Windows 의 POSIX 유틸 경로(`/usr/bin`)를 PATH 에서 못 찾아 `mktemp: command not found` / `dirname: command not found` 로 SFS 로직 진입 전에 죽었는데(issue #9), 이제 bridge 가 bash 안에서 `/usr/bin:/bin` 을 PATH 맨 앞에 붙여 실행하므로 POSIX `timeout`·`mktemp`·`dirname` 이 정상 해석됩니다.

체감 변화:

- **Windows**: `scoop update sfs` 후 `sfs.cmd team show`, `sfs.cmd team resolve-runtime researcher` 가 별도 PATH/환경 설정 없이 `team_preset: trio` 등 정상 출력까지 도달.
- **macOS / Linux / Git Bash**: 변화 없음 (수정은 Windows wrapper 한정).

---

## 0.8.53

0.8.52 는 `# sfs-fallback:` 출처 표식이 있는 fallback binding 만 canonical 로 승격했습니다. 그런데 이 표식은 0.8.52 이후 굳은 binding 에만 찍히므로, 그 이전에 antigravity 부재로 deprecated `gemini` 로 굳은 binding(표식 없음 — 예: 수동으로 끼워 넣은 researcher)은 user-custom 으로 영영 보존돼 `agy` 설치·인증 후에도 canonical 로 돌아올 길이 없었습니다. 0.8.53 은 두 번째 신호를 추가합니다: 표식이 없어도, binding 이 `runtime_registry` 의 deprecated 런타임을 가리키고 활성 preset 의 catalog canonical 이 다른 런타임이며 그게 capable 이면 — legacy fallback 으로 추론해 0.8.52 와 같은 감지 -> 제안(동의 1회) -> 승격 경로를 탑니다. 거절하면 `# sfs-pinned:` 표식을 남겨 다시 묻지 않고(사용자 의도로 확정), deprecated 가 아닌 런타임으로의 사용자 override 는 절대 건드리지 않습니다.

체감 변화:

- **0.8.52 이전에 gemini 로 굳은 researcher 도 자동 복귀** — `agy` 설치·인증 후
  `sfs team use trio`, `sfs team refresh`, 또는 `sfs upgrade` 가 "deprecated gemini ->
  antigravity 로 승격? [Y/n]" 한 줄로 제안합니다. 표식이 없던 legacy binding 도 이제 포함됩니다.
- **일부러 고른 gemini 면 거절하면 끝** — 거절 시 `# sfs-pinned:` 가 기록돼 다시 제안하지 않고
  그 binding 을 그대로 보존합니다. 한 번만 묻습니다.
- **deprecated 아닌 override 는 불변** — 사용자가 고른 비-deprecated 런타임(claude 등)은
  제안 대상이 아니며 절대 자동 변경되지 않습니다.
- **동의 없으면 무변경** — 비대화/미동의는 byte-for-byte 그대로이고 pin 도 쓰지 않습니다.
  solo/standalone 동작은 불변입니다.

---

## 0.8.52

trio researcher 가 활성화 시점에 antigravity(`agy`) 부재로 deprecated `gemini` fallback 으로 굳은 프로젝트가, `agy` 설치·인증 후에도 제품 차원에서 canonical 로 돌아올 길이 없던 문제를 고친 패치 릴리스입니다. 이제 fallback binding 에 출처 표식(`# sfs-fallback: <canonical>`)을 남겨, canonical 런타임이 capable 해지면 SFS 가 스스로 감지 -> 제안(동의 1회) -> 그 한 줄만 승격하고 표식을 제거합니다. 사용자가 직접 고른 binding 은 건드리지 않고(R3), 비대화/`--yes` 미동의는 byte-for-byte 무변경(R4)이며, antigravity 게이트는 auth-aware(R5)라 설치만 되고 미인증인 `agy` 는 승격하지 않습니다. solo/standalone 동작은 불변입니다.

체감 변화:

- **fallback 으로 굳은 researcher 가 자동으로 canonical 로 복귀** — `agy` 설치·인증 후
  `sfs team use trio` 재실행, 신규 `sfs team refresh`, 또는 `sfs upgrade` 가 "deprecated
  gemini fallback -> antigravity 로 승격? [Y/n]" 한 줄로 제안합니다. 동의하면 그 한 줄만 바뀝니다.
- **직접 고른 binding 은 절대 자동 변경 안 함** — 표식 없는 custom binding 은 그대로 보존.
- **설치만 되고 미인증인 `agy` 는 승격하지 않음** — auth-ready(Google 자격증명 /
  `SFS_ANTIGRAVITY_AUTH_READY`) 일 때만 승격해 런타임 에러를 막습니다.
- **"켜는 법을 알아야 켜지는" 안티패턴을 제품 규칙으로 못박음** — 새 routed 정책
  `zero-knowledge-activation`: SFS 가 감지+안전적용 가능한 상태는 반드시
  감지 -> 안내 -> 동의(1회) -> 적용 경로를 가져야 하고, 명령어/플래그/수동 config 편집을
  알아야 켜지면 설계버그로 봅니다. Gate 6 리뷰 점검 + activatable-states 메타테스트로 강제.

bash 쪽 동작과 명령 표면은 그대로이며, solo/standalone 락은 불변입니다.

---

## 0.8.51

같은 PowerShell 창에서 `sfs upgrade` 를 한 번 실행한 뒤 `sfs init` 등 친 명령이 stale `update` 로 둔갑하던 Windows 인자전달 버그를 고친 패치 릴리스입니다. Scoop self-upgrade reload 가 `$env:SFS_NATIVE_*` 를 세션에 남기고 `bin/sfs.ps1` 이 그 env 를 친 인자보다 먼저 골라, 이후 모든 명령이 stale `update` 로 바뀌었습니다 (0.6.45-0.6.56 / 0.8.50 회귀 계열). 이제 친 인자가 항상 inherited env 를 이기고(F1), self-upgrade reload 가 끝나면 세션 env 를 복원합니다(F2). bash 동작은 불변, 207/207 green.

체감 변화:

- **같은 창에서 `sfs upgrade` 후 `sfs init`/`sfs status`/`sfs team use` 가 정상 동작** — 더는
  stale `upgrade` 로 둔갑하지 않습니다. (재검증: 같은 창에서 `scoop update sfs` → `sfs upgrade`
  → `sfs init --yes` → 진짜 init.)
- **초기화 안 된 폴더 안내가 OS 에 맞게 표시** — Windows 는 `scoop install sfs ... on this PC`,
  Mac 는 `brew ... on this Mac`. "You tried: sfs <친 명령>" 도 실제 명령을 반영합니다.
- **Windows 에서 생성되는 JSON 의 BOM 제거** — `Unrecognized token` 파싱 오류를 막습니다.

bash 쪽 동작과 명령 표면은 그대로입니다 (0.8.50 과 동일, 207/207 green).

---

## 0.8.50

Windows(PowerShell/Scoop) 사용자도 bash 0.8.49 와 동일하게 멀티에이전트 팀을 켤 수 있게 한 패치 릴리스입니다. `install.ps1`·`upgrade.ps1` 이 `-Team <solo|pair|trio>` 를 받아 bash 코어로 그대로 넘기므로, capability 게이트(R3)와 `[Y/n]` 자동 제안(R5)이 Windows 에서도 동일하게 동작합니다. `-Team` 을 생략하면 아무 플래그도 넘기지 않아 solo 무변경입니다.

체감 변화:

- `.\upgrade.ps1 -Team trio` / `.\install.ps1 -Team trio` — Windows 에서도 팀 preset 을
  켤 수 있습니다. 켤 수 있는 역할만 적용되고, 안 되는 역할은 "설치/인증 후 `sfs team use`
  재실행" 안내와 함께 보류됩니다 (bash 와 동일한 코어가 처리).
- `-Team` 미지정 + 켤 수 있는 환경에서 `.\upgrade.ps1` 은 한 줄로 적용 여부를 물어봅니다
  (R5 자동 제안). 거절·비대화(`-Yes`)·미충족 환경은 solo 무변경입니다.
- `sfs.cmd team use <solo|pair|trio>` / `sfs.cmd upgrade --team` 은 이미 bash 코어로
  위임되어 동작했고, 이번 릴리스에서 그 위임이 회귀하지 않도록 잠갔습니다.
- Git Bash 가 없을 때의 안내문이 이제 `sfs team use` 활성화 경로를 함께 알려줍니다.

bash 동작은 한 글자도 바뀌지 않았습니다 — bash 0.8.49 가 그대로 spec 입니다.

---

## 0.8.49

0.8.48 의 업그레이드 경로 수리 위에, 사용자가 명령어를 몰라도 멀티에이전트 팀을 켤 수 있게 자동화를 완성한 마이너 릴리스입니다. 이제 `sfs team use trio` 로 업그레이드와 무관하게 언제든 팀을 활성화할 수 있고, 켤 수 있는 환경이면 `sfs upgrade` 가 한 줄로 적용 여부를 물어봅니다. 거절·비대화·미충족 환경은 solo 무변경입니다.

체감 변화:

- `sfs team use solo|pair|trio` — 업그레이드를 기다리지 않고 언제든 팀을 켜고/끄고/바꿉니다
  (예: `trio→pair`). 업그레이드 경로와 같은 코어를 써서 결과가 어긋나지 않습니다.
- 적용 전 런타임 CLI 설치·인증을 확인합니다. 켤 수 있는 역할만 적용되고, 안 되는 역할은
  "설치/인증 후 `sfs team use <preset>` 재실행" 안내와 함께 보류됩니다. researcher 의
  `agy` 가 없으면 deprecated `gemini` 로 폴백하거나 보류합니다 — 크래시 없이.
- 명령어를 몰라도 됩니다. 멀티에이전트가 가능한 환경에서 solo 로 `sfs upgrade` 하면
  "이 환경은 멀티에이전트(trio) 가능. 적용? [Y/n]" 한 줄을 보여줍니다. 한 번 정하면 다시
  보채지 않고, 환경이 안 되던 → 되는 으로 바뀔 때만 한 번 더 제안합니다.
- 동의 없는 적용은 없습니다. `--yes`/비대화·거절·환경 미충족은 `model-profiles.yaml`
  byte-for-byte 무변경, `team_dispatch` 미주입 — standalone 불변식 그대로입니다.

---

## 0.8.48

team topology 출하본(0.8.42..0.8.47)의 업그레이드 경로 버그 3개 + 발견가능성 결함 1개를 고친 패치 릴리스입니다. 기존(pre-0.8.42) 프로젝트도 이제 `sfs upgrade --team trio` 로 멀티에이전트를 켤 수 있습니다. solo 기본 무변경·standalone 불변식은 그대로입니다.

체감 변화:

- `sfs upgrade --team solo|pair|trio` 플래그가 실제로 동작합니다. 그동안은 front-door 가
  플래그를 "unknown arg" 로 거부해 `SFS_AGENT_TEAM` 환경변수로만 켤 수 있었습니다.
- 0.8.42 이전에 설치한 프로젝트(team 키가 없던 profile)도 업그레이드 시 team 스키마가
  자동 주입되어 `--team trio` 가 정상 적용됩니다. 예전엔 스키마가 없어 영구 skip 되며
  dispatch 만 주입되고 bindings 는 비어 라우팅이 동작하지 않던 '반쪽 적용' 버그가 있었습니다.
- team preset 을 install/upgrade 에서 직접 안내합니다(기본 solo). 비대화/`--yes` 는 solo
  유지 — 단독 실행 기본값과 standalone 보장은 변함없습니다.

---

## 0.8.47

Hermes 자체진화 seam 의 마지막 단계(P3)입니다. Seam B — 큐레이션/승격 후보를 외부 검토 표면으로 내보내고(포인터만), 사람이 내린 검토 결과를 다시 받아 advisory 로그에 적재합니다. 실제 적용(APPLY)은 끝까지 `tidy` 레일 + 사람 게이트입니다.

체감 변화:

- `sfs orchestrator export --from <candidates>` 가 후보를 **포인터 전용**(id +
  evidence_pointer + 메타)으로 review_outbox 에 내보냅니다 — 원문 body 는 구조적으로
  나가지 않습니다(file-drop transport).
- `sfs orchestrator import-review --file <review>` 가 사람 검토(approve|defer|reject +
  코멘트)를 검증·정화해 review-log 에 1줄 적재합니다. approve 라도 advisory 일 뿐, 적용·
  원격쓰기·게이트를 트리거하지 못합니다.
- **보안**: team topology 의 `sfs route` 실행 경로가 `eval` → argv 배열로 바뀌어, capsule
  goal 의 `$(…)`/백틱이 shell 로 실행되지 않습니다(주입 차단). 자격증명은 평문 금지,
  `credential_ref` 는 indirection placeholder 만.
- standalone: seam 을 끄면(기본) export/import 모두 거부하고 아무것도 쓰지 않습니다 —
  루프는 doctor+curation+tidy 만으로 동일 동작.

---

## 0.8.46

Hermes 자체진화 seam 의 2단계(P2)입니다. Seam A — 외부 오케스트레이터가 떨군 typed SIGNAL 캡슐을 받아 큐에 적재하는 경로가 열립니다. 제안만 쌓을 뿐, 루프의 실제 상태는 건드리지 않습니다.

체감 변화:

- `sfs orchestrator ingest --file <capsule>` 가 SIGNAL 캡슐(5개 typed 필드: source /
  kind / evidence_pointer / confidence / ts)을 검증하고 한 줄짜리 typed 항목을
  `.sfs-local/orchestrator/signal-queue.md` 에 append 합니다. curation 패스가 이 큐를
  읽기전용 추가 입력으로 소비합니다(doctor + lessons 아카이브와 나란히).
- suggest-only: ingest 는 큐만 씁니다 — lessons/evolution 원장이나 skill 을 자동기록하지
  않고, APPLY 는 여전히 `tidy` 레일 + 사람 게이트입니다.
- standalone: seam 이 꺼져 있거나(기본) 없으면 ingest 는 거부하고 큐를 만들지 않습니다.
  잘못된 kind·누락 필드·포인터 아닌 blob 증거는 큐를 그대로 둔 채 reject 됩니다.

---

## 0.8.45

team topology 의 자매 트랙인 Hermes 자체진화 seam 의 1단계(P1)입니다. 외부 상주 오케스트레이터(Hermes-class)를 데이터로 추상화하는 스키마 + 읽기전용 리졸버만 얹습니다 — 기본 비활성이라 끄면 지금과 100% 동일합니다.

체감 변화:

- `model-profiles.yaml` 에 `external_orchestrator` 블록이 생깁니다(`enabled: false` 기본).
  외부 오케스트레이터의 전송 방식(REST/webhook/CLI/file-drop)은 `transport_kind`
  scalar 하나로 추상화돼, 오케스트레이터 교체가 코드 수정 없이 설정 한 줄로 끝납니다(OCP).
- `sfs orchestrator show` 로 현재 seam 설정을 읽기전용으로 확인합니다. 이 단계는 스키마와
  리졸버(계약)까지만이며 실제 신호 주입·검토 표면은 다음 단계(P2/P3)에서 얹힙니다.
- 기본 비활성 스키마가 standalone 보장을 그대로 유지합니다 — 오케스트레이터를 떼거나 꺼두면
  루프는 doctor+curation+tidy 만으로 동일하게 돌고, 어떤 외부 신호도 코드/원장/스킬을 자동
  수정하거나 게이트를 우회하지 못합니다.

---

## 0.8.44

멀티에이전트 team topology 의 마지막 단계(P3)입니다. P1/P2 의 데이터 표면 위에 실제 디스패치 헬퍼 `sfs route <role> <capsule>` 가 얹혔습니다. solo 는 끝까지 그대로입니다.

체감 변화:

- team 을 켠 프로젝트에서 어댑터가 "자기 role 이 아니면 `sfs route <role> <capsule>`"
  규약대로 적임 runtime 에게 headless 위임할 수 있습니다. role→runtime→호출명령은
  전부 `model-profiles.yaml` 데이터에서 해석됩니다.
- CLI 별 prompt 전달 방식은 **데이터**입니다 — `transport_kind`(argv/stdin/file)
  scalar 하나만 바꾸면 전달 전략이 바뀌고 헬퍼 코드는 그대로입니다.
- 무한 위임 방지: hop 상한 + role 순환 감지가 폭주를 거부하고, dispatch off(solo)
  나 registry 부재 시엔 crash 없이 "직접 수행" 으로 안전하게 빠집니다.
- 실제 CLI 호출은 인증이 필요하므로 배포본 테스트에서는 `SFS_ROUTE_DRY_RUN=1` 로
  mock 합니다 — 제공물은 "데이터로 조정 가능" 이지 라이브 호출이 아닙니다.
- P3 까지 끝났으니 채널(brew/scoop) 배포는 0.8.43+0.8.44 를 `0.8.4x` 로 묶어 냅니다.

---

## 0.8.43

멀티에이전트 team topology 의 두 번째 단계(P2)입니다. P1 의 데이터 표면을 `--team` 설치/업그레이드 옵션으로 실제 배선하면서, 기본 `solo` 는 바이트 단위로 그대로 둡니다.

체감 변화:

- 기본 동작은 **그대로**입니다. `--team` 을 주지 않으면 `solo` 라서 바인딩이
  비어 있고 어댑터도 손대지 않습니다(현재 동작 0 변경).
- 멀티에이전트를 운영하려면 `install.sh --team trio`(또는 `pair`) 한 번이면
  됩니다. `model-profiles.yaml` 의 `agent_runtime_bindings` 가 채워지고
  (lead=claude, worker=codex, researcher=antigravity), `CLAUDE.md`/`AGENTS.md`/
  `GEMINI.md` frontmatter 에 역할별 dispatch 규약(`team_dispatch:`)이 주입됩니다.
- 이미 설치된 프로젝트는 `sfs upgrade --team trio` 로 같은 전환을 idempotent 하게
  적용할 수 있습니다(최신 버전이어도 동작). `SFS_AGENT_TEAM=trio` 환경변수도 동일.
- preset 은 **데이터**입니다 — `team_preset_catalog` 에 묶음 한 개를 더하면 새
  preset 이 생기고 install/resolver 코드는 그대로입니다(OCP).
- 실제 자동 호출 헬퍼는 `sfs route`(P3)로 확정됐습니다. 채널(brew/scoop) 배포는
  P3 까지 끝낸 뒤 `0.8.4x` 로 한 번에 묶어 냅니다.

---

## 0.8.42

멀티에이전트 team topology 의 첫 단계(P1)가 데이터 표면 + 회귀잠금으로 들어왔습니다. model-profiles.yaml 에 opt-in team 스키마(runtime_registry / agent_runtime_bindings / team_preset)와 그것을 읽는 읽기전용 sfs team resolver 가 추가되고, 기본 solo 는 동작이 0 변경이며 team 섹션을 통째로 지워도 solo 로 안전하게 degrade 됩니다. 실제 자동 호출(dispatch)은 P3 입니다.

체감 변화:

- 기본 동작은 **그대로**입니다. 새 설치본의 `team_preset` 은 `solo` 이고
  바인딩이 비어 있어 모든 역할이 기존처럼 `selected_runtime` 으로 동작합니다.
- 멀티에이전트를 운영하려는 소수 사용자는 `model-profiles.yaml` 의
  `runtime_registry` / `agent_runtime_bindings` 를 **설정 편집만으로** 바꿔
  역할별 CLI(claude/codex/antigravity)를 지정할 수 있는 토대가 생겼습니다.
  역할 재배치는 한 줄, 새 CLI 추가는 registry 항목 하나입니다(코드 수정 0).
- `sfs team show` / `sfs team resolve-runtime <역할>` 로 현재 매핑을 확인할 수
  있습니다. team/dispatch 섹션을 통째로 지워도 solo 로 안전하게 degrade 됩니다.
- 실제 자동 호출(`sfs dispatch`)은 다음 단계(P3)에서 이 위에 얹힙니다.

---

## 0.8.41

Shipped Markdown surfaces are scrubbed of stray closing-tag litter: 14 files under templates/ and docs/ carried a leftover end-of-file closing tag (a </content>, and in two files also a </invoke>) with no matching opening tag, which shipped into consumer installs; all are removed and a regression test locks them out.

체감 변화:

- consumer 설치본의 정책·가이드 문서 끝에 보이던 정체불명의 `</content>` 같은
  태그 줄이 사라진다. 본문 내용은 그대로다.
- 같은 아티팩트가 다시 끼어들면 `test-no-stray-content-tag.sh` 가 즉시
  잡아내므로, 다음 흡수 작업에서 조용히 재유입될 일이 없다.

---

## 0.8.40

Five mature-but-scattered self-improving policies gain one end-to-end loop map (signal -> record -> curate -> propose -> measure -> gate -> apply -> capture-delta) that calls each owning policy by-reference and declares the six cross-cutting invariants in one place, ending the dual-SSoT drift; an external orchestrator gains a prep-only self-improvement seam with no runtime wiring, so removing every orchestrator still leaves the loop working on doctor + curation + tidy alone.

체감 변화:

- 새 세션이나 외부 시스템이 "solon 의 자기개선이 한 사이클로 어떻게 도는가"를
  정책 5~6개를 따로 읽지 않고 `self-improvement-loop.md` 한 장으로 파악한다.
- suggest-only · 원장 권위 · `L-NNN` 보존 · 점수가 게이트를 못 뒤집음 · 코드
  자동패치 금지 · 스케줄 무인 실행 계약 — 이 6개 불변식이 이제 한 곳에서만
  선언돼 두 정책에 흩어져 어긋날 일이 없다.
- 외부 오케스트레이터(Hermes급)를 붙이고 싶은 운영자를 위한 seam 이 문서로
  열려 있되, 전부 제거해도 루프는 `doctor + curation + tidy` 만으로 동일하게
  돈다. 이번 변경엔 런타임 배선이 전혀 없다.

---

## 0.8.39

Three blog-insight work-units absorb into one patch: a steering-surface taxonomy turns WHERE each behavior instruction belongs into an explicit four-axis decision (entry stub / routed policy / Gate·hook / capsule), the sub-agent capsule contract gains final-message-only isolation plus isolated-and-adversarial verifier patterns, and status·flowcheck·PROGRESS can render into one self-updating live-status surface — every promotion is generalized from vendor blog posts by-reference, with managed-settings and the artifacts feature named but never depended on.

체감 변화:

- **지시를 어디에 둘지 결정 프레임.** "항상 지켜라 / 절대 하지 마라" 류 규칙은
  프롬프트(엔트리 stub)로는 보장이 안 되고 결정론적 강제(Gate·hook)로 가야 한다는
  4축 결정표가 routed context 에 명문화됐다. 비기술 운영자도 새 규칙을 어느
  표면에 둘지 판단할 수 있다.
- **서브에이전트 격리·검증 강화.** capsule 은 최종 메시지만 부모로 반환하고
  (body 비유출, 양방향 격리), 통과까지 도는 self-correction verifier 와 결과를
  반박하는 adversarial verifier 를 선택지로 쓸 수 있다.
- **스스로 채워지는 라이브 상태 표면.** `sfs status` / `flowcheck` / `PROGRESS`
  를 런이 진행되며 자동 갱신되는 단일 뷰(스스로 체크되는 릴리스 체크리스트)로
  렌더하는 경로가 명시됐다. 파일 원장이 권위이고 HTML 은 파생 투영일 뿐이라
  벤더 기능 없이도 동작한다.
- 계획 단계에 "착수 전 전체 매핑→병렬화"(map-first)와 "eval = first commit"
  포인터, 출처 역추적(evidence chain), 비용 기반 sunset 트리거가 추가됐다.

모든 승격은 벤더 블로그를 by-reference 로 인용하며, 모델 버전·제품/인명·
Team/Enterprise 베타 기능에는 의존하지 않습니다.

---

## 0.8.38

The command surface gets a drift lock and it caught three real bugs on its first run — every parallel command list (dispatch, adapters, MCP tools, context routing, usage text, router-doc markers) is now cross-checked by one parity test, which immediately surfaced recall missing from help and context-path resolution failing for recall and harness; the routed-context index gains themed sections, and upgrades become subdirectory-safe.

체감 변화:

- **(버그픽스) `sfs context path recall` / `harness` 가 "unknown context
  key" 로 실패하던 것 수정** + `recall` 이 `help --full` 명령 목록에서 빠져
  있던 것 보강. 셋 다 신설 패리티 테스트가 첫 실행에서 적발.
- **명령 표면 drift 잠금.** 디스패치·어댑터·MCP 툴·context 라우팅·usage·
  router-doc marker — 평행 리스트 6곳을 교차검사하는 테스트 1개. 한 곳에만
  명령을 추가하면 빠뜨린 곳을 테스트가 전부 호명합니다.
- **_INDEX 가 6개 주제 섹션으로.** 라우트 원문 그대로, 릴리스마다 추가되는
  라우트의 탐색 비용이 파일 전체 스캔에서 섹션 단위로.
- **업그레이드 하위디렉토리 안전화.** 미래의 중첩 어댑터도 정상 설치
  (부모 디렉토리 생성 + 재귀 chmod + 정렬 LC_ALL=C 고정).
- **"안 하기로 결정" 5건 사유와 함께 기록.** common.sh 추출(의미론 차이),
  router-doc lib 화(marker 만이 공유 계약 — drift 잠금으로 대체), backup
  dedup(표면별 상이), 200줄 분할(디텍터가 설계대로 작동 중 — 다음 내용
  수정과 동반), dispatch 전면 재작성(패리티 잠금이 같은 효과를 1/10
  리스크로). 보류가 아니라 결정입니다.

---

## 0.8.37

The upgrade path stops silently skipping runtime adapters and the release runbook becomes executable — upgrade enumerates runtime scripts dynamically (eight adapters were never refreshed before), post-publish verification ships as a script instead of prose, release guidance catches up to the in-repo cut, and a coherence pass closes the routed-context conflicts a full repo+wiki audit surfaced.

체감 변화:

- **(버그픽스) vendored 업그레이드가 runtime 어댑터 8종을 영영 안 갱신하던
  문제 수정.** upgrade.sh 의 하드코딩 19종 목록이 템플릿 27종을 못 따라가
  capture/event/flowcheck/ingest/profile/recall/report-bug/tidy 가 갱신에서
  빠져 있었습니다. context/ 모듈이 받았던 동적 열거 수정과 같은 방식으로
  고정 — 새 어댑터는 이제 누락될 수 없습니다.
- **출하 검증이 스크립트가 됐습니다.** preflight 가 안내만 하던
  `scripts/verify-product-release.sh` 실물 출하 — VERSION/tag/4 phase
  marker/채널 manifest/설치본을 로컬 증거만으로 일괄 판정 (0.8.34-36 에서
  수동 반복하던 시퀀스의 코드화).
- **릴리스 안내문이 현실을 따라잡았습니다.** "이 repo 엔 cut tooling 없음"
  류 폐기된 R-D1 안내 (AGENTS.md / release-policy / release-sequence 출력문)
  전부 in-repo cut 절차로 교체.
- **routed context 정합성 패스.** workaround 수명관리 이중 소유 해소
  (adapter-refactor → sunset review 경유), orphan 이던 agent-build 리뷰 렌즈
  라우팅 복구, 과잉 발화하던 load_when 3건 trigger-centric 재작성 ("token"
  한 단어에 ~300줄 hygiene 정책 동시 로드되던 것 차단), headless
  orchestrator 게이트에 typed-surface 집행 인용, 핸드오프 픽업 시 이벤트
  원장 대조 의무 명시.
- **테스트 스위트 강화.** per-test 워치독 (걸린 테스트 1개가 스위트 전체를
  못 멈추게) + 미분류 bucket 46건 → 가족 패턴 분류 + ceiling 잠금.
- **Tier-2 백로그 등재.** command registry / 공용 lib / upgrade.sh 분해 /
  200줄 정리는 CHANGELOG Deferred 절에 명시 등록.

---

## 0.8.36

Prompt surfaces become cache surfaces and capability claims get a review rail — routed context loads static-first/dynamic-last with updates by append (never in-place edits), every model upgrade asks what the harness can stop doing with handovers tested not assumed, and boundary actions get typed declarative surfaces the harness can intercept and audit, not prose instructions.

체감 변화:

- **프롬프트 표면 = 캐시 표면.** 엔트리 문서·kernel·routed 정책은 정적
  레이어, 휘발 상태(스프린트 상태·날짜·집계)는 그 뒤에 로드되는 상태
  파일(events.jsonl/PROGRESS)에만 둡니다. 갱신은 append 로 — 정적 표면을
  중간에 고치면 그 뒤 캐시가 전부 깨집니다 (캐시된 입력은 ~10% 비용).
  툴 표면은 좁게만이 아니라 **안정적으로** — 툴 목록 churn 도 캐시를
  깹니다. 모델은 런 구간당 하나, 비용 티어는 capsule 로.
- **모델 업그레이드마다 "하네스가 뭘 그만둘 수 있나" 질문.** 모델 능력
  부족을 보완하던 비계(툴 출력 사전 필터링, 컨텍스트 사전 소화, 외부
  단계 오케스트레이션)는 모델에게 넘길 후보 — 단 능력 주장은 검증 후
  채택 (vendor 수치: 자가 필터링 45.3%→61.6%). sunset 리뷰의 보완 질문,
  같은 tidy 레일.
- **경계 행동엔 typed 선언 표면.** 비가역·보안 민감·감사 필요 행동은 prose
  지시가 아니라 typed 인자를 가진 전용 도구/훅/커맨드로 — 가로채고,
  게이트하고, 감사할 수 있는 표면. typed 이벤트 버스/capsule 계약 규율의
  집행 레이어 적용판.
- **블로그 워치 잔여분 일괄 처분.** 미정독이던 프롬프트 사용법 글
  (Harnessing Claude's intelligence)을 흡수했고, 구 리포트 잔여 3건(KPI
  지표/plan A-B eval/founder PDF 매핑)은 사유와 함께 보류 등재했습니다.

---

## 0.8.35

Harness rules gain a model lifecycle and the run log becomes law — model-specific workarounds must carry a model/date source tag and surface for sunset review on model change (keep / retire / generalize); the append-only event log is the authoritative source for reconstructing any run, over handoff and progress prose; and lessons gain a periodic read-only curation pass that merges repeated patterns and feeds skill-promotion candidates (suggest-only, human-gated).

체감 변화:

- **모델 땜질 규칙에 유통기한이 생겼습니다.** 새
  `policies/model-workaround-sunset.md` — 특정 모델 거동에 대응하는 규칙
  (컨텍스트 리셋, 토큰 절약 지시 등)을 추가할 땐
  `model-workaround: {model, date, behavior}` 태그가 의무입니다. 태그 없는
  모델 땜질은 리뷰 발견사항 — 틀려서가 아니라 **안전하게 은퇴시킬 수 없어서**.
  모델 교체 시 tidy 가 태그된 규칙을 keep / retire / generalize 재검토
  후보로 표면화합니다 (suggest-only).
- **이벤트 로그가 런의 법전입니다.** 런 전체는 이벤트 로그에서 언제든 재구성
  가능해야 하고, resume·관측·메모리는 전부 로그에서 파생됩니다. 핸드오프나
  PROGRESS 서술이 원장과 어긋나면 **원장이 권위** — 모순은 silent 동기화
  대신 surface 합니다.
- **lessons 에 주기 큐레이션 패스가 생겼습니다 (Dreaming 패턴).** 쌓이기만
  하는 원장은 노이즈가 됩니다. 스케줄/tidy 시점의 read-only 패스가 반복
  trigger 를 묶어 병합 제안, promoted 졸업 후보, skill 승격 후보(스킬 승격
  루프의 2번째 입력원)를 리포트로 냅니다. 패스는 리포트만 쓰고 원장은 절대
  직접 수정하지 않으며, 적용은 tidy 에서 사람 게이트를 거칩니다.
- **vendor 인프라(managed sessions/sandboxes/콘솔)는 보류했습니다.** 일반화
  가능한 수명관리·재구성·큐레이션 원칙 3개만 by-reference 로 승격했습니다.

---

## 0.8.34

Credential handling becomes an explicit policy — agent-visible surfaces carry placeholders only while real keys live in one store, attach at the boundary with per-consumer scope, and rotate in one place; scheduled/unattended runs gain an operating contract (fresh session per fire, file-borne state, pause/resume/archive/on-demand controls).

체감 변화:

- **API 키를 어디에 둬야 하는지가 정책이 됐습니다.** 새
  `policies/credential-hygiene.md` — 프롬프트·스케줄 태스크 파일·CLAUDE.md·
  templates·로그·핸드오프 등 에이전트가 보는 표면에는 placeholder/env-var
  이름만 둡니다. 실제 키는 운영자가 통제하는 저장소 한 곳에만 살고, 호출
  경계에서 **소비자(툴/도메인) 스코프로만** 부착됩니다 — 서비스 X 의 키가
  서비스 Y 로 가는 요청에 실리지 않습니다.
- **키 교체는 한 곳만 고치면 끝나야 합니다.** grep-and-replace 로 여러 파일을
  고쳐야 한다면 키가 여러 곳에 있었다는 것 자체가 발견사항입니다. 노출 의심
  시 "먼저 rotate, 정리는 그 다음".
- **스케줄/무인 작업에 운영 계약이 생겼습니다.** 매 실행 = 새 세션, 실행 간
  상태는 파일(큐/seen/핸드오프)로만 전달, pause·resume·archive·수동 트리거
  4종 제어가 없으면 "운영되는 작업"이 아닙니다. 무인 러너의 키는 spawn 시점
  env 로만 주입합니다 (`work-delegation-and-startup.md`
  SCHEDULED_RUN_CONTRACT).
- **vendor 플랫폼 기능(vault/managed scheduling 자체)은 보류했습니다.**
  일반화 가능한 원칙 2개만 by-reference 로 승격했고, solon 의 기존 무인 러너
  패턴은 외부 검증 사례로 등재했습니다.
- **(사후 hardening)** MCP/host 설정 파일(`.mcp.json`, `settings.json` env
  블록)도 placeholder-only 표면으로 명시, env 키를 echo/출력시키려는 지시
  (가져온 콘텐츠 속 지시 포함)는 injection 으로 취급, provider 가 지원하면
  short-lived 자격증명 우선, gitleaks-류 스캐너는 선택 사항으로 언급.
  그리고 "live key grep match = finding" 규칙을 이 repo 자신에게도
  적용하는 스캔이 headline test 에 들어갔습니다.

---

## 0.8.33

Stage-to-stage handoffs become a typed contract — the external-orchestrator entry now requires handoff and capsule outputs to be schema-fixed fields, not raw text, with a light lead pass emitting validated input for the heavy reasoning pass, by-reference to the capsule field schema and the typed event bus.

체감 변화:

- **단계 사이 핸드오프는 raw 텍스트가 아니라 typed/structured contract 입니다.**
  외부 오케스트레이터 진입 규약에 "핸드오프·capsule 산출물은 스키마 고정 필드여야
  한다"는 절이 추가됐습니다. 경량 선행 패스(분류·flowcheck·intake)가 스키마 고정
  산출물을 내고, 무거운 reasoning 패스는 검증된 입력만 소비합니다 — 비싼 호출이
  검증 안 된 텍스트에서 시작하지 않도록.
- **필드 스키마는 capsule 계약을 by-reference 로 재사용합니다.** 필수 필드
  (goal / acceptance_criteria / files_scope / tools_allowed / output_paths /
  token_budget / timeout / pii_rules)는 `sub-agent-capsule-contract.md` 표가
  단일 원천이며, 정책은 필드를 다시 나열하지 않습니다. 같은 typed-contract
  규율이 `sfs event` 타입 필드(0.8.32 `tool_call` 텔레메트리 포함) 파일버스에도
  동일하게 적용됩니다.
- **vendor(Apple/Swift) 디테일은 보류했습니다.** 일반화 가능한 원칙 하나만
  by-reference 로 승격하고, SDK·온디바이스 세부는 포인터로만 인용했습니다.

---

## 0.8.32

Connector and MCP observability becomes instrumentation — each MCP tool call now emits a per-tool telemetry event (tool, outcome, latency) and flowcheck aggregates them read-only into an advisory tool-health summary that pinpoints the repeated-failure hotspot as a drift-warn and lessons signal, never changing the verdict.

체감 변화:

- **MCP 툴이 깨지거나 느려지면 flowcheck 가 짚어줍니다.** MCP 서버가 툴
  호출마다 `tool_call` 텔레메트리(어떤 툴 / 성공·실패 / 지연 ms)를 프로젝트
  이벤트 원장에 남기고, `sfs flowcheck` 가 이를 read-only 로 집계해 툴별
  호출수·에러·에러율·최대지연 요약과 **반복 실패 hotspot**(에러율이 아니라
  반복 에러 횟수 기준 — 1/1 한 번짜리는 hotspot 이 아님)을 보여줍니다. 이
  신호는 버그리포트 흐름의 drift-warn 과 lessons 누적 입력이 됩니다.
- **계측은 추가만, 기존 동작은 그대로입니다.** 텔레메트리는 verbatim 출력을
  바꾸지 않는 순수 side-write 이고 호출을 실패시키지 않으며, flowcheck 의
  판정(verdict)·exit 코드를 어느 방향으로도 바꾸지 않습니다.
  `SOLON_MCP_TELEMETRY=0` 으로 끌 수 있습니다.
- **차용한 것은 계측 스키마와 health 집계 패턴뿐입니다.** 커넥터 관측성
  블로그의 대시보드 UI·디렉터리 기능은 제품과 무관하므로 가져오지 않았습니다.

---

## 0.8.31

Skill evolution adoption becomes measured — held-out scoring now sits behind the four gates as a real procedure: a two-stage cheap-keyword then cost-gated LLM-judge before/after comparison on a held-out set, necessary to adopt but never overriding a failed gate or human sign-off.

체감 변화:

- **스킬을 진화시킬 때 "더 좋아졌다"를 측정으로 입증해야 합니다.** 지금까지
  채택 게이트는 사람 리뷰만이었습니다(measured 아님). 이제 4관문을 통과한 뒤,
  학습에 쓰지 않은 **홀드아웃 세트**로 변경 전후 점수를 비교합니다 — 1단계는
  무료 cheap-keyword 결정적 체크, 2단계는 비용 게이트가 걸린 LLM-judge(1단계
  통과 + 비자명한 변경일 때만). 점수는 **필요조건이지 충분조건이 아닙니다**:
  개선이 입증돼야 채택하되, 동점·후퇴면 기존 버전을 유지하고, 어떤 점수도
  관문 실패나 사람 승인을 뒤집지 못합니다.
- **새 시스템을 만들지 않았습니다.** skill-creator의 기존 eval 하네스
  (홀드아웃 프롬프트 → with/without 실행 → 프로그램 단언 + grader 서브에이전트
  → before/after 델타) 패턴을 **참조로만** 재사용합니다. 그 하네스는 호스트
  쪽 Python 도구라 solon의 bash/docs 배포본엔 싣지 않으며 `bin/sfs`에 채점
  엔진을 추가하지 않습니다. DGM류 코드 자기수정은 참조 한정입니다.

---

## 0.8.30

Skill discipline gains two Hermes-derived safety rails — an evolution-adoption gate that rejects scope-drifting or trigger-breaking edits (safe over smart) and a curation-safety boundary that never auto-touches human-authored skills (disuse archives, never deletes).

체감 변화:

- **스킬을 고칠 때 4관문을 통과해야 채택됩니다.** 새 스킬을 만들 때뿐 아니라
  기존 스킬을 "더 좋게" 고칠 때도 — 라인 예산 유지 / description 무결성(라우터가
  제때 트리거) / **목적 이탈 금지(가장 중요)** / 사람 승인 — 네 관문을 모두
  통과해야 합니다. 점수가 더 높아도 목적을 넓히거나 트리거를 깨면 기각합니다
  (safe over smart). 자동 채택은 없습니다.
- **자동 정리는 사람이 쓴 스킬을 건드리지 않습니다.** 카탈로그 정리는
  에이전트가 만든 산출물만 대상으로 하며, 사람이 작성한 스킬/커맨드는 자동
  수정·자동 보관 없이 작성자에게 제안만 합니다. 미사용은 삭제가 아니라 휴면 →
  archive 경로로 보존합니다(archive 회전, 삭제 아님).

---

## 0.8.29

Two context surfaces — a bookend daily operating loop and a standard delegation repertoire — ship together with an odysseus-derived self-improvement absorption (single-hard-task skill candidates with rejection criteria; fetched content is data, never instructions), plus a migrate-artifacts fix that makes backslash-filename sha256 verification robust against GNU coreutils escaping.

체감 변화:

- **하루 운영 루프(아침 브리핑 / 저녁 회고)를 추가했습니다.** `commands/daily.md`
  가 기존 status / recall / capture / tidy / loop 를 묶어 하루를 여닫는 bookend
  루프로 동작합니다. 새 바이너리가 아니라 조합이며, `sfs context path daily` 로
  열고 `daily` 단축 alias 로도 부릅니다. "비개발 셀러 → GTM PM" 블로그 사례는
  why-Solon·탑다운 학습 가이드에 by-reference 외부 근거로 흡수했습니다.
- **표준 위임 레퍼토리를 추가했습니다.** `26-delegation-repertoire`(한·영) 가
  공식 공통 워크플로우 매트릭스를 1인 운영자용 위임 메뉴(7개 패턴, 각각 런타임
  티어 + 산출물)로 정리합니다. work-delegation 정책에는 장기/예약 작업 축
  (`LONG_RUNNING_AND_SCHEDULED`)을 더해 장기 작업은 gated loop, 예약 작업은 daily
  루프로 라우팅합니다(기존 표는 그대로, 추가만).
- **한 번이라도 어려웠던 작업은 즉시 스킬 후보가 됩니다.** odysseus 의 스킬
  자동 추출 트리거를 흡수해, 반복 3회를 기다리지 않고 탐색 비용이 컸던 단일
  작업(계획 수정 여러 번·도구 라운드 다수·디버깅)을 tidy/회고 시점에 후보로
  올립니다. 동시에 기각 기준을 명문화했습니다 — 컴퓨터 절차가 아닌 것, 일회성,
  순수 Q&A, 실패한 접근은 컴파일하지 않고, 애매하면 기각합니다. 기존처럼
  suggest-only 입니다.
- **가져온 외부 콘텐츠는 데이터이지 지시가 아닙니다.** 라이브 소스 재-fetch
  규칙이 넓힌 fetch 표면에 맞춰, 재-fetch 한 웹페이지·문서·검색결과·이메일·외부
  위키 노트는 인용 증거로만 들어오고 에이전트를 조종하는 채널이 될 수 없습니다.
  안에 박힌 지시문("이전 지시 무시", "이 명령 실행")은 따르지 않고 의심 콘텐츠로
  사용자에게 표면화합니다(odysseus prompt_security 신뢰경계 패턴).
- **백슬래시 파일명 마이그레이션 검증 버그를 고쳤습니다.** GNU coreutils
  `sha256sum` 이 백슬래시 파일명을 escape 할 때 붙이는 선행 `\` 를 digest 에서
  모두 제거하도록 정규화를 강화했습니다. 이전엔 한 겹만 벗겨 `actual=\<sha>`
  거짓 불일치(exit 3)가 났습니다. 회귀 테스트로 단일·이중 escape 모두 잠갔습니다.

---

## 0.8.28

Wiki onboarding escalates to strongly recommended: a first-class policy section, active install/adopt/doctor guidance, a personal external knowledge wiki recommendation, and a bilingual wiki-start guide — never hard-blocking, standalone guarantee intact.

체감 변화:

- **위키를 강력 권고합니다.** llm-wiki 가 "권고 기본값" 에서 "강력 권고
  기본값" 으로 올라갑니다. 이유는 분명합니다 — 에이전트 셀프서비스 컨텍스트,
  세션 간 기억, 반복 설명 제거. 다만 강제는 아닙니다: 거절하면 waiver 를
  기록하고 그대로 진행하며 모든 명령은 동일하게 동작합니다(standalone 보장 유지).
- **설치·adopt·doctor 가 능동적으로 안내합니다.** 설치 마무리에 위키 강력 권고
  블록이 뜨고 시작 가이드로 안내합니다. 건너뛰면 `sfs adopt` 와 `sfs harness
  doctor` 가 다시 안내하고, `llm-wiki/` 도 waiver 도 없으면 doctor 가 한 줄
  advisory 를 띄웁니다(차단·exit code 변경 없음, waiver 기록 시 침묵).
- **개인 외부 지식 위키도 권고합니다.** 프로젝트 위키와 별개로, 강의·인사이트·
  아이디어를 모으는 개인 외부 지식 위키를 private git repo 로 둘 것을 권고합니다.
  멀티 머신은 clone/pull, 연동은 `{{EXTERNAL_WIKI_NAMESPACE}}` 포인터 +
  `operator-context.md` 경로 기재. advisory — 없어도 동작은 같습니다.
- **위키 시작 가이드(한·영).** 왜 강력 권고인지, 프로젝트 `llm-wiki/` 10분
  시작(스캐폴드 4파일), Obsidian vault 열기, 개인 지식 위키 시작, 포인터 인용
  규칙을 한 편으로 묶고 탑다운 학습 가이드와 연결했습니다.

---

## 0.8.27

Self-improving context disciplines (conflict gate, hook-promotion, skill-promotion loop, operator context, delegation startup) plus top-down learning and why-Solon onboarding ship together.

체감 변화:

- **컨텍스트 충돌을 잡아냅니다.** 양보다 충돌이 진짜 문제입니다. 모순될 수
  있는 지시에 `<!-- conflict-key: <이름> stance: allow|deny -->` 마커를 달아
  두면 `sfs harness doctor` 가 같은 이름에 allow/deny 가 동시에 선언된 경우를
  경고합니다. 마커가 붙은 것만 비교하므로 평범한 문서에는 오탐이 없습니다.
- **어떤 규칙을 훅으로 승격할지 기준이 생겼습니다.** 문서 규칙(기대) →
  게이트/린트(리뷰) → 훅(코드 강제, 유일한 100% 층) 3계층과, 승격 기준
  (치명도 + 기계적 탐지 + 사전 차단 필요, 반복은 별도 가속기)을 명문화했습니다.
  secret 접근·`rm -rf`·force-push 같은 케이스 예시 포함.
- **반복 작업을 스킬 후보로 제안합니다.** 완료 로그에서 3회 이상 반복된 작업
  패턴을 `sfs harness doctor` 가 찾아 "스킬/커맨드로 만들 만하다" 고 제안합니다.
  읽기 전용 제안일 뿐 자동 생성은 없습니다. 실패를 누적하는 lessons 루프의
  성공판입니다.
- **운영자 컨텍스트가 자기 자리를 갖습니다.** soul(에이전트 정체성) / user
  (운영자) / 절차(라우팅) 3분할로 나누고, 운영자 정보용 placeholder 파일
  (`operator-context.md`) 을 새로 둡니다. 정체성 파일에 운영 규칙이 쌓여
  비대해지는 것을 막습니다.
- **위임 판단과 착수 습관 가이드.** 이 일을 WU 로 위임할 가치가 있는지 5요소로
  판단하고, 착수 전 요구를 복창하고 묻고, quick chat / assisted session /
  autonomous code 중 맞는 런타임을 고르는 기준을 7-step 1단계에 연결했습니다.
- **온보딩 문서 2종(한·영).** 1인 운영자용 탑다운 학습 프로토콜(문제 중심 진입
  + AI 질문 배터리 + 이해 검증)과 "왜 solon 인가 — 남는 것은 작업 구조"
  서사를 추가했습니다.

---

## 0.8.26

Skill-catalog audit and doc colocation/provenance disciplines ship together.

체감 변화:

- 라우팅된 커맨드·정책을 9개 스킬 카테고리로 점검하는 렌즈가 생겼습니다.
  2026-06-06 점검 결과 실제 빈 칸은 `runbook` 하나, `data-analysis` 는
  방법론 배포물이라 의도적으로 비워둔 칸, `product-verification` 은 Gate
  스파인이 이미 가장 임팩트 큰 칸을 채우고 있어 약점이 아니라 강점으로
  기록됩니다. 모든 라우팅 파일은 트리거 중심의 비어있지 않은 `load_when`
  을 갖도록 잠겼고, 위험 작업용 `/careful`·`/freeze` 가드레일이 후보로
  문서화됐습니다.
- 문서가 코드와 따로 늙지 않게 막습니다. 라우팅 컨텍스트를 바꾸면 대응
  문서·route 를 같은 변경에서 함께 고치고, `_INDEX` 의 실제 route 는 깨진
  링크가 없도록 잠깁니다. 참조 문서는 Grain/Scope/Usage/Gotchas/Cross-Ref
  골격을 따르고, 스스로 검증하기 어려운 7-step 산출물에는 출처 등급·신뢰도·
  리뷰·신선도·책임자 다섯 필드의 한 줄 provenance footer 를 붙입니다.

---

## 0.8.25

Token-zero session recall and thin-client external-reference policies ship together.

체감 변화:

- 지난 작업을 토큰 0 으로 다시 찾습니다. `sfs recall <날짜|키워드>` 가
  handoff/report/retro 와 sprint 워크벤치, 이벤트 원장을 LLM 없이 grep/날짜
  인덱스로 검색해 위치만 알려줍니다. 읽기 전용이라 아무것도 바꾸지 않습니다.
- 외부 지식·오케스트레이터를 얇은 규약으로만 참조합니다. 외부 지식은
  `idea_wiki:LNNN-In` 같은 네임스페이스 포인터로 인용하고 내용은 복사하지
  않으며(출처 보존), 위키가 없어도 명령 동작은 그대로입니다. 외부 상주
  에이전트(Hermes류)는 headless 진입 규약을 따르되 release/push/merge/승인
  게이트를 우회할 수 없고 첫 권한은 읽기 전용입니다.

---

## 0.8.24

Self-improving loop: lessons ledger, autonomous-loop discard escalation, and feedback flywheel ship together.

체감 변화:

- 실패가 사라지지 않고 쌓입니다. WU / review / gate 에서 잡힌 실패는
  `.sfs-local/lessons.md` 에 회피 규칙으로 누적되고, `plan` 진입 때 참조하며,
  `flowcheck` 가 누적 lesson 수와 기록 의무를 advisory 1줄로 보여줍니다(판정/종료
  코드 불변). 반복된 문제는 검증 도구(test/lint/gate)로 승격해 lesson 에
  기록합니다 — 기록과 도구 반영이 하나의 루프입니다.
- 자율 루프가 정량 기준으로 멈출 줄 압니다. 연속 폐기(discard) 카운터가
  refine@3 / pivot@5 / halt@8(사람 호출)로 에스컬레이션하고, 한 번 채택하면
  0 으로 리셋됩니다. 이터레이션당 한 가지 원자적 변경만 하고, 복잡도만 늘리는
  미세 개선은 폐기합니다(단순함 우선). `sfs loop --help` 에 사다리가 노출됩니다.

---

## 0.8.23

Evidence-at-risk handoff guard and Stop hook registration repair ship together.

체감 변화:

- review 를 PASS 한 sprint 가 열린 채로 working tree 가 미커밋이면, 인수인계 증거가
  유실될 위험을 이제 세 곳에서 경고합니다. `sfs status` 는 1줄 대시보드에
  `evidence-at-risk` 플래그를 붙이고, 다음 `sfs` 명령은 단계가 쌓일수록 강해지는
  stderr 안내(gentle → firm → URGENT)를 남기되 명령을 막지는 않으며,
  `sfs healthcheck` 는 종료 코드를 바꾸지 않는 읽기 전용 `WARN` 으로 알립니다.
  commit 하거나 `sfs retro --close` 로 sprint 를 닫으면 사라집니다.
- Claude Code Stop hook 이 실제로 동작합니다. 이전에는 hook 스크립트만 설치되고
  `.claude/settings.json` 에 등록되지 않아 한 번도 울리지 않았습니다. `install.sh`
  가 기존 설정을 덮어쓰지 않고 hook 을 등록하며, 세션 종료 시 미커밋 인수인계
  위험을 제안합니다.

---

## 0.8.22

Legacy upgrade repair, solo KPIs, process self-audit, and verifier context split ship together.

체감 변화:

- `sfs upgrade` 가 오래된 0.5.x marker 를 가진 프로젝트에서도 조용히 실패하지 않고,
  marker 를 현재 runtime version 으로 갱신합니다. `--opt-in 0.6-storage` 의 no-op
  migration 은 성공으로 이어지고, 하위 `upgrade.sh` 실패는 원인 메시지를 남깁니다.
- upgrade 중 git-tracked sprint workbench 디렉토리는 묵묵히 압축/삭제되지 않습니다.
  보존 가능한 경로만 진행하고, 무고지 삭제를 막는 회귀 테스트가 추가되었습니다.
- `sfs measure` 는 local evidence 기반으로 onboarding ramp, WU cycle-time, agent-assisted
  commit ratio 를 함께 보여줍니다. provider billing API 나 network 호출은 여전히 하지 않습니다.
- review/retro 문맥은 gate·의례가 아직 목적에 맞는지 스스로 점검하고, meta-system 작업이
  이어질 때 user-outcome 작업을 다시 앞에 올리도록 안내합니다.
- verifier context split 패턴이 문서화되어, rule 단위 분리 verifier 와 skeptic persona 로
  self-review false positive 를 줄이는 방식을 권장합니다.
- dev-only 릴리스 도구인 `cut-release.sh` preview counter 는 content 기반으로 보정되었습니다.
  제품 runtime 기능은 아니지만 이번 0.8.22 dry-run gate 의 첫 실전 검증 대상입니다.

---

## 0.8.21

Verifier-caught packaged test path leak is fixed by an in-archive regression gate.

체감 변화:

- 0.8.20은 stable/tag/channels publish 뒤 release verifier 가 product archive 안의
  `tests/run-all.sh`에서 실패해 완료 릴리스로 닫히지 않았습니다.
- 실패 원인은 출하 테스트가 product archive 밖의 parent docset 파일을 hard-assert 한 것이었습니다.
  0.8.21은 이 docset-only SSoT sync check 를 파일이 있을 때만 실행하도록 바꿉니다.
- 새 정적 테스트가 `${DIST_DIR}/../...` 직접 hard-assert 재유입을 막고, hotfix cut 전
  product-like tar/extract in-archive full run-all 을 통과했습니다.

---

## 0.8.20

Review budget guardrails, measure dashboard, lite first experience, and richer HTML artifacts ship together.

체감 변화:

- 선언된 review/advisor budget 과 estimated cost 가 함께 있고 estimate 가 budget 을 넘으면
  `sfs review` 가 evaluator 호출 전에 멈춥니다. budget 이 없거나 estimate 를 모르면 기존 흐름을
  유지하면서 local telemetry 만 남깁니다.
- `sfs measure` 가 로컬 evidence 기반 대시보드와 JSON 출력을 제공합니다. provider billing API,
  live pricing table, network 호출은 포함하지 않습니다.
- 처음 쓰는 사용자는 `start → plan → implement → review` 네 명령을 중심으로 안내받고,
  고급 사용자는 full help 에서 전체 명령 목록을 확인할 수 있습니다.
- spec/review/handoff HTML artifacts 는 공통 metadata, evidence rail, status/action 영역을
  갖춰 다음 세션 인계와 검토 증거가 더 잘 남습니다.
- pinned Claude review command 의 `--model opus --effort xhigh` 플래그가 SFS profile evidence 로
  기록되어 review_high attestation gap 을 줄입니다.

---

## 0.8.19

Sprint close/tidy/adopt now preserve raw event excerpts before pruning active ledgers.

체감 변화:

- `sfs retro --close`, `sfs tidy`, `sfs adopt` 계열 정리 흐름이 닫힌 sprint 이벤트를
  active `.sfs-local/events.jsonl` 에서 줄이기 전에
  `.sfs-local/archives/events/sprints/<sid>.jsonl` 로 raw excerpt 를 먼저 남깁니다.
- archive write 가 실패하면 prune 을 진행하지 않는 fail-closed 정책으로 이벤트 원본 유실을 막습니다.
- C9 문서/SSoT 정리 결과로 ignored zip snapshot 은 `archives/local-snapshots/`
  local snapshot 으로만 다루며, 제품 문서 표면에는 host-local archive clutter 를 남기지 않습니다.

---

## 0.8.18

`sfs healthcheck` ignores Graphify derived Markdown exports when validating LLM Wiki frontmatter.

체감 변화:

- `llm-wiki/graphify_out/` 아래에 Graphify Markdown export 를 둬도
  `sfs healthcheck` 가 이를 정식 wiki note 로 오인해 frontmatter 오류를 내지 않습니다.
- `llm-wiki/`의 실제 README/topic/DDD notes 에 대한 frontmatter 검사는 그대로 유지됩니다.
- 0.8.17의 read-only healthcheck, report-bug draft-only gate, Graphify-derived workspace
  guidance 는 유지됩니다.

---

## 0.8.17

`sfs healthcheck` joins the packaged runtime, and LLM Wiki guidance now absorbs Graphify-style graph analysis.

체감 변화:

- `sfs healthcheck [--all|--project <dir>...]` 로 설치된 SFS 런타임과 프로젝트 상태를 읽기 전용으로
  점검할 수 있습니다. version drift, boosted command dispatch, routed context, status/divisions,
  `llm-wiki/` frontmatter, `.git/index.lock`, runtime regression subset 를 확인합니다.
- 이상이 감지되면 `report-bug DRAFT` 만 출력합니다. GitHub issue 를 만들거나 `gh` 를 호출하지 않고,
  기존 `sfs report-bug` confirm gate 를 유지합니다.
- `llm-wiki/` 정책과 skeleton 이 Graphify-style graph analysis 를 derived workspace 로 다룹니다.
  `graphify_out/`, node/edge vocabulary, confidence tag, suggested question, hub/surprising edge/gap 은
  wiki 승격 판단의 증거가 되지만 generated graph cache 는 source truth 를 대체하지 않습니다.
- `sfs upgrade` 가 legacy `.sfs-local/` state 와 SFS root docs 를 감지하면,
  `.sfs-local/VERSION` 하나가 없다는 이유로 “not initialized”에서 멈추지 않고
  VERSION/config marker 를 복구한 뒤 기존 sprint/events 상태를 보존하며 upgrade 를 이어갑니다.
- build/smoke/test logs, broad grep/file dump, large diff 처럼 I/O가 무거운
  검증/조사는 scoped worker 가 압축 verdict/evidence 를 반환하도록 Runtime Token Firewall
  guidance 를 강화했습니다. lead agent 는 root cause/fix-shape 판단에 집중합니다.

---

## 0.8.16

Local stable release verification ignores host-local root `.claude` settings while still scanning shipped templates.

체감 변화:

- local stable repo 에 남아 있는 ignored `.claude/settings.local.json` 같은 Claude Code
  세션 파일이 release verifier 를 깨지 않도록 했습니다.
- 제품으로 배송되는 `templates/.claude/**` 는 계속 검사합니다. Stop hook template 누락은
  여전히 잡고, host-local machine path 만 active product surface 에서 제외합니다.
- 최종 배포판은 0.8.16 입니다.

---

## 0.8.15

0.8.14 Stop hook packaging fix 가 MCP server archive hygiene 까지 보존합니다.

체감 변화:

- 0.8.14 tag archive 에 `mcp-server/__pycache__/*.pyc` 가 함께 들어간 release-cut
  hygiene 문제를 고쳤습니다.
- `mcp-server/` 는 공식 MCP host channel 이므로 release cut allowlist 에 포함하고,
  `--delete` sync 로 stale cache 파일을 제거합니다.
- Stop hook template 은 계속 포함되지만, Python cache/build/env 파일은 다시 ignore 됩니다.
  최종 배포판은 0.8.15 입니다.

---

## 0.8.14

0.8.13 자율주행 루프 배치가 Stop hook template까지 tag archive에 포함되어 설치됩니다.

체감 변화:

- 0.8.13 검증 중 packaged archive 에서 `templates/.claude/hooks/solon-stop-suggest.sh` 가
  빠져 vendored install smoke 가 실패하던 문제를 고쳤습니다.
- 이제 path-scoped suggest-only Stop hook 이 실제 tar.gz/zip archive 와 Homebrew/Scoop
  설치본에 포함됩니다.
- 사용자는 0.8.13의 모델 진화 점검 주기, 창업자 모드 문서, deep-interview,
  Ralph-grade 검증 pair, 비개발자 Gate 6 렌즈를 그대로 받되, 설치 패키지까지
  release verifier 를 통과한 0.8.14를 설치합니다.

---

## 0.8.13

자율주행 루프를 모델 진화, 창업자 모드, deep-interview, Ralph-grade 검증, 비개발자 안전 게이트까지 확장합니다.

체감 변화:

- 모델/런타임이 크게 바뀌거나 3-6개월이 지나면 agent adapter, skills, hooks,
  permissions, local overrides 를 점검하라는 유지보수 리듬이 생깁니다.
- README/제품 문서가 Chat/Cowork/Code 와 Idea/MVP/Launch/Scale 창업자 흐름을 더
  명확히 보여줘서, 비개발자도 어떤 모드로 시작할지 고르기 쉬워졌습니다.
- Brainstorm/intake 는 요구가 흐리면 바로 plan 으로 달리지 않고 audience,
  success, failure, constraints 기준의 deep-interview 질문으로 모호성을 줄입니다.
- Stop hook 은 suggest-only 로 설치되어 path-scoped guardrail 을 제안하고, 사용자
  작업을 강제로 덮어쓰지 않는 운영 boundary 를 지킵니다.
- critical flow 는 author 와 verifier 를 나눠 verification-pair evidence 를 남깁니다.
  "나중엔 랄프 루프 모드"의 기반이 될 Ralph-grade 자율 루프 방향이 문서,
  flowcheck, test 로 잠겼습니다.
- 비개발자 작업도 구조, 보안, UX, refactor 분리, secret/PII/logging 위험을 Gate 6 에서
  확인합니다.

---

## 0.8.12

하네스 레퍼런스와 LLM Wiki 지식 냉장고 관점을 SFS 흐름에 흡수합니다.

체감 변화:

- 외부 하네스 엔지니어링 레퍼런스에서 가져온 Phase 0 audit, 팀 아키텍처 명명, baseline eval,
  near-miss trigger, QA pair-read 같은 관점이 SFS 하네스/검토 문서에 들어갑니다.
- `sfs harness map --write` 가 `.sfs-local/harness/evolution-ledger.md` 를 만들고 기존 장부를
  보존합니다. 반복 피드백과 결함을 다음 guardrail 후보로 남길 수 있습니다.
- `llm-wiki/` 는 agent 가 스스로 꺼내 쓰는 지식 냉장고로 설명됩니다. agent 는 source-linked
  note 를 먼저 찾고, 남은 product 판단만 사용자에게 묻는 방향으로 더 분명해졌습니다.
- Codex 는 contract 가 잠긴 뒤 고정 scope 구현, 검증 반복, docs/index sync, review finding 반영을
  더 많이 맡는 worker 처리량 방향으로 정리됩니다.

---

## 0.8.11

macOS bash nounset 환경에서도 wiki anti-drift 검증이 stable package 를 통과합니다.

체감 변화:

- stable tar/zip 패키지처럼 `llm-wiki/README.md`가 없는 환경에서 빈 optional 배열 때문에 guard가 실패하던 문제를 제거했습니다.
- source repo에서는 wiki home anti-drift 문구를 계속 검증하고, packaged runtime에서는 packaged docs/policy 파일로 Solon/wiki 경계를 검증합니다.

---

## 0.8.10

stable product package 경계에 맞춰 wiki anti-drift 검증을 조정합니다.

체감 변화:

- 0.8.9에서 추가한 Solon/wiki 경계 guard가 source repo와 stable product package의 차이를 구분합니다.
- source repo에서는 `llm-wiki/README.md`까지 계속 검사하고, stable tar/zip처럼 owner-side wiki vault가 포함되지 않는 패키지에서는 packaged README, product-shape docs, SFS policy 파일 기준으로 anti-drift 경계를 검증합니다.
- 사용자는 0.8.9의 강의 레퍼런스 렌즈와 Solon Advancement Scorecard를 그대로 받되, release guard까지 통과한 패키지를 설치합니다.

---

## 0.8.9

강의 레퍼런스에서 뽑은 AI-era 운영 렌즈를 SFS 흐름에 흡수하고, wiki 확장이 Solon 의 제품 방향을 흔들지 않도록 scorecard 로 잠급니다.

체감 변화:

- 프롬프팅, RAG 지식창고, AI 직원 온보딩, MCP 광고 제작, source-library wiki,
  ChatOps agent harness, 승리 이론 전략, agent 생산성, Wenote/PMF 강의 인사이트가
  기존 SFS 정책팩과 review lens 로 들어갑니다. 새 lifecycle 명령을 늘리지 않고,
  `brainstorm → plan → implement → review → retro` 흐름을 더 잘 검토하게 만듭니다.
- wiki, RAG, graph, ingest, docs-memory 기능은 **Solon 을 돕는 도구**로 명시됩니다.
  wiki 볼륨이 커져도 Solon 의 방향은 SFS flow, 사람의 product judgment, 검증 가능한
  계약, review/handoff 에 둡니다.
- `Solon Advancement Scorecard` 가 Gate 2/3/6에 붙습니다. wiki 관련 아이디어는
  intent capture, plan contract, review evidence, handoff, repeated-context retrieval 중
  하나를 개선해야 Solon 고도화로 인정되고, 그렇지 않으면 wiki tooling follow-up 으로
  미뤄집니다.

---

## 0.8.8

docs/solon GC 가 report/retro 계승 후보를 llm-wiki 로 먼저 남기고 정리합니다.

체감 변화:

- `sfs tidy --all --wiki-promote --apply` 로 오래 남는 report/retro 를 바로 지우지
  않고, 먼저 `llm-wiki/promotion-candidates/` 에 계승 후보를 만듭니다.
- 후보 노트는 원본 report/retro 링크, 검토 체크리스트, 위키로 승격할 교훈·용어·
  도메인 맵·결정 placeholder 를 담습니다. 원본의 긴 회고/보고 문장을 통째로
  복사하지 않아서 wiki 가 다시 쓰레기통이 되는 일을 줄입니다.
- 원본 report/retro 에도 후보 링크가 남아, 나중에 compact/archive 하더라도 어떤
  지식이 wiki 승격 검토 대상으로 이어졌는지 추적할 수 있습니다.

---

## 0.8.7

llm-wiki 코어 진입 mechanic 으로 목적 있는 Raw 수집과 관측-먼저 프로젝트 맥락 부트스트랩을 더했습니다.

체감 변화:

- `sfs ingest` 로 자료를 Raw intake draft 로 남길 때 **수집 목적/관점 1줄**을 먼저
  기록합니다. `article`, `youtube`, `podcast`, `book`, `research` 별로 필요한
  기본 필드가 갈라져서, 나중에 llm-wiki 로 컴파일할 때 출처와 목적을 잃지 않습니다.
- `sfs init` 이 까는 `llm-wiki/` 골격에 `project-context.md` 가 추가됩니다. 새 프로젝트
  초기에 목적, 사용자, 핵심 산출물, 먼저 답할 질문, 비범위를 짧게 남겨서 프로젝트를
  **쿼리 가능한 기억**으로 만들기 쉬워집니다.
- wiki 진입 가이드는 새 도메인/코드베이스를 만날 때 관측(runtime/log/git/test/config)
  먼저, 그 다음 용어집과 맵을 만드는 흐름을 기본으로 안내합니다.

---

## 0.8.6

AI 시대 wiki 진입·인프라·디자인·분류 관점을 4개 지식팩의 review-lens 로 더했습니다.

체감 변화:

- wiki/온보딩, 인프라, 디자인, 분류(taxonomy) 정책팩에 **AI 시대 검토 질문**이
  추가됩니다. 새 코드베이스 진입 시 관측(APM식)·용어집·맵 먼저와 "왜"(Gold In)
  목적 먼저, AI 산출 증폭에 따른 토큰 예산·Jevons 용량 관점, 생성 시각자산의
  표절-아닌-재창작 IP 위생, 재사용 스킬/프롬프트/자동화의 자산 분류 같은 관점이
  리뷰 렌즈로 들어옵니다.
- 모두 **검토 질문**이라 규칙처럼 작업을 막지 않습니다. llm-wiki 진입은 review
  질문만 흡수했고, 수집·셋업 자동화 같은 코어 제품 메커닉은 별도 단계로 남습니다.

---

## 0.8.5

AI 시대 실무 강연에서 추린 검토 관점을 5개 지식팩의 review-lens 로 더했습니다.

체감 변화:

- 계획·구현·리뷰에서 활성화되는 정책팩(ddd-tdd / qa / 보안·로깅 / 전략-PM /
  도메인 지식 자산)에 **AI 시대 검토 질문**이 추가됩니다. AI 생성 코드의 소유·
  설명 책임, 정적분석+테스트 평준화, secure-by-default, 요청 4요소(목표·기준·
  금지·검증), 문제 근본원인 깊이, 자동화 경계(마지막 20%는 사람), 신뢰·희소성
  해자 같은 관점이 리뷰 렌즈로 들어옵니다.
- 규칙 강제가 아니라 **검토 질문/체크**로 들어오며, 강연 시점 수치는 by-reference
  로 빠져 있습니다. 기존 동작에는 영향이 없습니다(append-only).

---

## 0.8.4

지식 wiki(llm-wiki)를 제품이 직접 깔고, sprint 를 닫을 때 그 wiki 로 의미가 쌓이도록 했습니다.

체감 변화:

- `sfs init` / `sfs upgrade` 를 하면 프로젝트 루트에 **`llm-wiki/` 지식 vault
  골격**이 생깁니다(README + 검색 가이드 + frontmatter + ddd/bug-reports 폴더).
  원치 않으면 `SFS_INSTALL_LLM_WIKI=0` 으로 끌 수 있고, 이미 있으면 덮어쓰지
  않습니다. 기존 프로젝트도 `sfs upgrade` 시 받습니다.
- `sfs retro --close` 로 sprint 를 닫으면 **wiki-compile 체크리스트**가 함께
  생깁니다. report/retro 는 sprint 근거를 그대로 보존하고, llm-wiki 에는 오래
  남길 **의미만** 승격합니다. 공유지식 승격·삭제·민감자료 이동은 사람이
  검토한 뒤에만 반영됩니다(자동 승격 금지).

---

## 0.8.3

`sfs context list` 가 macOS 에서 routed 모듈을 하나도 못 보여주던 문제를 고쳤습니다.

체감 변화:

- macOS 사용자가 `sfs context list` 를 실행하면 이제 top-level/commands/policies
  모듈 목록이 **정상적으로 나옵니다**. 그동안 macOS 의 `find` 가 GNU 전용 옵션을
  지원하지 않아 목록이 비어 나오던 문제였습니다. (Linux/WSL 은 영향 없었습니다.)
- 같은 부류의 호환성 결함이 다시 들어오지 못하도록 회귀 테스트를 추가했습니다 —
  macOS 가 없는 CI 에서도 잡힙니다.

---

## 0.8.2

서브에이전트가 자기 작업을 스스로 검증하지 못하도록 계약에 못을 박았습니다.

체감 변화:

- 작업을 만든 에이전트(저작 lane)와 그 결과를 검증하는 에이전트(검증 lane)는
  이제 **같은 인스턴스이면 안 됩니다**. 자기평가 편향을 막기 위한 규칙으로,
  capsule 계약과 6본부 council 정책에 명문화됐습니다.
- "다른 에이전트"는 기본적으로 다른 인스턴스를 뜻하며, 서로 다른 모델(Codex/
  Gemini)까지 요구하는 것은 Gate 6 교차검증(cross-CPO) 단계뿐입니다. 매 capsule
  마다 모델을 지정하라는 새 필수 항목은 없습니다.

---

## 0.8.1

리뷰 게이트가 "자격 미달 리뷰어 모델"로 조용히 통과되던 결함을 닫았습니다 (Fixes #7).

체감 변화:

- Gate 6 교차검증(cross-CPO)에서 Codex 가 막혀 Gemini 로 넘어갈 때, 리뷰어가
  정책 모델(`gemini-3.1-pro-preview`)이 **아닌** 하위 모델로 내려가면 이제 게이트를
  통과시키지 않고 **멈추고 알립니다**. 하위 모델로 통과시키던 동작이 사라졌습니다.
- 리뷰어 모델 자격은 실제 호출 `--model` 플래그/route 핀으로 판정합니다. 리뷰어가
  응답 본문에서 자기 모델명을 뭐라고 말하든(예: preview 모델이 자기를 "2.5-pro"라
  자칭) 그 텍스트는 신뢰하지 않습니다.
- `sfs flowcheck` 가 리뷰어-tier 위반(하위 모델·host 기본모델·route 누락)을
  critical 로 잡습니다.

---

## 0.8.0

SFS 제품 결함을 공식 채널로 모으고, SFS 가 문서대로 실행됐는지 스스로 점검하는 탐지층을 더했습니다.

체감 변화:

- SFS 자체 버그를 발견하면 `sfs report-bug` 로 공식 채널(GitHub Issues)에 정식
  제출합니다. 제출 직후 이슈 URL·요약을 보여주고 **당신이 확정하기 전에는 수정에
  들어가지 않습니다.**
- 작업단위가 끝날 때 `sfs flowcheck` 가 "에러는 없었지만 문서대로 안 돈" 조용한
  이탈(잘못된 모델 tier, 빠진/뒤바뀐 게이트, 안 알린 충돌, 리뷰 없이 ship)을
  잡아냅니다. 심각 위반은 작업단위 done 을 막고(waiver 로만 통과), 경미 위반은
  경고만 합니다.
- 모델 라우팅 모순(#4)을 닫았습니다. 기본값에서 구현 워커가 호스트 상위 모델로
  새지 않고 정책 워커 tier(예: Sonnet)로 정확히 붙습니다. 설정이 정책과 어긋나면
  설치·업그레이드가 경고로 알려주되, 당신 설정을 마음대로 고치지 않습니다.
- **당신의 명시 명령이 SFS 기본값보다 우선합니다.** 기본에서 벗어나려면 범위
  (이번 작업/이번 sprint/해제 전까지)를 정하고, 시작·만료·충돌은 항상 알립니다.
  SFS 기본값으로 조용히 되돌아가지 않습니다.

---

## 0.7.12

강의 요약에서 뽑은 고도화 백로그와 인계 회귀방지를 한 버전으로 묶었습니다.

체감 변화:

- 도메인 엔티티·관계를 바꾸는 작업에 **ontology 리뷰 렌즈**가 자동으로 붙어,
  엔티티 이름·관계·불변식·하위호환과 자산/위키/테스트 재정합을 점검합니다.
- 서브에이전트로 일을 넘길 때 지켜야 할 **capsule 필드 계약**(목표/수용기준/
  파일범위/허용도구/출력경로/토큰예산/타임아웃/PII규칙)이 문서로 못박혔습니다.
- 새 **mcp-tool-zero** 템플릿으로 좁은 커스텀 MCP 도구를 안전 기본값으로 바로
  시작할 수 있습니다.
- 샌드박스에서 막힌 작업은 사용자에게 복붙을 떠넘기지 않고 **개발 런타임으로
  라우팅**하도록 기준이 바뀌었습니다.
- `sfs handoff verify` 가 인계가 **어느 디렉터리/레포에서 열려야 하는지**까지
  검증해, docset 과 distribution 을 헷갈려 인계가 조용히 실패하던 문제를 막습니다.

---

## 0.7.11

이번 버전은 듀얼 레포 인계 검증과 검색 도구 기준을 같은 search / verification
표면으로 묶어 정리합니다. 이전에는 `sfs handoff verify` 가 단일 디렉터리만
가정해, 작업 docset 과 안정 product 저장소가 분리된 환경에서 VERSION /
CHANGELOG 를 엉뚱한 쪽에서 찾아 실제로는 멀쩡한 인계를 어긋남으로 잘못
보고했습니다.

체감 변화:

- **`sfs handoff verify` 가 듀얼 레포를 이해합니다.** `--product-dir` /
  `--docset-dir` 로 VERSION·CHANGELOG(product)와 PROGRESS·HANDOFF·세션
  인덱스(docset)를 각각 다른 저장소에서 읽습니다. `--dir` 만 쓰던 기존
  방식은 그대로 동작합니다. docset 의 `PROGRESS.md` 앞부분에
  `product_repo_path:` 를 적어 두면 옵션 없이도 product 위치를 찾습니다.
- **검색 도구 기준이 정책이 됐습니다.** 에이전트는 코드/텍스트 검색에
  `rg`(ripgrep)를 기본으로 쓰고, 없을 때만 `grep` 으로 내려갑니다. ast-grep
  과 Aider 는 SFS 본체(대부분 bash + Markdown)에는 득이 적어 도입 보류로
  평가하고, 언어별 consumer 프로젝트의 선택 확장으로 남겼습니다.

contract test 2건이 듀얼 레포 검증 동작과 검색 정책/어댑터 문구를 잠가,
이 표면이 다시 어긋나면 즉시 fail 합니다.

## 0.7.10

이번 버전은 세션 인계 누락과 운영 로그 비대화를 같은 뿌리 문제로 보고
탐지·차단 표면을 추가합니다. 이전에는 PROGRESS.md 의 마지막 릴리스 기록이
실제 VERSION 보다 16 릴리스나 뒤처져도(0.6.141 vs 0.7.9) 자동으로 잡히지
않았고, 운영 로그가 455줄까지 자라도 막는 규칙이 prompt 안에 없었습니다.

체감 변화:

- **`sfs harness doctor` 가 운영 로그를 본다.** 새 "Operational Logs And
  Size" 섹션이 (1) VERSION 과 PROGRESS.md 릴리스 기록의 lag 를, (2)
  in-scope 마크다운의 200줄 초과를 파일별로 보고합니다. patch 1개 차이는
  warn, minor 차이/5개 이상은 partial, 250줄 초과는 release-blocking fail.
- **`sfs handoff verify` 신규 명령.** 세션을 넘기기 전에 durable handoff
  표면 8개(VERSION / CHANGELOG headline / PROGRESS 릴리스 기록 / 세션
  history / resume hint / HANDOFF stub / 세션 인덱스 / 200줄 준수)가 실제
  상태와 일치하는지 PASS / MISMATCH / N/A 로 한 페이지에 출력합니다.
  하나라도 어긋나면 실패로 끝나, 다음 세션이 stale 한 인계로 시작하지
  않습니다.
- **200줄 규칙이 routed policy 가 됐습니다.** `md-line-budget` 정책이
  컨텍스트에 라우팅되어, 에이전트가 새 문서를 쓸 때 ceiling 과 archive
  회전 절차를 prompt 안에서 직접 봅니다.

contract test 2건이 정책 문서 자체와 lag detector 동작을 잠가, 향후 이
표면이 다시 빠지면 즉시 fail 합니다.

## 0.7.9

이번 버전은 0.7.1 의 `*"ui"*` / `*"ops"*` 좁힘에 이어 review lens 의
형제 broad-substring 패턴을 일괄 sweep 한 사전 회귀 방지 patch 입니다.
회귀 보고가 들어오기 전에 미리 막는 차원의 quality cleanup — 회귀 0건,
타이트 함수.

infer_review_lens TEXT 와 review_path_lens_signal PATH 양쪽에서:

- **security**: `*"auth"*` (→ "author") / `*"secret"*` (→ "secretary")
  / `*"token"*` (→ "tokenize") 를 word-boundary + 고-신호 phrase 로 좁힘.
- **performance**: `*"perf"*` 는 `*"performance"*` 와 중복이고
  "perfect"/"perform" 을 false-positive 매칭하므로 제거. `*"memory"*`
  → `memory leak` / `out of memory` 등. `*"query"*` → `sql query` /
  `slow query`.
- **ddd-tdd**: `*"aggregate"*` (→ "aggregated data") 를 `aggregate
  root` / `aggregate boundary` 로 좁힘. PATH 의 `*ddd*` / `*tdd*` (→
  "daddy") 도 `ddd/` / `-ddd-` 형태로.
- **management-admin**: `*"tax"*` (→ "taxonomy" / "syntax") 를 `tax
  form` / `taxpayer` 등으로 좁힘.
- **api-contract**: bare `*api*` (→ "rapid" / "scrappy") 와 bare
  `*interface*` 를 dir-style 로.
- **design**: bare `*ui*` (→ "guide" / "build" / "library") 와 bare
  `*ux*` (→ "auxiliary") 를 `ui/` / `-ui-` / `react-ui` / `ui-kit`
  형태로.

`test-review-lens-false-positive-rejection` 신규 contract test 가 각
rejection 케이스를 짝지어진 positive 케이스와 함께 잠금. 향후 누가
패턴을 다시 넓히면 즉시 fail.

기존 6개 review test 모두 그대로 통과 — sweep 가 정당한 routing 결정을
하나도 깨지 않음.

## 0.7.8

이번 버전은 사용자용 산출물 (README / GUIDE / RELEASE-NOTES / 보고서
/ 학습 노트) 의 글쓰기 품질 계약을 정식 routed policy 로 박는 patch
입니다. 그동안 kernel.md 의 룰은 "evidence 잃지 마라" 라는 floor 만
있었고, "padding 도 하지 마라" 라는 ceiling 이 없었습니다. codex 가
사용자 study-note README 에 미사여구 잔뜩 박은 사건이 그 격차를
드러냈고, 0.7.8 이 그 격차를 닫습니다.

- `policies/writing-discipline.md` + `.ko.md` 신설. 금지 6개 (서두 /
  자기 칭찬 / 정보 없는 hedging / 재진술 / 마무리 상투구 / 마케팅 톤)
  와 보존 5개 (사실 / 결정 / 근거 / 경계 / 위험 경고) 를 enumeration
  으로 명시. review 단계 체크 항목도 포함.
- `kernel.md` 한 줄 cross-link 추가. 금지 카테고리는 그 한 줄 안에
  inline 으로 다 있어, kernel 만 읽는 agent 도 룰을 안다.
- `_INDEX.md` 등재.
- `docs/ko/10x-value/06-token-diet-10x.md` 의 "Caveman persona" 행에
  한 줄 disambiguation 추가 — Caveman 은 *스타일 토글* 이지 *글쓰기
  품질 계약* 이 아님을 명시하고, 품질 계약은 새 policy 로 연결.
- `test-writing-discipline-policy` contract test 가 위 전체 wiring
  (양 언어 frontmatter, load_when, 금지/보존 enumeration, kernel
  cross-link inline 룰, _INDEX 등재, token-diet disambiguation,
  실 sfs context cat 해석) 을 한꺼번에 잠금.

## 0.7.7

이번 버전은 0.7.x Flow Integration 4-patch 시리즈의 마지막 patch 입니다.
test suite 가 110 → 122 로 늘면서 flat summary 의 신호가 흐려졌고, 0.7.7
은 카테고리별 breakdown 을 기존 summary 옆에 붙입니다 — flat 형식은 그대로
보존되어 CI 가 깨지지 않습니다.

- `tests/run-all.sh` 가 모든 `test-*.sh` 를 8개 카테고리 (`host-channel`
  / `harness` / `release` / `packaging` / `review` / `doc-and-context` /
  `hygiene-and-policy` / `sfs-core` + `other` 폴백) 로 분류합니다. 기존
  `=== test-X.sh ===` 헤더 옆에 `[category]` 가 붙고, 끝의 summary 다음에
  "by category:" 절이 추가됩니다.
- 기존 flat `PASS: N / FAIL: M / Failed scripts:` 출력은 그대로 보존 —
  external grep 깨지지 않음.
- `test-run-all-categorization` 신규 contract test 가 분류기의 정확성과
  per-category summary 의 존재를 잠금.

**0.7.x Flow Integration 시리즈 마감**: 0.7.4 (entry surfaces) → 0.7.5
(bootstrap + install) → 0.7.6 (harness doctor + map) → 0.7.7 (test
categorization). 4 patch 모두 additive — 기존 flow signature 0건 변경.

## 0.7.6

이번 버전은 0.7.0~0.7.5 가 추가한 4개 host-channel surface 를 sfs
harness doctor / map 이 직접 점검 + 출력하도록 묶는 patch 입니다. 기존
harness 검사 (entry / divisions / tests / release) 0건 변경 — 새 절과
새 행이 옆에 붙는 형태입니다.

- `sfs harness doctor` 끝에 "Host Channels And 0.7.0 Surface" 절이 자동
  출력됩니다. CLI 채널 (항상 present), MCP server artifact,
  Solon-safe permission preset, Claude Agent SDK scaffold 의 availability
  + 본 프로젝트의 agent-build track signal (Gate 6 review 가
  `agent-build` lens 로 자동 라우팅될지) 까지 한 페이지에 정리.
- `sfs harness map` / `sfs harness map --write` 의 Harness Components
  테이블에 "Host channels (0.7.0+)" 행 한 줄 추가. 같은 4 channel 상태가
  written map 에 그대로 박힙니다.
- `scripts/sfs-harness.sh` 안 4개 detector helper 신설
  (`detect_mcp_server_artifact`, `detect_solon_safe_preset`,
  `detect_agent_sdk_template`, `detect_agent_build_track`).
- `test-harness-host-channel-surface` 신규 contract test 가 위 변경의
  회귀를 잠금.

## 0.7.5

이번 버전은 0.7.4 documentation 정리에 이어 bootstrap / install 의 0.7.0
surface 연결을 마무리하는 patch 입니다. 기존 Spring/Kotlin bootstrap 경로
0건 변경 — 전부 additive.

- `sfs bootstrap --experimental --template <name> <project-name>` 정식
  지원. `claude-agent-sdk-zero` 같은 0.7.0+ scaffold 가 한 줄로 작동.
  always-on placeholder (`<PROJECT-NAME>` / `<DATE>` / `<DOMAIN>`) 만
  치환하고 Spring-only token 은 건드리지 않음.
- `install.sh` 의 "다음 단계" 안내 끝에 §8 "0.7.0+ host-agnostic 진입"
  절 추가. MCP bridge (source clone 만 지원하는 현 상태 그대로 명시),
  권한 baseline, Agent SDK scaffold 한 줄 명령, agent-build lens 자동
  라우팅까지 4개 surface 의 진입점을 한 페이지에 정리.
- `test-bootstrap-template-flag` / `test-install-completion-hints` 신규
  두 contract test 가 위 변경의 회귀를 잠금.

## 0.7.4

이번 버전은 0.7.0~0.7.3 에서 추가된 host-agnostic surface (MCP server +
permission preset + agent-build lens + Agent SDK scaffold) 를 사용자가
처음 만나는 entry 문서들에 명시한 doc-side 정리 patch 입니다. 기존 절
0건 rewrite — 전부 additive.

- `docs/{ko,en}/current-product-shape/23-host-channels-and-mcp.md` 신규
  child + parent index 의 split_children 에 등록. CLI / MCP / Agent SDK
  세 채널을 동등하게 7-step 진입으로 명시하고 host 별 등록 경로 / 권한
  baseline / agent-build lens 자동 라우팅을 한 페이지에 정리.
- `README/04-section.md` (설치) 에 "MCP host 채널 (0.7.0+)" subsection
  추가 — 기존 CLI runtime 표 바로 다음.
- `docs/maintenance/methodology-7-step.md` 에 "Host-agnostic 진입" 절
  추가.
- `templates/SFS.md.template` 에 "Host channel detection" 절 추가.
- adapter doc frontmatter (`CLAUDE.md.template` / `AGENTS.md.template` /
  `GEMINI.md.template` / `SFS.md.template`) 의 `detail_sources` 에
  `mcp-server/README.md` 와 `.sfs-local/presets/solon-safe-permissions.yaml`
  명시. adapter body 는 여전히 frontmatter-only (오염 0).
- `test-host-channel-docs-coverage` 신규 — 위 변경이 한 번 들어간 뒤
  다시 빠지지 않도록 회귀 잠금.

## 0.7.3

이번 버전은 0.7.2 doc-separation 작업의 consumer-side 후속입니다. 이미
polluted CLAUDE.md / AGENTS.md / GEMINI.md 를 가진 consumer 가
sfs status 를 칠 때 한 줄 WARN 으로 자동 인지 + `sfs agent doctor --fix`
한 줄 안내로 AS 경로가 표면화됩니다.

- `sfs status` 가 polluted root adapter doc 을 감지하면 한 줄 hygiene
  notice + `sfs agent doctor --fix` hint 출력. AS path 자체는 0.6.139
  부터 작동하던 것이고, 0.7.3 은 *발견* 표면을 추가.
- `mcp-server/PUBLISHING.md` 신설 — `solon-mcp` PyPI cut 매뉴얼 recipe.
  README 의 `pipx install solon-mcp` 가 미래 명령임을 다시 명시하면서
  cut 일정 / 단계를 PUBLISHING.md 로 연결.
- `.gitignore` 확장 — `mcp-server/__pycache__/`, `.pytest_cache/`,
  `*.egg-info/`, `build/`, `dist/`, `.venv/` 등 0.7.0 이후 자주 등장하는
  Python 부산물 일괄 차단.
- `test-polluted-adapter-hygiene-notice.sh` 신규 — 0.7.3 의 detection
  + AS hint 가 회귀하지 않도록 잠금.

## 0.7.2

이번 버전은 사용자가 보고한 문서 관심사 미분리 제품 버그를 해결합니다.
top-level `CLAUDE.md` / `AGENTS.md` 같은 agent 지침서에 프로젝트 정체성,
배포 원칙, 수정 체크리스트, 방법론 reference 같은 운영 문서 내용이 박혀
있던 문제를 분리하고, hygiene test 로 재발을 잠급니다.

- `CLAUDE.md` 본문에서 프로젝트 정체성 / 배포 원칙 / 수정 체크리스트 /
  방법론 요약 6 섹션을 떼어 `docs/maintenance/` 의 5개 dedicated doc 으로
  이주. 본문은 agent 직접 행동 룰 (절대 금지) 과 짧은 cross-link 만 남김.
- `AGENTS.md` 의 dev-staging 관계 절도 `docs/maintenance/release-policy.md`
  § R-D1 으로 이주.
- 신규 hygiene test (`test-agent-entry-doc-hygiene.sh`) 가 향후 동일 유형
  의 오염 (forbidden H2 / 100 line 초과 / frontmatter_only 마커 손실) 을
  잠급니다.
- 기존 consumer 의 polluted CLAUDE.md 는 `sfs upgrade` 또는 `sfs agent
  doctor --fix` 가 이미 (0.6.139+) 자동으로 frontmatter-only template 로
  refactor 합니다. 본 버전은 그 capability 를 변경하지 않습니다 — 단지
  maintainer 측에서도 같은 hygiene shape 을 강제해 upstream 오염이
  재발하지 않도록 합니다.

## 0.7.1

이번 버전은 0.7.0 통합 검증 (`INTEGRATION-VERIFY-2026-05-28.md`) 에서
발견된 4개 항목을 한 patch 로 닫습니다. 기존 flow signature 0건 변경 —
전부 additive.

- **agent-build lens 자동 라우팅 회귀 수정**: case chain 안 broader-
  substring 패턴 (`*"ui"*` 가 "**bui**ld" 매칭) 에 outrank 되던 문제를
  agent-build 분기를 case 맨 앞으로 옮겨 해결. 이제 plan/brainstorm 에
  "MCP server", "Claude Agent SDK", "sub-agent" 가 등장하면 `--lens auto`
  로 agent-build 가 정상 라우팅됩니다.
- **broad-substring lens 패턴 좁힘**: `*"ui"*` / `*"ux"*` / `*"ops"*` 를
  word-boundary 형태 (`*" ui "*`, `*"ui/"*`, `*" ops "*`, `*"ops/"*` 등)
  로 좁히고, `devops`/`sre`/`design system` 같은 high-signal alternative
  를 추가. "guide", "build", "fluid", "auxiliary" 같은 흔한 영어 단어가
  더 이상 false positive 를 일으키지 않습니다.
- **`sfs context list [commands|policies|all]` 신설**: routed module 슬러그
  색인을 한 줄로 보여주는 discoverability helper. 0.7.0 의 신규 정책
  (`policies/agent-build-review-lens`) 도 즉시 발견됩니다.
- **MCP server install 안내 명확화**: 0.7.x 는 source clone 만 지원하고
  `pipx install solon-mcp` 는 PyPI publish 후의 미래 shape 임을 README
  서두에 명시.

## 0.7.0

이번 버전은 Solon 을 host-agnostic 하게 확장하는 첫 minor bump 입니다.
bash SSoT 원칙은 그대로 두고, non-bash 호스트(Claude Desktop, Claude in
Chrome, Cursor, Claude Agent SDK 등)에서 Solon 을 구동할 4가지 경로를
추가합니다.

- **Solon MCP server (`mcp-server/`)** — `sfs` 7-step flow 를 12개 MCP
  tool 로 노출하는 Python stdio 서버. bash stdout 을 verbatim forward
  하여 kernel.md SSoT 룰을 어기지 않습니다. `pipx install solon-mcp` 로
  설치 후 호스트의 MCP config 에 `solon-mcp` 등록만 하면 끝.
- **Solon-safe permission preset** — CLAUDE.md "절대 금지" 룰을
  runtime-agnostic YAML 로 export. Claude Code / Agent SDK / Codex
  / Cursor 가 모두 받아쓸 수 있는 형식. auto-push, destructive bash,
  hard reset 은 기본 denied.
- **`agent-build` review lens** — agent / MCP / sub-agent 를 ship 하는
  sprint 에 자동 라우팅되는 review lens. tool surface scope, permission
  posture, sub-agent isolation, system prompt drift, SSoT, evidence,
  failure modes 7개 subsection 을 CPO 가 점검합니다.
- **`claude-agent-sdk-zero` template** — Python Claude Agent SDK 프로젝트
  scaffold. solon-mcp + solon-safe permission preset 가 기본으로 wired
  됩니다.
- 신규 test 4개로 회귀 방지: `test-mcp-server-contract`,
  `test-solon-safe-permissions-preset`, `test-agent-build-review-lens`,
  `test-claude-agent-sdk-zero-template`.

## 0.6.145

이번 버전은 user-facing docs 정책을 "HTML-first" 에서 "HTML-encouraged" 로
약화하여 정책 문구와 실제 docs/ 산출물 형식 사이의 격차를 닫고, 동시에
source-side packaging fixture 의 stale 한 v0.6.17 참조를 현재 버전으로
sync 합니다.

- 8개 agent surface 의 정책 표현을 일관되게 갱신.
- 현재 docs/, GUIDE/, README/, BEGINNER-GUIDE/ 의 104개 MD 산출물은 GitHub
  렌더링 표면을 기준으로 의도적으로 MD 유지로 명시.
- 정책-실태 격차 회귀를 막기 위해 test 가 "MD 허용" 문구의 존재까지 검증.
- `packaging/scoop/sfs.json` 과 `packaging/homebrew/sfs.rb` 의 버전/URL/
  extract_dir 을 v0.6.17 → v0.6.145 로 갱신. 채널 SoT 는 여전히 외부
  tap/bucket repo 이지만, source-side fixture 가 127 release 차이로 벌어진
  상태를 정리해 onboarding 시 혼동을 줄임.

## 0.6.144

이번 버전은 테스트 하네스의 stdout 신호-대-소음 비율과 macOS bash 3.2 +
`set -u` 회귀 방지의 정적 검출 범위를 동시에 조여줍니다.

- `install.sh` 의 confirm() 가 `--yes` (비대화) 모드에서 한국어 prompt 한 줄을
  더 이상 stderr 로 흘리지 않습니다. `SFS_INSTALL_VERBOSE_CONFIRM=1` 로 명시적
  opt-in 시에만 옛 동작이 유지됩니다.
- `test-nounset-empty-array-expansion` 이 `scripts/` 와 template scripts 의
  모든 bash 스크립트를 정적으로 스캔해 unsafe `"${arr[@]}"` 사용지점을
  찾아냅니다. 새 스크립트가 들어와도 0.6.2 류 회귀가 사전에 차단됩니다.
- 새 정적 체크가 발견한 11개 call site 에 안전 idiom / 길이 가드 / nounset-safe
  주석을 일괄 적용.

## 0.6.143

이번 버전은 0.6.142 에서 잠시 grandfathered 됐던 maintainer 측 dev-staging
라벨을 active 제품 표면에서 일괄 제거하고, hygiene 테스트가 이 누설을
차단하도록 잠급니다.

- 8 개 template script 의 header banner 에서 `solon-mvp-dist/...` 경로 prefix
  를 제거하고 `Path note` 와 `Visibility` 표기를 도메인 중립 버전으로 갱신.
- `AGENTS.md` 의 maintainer 측 dev workflow 설명에서 private staging workdir
  이름을 제거.
- `scripts/install-cli-discovery.sh` comment 와 `tests/fixtures/token-diet/*.md`
  review-finding sample, 그리고 `tests/test-md-split-audit.sh` assertion 의
  `solon-mvp-dist` 인용 제거.
- private-dev-path hygiene 테스트가 이제 `solon-mvp-dist` 등장 자체를
  실패 신호로 본다.

## 0.6.142

이번 버전은 0.6.139 thin-router 리팩토링 이후 발견된 review executor stdin
hang 회귀와, 0.6.141 harness 추가 시 함께 들어간 maintainer-private dev path
누설을 정리합니다.

- `sfs review --executor gemini` 가 authenticated 분기에서 `gemini --help`
  capability probe 의 stdin 을 닫지 않아 일부 CLI 환경에서 무한 대기하던
  문제를 수정했습니다. 같은 방식으로 `claude auth status` / `codex login
  status` 점검도 stdin 을 닫습니다.
- `scripts/sfs-harness.sh` 안의 dated docset 경로 두 곳을 제거하고, 비표준
  test/release 위치를 쓰는 프로젝트는 `SFS_HARNESS_EXTRA_TEST_DIRS` /
  `SFS_HARNESS_EXTRA_RELEASE_FILES` 환경변수로 선언하도록 일반화했습니다.
- `install.sh` 가 `.sfs-local/divisions.yaml` 생성 시 `<PROJECT-NAME>` 도
  치환합니다. `model-profiles.yaml` 과 일관성이 맞춰집니다.
- private-dev-path hygiene 테스트가 dated docset 패턴 (`YYYY-MM-DD-sfs-v\d`)
  과 `phase1-mvp-templates` 를 직접 검출하도록 강화됐습니다.

## 0.6.141

이번 버전은 하네스 엔지니어링을 원칙에서 프로젝트 점검 기능으로 끌어올립니다.

- `sfs harness doctor` 로 현재 프로젝트가 AI 에게 오래 맡길 수 있는 환경인지 점검합니다.
- 점검 대상은 얇은 진입 문서, routed context, 활성 6본부 council, artifact/memory, wiki 또는 bug recurrence memory, test, release/check rail 입니다.
- `sfs harness map` 은 agent 역할, skill/policy, orchestrator rail, artifact, memory, test, release loop, human-owned boundary 를 한 번에 보여줍니다.
- `sfs harness map --write` 는 `.sfs-local/harness/harness-map.md` 를 만들어 긴 자율 작업이나 선택적 parallel-agent 작업 전에 운영 설계를 확인할 수 있게 합니다.

## 0.6.140

이번 버전은 0.6.139 의 `SFS.md` thin router 기능을 test-clean artifact 로 다시 배포합니다.

- 0.6.139 에서 기능과 채널 업데이트는 올라갔지만, stable artifact 안의 version regression 두 개가 이전 버전을 기대해 release verifier 에서 실패했습니다.
- 0.6.140 은 같은 `SFS.md` router refactor 기능에 version test 동기화를 포함해 tar.gz, zip, local stable 제품 테스트가 통과하도록 재컷합니다.
- 사용자가 체감하는 기능은 0.6.139 와 동일합니다. `SFS.md` 는 얇은 router 로 유지되고, `sfs doctor --fix` 는 기존 프로젝트의 비대한 `SFS.md` 를 archive 후 `## 프로젝트 개요` 보존 rewrite 합니다.

## 0.6.139

이번 버전은 `SFS.md` 를 정책 덤프가 아니라 얇은 프로젝트 router 로 되돌립니다.

- `SFS.md.template` 는 frontmatter, `## 프로젝트 개요`, read order, default entry, output contract, maintenance pointer 만 담습니다.
- 상세 SFS 규칙은 `kernel.md`, routed command/policy context, skills, command adapter 에 남기고 `SFS.md` 에 복제하지 않습니다.
- `sfs doctor --fix` 는 기존 프로젝트의 비대한 `SFS.md` 를 감지해 archive 하고, `## 프로젝트 개요` 를 보존한 채 thin router 로 되돌립니다.
- `sfs upgrade` 는 runtime 이 이미 최신이라도 `SFS.md router refactor` post-step 을 실행해 study-note 같은 적용 프로젝트에서 같은 문제가 재발하지 않도록 합니다.
- LLM Wiki bug report 와 `test-sfs-router-doc-refactor.sh` 로 발견일, 원인, 수정 경로, 재발 확인 항목을 추적합니다.

## 0.6.138

이번 버전은 AI 시대의 도메인 지식 해자를 SFS 실행 흐름 안에 넣습니다.

- 전문가 노하우, 반복 설명, craft rule 을 AI 가 재사용할 수 있는 glossary, playbook, skill, fixture, review lens, wiki map 으로 승격하는 기준을 추가합니다.
- 6본부 council 을 domain-asset capture loop 로 명시해 strategy-PM, taxonomy, design, dev, QA, infra 가 각자 발견한 실무 판단을 `asset_candidate` 로 남깁니다.
- plan/implement/review 템플릿에 Domain Asset Promotion/Implementation/Review Ledger 를 추가해 source, owner, artifact path, verification, publication boundary 가 검수되게 합니다.
- 관련 EN/KO 제품 문서와 회귀 테스트를 갱신해 6본부 지식팩이 장식용 표가 아니라 재사용 가능한 AI 지식 자산 수집 장치로 동작하도록 고정합니다.

## 0.6.137

이번 버전은 하네스 엔지니어링 원칙을 SFS 제품 흐름 안에 직접 넣습니다.

- 프롬프트로 더 잘해 달라고 부탁하는 대신, 에이전트가 잘할 수밖에 없는 작업 구조를 제품 규칙으로 둡니다.
- 작업마다 필요한 도구 표면을 작게 유지하고, 프로젝트 구조와 문서, 파일명, 테스트 루틴을 에이전트가 읽는 하나의 큰 프롬프트로 다룹니다.
- 구현 뒤 테스트와 self-review 를 거치는 검증 루프를 기본 기대치로 올립니다.
- 결제, 환불, 수수료, 예외 정책처럼 이해와 설계가 필요한 판단은 사람이 소유해야 한다는 경계를 명시합니다.
- Claude/Codex/Gemini/SFS 어댑터, 제품 문서, LLM Wiki map/index 를 함께 갱신해 이후 작업에서도 같은 하네스가 유지됩니다.

## 0.6.136

이번 버전은 LLM Wiki 와 AI 업무 지시 원칙을 SOLON 제품 플로우 안에 직접 넣습니다.

- LLM Wiki 와 RAG 의 역할을 분리해, 문서가 들어올 때 정리되는 지식과 질문 시점 검색을 함께 쓰도록 정리합니다.
- `목표`, `재료`, `먼저 물어볼 조건`, `결과 형식`을 `start`, `brainstorm`, `plan` 흐름과 sprint template 에 반영합니다.
- 작업 크기를 one-off, repeated, batch workspace 로 나눠 불필요한 ceremony 없이 적절한 제품 플로우로 라우팅합니다.
- 관련 제품 문서와 LLM Wiki 인덱스를 함께 갱신해 이후 업그레이드에서도 같은 경계를 유지합니다.

## 0.6.135

이번 버전은 packaging fixture 와 실제 Homebrew/Scoop 배포 채널의 권위 경계를 명확히 문서화합니다.

- 제품 repo 의 `packaging/homebrew/sfs.rb` 와 `packaging/scoop/sfs.json` 이 최신 배포 SoT 가 아니라 source-side fixture 임을 명시합니다.
- Homebrew/Scoop 최신 상태 확인 경로를 `sfs version --check`, 외부 tap/bucket, release verifier 로 정리합니다.

## 0.6.134

이번 버전은 review auth hang 회귀 테스트가 느린 CI 에서도 안정적으로 PASS 하도록 보강합니다.

- 비대화 review timeout guard 자체는 0.6.133 과 동일하게 유지합니다.
- 테스트의 바깥쪽 안전 timeout 만 여유 있게 늘려, SFS 내부 bounded timeout 결과를 기다립니다.

## 0.6.133

이번 버전은 Linux/GNU 환경에서 남던 migration, archive lock, review auth QA 실패를 닫습니다.

- 백슬래시가 들어간 파일명도 GNU `sha256sum` escaping 때문에 data-loss mismatch 로 오진하지 않습니다.
- `flock` 이 있는 환경과 advisory PID lock 환경 모두에서 archive race-lock 테스트가 같은 계약을 검증합니다.
- 비대화 review 실행에서 timeout 을 무제한으로 둬도 SFS 가 안전한 bounded timeout 으로 막아 hang 을 방지합니다.

## 0.6.132

이번 버전은 source dist 가 아니라 실제 stable product artifact 기준으로 테스트가 깨지는 문제를 막습니다.

- release cut 이 삭제된 테스트/문서 파일을 stable product 에 남기지 않습니다.
- maintainer 전용 handoff/archive 파일은 제품 릴리스에서 제거합니다.
- standalone product layout 에서도 제품 테스트가 부모 docset 부재만으로 실패하지 않습니다.
- release verifier 가 local stable product `tests/run-all.sh` PASS 를 확인합니다.

## 0.6.131

이번 버전은 제품에 포함되는 active 문서와 release-sequence 출력에서 private dev staging 경로명이 새지 않도록 막습니다.

- release cut 안내는 구체적인 개인 checkout 이름 대신 `private dev staging checkout` 으로 설명합니다.
- private path hygiene 회귀 테스트를 추가해 같은 문자열이 다시 active 제품 표면에 들어오면 실패합니다.

## 0.6.130

이번 버전은 `메모   앱 검색`처럼 공백이 흔들린 한국어 note 앱 요청도 올바르게 note CLI 작업으로 분류합니다.

- 한국어 note/memo intent 를 검사하기 전에 연속 공백을 정규화합니다.
- `메모리 누수 수정` 같은 일반 작업은 계속 note CLI 로 오분류하지 않습니다.

## 0.6.129

이번 버전은 `메모리 누수 수정` 같은 한국어 일반 작업이 note CLI 작업으로 잘못 분류되는 문제를 막습니다.

- note CLI 추론은 `note CLI`, `메모 앱`, `메모장`, `노트 앱` 처럼 명시적인 노트/메모 도구 표현에만 반응합니다.
- `메모리`처럼 다른 단어 안에 들어간 `메모` substring 은 note CLI 근거로 쓰지 않습니다.

## 0.6.128

이번 버전은 Gate 6 cross review 가 최신 self-CPO PASS 를 못 봐서 partial loop 에 빠지는 문제를 막습니다.

- cross review prompt 안에 같은 Gate 의 최신 self-CPO PASS 결과와 excerpt 를 별도 캡슐로 직접 넣습니다.
- Gate 6 partial next action 이 내부 id 때문에 `--gate 4` 로 안내되던 출력 버그를 고쳤습니다.
- `production` 단어가 `product` 로 오인되어 note CLI 작업이 상품/검색 도메인으로 분류되는 문제를 막았습니다.
- 테스트가 0개 실행된 명령 출력은 exit 0 이어도 acceptance evidence 로 인정하지 않도록 Gate 6 검수 문구를 추가했습니다.

## 0.6.127

이번 버전은 channel publish workflow 파일 자체가 GitHub Actions 에서 invalid YAML 로 거절되던 문제를 막습니다.

- workflow 안의 token 누락 안내를 YAML-safe `printf` 방식으로 바꿨습니다.
- 릴리스 테스트가 `.github/workflows/*.yml` 전체를 YAML 로 파싱해 syntax failure 를 먼저 잡습니다.
- product push 에서 optional channel workflow 가 jobs=0 빨간 check 로 남는 문제를 실제 원인까지 닫습니다.

## 0.6.126

이번 버전은 product repo push 때 optional channel workflow 가 빨간 zero-job check 로 남는 문제를 막습니다.

- `publish-product-channels.yml` 파일 변경 push 는 설명만 출력하는 no-op validation job 으로 성공 처리합니다.
- 실제 Homebrew/Scoop channel publish job 은 `workflow_dispatch` 에서만 실행됩니다.
- `SOLON_RELEASE_BOT_TOKEN` 이 없는 현재 운영에서는 preflight 의 `manual_required` 결과대로 로컬 Homebrew/Scoop push 를 사용합니다.
- 즉, optional 자동화 lane 이 준비되지 않았다는 이유로 release Actions 가 실패처럼 보이지 않습니다.

## 0.6.125

이번 버전은 Homebrew/Scoop channel publish workflow 의 토큰 누락을 release 후반에야 발견하는 문제를 줄입니다.

- `publish-product-channels.yml` 을 실행하기 전에 `sfs-channel-publish-preflight.sh` 로 workflow lane 을 먼저 분류합니다.
- `workflow_ready` 면 GitHub Actions workflow 로 Homebrew/Scoop repo 를 갱신할 수 있습니다.
- `manual_required` 면 workflow 를 누르지 않고 로컬 Homebrew tap / Scoop bucket repo 를 직접 갱신한 뒤 release verifier 로 검증합니다.
- `SOLON_RELEASE_BOT_TOKEN` 은 cross-repo workflow 자동화용 optional secret 입니다. 로컬 channel push 권한이 있으면 release blocker 가 아닙니다.
- workflow 자체도 token 누락 시 preflight/fallback 안내를 출력하도록 바꿨습니다.

## 0.6.124

이번 버전은 `sfs capture` 가 SFS 기본 flow 단계처럼 보이던 설계를 줄입니다.
승인, waiver, 결정, 외부 evidence 를 잃지 않기 위한 기능은 유지하지만, 기본 절차에 끼워 넣는 의식은 아닙니다.

- `capture` 를 lifecycle/gate 가 아니라 evidence primitive 로 재정의했습니다.
- 정상 산출물은 `brainstorm.md`, `plan.md`, `implement.md`, `review.md`, `retro.md`, wiki/report 가 계속 소유합니다.
- `capture` 는 explicit user approval, waiver, 결정, blocker, review-order override, 외부 PASS evidence 같은 최소 사실에만 씁니다.
- 새 runtime event 는 `evidence_capture` 를 기록하고, 기존 프로젝트의 `flow_capture` 는 계속 읽습니다.
- 사용자 가이드와 current-product-shape 문서에서 `flow checkpoint` 표현을 제거했습니다.

## 0.6.123

이번 버전은 제품 개발 완료 후 Claude Cowork/Gemini/GitHub Codex 리뷰를 증거로 붙이되, SFS 절차가 느린 의식으로 변하면 과감히 줄이도록 만듭니다.

- Claude Cowork, Gemini, GitHub `@codex` 는 구현 완료 후 external review evidence 로 기록할 수 있습니다.
- 이 외부 리뷰들은 self-CPO, SFS cross review, Gate 3, Gate 6 를 대체하지 않습니다.
- CLI bridge 가 인증되어 있으면 agent 가 직접 실행하고, Claude Cowork 처럼 UI/host 제어가 필요한 lane 은 compact review capsule 과 상태로 기록합니다.
- optional reviewer 가 unavailable 이라는 이유만으로 release 를 막지 않습니다. 실제 unresolved risk 만 blocker 입니다.
- `process-lean` review lens 를 추가해 SFS 절차의 병목, 반복 review loop, ceremony, user chore 를 검토합니다.
- 품질 invariant 는 유지하되, 불필요한 절차는 자동화, 축소, 인접 gate 통합, waiver 로 정리합니다.

## 0.6.122

이번 버전은 agent 가 본론을 놓치고 Gemini/Claude/Codex 같은 보조 도구 설정으로 빠지는 문제를 SFS 제품 버그로 막습니다.

- Mainline Focus Guard 를 추가해 tool/auth/model setup 을 `mainline`, `unblocker`, `deferred_followup`, `blocked`, `out_of_scope` 로 분류하게 했습니다.
- 진짜 unblocker 가 아니면 보조 설정이 sprint 본문을 가로챌 수 없습니다.
- Gate 6 에 mock/fixture/seed/data validation evidence 를 추가했습니다. 이름 붙은 fixture, invariant, boundary/negative case, command/result 없이 mock 만으로 PASS 할 수 없습니다.
- OWASP Web/API/LLM/MCP 관점의 agentic security/logging 검수와 Datadog 또는 동등한 redacted telemetry evidence/waiver 를 release readiness 에 포함했습니다.
- production `console.log`, `debugger`, 임시 probe log 는 배포 전 제거 또는 명시 waiver 가 필요합니다.
- 긴 작업은 wiki/workbench checklist 를 만들고 audit/edit/test/review/release 마다 상태를 갱신해야 합니다.

## 0.6.121

이번 버전은 SFS 를 “무늬만 SFS”가 아니라 6본부 agent team 이 실제로 계획과 검수에 개입하는 방향으로 강화합니다.

- enterprise agent-team knowledge pack 을 split 구조로 추가했습니다.
- Gate 3 plan 은 non-trivial product-bearing 작업에서 risk flag, selected pack, 6본부 finding/evidence/waiver 를 기록해야 합니다.
- Gate 6 review 는 SFS/harness 정책 변경의 project-applied QA/QC 와 hot path 성능/알고리즘 evidence 를 확인합니다.
- 성능/알고리즘 PASS 는 측정, bounded input proof, 또는 explicit N/A waiver 없이 통과할 수 없습니다.
- Gemini 는 3.x 이상 route 로 고정합니다: strategy/research/review 는 `gemini-3.1-pro-preview`, agentic coding/bounded helper 는 `gemini-3-flash-preview`, relay/probe/economy helper 는 `gemini-3.1-flash-lite` 입니다.

## 0.6.120

이번 버전은 fresh session 전환을 사용자의 `/clear` 입력이 아니라 host/agent 소유의 무손실 즉시 재개로 고정합니다.

- Session Continuation Guard 가 걸리면 agent 는 branch/commit/status/evidence/next prompt 를 담은 durable handoff/transfer capsule 을 먼저 만듭니다.
- host 가 제공하는 transfer/new-session/archive/clear+resume 제어가 있으면 직접 호출하고, 새 세션에서 즉시 이어갑니다. resume 없는 bare clear 는 금지합니다.
- host 전환+재개 제어가 없으면 현재 세션을 멈추고 다음 세션에 붙일 정확한 prompt 만 남깁니다.
- 사용자가 `/clear` 를 입력해야 한다고 반복 안내하는 것은 fresh-session autopilot 이 아니라 제품 버그로 취급합니다.

## 0.6.119

이번 버전은 fresh session 전환과 6본부 개입을 agent 재량이 아니라 SFS 하네스 계약으로 조입니다.

- Session Continuation Guard 가 걸리면 agent 는 같은 세션에서 계속할지 묻지 않고 compact handoff 를 만들고, host 가 지원하는 전환 제어로 넘깁니다.
- host 전환 기능이 없으면 다음 세션에 붙일 정확한 prompt/command 만 남기고 멈춥니다.
  0.6.120 에서 사용자 `/clear` 입력 요구 금지를 더 명확히 조였습니다.
- strategy-pm, dev, QA, design, infra, taxonomy 는 brainstorm 부터 Gate 6 까지 always-on conceptual sub-agent council 로 참여합니다.
- 실제 parallel worker 는 여전히 opt-in 이지만, 6본부 council ledger 는 plan/implement/review evidence 로 남아야 합니다.

## 0.6.118

이번 버전은 review 단계에서 모델 증명을 LLM 자기진술에 맡기지 않도록 고칩니다.

- Codex review bridge probe stderr/stdout 에서 `model: gpt-5.5`, `reasoning effort: xhigh` 같은 profile banner 를 SFS가 직접 추출합니다.
- CPO review prompt 에 `SFS Executor Profile Bridge Evidence` 섹션을 자동으로 붙입니다.
- matched bridge evidence 가 있으면 reviewer 는 자기 모델명을 직접 말하지 못했다는 이유만으로 partial 을 내면 안 됩니다.
- mismatch 또는 not-detected 는 artifact defect 가 아니라 profile bridge evidence gap 으로 분리합니다.

## 0.6.117

이번 버전은 자연어로 “SFS로”, “DDD 적용 확인”, “이 세션은 그 작업이었잖아”처럼 시작해도 SFS가 장식이 아니라 실제 컨텍스트/증거 조정으로 작동하게 만듭니다.

- 자연어 SFS 요청도 `sfs context`, handoff/docs, active sprint, wiki/DDD map 을 대조해야 합니다.
- 이미 승인된 sprint 가 있어도 최신 handoff 나 user intent 를 덮어쓸 수 없습니다.
- 기록이 의도를 증명하면 agent 는 사용자에게 다시 묻지 않고 mis-scoped work 로 판정하고 re-plan 또는 handoff 해야 합니다.
- DDD/TDD 작업 중 broad entrypoint 가 product behavior 를 더 품으면 Gate 6 finding 입니다.

## 0.6.116

이번 버전은 `인계문서` 요청이 이미 돌고 있던 PR/review loop 까지 즉시 끊는다는 점을 명확히 합니다.

- Handoff-only 요청은 새 작업만 막는 규칙이 아니라 active/queued loop interrupt 입니다.
- Agent 는 현재 PR batch 를 마저 끝내고 인계문서를 쓰면 안 됩니다.
- 이미 post-request PR/review/merge 작업을 했다면 지연 사유가 아니라 scope breach 로 보고해야 합니다.
- 이 규칙은 kernel, loop/review context, session guard, Claude/Codex/Gemini/Solon adapter surface, plugin README 에 모두 적용됩니다.

## 0.6.115

이번 버전은 사용자가 `인계문서`나 다음 세션용 handoff 만 요청했을 때 agent 가 그 뒤로 PR polling, review retrigger, merge, deploy, monitor loop 를 몰래 이어가지 못하게 막습니다.

- Handoff-only 요청은 이제 stop contract 입니다.
- Agent 는 handoff artifact 를 작성하고, 현재 상태/blocker/첫 다음 명령을 남긴 뒤 멈춰야 합니다.
- External review/check PASS 같은 continuation trigger 도 handoff-only 범위를 덮어쓸 수 없습니다.
- 같은 사용자 요청 안에서 계속 진행하라고 명시한 경우에만 PR/review/merge/deploy/monitor loop 를 이어갈 수 있습니다.
- 이 규칙은 Claude/Codex/Gemini/Solon adapter surface 와 runtime context 에 모두 배포됩니다.

## 0.6.114

이번 버전은 장시간 monitor 가 막연히 "계속 보는 중"이라고 말하지 않고, 실제 진행 상태를 evidence 로 분류하게 만듭니다.

- Monitor checkpoint 는 이제 `progressing`, `slow`, `stalled`, `dead`, `auth_blocked` 중 하나를 명시합니다.
- 각 checkpoint 는 commit delta, PR/head delta, local dirty state, test/check delta, review status delta, worker liveness probe result, lane-utilization evidence/waiver 를 남깁니다.
- 다음 행동도 `wait`, `probe`, `revive`, `close` 중 하나로 기록해야 합니다.
- Worker liveness 는 process/login/auth-status 만으로는 충분하지 않고 request-response probe 로 확인해야 합니다.
- Probe 는 static benign payload 만 사용하고, durable evidence 는 status/category/timestamp/redacted error class 로 제한합니다.
- Raw stdout/stderr, token/env, prompt body, model response, workspace/user content, PII 는 monitor evidence 로 보존하지 않습니다.
- Monitor close 는 heartbeat/automation cleanup 과 durable wiki/report evidence 를 함께 요구합니다.

## 0.6.113

이번 버전은 Claude/Codex 같은 실행 agent 가 "로그인돼 있음"만 보고 실제 작업 가능한 상태라고 착각하지 않도록 auth probe 를 조입니다.

- Claude probe 는 이제 작은 request-response worker 호출로 실제 응답 가능성을 확인합니다.
- 오래 살아 있는 로컬 프로세스, CLI login status, doctor/auth status 만으로는 PASS evidence 로 보지 않습니다.
- Claude 기본 probe 에서 `--dangerously-skip-permissions` 를 제거했습니다. 필요한 경우 기존 환경 override 로 명시할 수 있습니다.
- Probe stdout/stderr 에 남을 수 있는 bearer header 와 secret-like 환경값은 `.sfs-local/tmp` 저장 전에 redaction 됩니다.
- 새 하네스는 성공 호출, 401 fail-closed, 위험 bridge 재유입 방지, prompt 최소화, artifact redaction 을 검증합니다.

## 0.6.112

이번 버전은 구현 단계에서 plan AC/ADR 이 흐려지지 않도록 Gate 6 를 ledger 기반으로 조입니다.

- DDD/TDD 기본선은 backend/frontend 구분이 아니라 product-bearing entrypoint 전체에 적용됩니다. UI bootstrap/router, controller/job/repository, CLI/script/migration, docs wording, observability glue 도 product policy 의 임시 거처가 될 수 없습니다.
- Gate 6 review 는 Implementation Acceptance Ledger 로 every AC/ADR/decision 을 `implemented / missing / deferred / waived` 로 매핑하고, 파일/산출물과 테스트/evidence 가 없으면 PASS 하지 않습니다.
- `llm-wiki/` 가 있는 프로젝트에서 반복 하네스/제품 실패가 발견되면 problem, root cause, product fix, local tests, project-applied QA/QC, production/applied status, follow-up/waiver 를 기록해야 합니다.
- parallel sub-agent 구현 lane 은 disjoint files_scope 뿐 아니라 AC/ADR subset, expected tests/evidence, output report path, merge/conflict policy, native-language commit message 를 갖고 시작합니다.

## 0.6.111

이번 버전은 작은 review finding 묶음을 두고 사용자에게 "진행할까요?"라고 묻는 흐름을 막습니다.

- Brainstorm + plan review 는 사용자가 제품 의도와 결정 경계를 함께 설계하는 구간입니다. 이후 review loop 는 그 artifact 를 SoT 로 보고, 진짜 새 제품 결정일 때만 사용자를 부릅니다.
- Partial/fail finding 이 모두 결정적·저위험이고 승인된 contract 안의 작은 patch 라면 agent 가 patch, verify, self-CPO, cross review 를 autopilot 으로 이어갑니다.
- self-CPO evidence 누락, 작은 guard/test gap, regex 보정, evidence path, 의미 보존 문서 정합성 같은 finding 은 기본적으로 agent-owned 입니다.

## 0.6.110

이번 버전은 cross/self review finding 을 그대로 사용자 질문으로 전달하기 전에 전제부터 검수하게 만듭니다.

- Agent 는 finding 의 premise 를 명시하고 brainstorm, plan, domain SoT, schema, code, recorded decision 에 맞는지 먼저 확인합니다.
- SoT 가 이미 답하거나 전제가 틀린 finding 은 사용자 질문이 아니라 같은 cycle 의 plan/artifact rework 로 처리합니다.
- delete/cascade 정책도 제품 계약이 없으면 cascade soft-delete/restore 를 발명하지 않고, 하위 데이터가 있으면 delete reject 같은 작은 보존 정책을 기본으로 둡니다.

## 0.6.109

이번 버전은 `sfs version` / `sfs --version` / `sfs.cmd version` 의 단일 줄 버전 출력 계약을 복구합니다.

- `installed_release_headline` 은 `sfs version --check` 에서만 출력됩니다.
- 자동화나 CI 가 plain version 명령을 `sfs 0.6.109` 한 줄로 파싱하던 흐름을 다시 안전하게 유지합니다.
- 최신 릴리스 요약 앵커는 유지하되, evidence 출력과 machine version 출력을 분리합니다.

## 0.6.108

이번 버전은 설치된 Homebrew/Scoop payload 에 큰 `CHANGELOG.md` 가 빠지고 `RELEASE-NOTES.md` 만 있을 때도
`sfs version --check` 가 `installed_release_headline` 을 출력하도록 보강합니다.

- `CHANGELOG.md` 가 있으면 기존처럼 CHANGELOG headline 을 사용합니다.
- 설치 payload 에 `CHANGELOG.md` 가 없으면 `RELEASE-NOTES.md` 의 해당 버전 첫 문단을 headline 으로 사용합니다.
- release verifier 는 설치 runtime 의 `installed_release_headline` 출력까지 확인합니다.

## 0.6.107

이번 버전은 Agent 가 `sfs version --check` 로 최신 번호만 확인한 뒤 이전 release 내용을 최신 변경처럼
붙이는 문제를 막습니다.

- `sfs version --check` 출력에 local CHANGELOG 에서 읽은 `installed_release_headline` 을 추가합니다.
- 최신/적용/현재 버전 답변은 반드시 그 exact version 의 `VERSION` + `CHANGELOG` / `RELEASE-NOTES` entry 에 anchor 해야 합니다.
- 대화 기억이나 직전 릴리스 요약으로 현재 릴리스 의미를 추론하지 않도록 upgrade/freshness context 를 조였습니다.
- exact version entry 확인 전에는 "큰 invariant 변화 없음" 같은 판단형 요약을 하지 않습니다.

## 0.6.106

이번 버전은 Agent 가 실행할 수 있는 일을 사용자에게 다시 맡기는 흐름을 조입니다.
사용자가 원하는 결과가 있고 shell/tool/auth/approval 이 갖춰져 있으면 Agent 가 직접 실행하고 evidence 를 남겨야 합니다.

- copy-paste 명령 전달은 사용자가 명시적으로 명령을 원했거나 진짜 블로커가 있을 때만 허용합니다.
- 진짜 블로커와 승인 게이트를 분리합니다: `알아서 해`, `이번 세션은 진행`, autonomous deploy 같은 세션 승인 후에는 같은 범위의 approval-gated step 을 계속 진행합니다.
- 새 destructive/data-loss/public-contract 범위, missing auth, unavailable tooling/runtime, sandbox/permission denial 은 계속 멈춤 조건입니다.
- secrets/prod write 흐름은 승인 경계를 먼저 지키고, 승인 뒤에는 one-shot inline env + masked output 으로 Agent 가 직접 실행합니다.
- 새 하네스는 kernel, implement context, Claude/Codex/Gemini/SFS adapter surface 에 이 규칙이 빠지지 않는지 확인합니다.

## 0.6.105

이번 버전은 Agent 가 "최신 적용됐어?" 라고 답할 때 최신 릴리즈 headline 만 반복하다가
이미 설치된 핵심 기능을 놓치는 문제를 막습니다. 특히 병렬 sub-agent / multi-agent 구현을 물었으면
그 계약을 바로 보여줘야 합니다.

- `sfs upgrade` context 는 이제 latest headline 과 installed capability surface 를 구분하라고 안내합니다.
- sub-agent, 병렬 작업, multi-agent 구현, worker lane 을 물으면 Agent 는 single-agent 기본값과
  `sfs implement --agent-mode parallel --agents codex,claude[,gemini]` 선택 경로를 함께 설명합니다.
- 병렬 lane 의 조건도 같이 노출합니다: disjoint files_scope, lane-level verification,
  native/workspace-language 한 문장 commit message, Gate 6 PASS 전 agent cross review.
- install/upgrade 완료 안내에도 같은 구현 모드 계약을 넣어 "최신 적용" 확인이 모델 라우팅 설명에서 멈추지 않게 했습니다.

## 0.6.104

이번 버전은 사용자가 Agent 에게 "배포해줘" 라고 말했을 때의 의미를 제품 계약으로 고정합니다.
이 말은 단순 publish 가 아니라 "배포 프로세스 쭉 진행해줘" 입니다.

- Agent 는 release context 를 읽고 readiness check, 관련 테스트, review/검수, release cut,
  stable tag, Homebrew/Scoop 채널 반영, 설치 runtime 검증, evidence 보고까지 이어갑니다.
- Codex/Claude/Gemini/SFS entry surface 에 같은 규칙을 넣어 특정 Agent 만 다르게 멈추지 않게 했습니다.
- 새 회귀 테스트는 "배포해줘" 가 publish-only 로 축소되지 않고 검수와 설치 검증까지 요구하는지 확인합니다.

## 0.6.103

이번 버전은 AI Agent 가 만드는 문서의 기본 포맷을 더 분명히 나눕니다. 에이전트가 참고하는
운영 문서, SSoT, 로그, 스키마, README 는 Markdown 을 유지하고, 실제 사용자나 외부 독자가 읽는
가이드, 보고서, 핸드북, 온보딩 문서, 랜딩성 문서는 HTML 을 기본 산출물로 삼습니다.

- 이 규칙을 product maintenance guide, 설치되는 `CLAUDE.md`, runtime kernel, Codex/Claude/Gemini/SFS
  command surface 에 반영했습니다.
- HTML-first 이유는 사용자 문서가 브라우저 내비게이션, 시각 위계, 접근성, 배포 후 렌더링 검수까지
  포함해야 하기 때문입니다.
- 새 하네스 `test-user-facing-docs-html-first.sh` 는 규칙이 source SSoT 와 product agent entry surface 에
  빠짐없이 들어있는지 검증합니다.
- 0.6.103 검증은 `run-all.sh` 90/0 PASS, focused docs guard, shell syntax, `git diff --check` PASS 입니다.

## 0.6.102

이번 버전은 Obsidian wiki 를 구성하다가 host-local 도구 묶음이나 user-home 폴더를 프로젝트 SoT 로
오인하는 흐름을 막습니다. SFS 에 이미 흡수된 개념은 SFS command/policy surface 로 처리하고,
외부 도구는 사용자가 명시 요청한 경우에만 external environment evidence 로 남깁니다.

- Obsidian wiki policy, runtime kernel, Codex/Claude/Gemini/SFS template 에 host-local 경계를 추가했습니다.
- Obsidian 적용 프로젝트 runtime notice 도 host-local 도구는 project SSoT 나 wiki install target 이 아니라고 안내합니다.
- 새 하네스 `test-obsidian-host-local-boundary.sh` 는 active guidance 에 named host-local 도구나 user-home 폴더가
  project SoT, wiki root, install target, migration source 로 재유입되지 않는지 검증합니다.
- 이 변경은 Obsidian 권고를 약하게 만드는 것이 아니라, 필요한 것만 남긴다는 SFS 원칙에 맞춰 wiki 이관 범위를 조입니다.
- 0.6.102 검증은 `run-all.sh` 89/0 PASS 와 wiki link check, shell syntax, `git diff --check` PASS 입니다.

## 0.6.101

이번 버전은 이미 Obsidian 또는 `llm-wiki/` 가 적용된 SFS 프로젝트를 agent 가 놓치지 않도록
런타임 notice 와 테스트 하네스를 추가합니다.

- `.obsidian/` 또는 `llm-wiki/` 가 있으면 SFS 가 Obsidian 적용 프로젝트로 감지합니다.
- 감지된 프로젝트에서는 broad scan 전에 `llm-wiki/README.md` 와 `llm-wiki/ddd/README.md` 를
  확인하도록 안내합니다.
- `llm-wiki/ddd/` 가 빠져 있거나 `.obsidian/` 만 있고 `llm-wiki/` 가 없으면 gap/waiver 를 남기도록
  notice 를 출력합니다.
- taxonomy 는 독립 wiki 나 조직 본부가 아니라 domain language/classification lens 라는 경계를 다시 고정했습니다.
- 새 하네스는 active wiki 감지, DDD wiki gap, `.obsidian/`-only gap, notice opt-out 을 직접 검증합니다.
- 0.6.101 검증은 `run-all.sh` 88/0 PASS 와 wiki link check, shell syntax, `git diff --check` PASS 입니다.

## 0.6.100

이번 버전은 SFS 프로젝트가 Obsidian LLM wiki 를 함께 쓰는 기본 흐름을 추가합니다. 무료이고
Markdown 기반인 Obsidian 을 권고 기본값으로 삼되, 사용자가 원하지 않거나 환경상 쓸 수 없으면
기존 SFS 문서 산출물로 계속 진행합니다.

- 신규 SFS 프로젝트는 scaffold 뒤 repo root vault 와 `llm-wiki/` baseline 을 권장합니다.
- 기존 프로젝트는 `sfs adopt` 이후 기존 문서를 복사하지 않고 source link 중심으로 wiki 에 이관하도록 안내합니다.
- 다음 sprint 부터는 broad repo scan 전에 wiki map 을 먼저 읽는 retrieval 흐름을 권장합니다.
- Codex/Claude/Gemini/SFS agent template 과 product docs 에 같은 정책을 반영했습니다.
- Obsidian workspace/cache/plugin payload 는 commit 에 들어가지 않도록 `.gitignore` guidance 를 추가했습니다.
- 0.6.100 검증은 `run-all.sh` 87/0 PASS, wiki link check, Obsidian JSON parse, `git diff --check` PASS 입니다.

## 0.6.99

이번 버전은 제품 문서 하네스를 다시 꽉 조였습니다. 긴 active markdown 은 parent index 와 child 문서로
분리했고, frontmatter 가 빠지거나 200줄 budget 을 넘거나 분리된 child 문서를 테스트가 못 따라가면
바로 실패하도록 확인했습니다.

- active 제품 문서는 frontmatter 로 로드 가능한 상태를 유지합니다.
- `README`, `GUIDE`, `BEGINNER-GUIDE`, 영문/국문 제품 문서와 incident 문서를 200줄 이하 child 문서로 분리했습니다.
- 문서 테스트는 parent `.md` 뿐 아니라 sibling child directory 까지 검색합니다.
- release cut allowlist 에 top-level split child directory 를 포함해 배포 산출물에서도 문서가 빠지지 않게 했습니다.
- 0.6.99 검증은 음성 하네스 3건과 `run-all.sh` 86/0 PASS 입니다.

## 0.6.98

이번 버전은 이미 코드가 있는 프로젝트를 SFS 로 받아들일 때 DDD/TDD retrofit 경로를 같이 심습니다.
기존 구조가 DDD 로 잡혀 있지 않다면 바로 대규모 파일 이동을 하지 않고, 현재 코드 shape 를 진단한 뒤
다음 sprint 가 characterization/TDD evidence 로 한 behavior slice 씩 refactor 하도록 안내합니다.

- `sfs adopt --ddd-tdd-retrofit --apply` 가 source path 를 스캔해 DDD-lite boundary 상태를
  `missing`, `partial`, `present`, `no-code` 로 판정합니다.
- adoption handoff 에 DDD 상태, layer counts, hotspot, 다음 refactor action 이 들어갑니다.
- `ddd-tdd-retrofit.md` 와 `docs/solon/domain-map.md` 가 생성되어 durable product/domain language 를
  다음 sprint 에 이어갈 수 있습니다.
- TDD 는 legacy code 에 retroactive 로 붙이지 않고, 다음 실제 refactor sprint 부터
  characterization/failing/smoke evidence 로 시작하도록 고정했습니다.
- 0.6.98 검증은 `run-all.sh` 85/0 PASS 입니다.

## 0.6.97

이번 버전은 DDD/TDD 를 backend 전용 설계 취향이 아니라 product behavior 전체의 기본 규칙으로 올립니다.
SFS 는 이제 UI, API, CLI, 문서, 데이터, workflow glue, backend scaffold 모두에서 도메인 언어,
제품 행동 경계, 첫 evidence 경로를 요구하도록 안내합니다.

- DDD/TDD knowledge pack 은 `product behavior` 와 acceptance criteria 변경에도 로드됩니다.
- plan/implement/bootstrap/agent adapter 문구가 product-level DDD/TDD 기준으로 맞춰졌습니다.
- review lens 는 product rule 이 UI label, CLI flag, docs wording, migration, adapter, controller,
  repository, job 같은 곳에 숨어 있으면 finding 으로 잡도록 바뀌었습니다.
- GitHub @codex help 문구도 `self-CPO PASS -> cross CPO PASS -> GitHub @codex last` 순서로 정리됐습니다.
- 0.6.97 검증은 `run-all.sh` 84/0 PASS 입니다.

## 0.6.96

이번 버전은 구현 이후 리뷰 순서를 `self-CPO PASS -> cross CPO PASS -> GitHub @codex`
로 고정합니다. GitHub @codex 는 이제 구현 후 최종 PR/code review evidence 로만 쓰이며,
brainstorm 이나 Gate 3 plan review 에서는 동작하지 않습니다.

- `sfs review --gate 6` 은 self 단계와 cross 단계를 분리해서 기록합니다.
- Gate 6 기본 흐름은 self-CPO PASS 전에는 self, self PASS 후에는 cross 로 이어집니다.
- `sfs commit apply --group product-code` 는 구현 후 self-CPO PASS 와 cross CPO PASS 가 없으면 push 를 막습니다.
- self-CPO 만 사용할 수 있는 사용자는 fallback reason 을 기록한 self-CPO PASS 로 진행할 수 있습니다.
- backend/design knowledge pack 은 200줄 이하 routed child doc 으로 분리되어 frontmatter 기반으로 정확히 불립니다.
- 0.6.96 검증은 `run-all.sh` 83/0 PASS 입니다.

## 0.6.95

이번 버전은 Gate 3 review PASS 를 사용자 승인처럼 취급하던 흐름을 막습니다.
계획이 제품 의도, IA, acceptance 기준, 보이는 UI, public contract, 보안/데이터, 비용/지연,
파괴적 동작 같은 경계를 바꾸면 agent 는 바로 구현하지 않고 사용자 승인을 먼저 받아야 합니다.

- `plan.md` 에 사용자 승인 필요 상태가 표시되면 `sfs implement` 는 Gate 3 PASS 가 있어도 멈춥니다.
- 다음 단계는 구현이 아니라 `sfs capture --kind user-approval --gate 3 ...` 로 사용자 승인 또는 waiver 를 기록하는 것입니다.
- `sfs review --gate 3` 의 next action 도 approval pending 상태에서는 implement 가 아니라 사용자 승인 capture 로 안내합니다.
- `sfs capture` 는 `user-approval` / `approval` kind 를 받아 sprint ledger 에 명시 승인 evidence 를 남깁니다.
- 회귀 테스트는 capture flow, implement preflight block, review next-action routing 을 직접 검증합니다.

## 0.6.94

이번 버전은 Gate 3 review 가 self-CPO PASS 만 보고 구현으로 넘어가는 문제를 막되,
다른 Agent 를 구독하지 않았거나 외부 Agent 토큰이 소진된 사용자까지 막지는 않도록
fallback evidence 경로를 분리합니다. 또한 보이는 frontend/UI 변경은 사용자가 직접
확인하기 전에 agent 가 browser automation 으로 먼저 확인하도록 개발본부 guard 를 강화했습니다.

- `sfs implement` 는 Gate 3 PASS 를 볼 때 cross review evidence 또는 유효한 self-CPO fallback
  evidence 를 확인합니다.
- bare self-CPO PASS 만으로는 구현 진입이 막히지만, no other agent subscription, external agent
  token exhaustion, cross-review bridge unavailable 같은 이유가 기록된 self-CPO fallback PASS 는
  통과할 수 있습니다.
- `sfs review` 는 Gate 3 run event 에 `review_stage` 와 `cross_review` metadata 를 기록합니다.
- visible frontend/UI 구현은 사용자 확인 전에 Playwright/Cypress/Storybook 또는 동등한 browser
  automation 으로 desktop/mobile viewport, primary interaction, responsive fit, console/runtime
  error evidence 를 남기도록 했습니다.
- 0.6.94 검증은 `run-all.sh` 81/0 PASS 입니다.

## 0.6.93

이번 버전은 프로젝트 안에 남은 오래된 `.sfs-local/context` 가 최신 runtime guard 를 가려서
토큰/세션 보호 규칙이 실제 SFS flow 에 적용되지 않는 문제를 막습니다.

- 프로젝트 VERSION 이 runtime 보다 오래된 경우 `sfs context cat/path` 는 packaged runtime context 를
  우선 읽습니다.
- 꼭 project-local context override 를 확인해야 할 때만 `SFS_CONTEXT_PREFER_PROJECT=1` 로 명시합니다.
- vendored upgrade 는 context policy 파일을 하드코딩 목록이 아니라 실제 runtime context 디렉터리에서
  전부 동기화합니다.
- 그래서 `session-continuation-guard.md`, `context-pollution-guard.md`,
  `runtime-token-firewall.md` 같은 새 guard 가 추가되어도 낡은 프로젝트가 조용히 빠뜨리지 않습니다.
- 0.6.93 검증 목표는 `run-all.sh` 81/0 PASS 입니다.

## 0.6.92

이번 버전은 같은 Claude/Codex/Gemini 세션을 오래 이어 쓰면서 token meter 가 비정상적으로 빨리
차는 문제를 SFS flow 안에서 멈추게 합니다.

- `sfs upgrade` 는 runtime 과 project-local context 를 최신화하지만, 이미 열린 LLM 대화의 누적
  토큰을 지우지는 못한다는 경계를 명확히 했습니다.
- 새 WU/sprint 첫 구현·review 전에 token meter 가 30% 이상이면 fresh session 으로 넘깁니다.
- 새 gate, autonomous loop wakeup, worker handoff, cross-review 전에 token meter 가 50% 이상이면
  같은 대화를 계속 쓰지 않고 compact handoff 를 남깁니다.
- 같은 chat 이 여러 WU/sprint 를 지나거나 loop wakeup 이 2회를 넘으면 fresh-session handoff 로
  전환합니다.
- handoff 에는 `report.md`, `review.md`, capture id, commit/branch, 실패 명령, 다음 SFS 명령만
  남기고 전체 chat transcript 는 복사하지 않습니다.

## 0.6.91

이번 버전은 GitHub/@codex/PR/check PASS 를 SFS gate 종료로 오해하는 흐름을 막습니다.

- 외부 review/check PASS 는 continuation trigger 입니다. PASS 라고 말하고 멈추지 않고, 다음
  미충족 SFS review 명령으로 이어갑니다.
- Codex, Claude, Gemini, 기타 LLM Agent 모두 같은 규칙을 따릅니다: self-CPO 먼저, self-CPO
  PASS 뒤에 설정된 cross-review 순서입니다.
- 닫힌 sprint 에 대해 review 를 이어갈 때는 `.sfs-local/current-sprint` 를 손으로 복구하지 않고
  `sfs review --sprint <id> --gate <n>` 를 사용합니다.
- Context Pollution Guard 는 전체 review transcript/prompt 를 core context 에 남기지 않고, 외부
  PASS evidence 와 정확한 next SFS command 만 capture 하도록 고정합니다.
- 0.6.91 검증은 `run-all.sh` 78/0 PASS 로 기록됐습니다.

## 0.6.90

이번 버전은 자연어로 오간 중요한 결정을 SFS flow 안에 짧게 남기고, 반대로 prompt/transcript/
scratch 로그가 Solon 제품 문맥에 눌러앉아 토큰을 태우는 경로를 막습니다.

- `sfs capture` 와 `sfs note` 로 구현 방향, 리뷰 순서, 예외/waiver, blocker, evidence 를
  현재 sprint `log.md` 와 `events.jsonl` 에 기록할 수 있습니다.
- `flow_capture` event 는 capture 별로 남아 active ledger compaction 중에도 여러 checkpoint 가
  사라지지 않습니다.
- 닫힌 sprint 는 `sfs review --sprint <id> --gate <n>` 로 최신 cold archive 에서 복원해 review 를
  재개할 수 있습니다.
- Context Pollution Guard 가 core docs/context 에 남길 것은 결론과 evidence path 로 제한하고,
  prompt body, 전체 대화, bridge/review scratch, 긴 command log 는 tmp/archive 쪽에 두도록 고정합니다.
- `sfs capture` 는 기본 2000 bytes budget 으로 prompt/transcript dump 를 막고, 명시적인 local 예외만
  `SFS_CAPTURE_ALLOW_LONG=1` 로 허용합니다.
- release push 정책은 "무조건 금지"가 아니라 "surprise push 금지"로 정리했습니다. 사용자가 자동
  배포를 명시 승인하면 source/stable/tag/Homebrew/Scoop push 를 진행하고 evidence 로 남길 수 있습니다.
  이 규칙은 Codex 뿐 아니라 Claude, Gemini, 기타 LLM Agent 모두에 동일하게 적용됩니다.
- CPO review prompt 안의 Markdown backtick 이 Bash 명령으로 실행되던 위험을 막아, 문서 속
  `sfs review` 같은 예시가 숨은 재귀 실행으로 번지지 않습니다.
- 0.6.90 검증은 `run-all.sh` 77/0 PASS 로 기록됐습니다.

## 0.6.89

이번 버전은 SFS 인수인계 문서 경로를 도메인 우선 구조로 바꾸고, Claude main thread 가
Codex/worker wrapper 에 대화 전체를 넘기며 토큰을 태우는 경로를 Runtime Token Firewall 로 막습니다.

- `sfs start "<goal>"` 는 자연어 목표에서 높은 확신의 domain/subdomain/feature 를 추론해
  `docs/solon/<domain>/<subdomain>/<feature>/<date>/` 아래에 `report.md` 와 `retro.md` 를 준비합니다.
- `--domain`, `--subdomain`, `--feature` 는 명시 override 로 남고, `--workspace` 는 초기 탐색용 legacy fallback 입니다.
- `sfs tidy --all --apply` 는 기존 flat shared docs 를 안전하게 domain-first 경로로 옮기며, 충돌하면 덮어쓰지 않습니다.
- worker/review handoff 는 이제 capsule-only 입니다: goal, AC, files_scope, 명령, 결과 경로, compact evidence 만 넘깁니다.
- Claude in-process Codex/Gemini plugin wrapper, rescue subagent, forked context, full-history bridge 는 기본 review 경로에서 차단됩니다.
- `sfs review --executor codex-plugin` 대신 Codex CLI bridge, `SFS_REVIEW_CODEX_CMD`, 또는 `--prompt-only` 수동 handoff 를 사용합니다.
- 0.6.89 검증은 `run-all.sh` 73/0 PASS 로 기록됐습니다.

## 0.6.88

이번 버전은 수동/retroactive close 가 shared docs 를 sprint id 폴더에 잘못 놓아도
다음 공식 `sfs report` 또는 `sfs retro` 실행에서 workspace 폴더로 회복합니다.

- 예: `2026-W21-security-audit` sprint id 와 `--workspace security-audit` 를 같이 쓴 경우,
  잘못 놓인 `docs/solon/2026-W21-security-audit/<date>/report.md` 는
  `docs/solon/security-audit/<date>/report.md` 로 이동됩니다.
- 기존 `sfs start --workspace <english-name>` 계약은 그대로 유지됩니다.
- 회귀 테스트는 week-prefixed custom sprint id 와 별도 workspace 조합을 직접 검증합니다.

## 0.6.87

이번 버전은 GitHub PR 코드리뷰와 SFS review gate 를 명확히 분리합니다.

- GitHub 의 `@codex` PR/code review, PR approval, GitHub check PASS 는 외부 evidence 일 뿐입니다.
- 이런 GitHub 신호는 self-CPO, SFS cross review, `sfs review`, Gate 3, Gate 6 PASS 를 대체하지 않습니다.
- `sfs review` prompt/run scratch 는 실행별 디렉터리에 격리되어, 설치된 구버전 runtime 이 동시에 probe 되어도 현재 prompt/result 파일을 지우지 않습니다.
- tidy/retro close 는 새 nested review scratch 도 sprint cold archive 로 묶고 `.sfs-local/tmp` 에서 제거합니다.
- explicit review lens override 는 prompt/executor side effect 뒤에도 `review.md` frontmatter 에 다시 고정됩니다.
- 0.6.87 검증은 `run-all.sh` 72/0 PASS 와 Codex `gpt-5.5` xhigh self-CPO PASS 로 기록됐습니다.

## 0.6.86

이번 버전은 Token Diet 를 더 짧게 만드는 릴리스가 아니라, 짧아져도 품질이 떨어지지 않게 고정하는 릴리스입니다.

- compact 출력은 검증된 routine 표면에만 머뭅니다: status, start, report.
- review, decision, safety, source trace, verification evidence 는 줄였을 때 추적성이 흔들리면 full clarity 를 유지합니다.
- quiet release verifier 는 실패 시 숨긴 stdout/stderr 를 다시 보여준다는 사실을 더 명확히 출력합니다.
- status dashboard, MD split audit, release helper, session retro/index 정리를 테스트로 묶어 다음 릴리스 작업의 증거를 더 쉽게 추적할 수 있게 했습니다.
- 0.6.86 검증은 `run-all.sh` 70/0 PASS 와 self-CPO R6 PASS 로 기록됐습니다.

## 0.6.85

이번 버전은 release verifier 출력 소음을 줄입니다.

- `scripts/verify-product-release.sh` 가 내부 install/upgrade smoke 로그를 성공 시 숨깁니다.
- smoke 가 실패하면 숨긴 stdout/stderr 를 `[verify-product-release]` prefix 로 다시 출력하므로 원인 추적성은 유지됩니다.
- 결과적으로 릴리스 확인 로그는 짧아지고, 실패 증거는 사라지지 않습니다.

## 0.6.84

이번 버전은 SFS Token Diet 를 추가합니다. 목표는 단순히 짧게 말하는 것이 아니라,
짧아져도 evidence, warning, decision, source trace, verification 이 사라지지 않게 하는 것입니다.

- `SFS_OUTPUT_STYLE=compact sfs status` 또는 `sfs status --compact` 로 상태를 한 줄 compact 형식으로 볼 수 있습니다.
- `sfs start "목표" --output-style compact` 는 생성 경로, shared docs 경로, 권장 brainstorm 명령,
  `--simple` / `--hard` 대안, `recommended=normal` 을 한 줄로 보존합니다.
- `SFS_OUTPUT_STYLE=compact sfs report` 와 `sfs report --output-style compact` 는 report/archive 경로와
  compact/finalization 상태를 한 줄로 보존합니다. 기존 `sfs report --compact` 는 그대로 workbench archive/finalize 의미입니다.
- destructive/security/privacy/data-loss warning, user decision, review finding, raw-source traceability 는 compact 대상이 아닙니다.
  줄이면 품질이나 추적성이 낮아지는 경우 SFS 는 full clarity 를 유지합니다.
- Caveman/persona 말투는 기본값이 아닙니다. SFS 기본값은 professional compact output 입니다.
- filefunc 벤치마크에서는 Context Diet 만 흡수했습니다: precise routed context, stable search vocabulary,
  raw-text fallback, verification. SFS 전체에 one-file-one-function/type 규칙이나 mandatory annotation 을 강제하지 않습니다.

## 0.6.83

이번 버전은 Claude/Gemini/Codex 의 모델 레벨 분리를 더 명확히 고정하고,
작업 완료 조건에 self-agent top-model CPO PASS 루프를 추가합니다.

- Claude 쪽 코딩 가능한 worker/facilitator/code helper/mechanical helper 는 Sonnet 4.6 입니다.
- Haiku 는 코딩하지 않습니다. 단순 relay, 요약, 작은 read-only 보조 같은 non-coding helper 전용입니다.
- 실질 research 는 가능하면 Gemini researcher executor 를 우선 사용하고, Gemini 는 모든 role 을
  strategy/research/review 는 `gemini-3.1-pro-preview`, agentic coding/bounded 구현 helper 는 `gemini-3-flash-preview`, relay/probe/economy helper 는 `gemini-3.1-flash-lite` 로 둡니다. 3.x 미만 fallback 은 쓰지 않습니다.
- Codex 기준은 기존대로 유지됩니다: 일반 worker 는 `gpt-5.4`, 단순 non-coding helper 는
  `gpt-5.4-mini`, bounded coding helper 는 `gpt-5.3-codex`, 무판단 mechanical implementation helper 는
  `gpt-5.3-codex-spark` 입니다.
- 작업을 끝냈다고 보고하기 전에는 self-agent top-model CPO evidence 가 필요합니다:
  Claude Opus 4.7, Codex `gpt-5.5` xhigh, Gemini `gemini-3.1-pro-preview`.
- advisor 호출은 self-CPO PASS 를 대체하지 않습니다. partial/fail 이면 CPO 가 방향을 다시 잡고,
  구현/검증/self-CPO 를 PASS 될 때까지 반복합니다.

## 0.6.82

이번 버전은 Codex 쪽 단순 구현 위임 기준을 정확히 나눕니다.

- Codex 일반 구현 worker 는 `gpt-5.4` 입니다.
- Codex 단순 helper / non-coding helper 는 `gpt-5.4-mini` 입니다.
- 범위가 좁지만 코드 판단이 조금 남은 repo-aware coding helper 는 `gpt-5.3-codex` 입니다.
- scope, files_scope, AC, 정확한 수정 의도가 모두 잠겼고 판단이 필요 없는 단순 구현만
  `gpt-5.3-codex-spark` 로 보냅니다.
- Claude 와 Gemini 는 기존 tier family 설정을 그대로 유지합니다.
- plan/implement/kernel, Codex/Claude/Gemini adapter, GUIDE/current-product/10x 문서를 같은 기준으로
  맞췄습니다.

## 0.6.81

이번 버전은 Gemini/Codex/Claude cross review 를 처음 실행할 때 인증 안내가 먼저 나오게 고칩니다.

- `sfs review --executor gemini` 같은 named executor review 는 full CPO prompt 를 만들기 전에
  인증 상태를 먼저 확인합니다.
- 인증이 안 되어 있으면 review 실패처럼 기록하지 않고, `sfs auth login --executor <tool>` →
  `sfs auth probe --executor <tool>` → 같은 review 재시도 순서로 안내합니다.
- Codex/Claude 같은 headless 세션에서 `/dev/tty: Device not configured` 로 interactive auth 가
  뒤늦게 터지던 흐름을 막았습니다.
- 외부 Gemini 앱에 직접 붙여넣고 싶을 때는 기존처럼 `--prompt-only` 를 쓰면 됩니다.

## 0.6.80

이번 버전은 README 를 제품 소개페이지답게 다시 줄입니다.

- README 는 Solon 이 왜 좋은지, 어떻게 시작하는지, 어디서 더 읽으면 되는지만 짧게 보여줍니다.
- 버전별 변경 설명, 본부/지식팩 세부 정책, review evidence, 모델 라우팅 같은 운영 스펙은
  README 에서 빼고 GUIDE / current-product / 10x value 문서로 보냈습니다.
- 모델 라우팅의 자세한 설명은 한국어/영어 10x value 문서에 추가했습니다.
- README 가 다시 release note 처럼 길어지지 않도록 intro hygiene 테스트를 추가했습니다.

## 0.6.79

이번 버전은 README 와 제품 문서에서 본부, 지식팩, review lens 설명이 서로 어긋나던 부분을 맞춥니다.

- `.sfs-local/divisions.yaml` 은 기존 프로젝트 호환을 위한 6개 activation slot 이고, 전체
  지식팩/review lens registry 가 아니라고 명확히 적었습니다.
- backend 는 dev specialization, management-admin 은 재무/경리/세무/회계 관점, taxonomy 는 독립
  조직 본부가 아니라 모든 본부에 걸치는 언어/분류 lens 로 정리했습니다.
- README, GUIDE, 한국어/영어 current-product 문서, index 문서, knowledge-pack router, 기본
  `divisions.yaml` 템플릿을 같은 기준으로 맞췄습니다.
- stale `0.6.26` / `0.6.27` 문장이 다시 들어오지 않도록 문서 싱크 테스트를 추가했습니다.

## 0.6.78

이번 버전은 0.6.77의 commit-aware review evidence 를 실제 큰 프로젝트에서도 빠르게 끝나도록 보강합니다.

- `backend/src` 같은 넓은 디렉터리 토큰을 review evidence 로 확장할 때 기본 80개까지만 bounded 확장합니다.
- indexed evidence 경로를 prompt 생성 중 반복 계산하지 않고 cache 합니다.
- ADR/report 같은 작은 durable 문서는 전체 본문을 싣고, source/config 파일은 bounded excerpt 로 유지합니다.
- `study-note` 실제 sprint 에서 `sfs review --gate 4 --prompt-only`가 완료되고 evidence prompt 가 끝까지
  생성되는 것을 확인했습니다.

## 0.6.77

이번 버전은 commit 후 clean tree 상태에서 `sfs review` evidence 가 비어 보이던 문제를 고칩니다.

- `sfs review` 가 이제 직전 커밋의 reviewable 파일도 evidence prompt 에 포함합니다.
- `docs/solon/<english-workspace>/<yyyyMMdd>/report.md` / `retro.md` 같은 공유 인수인계 문서와
  `docs/solon/decisions/*.md` ADR 을 first-class review evidence 로 다룹니다.
- 작은 ADR/report 는 제한 안에서 전체 본문을 싣기 때문에 뒤쪽의 operational assumptions 같은 절이
  cap 때문에 사라지지 않습니다.
- `review.md` 의 goal/workspace frontmatter 도 review 실행 때마다 현재 sprint 기준으로 갱신합니다.

## 0.6.76

이번 버전은 Solon 작업의 commit 안내를 `sfs commit`으로 고정합니다.

- `sfs commit apply --group <name>` 은 이제 선택한 그룹을 stage, commit 한 뒤 현재 branch 를
  기본으로 push 합니다. upstream 이 없으면 `git push -u origin <branch>` 로 연결합니다.
- 로컬 sandbox, SFS release 테스트, offline 작업처럼 push 하면 안 되는 경우에만 `--no-push` 를 씁니다.
- Claude/Codex/Gemini entry 와 SFS.md 는 Solon 작업에서 host-local `/commit` skill 을 안내하지 말고
  `sfs commit plan` → `sfs commit apply --group <name>` 을 안내하도록 고정했습니다.
- install/upgrade/uninstall 완료 안내도 raw `git add` / `git commit` / `git push` 대신 `sfs commit` 을
  보여줍니다.

## 0.6.75

이번 버전은 review partial/fail 이후의 자동 rework 기준을 명확히 합니다.

- grep 범위, stale evidence, AC와 파일/산출물 매핑, evidence path 오타, 의미 보존 문서 일관성처럼
  작은 결정론적 finding 은 agent 가 같은 cycle 안에서 patch, 최소 검증, same-gate review 재호출까지
  이어갑니다.
- 사용자에게 묻는 경우는 범위, architecture, public contract, 보안/개인정보/data-loss,
  비용/지연/model policy, destructive action, AC 의미 변경처럼 제품 판단이 필요한 경우로 좁혔습니다.
- Claude/Codex/Gemini entry, Codex skill, plugin command, routed plan/review context, README/GUIDE 에
  같은 규칙을 반영했습니다.

## 0.6.74

이번 버전은 `.sfs-local` 보존 정책을 문서와 agent entry 전체에 맞춰 최신화합니다.

- `.sfs-local/` 은 history stack 이 아니라 현재 sprint 를 위한 private active workbench 라고 명시했습니다.
- `events.jsonl` 은 현재 sprint ledger 일 때만 남고, stale/orphan/closed-sprint-only 이벤트는
  `sfs upgrade` / `sfs tidy --all --apply` 가 제거 또는 archive 한다고 정리했습니다.
- 반복 cleanup evidence 는 날짜별
  `.sfs-local/archives/adopt/surface-cleanup/<yyyyMMdd>/surface-cleanup.tar.gz` 로 묶는다고
  README/GUIDE/Claude/Codex/Gemini entry 문서에 반영했습니다.

## 0.6.73

이번 버전은 0.6.72의 surface-cleanup 정리 정책을 Windows/릴리스 검증까지 맞춥니다.

- `surface-cleanup/<yyyyMMdd>/surface-cleanup.tar.gz` 안에 들어간 archive evidence 를
  Windows Scoop Smoke 와 release verifier 가 제대로 찾습니다.
- 실제 프로젝트 표면은 하루 단위 bundle 하나로 깔끔하게 유지하고, 복구 근거는 tar 내부에 보존합니다.

## 0.6.72

이번 버전은 `.sfs-local/archives/adopt/surface-cleanup/` 을 더 보기 좋게 정리합니다.

- 같은 날 생긴 surface-cleanup run directory 들을
  `surface-cleanup/<yyyyMMdd>/surface-cleanup.tar.gz` 하나로 묶습니다.
- 복구 evidence 는 tar 안에 그대로 남기고, 바깥에서 보이는 폴더는 날짜 단위로 줄입니다.
- 기존 프로젝트도 수동 삭제가 아니라 `sfs upgrade --yes` 또는 `sfs tidy --all --apply` 만으로 수렴합니다.

## 0.6.71

이번 버전은 Codex review 모델 라우팅을 원래 방식으로 되돌립니다.

- 맞습니다. Codex CLI model flag 전달은 환경별로 신뢰할 수 없어서, 기본 bridge 는
  `--model`/reasoning CLI flag 를 강제하지 않는 방식이어야 합니다.
- `sfs review --executor codex` 기본값은 다시 prompt + host/runtime profile 계약입니다.
  prompt 안에서 `review_high = gpt-5.5 + xhigh` 를 요청하고, `gpt-5.3-codex` normal/worker
  fallback 으로 CPO/cross review PASS 를 내지 말라고 명시합니다.
- CLI flag 방식이 되는 환경에서는 사용자가 `SFS_REVIEW_CODEX_CMD` 를 직접 지정할 수 있습니다.
  built-in 기본값은 flag 강제가 아닙니다.

## 0.6.70

이번 버전은 `events.jsonl` 기준을 더 빡세게 고정합니다.

- `events.jsonl` 은 이제 “현재 sprint 상태 라우팅”만 남기는 active ledger 입니다.
  이미 닫힌 sprint, adoption/upgrade migration 로그, sprint_id 없는 로그성 줄은 visible state 로 남기지 않습니다.
- `sfs tidy --all --apply` 는 닫힌 sprint 폴더가 이미 archive 되어 보이지 않아도, 그 sprint 의 event 줄을 prune 합니다.
- `sfs upgrade --yes` 도 같은 규칙을 적용하므로 기존 프로젝트는 수동 삭제가 아니라 정상 SFS 명령으로 최신 정책에 수렴합니다.
- Codex review bridge 는 0.6.71에서 prompt + host/runtime profile 계약으로 정정되었습니다.

## 0.6.69

이번 버전은 Codex cross review 모델 라우팅을 바로잡습니다.

- `sfs review --executor codex` 기본 CPO prompt 가 Codex review tier 를 명시합니다:
  `gpt-5.5` + `xhigh`.
- 구현 worker 기본값과 review/CPO 기본값을 분리했습니다. `gpt-5.3-codex` 는 고정된 구현 slice 용도이고,
  설계/review/cross review 같은 깊은 판단 작업의 기본값이 아닙니다.
- 0.6.69/0.6.70의 CLI flag 방식은 0.6.71에서 정정되었습니다. built-in 기본값은 prompt + host/runtime profile 계약이고,
  concrete CLI flag 는 `SFS_REVIEW_CODEX_CMD`로 명시 override 할 때만 씁니다.

## 0.6.68

이번 버전은 `events.jsonl` 기준을 다시 정확히 고정합니다.

- `events.jsonl` 은 sprint 진행 중에만 남길 수 있습니다. 한 줄 이유는
  “현재 sprint 의 status/gate/review 라우팅에 필요한 active ledger” 입니다.
- 같은 명령을 여러 번 열어도 내용이 stack 처럼 계속 쌓이지 않습니다. 같은 sprint/gate/type 의
  오래된 줄은 새 줄로 교체됩니다.
- sprint 가 닫혔거나 active sprint 가 없으면 `docs/solon/.../report.md`, private archive,
  git history 가 durable record 이므로 `events.jsonl` 은 `sfs tidy --all --apply` 때 제거됩니다.
- `sfs upgrade` 도 기존 프로젝트의 오래 쌓인 event ledger 를 compact 해서 최신 정책으로 수렴시킵니다.

## 0.6.67

이번 버전은 0.6.65/0.6.66의 collapsed archive 정책에서 복구 evidence 를 더 안전하게 보존합니다.

- 한 번의 upgrade 안에서 archive bucket collapse 가 여러 번 일어나도 같은
  `archives/adopt/surface-cleanup/...` 경로를 덮어쓰지 않습니다.
- vendored-to-thin upgrade 때 `project-runtime-assets`, `project-agent-adapters`,
  `project-local-context` 백업 evidence 가 모두 cold archive 안에 남는지 회귀 테스트로 고정했습니다.
- 사용자-facing 정리 기준은 그대로입니다: visible surface 에는 한 줄 이유가 있는 파일만 남깁니다.

## 0.6.66

이번 버전은 0.6.65의 surface cleanup 정책에 맞춰 배포 검증도 같이 맞춥니다.

- Windows Scoop smoke 가 `runtime-migrations` top-level 폴더 대신
  `archives/adopt/surface-cleanup/.../preexisting-archives.tar.gz` 안의 backup evidence 를
  인식합니다.
- owner-side release verifier 도 같은 collapsed archive 구조를 정상 release evidence 로 인정합니다.
- 사용자-facing 동작은 0.6.65와 같습니다: cache/log/placeholder 파일은 visible surface 에 남기지 않고,
  복구 evidence 는 `archives/adopt` 아래로 접습니다.

## 0.6.65

이번 버전은 adopt 이후 다시 생기던 `.sfs-local` 표면 잔여물을 막습니다.

- `sfs tidy --all --apply` 는 이제 sprint 폴더가 하나도 없어도 post-adopt surface cleanup 으로
  동작합니다.
- `.sfs-local/cache/*notice.env`, placeholder-only `auth.env`, orphan `events.jsonl` 은 visible
  surface 에 남기지 않습니다.
- `.sfs-local/archives/runtime-migrations`, `runtime-upgrades`, `sprints` 처럼 흩어진 archive
  bucket 은 `archives/adopt/surface-cleanup/.../preexisting-archives.tar.gz` 로 접습니다.
- version notice cache 는 프로젝트 `.sfs-local/cache` 가 아니라 사용자 SFS cache 로 이동했습니다.
  그래서 `sfs status` 같은 일반 명령이 cache 폴더를 다시 만들지 않습니다.
- 한 줄 이유 기준은 그대로입니다: `archives/adopt` 는 cleanup rollback/recovery evidence 이므로
  남길 수 있고, cache/log/placeholder 파일은 남기지 않습니다.

## 0.6.64

이번 버전은 `adopt` 이후에도 `.sfs-local`에 남아 보이던 잔여 파일/디렉터리를 더 강하게 정리합니다.

- `sfs adopt --apply` 후 `events.jsonl`, `current-sprint`, `tmp`, `cache`, 빈 `sprints` 같은
  active workbench 잔여물이 visible surface 에 남지 않도록 했습니다.
- `.sfs-local/auth.env.example` 은 프로젝트에 복사하지 않습니다. 샘플은 packaged runtime 에만 두고,
  실제 로컬 인증이 필요하면 `sfs auth path` 가 가리키는 `auth.env`를 명시적으로 씁니다.
- 이미 생긴 `auth.env.example`, 빈 `cache`/`tmp`/`queue` 는 `sfs upgrade` 때 cold archive 하거나
  삭제해서 최신 thin surface 로 수렴합니다.
- adopt dry-run/apply 출력과 handoff 문서에 “비운 surface dir 정리” evidence 를 남깁니다.
- 공유 인수인계/기록 문서는 `docs/solon/<english-workspace>/<yyyyMMdd>/` 아래에 남깁니다.
  `sfs start "<목표>" --workspace <english-name>` 로 sprint id 대신 명확한 영어 한 줄 이름을
  고정할 수 있습니다.
- `sfs review` 결과 stdout 에도 global `next:`가 붙습니다. Gate 3 PASS 는 `sfs implement`,
  이후 review PASS 는 닫기 흐름(`sfs retro`)으로 이어지도록 agent별 출력 차이를 줄였습니다.

## 0.6.63

이번 버전은 Gate 3 plan 의 `리뷰 준비` 체크리스트 문구를 다듬습니다.

- 어색한 `열린 결정이 이름 붙어 있다` 문구를 제거했습니다.
- 대신 `Gate 2 결정이 요구사항과 AC에 연결되어 있다`, `slice별 파일/산출물 매핑이 있다`,
  `worker 모델 라우팅이 명시되어 있고, Spark는 scope/files_scope/AC가 잠긴 기계적 구현 보조
  작업에만 쓴다`로 바꿨습니다.
- plan context 에도 같은 기준을 넣어 Claude, Codex, Gemini 가 번역투 review-readiness 문구를
  다시 만들지 않도록 했습니다.

## 0.6.62

이번 버전은 Claude, Codex, Gemini 모두에서 결정 질문 노출 방식을 다시 고정합니다.

- `A/A/A/C/C 확정` 같은 내부 option bundle 을 사용자-facing 확정 문구로 쓰지 않습니다.
- 사용자가 “권장안 다시 보여줘”라고 해도 추천 label 묶음이나 추천 row 하나만 다시 보여주지 않습니다.
  권장 경로를 자연어로 설명하고, 어떤 대안이 plan 을 바꾸는지 같이 보여줍니다.
- 확정 문구는 `권장안 그대로 확정`처럼 사람이 읽는 자연어를 씁니다.
- Claude template, Gemini command, Codex skill/prompt, 공통 SFS.md, plugin command,
  routed kernel/brainstorm/plan context 에 같은 규칙을 넣었습니다.

## 0.6.61

이번 버전은 addyosmani/agent-skills 벤치마크에서 쓸 만한 practice 를 SFS 의 기존 명령 안으로
흡수합니다. 새 명령어를 늘리는 대신 `implement`, `review`, `adopt`, `tidy`, `release` 의
판단 기준이 더 선명해집니다.

- `implement` 는 framework/library/API 작업에서 공식 문서나 실제 source-of-truth 근거를 더
  강하게 요구하고, 반복 실패는 stop-the-line debugging 으로 원인/evidence 를 먼저 잡습니다.
- `review` 는 `source-docs`, `simplify`, `security`, `performance`, `api-contract` 렌즈를
  추가로 이해합니다. 보안/성능/API contract 같은 위험을 generic code review 에 묻지 않습니다.
- `adopt` 와 `tidy` 는 deprecation/migration 정리 기준을 공유합니다. 남길 이유를 한 줄 이상으로
  설명할 수 없는 로그성/히스토리성 파일은 visible surface 에 남기지 않습니다.
- `release` 는 배포 전 version/channel/install 검증, rollback/reversibility, observable release
  evidence 를 더 분명하게 확인합니다.
- README, GUIDE, current product docs, 10x docs 에 “agent-skills류 practice 는 기존 SFS 명령
  강화로 흡수한다”는 기준을 반영했습니다.

## 0.6.60

이번 버전은 adoption 정리 기준을 “남겨야 하는 이유를 한 줄 이상으로 설명할 수 없으면
visible surface 에 남기지 않는다”로 맞춥니다.

- `sfs adopt --apply` 는 이제 공유 인수인계 문서를
  `docs/solon/<english-workspace>/<yyyyMMdd>/handoff.md` 에 만듭니다. adopt 의 `<workspace>` 는 기본적으로
  `legacy-baseline` 이고, `--id <name>` 을 주면 그 이름을 path-safe 하게 씁니다.
- 예전 `docs/solon/<id>-adoption-summary.md` 형식의 flat adoption summary 는 private cold
  archive 로 접고 visible docs 에 남기지 않습니다.
- `.sfs-local/events.jsonl`, `tmp`, `decisions`, 예전 sprint 폴더, 오래된 archive 폴더,
  adapter/runtime 찌꺼기처럼 durable handoff 가 아닌 파일은 cold archive 로 들어가거나 삭제됩니다.
- adopt 이후 visible `.sfs-local` 은 런타임에 필요한 `VERSION`, `config.yaml`,
  `divisions.yaml`, `model-profiles.yaml` 정도만 남깁니다.
- `docs/solon/` 은 handoff 기본 위치가 아니라 domain map, design contract 같은 프로젝트 공용
  Solon reference 문서 위치로 유지합니다.

## 0.6.59

이번 버전은 작업 인계 문서 위치를 `.sfs-local` private workbench 에서 repo root 의
공유 문서 표면으로 옮깁니다.

- `sfs report` 는 이제 `docs/solon/<workspace>/<yyyyMMdd>/report.md` 를 만듭니다.
- `sfs retro` 와 `sfs retro --draft` 는 같은 위치에 `retro.md` 를 만듭니다.
- `<workspace>` 는 기본적으로 `sfs start "<goal>"` 의 goal 텍스트를 path-safe 하게 정리한
  값입니다. 예를 들어 `sfs start "결제 오류 수정"` 은
  `docs/solon/결제-오류-수정/<yyyyMMdd>/report.md` 와 `retro.md` 를 남깁니다.
- 기존 `.sfs-local/sprints/<id>/report.md` / `retro.md` 가 있으면 가능한 경우 새 공유 위치로
  옮기고, 충돌하는 legacy copy 는 cold archive 로 접어 visible residue 로 남기지 않습니다.
- `report.md` / `retro.md` 본문은 커밋 메시지 규칙과 같이 사용자의 native/workspace 언어를
  기본값으로 삼습니다.

## 0.6.58

이번 버전은 `.sfs-local` 정리 기준을 더 엄격하게 맞춥니다. 이제 `sfs tidy --all
--apply` 는 “남겨야 하는 이유를 한 줄로 설명할 수 있는 것만 visible 상태로 둔다”는
규칙을 실제 동작으로 적용합니다.

- 닫힌 sprint 의 `brainstorm.md`, `plan.md`, `implement.md`, `log.md`, `review.md`
  같은 workbench 문서는 계속 `.tar.gz` cold archive 로 묶어 복구 가능하게 둡니다.
- `events.jsonl` 은 durable history 가 아니라 active state ledger 로 취급합니다.
  active sprint/current state 를 뒷받침하지 않는 closed-sprint event line 은 tidy 후
  제거되고, 남은 line 이 없으면 파일 자체도 삭제합니다.
- 깨진 `current-sprint` 포인터, 빈 `.gitkeep` placeholder, 비어 있는 queue/decision/tmp/cache
  디렉터리도 tidy apply 에서 함께 제거합니다.
- dry-run/apply 출력에 event pruning 과 residue cleanup 요약이 나오므로, Windows 에서
  `sfs.cmd tidy --all` 을 실행했을 때 새 규칙이 반영됐는지 바로 확인할 수 있습니다.

## 0.6.57

이번 버전은 Windows 에서 검증된 0.6.56 `sfs.cmd` 패치셋을 macOS release cut 으로
Homebrew/Scoop 채널에 게시하는 사용자-facing 버전입니다. 이미 push 된 `v0.6.56`
태그는 Windows proof baseline 으로 남기고, 실제 패키지 배포 기준은 `v0.6.57` 로
올립니다.

- Windows `sfs.cmd version`, `context cat`, `start`, `upgrade` 가 usage-only/help 로
  무너지는 인자 전달 문제를 고친 0.6.56 패치셋을 그대로 포함합니다.
- `sfs.cmd upgrade` 는 self-upgrade 뒤 최종 PowerShell-to-Git-Bash bridge 에서 실제로
  돌아왔는지 trace marker 로 확인하고, Git Bash watchdog 이 PowerShell pipeline 을
  계속 붙잡는 경로를 막습니다.
- 사용자 문서의 현재 버전 표기는 0.6.57 로 갱신했고, 세부 장애 분석은
  [Windows SFS 래퍼 장애 요약 보고서](./docs/ko/windows-wrapper-incident-0.6.56.md)
  에 0.6.56 proof baseline 으로 유지합니다.

## 0.6.56

이번 버전은 Windows `sfs.cmd version` 이 계속 usage-only 로 떨어지던 진짜 원인을 고칩니다.
0.6.55 후보를 실제 Windows runner 에 trace 로 올려 보니 batch 쪽은 `version` 을 잃지 않았습니다.
문제는 `sfs.ps1` 의 여러 helper 함수가 PowerShell 자동 변수와 충돌하기 쉬운 `$Args`
파라미터명을 사용해, 살아 있는 env bridge 인자가 함수 경계를 지날 때마다 empty/help 로
무너진 데 있었습니다.

- 0.6.54 smoke 실패 run: `25548381094`.
- 0.6.55 trace 실패 run: `25554923214`.
- `sfs.ps1` 의 `Test-SfsUsableArgs` 는 이제 `$Items`, native dispatch/self-upgrade helper 는
  `$InvocationArgs` 를 사용해 `SFS_NATIVE_ARG_1=version` 같은 단일 인자를 끝까지 정상 인자로
  전달합니다.
- `--% %SFS_NATIVE_RAW_ARGS%` 실험은 제거했습니다. runner 에서 이 경로는 `version` 이 아니라
  `--SFS_NATIVE_RAW_ARGS` 토큰을 만들었습니다.
- numbered env bridge, raw env fallback, saved command-line fallback, parent command-line fallback 은
  그대로 유지해서 Windows/Scoop runner 의 다른 인자 전달 모양도 계속 회복합니다.
- Windows smoke 와 release verifier 는 이제 `SFS_ARGTRACE_PS_SELECTED_SOURCE=env` 와
  `SFS_ARGTRACE_PS_FINAL_ARGS=.*version` 을 확인한 뒤에야 `sfs.cmd version` 을 통과시킵니다.
- `sfs.cmd upgrade` 는 Scoop self-upgrade 전에 WindowsPowerShell module path 를 복원하고
  `Microsoft.PowerShell.Utility` 를 명시 로드하며, 그래도 없으면 현재 Scoop runspace 에
  path/stream hashing 을 지원하는 `Get-FileHash` fallback 을 주입합니다. GitHub Windows
  runner 에서 Scoop 이 zip hash 를 확인할 때 이 cmdlet 이 필요했습니다.
- Scoop self-upgrade 뒤 새 runtime 을 다시 호출할 때 `upgrade` 가 문자 단위로 쪼개져
  `unknown command: u` 로 떨어지지 않도록 reload 와 최종 Git Bash bridge 인자를 명시
  `string[]` 로 고정했습니다.
- reload 대상도 Scoop 의 `current\bin\sfs.ps1` 로 재해석하고, Windows 에서 들어온
  `upgrade` spelling 은 canonical `update` 로 치환합니다. `sfs.cmd upgrade` 로 들어와도
  self-update 후에는 `sfs update` 흐름으로 이어집니다.
- self-update reload 직전에는 오래 남은 `SFS_NATIVE_ARG_*` 환경 변수도 canonical `update`
  배열로 다시 씁니다. trace run `25558767614` 처럼 `PS_RELOAD_ARGS=update` 인데도
  stale `SFS_NATIVE_ARG_1=upgrade` 가 더 높은 우선순위로 선택되는 경로를 차단합니다.
- Windows CI 의 `sfs.cmd upgrade` smoke 는 사용자-facing spelling 그대로 실행하고, 내부
  runtime 만 non-interactive 로 움직입니다. Git Bash 가 `/dev/tty` 를 다시 열고 프롬프트에서
  멈추는 상태도 trace 로 확인해 막았습니다.
- `SFS_UPGRADE_TRACE=1` 은 개발/CI 에서만 upgrade phase 를 보여주는 opt-in 로그입니다.
  운영 기본값은 조용하고, 문제가 생긴 경우에만 phase trace 를 켤 수 있습니다.
- 추가 trace run `25559894888` 에서는 Windows reload 가 `[update]` 로 정상 진입한 뒤
  `maybe_prompt_model_profile after` 다음에서 멈췄습니다. 그래서 upgrade 후반에
  `model profile notice`, `cli-discovery hook`, `completion output` trace 를 더 넣었습니다.
- CLI discovery 는 이제 무한 대기하지 않습니다. 전체 hook 은 `SFS_CLI_DISCOVERY_TIMEOUT_SEC`,
  내부 `claude`/`gemini`/`git clone` probe 는 `SFS_DISCOVERY_CMD_TIMEOUT_SEC` 로 제한하고,
  timeout 이 나면 warning 후 upgrade 를 계속합니다.
- upgrade trace pipeline 은 더 이상 assignment 로 감싸지 않습니다. `Tee-Object` 출력이 Actions
  로그에 즉시 보이도록 해서, 다음 실패는 마지막 trace 줄에서 바로 추적할 수 있습니다.
- `SFS_WINDOWS_ARG_TRACE=1` 진단 모드도 추가되어, 다음 Windows runner 실패가 나면 batch `%*`,
  PowerShell `$args`, 최종 선택 source 를 로그에서 바로 볼 수 있습니다.
- 질문/결정 출력 guardrail 도 보강했습니다. `Q1: persona scope, 추천 A` 처럼 추천값만 보여주는
  표는 금지하고, 모든 선택지의 뜻과 결과를 설명한 뒤 추천을 default 로 표시합니다. 선택지가
  많으면 숨기지 않고 한 번에 하나씩 묻습니다.
- `.sfs-local/` 은 private workbench 로 유지합니다. `events.jsonl`, cache, tmp, archive, run log 는
  commit 대상이 아니고, 공유할 결론은 `docs/solon/<english-workspace>/<yyyyMMdd>/` 의 sprint `report.md` 로 남기는 정책을
  다시 명확히 했습니다.
- [Windows SFS 래퍼 장애 요약 보고서](./docs/ko/windows-wrapper-incident-0.6.56.md) 는 P27 로 이
  설치 직후 usage-only 문제까지 기록합니다.

## 0.6.54

이번 버전은 0.6.53 을 실제 GitHub Windows runner 에 올린 뒤에도 남은 usage-only 문제를
고칩니다. hardened shim 안에는 delayed-expansion saved-cmdline bridge 가 있었지만,
runner 에서는 최초 `sfs.cmd version` 이 여전히 usage 만 출력했습니다.

- 0.6.53 smoke 실패 run: `25546859759`.
- `sfs.ps1` 은 env/raw/saved command-line source 가 모두 비면 parent `cmd.exe` 의
  `Win32_Process.CommandLine` 을 읽어 원래 `sfs.cmd ...` 꼬리를 복구합니다.
- parent command-line fallback 도 saved-cmdline 과 같은 parser 를 사용해
  `&& sfs.cmd --help >NUL` 같은 tail 을 첫 번째 명령의 인자로 착각하지 않습니다.
- parser 는 이제 공백으로 먼저 자르지 않고 `sfs.cmd` 명령명 뒤의 꼬리부터 추출하므로,
  parent command line 경로 중간에 공백이 있어도 `version`, `context cat`, `start` 인자를
  잃지 않습니다.
- release verifier 와 Windows guardrail test 가 parent command-line fallback 계약을 회귀로 막습니다.
- [Windows SFS 래퍼 장애 요약 보고서](./docs/ko/windows-wrapper-incident-0.6.56.md) 는 P21 로 이
  설치 직후 usage-only 문제까지 기록합니다.

## 0.6.53

이번 버전은 0.6.52 를 실제 GitHub Windows runner 에 올린 뒤 드러난 saved command-line 문제를
고칩니다. 설치 직후 hardened `sfs.cmd` shim 이 `SFS_NATIVE_RAW_ARGS` 까지 갖고 있었는데도
`sfs.cmd version` 이 usage-only 로 떨어졌습니다. 그래서 batch 프로세스가 가진 원본
명령행을 child PowerShell 을 띄우기 전에 delayed expansion 으로 `SFS_NATIVE_CMDLINE` 에 저장합니다.

- 0.6.52 smoke 실패 run: `25545120029`.
- `sfs.cmd` 와 Scoop post-install hardened `sfs.cmd` shim 이 `SFS_NATIVE_CMDLINE=!CMDCMDLINE!` 을 저장해
  따옴표, `&&`, `>` 가 batch `set` 줄을 깨지 않게 합니다.
- `sfs.ps1` 은 raw arg tail 다음, child PowerShell 의 `CMDCMDLINE` fallback 전에 saved cmdline 을 읽습니다.
- saved cmdline 에 `&& sfs.cmd --help >NUL` 같은 tail 이 붙어도 첫 번째 `sfs.cmd` 명령만 인자로 해석합니다.
- release verifier, Windows guardrail test, GitHub Windows smoke 가 saved-cmdline fallback 계약을 회귀로 막습니다.
- [Windows SFS 래퍼 장애 요약 보고서](./docs/ko/windows-wrapper-incident-0.6.56.md) 는 P20 으로 이
  설치 직후 usage-only 문제까지 기록합니다.

## 0.6.52

이번 버전은 0.6.51 을 실제 GitHub Windows runner 에 올린 뒤 드러난 마지막 arg-tail 문제를
고칩니다. 설치 직후 hardened `sfs.cmd` shim 이 실행됐는데도 `sfs.cmd version` 이 usage-only 로
떨어졌기 때문에, `%1..%n` 수집 루프가 `shift` 하기 전에 원본 `%*` 꼬리를 `SFS_NATIVE_RAW_ARGS`
로 보존하도록 했습니다.

- 0.6.51 smoke 실패 run: `25543802195`.
- `sfs.cmd` 와 Scoop post-install hardened `sfs.cmd` shim 이 `SFS_NATIVE_RAW_ARGS=%*` 를 먼저 저장합니다.
- `sfs.ps1` 은 numbered env bridge 다음, `CMDCMDLINE` fallback 전에 raw arg tail 을 읽고,
  비어 있는 arg 배열은 fallback 을 막지 못하게 처리합니다.
- release verifier 와 Windows guardrail test 가 raw-arg fallback 계약을 회귀로 막습니다.
- [Windows SFS 래퍼 장애 요약 보고서](./docs/ko/windows-wrapper-incident-0.6.56.md) 는 P19 로 이
  설치 직후 usage-only 문제까지 기록합니다.

## 0.6.51

이번 버전은 0.6.50 을 실제 GitHub Windows runner 에 올린 뒤 드러난 smoke workflow 문제를
고칩니다. 제품 wrapper 수정은 유지하고, 알려진 깨진 `v0.6.49` archive 를 가져오는 Git refspec 에
PowerShell `${brokenVersion}` braces 를 붙여 Windows CI가 복구 검증까지 실제로 진행하게 했습니다.

- 0.6.50 smoke 실패 run: `25542777986`.
- 실패 원인: `$brokenVersion:` 이 PowerShell scoped-variable 문법처럼 해석되어
  `refs/tags/v/tags/v0.6.49` 를 fetch 하려 했습니다.
- Windows smoke 는 이제 `refs/tags/v${brokenVersion}:refs/tags/v${brokenVersion}` 를 사용합니다.
- release verifier 와 Windows guardrail test 가 refspec 과 archive tag brace 계약을 회귀로 막습니다.
- [Windows SFS 래퍼 장애 요약 보고서](./docs/ko/windows-wrapper-incident-0.6.56.md) 는 P18 로 이
  release-smoke 문제까지 기록합니다.

## 0.6.50

이번 버전은 0.6.49 를 실제 GitHub Windows runner 에 올린 뒤 확인된 잔여 shim 문제를
수정합니다. post-install 이 `sfs.cmd` shim 을 덮어쓴 것은 맞았지만, env-only 전달만으로는
`sfs.cmd version` 인자가 다시 usage 로 떨어졌습니다. 그래서 hardened `sfs.cmd` shim 이
numbered env bridge 와 `%*` positional fallback 을 함께 `sfs.ps1` 에 넘기도록 고정했습니다.

- Windows PowerShell/cmd 의 사용자 경로는 계속 `sfs.cmd ...` 입니다.
- 설치 직후 shim 파일에 `SFS_NATIVE_ARGC` 와 `%*` 가 모두 있는지도 Windows smoke 가 확인합니다.
- Windows smoke 는 실제 `v0.6.49` archive 도 설치해 `sfs.cmd version` usage 회귀를 재현한 뒤,
  `scoop update` 와 `scoop update sfs` 로 현재 runtime 까지 복구되는지 확인합니다.
- `sfs.cmd version`, `sfs.cmd context cat kernel`, `sfs.cmd start ...`, `sfs.cmd upgrade`
  가 env-only shim 전달 실패에 막히지 않도록 두 경로를 동시에 열어 둡니다.
- [Windows SFS 래퍼 장애 요약 보고서](./docs/ko/windows-wrapper-incident-0.6.56.md) 는 P1-P17
  문제 목록과 0.6.49 GitHub smoke run `25541086874` 실패 근거까지 포함합니다.

## 0.6.49

이번 버전은 0.6.48 을 실제 GitHub Windows runner 에 올린 뒤 확인된 마지막 shim 문제를
수정합니다. `sfs.cmd` 로 경로를 고정해도 Scoop 이 생성한 `sfs.cmd` shim 자체가 `version`
인자를 버릴 수 있었으므로, 설치 후 hook 이 shims 디렉터리의 `sfs.cmd`, `sfs.ps1`,
extensionless `sfs` 를 Solon 이 제어하는 deterministic wrapper 로 덮어씁니다.

- Windows PowerShell/cmd 의 사용자 경로는 계속 `sfs.cmd ...` 입니다.
- `sfs.cmd version`, `sfs.cmd context cat kernel`, `sfs.cmd start ...`, `sfs.cmd upgrade`
  가 generated shim 인자 손실에 막히지 않도록 shim 자체를 post-install 에서 고정합니다.
- Git Bash 에서는 extensionless `sfs` shim 이 packaged `bin/sfs` 를 실행합니다.
- `sfs.ps1` 내부 인자 정규화도 named-array forwarding 으로 보강해 `context cat kernel` 같은
  여러 단어 명령이 내부 함수 호출에서 잘리지 않게 했습니다.
- [Windows SFS 래퍼 장애 요약 보고서](./docs/ko/windows-wrapper-incident-0.6.56.md) 는 P1-P16
  문제 목록과 0.6.48 GitHub smoke run `25539387684` 실패 근거까지 포함합니다.

## 0.6.48

이번 버전은 0.6.47 을 실제 GitHub Windows runner 에 올린 뒤 확인된 smoke 계약 문제를
정리합니다. bare `sfs` generated shim 은 PowerShell/cmd 에서 여전히 인자를 잃을 수 있으므로,
Windows 의 사용자 실행 경로와 CI 통과 기준을 `sfs.cmd` 로 고정했습니다.

- Windows PowerShell/cmd 검증은 이제 `sfs.cmd version`, `sfs.cmd status`,
  `sfs.cmd context cat ...`, `sfs.cmd start ...`, `sfs.cmd upgrade` 를 직접 확인합니다.
- Git Bash/WSL 에서는 기존처럼 bare `sfs` 를 검증합니다.
- 문서와 Scoop packaging guide 는 Windows 예시를 `sfs.cmd` 기준으로 정리했습니다.
- [Windows SFS 래퍼 장애 요약 보고서](./docs/ko/windows-wrapper-incident-0.6.56.md) 는 P1-P15
  문제 목록과 0.6.47 GitHub smoke run `25535059980` 실패 근거까지 포함합니다.

## 0.6.47

이번 버전은 0.6.46 을 실제 GitHub Windows runner 에 올린 뒤 확인된 마지막 인자 수신 문제를
좁힙니다. 0.6.46 에서 Scoop manifest target 은 실제로 `sfs.ps1` 로 바뀌었지만,
`ValueFromRemainingArguments` script param 이 `version` 인자를 받지 못해 `sfs version` 이 다시
usage-only 로 떨어졌습니다.

- packaged `sfs.ps1` 에서 param block 을 제거했습니다.
- `sfs.ps1` 은 이제 numbered env bridge 다음에 PowerShell 자동 `$args` 를 읽고, 그 뒤
  `CMDCMDLINE`, `$MyInvocation.UnboundArguments` fallback 을 유지합니다.
- `sfs.cmd` 는 직접 실행/호환용 trampoline 으로 남아 env bridge 와 `%*` fallback 을 계속 제공합니다.
- Windows guardrail 과 release verifier 는 이제 packaged `sfs.ps1` 안의 `ValueFromRemainingArguments` 를
  회귀로 보고 실패시킵니다.
- [Windows SFS 래퍼 장애 요약 보고서](./docs/ko/windows-wrapper-incident-0.6.56.md) 는 P1-P14
  문제 목록과 0.6.46 GitHub smoke run `25534566676` 실패 근거까지 포함합니다.

## 0.6.46

이번 버전은 0.6.45 를 실제 GitHub Windows runner 에 올린 뒤에도 남아 있던 최초
`sfs version` usage-only 실패를 다시 좁힙니다. 결론은 더 명확해졌습니다. Scoop 이 생성하는
primary shim 은 packaged `bin\sfs.cmd` 를 target 으로 삼으면 안 되고, `bin\sfs.ps1` 을 직접
호출해야 합니다.

- Scoop manifest 는 이제 `bin\sfs.ps1` 을 통해 `sfs` / `sfs.cmd` shim 을 노출합니다.
- `sfs.ps1` 은 Scoop PowerShell shim 의 positional args 를 받으면서도 env bridge, `$args`,
  `CMDCMDLINE`, `$MyInvocation.UnboundArguments` fallback 을 유지합니다.
- packaged `sfs.cmd` 는 직접 실행/호환용 thin trampoline 으로 남고, `%*` 를 보조 fallback 으로
  `sfs.ps1` 에 같이 넘깁니다.
- Windows guardrail 과 release verifier 는 이제 Scoop manifest 가 `bin\sfs.ps1` 을 primary target 으로
  쓰는지 확인하고, generated shim -> packaged `.cmd` 경로를 기본값으로 되돌리면 실패합니다.
- [Windows SFS 래퍼 장애 요약 보고서](./docs/ko/windows-wrapper-incident-0.6.56.md) 는 P1-P13
  문제 목록과 0.6.45 GitHub smoke run `25533332634` 실패 근거까지 포함합니다.

## 0.6.45

이번 버전은 0.6.44 를 실제 GitHub Windows runner 에 올린 뒤에도 남아 있던 `sfs.cmd`
인자 손실을 한 번 더 좁힙니다. 0.6.44 의 `%1..%n` numbered env bridge 도 Scoop shim 아래에서는
빈 인자로 시작될 수 있었고, `sfs version` 은 또 usage-only 로 떨어졌습니다.

- `sfs.ps1` 은 이제 numbered env bridge, positional param, `$args` 가 모두 비어 있을 때
  Windows 의 원본 `CMDCMDLINE` 명령행을 마지막 fallback 으로 파싱합니다.
- 이 fallback 은 `sfs` / `sfs.cmd` 뒤의 실제 명령 꼬리만 꺼내 같은 SFS 인자 목록으로 정규화합니다.
- Windows guardrail 과 release verifier 는 이제 `CMDCMDLINE` fallback reader 와 command-line
  splitter 를 필수로 확인합니다.
- [Windows SFS 래퍼 장애 요약 보고서](./docs/ko/windows-wrapper-incident-0.6.56.md) 는 P1-P12
  문제 목록과 `스프린트 생성 테스트` Windows smoke 기준으로 최신화했습니다.

## 0.6.44

이번 버전은 0.6.43 을 실제 GitHub Windows runner 에 올린 뒤에도 남아 있던 `sfs.cmd`
인자 손실을 고칩니다. 0.6.43 의 PowerShell `-Command @args` 경로도 Scoop shim 아래에서는
`sfs version` 을 usage-only 로 떨어뜨렸습니다. 그래서 Windows wrapper 는 이제 PowerShell CLI
argument binding 을 기본 신뢰 경로에서 제거합니다.

- `sfs.cmd` 는 받은 `%1..%n` 인자를 `SFS_NATIVE_ARGC` / `SFS_NATIVE_ARG_N` 번호 환경 변수로 저장한
  뒤, 인자 없이 `sfs.ps1` 을 실행합니다.
- `sfs.ps1` 은 이 numbered env bridge 를 첫 번째 인자 소스로 읽고, 그 다음 positional param,
  `$args`, `$MyInvocation.UnboundArguments` 를 fallback 으로 정규화합니다.
- Windows guardrail 과 release verifier 는 이제 예전 `-File ... %*` bridge 와
  `-Command "& $env:SFS_NATIVE_SCRIPT @args"` bridge 를 모두 실패로 봅니다.
- [Windows SFS 래퍼 장애 요약 보고서](./docs/ko/windows-wrapper-incident-0.6.56.md) 는 이후 P1-P12
  문제 목록과 `스프린트 생성 테스트` Windows smoke 기준으로 최신화했습니다.

## 0.6.43

이번 버전은 0.6.42 를 실제 GitHub Windows runner 에 올린 뒤에도 남아 있던 마지막 Windows
인자 전달 실패를 고칩니다. 0.6.42 에서 batch label 은 제거됐지만, Scoop shim 아래에서는
`powershell.exe -File sfs.ps1 %*` 경로도 `sfs version` 을 usage-only 로 떨어뜨렸습니다.
이 릴리스의 `-Command @args` 경로도 실제 Windows smoke 에서 실패해 0.6.45 numbered env bridge 로
후속 보강됐습니다.

- `sfs.cmd` 는 이제 `-File` 이 아니라 PowerShell `-Command "& $env:SFS_NATIVE_SCRIPT @args"`
  경로로 `sfs.ps1` 을 호출합니다.
- `sfs.ps1` 은 positional array param 을 첫 번째 인자 소스로 받고, 그 다음 `$args` 와
  `$MyInvocation.UnboundArguments` 를 fallback 으로 정규화합니다.
- Windows guardrail 과 release verifier 는 이제 예전 `-File ... %*` bridge 를 실패로 보고,
  `SFS_NATIVE_SCRIPT @args` 경로를 필수로 확인합니다.
- [Windows SFS 래퍼 장애 요약 보고서](./docs/ko/windows-wrapper-incident-0.6.56.md) 는 이후 P1-P12
  문제 목록과 `스프린트 생성 테스트` Windows smoke 기준으로 최신화했습니다.

## 0.6.42

이번 버전은 0.6.41 을 실제 GitHub Windows runner 에 올린 뒤 남아 있던 `sfs.cmd` 인자 손실을
마저 제거합니다. 결론은 더 세게 단순해졌습니다. Windows 의 `sfs.cmd` 는 더 이상 batch label 로
판단하거나 전달하지 않고, 곧장 `sfs.ps1` 로 들어가는 얇은 PowerShell trampoline 입니다.

- `sfs.cmd` 안의 `call :...` label dispatch 를 제거했습니다. Scoop shim 아래에서 label forwarding
  자체가 `sfs version` 을 usage-only 로 떨어뜨릴 수 있었기 때문입니다.
- `sfs.ps1` 이 `version`, `status`, `guide`, `context`, Scoop self-upgrade, Bash fallback 을 모두
  소유합니다. Windows PowerShell/cmd 에서도 macOS 의 `sfs` 처럼 명령 인자를 받아야 한다는 목표에
  맞춘 고정 경로입니다.
- Windows guardrail 과 release verifier 가 이제 `sfs.cmd` 안의 batch label, raw Git Bash `%*`,
  `SFS_ORIGINAL_ARGS`, batch-owned `scoop update` 를 모두 실패로 봅니다.
- 현재 0.6.54 기준으로는 0.6.49 이하의 깨진 wrapper 때문에 `sfs.cmd update` 도 usage 만 출력하는
  경우 최초 1회 `scoop update` 후 `scoop update sfs`, 그리고 `sfs.cmd upgrade --no-self-upgrade` 로 복구합니다.
- [Windows SFS 래퍼 장애 요약 보고서](./docs/ko/windows-wrapper-incident-0.6.56.md) 는 이후
  P10-P12 PowerShell shim 문제까지 포함하는 0.6.45 기준으로 최신화했습니다.

## 0.6.41

이번 버전은 0.6.40 을 실제 GitHub Windows runner 에 올린 뒤 남아 있던 Windows 전용 문제를
고칩니다. 결론은 더 단순해졌습니다. Windows 에서 실행되는 `.ps1` / `.cmd` 는 PowerShell 5.1 의
legacy decoding 을 견디도록 ASCII 로 고정하고, `sfs.cmd` 는 저장해 둔 인자 변수가 아니라 실제
call-label `%*` 를 바로 `sfs.ps1` 에 전달합니다.

- `install-cli-discovery.ps1` 등 Windows PowerShell/cmd 스크립트에서 non-ASCII 문자를 제거했습니다.
  BOM 없는 UTF-8 파일을 Windows PowerShell 5.1 이 ANSI 로 읽으면서 parser error 를 내던 문제를
  막습니다.
- `sfs.cmd` 는 `SFS_ORIGINAL_ARGS` 캐시를 쓰지 않습니다. Scoop shim 경로에서 빈 인자로 떨어져
  `sfs version` 이 usage 만 출력하던 경로를 제거했습니다.
- Windows guardrail 과 release verifier 가 `.ps1` / `.cmd` ASCII-only, direct `%*` forwarding,
  same-line `exit /b !ERRORLEVEL!` 계약을 함께 검사합니다.
- [Windows SFS 래퍼 장애 요약 보고서](./docs/ko/windows-wrapper-incident-0.6.56.md) 는 이후
  P1-P12 문제 목록과 0.6.45 기준 검증 경로로 최신화했습니다.

## 0.6.40

이번 버전은 0.6.39 배포 후 실제 GitHub Windows runner 에서 다시 잡힌 마지막 wrapper 문제를
고칩니다. 목표는 그대로입니다. Windows PowerShell/cmd 에서 `sfs.cmd` 가 macOS 의 `sfs` 처럼
명령 인자를 받고, upgrade 뒤에도 이상한 조각 명령을 실행하지 않아야 합니다.
이 릴리스는 실제 Windows Scoop smoke 에서 PowerShell 5.1 parser / Scoop shim 인자 문제가
추가로 확인되어 0.6.41 로 후속 보강됐습니다.

- `sfs.cmd` 의 same-line 종료 방식을 `exit /b !ERRORLEVEL!` 로 바꿨습니다. 0.6.39 의
  `call exit /b %%ERRORLEVEL%%` 형태는 실제 Windows/Scoop shim 조합에서 안정적이지 않았습니다.
- batch wrapper 는 delayed expansion 을 켜고, `sfs.ps1` 호출 뒤 같은 parsed line 에서 종료합니다.
- Scoop post-install 의 `install-cli-discovery.ps1` 는 Claude filesystem-direct fallback 실패를
  명시적으로 catch 한 뒤 cleanup 하도록 보강했습니다.
- Windows CI 는 계속 이전 로컬 패키지 설치 -> `sfs.cmd upgrade` -> 한국어 `sfs.cmd start` 순서로
  실제 Windows 동작을 검증합니다.

## 0.6.39

이번 버전은 Windows PowerShell/cmd 에서 `sfs.cmd` 가 macOS 의 `sfs` 처럼 실제 명령을 받도록
고칩니다. 0.6.38 설치 후에도 `sfs.cmd context cat ...` 과 `sfs.cmd start ...` 가 usage 만
출력하던 문제를 수정했습니다.
이 릴리스는 실제 Windows Scoop smoke 에서 추가 batch exit/parser 문제가 발견되어 0.6.40 으로
후속 보강됐습니다.

- `sfs.ps1` 이 Windows PowerShell 5.1 의 불안정한 script param catch-all 에 의존하지 않고
  `$args` / `$MyInvocation.UnboundArguments` 로 명령 인자를 직접 정규화합니다.
- `sfs.cmd` 는 self-upgrade 뒤 batch 파일이 교체되어도 다음 줄을 읽지 않도록 PowerShell 호출과
  종료를 같은 parsed line 으로 고정했습니다. `e`, `*` 같은 조각 문자열이 명령처럼 실행되는 잔여
  문제를 막습니다.
- Windows Scoop smoke 가 이제 `sfs.cmd context cat kernel`, `sfs.cmd context cat commands/start.md`,
  `sfs.cmd start --id ci-sprint-test "sprint-create-test"`, 이벤트 goal, `sfs.cmd status` 까지
  검증합니다.
- 같은 Windows smoke 가 로컬 이전 Scoop 패키지에서 현재 패키지로 `sfs.cmd upgrade` 를 실제 실행하고,
  `e`, `*`, `TIVE_READONLY_DONE`, `LF_UPGRADE_DONE` 같은 batch tail-fragment 가 나오지 않는지 확인합니다.
- Windows smoke 가 한국어 goal `스프린트 생성 테스트` 도 `sfs.cmd start` 로 생성하고 이벤트 goal 까지
  확인합니다.
- Windows wrapper 장애 보고서는 이후 0.6.45 최종 기준선으로 최신화했습니다.

## 0.6.38

이번 버전은 0.6.37 Windows Scoop self-upgrade 수정은 그대로 유지하면서, Homebrew 설치본에서 새
incident-report 문서 테스트가 `CHANGELOG.md` / `RELEASE-NOTES.md` 위치를 잘못 보는 문제를 고칩니다.

- Homebrew 설치본에서는 런타임 테스트가 `libexec/tests` 에서 실행되고, 상위 문서는 Cellar 버전
  루트에 있습니다.
- `test-windows-wrapper-incident-report.sh` 가 source layout 과 Homebrew installed layout 둘 다
  이해하도록 고쳤습니다.
- Windows 사용자는 0.6.37 에 들어간 `sfs.cmd upgrade` self-replacement 방지 수정을 그대로
  받습니다.
- Windows wrapper 장애 보고서는 이후 0.6.45 기준 링크와 P1-P12 문제점 정리로 최신화했습니다.

## 0.6.37

이번 버전은 Windows Scoop 설치본에서 `sfs.cmd upgrade` 가 자기 자신을 교체하는 batch 파일 안에서
계속 실행되며 `TIVE_READONLY_DONE`, `LF_UPGRADE_DONE` 같은 조각 문자열을 명령처럼 실행하던
문제를 고칩니다.

- `sfs.cmd` 는 더 이상 `scoop update` / `scoop update sfs` 를 직접 실행하지 않습니다.
- Windows self-upgrade 는 이미 인자를 정규화하고 메모리 실행에 더 안전한 `sfs.ps1` 이 맡습니다.
- `sfs.cmd` 는 native read-only 확인 후 나머지 명령을 PowerShell entrypoint 로 넘기는 얇은 wrapper
  로 돌아갑니다.
- 이번 Windows wrapper 장애 흐름과 발견된 문제점은
  [Windows SFS 래퍼 장애 요약 보고서](./docs/ko/windows-wrapper-incident-0.6.56.md) 에 정리했습니다.

## 0.6.36

이번 버전은 0.6.35 Windows 래퍼 수정 자체는 유지하면서, Homebrew 설치본의 문서 검증 테스트가
`CHANGELOG.md` 위치를 잘못 보는 문제를 고칩니다.

- Homebrew 설치본에서는 `CHANGELOG.md` 가 `libexec` 안이 아니라 Cellar 버전 루트에 있습니다.
- `test-docs-model-routing.sh` 가 source layout 과 Homebrew installed layout 둘 다 이해하도록
  고쳤습니다.
- Windows 사용자는 0.6.35 에 들어간 `sfs.cmd -> sfs.ps1 -> Bash runtime` bridge 수정을 그대로
  받습니다.
- Windows 에서 실제로 관찰된 usage-only, 빈 출력, 한국어 깨짐, Homebrew installed layout 문제는
  [Windows SFS 래퍼 장애 요약 보고서](./docs/ko/windows-wrapper-incident-0.6.56.md) 에 정리했습니다.

## 0.6.35

이번 버전은 Windows Scoop 설치본에서 `sfs.cmd` 가 다시 usage 만 출력하거나,
`sfs.cmd start "<한국어 목표>"` 후 출력/인코딩이 불안정해지는 문제를 고칩니다.

- `sfs.cmd status`, `sfs.cmd context cat kernel` 같은 읽기 명령이 PowerShell entrypoint 에
  인자를 확실히 넘기도록 다시 고정했습니다.
- `sfs.ps1` 은 `powershell.exe -File ... status`, `... context cat kernel`, `-SfsArgs`
  배열 호출 모양을 모두 같은 인자 목록으로 정규화합니다.
- `sfs.cmd start "<목표>"` 같은 상태 변경 명령도 raw Git Bash 직행 대신 PowerShell bridge 를
  거친 뒤 Bash runtime 으로 내려갑니다. 그래서 Windows 에서는 성공한 쪽, 즉 PowerShell 이
  Unicode-safe 인자 배열을 들고 있는 경로로 고정됩니다.
- PowerShell bridge 는 UTF-8 console/native-command encoding 과 Git Bash UTF-8 locale 을
  기본으로 맞춥니다.
- Windows 테스트는 가능하면 실제 `powershell.exe -File sfs.ps1 context cat kernel` 과
  `status` 호출까지 실행해 usage-only 회귀를 잡습니다.

## 0.6.34

이번 버전은 SFS 모델 라우팅을 사용자가 따로 설정하지 않아도 기본 적용되게 바꿉니다.

- 단순 relay, 누락 인자 질문, 낮은 위험의 짧은 요약은 helper-grade intake 로 처리합니다.
  Codex 기준 기본값은 `gpt-5.4-mini` 입니다.
- brainstorm 질문 생성, 선택지 framing, 답변 요약은 facilitator tier 로 처리합니다.
  Codex 기준 기본값은 `gpt-5.4` 입니다.
- 하위모델 출력이 질문/선택지를 설계하거나 답변을 해석하거나 gate/plan 에 영향을 주면
  최상위 advisor 검토가 필수입니다. Codex advisor 는 `gpt-5.5` xhigh 입니다.
- 이 승격은 자동 content classifier 가 아니라 SFS role label 과 self-CPO/review 규칙으로 강제합니다.
- Helper-grade 단순 I/O 는 advisor 검토를 생략할 수 있습니다.
- advisor 호출은 self-CPO PASS 를 대체하지 않습니다. external/cross review 전에는 요구사항,
  AC, 구현 slice, ADR/decision id, file/artifact/evidence, SEED/placeholder/mock/fallback
  non-acceptance 를 확인한 self-CPO mini-check 를 남겨야 합니다.
- review executor 는 full CPO prompt 전에 작은 bridge probe 를 먼저 실행합니다. Claude/Codex/Gemini
  CLI 가 무출력으로 멈추면 full review 로 들어가지 않고 `/sfs auth probe` 또는
  `SFS_REVIEW_<EXECUTOR>_CMD` 설정을 안내합니다.
- Claude review bridge 기본값은 성공이 확인된 `claude -p "$(cat)"` prompt-argument 경로로 고정했습니다.
  실패가 확인된 `claude -p --dangerously-skip-permissions` stdin 경로는 더 이상 기본값으로 쓰지 않습니다.
- Gemini 는 facilitator/advisor/review 기본값으로 `gemini-3.1-pro-preview`, helper-grade fallback 으로
  `gemini-3-flash-preview` 만 명시합니다. 3.x 미만 fallback 은 쓰지 않습니다.
- 구현 worker 는 그대로 `gpt-5.3-codex`, 기계적 helper 는 `gpt-5.3-codex-spark` 입니다.
- 새 프로젝트와 fallback 상태의 기존 프로젝트는 `solon_recommended` role routing 을 기본값으로 씁니다.

## 0.6.33

이번 버전은 Claude/Codex/Gemini SFS 어댑터가 사용자 언어와 SFS 용어를 섞어 이상한 선택지로
보여 주는 문제를 막는 핫픽스입니다.

- 택소노미를 조직명이 아니라 SFS의 제품 기능 계약으로 명시했습니다.
- `sfs start` 처럼 필수 인자가 빠졌을 때 `Other`, `Type something` 같은 앱 placeholder 를
  선택지처럼 보여 주지 않도록 막았습니다.
- 한국어 사용자가 `sfs start` goal 을 빼먹으면 한 문장 질문으로
  `이번 sprint 목표를 한 줄로 말해 주세요. 예: "docker compose 구조 리디자인"` 를 쓰도록 했습니다.
- 같은 guardrail 이 Claude, Codex, Gemini 어댑터와 SFS kernel 전체에 적용됩니다.

## 0.6.32

이번 버전은 0.6.31 에서도 남아 있던 Windows CMD 인자 전달 문제를 다시 고칩니다.

- `sfs.cmd` 가 원본 인자를 batch subroutine 안이 아니라 파일 최상단에서 먼저 캡처합니다.
- `sfs.cmd status`, `sfs.cmd version --check`, `sfs.cmd context cat ...` 이
  PowerShell native 경로로 넘어갈 때 같은 원본 인자를 사용합니다.
- 0.5.96 시절처럼 ordinary Git Bash command forwarding 은 기존 `%*` 전달 방식을 유지합니다.

## 0.6.31

이번 버전은 0.6.30 의 Windows native read-only 경로에서 생긴 인자 전달 버그를 고칩니다.

- `sfs.cmd status` 가 `status` 인자를 잃고 usage 만 출력하던 문제를 수정했습니다.
- `sfs.cmd version --check` 가 `version --check` 인자를 잃고 usage 만 출력하던 문제를 수정했습니다.
- `sfs.cmd context cat ...` 도 같은 캡처된 인자 전달 경로를 사용합니다.

## 0.6.30

이번 버전은 Windows Codex 앱 또는 Git Bash 안에서 실행한 Codex 가 SFS 읽기 명령까지
Git Bash 로 들어가며 멈추던 문제를 한 번 더 막는 핫픽스입니다.

- `sfs.cmd status`, `sfs.cmd version`, `sfs.cmd context path ...`,
  `sfs.cmd context cat ...` 는 이제 Git Bash 없이 Windows native 로 동작합니다.
- Codex/Claude/Gemini adapter 는 Windows 에서 routed context 를 읽을 때
  `sfs.cmd context cat ...` 를 우선 사용하도록 안내합니다.
- agent runner 가 Git Bash 를 못 띄우면 읽기 명령은 native fallback 으로 처리하고,
  `start` 같은 상태 변경 명령은 사용자가 PowerShell/cmd 에서 직접 실행하도록 안내합니다.
- Windows 가이드에 Codex 앱/Git Bash sandbox 실패 대응 절차를 보강했습니다.

## 0.6.29

이번 버전은 Windows 에서 Claude, Gemini, Codex 의 SFS 명령이 Git Bash 시작 전에
`couldn't create signal pipe, Win32 error 5` 로 막히던 흐름을 고친 핫픽스입니다.

- Windows PowerShell/cmd 에서는 `sfs.cmd --help`, `sfs.cmd guide` 가 Git Bash 없이도 바로 출력됩니다.
- Claude, Gemini, Codex 용 SFS adapter 는 Windows 실행 시 `sfs.cmd ...` 를 우선 사용하도록 안내합니다.
- `sfs start` 같은 상태 변경 명령이 빈 stdout/stderr 로 끝나면 성공으로 보지 않도록 guardrail 을 추가했습니다.
- `start` 성공은 `.sfs-local/current-sprint` 와 sprint 폴더가 실제로 생겼을 때만 인정합니다.
- Windows 사용자 가이드에 agent 실행 sandbox / Git Bash signal-pipe 에러 대응 절차를 추가했습니다.

## 0.6.28

이번 버전은 0.6.27 에 추가한 native 언어 커밋 메시지 테스트가 Homebrew 설치본에서도 그대로
통과하도록 고친 핫픽스입니다.

- Homebrew 설치본은 `README.md` 를 Cellar 루트에 두고 runtime 테스트는 `libexec` 아래에서 실행합니다.
- native 언어 커밋 메시지 테스트가 source layout 과 installed Homebrew layout 둘 다 이해하도록 수정했습니다.
- 사용자-facing 규칙은 0.6.27 과 같습니다. 커밋 메시지는 사용자의 native/workspace 언어가 기본입니다.

## 0.6.27

이번 버전은 agent 가 커밋 메시지를 사용자의 native 언어 또는 workspace 언어로 쓰도록 기본 규칙을
바꿉니다.

- 한국어 사용자에게는 `수정: 로그인 오류 안내 개선` 처럼 한국어 커밋 메시지가 기본입니다.
- 영어 커밋 메시지는 사용자의 native 언어가 영어이거나 repo 가 영어 커밋을 명시적으로 요구할 때만 기본값입니다.
- `sfs implement` 의 병렬 lane commit message 도 같은 규칙을 따릅니다.
- `sfs review` 는 proposed/actual commit message 가 사용자 언어와 맞는지도 확인합니다.
- install/upgrade/uninstall 안내의 예시 커밋 메시지도 한국어 UX에서는 한국어로 보입니다.

## 0.6.26

이번 버전은 디자인본부 시스템에 AI 슬롭 방지용 디자인 시스템 운영 규칙을 추가합니다.

- `design.md` 또는 `docs/solon/design.md` 를 AI 가 읽는 디자인 시스템 계약으로 봅니다.
- 디자인/frontend 구현은 `design.md` 를 먼저 읽고, 구현 후 token drift 를 확인하도록 안내합니다.
- review 는 임의 색상, 임의 type scale, 임의 spacing/radius, 섞인 icon style, generic AI 슬롭 느낌을 finding 으로 볼 수 있습니다.
- 한국어 제품 starter set 으로 원티드 몽타주식 컴포넌트, Coolicons 같은 단일 icon family, Pretendard 같은 Korean-capable font 를 참고하되, 기존 design system 이 있으면 기존 system 을 우선합니다.
- 10x value 문서에 multi-agent implement 와 design-system governance 를 AI 시대의 실행/품질 leverage 로 반영했습니다.

## 0.6.25

이번 버전은 구현 작업량이 클 때 여러 agent 를 병렬로 쓰는 선택지를 추가합니다. 기본값은 그대로
Single Agent 입니다.

- `sfs implement` 출력에서 기본 Single Agent 와 선택형 parallel agent 명령을 함께 안내합니다.
- 병렬 모드는 `sfs implement --agent-mode parallel --agents codex,claude[,gemini] ...` 로 명시적으로 선택합니다.
- 병렬 lane 은 files_scope 가 겹치지 않아야 하고, lane 별 commit message 를 한 문장으로 설명할 수 있어야 합니다.
- 구현이 끝나면 Single Agent 도 `sfs review --gate 6` 가 필수입니다.
- 병렬 agent 로 구현했다면 Gate 6 전에 agent 간 cross review evidence 도 필수입니다.

## 0.6.24

이번 버전은 0.6.23 에 추가한 문서 테스트가 Homebrew 설치본에서도 그대로 통과하도록 고친 핫픽스입니다.

- Homebrew 설치본은 `README.md` 를 Cellar 루트에 두고 runtime 파일은 `libexec` 아래에 둡니다.
- 문서 테스트가 source layout 과 installed Homebrew layout 둘 다 이해하도록 수정했습니다.
- 사용자 문서 내용은 0.6.23 의 모델 라우팅 최신화 그대로 유지됩니다.

## 0.6.23

이번 버전은 0.6.22 의 Codex worker 모델 라우팅을 사용자 문서까지 맞춘 문서 핫픽스입니다.

- README, GUIDE, BEGINNER-GUIDE, 한국어/영어 docs 의 오래된 0.6.17 기준 문구를 현재 기준으로 정리했습니다.
- C-Level/review 는 high reasoning, Claude worker 는 Sonnet 계열, Codex worker 는 `gpt-5.3-codex` 라고 설명합니다.
- `gpt-5.3-codex-spark` 는 일반 구현 worker 가 아니라 scope/files_scope/AC 가 잠긴 helper subtask 용도라고 명시했습니다.
- architecture, public contract, security, privacy, data-loss, release gate, 반복 실패가 있으면 high reasoning 으로 승격한다고 문서화했습니다.

## 0.6.22

이번 버전은 Codex 쪽 구현 worker 모델 기본값을 명확히 나누는 핫픽스입니다.

- C-Level/review 는 계속 high reasoning 모델이 맡습니다.
- Codex 구현 worker 기본값은 `gpt-5.3-codex` 입니다.
- `gpt-5.3-codex-spark` 는 일반 구현 worker 가 아니라 scope/files_scope/AC 가 잠긴 기계적 helper subtask 용도입니다.
- architecture, public contract, security, privacy, data-loss, release gate, 반복 실패 같은 위험이 있으면 worker 도 high reasoning 으로 승격합니다.
- Claude 쪽 worker 기본값은 기존처럼 Sonnet 계열로 유지됩니다.

## 0.6.21

이번 버전은 Gate 3 review 를 많이 돌렸다는 이유로 implement 여부를 묻던 흐름을 막는 핫픽스입니다.

- self review 가 먼저 PASS 해야 합니다.
- self review PASS 이후에 cross review 를 돌립니다.
- cross review 가 partial/fail 이면 plan 을 고친 뒤 다시 self review 부터 시작합니다.
- review round 수, lens 수, advisor 지적 수, “충분히 봄”은 PASS 를 대신할 수 없습니다.
- 최신 Gate 3 review 가 partial/fail 이면 `sfs implement` 는 계속 막힙니다.

## 0.6.20

이번 버전은 같은 Gate review 를 반복할 때 lens 가 `docs` 에서 `design` 처럼 바뀌어 review loop 가 수렴하지 않던 문제를 고친 핫픽스입니다.

- 첫 `sfs review --lens auto` 는 기존처럼 작업 evidence 를 보고 lens 를 고릅니다.
- 같은 sprint/gate 의 다음 auto review 는 이전 lens 를 재사용합니다.
- 의도적으로 lens 를 바꾸려면 `--lens design` 처럼 명시적으로 지정해야 합니다.
- 그래서 "pass 될 때까지" 반복의 의미가 같은 기준 안에서 유지됩니다.

## 0.6.19

이번 버전은 Gate 3 계획이 끝났다고 바로 구현으로 넘어가며 사용자에게 모델 선택을 묻던 흐름을 막는 핫픽스입니다.

- `sfs implement` 는 이제 Gate 3 Plan review PASS 없이는 시작하지 않습니다.
- 정상 흐름은 `sfs plan` 다음 `sfs review --gate 3`, 그 다음 `sfs implement` 입니다.
- C-Level 모델은 설계, 계약, AC, 검토 handoff 를 책임지고, worker/generator 모델이 고정된 구현 slice 를 맡는다는 역할 경계를 명시했습니다.
- 예외적으로 사용자가 plan review 를 건너뛰라고 명시한 경우에만 `--allow-unreviewed-plan` 으로 진행할 수 있고, 그 waiver 는 기록됩니다.
- 앞으로 Action Rail 이 ready plan 에서 바로 구현/모델 선택으로 뛰면 guardrail 테스트가 실패합니다.

## 0.6.18

이번 버전은 UX가 있는 작업에서 Solon 이 "경고/차단"부터 말하지 않고, 사용자가 바로 고칠 수 있는 흐름을 먼저 설계하도록 바꾼 핫픽스입니다.

- 입력값 검증은 먼저 무엇을 어디서 어떻게 고치면 되는지 보여줘야 합니다.
- `[Product]` 같은 미치환 placeholder 는 field 가까이에 표시하고, focus/clear/replace/AI에게 맡기기 같은 회복 경로를 요구합니다.
- "잘못된 입력" 같은 막힌 문구보다 "아직 실제 값으로 바꿔야 할 부분이 있어요" 같은 coaching tone 을 쓰도록 디자인 지식팩을 보강했습니다.
- 서버 4xx 는 비용/보안/데이터 무결성을 지키는 마지막 안전망으로만 다루고, UI 가 같은 field-level 복구 안내로 렌더링할 수 있어야 합니다.
- 앞으로 이 repair-first UX 계약이 빠지면 패키지 테스트가 실패합니다.

## 0.6.17

이번 버전은 review 통과 후 다음 액션 안내가 `sfs report` 를 불필요하게 먼저 권하던 문제를 바로잡은 핫픽스입니다.

- 정상 마무리 경로는 `sfs retro` 하나입니다.
- `retro` 는 이미 `report.md` 를 확인하거나 만들고, `retro.md` 를 정리하고, sprint close 까지 이어갑니다.
- `sfs report` 는 보고서만 미리 보거나 과거 sprint 보고서를 다시 만들 때 쓰는 선택 명령으로 정리했습니다.
- review/tidy context 와 CPO review prompt 에서 `report -> retro` 안내가 다시 나오지 않도록 테스트를 추가했습니다.

## 0.6.16

이번 버전은 Gate 3 같은 계획 보고서에서 결정 질문이 너무 압축되어 보이던 문제를 바로잡은 핫픽스입니다.

- 보고서가 `Q1`, `D1`, `AC-1` 같은 식별자만 앞세워 사용자의 결정을 요구하지 않도록 했습니다.
- 결정이 필요할 때는 무엇을 결정하는지, 왜 지금 필요한지, 권장 기본값이 무엇인지, 각 선택지가 무엇을 바꾸는지 풀어서 설명해야 합니다.
- Gate 3 plan 이 아직 draft 인 경우에도 마지막 질문은 짧은 decision brief 로 남기도록 context 를 보강했습니다.
- Claude, Gemini, Codex adapter template 모두 같은 보고서 명료성 규칙을 갖습니다.
- 앞으로 이 규칙이 빠지면 agent behavior guardrail 테스트가 실패합니다.

## 0.6.15

이번 버전은 릴리스 노트가 stable package 에 누락되던 배포 스크립트 문제를 바로잡은 핫픽스입니다.

- dev 에서는 0.6.13, 0.6.14 릴리스 노트가 최신이었지만 stable tag 와 설치본에는 `RELEASE-NOTES.md` 가 오래된 상태로 남을 수 있었습니다.
- `cut-release.sh` 가 이제 `RELEASE-NOTES.md` 를 stable 제품 저장소로 함께 동기화합니다.
- 앞으로 release cutter allowlist 에서 릴리스 노트가 빠지면 테스트가 실패하도록 막았습니다.

## 0.6.14

이번 버전은 실사용 중 발견된 review lens 이름 불일치를 바로잡은 핫픽스입니다.

- `sfs review --lens strategy-pm` 처럼 본부 이름을 넣어도 이제 `strategy` lens 로 정상 처리됩니다.
- `strategy_pm`, `design/frontend`, `infra`, `finance`, `accounting` 같은 자주 나오는 표현도 공개 lens 이름으로 정규화됩니다.
- `management-admin` 은 재무 기록, 경리, 세무/회계 질문, 현금 evidence 를 보는 review lens 로 직접 사용할 수 있습니다.
- 잘못된 lens 를 넣었을 때 오류 메시지가 alias 예시를 함께 보여줍니다. agent 가 엉뚱한 lens 로 오래 기다리는 일을 줄이기 위한 조치입니다.

## 0.6.13

이번 버전은 Claude, Codex, Gemini 를 팀처럼 쓰는 방식을 Solon 답게 얇게 반영한 릴리스입니다.

- 큰 조사나 마이그레이션 판단이 필요할 때 사용할 수 있는 read-only researcher 역할이 추가됐습니다.
- researcher 는 코드를 직접 고치거나 품질 승인을 하지 않습니다. 넓게 읽고, 필요한 사실과 근거만 작게 남깁니다.
- 모델 프로필에 `research_high` 단계가 추가되어 Gemini 처럼 긴 컨텍스트에 강한 도구를 조사 역할에 더 자연스럽게 배치할 수 있습니다.
- 구현은 여전히 작은 파일 범위와 명확한 작업 단위로 나눕니다. 여러 에이전트를 쓰더라도 프로젝트 표면이 커지지 않도록 했습니다.
- 리뷰는 작성자와 분리된 관점으로 보게 했습니다. 같은 agent 가 만든 코드를 같은 맥락에서 다시 승인하는 흐름은 위험 신호로 다룹니다.
- 도메인 용어가 sprint 를 넘어 오래 살아야 할 때는 `docs/solon/domain-map.md` 같은 짧은 공유 문서로 남기는 방향을 안내합니다.
- 사용자가 굳이 멀티 에이전트 구성을 몰라도 됩니다. 작업이 작으면 기존처럼 `sfs plan`, `sfs implement`, `sfs review` 흐름으로 충분합니다.

## 0.6.12

이번 버전은 AI 가 코딩이나 문서 작업을 할 때 자주 놓치는 안전장치를 SFS 흐름 안에 얇게 넣은 릴리스입니다.

- agent 는 구현 전에 중요한 가정과 선택지를 먼저 드러냅니다. 불명확한 부분이 있으면 추측하지 않고 작은 질문으로 멈춥니다.
- 구현은 최소 유용 단위로 시작합니다. 요청과 직접 관련된 파일과 줄만 조심스럽게 건드립니다.
- 실제 파일, diff, 에러 로그, 테스트 출력을 읽고 판단하도록 kernel 과 command context 를 강화했습니다.
- 완료 전에는 가능한 가장 작은 테스트, 빌드, smoke, review check 를 실행하고 그 결과를 보고하도록 명시했습니다.
- `checklist.md` 와 `context-notes.md` 를 루트에 강제로 만들지 않습니다. 대신 SFS sprint workbench 문서 안에 계획, checklist, context note 를 남기도록 정리했습니다.
- 한국어 응답의 문장 끝 콜론 금지와 Korean-first 프로젝트의 새 source file 역할 헤더 규칙도 kernel 에 들어갔습니다.
- Claude, Codex, Gemini adapter 는 긴 규칙을 복제하지 않고 routed SFS context 를 따르도록 짧게 연결됩니다.
- Mac 에서 `sfs upgrade` 가 본체 업데이트를 못 할 때는 `brew upgrade MJ-0701/solon-product/sfs` 를 먼저 실행하시면 됩니다. 짧은 `brew upgrade sfs` 가 기대대로 동작하지 않는 경우까지 README, GUIDE, BEGINNER-GUIDE 에 보강했습니다.

## 0.6.11

이번 버전은 Solon 전체에 "남겨야 될 것만 남긴다" 원칙을 적용한 정리 릴리스입니다.

- `.sfs-local/` 은 기본 비공개 작업 공간으로 gitignore 됩니다.
- `sfs start` 는 더 이상 빈 절차 문서를 한 번에 만들지 않습니다. 각 단계 명령이 필요한 문서만 생성합니다.
- `sfs adopt --apply` 는 기존 프로젝트를 요약해서 `docs/solon/<english-workspace>/<yyyyMMdd>/handoff.md` 하나를 공유 문서로 남깁니다.
- adopt 의 raw scan, 과거 sprint, archive evidence 는 `.sfs-local/archives/` 에 private cold archive 로 접습니다.
- 이미 0.6.11 인 프로젝트도 `sfs upgrade` 를 다시 실행하면 예전 `legacy-baseline` sprint 와 빈 단계 문서 잔여물을 더 접습니다.
- 새로 생성되는 sprint 문서 템플릿은 설명문을 줄이고 실제로 채워야 할 칸만 남겼습니다.
- 새 설치는 빈 `sprints/`, `decisions/`, `queue/` 디렉터리를 미리 만들지 않습니다.

## 0.6.10

이번 버전은 Solon report 의 보이는 표면을 다시 손봤습니다.

- report 가 긴 bullet dump 처럼 보이지 않도록 title/verdict strip, 상태 패널, action rail, 질문 queue 구조를 명시했습니다.
- Claude, Gemini, Codex adapter template 모두 같은 report-surface 규칙을 갖습니다.
- 내용은 계속 간결하게 유지하지만, 사용자가 지금 봐야 할 판단/다음 행동이 더 먼저 보이도록 했습니다.

## 0.6.9

이번 버전은 "설치됐는데 실제로 바로 쓰려니 막히는" 부분을 닫는 핫픽스입니다.

- `sfs adopt "문서 정리좀 해야될거 같은데."` 처럼 기존 프로젝트를 정리하려는 자연어 brief 를 이제 정상으로 받습니다.
- `adopt` 는 기본 dry-run 입니다. 실제 파일을 만들려면 `sfs adopt --apply "..."` 를 쓰면 됩니다.
- `sfs context path adopt`, `sfs context path start`, `sfs context path sprint`, `sfs context path intake` 같은 agent routing 경로가 정상화됐습니다.
- CLI discovery 진단이 실패를 성공처럼 보이지 않게 정리됐습니다.
- Claude/Gemini/Codex 연결 메타데이터와 한국어 사용자 문서를 0.6.9 기준으로 맞췄습니다.

이미 0.6.8 을 설치했다면 `brew reinstall MJ-0701/solon-product/sfs` 또는 `sfs upgrade` 로 받으면 됩니다.

## 0.6.1

이번 버전은 Solon 이 "필요한 기준만 조용히 꺼내 쓰는" 감각을 더 또렷하게 만드는 작은 패치입니다.

- backend, 전략/PM, QA, 디자인/frontend, infra/DevOps, 경영관리, taxonomy 지식팩이 빈 목록이 아니라 실제 가이드로 채워졌습니다.
- Solo Founder 에게 꼭 필요한 재무, 경리, 세무, 회계, 인보이스, 현금 흐름, 외주/급여 증빙 기준도 경영관리 지식팩에 포함했습니다.
- 사용자는 여전히 `sfs plan`, `sfs review` 처럼 익숙한 명령만 쓰면 됩니다. Solon 이 작업 성격을 보고 필요한 관점만 얇게 읽습니다.
- 작은 문서 수정에는 작은 기준을, 배포나 구조 변경처럼 위험이 큰 작업에는 더 단단한 기준을 적용하는 쪽으로 안내가 정리됐습니다.
- 새로 설치한 프로젝트와 이미 작업 중인 프로젝트가 같은 지식팩을 보도록 active context 와 패키지 템플릿을 맞췄습니다.
- README 는 큰 지도 역할만 유지하고, 버전별 변화는 이 릴리스 노트에서 따로 확인하도록 정리했습니다.

추가로 외워야 하는 명령은 없습니다. 업데이트 후 평소처럼 `sfs status` 로 시작하면 됩니다.

## 0.6.0

이번 버전의 방향은 "프로젝트 안을 덜 어지럽게 만들고, 첫 실행을 더 빨리 성공시키는 것"입니다.

- `brew install` / `scoop install` 한 번이면 Claude Code, Gemini CLI, Codex CLI 에서 모두 Solon 을 찾습니다.
- 새 프로젝트에는 운영에 필요한 얇은 연결 문서와 `.sfs-local/` 기록 공간만 남습니다.
- 앱 뼈대는 Solon 이 특정 프레임워크로 고정하지 않습니다. 사용자가 Next.js/Spring 같은 말을 몰라도, 대화 중 필요해 보이면 AI 가 "초기 프로젝트 구성해드릴까요?"라고 묻고, 동의 시 크기에 맞는 native 구성을 잡은 뒤 Solon 으로 돌아오는 흐름을 권장합니다.
- 설치/업데이트 직후 SFS discovery 를 우선순위 1로 올립니다. 그래서 Solon 작업은 먼저 SFS 로 들어가고, 사용자가 나중에 직접 바꾼 우선순위는 존중합니다.
- 오래 걸리는 작업은 `sfs measure --alive -- <command>` 로 조용히 멈춘 것처럼 보이지 않게 진행 신호를 남길 수 있습니다.
- `review` 는 줄바꿈이나 이름만 바뀐 일을 과하게 문제 삼기보다, 사용자가 실제로 영향을 받는 변화에 더 집중합니다.
- 버전 이름은 이제 보통의 `0.6.0` 형태를 씁니다. 예전 `-product` 표기는 과거 릴리스 기록에만 남습니다.

처음 설치하거나 업데이트하는 방법은 [README.md](./README.md) 와 [GUIDE.md](./GUIDE.md) 에서 확인하세요.

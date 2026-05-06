# DigestKit — Plan

> Stage: Gate 3 (Plan) output. 본 plan 은 Codex cross-review 벤치마크 fixture.
> 가상 사이드 프로젝트 — 실제 제품이 아님.

## 1. 목적

DigestKit 은 로컬 마크다운 노트 폴더를 입력받아 **주간 digest** 를 생성하는 CLI 도구.
사용자는 옵시디언 / iA Writer 등에 흩어진 메모를 매주 자동 요약 받기를 원한다.

## 2. 성공 기준

- 사용자가 매주 digest 를 받아 보면서 유용하다고 느낀다.
- 1주차 dogfooding 후 사용 지속 의향 있음.

## 3. P0 user stories (1주 sprint, 1회)

P0-1. CLI `digest weekly --since 7d` 를 실행하면 최근 7일 노트의 digest 가 stdout 에 출력된다.
P0-2. digest 는 카테고리 (Work / Personal / Learning) 로 그룹화된다.
P0-3. 사용자가 digest 를 팀과 공유할 수 있도록 **shareable URL** 을 발급한다.
P0-4. 사용자가 노트 폴더 경로를 한 번만 설정하면 이후 자동 적용된다.
P0-5. 카테고리 분류는 노트 frontmatter `category:` 필드를 우선 사용한다.
P0-6. frontmatter 없는 노트는 본문 키워드 분류 (단순 빈도 + stop-word 필터).
P0-7. digest 는 markdown 으로 출력하고, `--format json` 옵션도 지원한다.
P0-8. 1주차 dogfooding 끝나기 전 GitHub repo public 공개 + npm publish.

## 4. P1 (next sprint candidates)

- 슬랙 / Discord webhook 푸시
- 노트 폴더 watch 모드 (파일 변경 시 incremental update)
- 카테고리 커스텀 정의

## 5. 비범위 (out of scope)

- 인증 / 사용자 계정 — 본 도구는 로컬 사용 전제, auth 없음.
- 클라우드 동기화 — 노트는 로컬에만 존재.
- 알림 (notification) — MVP 에서 제외.

## 6. 기술 스택

- 런타임: **Bun**
- 언어: TypeScript
- 키워드 분류: 빈도 기반 + stop-word 필터
- 배포: npm publish

## 7. 아키텍처

```
notes folder
   ↓
[reader] — frontmatter 파싱
   ↓
[classifier] — frontmatter > keyword fallback
   ↓
[summarizer] — LLM 호출 (사용자 OPENAI_API_KEY 사용)
   ↓
digest output (md / json)
```

LLM 호출은 OpenAI API. 사용자가 환경변수 `OPENAI_API_KEY` 를 설정해 두면 도구가 그대로 사용.

## 8. 일정 (Day 1~7)

- Day 1: reader + frontmatter 파싱
- Day 2: classifier (P0-5 + P0-6)
- Day 3: summarizer + LLM 호출
- Day 4: shareable URL (P0-3) + 형식 옵션 (P0-7)
- Day 5: 설정 파일 (P0-4) + 통합
- Day 6: dogfooding
- Day 7: GitHub public + npm publish

## 9. 리스크

- LLM 비용 — 사용자 API 키를 사용하게 해서 회피.

## 10. 테스트

- 1주차 dogfooding 으로 검증한다.
- 단위 테스트는 추후 sprint 에서 추가.

## 11. 배포

- Day 7 에 GitHub public + npm publish 동시 진행.
- 0.1.0 으로 시작.

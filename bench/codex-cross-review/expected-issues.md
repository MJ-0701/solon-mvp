# Expected Issues — DigestKit Plan Plant List

> ⛔ 답안지. RUN.md step 3 에서 비교 리포트 작성할 때 처음 연다.
> 그 전에 review 출력에 영향 주면 평가 무효화.

본 plan 에는 의도적으로 14 개의 review-bait 가 심어져 있다. 등급:
- **S** — 구조적 / 출시 위험. 좋은 reviewer 는 반드시 잡아야.
- **A** — 명백한 모순 / 누락. 평균적 reviewer 가 잡는다.
- **B** — 미묘한 / domain 지식 필요. 우수 reviewer 만.

---

## S — 구조적 / Release Readiness

### S-1. P0-3 ↔ §5 모순 (shareable URL vs no auth/no cloud)
P0-3 은 "팀과 공유할 shareable URL" 을 요구하는데, §5 비범위는 "auth 없음 / 클라우드 동기화 없음 / 로컬 전용" 이라고 못 박았다. URL 발급은 호스팅 + 공개 식별자 + (현실적으로) 어떤 형태의 권한 모델을 요구한다. 양쪽 다 만족 불가.

### S-2. Release Readiness evidence 전무
plan 은 Day 7 에 GitHub public + npm publish 까지 한다. Solon 7-step 의 Release Readiness 6 항목 (secret / auth / data / monitoring / rollback / cost) 중 어느 것도 plan 에 없음.
- secret: OPENAI_API_KEY 보관 / 노출 정책 부재
- auth: 비범위라 했지만 P0-3 이 깨버림 (S-1 과 연결)
- data: 노트 PII / 회사 자료 LLM 송신 정책 부재
- monitoring: LLM 호출 실패 / 사용량 관측 부재
- rollback: 0.1.0 npm publish 후 롤백 / yank 정책 부재
- cost: §9 에 LLM 비용 언급 있지만 사용자 키로 떠넘김 — 책임 회피일 뿐 대비책 X

### S-3. 데이터 / privacy 처리 누락
노트는 명시적으로 "옵시디언 / iA Writer / Apple Notes" 의 개인 메모 + (sprint-context 에 따르면) 회사 자료 가능성. 그 raw text 가 OpenAI API 로 그대로 전송되는데, 정책 / 사용자 고지 / opt-out / redaction 없음.

### S-4. P0 over-scope vs sprint 길이
1주 (Day 1~7) sprint 에 P0 가 8 개. Day 6 dogfooding, Day 7 출시 = 실 개발 5 일.
- P0-3 (shareable URL) 은 호스팅 / 권한 / 식별자 — 그 자체로 하루 이상.
- P0-7 markdown + json 두 포맷도 1 일.
- P0-5/6 분류 두 path 도 1 일 이상.
완료 가능 범위가 아님.

### S-5. 단위 테스트 전략 hand-wave + Day 7 출시
§10 "단위 테스트는 추후 sprint" + Day 7 npm publish public. 0 test coverage 로 public release.
0.1.0 이라 해도 dogfooding 1 일 후 공개 = 신뢰 가능한 검증 채널 부재.

---

## A — 명백한 누락 / 모순

### A-6. 성공 기준 측정 불가능
§2 "유용하다고 느낀다", "사용 지속 의향" — 둘 다 정성 표현. 매주 사용 횟수 / digest 열람 / opt-out 이탈률 등 측정 metric 없음.

### A-7. 기술 선택 근거 부재
§6 Bun 선택, classifier 알고리즘 선택 모두 "왜" 가 없음. Node 대비 Bun 선택, transformer 기반 분류 대비 빈도 기반 선택 근거 부재.

### A-8. dogfooding 1 일 = 검증 신뢰도 X
§8 Day 6 단 하루 dogfooding 후 Day 7 public release. 주간 사용 도구의 "1주 사용 의향" 을 1 일 사용으로 검증 불가능. 성공 기준 (§2) 자체 측정 불가.

### A-9. P0-3 shareable URL — 인프라 미정
shareable URL 의 호스팅 위치 / TTL / 권한 / 비용 / 만료 정책 모두 미정. P0 인데 design 깊이가 0.

### A-10. 리스크 항목 빈약
§9 리스크는 LLM 비용 1 개. 누락된 리스크 다수: classifier 정확도, dogfood-of-1 검증 무효, PII 누출 (S-3 과 연결), Bun 호환성, npm publish 후 회수 곤란.

---

## B — 미묘한 / domain 지식

### B-11. P0-5/P0-6 우선순위 tie-break 미정
frontmatter 와 키워드 분류가 다른 결과를 내면? P0-5 가 "우선" 한다 했지만, 키워드 결과는 무시? 보조 신호로 사용? 명세 부족.

### B-12. `--since 7d` 의 시간 기준 모호
파일 mtime 기준? frontmatter `date:` 기준? 노트 본문의 first heading 날짜 기준? 노트 도구마다 mtime 의미가 다름 (Apple Notes 는 sync 마다 바뀜).

### B-13. npm publish + GitHub public 동시 — 패키지 이름 / 라이선스 / README 부재
plan 에 패키지 이름, 라이선스, README, 콘텐츠 정책 등 public release 위생 항목 0.

### B-14. classifier 기본 카테고리 (Work / Personal / Learning) 의 사용자 fit
사용자 노트가 "취미 사진 / 운동기록 / 가족" 위주면 3 카테고리가 미스매치. P1 에 "커스텀 카테고리" 가 있지만, P0 의 분류 결과가 사용자에게 무용할 가능성 = MVP 검증 자체 위험.

---

## 점수표

| Run | S 잡음 | S 부분 | A 잡음 | A 부분 | B 잡음 | B 부분 | False positive | Total weight |
|---|---|---|---|---|---|---|---|---|
| A | | | | | | | | |
| B | | | | | | | | |

가중치: S=3, A=2, B=1 (부분 발견 0.5 곱).

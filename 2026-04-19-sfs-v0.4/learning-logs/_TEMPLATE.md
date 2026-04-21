---
pattern_id: P-<kebab-name>
title: "<한 줄 요약 — 이 패턴이 해결하는 문제>"
captured_from: WU-<id> (session: <codename>, date: <YYYY-MM-DD>)
visibility: raw-internal       # raw-internal | business-only | oss-public
applicability:
  - "<언제 이 패턴이 쓰이는가 — 구체 상황 1>"
  - "<언제 이 패턴이 쓰이는가 — 구체 상황 2>"
reuse_count: 0
related_patterns: []           # 교차 참조 (다른 P-<id> 배열)
---

# P-<kebab-name> — <한 줄 요약>

> **visibility**: raw-internal / business-only / oss-public 중 하나. OSS 공개 가능 여부는 `.visibility-rules.yaml` + 본 frontmatter 조합으로 결정.

---

## 문제

> 언제, 어떤 상황에서 이 문제가 발생하는가? 증상 · 원인 · 영향 범위 기술.

- 증상:
- 발생 조건:
- 원인:
- 영향:

## 해결 패턴

> 재사용 가능한 **절차 / 명령 / 코드 스니펫**. 구체적 단계로 기술.

### 단계

1.
2.
3.

### 샘플 명령 / 코드

```bash
# example
```

## 재사용 체크리스트

- [ ] 전제 조건 확인: ...
- [ ] 사이드 이펙트 검토: ...
- [ ] 롤백 가능 여부: ...
- [ ] 원칙 2 (self-validation-forbidden) 위반 여부 검토

## 관련 WU / 세션

- **최초 발견**: WU-<id> (<sha> · session: <codename>)
- **재발견 / 재사용**:
  - WU-<id>: <간단 맥락>

## Notes

> OSS 공개 시 주의 사항 · Business-only 라면 Solon 제품 특화 이유 · raw-internal 인 경우 영구 사유.

---
description: CTO Team Review - 팀 산출물 검토 및 승인
model: opus
---

# Team Review Skill

CTO가 팀원들의 산출물을 검토하고 승인/반려하는 스킬.

## Review Checklist

### Plan Review
- [ ] 요구사항이 명확하고 측정 가능한가?
- [ ] 기술적으로 실현 가능한가?
- [ ] 프로젝트 범위에 적합한가?
- [ ] Executive Summary가 4가지 관점을 포함하는가?

### Design Review
- [ ] Plan 문서와 일관성이 있는가?
- [ ] API 계약이 명확한가?
- [ ] 기존 아키텍처 패턴을 따르는가?
- [ ] ImageGenerator 인터페이스 추상화를 유지하는가?

### Code Review
- [ ] Design 문서 스펙을 충족하는가?
- [ ] Kotlin 컨벤션을 따르는가?
- [ ] 보안 이슈가 없는가? (API 키 하드코딩 등)
- [ ] suspend fun 패턴을 올바르게 사용하는가?

## Decision Template

```
## Review Decision: {document/feature}
- Reviewer: CTO Agent
- Status: APPROVED / NEEDS_REVISION / REJECTED
- Comments: {specific feedback}
- Action Items: {required changes if any}
```

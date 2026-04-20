---
name: commit
description: 커밋 메시지 규칙 검증 + 커밋 + 푸시 워크플로우
---

# Commit Skill

## 수행 절차

### 1. 브랜치 확인

- `git branch --show-current`로 현재 브랜치 확인
- master/main이면 **커밋 차단** → 사용자에게 feature 브랜치 생성 요청
- 브랜치명에서 JIRA 키 추출 시도 (예: `feature/IVS-159` → `IVS-159`, `IVS-159` → `IVS-159`)

### 2. 변경사항 확인

- `git status`로 staging 상태 확인
- staged 변경이 없으면 사용자에게 staging 안내
- `git diff --cached --stat`으로 변경 파일 목록 표시

### 3. JIRA 티켓 확인

- 브랜치명에서 추출한 JIRA 키 사용
- 추출 실패 시 사용자에게 JIRA 티켓 번호 확인

### 4. 커밋 메시지 생성

- 변경 내용 분석 후 아래 형식으로 생성:

```
{JIRA-KEY}:{type}: {간단 설명}

변경 사항:
- 주요 변경 1
- 주요 변경 2

Deploy-Note: {배포 노트}
```

#### Deploy-Note 작성 규칙

- **비개발자(영업, 기획, 운영)가 읽는다는 전제**로 작성한다.
- 기술 용어(API, Entity, DTO, Controller, Service, Repository, Redis, QueryDSL 등) 사용 금지
- 사용자/고객 관점에서 "무엇이 바뀌는지"를 한 문장으로 설명한다.
- 형식: `~할 수 있습니다`, `~가 개선됩니다`, `~가 수정됩니다`
- refactor, chore, test 등 사용자에게 보이지 않는 변경은 `Deploy-Note: 내부 코드 개선` 으로 통일한다.

#### Deploy-Note 예시

| 커밋                             | Deploy-Note                      |
|--------------------------------|----------------------------------|
| feat: 보장분석 리포트 PDF 다운로드 API 추가 | 보장분석 리포트를 PDF로 다운로드할 수 있습니다.     |
| fix: CMS 출금 잔액 부족 시 에러 처리      | CMS 출금 시 잔액이 부족하면 안내 메시지가 표시됩니다. |
| feat: 알림톡 발송 기능 추가             | 출금 결과를 알림톡으로 받아볼 수 있습니다.         |
| refactor: 출금 서비스 트랜잭션 분리       | 내부 코드 개선                         |
| chore: Gradle 버전 업데이트          | 내부 코드 개선                         |

#### type 규칙

| type     | 설명              |
|----------|-----------------|
| feat     | 새로운 기능          |
| fix      | 버그 수정           |
| refactor | 리팩토링 (기능 변화 없음) |
| docs     | 문서 수정/추가        |
| test     | 테스트 코드 추가/보강    |
| chore    | 빌드/설정/환경 관련     |

### 5. 검증

- [ ] 메시지 형식: `^[A-Z0-9]+-[0-9]+: (feat|fix|refactor|docs|test|chore): .+`
- [ ] Co-Authored-By 포함되지 않음
- [ ] 커밋 대상에 민감 파일(.env, credentials, secret) 없음

### 6. 사용자 확인

- 커밋 메시지를 사용자에게 보여주고 **반드시 승인을 받는다.**
- 승인 없이 커밋하지 않는다.

### 7. 커밋 실행

- 승인된 메시지로 `git commit` 실행

### 8. 푸시

- 사용자에게 푸시 여부 확인
- 승인 시 `git push` 실행

### 9. PR 관리 (push 후 자동)

- `gh pr view --json number,body`로 현재 브랜치의 PR 확인

#### PR이 없는 경우 → PR 생성

- `git log origin/master..HEAD`로 전체 커밋 분석
- 아래 템플릿을 채워서 `gh pr create` 실행
- **사용자에게 PR 생성 여부를 확인한 후 실행한다.**

#### PR이 있는 경우 → PR body 갱신

1. `git log origin/master..HEAD --format=%B`로 PR 내 모든 커밋 메시지 수집
2. 커밋 메시지를 분석하여 다음 섹션을 갱신한다:
    - **작업 종류**: 커밋 type(feat/fix/refactor/docs/test/chore)으로 체크박스 갱신
    - **변경 사항**: 전체 커밋의 변경 내용을 간략히 요약 (중복 제거)
    - **주요 기능**: feat/fix 커밋 항목 나열 (중복 제거)
    - **주의사항**: DB 마이그레이션, 환경변수, 외부 API 변경 등 감지 시 추가
    - **테스트**: 테스트 코드가 포함된 커밋이 있으면 체크
    - **Deploy Note**: Deploy-Note 라인 추출 → 중복 통합
3. 갱신 원칙:
    - 개발자가 읽는 섹션이므로 커밋 메시지를 그대로 활용해도 무방
    - 중복/유사 항목만 제거하고, 별도 가공하지 않는다
    - **관련 이슈** 섹션은 변경하지 않는다
4. `gh pr edit {number} --body "{updated body}"`로 PR 설명 업데이트

#### PR body 템플릿

```markdown
## 작업 종류

- [ ] 새로운 기능 개발
- [ ] 버그 수정
- [ ] 리팩토링
- [ ] 문서/설정

> 해당하는 항목에 [x] 체크한다. 커밋 type으로 판단한다.

## 관련 이슈

{JIRA-KEY} (JIRA 링크 또는 이슈 링크)

## 변경 사항

커밋 내역을 분석하여 간략하게 작성한다.

## 주요 기능

- [ ] 주요 기능 1
- [ ] 주요 기능 2

> 커밋 내역에서 feat/fix에 해당하는 항목을 나열한다.

## 주의사항

- 특별히 주의해야 할 사항 (DB 마이그레이션, 환경변수 추가, 외부 API 변경 등)

> 해당 없으면 "없음"으로 표기한다.

## 테스트

- [ ] 유닛 테스트
- [ ] 통합 테스트
- [ ] 슬라이스 테스트

> 실제로 추가/수행된 테스트만 체크한다.

## Deploy Note

- {통합된 Deploy-Note 목록}

> 비개발자(영업, 기획, 운영)가 읽는 배포 공지용.
> GitHub Actions가 이 섹션을 추출하여 Slack 배포공지에 전송한다.
```

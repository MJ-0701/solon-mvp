# `solon-mvp`

관리자 페이지 MVP — 매출 조회 / 현금영수증 발행 / 권한 관리 / 대시보드.

## Stack

- **Framework**: `<STACK>` (예: Next.js 15 App Router + TypeScript)
- **DB / ORM**: `<DB>` (예: Postgres + Prisma)
- **UI**: `<UI-LIB>` (예: shadcn/ui + Tailwind CSS)
- **Auth**: `<AUTH>` (예: NextAuth.js + RBAC 3 단계 admin/manager/viewer)
- **배포**: `<DEPLOY>` (예: Vercel)
- **현금영수증 외부 API**: `<RECEIPT-API>` (예: 국세청 홈택스 e-세로)

## 개발 방식

7-step flow (브레인스토밍 → plan → sprint → 구현 → review → commit → 문서화) 로 1 cycle ≈ 5~7 일 주기 운용. 세부 지침은 `CLAUDE.md`.

## 실행

```bash
# 개발 서버
npm install
npm run dev

# 빌드
npm run build

# DB migration
npx prisma migrate dev
```

## Sprint 산출물

Sprint 단위 산출물은 `.sfs-local/sprints/<YYYY-W>-sprint-<N>/` 에 저장됨. git 에는
commit 되지만 `events.jsonl` 은 PII/감사 리스크로 ignore (`.gitignore` 참조).

## License / IP

`<LICENSE-OR-IP-NOTICE>` (예: 회사 내부 자산, 외부 배포 금지).

## Contributors

- 채명정 (`<EMAIL>`)

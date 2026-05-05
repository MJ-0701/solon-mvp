---
id: sfs-policy-management-admin-knowledge-pack-ko
summary: 경영관리, 재무, 경리, 세무, 회계 업무를 위한 solo-founder 운영 지식팩.
language: ko
load_when:
  - management-admin
  - finance
  - accounting
  - bookkeeping
  - tax
  - invoice
  - cashflow
  - payroll
  - compliance
  - 경영관리
  - 재무
  - 경리
  - 세무
  - 회계
status: filled-v1
content_policy: "compact operating guidance; apply only matching ids and keep admin depth proportional to money/compliance risk"
---

# Management/Admin Knowledge Pack Inventory

이 파일은 경영관리 작업을 위한 compact filled guidance pack 이다. sprint,
plan, review, release 가 돈의 흐름, 경리, 세무, 회계, 계약, 급여/외주비,
영수증, 세금계산서/인보이스, 예산, 사업자 compliance 를 건드릴 때 사용한다.
matching id 만 적용한다.

이 pack 은 법률, 세무, 회계 전문가 조언을 대체하지 않는다. 관할별 신고 기준,
세율, 공제 가능성, 세무 해석을 추측하지 않는다. 신고, 급여, 세금 노출,
규제 보고, 중요한 재무제표에 영향을 주는 결정은 세무사/회계사/변호사 확인이
필요한 owner decision 으로 surface 한다.

## Activation Rules

- 재무 기록, 돈의 이동, 보고, compliance 노출, 향후 경영관리 판단의 증빙이
  바뀔 때만 활성화한다.
- 매출 전 실험에는 가벼운 지출 한도, 영수증 습관, 중단 조건이면 충분하다.
  ERP 같은 무거운 프로세스를 강제하지 않는다.
- 첫 매출, 반복 결제, 환불, 급여/외주비, 세무 신고, 해외 거래,
  투자자/대출기관 보고는 경영관리 depth 를 올린다.
- Strategy/PM 과 구분한다. Strategy/PM 은 "사업 결정이 맞는가"를 보고,
  경영관리는 "기록, 통제, 현금 시야, compliance 증빙이 준비됐는가"를 본다.

## ADM-SCALE - Review Depth By Business Stage

- ADM-SCALE-001: 버리는 실험은 지출 한도, 영수증 캡처, 중단 조건이면 충분하다.
- ADM-SCALE-002: 매출 전 제품은 비용 분류, 현금 runway, 구독/벤더 목록이 필요하다.
- ADM-SCALE-003: 첫 유료 고객은 인보이스/영수증 증빙, 입금 상태, 환불 정책, 경리 분류가 필요하다.
- ADM-SCALE-004: 반복 매출은 월마감 습관, 미수/미지급 시야, 매출/환불 처리, churn/cash reconcile 이 필요하다.
- ADM-SCALE-005: 외주, 급여, 커미션은 역할, 계약, 지급 일정, 세무 서류 owner, 승인 증빙이 필요하다.
- ADM-SCALE-006: 세무/법정 신고는 관할, 사업자 형태, 기간, 원천 문서, 신고 owner, 기한, 전문가 checkpoint 가 필요하다.
- ADM-SCALE-007: 해외, 다중 통화, 지원금, 투자자, 대출기관 보고는 통화 처리, 원천징수/VAT/GST/sales-tax flag, 보고 조건, 전문가 검토가 필요하다.

## ADM-PROP - Proposition Inventory

- ADM-PROP-001: 현금 runway 는 현재 현금, 예상 유입, 확정 유출, burn, 다음 결정 시점을 말해야 한다.
- ADM-PROP-002: 경리 기록은 수입, 지출, 영수증, 인보이스, 환불, 이체의 단일 원장을 가져야 한다.
- ADM-PROP-003: 개인 돈과 사업 돈은 계좌, 카드, 영수증, reimbursement note 에서 분리한다.
- ADM-PROP-004: 모든 지출은 날짜, 거래처, 금액, 통화, 분류, 목적, 결제수단, 영수증/원천 증빙을 가져야 한다.
- ADM-PROP-005: 인보이스 번호, 고객명, 발행일, 만기일, 입금 상태, 환불/credit note 는 추적 가능해야 한다.
- ADM-PROP-006: 세무 민감 항목은 최종 세무 처리를 추측하지 말고 flag 로 남긴다.
- ADM-PROP-007: 급여, 외주비, 커미션은 계약, 단가, 기간, 승인, 지급 증빙, 현지 세무 서류 owner 가 필요하다.
- ADM-PROP-008: 구독/벤더 지출은 owner, 갱신일, 해지 경로, 데이터 risk note, 비용 근거가 필요하다.
- ADM-PROP-009: 월마감은 은행/결제대행 잔액과 원장을 reconcile 하고 미해결 차이를 남긴다.
- ADM-PROP-010: 가격, 할인, 환불, credit 정책은 사용자 약속이 되기 전에 재무 영향을 밝혀야 한다.
- ADM-PROP-011: 재무 export/report 는 secret, 은행 정보, 세금 ID, 개인정보를 AI prompt/log 로 흘리지 않아야 한다.
- ADM-PROP-012: 신고, 현금 약속, 계약, 급여, 투자자/대출기관 신뢰에 영향을 주는 경영관리 결정은 audit-friendly evidence 가 필요하다.
- ADM-PROP-013: solo founder 라도 신고, 큰 지급, 급여, 되돌리기 어려운 계정 변경 전에는 maker/checker pause 가 필요하다.
- ADM-PROP-014: 법률/세무/회계 불확실성은 AI 확신으로 닫지 말고 owner 와 due date 가 있는 질문으로 남긴다.

## ADM-FILL - Operating Guidance

### ADM-FILL-CASH - Cash And Runway

- 현재 잔액, 확정 비용, 예상 수입, runway, 다음 결정일을 작게 유지한다.
  목적은 회계 흉내가 아니라 판단 선명도다.
- 일회성 setup 비용과 반복 burn 을 분리한다. 반복 burn 은 단일 도구 구매보다
  생존 곡선을 더 빠르게 바꾼다.
- 유료 제품은 매출, 환불, 입금 지연, 수수료, churn, support cost 를 현금 현실과 연결한다.

### ADM-FILL-BOOKS - Bookkeeping And Evidence

- 영수증과 인보이스는 사건이 발생했을 때 캡처한다. 나중 정리는 더 비싸고 덜 믿을 만하다.
- founder 가 판단하는 방식에 맞는 안정적인 분류를 쓰고, 전문 보고가 필요할 때 회계사 chart of accounts 로 매핑한다.
- 거래 근처에 원천 증빙을 둔다: 영수증, 인보이스, 계약, 은행/결제대행 라인, 승인 note, 환불/credit note.

### ADM-FILL-TAX - Tax And Compliance Boundary

- 세무 문장을 만들기 전 관할, 사업자 형태, 과세 기간, 거래 유형, 상대방 위치, 원천 문서를 확인한다.
- 세율, 신고 기준, 공제 가능성, 고용/외주 구분, 매출 인식 규칙을 추측하지 않는다. 전문가 질문으로 surface 한다.
- 기한과 owner 를 명시한다. 세무/compliance 작업에 owner 와 날짜가 없으면 문서가 멀쩡해 보여도 미래 사고다.

### ADM-FILL-CONTROL - Solo-Founder Controls

- 1인 운영에도 큰 지급, 급여, 신고, 은행/계정 설정, production billing 변경, 계약 서명 전에는 마찰이 필요하다.
- 누가 결정했는지, 어떤 근거를 봤는지, 무엇을 미뤘는지, 언제 다시 볼지 audit trail 을 남긴다.
- AI 를 쓸 때 민감한 재무 데이터는 masking 하거나 빼고, 정확한 값이 필요 없으면 구조, 분류, synthetic example 을 사용한다.

## ADM-REVIEW - Review Questions

- 제품 동작만 말하고 재무/경영관리 영향은 빠뜨리지 않았는가?
- 돈의 이동, 인보이스, 환불, 지출, 구독이 원천 증빙으로 추적되는가?
- 세무/회계/법률 불확실성이 AI 결론이 아니라 질문으로 surface 되었는가?
- 사업 단계에 맞는 depth 인가? 작은 실험에 무거운 프로세스를 강제하지 않았는가?
- 은행 정보, 세금 ID, 개인정보, 민감한 금액이 prompt/log/public artifact 로 새지 않는가?

## ADM-EVIDENCE - Suggested Evidence

- 날짜와 가정이 붙은 cash/runway snapshot.
- 분류와 영수증/원천 링크가 있는 ledger 또는 transaction export.
- 인보이스/환불/입금 상태 목록.
- 월마감 reconcile note: 은행/결제대행 잔액 versus 원장.
- 세무/회계 전문가 질문 목록: owner, due date, source docs 포함.
- 큰 지급, 급여/외주비, 신고, 계약, 가격, 할인, 환불, 투자자/대출기관 보고에 대한 승인/결정 기록.

## ADM-GAP - Deepening Slots

- ADM-GAP-001: solo-founder 월마감 checklist.
- ADM-GAP-002: 영수증, 인보이스, 원천 문서 folder pattern.
- ADM-GAP-003: cash runway 와 burn-rate worksheet.
- ADM-GAP-004: 외주/지급 evidence checklist.
- ADM-GAP-005: jurisdiction/entity/period 별 세무사 질문 template.
- ADM-GAP-006: AI-safe financial data redaction examples.

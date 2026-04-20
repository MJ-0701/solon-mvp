# CHECK - Spring Backend

## 1. 아키텍처/책임 분리
- [ ] Controller가 비즈니스 로직을 과도하게 갖지 않는다.
- [ ] Service가 orchestration 중심으로 유지된다.
- [ ] Domain에 핵심 규칙이 드러난다.
- [ ] Infra 관심사가 Domain을 오염시키지 않는다.

## 2. API/Validation
- [ ] Request validation이 충분하다.
- [ ] Response DTO가 명확하다.
- [ ] 에러 응답 포맷이 표준화돼 있다.
- [ ] 쓰기 API의 멱등성 필요 여부가 검토되었다.

## 3. Transaction/DB
- [ ] transaction boundary가 적절하다.
- [ ] 조회에는 readOnly 검토가 이루어졌다.
- [ ] N+1 가능성을 점검했다.
- [ ] 인덱스/실행계획 검토가 필요 시 수행되었다.
- [ ] long transaction/락 경합 가능성이 검토되었다.

## 4. 외부 연동
- [ ] timeout이 설정되어 있다.
- [ ] retry는 idempotent 호출에만 사용된다.
- [ ] 실패 시 사용자/운영자가 원인을 구분할 수 있다.
- [ ] 보정 또는 재처리 전략이 정의되어 있다.

## 5. 보안
- [ ] 인증/인가가 적절하다.
- [ ] 개인정보 로그 노출이 없다.
- [ ] 관리자 API 보호가 충분하다.
- [ ] 파일 업로드/입력 검증 취약점이 없다.

## 6. Observability
- [ ] 핵심 flow에 success/error/latency metric이 있다.
- [ ] traceId/correlationId가 있다.
- [ ] 장애 탐지 가능한 monitor 설계가 있다.
- [ ] 로그가 원인 분석에 충분하다.

## 7. 테스트
- [ ] 정상 케이스 테스트가 있다.
- [ ] 실패/경계값 테스트가 있다.
- [ ] 회귀 테스트가 필요한 경우 추가되었다.
- [ ] 배포 전 smoke test 가능하다.

## 8. 최종 판정
- [ ] merge 가능
- [ ] 보완 후 merge
- [ ] 재설계 필요

## 9. 리뷰 메모
- 주요 리스크:
- 즉시 수정 필요:
- 추후 개선:

---
card_id: order-service-create
target: src/main/java/com/acme/service/OrderService.java:18-20
confidence: 1
---

## Purpose

주문 생성 스텁 — 현재 고정 문자열만 반환하는 것으로 보인다.

## Inputs/Outputs

- in: 없음
- out: "created" 고정 문자열

## Side effects

없음 (DB 쓰기 코드 없음 — 미완성 추정).

## Tables

- 없음

## Calls

- called-by: OrderController.createOrder

## Evidence

- src/main/java/com/acme/service/OrderService.java:19 — return "created" 고정값

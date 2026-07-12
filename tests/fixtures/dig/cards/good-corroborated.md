---
card_id: order-service-findall
target: src/main/java/com/acme/service/OrderService.java:14-16
confidence: 2
---

## Purpose

주문 목록 전체를 조회해 문자열로 반환한다.

## Inputs/Outputs

- in: 없음
- out: 주문 목록의 toString 문자열

## Side effects

없음 (읽기 전용 쿼리).

## Tables

- orders (read)

## Calls

- calls: OrderRepository.findAll
- called-by: OrderController.listOrders

## Evidence

- src/main/java/com/acme/service/OrderService.java:15 — orderRepository.findAll() 호출
- src/main/java/com/acme/controller/OrderController.java:19 — listOrders 가 findAll 위임

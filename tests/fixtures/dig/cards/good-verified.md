---
card_id: post-service-list
target: src/services/postService.js:5-7
confidence: 2
---

## Purpose

게시글 전체를 작성자 포함으로 조회한다.

## Inputs/Outputs

- in: 없음
- out: Post[] (author eager load)

## Side effects

없음.

## Tables

- Post (read), User (read via include)

## Calls

- calls: prisma.post.findMany
- called-by: routes/posts GET /

## Evidence

- src/services/postService.js:6 — prisma.post.findMany include author

## Runtime evidence

- 로컬 실행 GET /posts 200 응답, author 필드 포함 확인

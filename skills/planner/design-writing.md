---
description: Design Writing Guide - PDCA Design 문서 작성 가이드
model: sonnet
---

# Design Writing Guide Skill

PDCA Design 문서를 작성할 때 따라야 할 구조와 가이드라인.

## Design Document Structure

1. **Overview** - Plan 문서 참조 및 설계 목표
2. **API Design** - 엔드포인트, 요청/응답 스키마
3. **Data Model** - DTO, Entity 정의
4. **Component Design** - 클래스/인터페이스 설계
5. **Sequence Diagram** - 주요 플로우 시퀀스
6. **Error Handling** - 에러 코드 및 처리 전략
7. **Configuration** - 필요한 설정 값
8. **Implementation Order** - 구현 순서 및 의존성

## API Design Template

```yaml
POST /api/images/{endpoint}
Request:
  Content-Type: multipart/form-data
  Parts:
    - image: File (PNG|JPEG|WebP, max 10MB)
    - options: JSON (optional)
Response:
  200:
    body: { requestId, status, resultUrl }
  400:
    body: { error, message, details }
```

## Component Design Template

```
Interface: ImageGenerator
├── analyzeProduct(image: ByteArray): ProductAnalysis
├── generateImage(prompt: String, referenceImage: ByteArray?): GeneratedImage
└── generateCustomImage(prompt: String, image: ByteArray): GeneratedImage

Implementation: OpenAiImageGenerator
├── Uses: WebClient (OpenAI API)
├── Config: OpenAiConfig (apiKey, baseUrl, model)
└── Error: OpenAiApiException handling
```

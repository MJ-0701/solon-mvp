---
description: Implementation Guide - 구현 가이드 및 코딩 패턴
model: opus
---

# Implementation Guide Skill

Design 문서를 기반으로 구현할 때 따라야 할 패턴과 가이드.

## Kotlin + Spring Boot Patterns

### Controller Pattern
```kotlin
@RestController
@RequestMapping("/api/images")
class ImageController(
    private val imageGenerationService: ImageGenerationService
) {
    @PostMapping("/generate")
    suspend fun generateImage(
        @RequestPart("image") image: FilePart,
        @RequestPart("options", required = false) options: String?
    ): ResponseEntity<ImageGenerationResponse> {
        // Implementation
    }
}
```

### Service Pattern
```kotlin
@Service
class ImageGenerationService(
    private val imageGenerator: ImageGenerator
) {
    suspend fun generateImage(image: ByteArray, options: ImageOptions): GenerationResult {
        // Business logic with coroutines
    }
}
```

### WebClient Pattern
```kotlin
webClient.post()
    .uri("/v1/images/generations")
    .bodyValue(request)
    .retrieve()
    .awaitBody<OpenAiResponse>()
```

## Build Verification
```bash
./gradlew build -x test
./gradlew bootRun
```

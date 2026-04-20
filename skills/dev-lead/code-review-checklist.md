---
description: Code Review Checklist - 코드 리뷰 체크리스트
model: opus
---

# Code Review Checklist Skill

구현 코드를 리뷰할 때 사용하는 체크리스트.

## Security
- [ ] API 키가 환경변수로만 참조되는가?
- [ ] 사용자 입력이 적절히 검증되는가?
- [ ] 파일 업로드 크기 제한 (10MB)이 적용되는가?
- [ ] 허용 이미지 포맷 검증 (PNG, JPEG, WebP)

## Architecture
- [ ] ImageGenerator 인터페이스를 통해 구현되는가?
- [ ] 패키지 구조를 따르는가? (config, controller, dto, generator, service)
- [ ] DTO가 적절히 정의되는가?

## Kotlin Best Practices
- [ ] suspend fun이 적절히 사용되는가?
- [ ] Coroutine scope이 올바르게 관리되는가?
- [ ] data class가 적절히 사용되는가?
- [ ] null safety가 잘 처리되는가?

## Spring Boot
- [ ] Bean 주입이 생성자 주입으로 되는가?
- [ ] 예외 처리가 GlobalExceptionHandler로 집중되는가?
- [ ] 설정이 application.yml에서 관리되는가?

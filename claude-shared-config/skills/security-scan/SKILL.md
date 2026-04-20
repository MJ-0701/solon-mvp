---
name: security-scan
description: AgentShield로 Claude Code 설정(.claude/) 보안 스캔 — 시크릿 노출, 과도한 권한, 프롬프트 인젝션 탐지
---

# Security Scan Skill

## 목적
AgentShield를 사용하여 프로젝트의 Claude Code 설정(`.claude/` 디렉토리)에 보안 취약점이 있는지 스캔한다.

## 스캔 대상

| 파일 | 검사 내용 |
|------|----------|
| CLAUDE.md | 하드코딩된 시크릿, 자동 실행 지시, 프롬프트 인젝션 패턴 |
| settings.json | 과도한 허용 목록, 거부 목록 부재, 위험한 우회 플래그 |
| settings.local.json | 누적된 일회성 허용 규칙, rm/docker/chmod 등 위험 명령 |
| hooks/ | 명령어 인젝션, 데이터 유출, 오류 억제 |
| agents/*.md | 제한되지 않은 도구 접근, 프롬프트 인젝션 표면 |

## 수행 절차

1. `ecc-agentshield scan` 실행
2. 결과를 사용자에게 보고 (Grade, 심각도별 건수, 주요 발견)
3. HIGH 이상 항목에 대해 조치 방안 제안

## 주기적 실행

`/loop`과 함께 사용하여 세션 중 주기적으로 스캔할 수 있다:

```
/loop 5m /security-scan
```

간격은 필요에 따라 조절한다 (예: `/loop 10m`, `/loop 30m`).

## 심각도 등급

| Grade | 점수 | 의미 |
|-------|------|------|
| A | 90-100 | 안전 |
| B | 75-89 | 경미한 이슈 |
| C | 60-74 | 주의 필요 |
| D | 40-59 | 상당한 위험 |
| F | 0-39 | 치명적 취약점 |

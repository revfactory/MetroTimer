---
name: build-timer
description: "메트로 테마 macOS 타이머 앱 빌드 오케스트레이터. 타이머 빌드, 타이머 만들기, 타이머 앱."
---

# Build Timer — 메트로 타이머 앱 빌드 오케스트레이터

macOS용 메트로 테마 타이머 앱을 빌드하고 검증하는 오케스트레이터.

## 실행 모드
서브 에이전트 모드 (Producer-Reviewer 패턴)

## 데이터 흐름

```
[오케스트레이터]
    ├── Phase 1: swift-builder (앱 생성)
    ├── Phase 2: app-tester (빌드 검증)
    ├── Phase 3: 수정 필요 시 swift-builder 재호출
    └── Phase 4: 최종 결과 보고
```

## Phase 1: 앱 생성

swift-builder 에이전트를 호출하여 타이머 앱을 생성한다.

```
Agent(
  subagent_type: "general-purpose",
  prompt: "swift-builder 에이전트 역할로 작업하세요. /Users/robin/Downloads/timer-mac/.claude/agents/swift-builder.md 를 읽고 해당 역할에 따라 macOS 메트로 테마 타이머 앱을 빌드하세요.

  요구사항:
  - Swift Package Manager 프로젝트 구조
  - 메트로 디자인 테마 (다크 배경, 볼드 타이포, 플랫 UI)
  - 시작/중지 토글 버튼
  - 경과 시간 표시 (MM:SS)
  - 항상 최상단 (floating window)
  - 컴팩트 윈도우, 타이틀바 숨김, 드래그 가능

  프로젝트 경로: /Users/robin/Downloads/timer-mac/
  ",
  mode: "auto"
)
```

## Phase 2: 빌드 검증

app-tester 에이전트를 호출하여 빌드 및 품질을 검증한다.

```
Agent(
  subagent_type: "general-purpose",
  prompt: "app-tester 에이전트 역할로 작업하세요. /Users/robin/Downloads/timer-mac/.claude/agents/app-tester.md 를 읽고 해당 체크리스트에 따라 /Users/robin/Downloads/timer-mac/ 의 타이머 앱을 검증하세요.

  1. 코드를 읽고 리뷰
  2. swift build 실행
  3. 체크리스트 항목별 검증 결과 보고
  4. 문제 발견 시 구체적 수정 방안 제시
  ",
  mode: "auto"
)
```

## Phase 3: 수정 (조건부)

Phase 2에서 CRITICAL 이슈가 발견된 경우에만 실행.

```
Agent(
  subagent_type: "general-purpose",
  prompt: "swift-builder 역할로 다음 이슈를 수정하세요: {테스터 피드백}",
  mode: "auto"
)
```

Phase 3 실행 후 Phase 2를 한 번 더 실행하여 수정 확인. 최대 2회 반복.

## Phase 4: 결과 보고

사용자에게 최종 결과를 보고한다:
- 빌드 성공 여부
- 실행 방법 (`swift build && .build/debug/MetroTimer` 또는 Xcode)
- 주요 기능 목록
- 스크린샷 또는 UI 설명

## 에러 핸들링

| 에러 유형 | 전략 |
|----------|------|
| swift-builder 실패 | 에러 로그 분석 후 프롬프트 보강하여 1회 재시도 |
| 빌드 실패 | app-tester가 에러 분석, swift-builder에 수정 요청 |
| 2회 반복 후에도 실패 | 현재까지의 코드 + 잔여 이슈 목록을 사용자에게 보고 |

## 테스트 시나리오

### 정상 흐름
1. swift-builder가 프로젝트 생성 → 성공
2. app-tester가 `swift build` 실행 → 성공
3. 체크리스트 전항목 통과
4. 사용자에게 완성 보고

### 에러 흐름
1. swift-builder가 프로젝트 생성 → 성공
2. app-tester가 `swift build` 실행 → 컴파일 에러
3. 에러 내용을 swift-builder에 전달
4. swift-builder가 수정 → app-tester 재검증 → 성공
5. 사용자에게 완성 보고 (1회 수정 이력 포함)

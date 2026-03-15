# MetroTimer

macOS용 플로팅 타이머 앱. SwiftUI + AppKit 기반.

## 기술 스택

- **언어**: Swift 5.9
- **UI**: SwiftUI + AppKit (NSWindow)
- **빌드**: Swift Package Manager + Xcode 26
- **타겟**: macOS 13.0+
- **CI/CD**: GitHub Actions (자동 버전 태깅 + Release 빌드)

## 빌드

```bash
swift build          # Debug 빌드
swift build -c release  # Release 빌드
swift run            # 빌드 + 실행
```

## 아키텍처

단일 파일 구조 (`Sources/MetroTimer/MetroTimerApp.swift`):

- `MetroTimerApp` — @main 앱 엔트리, WindowGroup
- `AppDelegate` — NSApplicationDelegate, 앱 활성화
- `WindowAccessor` — NSViewRepresentable, 윈도우 설정 (floating, borderless, drag)
- `TimerViewModel` — @MainActor ObservableObject, Date 기반 타이머 로직
- `ContentView` — 메인 UI (타이머 + 버튼 + 닫기)

## 주요 구현 사항

- **Always On Top**: `window.level = .floating` + `styleMask = .borderless`
- **정밀 타이머**: `Date().timeIntervalSince(startDate)` 기반, 10ms 간격 갱신
- **반투명**: `window.backgroundColor = .clear` + SwiftUI Color opacity(0.85)
- **1분 펄스**: `minutePulse` 상태로 배경 플래시 + scaleEffect 스프링 바운스

## 커밋 컨벤션

- 커밋 메시지는 한글로 작성
- 시맨틱 버전이 필요한 경우: `fix:`, `feat:`, `BREAKING CHANGE:` 접두사 사용
- GitHub Actions가 커밋 메시지 기반으로 자동 버전 태깅

## 파일 설명

| 파일 | 용도 |
|------|------|
| `Package.swift` | SPM 패키지 정의 |
| `project.yml` | xcodegen 프로젝트 설정 |
| `Info.plist` | 앱 메타데이터 |
| `MetroTimer.entitlements` | App Sandbox |
| `.github/workflows/release.yml` | CI/CD 파이프라인 |
| `docs/index.html` | GitHub Pages 랜딩 페이지 |
| `APPSTORE_GUIDE.md` | App Store 제출 가이드 |

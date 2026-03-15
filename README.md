# MetroTimer

![MetroTimer](MetroTimer.png)

macOS용 초간단 플로팅 타이머. 메트로 디자인 테마가 적용된 항상 최상단 타이머.

[![Build & Release](https://github.com/revfactory/MetroTimer/actions/workflows/release.yml/badge.svg)](https://github.com/revfactory/MetroTimer/actions/workflows/release.yml)
[![Latest Release](https://img.shields.io/github/v/release/revfactory/MetroTimer)](https://github.com/revfactory/MetroTimer/releases/latest)

## Download

[Latest Release](https://github.com/revfactory/MetroTimer/releases/latest) 에서 `MetroTimer-*.zip`을 다운로드하세요.

## Features

- **Always On Top** — 모든 데스크탑 스페이스에서 항상 최상단 표시
- **센티초 정밀도** — HH:MM:SS.cc (1/100초) 포맷, 10ms 간격 갱신
- **Metro Design** — 다크 배경, 볼드 모노스페이스 타이포, 플랫 UI
- **Pulse Animation** — 1분 경과 시 배경 플래시 + 스프링 바운스
- **Compact** — 320x70pt 가로형, 반투명 배경, 둥근 모서리
- **Draggable** — 전체 윈도우 드래그 이동
- **Accessible** — VoiceOver 지원

## Requirements

- macOS 13.0+
- Xcode 26+ (빌드 시)

## Build & Run

```bash
# SPM으로 빌드 및 실행
swift run

# Release 빌드
swift build -c release
```

## Xcode

```bash
# Xcode 프로젝트 열기
open MetroTimer.xcodeproj
```

## CI/CD

main 브랜치에 push하면 GitHub Actions가 자동으로:

1. 시맨틱 버전 태그 생성 (커밋 메시지 기반)
2. `swift build -c release`로 빌드
3. `.app` 번들 패키징
4. GitHub Release에 zip 업로드

### 버전 규칙

| 커밋 메시지 | 버전 변경 |
|------------|----------|
| `fix:` / 일반 커밋 | patch (v1.0.0 → v1.0.1) |
| `feat:` | minor (v1.0.0 → v1.1.0) |
| `BREAKING CHANGE:` | major (v1.0.0 → v2.0.0) |

## Project Structure

```
MetroTimer/
├── Package.swift
├── MetroTimer.xcodeproj/
├── Sources/MetroTimer/
│   ├── MetroTimerApp.swift
│   └── Assets.xcassets/
├── Info.plist
├── MetroTimer.entitlements
├── .github/workflows/release.yml
└── docs/index.html
```

## License

[MIT](LICENSE)

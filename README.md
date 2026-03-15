# MetroTimer

![MetroTimer](MetroTimer.png)

macOS용 초간단 플로팅 타이머. 메트로 디자인 테마가 적용된 항상 최상단 타이머.

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

# .app 번들은 build/ 디렉토리에 생성
open build/MetroTimer.app
```

## Xcode

```bash
# Xcode 프로젝트 열기
open MetroTimer.xcodeproj
```

## Project Structure

```
timer-mac/
├── Package.swift
├── MetroTimer.xcodeproj/
├── Sources/MetroTimer/
│   ├── MetroTimerApp.swift
│   └── Assets.xcassets/
├── Info.plist
├── MetroTimer.entitlements
├── build/MetroTimer.app
└── docs/index.html
```

## License

MIT License

Copyright (c) 2026

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

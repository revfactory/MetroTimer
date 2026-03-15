# Metro Timer — App Store 제출 가이드 (Xcode 26.3 기준)

> **필수 요건**: 2026년 4월 28일부터 App Store Connect에 업로드하는 모든 앱은
> Xcode 26 이상 + macOS 26 SDK로 빌드해야 합니다.
> 현재 최신 안정 버전: **Xcode 26.3** (2026.02.26 릴리즈)

---

## 1. 사전 준비

### 1-1. Apple Developer Program 등록
1. https://developer.apple.com/programs/ 접속
2. Apple ID로 로그인 → 등록 ($99/년)
3. 등록 완료 후 App Store Connect 접근 가능

### 1-2. Xcode 26.3 확인
```bash
xcodebuild -version
# Xcode 26.3
# Build version ...
```
구버전이면 App Store 또는 developer.apple.com/xcode 에서 업데이트.

---

## 2. Xcode에서 프로젝트 열기

SPM 기반 프로젝트이므로 Package.swift를 직접 열면 됩니다.

```bash
open /Users/robin/Downloads/timer-mac/Package.swift
```

Xcode 26.3이 패키지를 resolve하면 `MetroTimer` scheme이 자동 생성됩니다.

### Scheme 확인
- 상단 툴바에서 **MetroTimer** scheme 선택
- Destination: **My Mac** 선택

---

## 3. 프로젝트 설정

### 3-1. Signing & Capabilities

1. 좌측 Navigator에서 **Package.swift** 최상위 항목 선택
2. **MetroTimer** 타겟 선택 → **Signing & Capabilities** 탭

| 설정 | 값 |
|------|-----|
| Automatically manage signing | 체크 |
| Team | 본인 개발자 팀 선택 |
| Bundle Identifier | `com.yourname.metrotimer` (고유값으로 변경) |

3. **+ Capability** 클릭 → **App Sandbox** 추가
4. **+ Capability** 클릭 → **Hardened Runtime** 추가 (Xcode 26에서 필수)

> `MetroTimer.entitlements` 파일이 이미 프로젝트에 포함되어 있습니다.

### 3-2. Build Settings

| 설정 | 값 |
|------|-----|
| Info.plist File | `$(SRCROOT)/Info.plist` |
| Code Signing Entitlements | `$(SRCROOT)/MetroTimer.entitlements` |
| ASSETCATALOG_COMPILER_APPICON_NAME | `AppIcon` |

### 3-3. Liquid Glass 관련

Xcode 26 SDK로 빌드하면 기본 UI 컴포넌트에 **Liquid Glass** 효과가 자동 적용됩니다.
이 앱은 커스텀 borderless 윈도우를 사용하므로 Liquid Glass가 자동 적용되지 않습니다.
필요시 `.glassEffect()` modifier로 수동 적용할 수 있습니다:

```swift
// 예시: 버튼에 Liquid Glass 적용
.glassEffect(.regular.interactive())
```

> 현재 메트로 테마와 Liquid Glass는 디자인 철학이 다르므로, 적용하지 않아도 심사에 영향 없습니다.

---

## 4. 앱 아이콘 준비

`AppIcon.appiconset/Contents.json`이 이미 생성되어 있습니다.
1024x1024 원본 PNG 하나를 만들고 아래 명령어로 리사이즈:

```bash
cd /Users/robin/Downloads/timer-mac/AppIcon.appiconset

# 원본 icon_1024.png를 준비한 후:
for size in 16 32 64 128 256 512; do
  sips -z $size $size icon_1024.png --out icon_${size}x${size}.png
done
cp icon_1024.png icon_512x512@2x.png
```

### 필요한 사이즈

| 파일명 | 픽셀 크기 |
|--------|-----------|
| icon_16x16.png | 16x16 |
| icon_16x16@2x.png | 32x32 |
| icon_32x32.png | 32x32 |
| icon_32x32@2x.png | 64x64 |
| icon_128x128.png | 128x128 |
| icon_128x128@2x.png | 256x256 |
| icon_256x256.png | 256x256 |
| icon_256x256@2x.png | 512x512 |
| icon_512x512.png | 512x512 |
| icon_512x512@2x.png | 1024x1024 |

---

## 5. Archive & Upload (Xcode 26.3)

### 5-1. Archive 생성

1. **Product** → **Archive** (또는 `Cmd + Shift + B` 후 `Product > Archive`)
2. Destination이 **My Mac**인지 확인 (시뮬레이터가 아닌 실제 Mac)
3. 빌드 완료 후 **Organizer** 창이 자동으로 열림

> Archive가 안 되는 경우: Scheme > Edit Scheme > Archive 설정에서 Build Configuration이 **Release**인지 확인

### 5-2. App Store에 업로드

1. Organizer에서 해당 Archive 선택
2. **Distribute** 버튼 클릭
3. **TestFlight & App Store** 선택
4. **Upload** 선택

업로드 옵션:
| 옵션 | 설정 |
|------|------|
| Strip Swift symbols | 체크 |
| Upload symbols | 체크 |
| Manage Version and Build Number | 체크 |

5. **Upload** 클릭 → App Store Connect로 전송

### 5-3. 업로드 후 처리

- App Store Connect에서 빌드 처리에 약 5~30분 소요
- 처리 완료 후 이메일 알림 수신
- TestFlight에서 먼저 테스트 가능

---

## 6. App Store Connect 설정

https://appstoreconnect.apple.com 에서 새 앱 생성:

### 6-1. 기본 정보

| 항목 | 값 |
|------|-----|
| 앱 이름 | Metro Timer |
| 부제목 | 미니멀 플로팅 타이머 (30자 이내) |
| 번들 ID | Xcode와 동일한 값 |
| SKU | MetroTimer2026 |
| 기본 언어 | 한국어 |
| 카테고리 | 유틸리티 (Utilities) |
| 콘텐츠 등급 | 4+ |

> Xcode 26부터 연령 등급 시스템이 세분화되었습니다. App Store Connect에서 새로운 등급 질문에 응답하세요.

### 6-2. 앱 설명

| 항목 | 내용 |
|------|------|
| 프로모션 텍스트 (170자) | 데스크탑 위에 항상 떠있는 미니멀 타이머. 센티초 단위 정밀 측정, 메트로 디자인. |
| 설명 (4000자) | 앱 기능, 사용법, 특징 상세 기술 |
| 키워드 (100자) | 타이머,스톱워치,시간,생산성,플로팅,미니멀,유틸리티,작업,집중 |

### 6-3. 개인정보 보호

| 항목 | 설정 |
|------|------|
| 데이터 수집 | "수집하지 않음" |
| 개인정보처리방침 URL | 필수 (GitHub Pages 등으로 간단히 생성) |

### 6-4. 제출 (Draft Submissions)

Xcode 26 / App Store Connect에서는 **여러 개의 드래프트 제출을 동시에 생성**할 수 있습니다:
1. App Store Connect → 앱 선택 → **App Store** 탭
2. **새 제출 생성** (여러 드래프트 가능)
3. 빌드 선택, 스크린샷 업로드, 설명 입력
4. **심사 제출** 클릭

---

## 7. 스크린샷 규격

Mac App Store 필수 스크린샷:

| 디스플레이 | 해상도 | 필수 |
|-----------|--------|------|
| Mac (일반) | 1280x800 이상 | 필수 (최소 1장) |
| Mac (Retina) | 2560x1600 이상 | 권장 |
| Mac (16인치) | 1440x900 이상 | 권장 |

- 최소 1장, 최대 10장
- PNG 또는 JPEG
- `Cmd + Shift + 4`로 영역 캡처

---

## 8. 심사 주의사항

### 8-1. Always-on-Top (플로팅 윈도우)

이 앱은 `window.level = .floating`과 `styleMask = .borderless`를 사용합니다.
**심사 노트에 반드시 기재**:

> "Metro Timer는 사용자가 다른 작업 중에도 경과 시간을 확인할 수 있도록 항상 최상위에 표시되는 타이머입니다.
> 컴팩트한 UI를 위해 커스텀 borderless 윈도우를 사용하며, 이는 앱의 핵심 사용 시나리오입니다.
> 사용자는 닫기 버튼(X) 또는 Cmd+Q로 언제든 앱을 종료할 수 있습니다."

### 8-2. App Sandbox

- Sandbox 필수 활성화 (`MetroTimer.entitlements` 포함)
- 이 앱은 네트워크, 파일, 카메라 등 추가 권한 불필요

### 8-3. 최소 기능 요구사항

Apple은 기능이 너무 단순한 앱을 리젝할 수 있습니다. 심사 노트에 강조:
- 센티초(1/100초) 단위 정밀 타이머
- 분 단위 시각적 펄스 애니메이션 (배경 플래시 + 스케일 바운스)
- 모든 데스크탑 스페이스에서 표시
- 전체 윈도우 드래그 이동
- VoiceOver 접근성 완전 지원
- 메트로 디자인 시스템 적용

### 8-4. ITSAppUsesNonExemptEncryption

`Info.plist`에 `ITSAppUsesNonExemptEncryption: false`가 설정되어 있어
업로드 시 암호화 관련 질문이 생략됩니다.

### 8-5. Liquid Glass 미적용 관련

메트로 디자인 테마를 의도적으로 사용하므로 Liquid Glass를 적용하지 않습니다.
이는 디자인 선택이며 심사 리젝 사유가 아닙니다.

---

## 9. 제출 전 최종 체크리스트

- [ ] Xcode 26.3으로 빌드 성공
- [ ] Bundle Identifier 고유값으로 변경
- [ ] Code Signing 정상 (Team 선택됨)
- [ ] App Sandbox 활성화
- [ ] Hardened Runtime 활성화
- [ ] 앱 아이콘 10개 사이즈 준비 완료
- [ ] Info.plist 버전 정보 올바름
- [ ] 접근성 레이블 적용 (VoiceOver 테스트)
- [ ] Archive → Upload 성공
- [ ] App Store Connect 앱 정보 입력 완료
- [ ] 스크린샷 최소 1장 업로드
- [ ] 개인정보처리방침 URL 준비
- [ ] 심사 노트에 플로팅 윈도우 설명 작성
- [ ] 연령 등급 질문 응답 완료

---

## 참고 링크

- Apple Developer Program: https://developer.apple.com/programs/
- App Store Connect: https://appstoreconnect.apple.com
- App Review Guidelines: https://developer.apple.com/app-store/review/guidelines/
- Liquid Glass 가이드: https://developer.apple.com/documentation/SwiftUI/Applying-Liquid-Glass-to-custom-views

---
name: appstore-images
description: "App Store 심사용 스크린샷 이미지 생성 오케스트레이터. 앱 심사 이미지, 스크린샷 생성, App Store 스크린샷."
---

# App Store Images — 심사용 이미지 생성 오케스트레이터

MetroTimer 앱의 App Store 심사용 스크린샷을 에이전트 팀으로 자동 생성하는 오케스트레이터.

## 실행 모드: 에이전트 팀 (파이프라인 + 생성-검증)

에이전트 간 직접 통신으로 실시간 조율. screenshot-capturer → image-designer → app-tester 파이프라인에 검증 피드백 루프를 추가.

## 팀 구성

| 팀원 이름 | subagent_type | 역할 | 출력 |
|----------|--------------|------|------|
| capturer | screenshot-capturer | 앱 빌드 + 스크린샷 캡처 | `_workspace/01_screenshots/` |
| designer | image-designer | 스크린샷 → App Store 규격 이미지 | `_workspace/02_appstore_images/` |
| tester | app-tester | 최종 이미지 규격 검증 | 검증 보고서 |

## 워크플로우

### Phase 1: 준비

1. 프로젝트 경로 확인: `/Users/robin/IdeaProjects/MetroTimer`
2. `_workspace/` 디렉토리 생성
3. 기존 스크린샷 확인 (`MetroTimer.png` 또는 `main.png` 존재 여부)
4. APPSTORE_GUIDE.md에서 스크린샷 규격 재확인

```bash
mkdir -p _workspace/00_input _workspace/01_screenshots _workspace/02_appstore_images _workspace/03_final
```

5. 기존 스크린샷이 있으면 `_workspace/00_input/`에 복사:
```bash
cp MetroTimer.png _workspace/00_input/ 2>/dev/null || true
cp main.png _workspace/00_input/ 2>/dev/null || true
```

### Phase 2: 팀 생성 및 태스크 할당

1. **TeamCreate**로 팀 생성:
```
TeamCreate(team_name: "appstore-images", description: "App Store 심사용 이미지 생성 팀")
```

2. **TaskCreate**로 작업 목록 생성:

| ID | 작업 | 담당 | 의존 |
|----|------|------|------|
| 1 | 앱 빌드 및 스크린샷 캡처 (idle, running, elapsed 3개 상태) | capturer | 없음 |
| 2 | 캡처된 스크린샷으로 App Store 프로모션 이미지 생성 (Retina 3장 + Standard 3장) | designer | 1 |
| 3 | 생성된 이미지 규격 검증 (해상도, 비율, 포맷, 파일 무결성) | tester | 2 |
| 4 | (조건부) CRITICAL 이슈 수정 후 재생성 | designer | 3 |

### Phase 3: 팀원 스폰

3명의 팀원을 스폰한다. capturer는 즉시 시작, designer와 tester는 대기.

**capturer 스폰:**
```
Agent(
  subagent_type: "screenshot-capturer",
  name: "capturer",
  team_name: "appstore-images",
  prompt: "당신은 appstore-images 팀의 capturer입니다.

  팀 설정 파일을 읽어 팀원을 확인하세요: ~/.claude/teams/appstore-images/config.json
  작업 목록을 확인하세요: TaskList

  프로젝트 경로: /Users/robin/IdeaProjects/MetroTimer
  출력 경로: /Users/robin/IdeaProjects/MetroTimer/_workspace/01_screenshots/

  에이전트 정의: /Users/robin/IdeaProjects/MetroTimer/.claude/agents/screenshot-capturer.md 를 읽고 따르세요.

  캡처할 상태:
  1. screenshot_idle.png — 타이머 정지 상태 (00:00:00.00)
  2. screenshot_running.png — 타이머 실행 중 (몇 초 경과 후)
  3. screenshot_elapsed.png — 타이머 오래 실행 (가능하면 1분+ 경과)

  절차:
  1. swift build -c release
  2. .build/release/MetroTimer 실행
  3. screencapture로 각 상태 캡처
  4. 앱 종료
  5. 작업 완료 후 TaskUpdate로 태스크 완료 처리
  6. designer에게 SendMessage로 캡처 결과 직접 전달 (파일 경로, 해상도, 상태 설명)

  screencapture 권한이 없거나 실패하면:
  - 기존 /Users/robin/IdeaProjects/MetroTimer/main.png 또는 MetroTimer.png를 대체 이미지로 사용
  - 대체 이미지 사용 사실을 designer에게 반드시 알릴 것
  ",
  mode: "auto",
  run_in_background: true
)
```

**designer 스폰:**
```
Agent(
  subagent_type: "image-designer",
  name: "designer",
  team_name: "appstore-images",
  prompt: "당신은 appstore-images 팀의 designer입니다.

  팀 설정 파일을 읽어 팀원을 확인하세요: ~/.claude/teams/appstore-images/config.json
  작업 목록을 확인하세요: TaskList

  에이전트 정의: /Users/robin/IdeaProjects/MetroTimer/.claude/agents/image-designer.md 를 읽고 따르세요.

  capturer로부터 스크린샷 캡처 완료 메시지를 받으면 작업을 시작하세요.
  메시지를 받기 전에는 대기하세요.

  입력 경로: /Users/robin/IdeaProjects/MetroTimer/_workspace/01_screenshots/
  출력 경로: /Users/robin/IdeaProjects/MetroTimer/_workspace/02_appstore_images/

  생성할 이미지 (최소 3장):

  1. appstore_retina_01.png (2560x1600) — 메인 스크린샷
     - 메트로 다크 배경 (#1a1a2e)
     - 중앙에 앱 스크린샷 크게 배치
     - 상단에 '미니멀 플로팅 타이머' 텍스트

  2. appstore_retina_02.png (2560x1600) — 기능 소개 1
     - 타이머 실행 중 스크린샷
     - '센티초 단위 정밀 타이머' 텍스트
     - 메트로 강조색 (#e94560) 액센트

  3. appstore_retina_03.png (2560x1600) — 기능 소개 2
     - 'Always On Top — 항상 눈앞에' 텍스트
     - 데스크탑 위에 떠있는 모습 강조

  각 Retina 이미지의 Standard(1280x800) 버전도 함께 생성.

  사용 도구: Python Pillow 또는 sips
  색상: 메트로 팔레트 (#1a1a2e, #e94560, #eeeeF4, #66667a)

  작업 완료 후:
  1. TaskUpdate로 태스크 완료 처리
  2. tester에게 SendMessage로 검증 요청 (파일 경로, 의도된 해상도 목록)

  tester로부터 CRITICAL 이슈 피드백을 받으면:
  1. 해당 이미지만 수정 재생성
  2. tester에게 재검증 요청
  ",
  mode: "auto",
  run_in_background: true
)
```

**tester 스폰:**
```
Agent(
  subagent_type: "app-tester",
  name: "tester",
  team_name: "appstore-images",
  prompt: "당신은 appstore-images 팀의 tester입니다.

  팀 설정 파일을 읽어 팀원을 확인하세요: ~/.claude/teams/appstore-images/config.json
  작업 목록을 확인하세요: TaskList

  에이전트 정의: /Users/robin/IdeaProjects/MetroTimer/.claude/agents/app-tester.md 를 읽고 따르세요.

  designer로부터 이미지 검증 요청 메시지를 받으면 작업을 시작하세요.
  메시지를 받기 전에는 대기하세요.

  검증 대상 경로: /Users/robin/IdeaProjects/MetroTimer/_workspace/02_appstore_images/

  검증 항목:
  1. 파일 존재 여부 (최소 Retina 3장 + Standard 3장 = 6장)
  2. 각 이미지 해상도 확인: sips -g pixelWidth -g pixelHeight
     - Retina: 2560x1600
     - Standard: 1280x800
  3. 비율 16:10 준수
  4. PNG 포맷 무결성
  5. 파일 크기 적정 (100KB 이상)

  검증 후:
  1. TaskUpdate로 태스크 완료 처리
  2. 팀 리더에게 SendMessage로 최종 결과 보고
     - PASS: 모든 항목 통과 → 최종 이미지 경로 안내
     - FAIL: CRITICAL 이슈 → designer에게 직접 수정 요청 후 재검증
     - PARTIAL: WARNING만 → 제출 가능하다고 보고
  ",
  mode: "auto",
  run_in_background: true
)
```

### Phase 4: 모니터링 및 결과 수집

오케스트레이터(팀 리더)는 팀원들의 메시지를 수신하며 진행 상황을 모니터링한다.

1. capturer → designer → tester 파이프라인이 자동으로 진행됨
2. tester의 최종 보고를 수신하면 Phase 5로 진행
3. 10분 이상 응답 없으면 TaskList로 상태 확인

### Phase 5: 최종 정리 및 보고

1. `_workspace/02_appstore_images/`의 산출물을 `_workspace/03_final/`에 복사:
```bash
cp _workspace/02_appstore_images/appstore_*.png _workspace/03_final/
```

2. 팀원 종료:
```
SendMessage(to: "capturer", message: {type: "shutdown_request"})
SendMessage(to: "designer", message: {type: "shutdown_request"})
SendMessage(to: "tester", message: {type: "shutdown_request"})
```

3. 사용자에게 보고:
   - 생성된 이미지 목록 및 해상도
   - App Store Connect 업로드 방법
   - 누락된 이미지가 있으면 명시

## 데이터 흐름

```
[오케스트레이터/팀 리더]
    ├── TeamCreate("appstore-images")
    ├── TaskCreate(4개 작업)
    │
    ├── capturer (스크린샷 캡처)
    │   ├── swift build → 앱 실행 → screencapture
    │   ├── → _workspace/01_screenshots/ (파일 기반)
    │   └── → designer에게 SendMessage (메시지 기반)
    │
    ├── designer (이미지 생성)
    │   ├── capturer 메시지 수신 → 작업 시작
    │   ├── Pillow/sips로 프로모션 이미지 생성
    │   ├── → _workspace/02_appstore_images/ (파일 기반)
    │   └── → tester에게 SendMessage (메시지 기반)
    │
    ├── tester (규격 검증)
    │   ├── designer 메시지 수신 → 검증 시작
    │   ├── sips로 해상도/포맷 확인
    │   ├── CRITICAL → designer에게 수정 요청 (피드백 루프)
    │   └── PASS/PARTIAL → 팀 리더에게 최종 보고
    │
    └── 최종 정리 → _workspace/03_final/
```

## 데이터 전달 프로토콜

| 전략 | 용도 |
|------|------|
| **메시지 기반** (SendMessage) | 작업 시작 신호, 검증 피드백, 수정 요청 |
| **태스크 기반** (TaskCreate/Update) | 진행 상황 추적, 의존 관계 관리 |
| **파일 기반** (_workspace/) | 스크린샷, 프로모션 이미지, 최종 산출물 |

## 에러 핸들링

| 상황 | 전략 |
|------|------|
| 빌드 실패 | capturer가 에러 보고 → 기존 MetroTimer.png/main.png 사용 |
| screencapture 권한 없음 | 기존 스크린샷 사용 + 사용자에게 권한 안내 |
| capturer 실패 | 기존 스크린샷으로 대체하여 designer에게 직접 지시 |
| designer 실패 | 1회 재시도. 재실패 시 raw 스크린샷을 sips로 리사이즈만 수행 |
| tester CRITICAL | designer에게 직접 수정 요청 → 재검증 (최대 1회) |
| Pillow 미설치 | `pip install Pillow` 자동 실행 |
| 팀원 중지 | 해당 작업을 오케스트레이터가 직접 수행 |

## 테스트 시나리오

### 정상 흐름
1. 팀 생성 → 3명 스폰
2. capturer: swift build 성공 → 3개 상태 캡처 → designer에게 직접 전달
3. designer: 6개 프로모션 이미지 생성 → tester에게 검증 요청
4. tester: 전항목 PASS → 팀 리더에게 보고
5. 오케스트레이터: `_workspace/03_final/`에 복사 → 팀 종료 → 사용자 보고

### 에러 흐름 (screencapture 권한 없음 + 이미지 규격 미달)
1. capturer: screencapture 실패 → 기존 main.png로 대체 → designer에게 "대체 이미지 1장" 전달
2. designer: 1장으로 3개 프로모션 이미지 생성 → tester에게 검증 요청
3. tester: appstore_retina_02.png 해상도 미달 (CRITICAL) → designer에게 수정 요청
4. designer: 해당 이미지 재생성 → tester에게 재검증 요청
5. tester: PASS → 팀 리더에게 보고
6. 오케스트레이터: 최종 정리 → "screencapture 권한 필요" 안내 포함 보고

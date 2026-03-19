# 기술 사양 문서

## 1. 엔진 & 환경

### Unity 설정
| 항목 | 값 |
|------|-----|
| Unity 버전 | 2022.3 LTS |
| 렌더 파이프라인 | 2D URP (Universal Render Pipeline) |
| 스크립팅 백엔드 | IL2CPP (빌드) / Mono (에디터) |
| API 호환성 | .NET Standard 2.1 |
| 컬러 스페이스 | Linear |

### 타겟 사양
| 플랫폼 | 최소 사양 | 권장 사양 |
|--------|---------|----------|
| PC | i3 / 4GB RAM / Intel HD 4000 | i5 / 8GB RAM / GTX 1050 |
| iOS | iPhone 8 (A11) / iOS 14+ | iPhone 12+ |
| Android | Snapdragon 660 / 3GB RAM / Android 8+ | Snapdragon 870+ |

### 빌드 크기 목표
| 플랫폼 | 목표 크기 |
|--------|----------|
| PC | < 500MB |
| Mobile | < 200MB (초기 다운로드) |

---

## 2. 프로젝트 아키텍처

### 레이어 구조
```
┌─────────────────────────────────┐
│           UI Layer              │  Unity MonoBehaviour
│  GameUIManager, CardUI, etc.    │  (UGUI / TextMeshPro)
├─────────────────────────────────┤
│         Bridge Layer            │  GameBootstrap
│  Unity ↔ Pure C# 연결           │  (MonoBehaviour → 순수 C#)
├─────────────────────────────────┤
│        Game Logic Layer         │  순수 C# (Unity 의존 없음)
│  GameManager, RoundManager      │  테스트 가능
│  ScoringEngine, MatchingEngine  │
├─────────────────────────────────┤
│         Data Layer              │  ScriptableObject + 코드 DB
│  HwaTuCardDatabase              │  (에디터: SO, 런타임: 코드)
│  TalismanDatabase, BossDatabase │
└─────────────────────────────────┘
```

### 의존성 규칙
```
UI → Bridge → Logic → Data
  (단방향, 역방향 의존 금지)

Logic 레이어는 UnityEngine 참조 금지 (테스트 가능성)
UI 레이어만 MonoBehaviour 사용
Data 레이어는 ScriptableObject + 순수 C# 이중 구조
```

---

## 3. 핵심 시스템 사양

### 3.1 카드 시스템
```
총 카드 수: 48장 (12월 × 4장)
카드 속성: Id, Name, Month(1~12), Type(4종), Ribbon(4종), Points, Special

메모리: CardInstance는 참조 타입 (힙 할당)
        48개 인스턴스 + 풀링 필요 없음 (소량)

셔플: Fisher-Yates 알고리즘
시드: System.Random (결정론적 시드 지원 → 일일 도전용)
```

### 3.2 매칭 엔진
```
검색: O(n) 선형 탐색 (바닥패 최대 12장 → 성능 문제 없음)
매칭 타입: 4가지 (NoMatch, Single, Double, Triple)
실행: 카드 이동 (List 조작) → O(n)
```

### 3.3 족보 판정
```
판정 시점: 매 턴 종료 시
판정 복잡도: O(n) (획득패 순회)
족보 수: 10+ (광, 띠 3종, 열끗, 피, 복합)
캐싱: 필요 없음 (48장 미만 순회)
```

### 3.4 부적 시스템
```
최대 슬롯: 5개
트리거 체크: 매 이벤트 발생 시 5개 순회 → O(1)
효과 적용 순서: 가산 → 승산 → 특수 (3-pass)
확률 처리: System.Random.NextDouble()
```

### 3.5 상태 관리
```
GameState: enum (7개 상태)
RoundPhase: enum (9개 페이즈)
상태 전환: 이벤트 기반 (Action delegate)
저장: JSON 직렬화 (PlayerState + 현재 층/라운드)
```

---

## 4. 저장 시스템

### 저장 데이터 구조
```json
{
  "version": "0.1.0",
  "saveSlot": 1,
  "timestamp": "2026-03-19T12:00:00Z",

  "player": {
    "lives": 2,
    "yeop": 150,
    "currentFloor": 3,
    "talismans": [
      {"name": "Blood Oath", "isActive": true},
      {"name": "Dokkaebi Hat", "isActive": true}
    ]
  },

  "run": {
    "seed": 42,
    "currentBossIndex": 2,
    "currentRound": 2,
    "totalRoundsInFloor": 3,
    "goTargetMultiplier": 1.0,
    "goHandPenalty": 0
  },

  "meta": {
    "totalRuns": 15,
    "bestScore": 42000,
    "achievements": ["first_win", "five_gwang"],
    "unlockedTalismans": ["Blood Oath", "Red Gate", "Dokkaebi Hat"]
  }
}
```

### 저장 타이밍
- 층 클리어 시 자동 저장
- 상점 퇴장 시 자동 저장
- 앱 백그라운드 진입 시 (모바일)
- 수동 저장 없음 (로그라이크 특성)

### 저장 위치
| 플랫폼 | 경로 |
|--------|------|
| PC | `Application.persistentDataPath` |
| iOS | `Application.persistentDataPath` (iCloud 백업) |
| Android | `Application.persistentDataPath` (내부 저장소) |

---

## 5. 성능 최적화

### UI 최적화
- 카드 UI: 오브젝트 풀링 (손패 10장 + 바닥패 12장 = 22개 풀)
- 텍스트: TextMeshPro (동적 폰트 아틀라스)
- 캔버스: 분리 (HUD / 카드 / 팝업) → 불필요한 리빌드 방지

### 메모리 최적화
- 카드 스프라이트: 아틀라스 패킹 (1장의 스프라이트 시트)
- 배경: 씬당 1장 (레이어드 패럴랙스는 3~4장)
- 오디오: BGM은 스트리밍, SFX는 메모리 로드

### 모바일 최적화
- 타겟 FPS: 30fps (카드 게임이므로 충분)
- 배터리: 화면 밝기 비간섭, 백그라운드 작업 최소화
- 발열: 파티클 수 제한, 셰이더 경량화

---

## 6. 테스트 전략

### 유닛 테스트 (NUnit)
```
Assets/Tests/EditMode/
├── HwaTuCardDatabaseTests.cs   — 카드 데이터 검증
├── DeckManagerTests.cs         — 셔플/분배 검증
├── MatchingEngineTests.cs      — 매칭 로직 검증
├── ScoringEngineTests.cs       — 족보/점수 검증
├── TalismanTests.cs            — 부적 효과 검증 (추가 예정)
├── GoStopDecisionTests.cs      — Go/Stop 리스크 검증 (추가 예정)
└── BossGimmickTests.cs         — 보스 기믹 검증 (추가 예정)
```

### 통합 테스트
- 1라운드 풀 루프 (딜 → 매칭 → 족보 → Go/Stop → 정산)
- 보스전 풀 루프 (3라운드 + 기믹)
- 런 풀 루프 (5층 완주)

### 밸런스 테스트 (자동 시뮬레이션)
```csharp
// 10,000회 자동 플레이로 통계 수집
// - 평균 클리어 점수
// - 부적별 승률 기여도
// - Go 횟수별 생존율
// - 층별 클리어율
```

---

## 7. CI/CD 파이프라인

### Git 브랜치 전략
```
main         — 안정 빌드 (릴리즈)
develop      — 개발 통합
feature/*    — 기능별 브랜치
hotfix/*     — 긴급 수정
```

### 빌드 자동화
| 트리거 | 동작 |
|--------|------|
| PR to develop | 유닛 테스트 실행 |
| Merge to develop | 개발 빌드 (PC) 생성 |
| Tag (v*) | 릴리즈 빌드 (PC + Mobile) |

### 빌드 도구
- **Unity Build Automation** 또는 **GameCI** (GitHub Actions)
- 빌드 아티팩트: Steam (Steamworks SDK), iOS (Xcode), Android (APK/AAB)

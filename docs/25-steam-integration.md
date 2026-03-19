# Steam 통합 & PC 빌드 설계

## 1. Steam 기능 연동

### Steamworks SDK 통합
| 기능 | 구현 | 우선순위 |
|------|------|---------|
| 업적 (Achievements) | 50개 업적 연동 | 필수 |
| 리더보드 | 4개 보드 (최고웨이브/점수/주간/스피드런) | 필수 |
| 클라우드 저장 | 세이브 파일 자동 동기화 | 필수 |
| 트레이딩 카드 | Steam 트레이딩 카드 5장 | 권장 |
| 리치 프레즌스 | "3영역에서 불꽃 도깨비와 대전 중" 표시 | 권장 |
| 스크린샷 | F12 스크린샷 + 족보 순간 자동 캡쳐 | 선택 |
| Steam Deck | 풀 지원 (Verified 목표) | 권장 |
| 워크샵 | 카드 스킨 모드 (Beta 이후) | 선택 |
| 데모 | Steam Next Fest 데모 빌드 | 필수 |

### Unity에서 Steamworks 연동
```csharp
// Steamworks.NET 사용 (무료, MIT 라이선스)
// https://github.com/rlabrecque/Steamworks.NET

// Assets/Plugins/Steamworks.NET/
// steam_appid.txt → 앱 ID 설정

// 초기화
SteamAPI.Init();

// 업적
SteamUserStats.SetAchievement("FIRST_WIN");
SteamUserStats.StoreStats();

// 리더보드
SteamUserStats.FindLeaderboard("HighestWave");
SteamUserStats.UploadLeaderboardScore(leaderboard,
    ELeaderboardUploadScoreMethod.k_ELeaderboardUploadScoreMethodKeepBest,
    waveNumber, null, 0);

// 클라우드 저장
SteamRemoteStorage.FileWrite("save.json", data, data.Length);
```

---

## 2. Steam 스토어 페이지 설계

### 기본 정보
```
제목: Dokkaebi's Hand (도깨비의 패)
개발사: [스튜디오명]
장르: Card Game, Roguelike, Strategy, Deckbuilder
태그: Roguelike Deckbuilder, Card Game, Strategy, Dark Fantasy,
      Korean, Singleplayer, Indie, Turn-Based, Atmospheric
플랫폼: Windows / macOS / Linux
가격: $9.99
출시: 얼리 액세스 → 정식 출시
```

### 스토어 설명 (영문)
```
=== Short Description (300자) ===
A roguelike deckbuilder based on Korean Hwatu (Go-Stop) cards.
Match cards, complete combinations, risk it all with "Go",
and fight your way through the Korean underworld.
Upgrade your cards, collect talismans, summon dokkaebi allies,
and challenge the endless abyss.

=== About This Game ===

🎴 HWATU MEETS ROGUELIKE
Play Go-Stop like never before. Match cards by month,
complete traditional Korean card combinations (yokbo),
and multiply your score with the Chips × Mult system.

👹 FACE THE TEN KINGS
Battle through 10 realms of the Korean underworld,
each ruled by a judge-king with unique mechanics.
Adapt your strategy or perish.

🔮 EVOLVE YOUR CARDS
Your 48-card deck grows with you. Enhance, mutate,
and awaken each card through 5 tiers of power.
No two decks are alike.

⚖️ GO OR STOP — GREED KILLS
Every round faces you with the ultimate choice.
Go for bigger multipliers at the risk of losing everything.
The Greed Scale watches your every move.

♾️ ENDLESS ABYSS
After the story, the real challenge begins.
Infinite waves, escalating difficulty, and powerful upgrades.
How far can you go?

🏮 KOREAN SPIRIT
Ink-wash visuals, traditional Korean music fusion,
and folklore brought to life. A cultural experience
wrapped in addictive card gameplay.
```

### 스크린샷 가이드 (7장)
1. **족보 완성 순간** — 홍단 완성 + 먹물 연출 (핵심 비주얼)
2. **Go/Stop 선택** — 욕망의 저울이 기울어진 상태
3. **보스전** — 먹보 도깨비 등장 + 대사
4. **카드 강화** — 전설 등급 카드 이펙트
5. **상점** — 부적 구매 화면
6. **무한 모드** — 웨이브 30+ 고점수 화면
7. **사주팔자** — 런 시작 시 사주 결정 화면

### 트레일러 구성 (60초)
```
[0-5초] 먹물 배경에서 제목 등장
[5-15초] 화투 매칭 기본 플레이
[15-25초] 족보 완성 → 점수 폭발 연출
[25-35초] Go/Stop 선택 → 욕망의 저울 → 3Go 폭발
[35-45초] 보스전 몽타주 (5종 보스 빠르게)
[45-55초] 카드 강화 + 부적 시너지 + 무한 모드
[55-60초] "당신의 욕심은 어디까지인가?" + 출시일
```

---

## 3. Steam Deck 최적화

### 입력 설정
| 동작 | Steam Deck |
|------|-----------|
| 카드 선택 | 좌스틱 커서 + A 버튼 |
| 카드 확인 | A 버튼 |
| 카드 상세 | Y 버튼 (길게) |
| Go/Stop | D-Pad 좌/우 + A 확인 |
| 족보 가이드 | L1 (토글) |
| 동료 도깨비 스킬 | R1/R2 |
| 메뉴 | Start |
| 빠른 진행 | R2 (홀드) |

### 해상도 & 성능
| 항목 | 목표 |
|------|------|
| 해상도 | 1280×800 (네이티브) |
| FPS | 30fps 고정 (배터리 절약) |
| 텍스트 크기 | 기본의 125% (자동) |
| UI 스케일 | 110% (자동) |
| 배터리 | 3시간+ 플레이 |

---

## 4. PC 빌드 사양

### 최소/권장 사양
| | 최소 | 권장 |
|--|------|------|
| OS | Windows 10 64-bit | Windows 10/11 64-bit |
| CPU | Intel i3-6100 / AMD Ryzen 3 | Intel i5-8400 / AMD Ryzen 5 |
| RAM | 4 GB | 8 GB |
| GPU | Intel HD 630 / GTX 750 | GTX 1050 / RX 560 |
| 저장 | 500 MB | 1 GB |
| DirectX | 11 | 12 |

### 빌드 설정
```
Platform: Windows x64 / macOS / Linux
Scripting Backend: IL2CPP
API Compatibility: .NET Standard 2.1
Graphics API: DirectX 11/12, Vulkan (Linux), Metal (Mac)
Compression: LZ4HC
Strip Engine Code: Yes
```

---

## 5. 출시 로드맵

### Phase 1: 얼리 액세스 (EA)
```
기간: 3~6개월
콘텐츠:
  - 스토리 5영역 (1~5)
  - 부적 15종
  - 카드 강화 3등급 (기본~신통)
  - 기본 업적 20개
  - 한국어 + 영어

가격: $7.99 (정식 출시 시 인상 고지)

목표:
  - 커뮤니티 피드백 수집
  - 밸런스 데이터 수집
  - 버그 수정
```

### Phase 2: 콘텐츠 업데이트
```
EA 중 1~2회 대규모 업데이트

업데이트 1 (EA +2개월):
  - 스토리 6~10영역
  - 부적 10종 추가 (총 25종)
  - 무한 모드 (웨이브 25까지)
  - 카드 강화 전설 등급 추가
  - 업적 15개 추가

업데이트 2 (EA +4개월):
  - 무한 모드 확장 (웨이브 100+)
  - 영구 강화 트리
  - 사주팔자 시스템
  - 도깨비 각인 시스템
  - 일본어 로컬라이제이션
```

### Phase 3: 정식 출시 (v1.0)
```
가격: $9.99

추가 콘텐츠:
  - 해탈 등급 카드
  - 동료 도깨비 전체
  - 뉴게임+ (윤회)
  - 업적 50개 완성
  - Steam 트레이딩 카드
  - 주간 도전
  - 폴리싱 (최종 아트, 사운드, 이펙트)
```

### Phase 4: 출시 후 지원
```
무료 업데이트 (시즌):
  - 3개월 주기 시즌 콘텐츠
  - 새 부적, 이벤트, 보스

유료 DLC (검토):
  - 새로운 저승 (외국 신화 접목)
  - 카드 스킨 팩
```

---

## 6. 커뮤니티 & 위시리스트 전략

### Steam Next Fest 참가
- **데모 범위:** 튜토리얼 + 1~2영역 + 상점 1회
- **플레이 시간:** 20~30분
- **데모 한정 보상:** 정식 출시 시 전용 카드 스킨 해금

### 위시리스트 캠페인
```
목표: 출시 전 위시리스트 10,000+

채널별 전략:
- Reddit (r/roguelikes, r/deckbuildinggames): 개발 GIF 주 1회
- Twitter/X: 일일 개발 스크린샷 + 족보/부적 소개
- YouTube: 인디 게임 유튜버 키 배포 (10~20명)
- 한국 커뮤니티: 인벤, 루리웹, 에펨코리아 홍보
- Discord: 개발 서버 운영, 알파 테스터 모집
```

### Steam 태그 전략
```
필수 태그:
- Roguelike Deckbuilder
- Card Game
- Strategy
- Indie

차별화 태그:
- Korean (한국 문화)
- Dark Fantasy
- Atmospheric
- Turn-Based

트렌드 태그:
- Balatro-like (검색 유입)
- Singleplayer
- Replay Value
```

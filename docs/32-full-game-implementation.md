# 전체 게임 완성 구현 문서

## 구현 개요

8단계에 걸쳐 "뼈대 완성" 상태에서 "완전한 플레이 경험"으로 확장 완료.

## Step 1: 크리티컬 버그 수정

### 쓸(Sweep) 배수 보너스
- `RoundManager.cs` — `_sweepMultBonus` 필드 추가, `ExecuteHandMatch`에서 누적, `SelectStop`에서 실제 적용
- 기존: 코드에서 sweepBonus를 계산만 하고 적용하지 않음
- 수정: `result.Mult += _sweepMultBonus` 적용 + CompletedYokbo에 표시

### card_pack 소모품 효과
- `PlayerState.cs` — `NextRoundHandBonus` 필드 추가
- `ShopManager.cs:119` — `player.NextRoundHandBonus += 2` 실제 적용
- `RoundManager.cs:StartRound` — NextRoundHandBonus 반영하여 handSize 증가

### SpiralStart 축복 선택 분리
- `GameManager.cs` — `BeginSpiralWithBlessing()` 메서드 분리
- UI에서 축복 선택 후 별도 호출

## Step 2: 축복 선택 UI

- `MockupSceneBuilder.cs` — `ShowBlessingSelectionUI()` 추가
- 4종 축복 버튼 (색상 구분) + "거부" 버튼
- `HandleStateChange` → `SpiralStart`에서 자동 호출
- `SpiralManager.cs` 축복 효과 → `RoundManager.BlessingHandPenalty`로 전달

## Step 3: 저승 수련 UI

- `MockupSceneBuilder.cs` — `ShowUpgradeTreeUI()` 추가
- 3갈래 트리를 좌/중/우 컬럼으로 배치
- 넋 잔여량 표시 + 구매 가능 여부 색상 표시
- 메인 메뉴 + 게임오버 화면에서 접근 가능

## Step 4: 웨이브 강화 선택

- `WaveUpgradeManager.cs` (신규) — 12종 강화 풀, 랜덤 3개 선택
  - 카테고리: card / talisman / survival / special
  - 고렙(10+) 전용 강화 추가
- `MockupSceneBuilder.cs` — `ShowWaveUpgradeUI()` — 3개 카드형 선택 UI
- `GameManager.HandleRoundEnded` — 관문 보스 격파 후 웨이브 강화 생성

## Step 5: 부적 20종 확장

### 추가 13종
| # | 이름 | 등급 | 효과 |
|---|------|------|------|
| 8 | 삼도천의 나룻배 | 일반 | 라운드 시작 시 칩 +15 |
| 9 | 도깨비 방망이 | 일반 | 쓸 시 칩 +40 |
| 10 | 열녀문 | 일반 | 초단 완성 시 배수 +2 |
| 11 | 황천의 거울 | 희귀 | Stop 시 칩 +50 |
| 12 | 기린 각 | 희귀 | 열끗 5장+ 시 배수 +3 |
| 13 | 사주팔자의 주사위 | 희귀 | Go 시 50% 칩 +80 |
| 14 | 염라왕의 도장 | 전설 | 오광 시 배수 x3 |
| 15 | 천상의 비파 | 전설 | 청단 시 칩+100 배수+2 |
| 16 | 지옥불꽃 | 전설 | 피 15장+ 시 배수 x2 |
| 17 | 허깨비 | 저주 | 매칭 실패 시 엽전 -5 |
| 18 | 망각의 띠 | 저주 | Go 2회+ 시 손패 -1 |
| 19 | 윤회의 구슬 | 일반 | 광 1장당 칩 +10 |
| 20 | 욕망의 저울 | 희귀 | 목표 -10%, 영역 시 목숨 -1 |

### 트리거 연결
- `TalismanManager.NotifyTrigger()` — 모든 비점수 트리거 처리
- `RoundManager.PlayHandCard()` — OnTurnStart, OnMatchFail 트리거
- `RoundManager.ExecuteHandMatch()` — OnMatchSuccess, OnCardPlayed 트리거
- `RoundManager.EndTurn()` — OnTurnEnd 트리거 (흉살 등)
- `MatchingEngine` — OnMatchSuccess/OnMatchFail 이벤트 추가

## Step 6: 대장간 + 동료 스킬

### 대장간
- `MockupSceneBuilder.ShowForgeUI()` — 저승 장터 내 "대장간" 탭
- `CardEnhancementManager.GetUpgradeCost()` — 비용 계산 (50/100/200/500)
- `GameManager.UpgradeCard()` — 강화 실행

### 길들인 도깨비 스킬 실행
- `CompanionDokkaebi.ExecuteAbility()` — 7종 전체 구현
  - 먹보: 바닥패 1장 제거
  - 장난꾸러기: 손패↔바닥 교환
  - 여우: 와일드카드 (SetWildCardNext)
  - 거울: 보스 기믹 반사 (ReflectNextMechanic)
  - 불꽃: 바닥패 전체 리셋 (CompanionResetField)
  - 그림자: 보스 HP -15% (ApplyShadowReduction)
  - 뱃사공: 턴 되감기 (간소화: 보스 HP 감소)
- `BossManager.ReflectNextMechanic()` 추가

## Step 7: 튜토리얼

- `TutorialManager.cs` (신규) — 4단계 진행 관리
  1. 패 내기와 매칭
  2. 족보와 점수
  3. Go/Stop 선택
  4. 보스와 전략
- `MockupSceneBuilder.ShowTutorialOverlay()` — 뱃사공 대사 + 힌트 + 다음/스킵
- `GameManager.IsTutorialMode` — 첫 런 감지 (`PlayerPrefs.HasKey("tutorial_done")`)

## Step 8: 세이브/로드 + 업적 + 도감

### 세이브/로드
- `GameManager.LoadFromSave(SaveData)` — 윤회/관문/부적/수련/길들인 도깨비/업적 복원
- `GameBootstrap` — 시작 시 `SaveManager.Load()` → `LoadedSave` 저장
- 메인 메뉴 "이어하기" 버튼 — `LoadedSave` 존재 시 활성화

### 업적 UI
- `MockupSceneBuilder` — `OnAchievementUnlocked` 구독하여 토스트 메시지 표시
- `ShowCollectionUI()` — 업적 목록 + 달성 진행률

### 도감
- 메인 메뉴 "도감" 버튼 → 업적 목록 화면

## 수정 파일 목록

| 파일 | 변경 사항 |
|------|----------|
| `PlayerState.cs` | NextRoundHandBonus, WildCardNextMatch 필드 추가 |
| `RoundManager.cs` | 쓸 보너스, 축복 패널티, 부적 트리거, 길들인 도깨비 스킬 메서드 |
| `GameManager.cs` | BeginSpiralWithBlessing, LoadFromSave, UpgradeCard, 관문 강화 |
| `MockupSceneBuilder.cs` | 축복/수련/대장간/길들인 도깨비/튜토리얼/업적/도감 UI 전부 |
| `ShopManager.cs` | card_pack 효과, UpgradeCard |
| `TalismanDatabase.cs` | 13종 추가 (총 20종) |
| `TalismanManager.cs` | NotifyTrigger 메서드 |
| `MatchingEngine.cs` | OnMatchSuccess/OnMatchFail 이벤트 |
| `CompanionDokkaebi.cs` | ExecuteAbility 전 스킬 구현 (길들인 도깨비) |
| `BossManager.cs` | ReflectNextMechanic |
| `CardEnhancement.cs` | GetUpgradeCost, GetAllEnhancements |
| `LocalizationManager.cs` | ~80개 키 추가 |
| `GameBootstrap.cs` | SharedSaveManager, LoadedSave 정적 프로퍼티 |
| `docs/07-mvp-status.md` | 전체 현황 업데이트 (새 컨셉: HP 기반 전투, 윤회/관문 구조) |

## 신규 파일
| 파일 | 설명 |
|------|------|
| `Core/WaveUpgradeManager.cs` | 웨이브 강화 3택 시스템 |
| `Core/TutorialManager.cs` | 4단계 튜토리얼 |
| `docs/32-full-game-implementation.md` | 이 문서 |

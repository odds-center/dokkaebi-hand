# 구현 현황

> **현재 방향:** 보스 HP 전투 시스템 + 3종 족보(고스톱+섯다+저승) + 윤회/관문 구조
> 용어: 나선→윤회, 영역→관문, 목표 점수→보스 HP, 점수→데미지, 상점→저승장터

## Phase 1: MVP (완료)

### 데이터 모델
- [x] `HwaTuCard.cs` — ScriptableObject 정의
- [x] `HwaTuCardDatabase.cs` — 48장 전체 카드 코드 데이터베이스
- [x] `CardInstance.cs` — 런타임 카드 인스턴스
- [x] `PlayerState.cs` — 플레이어 상태 관리 + NextRoundHandBonus + WildCardNextMatch

### 코어 로직
- [x] `DeckManager.cs` — 셔플, 분배, 뽑기
- [x] `MatchingEngine.cs` — 같은 월 매칭 판정 (4가지 케이스) + OnMatchSuccess/OnMatchFail 이벤트
- [x] `ScoringEngine.cs` — 고스톱 족보 판정 + 칩/배수 계산 (→ 섯다/저승 족보 추가 필요)
- [x] `GoStopDecision.cs` — Go/Stop 리스크 적용

### 게임 루프
- [x] `RoundManager.cs` — 턴 진행 (7단계 페이즈) + 쓸 보너스 실적용 + 축복 손패 패널티 + 부적 트리거 전체 연결
- [x] `GameManager.cs` — 라운드 연결, 관문 진행, 보스 HP 전투 + LoadFromSave + 웨이브 강화 흐름 + 축복 분리
- [x] `GameBootstrap.cs` — Unity 진입점 + 세이브 로드 연동

### 부적 시스템
- [x] `TalismanDatabase.cs` — 20종 (일반 6, 희귀 5, 전설 4, 저주 3, 특수 2)
- [x] `TalismanManager.cs` — 트리거/효과 적용 (가산→승산→특수) + NotifyTrigger (모든 트리거 포인트)

### 보스 시스템
- [x] `BossManager.cs` — 기믹 처리 (5가지 기믹) + 거울 도깨비 반사 + HP 바 + 반격 + 격노 페이즈
- [x] `BossGenerator.cs` — 랜덤 보스 생성 (항상 랜덤, 고정 순서 없음)
- [x] `BossParts.cs` — 24종 파츠, 세트 효과

### 무한 윤회
- [x] `SpiralManager.cs` — 10관문 1윤회, 무한 반복 (용어: 나선→윤회, 영역→관문)
- [x] `SpiralBlessing` — 4종 축복 (업화/빙결/공허/혼돈)

### 영구 진행
- [x] `PermanentUpgradeManager.cs` — 3갈래 트리 (패/부적/생존) 19종
- [x] `AchievementManager.cs` — 21종 업적, Steam 연동 준비
- [x] `SoulFragmentCalculator.cs` — 보상 공식

### 동료 시스템
- [x] `CompanionDokkaebi.cs` — 7종 동료 + ExecuteAbility (전 스킬 구현)

### 카드 강화
- [x] `CardEnhancement.cs` — 5단계 강화 (기본→연마→신통→전설→해탈) + 비용 계산

### 세이브 시스템
- [x] `SaveSystem.cs` — 이중 저장 (로컬 + Steam 클라우드) + 자동 세이브

### 상점/이벤트
- [x] `ShopManager.cs` — 부적 3종 + 소모품 2종 + 대장간(카드 강화)
- [x] `EventManager.cs` — 6종 랜덤 이벤트

### 다국어
- [x] `LocalizationManager.cs` — 4개 언어 (KR/EN/JP/ZH) ~200개 키

### UI
- [x] `MockupSceneBuilder.cs` — 100% 프로그래매틱 UI (전체 화면 단일 캔버스)

## Phase 2: 전체 완성 (완료)

### 신규 시스템
- [x] `WaveUpgradeManager.cs` — 관문 클리어 시 3택 1 강화 선택 (12종)
- [x] `TutorialManager.cs` — 4단계 인터랙티브 튜토리얼

### UI 확장
- [x] 축복 선택 UI (윤회 시작 시 4종 택 1 + 거부)
- [x] 영구 강화 UI (메인 메뉴 + 게임오버에서 접근)
- [x] 웨이브 강화 UI (3개 카드형 선택)
- [x] 대장간 UI (상점 내 카드 강화)
- [x] 동료 도깨비 UI (하단 아이콘 + 스킬 사용)
- [x] 튜토리얼 오버레이 (뱃사공 대사 + 힌트 + 스킵)
- [x] 업적 토스트 (달성 시 자동 표시)
- [x] 도감 UI (업적 목록)
- [x] 이어하기 버튼 (세이브 존재 시)
- [x] 게임오버 화면 개선 (영구 강화 접근)

### 버그 수정
- [x] 쓸(Sweep) 배수 보너스 실제 적용
- [x] card_pack 소모품 효과 구현 (NextRoundHandBonus)
- [x] SpiralStart에서 축복 선택 UI 분리

## Phase 3: Love2D 프로토타입 (진행 중)

### 오디오
- [x] BGM 시스템 (`bgm.lua`) — 5 CC0 트랙(OpenGameArt), 게임 상태 기반 자동 전환, 1초 크로스페이드
- [x] SFX 절차적 생성 (`sfx.lua`) — 24종 효과음, 외부 파일 없이 코드로 생성

### 전투 UI
- [x] 손패 정렬 — 4가지 모드 (없음/월/타입/값), CardEnums.CardTypeValue 기반
- [x] 콤보 카테고리 그룹핑 — 6개 분류(gostop/seotda/jeoseung/seasonal/collection/monthpair), 카테고리별 고유 색상
- [x] 중앙 메시지 시스템 — 보스 등장/격파/판 시작 시 시네마틱 페이드인/아웃 메시지
- [x] 보스 패널 UI 개선 — 이중 패널 배경, HP 비율 컬러바, 기믹 빨간 뱃지, HP바 광택 효과, 콤보 카테고리 태그
- [x] 데미지 패널 UI 개선 — 칼럼 구분선, 파란 칩 색상, 금색 데미지 배경, 460px 패널

### 설정 UI
- [x] 볼륨 슬라이더 — 1% 단위 드래그 지원 (기존 20% 단계)
- [x] 픽셀아트 16x16 도트 아이콘 — 지구본(언어), 번개(속도), 흔들림(화면흔들림), 음표(BGM), 스피커(SFX)
- [x] 아이콘 생성기 (`icon_generator.lua`) — 설정 아이콘 절차적 생성

### 저승 장터
- [x] TalismanDatabase 연동 — `talisman_database.lua`(20종)에서 직접 목록 참조
- [x] 보유 부적 제외 + 저주 부적 제외
- [x] 등급별 가격: 일반=40, 희귀=70, 전설=120

### 이벤트
- [x] 5종 이벤트 구현 — 운명의 갈림길, 저승 방랑자, 도깨비불 시험, 삼도천 강가, 과거의 도전자
- [x] 선택이 다음 보스전에 직접 영향 — HP 변조(`_next_boss_hp_mult`), 기믹 봉인(`_next_boss_gimmick_seal`)
- [x] 동전 던지기(삼도천) — 50% 도박 + 중앙 연출 메시지

### 축복/강화
- [x] 축복 카드 레이아웃 — 80px 이미지 영역 추가, 카드 높이 210→280px
- [x] 중복 없는 강화 선택 — gen_upgrades() 셔플 후 3개 선택 (기존 랜덤 중복 가능)

### Love2D 파일 목록
```
dokkaebi-love2d/
  main.lua, conf.lua
  src/core/       — sfx.lua, bgm.lua, player_state.lua, spiral_manager.lua, number_formatter.lua
  src/cards/      — deck_manager.lua, hand_evaluator.lua, card_enums.lua
  src/combat/     — seotda_challenge.lua, boss_data.lua, boss_battle.lua
  src/talismans/  — talisman_data.lua, talisman_database.lua, talisman_manager.lua
  src/ui/         — card_renderer.lua, button.lua, draw_utils.lua, effects.lua, icon_generator.lua, yokbo_guide.lua
  assets/bgm/     — 5 CC0 BGM tracks
  assets/fonts/   — Pretendard fonts
```

## 전체 파일 목록

### Core
```
Assets/Scripts/Core/GameManager.cs
Assets/Scripts/Core/PlayerState.cs
Assets/Scripts/Core/GameBootstrap.cs
Assets/Scripts/Core/SpiralManager.cs
Assets/Scripts/Core/ShopManager.cs
Assets/Scripts/Core/EventManager.cs
Assets/Scripts/Core/PermanentUpgradeManager.cs
Assets/Scripts/Core/AchievementManager.cs
Assets/Scripts/Core/CompanionDokkaebi.cs
Assets/Scripts/Core/LocalizationManager.cs
Assets/Scripts/Core/NumberFormatter.cs
Assets/Scripts/Core/SoulFragmentCalculator.cs
Assets/Scripts/Core/SaveSystem.cs
Assets/Scripts/Core/WaveUpgradeManager.cs     (신규)
Assets/Scripts/Core/TutorialManager.cs        (신규)
```

### Cards
```
Assets/Scripts/Cards/HwaTuCard.cs
Assets/Scripts/Cards/HwaTuCardDatabase.cs
Assets/Scripts/Cards/CardInstance.cs
Assets/Scripts/Cards/CardEnhancement.cs
Assets/Scripts/Cards/DeckManager.cs
Assets/Scripts/Cards/MatchingEngine.cs
Assets/Scripts/Cards/ScoringEngine.cs
Assets/Scripts/Cards/GoStopDecision.cs
```

### Combat
```
Assets/Scripts/Combat/RoundManager.cs
Assets/Scripts/Combat/BossManager.cs
Assets/Scripts/Combat/BossGenerator.cs
Assets/Scripts/Combat/BossParts.cs
Assets/Scripts/Combat/BossData.cs
Assets/Scripts/Combat/BossDatabase.cs
```

### Talismans
```
Assets/Scripts/Talismans/Talisman.cs
Assets/Scripts/Talismans/TalismanInstance.cs
Assets/Scripts/Talismans/TalismanManager.cs
Assets/Scripts/Talismans/TalismanDatabase.cs
```

### UI
```
Assets/Scripts/UI/MockupSceneBuilder.cs
Assets/Scripts/UI/MockupSpriteFactory.cs
Assets/Scripts/UI/GameUIManager.cs
Assets/Scripts/UI/CardUI.cs
```

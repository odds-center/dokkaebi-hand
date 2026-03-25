# 아키텍처 문서

## 폴더 구조
```
/Assets
  /Scripts
    /Core        - GameManager, PlayerState, GameBootstrap, SpiralManager,
                   PermanentUpgradeManager, AchievementManager, CompanionDokkaebi,
                   SaveSystem, ShopManager, EventManager, LocalizationManager,
                   NumberFormatter, WaveUpgradeManager, TutorialManager,
                   DestinySystem, GreedScale, DokkaebiSealSystem, SoulFragmentCalculator
    /Cards       - HwaTuCard, HwaTuCardDatabase, CardInstance, CardEnhancement,
                   DeckManager, HandEvaluator, MatchingEngine, ScoringEngine, GoStopDecision
    /Combat      - RoundManager, BossManager, BossGenerator, BossParts, BossData,
                   BossDatabase, BossBattle, BattleSystem, SeotdaChallenge
    /Talismans   - Talisman, TalismanInstance, TalismanManager, TalismanDatabase
    /UI          - MockupSceneBuilder, MockupSpriteFactory, GameUIManager, CardUI,
                   GameEffects, CardHoverHandler
  /Art           - 스프라이트, 일러스트, 배경, 파티클
  /Audio         - BGM, SFX
  /Data          - ScriptableObject 에셋
  /Tests
    /EditMode    - 18개 유닛 테스트

/dokkaebi-love2d           - Love2D 프로토타입 (플레이 가능)
/pixel-art-generator       - FLUX Dev API 에셋 생성 도구
/sd-prompts-flux           - 카테고리별 프롬프트 정의 (300+ 에셋)
```

## 핵심 클래스 다이어그램

```
GameBootstrap (MonoBehaviour, 진입점)
    └── GameManager (게임 루프 총괄)
            ├── PlayerState (플레이어 상태)
            ├── DeckManager (덱 셔플/분배)
            ├── TalismanManager (부적 트리거/효과)
            ├── BossManager (보스 기믹)
            ├── SpiralManager (윤회/관문 진행)
            ├── PermanentUpgradeManager (영구 강화)
            ├── AchievementManager (업적)
            ├── CompanionDokkaebi (동료 도깨비)
            ├── WaveUpgradeManager (웨이브 강화)
            ├── TutorialManager (튜토리얼)
            ├── DestinySystem (사주팔자)
            ├── GreedScale (탐욕 저울)
            ├── DokkaebiSealSystem (도깨비 인장)
            ├── ShopManager (저승 장터)
            ├── EventManager (이벤트)
            ├── SaveSystem (이중 저장)
            └── RoundManager (라운드 진행)
                    ├── HandEvaluator (족보 판정 — 고스톱/섯다/저승)
                    ├── MatchingEngine (패 매칭 판정)
                    ├── ScoringEngine (칩/배수 계산)
                    ├── SeotdaChallenge (섯다 2장 대결)
                    └── GoStopDecision (Go/Stop 리스크)
```

## 데이터 흐름

### 전투 흐름 (보스 HP 전투)
```
1. PlayerTurn: 플레이어가 손패에서 카드 선택 (1~5장)
2. HandMatch: MatchingEngine이 바닥패와 매칭 판정
3. DrawFlip: DeckManager에서 뒤집기 카드 드로우
4. DrawMatch: 뒤집기 카드 매칭
5. YokboCheck: HandEvaluator가 3종 족보 판정 (고스톱/섯다/저승)
6. GoStopChoice: 족보 완성 시 Go/Stop 선택
7. AttackSelect: 모은 패 중 2장 선택 → 섯다 족보 판정
8. Damage: 최종 데미지 = 칩 × 배수 × Go 배수 → 보스 HP 차감
9. BossReaction: 보스 기믹 + 반격 + 격노 페이즈
```

### 데미지 계산 파이프라인
```
기본 족보 (HandEvaluator — 3종 족보 시너지)
    ↓
칩(Chips) + 배수(Mult) 산출
    ↓
Go 배수 적용 (1Go=×2, 2Go=×4, 3Go=×10)
    ↓
부적 가산(+) 효과 (TalismanManager)
    ↓
부적 승산(×) 효과 (TalismanManager)
    ↓
특수 부적 효과 (피의 맹세, 저승사자의 명부 등)
    ↓
웨이브 강화 보너스 (WaveUpgradeManager)
    ↓
최종 데미지 = Chips × Mult → 보스 HP 차감
```

## Love2D 프로토타입 구조

```
dokkaebi-love2d/
  main.lua, conf.lua
  src/core/       — game_manager, player_state, spiral_manager, number_formatter,
                    bgm, sfx, achievement_manager, companion_manager, destiny_system,
                    event_manager, greed_scale, localization, permanent_upgrades,
                    save_system, seal_system, shop_manager, soul_calculator,
                    tutorial_manager, wave_upgrades
  src/cards/      — deck_manager, hand_evaluator, card_enums, card_database,
                    card_enhancement, card_instance, go_stop_decision, matching_engine
  src/combat/     — round_manager, boss_manager, boss_battle, boss_data,
                    boss_generator, seotda_challenge
  src/talismans/  — talisman_data, talisman_database, talisman_manager
  src/ui/         — card_renderer, button, draw_utils, effects, hud,
                    icon_generator, icons, pixel_icons, boss_icons, yokbo_guide
  assets/bgm/     — 5 CC0 BGM tracks (OpenGameArt)
  assets/fonts/   — Pretendard fonts
```

## 아트 에셋 파이프라인

```
pixel-art-generator/          ← FLUX Dev API 생성 도구
  config.py                   — 모델/카테고리/경로 설정
  parse_prompts.py            — sd-prompts-flux/ md 파싱
  generate.py                 — Replicate API 호출
  batch_generate.py           — 배치 생성 CLI (메인 진입점)
  post_process.py             — 배경 제거, 리사이즈, 스프라이트시트
  generate_all.py             — 전체 생성 스크립트

sd-prompts-flux/              ← 프롬프트 정의 (12개 카테고리)
  01-bosses.md                — 보스 스프라이트
  02-boss-expressions.md      — 보스 표정 변형
  03-companions.md            — 동료 도깨비
  04-talismans.md             — 부적 아이콘
  05-backgrounds.md           — 게임 배경
  06-card-illustrations.md    — 화투 카드 48장
  07-card-extras.md           — 카드 뒷면/강화
  08-icons.md                 — UI 아이콘
  09-vfx.md                   — VFX 이펙트
  10-ui-frames.md             — UI 프레임/패널
  11-hud-icons.md             — HUD 아이콘
```

## 테스트 구조

```
Assets/Tests/EditMode/
  HwaTuCardDatabaseTests.cs   — 48장 카드 데이터 검증
  DeckManagerTests.cs          — 셔플/분배 로직
  MatchingEngineTests.cs       — 매칭 판정
  ScoringEngineTests.cs        — 족보/점수 계산
  BossGeneratorTests.cs        — 랜덤 보스 생성
  CombatFlowTests.cs           — 전투 흐름 통합
  TalismanExpandedTests.cs     — 부적 효과
  PermanentUpgradeTests.cs     — 영구 강화
  WaveUpgradeManagerTests.cs   — 웨이브 강화
  TutorialManagerTests.cs      — 튜토리얼
  CardEnhancementTests.cs      — 카드 강화
  SpiralManagerTests.cs        — 윤회/관문
  NumberFormatterTests.cs      — 큰 숫자 표시
  BossDefeatTransitionTests.cs — 보스 격파 전환
  PersonaSimulationTests.cs    — 페르소나 시뮬레이션
  AdditionalBugFixTests.cs     — 추가 버그 수정
  ThirdPassBugFixTests.cs      — 3차 버그 수정
  ScalingAndErrorTests.cs      — 스케일링/에러
```

---

## 설계 원칙
1. **비MonoBehaviour 로직 우선:** 게임 로직은 순수 C# 클래스로 구현, Unity 의존성 최소화
2. **테스트 가능성:** 핵심 로직(매칭, 족보, 점수)은 유닛 테스트로 검증 (18개 테스트 파일)
3. **데이터 분리:** 런타임 데이터베이스(코드) + ScriptableObject(에셋) 이중 구조
4. **이벤트 기반:** 상태 변경 시 이벤트로 UI 업데이트 트리거
5. **이중 구현:** Unity C# (프로덕션) + Love2D Lua (프로토타입) 병행

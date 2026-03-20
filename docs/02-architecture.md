# 아키텍처 문서

## 폴더 구조
```
/Assets
  /Scripts
    /Core        - GameManager, PlayerState, GameBootstrap
    /Cards       - HwaTuCard, DeckManager, MatchingEngine, ScoringEngine
    /Talismans   - Talisman, TalismanManager, TalismanDatabase
    /Combat      - RoundManager, BossManager, BossData
    /UI          - GameUIManager, CardUI
    /Effects     - VFX, 사운드 트리거 (TBD)
  /Art           - 스프라이트, 일러스트, 배경, 파티클
  /Audio         - BGM, SFX
  /Data          - ScriptableObject 에셋
  /Tests         - 유닛 테스트
```

## 핵심 클래스 다이어그램

```
GameBootstrap (MonoBehaviour, 진입점)
    └── GameManager (게임 루프 총괄)
            ├── PlayerState (플레이어 상태)
            ├── DeckManager (덱 셔플/분배)
            ├── TalismanManager (부적 트리거/효과)
            ├── BossManager (보스 기믹)
            └── RoundManager (라운드 진행)
                    ├── MatchingEngine (패 매칭 판정)
                    ├── ScoringEngine (족보/점수 계산)
                    └── GoStopDecision (Go/Stop 리스크)
```

## 데이터 흐름

### 턴 진행 흐름
```
1. PlayerTurn: 플레이어가 손패에서 카드 선택
2. HandMatch: MatchingEngine이 바닥패와 매칭 판정
3. DrawFlip: DeckManager에서 뒤집기 카드 드로우
4. DrawMatch: 뒤집기 카드 매칭
5. YokboCheck: ScoringEngine이 족보 판정
6. GoStopChoice: 족보 완성 시 Go/Stop 선택
7. Scoring: 최종 점수 계산 (칩 × 배수 + 부적 효과)
```

### 점수 계산 파이프라인
```
기본 족보 점수 (ScoringEngine)
    ↓
Go 배수 적용
    ↓
부적 가산(+) 효과 (TalismanManager)
    ↓
부적 승산(×) 효과 (TalismanManager)
    ↓
특수 부적 효과 (피의 맹세, 저승사자의 명부 등)
    ↓
최종 점수 = Chips × Mult
```

## Love2D 프로토타입 구조

```
dokkaebi-love2d/
  main.lua
  conf.lua
  src/core/       — sfx.lua, bgm.lua, player_state.lua, spiral_manager.lua, number_formatter.lua
  src/cards/      — deck_manager.lua, hand_evaluator.lua, card_enums.lua
  src/combat/     — seotda_challenge.lua, boss_data.lua, boss_battle.lua
  src/talismans/  — talisman_data.lua, talisman_database.lua, talisman_manager.lua
  src/ui/         — card_renderer.lua, button.lua, draw_utils.lua, effects.lua, icon_generator.lua, yokbo_guide.lua
  assets/bgm/     — 5 CC0 BGM tracks (OpenGameArt)
  assets/fonts/   — Pretendard fonts
```

---

## 설계 원칙
1. **비MonoBehaviour 로직 우선:** 게임 로직은 순수 C# 클래스로 구현, Unity 의존성 최소화
2. **테스트 가능성:** 핵심 로직(매칭, 족보, 점수)은 유닛 테스트로 검증
3. **데이터 분리:** 런타임 데이터베이스(코드) + ScriptableObject(에셋) 이중 구조
4. **이벤트 기반:** 상태 변경 시 이벤트로 UI 업데이트 트리거

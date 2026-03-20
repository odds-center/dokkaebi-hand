# 도깨비의 패 (Dokkaebi's Hand) — CLAUDE.md

## 핵심 컨셉
> **넌 죽었다. 저승의 도깨비들과 고스톱을 쳐서 이승으로 돌아가야 한다.**
> 화투패를 모아서 족보를 만들고, 그 족보로 보스 도깨비의 HP를 깎아서 물리친다.

**장르:** 무한 로그라이트 화투 액션 덱빌더 (Unity C#, Steam PC)
**전투 시스템:** 고스톱 매칭으로 패를 모은다 → 족보 = 공격 → 보스 HP를 깎는다

### 3가지 족보 체계
1. **고스톱 족보** — 오광/삼광/홍단/청단/초단/고도리/총통 등 (전통)
2. **섯다 족보** — 먹은 패 중 2장 조합: 38광땡/장땡/알리/독사/구삥/세륙 등
3. **저승 족보** — 이 게임만의 고유 조합: 사계/월하독작/선후착/도깨비불 등

### 전투 흐름
```
보스가 판을 깐다 (HP: ████████ 1,500)

[고스톱 페이즈] 패를 모아서 시너지를 쌓는다
  → 패 돌리기 (손패 10장, 바닥 8장)
  → 손패 1장 → 바닥 매칭 → 먹기 / 더미 뒤집기 → 매칭
  → 모은 패로 고스톱 족보 완성 = 시너지 버프 활성!
    (삼광 → 섯다 데미지 ×2, 홍단 → 섯다 +40점, 고도리 → ×1.5)
  → 족보 하나라도 완성 → "고 할래? 스톱 할래?"
    - 고 → 시너지 배수 추가 (위험!)
    - 스톱 → 공격 페이즈로

[공격 페이즈] 모은 패 중 2장으로 섯다 공격!
  → 모은 패 중 2장 선택 → 섯다 족보 판정
  → 섯다 기본 데미지 × 고스톱 시너지 배수 = 최종 타격
  → 공격에 쓴 2장은 소모됨! (시너지 깨질 수 있음)
  → 보스 반격 (기믹 + 카운터어택)
  → 보스 HP 0 → 관문 돌파!

핵심 딜레마: "삼광 시너지(×2)를 유지할까, 광을 38광땡으로 써서 한 방에 때릴까?"
```

## 세계관 용어
| 게임 용어 | 의미 | 비고 |
|-----------|------|------|
| 윤회 | 10관문 = 1윤회, 무한 반복 | 나선(Spiral) 대체 |
| 관문 | 보스가 지키는 저승의 문 | 영역(Realm) 대체 |
| 판 | 라운드 | 고스톱 용어 |
| 고/스톱 | Go/Stop | 고스톱 원래 용어 |
| 먹다/쓸/쪽 | 매칭 결과 | 고스톱 원래 용어 |
| 넋 | 영구 강화 화폐 | 영혼 조각 대체 |
| 엽전(냥) | 런 내 화폐 | |
| 저승 장터 | 상점 | |
| 저승 수련 | 영구 강화 | |
| 길들인 도깨비 | 동료 (이긴 보스를 부림) | |
| 기물 | 보스 장비 파츠 | |

## 핵심 규칙
- **아트 스타일:** 2D 픽셀아트. FilterMode.Point.
- **무한 윤회:** 10관문 = 1윤회, 무한 반복. 최종 스테이지 없음.
- **보스:** 항상 랜덤 생성 (랜덤 도깨비 + 랜덤 기물 조합 + 랜덤 기믹 간격)
- **보스 HP:** 족보 데미지로 깎는다. 여러 판 쳐서 HP 0으로 만들면 격파.
- **선택적 엔딩:** 매 윤회 끝 "이승의 문". 엔딩 후에도 계속 가능.
- **입력:** 마우스/터치 전용. 키보드 절대 사용 안 함.
- **네트워크:** 100% 오프라인.
- **저장:** 로컬 파일 + Steam 클라우드 이중 저장.
- **다국어:** 한국어/영어/일본어/중국어 (L.Get("key")).
- **큰 숫자:** NumberFormatter K/M/B.

## 코드 구조
```
Assets/Scripts/
  Core/       — GameManager, SpiralManager, PlayerState, PermanentUpgradeManager,
                AchievementManager, CompanionDokkaebi, SaveSystem, ShopManager,
                EventManager, LocalizationManager, NumberFormatter, GameBootstrap,
                WaveUpgradeManager, TutorialManager, DestinySystem, GreedScale,
                DokkaebiSealSystem
  Cards/      — HwaTuCard, HwaTuCardDatabase, CardInstance, CardEnhancement,
                DeckManager, MatchingEngine, ScoringEngine, GoStopDecision
  Combat/     — RoundManager, BossManager, BossGenerator, BossParts, BossData,
                BossDatabase, BossBattle
  Talismans/  — Talisman, TalismanInstance, TalismanManager, TalismanDatabase
  UI/         — MockupSceneBuilder, MockupSpriteFactory, GameUIManager, CardUI,
                GameEffects
Assets/Tests/ — 12개 테스트 파일

dokkaebi-love2d/        (Love2D 프로토타입)
  src/core/     — sfx.lua, bgm.lua, player_state.lua, spiral_manager.lua, number_formatter.lua
  src/cards/    — deck_manager.lua, hand_evaluator.lua, card_enums.lua
  src/combat/   — seotda_challenge.lua, boss_data.lua, boss_battle.lua
  src/talismans/ — talisman_data.lua, talisman_database.lua, talisman_manager.lua
  src/ui/       — card_renderer.lua, button.lua, draw_utils.lua, effects.lua,
                  icon_generator.lua, yokbo_guide.lua
  assets/bgm/   — 5 CC0 BGM tracks
  assets/fonts/ — Pretendard fonts
```

## 개발 원칙
1. **docs/ 먼저 확인:** 코드 수정 전 관련 설계 문서 필독.
2. **문서와 코드 동기화:** 코드 변경 시 docs/*.md 함께 업데이트.
3. **고스톱 용어 유지:** 고/스톱/판/먹다/쓸/쪽 등 고스톱 원래 말 그대로.
4. **저승 세계관:** 게임 시스템 용어는 저승/도깨비 분위기로.
5. **마우스/터치만:** 키보드 입력 절대 추가 안 함.
6. **오프라인:** 네트워크 호출 절대 추가 안 함.
7. **다국어:** 하드코딩 텍스트 금지. L.Get("key") 필수.
8. **큰 숫자:** 점수/배수/엽전 표시 시 NumberFormatter.
9. **테스트:** 핵심 로직 변경 시 테스트 추가/수정.

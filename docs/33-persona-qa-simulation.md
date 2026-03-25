# 도깨비의 패 — 페르소나 QA 시뮬레이션

> 4종의 플레이어 페르소나가 게임을 처음부터 끝까지 플레이하며 버그, 밸런스, UX 문제를 발견하는 문서.

---

## 페르소나 정의

### P1. 김초보 (초심자)
- **프로필:** 게임 경험 적음, 고스톱 규칙 모름, 튜토리얼에 의존
- **플레이 스타일:** 아무 카드나 누름, Go를 잘 안 함, 부적 시스템 무시
- **검증 목표:** 기본 흐름이 끊기지 않는가, 막히는 구간이 없는가

### P2. 이전략 (전략 플레이어)
- **프로필:** 로그라이트 마니아(Balatro, StS 경험), 고스톱 규칙 숙지
- **플레이 스타일:** 시너지 극대화, Go 3회 도전, 부적 빌드 중시
- **검증 목표:** 시너지 스택, Go 리스크/리워드, 데미지 계산 정합성

### P3. 박탐욕 (극한 도전자)
- **프로필:** 무한 모드 전문, 최고 기록 추구
- **플레이 스타일:** 연속 Go, 최대 배수 추구, 윤회 10+ 진행
- **검증 목표:** 오버플로우, 극한 밸런스, 무한 루프 가능성

### P4. 최세이브 (세이브/로드 테스터)
- **프로필:** 게임을 수시로 껐다 킴, 세이브 의존
- **플레이 스타일:** 매 관문마다 세이브/로드 반복
- **검증 목표:** 세이브 데이터 무결성, 상태 복원 정확성

---

## 시뮬레이션 1: 김초보 — 첫 플레이

### 세션 1-1: 게임 시작 ~ 1관문

```
[MainMenu] → "새 게임" 클릭
  → [SpiralStart] 축복 선택 화면
    김초보: "뭔지 모르겠고... 아무거나" → 업화(칩 +20%) 선택

[StartNewGame]
  Lives: 3, Yeop: 100냥
  사주팔자 랜덤 생성

[BeginSpiralWithBlessing("fire")]
  → [StartNextRealm] 보스 생성 (랜덤)
    예시: 먹보 도깨비 (HP: 3,000)
    "크하하! 네 패에서 맛있는 냄새가 나는구나!"

[StartNextRound]
  라운드 1, 손패 10장 배분
```

**시뮬레이션:**

```
Phase: SelectCards
  김초보: 아무 카드 1장 선택 → "내기!" 클릭
  SubmitCards([1월 피])
    → HandEvaluator: "single" 콤보 발동 (D등급, 5칩, 1.0배)
    → AccumulatedCombos: 1개 → GoStopChoice 진입 ✓

Phase: GoStopChoice
  김초보: "스톱이 뭔지 모르겠는데... 스톱 눌러야지"
  SelectStop()
    → AttackSelect 전환 ✓
    "스톱! 공격할 2장을 골라라!"

Phase: AttackSelect
  김초보: 아무 2장 선택 (2월 피 + 8월 피)
  SeotdaAttack(2월피, 8월피)
    → SeotdaChallenge.Evaluate: 2+8=10 → 0끗 → 갑오 (Rank 0)
    → baseDamage = 3
    → finalDamage = (3 + 5) × 1.0 × 1.0 = 8
    → 보스 HP: 3000 → 2992

Phase: RoundEnd → HandleRoundEnded(won=true)
  보스 살아있음 → 반격
  HP비율 99.7% → LightAttack → 조롱 "크하하! 배고프다~"
  → PostRound
```

**발견 사항:**
- ✅ 기본 흐름 정상 작동
- ⚠️ **UX 문제:** 데미지 8로 보스 HP 3000을 깎아야 함 → 초보자에게 375판 필요
- 💡 **밸런스 제안:** 시너지 없는 갑오 공격이 너무 약함. 최소 데미지 보장 or 초보 가이드 필요

```
Round 2:
  김초보: 또 1장만 선택 → 내기 → 스톱 → 공격
  결과: 비슷한 데미지 (5~15)

  ... 10라운드 반복 후에도 보스 HP 2900 ...

  김초보: "이거 언제 끝나...?"
```

**발견 사항:**
- ⚠️ **밸런스 이슈 — BUG-27:** `TotalRoundsInRealm` (보스 라운드 수 3)이 있지만 `CurrentRoundInRealm`이 `TotalRoundsInRealm`을 초과해도 강제 종료 메커니즘 없음. 무한 라운드 가능.
- **코드 확인:** `GameManager.StartNextRound()`에서 `CurrentRoundInRealm++`만 하고 상한 체크 없음
- **영향:** 초보자가 영원히 같은 보스와 싸우게 됨

```csharp
// GameManager.cs:243 — 현재 코드
public void StartNextRound()
{
    CurrentRoundInRealm++;
    // ❌ TotalRoundsInRealm 초과 시 강제 종료 없음
    ...
}
```

---

### 세션 1-2: 이벤트 & 상점

```
(보스 격파 후)
[PostRound] → 웨이브 강화 3택
  김초보: "치유" 선택 (+2 Lives)
  Lives: 3 → 5

[Shop] 상점 진입
  아이템: 피의 맹세(30냥), 도깨비 방망이(40냥), 체력 회복(75냥)

  김초보: "체력 회복 사자" → 75냥 지불 → Lives 5→6
  Yeop: 100+50(보상) - 75 = 75냥

[LeaveShop]
  CurrentRealm: 2 (짝수) → 이벤트 발생!

[Event] "저승 방랑자"
  김초보: "도와준다" → +50냥
  Yeop: 75 + 50 = 125냥

[LeaveEvent] → StartNextRealm
  2관문 보스 등장!
```

**발견 사항:**
- ✅ 상점 → 이벤트 → 다음 관문 전환 정상
- ✅ 엽전 계산 정상
- ✅ 체력 캡 MaxLives(10) 정상 적용 (이전 버그 수정됨)

---

## 시뮬레이션 2: 이전략 — 시너지 빌드 플레이

### 세션 2-1: 시너지 극대화 전략

```
[SpiralStart] 빙결 선택 (배수 +1, 매 라운드 손패 -1)

1관문: 장난꾸러기 도깨비 (HP: 3,750)

Round 1:
  손패: 10 - 1(빙결 패널티) = 9장

Phase: SelectCards
  이전략: 홍단 3장 세트 선택 (1월홍, 2월홍, 3월홍)
  SubmitCards([1월홍단, 2월홍단, 3월홍단])
    → HandEvaluator:
      - "hongdan" (B등급, 100칩, 2.0배) ✓
      - "monthpair_1" (1월 쌍, 20칩) — 해당 안 됨 (다른 월)
      - "single" × 3 → 이미 더 높은 콤보 있으므로 무시?

  ⚠️ 체크: 카드 3장 제출 → 남은 6장 (공격 2장 + 4장 여유)
  AccumulatedChips: 100, AccumulatedMult: 2.0
  PlaysUsed: 1, MaxPlays: 4
  AccumulatedCombos.Count > 0 → GoStopChoice ✓

Phase: GoStopChoice
  이전략: "Go! 시너지 더 쌓자"
  SelectGo()
    GoCount: 1, +3장 드로우 → 손패: 6+3 = 9장
    bossDamage: 5 → Yeop -5냥

Phase: SelectCards (다시)
  이전략: 청단 2장 선택 (6월청, 9월청)
  SubmitCards([6월청단, 9월청단])
    → 2장 콤보 판정
    AccumulatedChips: 100 + 60 = 160
    AccumulatedMult: 2.0 × 1.5 = 3.0
    PlaysUsed: 2

  이전략: "스톱!"
  SelectStop() → AttackSelect

Phase: AttackSelect
  이전략: 남은 패에서 최고 족보 선택
  손패 중 3월 광 + 8월 광 발견!
  SeotdaAttack(3월광, 8월광)
    → 38광땡! (Rank 100)
    → baseDamage = 80
    → finalDamage = (80 + 160) × 3.0 × 2.0(Go1) = 1,440!
    → 보스 HP: 3750 → 2310

  "38광땡으로 1440 타격!!"
```

**발견 사항:**
- ✅ 시너지 스택 정상 (칩 누적 + 배수 곱셈)
- ✅ Go 배수 정상 적용
- ✅ 38광땡 판정 정상
- ✅ 축복(빙결) 손패 패널티 정상 적용

### 세션 2-2: Go 3 극한 도전

```
Round 2:
  이전략: Go 3회 도전!

  내기 1 → Go 1 (+3장, 보스 5dmg)
  내기 2 → Go 2 (+2장, 보스 15dmg)
  내기 3 → Go 3 (+1장, 보스 30dmg, 즉사 위험!)

  ApplyGoDamage(30):
    Yeop -= 30 → 부족하면 0
    GoCount >= 3 → 즉사 판정!
    deathChance: 20%
    주사위: 0.85 → 즉사 미발동 ✓

  내기 4 (MaxPlays=4 도달) → AttackSelect 강제

  이전략: 장땡(10월 × 2) 공격!
  baseDamage = 50
  finalDamage = (50 + 300) × 5.0 × 10.0(Go3) = 17,500!

  보스 HP: 2310 → 0 → 격파!
```

**발견 사항:**
- ✅ Go 3 즉사 판정 정상
- ✅ Go 3 배수 ×10 정상
- ✅ MaxPlays 도달 시 AttackSelect 강제 전환 정상
- ⚠️ **밸런스 관찰:** Go 3 성공 시 데미지가 17,500으로 폭발적. 1관문 보스를 한 방에 처리 가능. 의도된 설계인지 확인 필요.

---

## 시뮬레이션 3: 박탐욕 — 무한 윤회 극한 도전

### 세션 3-1: 윤회 1 전체 돌파

```
윤회 1, 축복: 공허(부적 효과 2배, 슬롯 -2)
  → 부적 슬롯: 5 - 2 = 3칸

관문 1~9: 랜덤 보스 연속 격파
  전략: 매 관문 Go 2~3 → 고배수 공격
  웨이브 강화: 칩+20, 배수+1, 부적슬롯+1 반복
  상점: 전설 부적 구매 (저승사자의 명부: 4로 끝나면 ×4)

관문 10: 염라대왕 (HP: 6,000, 광 무효화)
  BossGimmick.NoBright → 광 카드 사용 불가
  이 보스에서는 38광땡 같은 광 조합 사용 불가!
```

**발견 사항:**
- ⚠️ **BUG-28:** `BossManager.IsGwangDisabled()`가 `true`를 반환하지만, `RoundManager.ExecuteAttack()`에서 이를 체크하지 않음. 플레이어가 광 카드로 공격 가능.

```csharp
// BossManager.cs:120-123
public bool IsGwangDisabled()
{
    return _currentBoss != null && _currentBoss.Gimmick == BossGimmick.NoBright;
}
// ❌ 이 값을 체크하는 곳이 없음!
// RoundManager.ExecuteAttack, HandEvaluator 어디에도 광 무효화 로직 없음
```

```
관문 10 클리어 → Gate 출현!
  "이승의 문을 통과합니다..."
  박탐욕: "계속 간다" → ContinueAfterGate()
    → 윤회 2 진입
    Soul Fragments 보상: 100 (윤회 1 완료)
```

### 세션 3-2: 윤회 3 재앙 보스

```
윤회 3, 관문 10: 백골대장 (HP: 112,500, Skullify)
  TargetScore 5000 × 15 × (1 + 0.5 × 2) = 150,000

  Round 1:
    턴 시작 → BossManager.OnTurnStart → Skullify 발동
    손패 랜덤 1장 → 해골로 변환 → 제거
    _skullCount: 1

  Round 2:
    _skullCount: 2
    "2/3... 위험해!"

  Round 3:
    _skullCount: 3 → 즉사!
    player.Lives = 0 → OnPlayerKilled 발동
    → HandlePlayerKilled() → GameState.GameOver ✓ (BUG-01 수정 확인)
```

**발견 사항:**
- ✅ BUG-01 수정 검증: 백골대장 즉사 → GameOver 정상 전환

### 세션 3-3: 윤회 10+ 극한 데미지

```
윤회 10, 관문 5
  WaveChipBonus: +200 (10 × 20)
  WaveMultBonus: +10 (10 × 1)
  부적: 염라왕의 도장(×3), 지옥불꽃(×2), 공허(×2배 효과)

  Go 3 성공:
    AccumulatedChips: 500 + 200(wave) = 700
    AccumulatedMult: 15.0 × 3(도장) × 2(불꽃) = 90.0
    goMult: 10.0
    baseDamage: 80 (38광땡)

    rawDamage = (80 + 700) × 90.0 × 10.0 = 702,000
    → long으로 계산 → int 클램프 ✓ (BUG-19 수정 확인)
```

**발견 사항:**
- ✅ BUG-19 수정 검증: 오버플로우 방지 정상
- ⚠️ **밸런스 관찰:** 윤회 10에서 데미지 70만+. 보스 HP는 `5000 × 15 × 5.5 = 412,500`. 한 방 킬 가능. 의도된 파워 커브인지 확인 필요.

---

## 시뮬레이션 4: 최세이브 — 세이브/로드 스트레스 테스트

### 세션 4-1: 기본 세이브/로드

```
윤회 1, 관문 5, 축복: 빙결
  Lives: 5, Yeop: 230, 부적 3개 장착

[Save]
  SaveManager.Save(data)
    → data.Timestamp = 현재시간
    → _localBackend.Save(RunSaveKey, json) ✓ (BUG-20 수정됨)
    → _steamBackend.Save(RunSaveKey, json) ✓

[게임 종료 → 재시작]

[Load]
  SaveManager.Load()
    → localJson = _localBackend.Load(RunSaveKey) ✓
    → steamJson = _steamBackend.Load(RunSaveKey) ✓
    → Timestamp 비교 → 더 최신 것 사용

  GameManager.LoadFromSave(data):
    _spiral.LoadFromSave(data.Spiral)
      → CurrentSpiral: 1, CurrentRealm: 5
      → ActiveBlessing: "ice" 복원 ✓ (BUG-08 수정됨)

    player.Lives: 5, Yeop: 230
    부적 3개 복원
```

**발견 사항:**
- ✅ BUG-08 수정 검증: 축복 정상 복원
- ✅ BUG-20 수정 검증: RunSaveKey 사용
- ⚠️ **BUG-29:** `LoadFromSave()` 후 `StartNextRealm()` 호출 시 새 보스가 생성되지만, 이전 보스의 HP 상태(부분 데미지)가 복원되지 않음. `BossBattle` 인스턴스가 세이브에 포함 안 됨.

```csharp
// GameManager.cs:606-611 — LoadFromSave
public void LoadFromSave(SaveData data)
{
    _spiral.LoadFromSave(data.Spiral);
    _player.Lives = data.Lives;
    // ...
    // ❌ CurrentBattle (보스 HP 상태) 복원 없음!
    // ❌ CurrentBoss (현재 보스 데이터) 복원 없음!
}
```

### 세션 4-2: 이벤트 중 세이브/로드

```
[Event] 상태에서 세이브 → 로드
  → LoadFromSave → StartNextRealm
  → 이벤트 선택 안 한 상태로 다음 보스 생성
  → 이벤트 스킵됨!
```

**발견 사항:**
- ⚠️ **BUG-30:** 이벤트/상점 중간 상태가 세이브에 미포함. 로드 시 해당 단계가 스킵됨.

---

## 발견된 신규 버그 요약

| ID | 심각도 | 페르소나 | 설명 |
|----|--------|----------|------|
| **BUG-27** | HIGH | P1(김초보) | 라운드 수가 TotalRoundsInRealm 초과해도 강제 종료 없음 → 무한 라운드 |
| **BUG-28** | HIGH | P3(박탐욕) | 염라대왕 NoBright 기믹이 실제로 광 카드를 차단하지 않음 |
| **BUG-29** | MEDIUM | P4(최세이브) | 보스 HP 상태가 세이브에 미포함 → 로드 시 풀HP로 리셋 |
| **BUG-30** | LOW | P4(최세이브) | 이벤트/상점 진행 중 세이브 → 로드 시 해당 단계 스킵 |

---

## 밸런스 패치 (적용됨)

### 변경 전 vs 변경 후

| 항목 | 변경 전 | 변경 후 | 이유 |
|------|---------|---------|------|
| 보스 HP 공식 | `TargetScore × 15` | `TargetScore × 3` | 초보도 2~3판이면 격파 |
| 1관문 먹보 TargetScore | 200 (HP 3,000) | 120 (HP 360) | 첫 보스가 벽이면 이탈 |
| 2관문 장난꾸러기 TargetScore | 250 (HP 3,750) | 140 (HP 420) | 점진적 난이도 상승 |
| 3관문 불꽃 TargetScore | 300 (HP 4,500) | 180 (HP 540) | 3관문까지는 입문 구간 |
| 1관문 기믹 간격 | 매 턴 | 2턴마다 | 첫 보스 기믹이 너무 빈번 |
| 섯다 최저 데미지 (갑오) | 3 | 10 | 최약 공격도 의미 있게 |
| 섯다 중간 데미지 (세륙) | 20 | 35 | 일반 족보 위력 상향 |
| 섯다 최고 데미지 (38광땡) | 80 | 150 | 대박 족보의 쾌감 |
| 시작 체력 | 3 | 5 | 실수 여유 확보 |
| 시작 엽전 | 100냥 | 150냥 | 첫 상점에서 부적 + 소모품 구매 가능 |
| Go 3 즉사 확률 | 20% | 10% | 극한 도전의 리스크는 유지하되 완화 |
| 보스 광분 목숨 감소 | 30% | 15% | 운 나쁘면 연속 사망 방지 |
| 내기 횟수 | 4회 | 5회 | 시너지 쌓을 기회 추가 |
| 단일패 콤보 칩 | BasePoints(1~20) | 최소 10 보장 | 피 1장도 10칩 |

### 김초보 재시뮬레이션 (패치 후)

```
1관문: 먹보 도깨비 (HP: 360)

Round 1:
  1장 내기 (단일패) → 10칩 × 1.0배
  스톱 → 공격: 2월피 + 8월피 = 갑오
  baseDamage = 10, finalDamage = (10 + 10) × 1.0 × 1.0 = 20
  보스 HP: 360 → 340

Round 2:
  2장 내기 (같은 월 쌍) → 30칩 × 1.2배
  스톱 → 공격: 1월피 + 2월피 = 알리(55dmg)
  finalDamage = (55 + 30) × 1.2 × 1.0 = 102
  보스 HP: 340 → 238

Round 3:
  3장 내기 (홍단 세트) → 100칩 × 2.0배
  스톱 → 공격: 3월광 + 8월광 = 38광땡(150dmg)
  finalDamage = (150 + 100) × 2.0 × 1.0 = 500
  보스 HP: 238 → 0 → 격파!

→ 3판 만에 보스 격파! 초보도 충분히 가능!
```

**결과:** 김초보가 시너지를 조금이라도 쌓으면 2~3판이면 격파. 시너지 없이도 5~6판이면 가능.

---

## 테스트 커버리지 매트릭스

| 게임 흐름 | P1 | P2 | P3 | P4 |
|-----------|:--:|:--:|:--:|:--:|
| 게임 시작 ~ 첫 전투 | ✅ | ✅ | ✅ | - |
| 시너지 페이즈 (1장) | ✅ | - | - | - |
| 시너지 페이즈 (3장+) | - | ✅ | ✅ | - |
| Go 1회 | - | ✅ | ✅ | - |
| Go 3회 + 즉사 판정 | - | ✅ | ✅ | - |
| 38광땡 공격 | - | ✅ | ✅ | - |
| 갑오(최약) 공격 | ✅ | - | - | - |
| 보스 격파 | - | ✅ | ✅ | - |
| 보스 반격 (경/강/광분) | ✅ | ✅ | ✅ | - |
| 웨이브 강화 선택 | ✅ | ✅ | ✅ | - |
| 상점 구매 | ✅ | ✅ | - | - |
| 이벤트 선택 | ✅ | - | - | ✅ |
| 10관문 → 이승의 문 | - | - | ✅ | - |
| 다음 윤회 진입 | - | - | ✅ | - |
| 재앙 보스 (백골대장) | - | - | ✅ | - |
| 세이브/로드 | - | - | - | ✅ |
| 축복 효과 | ✅ | ✅ | ✅ | ✅ |
| 부적 빌드 | - | ✅ | ✅ | - |
| 윤회 10+ 극한 | - | - | ✅ | - |

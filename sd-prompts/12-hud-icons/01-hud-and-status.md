# HUD 아이콘 & 상태 표시 요소

> 게임 플레이 중 **항상 화면에 보이는** HUD(Head-Up Display) 요소들.
> 목숨, 덱, 손패 수, 턴, 라운드, 페이즈, 탐욕도 등.

## 생성 환경

```yaml
Model: Flux-dev (ComfyUI)
Resolution: 192 x 192 (→ 다운스케일 48x48, 4배) — 아이콘류
           또는 용도별 상이 (아래 참조) — 게이지/바류
Steps: 20~25
Guidance: 3.5
Batch: 4장
```

## 공통 프롬프트 프리픽스

```
A single pixel art HUD icon in the style of The Binding of Isaac. One simple recognizable object centered on a plain solid bright green (#00FF00) chroma key background. 16-bit retro pixel art with crisp sharp pixels, no anti-aliasing, no gradients. Bold thick black outlines. Flat color fill only. The object floats in empty space with no ground, no shadow, no pedestal, no decorative elements. Extremely simple silhouette — must be readable at very small sizes. Square 1:1 composition. Only the icon, nothing else.
```

## 후처리

```
1. 배경 제거 → 투명 알파
2. Nearest Neighbor 다운스케일 → 목적 크기
3. PNG (알파) → Assets/Art/UI/HUD/
```

---

## 1. 생명력 아이콘 — 3종

### hud_life_full — 목숨 (가득)
**Seed:** 85001 | **크기:** 192x192 (→48x48)

```
A small pixel art heart icon representing one life point — full and healthy. The heart is vivid blood red with a bold black outline. A tiny bright highlight spot on the upper-left suggests a healthy shiny surface. Simple classic heart shape. This is the player's life counter icon when HP is available.
```

### hud_life_empty — 목숨 (빈)
**Seed:** 85002 | **크기:** 192x192 (→48x48)

```
A small pixel art heart icon representing a lost life point — empty and dark. The same heart shape but filled with dark gray instead of red. The outline is still black but thinner and duller. A small crack runs across the surface. This is the life counter icon when HP has been lost.
```

### hud_life_danger — 목숨 (위험 — 마지막 1개)
**Seed:** 85003 | **크기:** 192x192 (→48x48)

```
A small pixel art heart icon pulsing with danger — the last remaining life. The heart is vivid red but flickering with a bright white-red glow around it. Small urgency lines radiate outward from the heart. The heart appears to be beating intensely. This icon signals "last chance — one more hit and you're dead."
```

---

## 2. 카드 관련 HUD 아이콘 — 4종

### hud_deck — 덱 아이콘
**Seed:** 85011 | **크기:** 192x192 (→48x48)

```
A small pixel art icon of a stack of hwatu cards seen from the side. Three or four cards stacked neatly, showing their dark navy card backs with a faint gold trim line. The stack is slightly fanned to show depth. This represents the remaining draw deck during gameplay.
```

### hud_hand — 손패 수 아이콘
**Seed:** 85012 | **크기:** 192x192 (→48x48)

```
A small pixel art icon of a hand of cards spread in a fan shape. Three cards fanned outward, showing their colorful front sides (cream with faint red/blue marks). A small open hand silhouette holds them from below. This represents the player's current hand card count.
```

### hud_captured — 먹은 패 아이콘
**Seed:** 85013 | **크기:** 192x192 (→48x48)

```
A small pixel art icon of a pile of captured/collected cards. Several cards stacked messily in a pile, slightly overlapping. The cards show various colors (red, blue, gold hints) from their front sides. This represents the player's captured card collection during a round.
```

### hud_field — 바닥패 아이콘
**Seed:** 85014 | **크기:** 192x192 (→48x48)

```
A small pixel art icon of cards laid out flat on a surface. Three cards placed face-up in a row on a dark surface, showing their fronts. This represents the field/table cards available for matching.
```

---

## 3. 게임 진행 아이콘 — 4종

### hud_turn — 턴 카운터 아이콘
**Seed:** 85021 | **크기:** 192x192 (→48x48)

```
A small pixel art hourglass icon. A traditional hourglass shape with dark navy frame and golden sand flowing from top to bottom. The sand glows faintly gold. This represents the current turn number during gameplay.
```

### hud_round — 라운드 카운터 아이콘
**Seed:** 85022 | **크기:** 192x192 (→48x48)

```
A small pixel art circular badge icon representing the current round/판. A dark navy circle with a gold border and a small traditional Korean pattern inside. A number would overlay on top. This represents "which 판 (round) are you in?"
```

### hud_spiral — 윤회 카운터 아이콘
**Seed:** 85023 | **크기:** 192x192 (→48x48)

```
A small pixel art spiral/ouroboros icon. A circular spiral pattern in ghost fire cyan, suggesting the cycle of death and rebirth. The spiral turns inward, representing the endless loop of reincarnation. This represents the current spiral/윤회 number.
```

### hud_floor — 관문 카운터 아이콘
**Seed:** 85024 | **크기:** 192x192 (→48x48)

```
A small pixel art gate/torii icon. A simple dark stone gate arch shape — the traditional Korean gateway to the next realm. A faint light shines through the gate opening. This represents the current floor/관문 number within a spiral.
```

---

## 4. 탐욕 게이지 (Greed Scale)
**Seed:** 85031 | **크기:** 600x48 (가로로 길고 얇은 바)

```
A pixel art horizontal gauge bar frame for the greed scale. The bar frame is dark navy with thin gold border. The left end has a small calm blue icon (safety/stop). The right end has a small aggressive red icon (danger/greed). Between them, the bar interior shows a gradient zone divided into segments — from cool blue on the left through neutral in the center to hot red on the right. Tick marks divide the bar into sections. The actual fill level will be overlaid in code, but the frame and background gradient should be pre-rendered. This represents how much greed/risk the player has accumulated. Wide horizontal format.
```

---

## 5. 부적 슬롯 프레임
**Seed:** 85041 | **크기:** 192x192 (→64x64)

### hud_talisman_slot — 부적 슬롯 (빈)

```
A pixel art empty talisman equipment slot frame. A square frame with dark navy interior and thin gold border. A faint talisman paper outline shape is barely visible in the center — suggesting where a talisman would go. Small corner brackets in gold at each corner. The slot looks empty and waiting to be filled. This is the frame behind each talisman icon in the talisman bar.
```

### hud_talisman_slot_active — 부적 슬롯 (활성)
**Seed:** 85042 | **크기:** 192x192 (→64x64)

```
A pixel art active talisman equipment slot frame. Same square frame but with a brighter cyan (#00D4FF) border glow — the talisman in this slot just triggered its effect. Small energy particles at the corners. The slot is highlighted and active. This frame shows when a talisman activates during gameplay.
```

### hud_talisman_slot_cursed — 부적 슬롯 (저주)
**Seed:** 85043 | **크기:** 192x192 (→64x64)

```
A pixel art cursed talisman slot frame. Same square frame but with a sinister dark purple (#6B2D5B) border and small chain links crossing over the slot — the talisman cannot be removed. Dark wisps leak from the slot edges. The slot is locked by a curse. This indicates a forced-equipped cursed talisman.
```

---

## 6. 동료 슬롯 프레임
**Seed:** 85051 | **크기:** 192x192 (→64x64)

### hud_companion_slot — 동료 슬롯 (빈)

```
A pixel art empty companion dokkaebi slot frame. A circular frame with dark navy interior and thin gold border. A faint dokkaebi horn silhouette is visible in the center — suggesting where a companion portrait would go. The circle has a small cooldown indicator arc at the bottom. Empty and waiting for a tamed dokkaebi.
```

### hud_companion_ready — 동료 슬롯 (스킬 준비됨)
**Seed:** 85052 | **크기:** 192x192 (→64x64)

```
A pixel art companion slot frame with skill ready indicator. Same circular frame but with a ghost fire cyan (#00D4FF) pulsing border glow — the companion's ability is ready to use. A small exclamation mark or star appears at the top of the circle. The slot is energized and ready for activation.
```

---

## 7. 기믹 경고 아이콘
**Seed:** 85061 | **크기:** 192x192 (→48x48)

```
A pixel art warning icon for boss gimmick activation. A triangular warning sign shape in blood red with a dark exclamation mark in the center. The triangle has a thin gold border. Small danger lines radiate from the triangle corners. This icon flashes on screen when a boss gimmick is about to activate — a universal "danger incoming" symbol.
```

---

## 8. 점수 표시 프레임 — 칩/배수/합계

### hud_chip_frame — 칩 표시
**Seed:** 85071 | **크기:** 256x80

```
A pixel art horizontal score display frame for chip count. A small wide panel with dark navy background and gold border. A small chip/coin icon on the left side. The rest is open for the number display. Gold color theme — chips are the base score currency. Transparent areas around the frame.
```

### hud_mult_frame — 배수 표시
**Seed:** 85072 | **크기:** 256x80

```
A pixel art horizontal score display frame for multiplier count. Same shape as chip frame but with blood red accent coloring instead of gold. A small "×" multiplication symbol icon on the left side in red. The rest is open for the number. Red color theme — the multiplier amplifies danger and reward.
```

### hud_total_frame — 합계 표시
**Seed:** 85073 | **크기:** 256x80

```
A pixel art horizontal score display frame for total damage/score. Wider and more prominent than chip or mult frames. Dark navy background with brilliant gold border and a subtle golden inner glow. A small sword/impact icon on the left side. The rest is open for the final calculated number. This is the "bottom line" — the actual damage dealt to the boss.
```

---

## 요약

| 카테고리 | 수량 | 크기 |
|----------|------|------|
| 생명력 아이콘 | 3 | 48x48 |
| 카드 HUD 아이콘 | 4 | 48x48 |
| 게임 진행 아이콘 | 4 | 48x48 |
| 탐욕 게이지 | 1 | 600x48 |
| 부적 슬롯 프레임 | 3 | 64x64 |
| 동료 슬롯 프레임 | 2 | 64x64 |
| 기믹 경고 아이콘 | 1 | 48x48 |
| 점수 표시 프레임 | 3 | 256x80 |
| **합계** | **21** | |

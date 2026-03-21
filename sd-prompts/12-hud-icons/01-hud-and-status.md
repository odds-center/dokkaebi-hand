# HUD 아이콘 & 상태 표시 요소

> 게임 플레이 중 **항상 화면에 보이는** HUD(Head-Up Display) 요소들.
> 목숨, 덱, 손패 수, 턴, 라운드, 페이즈, 탐욕도 등.

## 생성 환경

```yaml
Model: Pony Diffusion V6 XL (ComfyUI)
LoRA: Binding of Isaac Style v2.1 (strength 0.80)
Resolution: 192 x 192 (→ 다운스케일 48x48, 4배) — 아이콘류
           또는 용도별 상이 (아래 참조) — 게이지/바류
Sampler: euler_a
Steps: 25~30
CFG: 7
Batch: 4장
```

## 공통 프롬프트 프리픽스

```
score_9, score_8_up, score_7_up, pixel art, game assets, chibi, simple green background, HUD icon, Binding of Isaac style, 32x32 pixel grid, blocky jagged edges, no smooth curves, no anti-aliasing, flat colors, thick black outlines, one simple recognizable object, chroma key green background, no ground, no shadow, no pedestal, extremely simple silhouette, fully contained with margins
```

## 공통 네거티브 프롬프트

```
score_4, score_3, score_2, score_1, blurry, photo, realistic, 3d render, smooth shading, anti-aliasing, gradient, soft edges, watercolor, text, watermark, signature
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
small heart icon, one life point full and healthy, vivid blood red, tiny bright highlight spot upper-left, healthy shiny surface, simple classic heart shape, life counter icon HP available
```

### hud_life_empty — 목숨 (빈)
**Seed:** 85002 | **크기:** 192x192 (→48x48)

```
small heart icon, lost life point empty and dark, same heart shape filled dark gray instead of red, thinner duller outline, small crack across surface, life counter icon HP lost
```

### hud_life_danger — 목숨 (위험 — 마지막 1개)
**Seed:** 85003 | **크기:** 192x192 (→48x48)

```
small heart icon pulsing with danger, last remaining life, vivid red flickering bright white-red glow around it, small urgency lines radiating outward, heart beating intensely, last chance one more hit dead signal
```

---

## 2. 카드 관련 HUD 아이콘 — 4종

### hud_deck — 덱 아이콘
**Seed:** 85011 | **크기:** 192x192 (→48x48)

```
small icon of stacked hwatu cards from side, three or four cards stacked neatly, dark navy card backs faint gold trim line, stack slightly fanned for depth, remaining draw deck icon
```

### hud_hand — 손패 수 아이콘
**Seed:** 85012 | **크기:** 192x192 (→48x48)

```
small icon of hand of cards in fan shape, three cards fanned outward, colorful front sides cream with faint red blue marks, small open hand silhouette holding from below, player hand card count icon
```

### hud_captured — 먹은 패 아이콘
**Seed:** 85013 | **크기:** 192x192 (→48x48)

```
small icon of pile of captured collected cards, several cards stacked messily overlapping, various colors red blue gold hints from fronts, player captured card collection icon
```

### hud_field — 바닥패 아이콘
**Seed:** 85014 | **크기:** 192x192 (→48x48)

```
small icon of cards laid flat on surface, three cards face-up in row on dark surface, showing fronts, field table cards for matching icon
```

---

## 3. 게임 진행 아이콘 — 4종

### hud_turn — 턴 카운터 아이콘
**Seed:** 85021 | **크기:** 192x192 (→48x48)

```
small hourglass icon, traditional hourglass shape, dark navy frame, golden sand flowing top to bottom, sand glows faintly gold, current turn number icon
```

### hud_round — 라운드 카운터 아이콘
**Seed:** 85022 | **크기:** 192x192 (→48x48)

```
small circular badge icon, current round counter, dark navy circle gold border, small traditional Korean pattern inside, number overlay on top, which round you are in icon
```

### hud_spiral — 윤회 카운터 아이콘
**Seed:** 85023 | **크기:** 192x192 (→48x48)

```
small spiral ouroboros icon, circular spiral pattern in ghost fire cyan, cycle of death and rebirth, spiral turning inward, endless loop of reincarnation, current spiral number icon
```

### hud_floor — 관문 카운터 아이콘
**Seed:** 85024 | **크기:** 192x192 (→48x48)

```
small gate torii icon, simple dark stone gate arch shape, traditional Korean gateway to next realm, faint light through gate opening, current floor number icon
```

---

## 4. 탐욕 게이지 (Greed Scale)
**Seed:** 85031 | **크기:** 600x48 (가로로 길고 얇은 바)

```
horizontal gauge bar frame for greed scale, dark navy frame thin gold border, left end small calm blue icon safety stop, right end small aggressive red icon danger greed, bar interior gradient zone divided into segments, cool blue left neutral center hot red right, tick marks dividing bar into sections, fill level overlaid in code, greed risk accumulation indicator, wide horizontal format
```

---

## 5. 부적 슬롯 프레임
**Seed:** 85041 | **크기:** 192x192 (→64x64)

### hud_talisman_slot — 부적 슬롯 (빈)

```
empty talisman equipment slot frame, square frame dark navy interior thin gold border, faint talisman paper outline in center suggesting placement, small corner brackets in gold at each corner, empty waiting to be filled, frame behind talisman icon in talisman bar
```

### hud_talisman_slot_active — 부적 슬롯 (활성)
**Seed:** 85042 | **크기:** 192x192 (→64x64)

```
active talisman equipment slot frame, same square frame, brighter cyan #00D4FF border glow, talisman just triggered its effect, small energy particles at corners, highlighted active slot
```

### hud_talisman_slot_cursed — 부적 슬롯 (저주)
**Seed:** 85043 | **크기:** 192x192 (→64x64)

```
cursed talisman slot frame, same square frame, sinister dark purple #6B2D5B border, small chain links crossing over slot talisman cannot be removed, dark wisps from slot edges, locked by curse, forced-equipped cursed talisman indicator
```

---

## 6. 동료 슬롯 프레임
**Seed:** 85051 | **크기:** 192x192 (→64x64)

### hud_companion_slot — 동료 슬롯 (빈)

```
empty companion dokkaebi slot frame, circular frame dark navy interior thin gold border, faint dokkaebi horn silhouette in center suggesting companion portrait, small cooldown indicator arc at bottom, empty waiting for tamed dokkaebi
```

### hud_companion_ready — 동료 슬롯 (스킬 준비됨)
**Seed:** 85052 | **크기:** 192x192 (→64x64)

```
companion slot frame skill ready indicator, same circular frame, ghost fire cyan #00D4FF pulsing border glow, companion ability ready to use, small exclamation mark or star at top of circle, energized ready for activation
```

---

## 7. 기믹 경고 아이콘
**Seed:** 85061 | **크기:** 192x192 (→48x48)

```
warning icon for boss gimmick activation, triangular warning sign in blood red, dark exclamation mark in center, thin gold border, small danger lines from triangle corners, flashes when boss gimmick about to activate, universal danger incoming symbol
```

---

## 8. 점수 표시 프레임 — 칩/배수/합계

### hud_chip_frame — 칩 표시
**Seed:** 85071 | **크기:** 256x80

```
horizontal score display frame for chip count, small wide panel dark navy background gold border, small chip coin icon on left side, rest open for number display, gold color theme base score currency, transparent areas around frame
```

### hud_mult_frame — 배수 표시
**Seed:** 85072 | **크기:** 256x80

```
horizontal score display frame for multiplier count, same shape as chip frame, blood red accent coloring instead of gold, small multiplication symbol icon on left side in red, rest open for number, red color theme amplifies danger and reward
```

### hud_total_frame — 합계 표시
**Seed:** 85073 | **크기:** 256x80

```
horizontal score display frame for total damage score, wider more prominent than chip or mult frames, dark navy background brilliant gold border subtle golden inner glow, small sword impact icon on left side, rest open for final calculated number, bottom line actual damage to boss
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

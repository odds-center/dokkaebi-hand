# 부적(Talisman) 아이콘 (20종)

> **아이작 스타일** — 1:1 정사각 안에 오브젝트만 딱. 투명 배경. 심플한 도트.
> 48x48px 최종 크기. 작은 크기에서도 한눈에 뭔지 알 수 있어야 함.
> 등급 구분은 배경색이 아닌 **게임 UI에서 테두리 색상으로** 처리.

## 생성 환경

```yaml
Model: Pony Diffusion V6 XL (ComfyUI)
LoRA: Binding of Isaac Style v2.1 (strength 0.80)
Resolution: 128 x 128 → 다운스케일 96x96 (@1920x1080)
Sampler: euler_a
Steps: 25
CFG: 7
Batch: 4장
```

## 공통 프롬프트 프리픽스

```
score_9, score_8_up, score_7_up, pixel art, game assets, chibi, simple green background, single item icon, one simple recognizable object centered, flat colors, thick black outlines, no ground, no shadow, no pedestal, square composition, only the item, nothing else
```

## 공통 네거티브 프롬프트

```
score_4, score_3, score_2, score_1, blurry, photo, realistic, 3d render, smooth shading, anti-aliasing, gradient, soft edges, watercolor, text, watermark, signature
```

## 후처리

```
1. 크로마키 그린 배경 제거 → 투명 알파
2. Nearest Neighbor 다운스케일 → 48x48
3. PNG (알파) → Assets/Art/Icons/Talisman/
4. 게임 UI에서 등급별 테두리 색상 렌더링 (일반=회색, 희귀=파랑, 전설=금색, 저주=보라)
```

---

## 일반 (Common) — 6종

### talisman_blood_oath — 피의 맹세
**Seed:** 73001
```
single crimson blood drop, small white paper talisman behind it, bright red drop, pale paper, two overlapping objects
```

### talisman_red_gate — 홍살문
**Seed:** 73002
```
tiny red Korean gate, two red pillars, red beam across top, torii-like silhouette, vivid red hongsalmun shape
```

### talisman_samdo_ferry — 삼도천의 나룻배
**Seed:** 73003
```
small brown wooden boat, single tiny cyan ghost flame floating above, side-view boat shape, dark brown hull, cyan wisp on top
```

### talisman_dokkaebi_club — 도깨비 방망이
**Seed:** 73004
```
short thick wooden club, metal studs, classic dokkaebi bangmangi, dark brown wood, gray metal dots, angled slightly, single weapon
```

### talisman_virtue_gate — 열녀문
**Seed:** 73005
```
small stone arch gate, green ribbon tied at top, gray stone, bright green ribbon bow, simple arch shape
```

### talisman_samsara_bead — 윤회의 구슬
**Seed:** 73006
```
single round jade-green prayer bead, tiny spiral mark inside, bright green sphere, single glowing orb
```

---

## 희귀 (Rare) — 6종

### talisman_dokkaebi_hat — 도깨비 감투
**Seed:** 73011
```
cone-shaped dark hat, Korean dokkaebi invisibility hat, dark fabric, faint purple shimmer line, triangular hat shape
```

### talisman_moonlight_fox — 달빛 여우
**Seed:** 73012
```
small white fox silhouette sitting, yellow crescent moon above, tiny simple fox, clear crescent, white fox, yellow moon
```

### talisman_underworld_mirror — 황천의 거울
**Seed:** 73013
```
small round bronze mirror, traditional Korean bronze mirror shape, dark bronze rim, bright reflective silver center, circle with frame
```

### talisman_girin_horn — 기린 각
**Seed:** 73014
```
single curved golden horn, bright gold color, slight upward curve, crescent-like horn shape
```

### talisman_fate_dice — 사주팔자의 주사위
**Seed:** 73015
```
two small wooden dice side by side, dark brown cubes, red dot marks on faces, simple pair of dice
```

### talisman_scale_desire — 욕망의 저울
**Seed:** 73017
```
tiny golden balance scale, tilted to one side, one pan lower, simple gold scale shape
```

---

## 전설 (Legendary) — 5종

### talisman_reaper_ledger — 저승사자의 명부
**Seed:** 73021
```
dark scroll partially unrolled, red seal stamp on it, dark brown scroll, bright red seal mark, simple scroll shape
```

### talisman_madness_bright — 광기의 광
**Seed:** 73022
```
bright golden star shape, jagged chaotic rays shooting outward, gold center, gold rays, hwatu bright symbol gone wild, simple starburst
```

### talisman_yeomra_seal — 염라왕의 도장
**Seed:** 73023
```
square red seal stamp, official seal shape, bright crimson red square, dark impression lines inside, simple square stamp
```

### talisman_heavenly_lute — 천상의 비파
**Seed:** 73024
```
small traditional Korean biwa lute instrument, dark brown body, pale strings, simple instrument silhouette
```

### talisman_hellflame — 지옥불꽃
**Seed:** 73025
```
single intense flame, orange-red outer flame, white-hot center, classic fire shape, pointed tips, simple flame icon
```

---

## 저주 (Cursed) — 3종

### talisman_doom — 흉살
**Seed:** 73031
```
cracked black talisman paper, single glowing red eye in center, dark cracked rectangle, one red eye, cursed paper
```

### talisman_phantom — 허깨비
**Seed:** 73032
```
pale ghostly hand reaching upward, fingers spread, translucent pale gray-white hand shape, upward-reaching hand
```

### talisman_oblivion_ribbon — 망각의 띠
**Seed:** 73033
```
dark gray ribbon, loose knot, fraying ends, ribbon ends dissolve into scattered pixels, knotted ribbon
```

# 부적(Talisman) 아이콘 (20종)

> 48x48px 아이콘. 작은 크기에서도 시각적 구분이 되어야 함.
> 등급별 배경색으로 희귀도 구분: 일반=회색, 희귀=파랑, 전설=금색, 저주=보라.

## 생성 환경

```yaml
Model: Flux-dev (ComfyUI)
Resolution: 192 x 192 (→ 다운스케일 48x48, 4배)
Steps: 20~25
Guidance: 3.5
Batch: 4장
```

## 공통 프롬프트 프리픽스

```
A single small square pixel art icon of a Korean talisman charm. 16-bit retro pixel art with crisp sharp pixels, no anti-aliasing. Bold flat colors with thick black outlines. Limited color palette based on game palette: dark navy (#1A1A2E), blood red (#C41E3A), ghost fire cyan (#00D4FF), gold (#FFD700), bone white (#E8E8E8), deep purple (#6B2D5B). The icon depicts one clear central object or symbol on a colored background. Simple enough to read at very small sizes. Fully contained within the square frame with margins. No text.
```

## 후처리

```
1. Nearest Neighbor 다운스케일 → 48x48
2. PNG → Assets/Art/Icons/Talisman/
```

---

## 일반 (Common) — 회색 배경

### talisman_blood_oath — 피의 맹세
**Seed:** 73001
```
A small talisman icon on a gray background. A crimson red blood drop falling onto a folded paper talisman. The paper has a faint red seal mark. Simple composition — blood drop above talisman paper. Color palette: gray background, crimson red, parchment white.
```

### talisman_red_gate — 홍살문
**Seed:** 73002
```
A small talisman icon on a gray background. A miniature red torii-style Korean hongsalmun gate. Two red pillars with a horizontal beam across the top. Simple architectural silhouette. Color palette: gray background, vivid red, dark brown.
```

### talisman_samdo_ferry — 삼도천의 나룻배
**Seed:** 73003
```
A small talisman icon on a gray background. A tiny wooden boat floating on dark water with a faint cyan ghost flame hovering above it. Simple side-view silhouette. Color palette: gray background, dark brown boat, cyan flame, dark blue water.
```

### talisman_dokkaebi_club — 도깨비 방망이
**Seed:** 73004
```
A small talisman icon on a gray background. A traditional Korean dokkaebi club — a short thick wooden bat with metal studs. Simple centered object. Color palette: gray background, dark brown wood, metallic gray studs.
```

### talisman_virtue_gate — 열녀문
**Seed:** 73005
```
A small talisman icon on a gray background. A miniature stone memorial gate with a green ribbon tied around it. Traditional Korean 열녀문 arch shape. Color palette: gray background, stone gray, green ribbon.
```

### talisman_samsara_bead — 윤회의 구슬
**Seed:** 73006
```
A small talisman icon on a gray background. A single glowing jade-green prayer bead with a faint spiral pattern inside. Simple centered sphere. Color palette: gray background, jade green, faint inner glow.
```

---

## 희귀 (Rare) — 파란 배경

### talisman_dokkaebi_hat — 도깨비 감투
**Seed:** 73011
```
A small talisman icon on a blue background. A traditional Korean invisibility hat — the dokkaebi gamtu. A cone-shaped dark hat with mysterious purple shimmer. Color palette: blue background, dark fabric, purple shimmer.
```

### talisman_moonlight_fox — 달빛 여우
**Seed:** 73012
```
A small talisman icon on a blue background. A small white fox silhouette sitting under a crescent moon. The fox glows faintly silver. Color palette: blue background, white fox, silver moonlight, pale yellow moon.
```

### talisman_underworld_mirror — 황천의 거울
**Seed:** 73013
```
A small talisman icon on a blue background. A small round bronze mirror with a reflective surface showing a faint ghostly image. Traditional Korean bronze mirror shape. Color palette: blue background, bronze frame, silver mirror surface.
```

### talisman_girin_horn — 기린 각
**Seed:** 73014
```
A small talisman icon on a blue background. A single curved golden horn from a mythical Korean girin beast. The horn glows with faint gold energy. Color palette: blue background, golden horn, warm glow.
```

### talisman_fate_dice — 사주팔자의 주사위
**Seed:** 73015
```
A small talisman icon on a blue background. A pair of traditional wooden dice with Korean fortune symbols on each face instead of dots. Color palette: blue background, dark wood dice, red symbol marks.
```

### talisman_scale_desire — 욕망의 저울
**Seed:** 73017
```
A small talisman icon on a blue background. A small golden balance scale tilted heavily to one side, with a red heart on the heavy side and a skull on the light side. Color palette: blue background, gold scale, red heart, bone white skull.
```

---

## 전설 (Legendary) — 금색 배경

### talisman_reaper_ledger — 저승사자의 명부
**Seed:** 73021
```
A small talisman icon on a golden background. An ancient dark scroll partially unrolled, with glowing red text visible on the parchment. A seal of authority stamps the corner. Color palette: gold background, dark scroll, glowing red text, crimson seal.
```

### talisman_madness_bright — 광기의 광
**Seed:** 73022
```
A small talisman icon on a golden background. A hwatu bright card (광) symbol exploding with chaotic golden light rays. The light is unstable and wild. Color palette: gold background, bright white center, chaotic gold rays.
```

### talisman_yeomra_seal — 염라왕의 도장
**Seed:** 73023
```
A small talisman icon on a golden background. A large square red seal stamp — the official seal of King Yama. Bold Chinese characters impression in the center. Color palette: gold background, crimson red seal, dark ink impression.
```

### talisman_heavenly_lute — 천상의 비파
**Seed:** 73024
```
A small talisman icon on a golden background. A small Korean traditional biwa/pipa lute instrument glowing with celestial blue-white light. Color palette: gold background, dark wood instrument, celestial blue-white glow.
```

### talisman_hellflame — 지옥불꽃
**Seed:** 73025
```
A small talisman icon on a golden background. An intense orange-red flame burning with extreme heat, its core white-hot. Small lava drops falling from the flame. Color palette: gold background, orange-red flame, white-hot center.
```

---

## 저주 (Cursed) — 보라 배경

### talisman_doom — 흉살
**Seed:** 73031
```
A small talisman icon on a dark purple background. A cracked black talisman paper with a cursed red eye symbol in the center. Dark energy wisps leak from the cracks. Color palette: dark purple background, black paper, glowing red eye, dark wisps.
```

### talisman_phantom — 허깨비
**Seed:** 73032
```
A small talisman icon on a dark purple background. A translucent ghostly hand reaching upward from below, grasping at empty air. The hand is pale and semi-transparent. Color palette: dark purple background, pale translucent hand, faint gray.
```

### talisman_oblivion_ribbon — 망각의 띠
**Seed:** 73033
```
A small talisman icon on a dark purple background. A fraying dark ribbon tied in a knot, with the ends dissolving into particles of forgetting. The ribbon unravels at the edges. Color palette: dark purple background, dark gray ribbon, dissolving particles.
```

# 부적(Talisman) 아이콘 (20종)

> **아이작 스타일** — 1:1 정사각 안에 오브젝트만 딱. 투명 배경. 심플한 도트.
> 48x48px 최종 크기. 작은 크기에서도 한눈에 뭔지 알 수 있어야 함.
> 등급 구분은 배경색이 아닌 **게임 UI에서 테두리 색상으로** 처리.

## 생성 환경

```yaml
Model: Flux-dev (ComfyUI)
Resolution: 192 x 192 (→ Nearest Neighbor 다운스케일 48x48)
Steps: 20~25
Guidance: 3.5
Batch: 4장
```

## 공통 프롬프트 프리픽스

```
A single pixel art item icon in the style of The Binding of Isaac. One simple recognizable object centered on a plain solid bright green (#00FF00) chroma key background. 16-bit retro pixel art with crisp sharp pixels, no anti-aliasing, no gradients. Bold thick black outlines around the object. Flat color fill only. The object floats in empty space with no ground, no shadow, no pedestal, no decorative elements. Extremely simple silhouette — must be readable at 48x48 pixels. Square 1:1 composition. Only the item, nothing else.
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
A single crimson blood drop with a small white paper talisman behind it. The blood drop is bright red, the paper is pale. Two simple objects overlapping. Nothing else.
```

### talisman_red_gate — 홍살문
**Seed:** 73002
```
A tiny red Korean gate — two red pillars with a red beam across the top. Simple torii-like silhouette in vivid red. The iconic hongsalmun shape. Nothing else.
```

### talisman_samdo_ferry — 삼도천의 나룻배
**Seed:** 73003
```
A small brown wooden boat with a single tiny cyan ghost flame floating above it. Simple side-view boat shape. Dark brown hull, cyan wisp on top. Nothing else.
```

### talisman_dokkaebi_club — 도깨비 방망이
**Seed:** 73004
```
A short thick wooden club with metal studs — the classic dokkaebi bangmangi. Dark brown wood, gray metal dots. Angled slightly. One simple weapon. Nothing else.
```

### talisman_virtue_gate — 열녀문
**Seed:** 73005
```
A small stone arch gate with a green ribbon tied at the top. Gray stone, bright green ribbon bow. Simple arch shape. Nothing else.
```

### talisman_samsara_bead — 윤회의 구슬
**Seed:** 73006
```
A single round jade-green prayer bead with a tiny spiral mark inside. Bright green sphere with black outline. One simple glowing orb. Nothing else.
```

---

## 희귀 (Rare) — 6종

### talisman_dokkaebi_hat — 도깨비 감투
**Seed:** 73011
```
A cone-shaped dark hat — the Korean dokkaebi invisibility hat. Dark fabric with a faint purple shimmer line. Simple triangular hat shape. Nothing else.
```

### talisman_moonlight_fox — 달빛 여우
**Seed:** 73012
```
A small white fox silhouette sitting below a yellow crescent moon. The fox is tiny and simple, the moon is a clear crescent above. White fox, yellow moon. Nothing else.
```

### talisman_underworld_mirror — 황천의 거울
**Seed:** 73013
```
A small round bronze mirror — traditional Korean bronze mirror shape. Dark bronze rim, bright reflective silver center. Simple circle with a frame. Nothing else.
```

### talisman_girin_horn — 기린 각
**Seed:** 73014
```
A single curved golden horn. Bright gold color with a slight upward curve. Simple horn shape like a crescent. Nothing else.
```

### talisman_fate_dice — 사주팔자의 주사위
**Seed:** 73015
```
Two small wooden dice side by side. Dark brown cubes with red dot marks on the faces. Simple pair of dice. Nothing else.
```

### talisman_scale_desire — 욕망의 저울
**Seed:** 73017
```
A tiny golden balance scale tilted to one side. One pan lower than the other. Simple gold scale shape. Nothing else.
```

---

## 전설 (Legendary) — 5종

### talisman_reaper_ledger — 저승사자의 명부
**Seed:** 73021
```
A dark scroll partially unrolled with a red seal stamp on it. Dark brown scroll, bright red seal mark. Simple scroll shape. Nothing else.
```

### talisman_madness_bright — 광기의 광
**Seed:** 73022
```
A bright golden star shape with jagged chaotic rays shooting outward. Gold center, gold rays — the hwatu bright symbol gone wild. Simple starburst. Nothing else.
```

### talisman_yeomra_seal — 염라왕의 도장
**Seed:** 73023
```
A square red seal stamp — official seal shape. Bright crimson red square with dark impression lines inside. Simple square stamp. Nothing else.
```

### talisman_heavenly_lute — 천상의 비파
**Seed:** 73024
```
A small traditional Korean biwa lute instrument. Dark brown body with pale strings. Simple instrument silhouette. Nothing else.
```

### talisman_hellflame — 지옥불꽃
**Seed:** 73025
```
A single intense flame — orange-red outer flame with white-hot center. Classic fire shape with pointed tips. Simple flame icon. Nothing else.
```

---

## 저주 (Cursed) — 3종

### talisman_doom — 흉살
**Seed:** 73031
```
A cracked black talisman paper with a single glowing red eye in the center. Dark cracked rectangle, one red eye. Simple cursed paper. Nothing else.
```

### talisman_phantom — 허깨비
**Seed:** 73032
```
A pale ghostly hand reaching upward with fingers spread. Translucent pale gray-white hand shape. Simple upward-reaching hand. Nothing else.
```

### talisman_oblivion_ribbon — 망각의 띠
**Seed:** 73033
```
A dark gray ribbon tied in a loose knot with fraying ends. The ribbon ends dissolve into tiny scattered pixels. Simple knotted ribbon. Nothing else.
```

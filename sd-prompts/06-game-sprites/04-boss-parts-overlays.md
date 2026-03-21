# 보스 파츠 오버레이 스프라이트 (24종 × 등급 색상)

> **핵심 개념:** 보스 스프라이트 위에 **레이어로 얹히는** 장비 도트 스프라이트.
> 파츠가 많을수록 보스가 시각적으로 무장되어 "강해 보인다."
> 등급(일반/희귀/전설)에 따라 같은 파츠라도 색상 강도가 다르다.

## 시각 시스템 설계

```
[보스 기본 스프라이트]     ← 06-game-sprites/01-bosses.md
    ↑ 레이어
[머리 파츠 오버레이]       ← 이 파일 (Head)
    ↑ 레이어
[팔 파츠 오버레이]         ← 이 파일 (Arm)
    ↑ 레이어
[몸통 파츠 오버레이]       ← 이 파일 (Body)
    ↑ 레이어
[세트 보너스 오라]         ← 05-set-aura.md
```

파츠가 0개 → 보스만 보임 (약해 보임)
파츠가 1개 → 머리 OR 팔 OR 몸통 하나 추가 (약간 강해 보임)
파츠가 3개 → 전부 장착 → 세트 보너스까지 → **최고로 위협적**

## 등급별 색상 강도

| 등급 | 테두리 색 | 발광 강도 | 시각 인상 |
|------|----------|----------|----------|
| 일반 (Common) | 회색 (#888888) | 발광 없음 | 낡고 평범한 장비 |
| 희귀 (Rare) | 파란색 (#4488FF) | 은은한 파란 발광 | 마력이 깃든 장비 |
| 전설 (Legendary) | 금색 (#FFD700) | 강한 금색 발광 | 신성한/저주받은 장비 |

## 세트별 추가 색상 힌트

| 세트 | 색상 | 효과 |
|------|------|------|
| 불 (Fire) | 주황 (#FF4500) | 파츠 가장자리에 불꽃 이펙트 |
| 얼음 (Ice) | 하늘색 (#00D4FF) | 파츠에 얼음 결정 부착 |
| 그림자 (Shadow) | 보라 (#6B2D5B) | 파츠에서 그림자 연기 피어오름 |
| 해골 (Skull) | 뼈 흰색 (#E8E8E8) | 파츠에 해골/뼈 장식 |

## 생성 환경

```yaml
Model: Pony Diffusion V6 XL (ComfyUI)
LoRA: Binding of Isaac Style v2.1 (strength 0.65)
Resolution: 800 x 800 (픽셀 그리드 200x200 기준, 4x 생성)
       # → 다운스케일 600x600 (@1920x1080 기본 저장)
Sampler: euler_a
Steps: 25~30
CFG: 7
Batch: 4장
```

## 공통 프롬프트 프리픽스

```
score_9, score_8_up, score_7_up, pixel art, game assets, chibi, simple green background, equipment overlay sprite, chroma key green background, 200x200 pixel grid, blocky jagged edges, no smooth curves, no anti-aliasing, flat colors, thick black outlines, single equipment piece, no character body, front-facing overlay, fully contained with margins
```

## 공통 네거티브 프롬프트

```
score_4, score_3, score_2, score_1, blurry, photo, realistic, 3d render, smooth shading, anti-aliasing, gradient, soft edges, watercolor, text, watermark, signature
```

## 후처리

```
1. 배경 완전 제거 → 투명 알파 (장비 부분만 남김)
2. Nearest Neighbor 다운스케일 → 300x300 (보스 스프라이트 최종 크기와 동일)
3. 등급별 색상 보정 — 일반(채도 낮게), 희귀(파란 글로우 추가), 전설(금색 글로우 추가)
4. PNG (알파) → Assets/Art/Sprites/BossParts/
5. Unity에서 보스 스프라이트 위에 레이어로 합성
```

---

## 머리(Head) 파츠 — 8종

> 보스 스프라이트의 **머리 위~이마 위치**에 올라가는 장비.

### head_iron_horn — 쇠뿔 (일반)
**Seed:** 80101

```
pair of short stubby iron horns, top of canvas for head overlay, dull gray metallic iron, visible rivet marks, slight rust, curved slightly outward and upward, old heavy utilitarian, common equipment no glow, upper-center on 300x300 transparent canvas, gray metallic color
```

### head_fire_horn — 화염 뿔 (희귀, 불 세트)
**Seed:** 80102

```
pair of curved horns engulfed in orange fire, head overlay position, dark charcoal black horns, vivid orange-red flames burning from surface, embers and sparks flying upward from tips, warm orange glow, fire rendered as flat pixel art flames, upper-center on 300x300 transparent canvas, rare fire-set equipment, blue-bordered glow
```

### head_ice_crown — 얼음 왕관 (희귀, 얼음 세트)
**Seed:** 80103

```
crown of sharp ice crystals, head overlay position, translucent pale blue ice shards pointing upward, jagged ring shape, frost particles on surface, small floating ice crystals, cold cyan inner glow, upper-center on 300x300 transparent canvas, rare ice-set equipment
```

### head_third_eye — 제3의 눈 (일반)
**Seed:** 80104

```
single large floating eye, upper-center forehead area, bloodshot red slit pupil, dark veiny flesh surrounding, hovers above forehead position, dim reddish glow, common equipment on 300x300 transparent canvas, unsettling but not powerful-looking
```

### head_ghost_helm — 도깨비불 투구 (희귀)
**Seed:** 80105

```
dark iron warrior helmet, cyan ghost flame burning on top as crest, T-shaped face opening, dark blue-gray metal, blue-tinted edges, vivid cyan dokkaebi fire from crown, cyan light casting downward, upper-center on 300x300 transparent canvas, rare equipment, supernatural fire crest
```

### head_skull_crown — 해골 면류관 (전설, 해골 세트)
**Seed:** 80106

```
elaborate crown of multiple small skulls stacked and fused, bone-white dark hollow eye sockets, largest skull center front, smaller skulls forming ring, faint golden-white glow from eye sockets, upper-center on 300x300 transparent canvas, legendary skull-set equipment, golden legendary border glow
```

### head_fog_mask — 독안개 면 (희귀)
**Seed:** 80107

```
dark face mask covering lower face, toxic green fog wisps leaking from edges, dark leather-brown with metal rivets, green poisonous gas from ventilation holes, curling upward, face level on 300x300 transparent canvas, rare equipment, toxic gas effect
```

### head_king_helm — 천왕 투구 (전설)
**Seed:** 80108

```
grand ornate golden warrior helmet, sweeping wing-like decorations both sides, brilliant gold with engraved patterns, large central crest, divine radiance glow, upper-center on 300x300 transparent canvas, most impressive head equipment, golden legendary glow radiating outward
```

---

## 팔(Arm) 파츠 — 8종

> 보스 스프라이트의 **양쪽 팔/손 위치**에 올라가는 장비.

### arm_chain — 쇠사슬 (희귀)
**Seed:** 80201

```
heavy dark iron chains wrapped around both arm positions, thick dark metal links, padlock hanging from one end, chains draping across left and right sides, faint blue metallic sheen, left and right arm areas on 300x300 transparent canvas, rare equipment, heavy and oppressive
```

### arm_fire_glove — 불꽃 장갑 (일반, 불 세트)
**Seed:** 80202

```
pair of gauntlet gloves with orange flame aura, both hand positions, dark iron with flame patterns etched, small orange flames from knuckles and fingertips, moderate fire common equipment, left and right hand areas on 300x300 transparent canvas, common fire-set, subtle flame effect
```

### arm_shadow — 그림자 팔 (희귀, 그림자 세트)
**Seed:** 80203

```
dark shadowy tendrils wrapping both arm positions, living shadow, semi-transparent dark purple-black, wisps of dark smoke rising, shadows shift like liquid darkness, faint purple glow outline, left and right arm areas on 300x300 transparent canvas, rare shadow-set equipment, arms consumed by darkness
```

### arm_gold_brace — 황금 팔찌 (일반)
**Seed:** 80204

```
pair of golden bracelets with coin symbols, both wrist positions, simple gold bands, small coin medallions dangling, dull gold common equipment, left and right wrist areas on 300x300 transparent canvas, simple common equipment suggesting greed
```

### arm_poison_claw — 독 발톱 (희귀)
**Seed:** 80205

```
sharp curved claws from both hand positions, dripping green poison, dark bone-gray razor-sharp tips, green toxic liquid droplets falling, faint green toxic glow, left and right hand areas on 300x300 transparent canvas, rare equipment, deadly and venomous
```

### arm_seal — 봉인 부적 팔 (전설)
**Seed:** 80206

```
both arms wrapped in glowing red talisman papers, black calligraphy writing, papers spiraling like bandages, Korean Chinese seal script, bright red-gold glow, small paper fragments floating free, left and right arm areas on 300x300 transparent canvas, legendary equipment, divine sealing power, golden glow
```

### arm_web_hand — 거미줄 손 (희귀)
**Seed:** 80207

```
sticky white web strands between fingers at both hand positions, pale gray-white thin sticky webbing, connecting finger to finger, extending outward, faint silvery sheen, left and right hand areas on 300x300 transparent canvas, rare equipment, ensnaring and trapping
```

### arm_bone_pincer — 뼈 집게 (전설, 해골 세트)
**Seed:** 80208

```
large bone-white crab-like pincers replacing both hands, fused skull bones, interlocking bone segments, sharp jagged edges, pincers open and threatening, golden-white glow from bone joints, left and right hand areas on 300x300 transparent canvas, legendary skull-set equipment, golden legendary glow
```

---

## 몸통(Body) 파츠 — 8종

> 보스 스프라이트의 **몸통/가슴 중앙**에 올라가는 장비.

### body_iron_plate — 철갑 (일반)
**Seed:** 80301

```
dark iron chest plate covering torso center, utilitarian armor, visible rivets and dents, dull gray metallic no special effects, basic chest and upper abdomen shape, center-chest on 300x300 transparent canvas, common equipment, sturdy but unremarkable
```

### body_fire_mark — 화문 (희귀, 불 세트)
**Seed:** 80302

```
glowing orange fire rune symbol on chest center, heat ripples radiating outward, angular geometric Korean traditional pattern, bright orange-red branded mark, small flames from rune edges, orange glow, center-chest on 300x300 transparent canvas, rare fire-set equipment, burning brand of power
```

### body_ice_armor — 빙결 갑옷 (희귀, 얼음 세트)
**Seed:** 80303

```
crystalline blue ice encasing entire torso, frozen armor, translucent pale blue crystal facets, frost patterns, sharp ice shards from shoulders and edges, frozen mist on surface, cold cyan glow from within, covering torso on 300x300 transparent canvas, rare ice-set equipment, body frozen solid
```

### body_shadow_armor — 그림자 갑옷 (일반, 그림자 세트)
**Seed:** 80304

```
shifting dark shadow covering torso, living darkness clinging to body, semi-transparent dark purple-black, edges dissolving into wisps, faint purple tint at core, covering torso on 300x300 transparent canvas, common shadow-set equipment, subtle darkness
```

### body_talisman_absorb — 부적 흡수체 (전설)
**Seed:** 80305

```
multiple talisman papers violently sucked into chest center, absorbed by dark vortex, papers spiraling inward toward dark void, red calligraphy glowing as pulled in, dark hole at center, golden-red glow at absorption point, center-chest on 300x300 transparent canvas, legendary equipment, absorbing talisman power, golden glow
```

### body_mirror_plate — 거울 흉갑 (전설)
**Seed:** 80306

```
large polished mirror surface covering chest, silver-chrome with ornate dark frame edges, warped ghostly reflection not true mirror, brilliant silver-gold glow, center-chest on 300x300 transparent canvas, legendary equipment, reflecting attacks, divine mirror power, golden legendary glow
```

### body_thorn_armor — 가시 갑옷 (희귀)
**Seed:** 80307

```
armor with sharp protruding thorns across entire torso, dark iron base, dozens of pointed thorns at various angles, dark red tips as if blood-stained, faint blue metallic sheen on thorn tips, covering torso on 300x300 transparent canvas, rare equipment, attackers get hurt
```

### body_smoke — 연기 몸 (일반)
**Seed:** 80308

```
torso partially dissolved into smoke wisps, body becoming vapor, dark gray smoke from chest and sides, body outline barely visible through haze, smoke curling upward and outward, faint and ghostly common equipment, covering torso on 300x300 transparent canvas, half-smoke body, hard to hit
```

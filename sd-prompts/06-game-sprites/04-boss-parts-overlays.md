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
Model: Flux-dev (ComfyUI)
Resolution: 800 x 800 (픽셀 그리드 200x200 기준, 4x 생성)
       # → 다운스케일 600x600 (@1920x1080 기본 저장)
Steps: 25~30
Guidance: 3.5
Batch: 4장
```

## 공통 프롬프트 프리픽스

```
A low-resolution pixel art equipment overlay sprite on a plain solid bright green (#00FF00) background for chroma key removal. Made of large visible square pixels like a sprite from Stardew Valley — each individual pixel is clearly visible. Drawn on a 200x200 pixel grid then scaled up. Blocky jagged edges, no smooth curves, no anti-aliasing, no soft gradients, no blending between pixels. Bold flat color fills with thick black pixel outlines. This is a SINGLE piece of equipment to be layered ON TOP of an existing boss sprite. Only the equipment piece itself — no character body. Positioned correctly for front-facing overlay.
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
A pair of short stubby iron horns positioned at the top of the canvas, designed to sit on a character's head. The horns are dull gray metallic iron with visible rivet marks and slight rust. They curve slightly outward and upward. Thick black outlines. The horns look old, heavy, and utilitarian — common equipment with no special glow. Positioned in the upper-center of a 300x300 transparent canvas, spaced apart as if sitting on a head. Gray metallic color, no glow effect.
```

### head_fire_horn — 화염 뿔 (희귀, 불 세트)
**Seed:** 80102

```
A pair of curved horns engulfed in orange fire, positioned at the top of the canvas for head overlay. The horns themselves are dark charcoal black, with vivid orange-red flames constantly burning from their surface. Small embers and sparks fly upward from the horn tips. The fire illuminates the surrounding area with a warm orange glow. Thick black outlines on the horn shapes, fire rendered as flat pixel art flames. Positioned upper-center on 300x300 transparent canvas. The equipment radiates heat and danger — rare fire-set equipment with blue-bordered glow.
```

### head_ice_crown — 얼음 왕관 (희귀, 얼음 세트)
**Seed:** 80103

```
A crown made of sharp ice crystals, positioned at the top of the canvas for head overlay. The crown is made of translucent pale blue ice shards pointing upward in a jagged ring shape. Frost particles cling to the surface. Small ice crystals float near the crown. The ice has a cold cyan inner glow. Thick black outlines on major ice shapes. Positioned upper-center on 300x300 transparent canvas. The equipment radiates freezing cold — rare ice-set equipment.
```

### head_third_eye — 제3의 눈 (일반)
**Seed:** 80104

```
A single large floating eye positioned at the upper-center forehead area of the canvas. The eye is bloodshot red with a slit pupil, surrounded by dark veiny flesh. The eye hovers slightly above where a forehead would be, looking directly at the viewer. It has a dim reddish glow. Thick black outlines. Simple common equipment on 300x300 transparent canvas. Unsettling but not powerful-looking.
```

### head_ghost_helm — 도깨비불 투구 (희귀)
**Seed:** 80105

```
A dark iron warrior helmet with a cyan ghost flame burning on top as a crest. The helmet covers the upper head area, with a T-shaped face opening. The metal is dark blue-gray with blue-tinted edges. A vivid cyan dokkaebi fire burns steadily from the helmet's crown, casting cyan light downward. Thick black outlines. Positioned upper-center on 300x300 transparent canvas. Rare equipment with supernatural fire crest.
```

### head_skull_crown — 해골 면류관 (전설, 해골 세트)
**Seed:** 80106

```
An elaborate crown constructed from multiple small skulls stacked and fused together. The skulls are bone-white with dark hollow eye sockets. The crown sits grandly at the top of the canvas, with the largest skull at the center front and smaller ones forming the ring. A faint golden-white glow emanates from the eye sockets. Thick black outlines on each skull shape. Positioned upper-center on 300x300 transparent canvas. Legendary skull-set equipment — terrifyingly ornate with golden legendary border glow.
```

### head_fog_mask — 독안개 면 (희귀)
**Seed:** 80107

```
A dark face mask covering the lower face area, with toxic green fog wisps leaking from its edges. The mask is dark leather-brown with metal rivets. Thin streams of green poisonous gas seep from the mask's ventilation holes and edges, curling upward. Thick black outlines on the mask shape. Positioned at the face level on 300x300 transparent canvas. Rare equipment with toxic gas effect.
```

### head_king_helm — 천왕 투구 (전설)
**Seed:** 80108

```
A grand ornate golden warrior helmet with sweeping wing-like decorations on both sides. The helmet is brilliant gold with intricate engraved patterns on its surface. A large central crest rises from the top. The gold glows with divine radiance — this is legendary equipment. Thick black outlines defining the ornate metalwork. Positioned upper-center on 300x300 transparent canvas. The most impressive head equipment — golden legendary glow radiating outward.
```

---

## 팔(Arm) 파츠 — 8종

> 보스 스프라이트의 **양쪽 팔/손 위치**에 올라가는 장비.

### arm_chain — 쇠사슬 (희귀)
**Seed:** 80201

```
Heavy dark iron chains wrapped around both arm positions on the canvas. The chains are thick dark metal links with a padlock hanging from one chain end. The chains drape across the arm areas — left and right sides of the canvas. A faint blue metallic sheen on the chain links. Thick black outlines. Positioned at left and right arm areas on 300x300 transparent canvas. Rare equipment — heavy and oppressive.
```

### arm_fire_glove — 불꽃 장갑 (일반, 불 세트)
**Seed:** 80202

```
A pair of gauntlet gloves with orange flame aura, positioned at both hand areas of the canvas. The gauntlets are dark iron with flame patterns etched into the metal. Small orange flames flicker from the knuckles and fingertips. The fire is moderate — common equipment, not too flashy. Thick black outlines on the gauntlet shapes. Positioned at left and right hand areas on 300x300 transparent canvas. Common fire-set equipment with subtle flame effect.
```

### arm_shadow — 그림자 팔 (희귀, 그림자 세트)
**Seed:** 80203

```
Dark shadowy tendrils wrapping around both arm positions, made of living shadow. The shadow material is semi-transparent dark purple-black, with wisps of dark smoke rising from the surface. The shadows shift and flow like liquid darkness. A faint purple glow outlines the shadow mass. Thick outlines where the shadow is densest. Positioned at left and right arm areas on 300x300 transparent canvas. Rare shadow-set equipment — the arms are consumed by darkness.
```

### arm_gold_brace — 황금 팔찌 (일반)
**Seed:** 80204

```
A pair of golden bracelets with coin symbols, positioned at both wrist areas. The bracelets are simple gold bands with small coin medallions hanging from them. Dull gold color — common equipment without much glow. A few small coin shapes dangle from the bands. Thick black outlines. Positioned at left and right wrist areas on 300x300 transparent canvas. Simple common equipment suggesting greed.
```

### arm_poison_claw — 독 발톱 (희귀)
**Seed:** 80205

```
Sharp curved claws extending from both hand positions, dripping with green poison. The claws are dark bone-gray with razor-sharp tips. Green toxic liquid drips from each claw tip, forming small droplets that fall downward. A faint green toxic glow surrounds the claw area. Thick black outlines on the claw shapes. Positioned at left and right hand areas on 300x300 transparent canvas. Rare equipment — deadly and venomous.
```

### arm_seal — 봉인 부적 팔 (전설)
**Seed:** 80206

```
Both arms wrapped tightly in glowing red talisman papers with black calligraphy writing. The papers spiral around the arm positions like bandages, each covered in Korean/Chinese seal script. A bright red-gold glow emanates from the paper wrappings. Small paper fragments float free from the binding. Thick black outlines on the talisman paper edges. Positioned at left and right arm areas on 300x300 transparent canvas. Legendary equipment — divine sealing power with golden glow.
```

### arm_web_hand — 거미줄 손 (희귀)
**Seed:** 80207

```
Sticky white web strands stretching between the fingers at both hand positions. The webbing is pale gray-white, thin and sticky, connecting finger to finger and stretching outward. Some web strands extend beyond the hands into the surrounding space. A faint silvery sheen on the web material. Thick black outlines where the web is thickest. Positioned at left and right hand areas on 300x300 transparent canvas. Rare equipment — ensnaring and trapping.
```

### arm_bone_pincer — 뼈 집게 (전설, 해골 세트)
**Seed:** 80208

```
Large bone-white crab-like pincers replacing both hands, made entirely of fused skull bones. Each pincer is constructed from interlocking bone segments with sharp jagged edges. The pincers are open and threatening, ready to snap shut. A golden-white glow emanates from the bone joints. Thick black outlines on each bone segment. Positioned at left and right hand areas on 300x300 transparent canvas. Legendary skull-set equipment — terrifying bone weapons with golden legendary glow.
```

---

## 몸통(Body) 파츠 — 8종

> 보스 스프라이트의 **몸통/가슴 중앙**에 올라가는 장비.

### body_iron_plate — 철갑 (일반)
**Seed:** 80301

```
A dark iron chest plate covering the torso center area. Simple utilitarian armor with visible rivets and dents. Dull gray metallic color with no special effects. The armor has a basic shape — covering the chest and upper abdomen. Thick black outlines. Positioned at center-chest on 300x300 transparent canvas. Common equipment — sturdy but unremarkable.
```

### body_fire_mark — 화문 (희귀, 불 세트)
**Seed:** 80302

```
A glowing orange fire rune symbol on the chest center, with heat ripples radiating outward. The rune is an angular geometric Korean traditional pattern rendered in bright orange-red, as if branded onto the skin with fire. Small flames lick outward from the rune's edges. An orange glow radiates from the mark. Thick black outlines on the rune shape. Positioned at center-chest on 300x300 transparent canvas. Rare fire-set equipment — a burning brand of power.
```

### body_ice_armor — 빙결 갑옷 (희귀, 얼음 세트)
**Seed:** 80303

```
Crystalline blue ice encasing the entire torso area like frozen armor. The ice is translucent pale blue with visible crystal facets and frost patterns. Sharp ice shards protrude from the shoulders and edges. Frozen mist clings to the surface. A cold cyan glow emanates from within the ice. Thick black outlines on major ice formations. Positioned covering the torso on 300x300 transparent canvas. Rare ice-set equipment — the body is frozen solid.
```

### body_shadow_armor — 그림자 갑옷 (일반, 그림자 세트)
**Seed:** 80304

```
A shifting dark shadow covering the torso area, like living darkness clinging to the body. The shadow is semi-transparent dark purple-black, with edges that dissolve into wisps. The darkness shifts and flows slowly. A very faint purple tint at the core. Thick outlines only where the shadow is densest. Positioned covering the torso on 300x300 transparent canvas. Common shadow-set equipment — subtle darkness, not flashy.
```

### body_talisman_absorb — 부적 흡수체 (전설)
**Seed:** 80305

```
Multiple talisman papers being violently sucked into the chest center, as if absorbed by a dark vortex. The papers spiral inward toward a dark void at the chest center. Each paper has red calligraphy that glows as it gets pulled in. A dark hole at the center pulls everything toward it. Golden-red glow at the absorption point. Thick black outlines on the talisman papers. Positioned at center-chest on 300x300 transparent canvas. Legendary equipment — absorbing all talisman power with golden glow.
```

### body_mirror_plate — 거울 흉갑 (전설)
**Seed:** 80306

```
A large polished mirror surface covering the chest, reflecting distorted images. The mirror is silver-chrome with ornate dark frame edges. The reflection shows a warped ghostly image — not a true reflection but something otherworldly. A brilliant silver-gold glow radiates from the mirror surface. Thick black outlines on the mirror frame. Positioned at center-chest on 300x300 transparent canvas. Legendary equipment — reflecting attacks back with divine mirror power. Golden legendary glow.
```

### body_thorn_armor — 가시 갑옷 (희귀)
**Seed:** 80307

```
Armor covered in sharp protruding thorns across the entire torso. The armor base is dark iron, but dozens of sharp pointed thorns protrude outward at various angles. Some thorns have dark red tips as if stained with blood. A faint blue metallic sheen on the thorn tips. Thick black outlines on each thorn. Positioned covering the torso on 300x300 transparent canvas. Rare equipment — anyone who attacks gets hurt.
```

### body_smoke — 연기 몸 (일반)
**Seed:** 80308

```
The torso area partially dissolved into smoke wisps, as if the body is becoming vapor. Dark gray smoke pours from the chest and sides, with the body outline barely visible through the haze. The smoke curls upward and outward naturally. Very faint and ghostly — common equipment without much visual impact. Thin outlines visible through the smoke. Positioned covering the torso on 300x300 transparent canvas. Common equipment — the body is half-smoke, hard to hit.
```

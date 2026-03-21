# 인게임 보스 스프라이트 (14종: 일반 10 + 재앙 4)

> 컨셉아트(04)와 다름 — **실제 게임 화면에 표시되는 픽셀아트 스프라이트.**

## 생성 환경

```yaml
Model: Pony Diffusion V6 XL (ComfyUI)
LoRA: Binding of Isaac Style v2.1 (strength 0.65)
Resolution: 800 x 800 → 다운스케일 600x600 (@1920x1080)
Sampler: euler_a
Steps: 30
CFG: 7
Batch: 8장
```

## 공통 프롬프트 프리픽스

```
score_9, score_8_up, score_7_up, pixel art, game assets, chibi, simple green background, single character sprite, Korean dokkaebi demon, front-facing centered, flat colors, thick black outlines, limited color palette, dark fantasy, fully contained with margins, no cropping
```

## 공통 네거티브 프롬프트

```
score_4, score_3, score_2, score_1, blurry, photo, realistic, 3d render, smooth shading, anti-aliasing, gradient, soft edges, watercolor, text, watermark, signature
```

## 후처리

```
1. 8장 중 최선 선택
2. 크로마키 그린 배경 제거 → 투명 알파
3. Nearest Neighbor 다운스케일 → 600x600 (@1920x1080 기준)
4. PNG (알파) → Assets/Art/Sprites/Boss/
```

---

## 일반 보스 (10종)

### boss_glutton — 먹보 도깨비
**Seed:** 70001

```
large round body, gluttonous dokkaebi, massive protruding belly, stubby thick limbs, thick bull neck, reddish-orange skin, rough texture, short broken horns, round head, enormous wide mouth, large uneven teeth, gold-capped teeth, small greedy deep-set eyes, tattered dark loincloth, food stains on body, arms akimbo pose, confident laughing expression, menacing yet comedic, dangerous overgrown child, reddish orange palette, blood red accents, dark brown
```

### boss_trickster — 장난꾸러기 도깨비
**Seed:** 70002

```
lean mischievous dokkaebi, prankster, wiry thin body, exaggerated long arms, long fingers, blue-gray skin, sly grin, two curved horns pointing backward, large pointed ears, ragged dark vest, shorts, asymmetric eyes, one eye larger, crazy look, holding dokkaebi club behind back, crouching ready-to-pounce stance, one finger raised, playful but unsettling, blue-gray palette, dark teal, mischief purple accents
```

### boss_flame — 불꽃 도깨비
**Seed:** 70003

```
large muscular fire dokkaebi, engulfed in flames, charcoal-black cracked skin, glowing orange lava in body fissures, sharp angular features, pointed chin, brow ridges, tall pointed horns ablaze, burning orange-white eyes, smoke and ash rising from shoulders, aggressive wide attack stance, clenched fists, dripping liquid flame, tattered burnt cloth at waist, uncontrolled destructive fury, charcoal black palette, flame orange, fire yellow, ember red
```

### boss_shadow — 그림자 도깨비
**Seed:** 70004

```
shadow dokkaebi, living darkness, semi-transparent shifting form, edges dissolving into smoke wisps, ink-black body, faint glowing purple eyes, two floating points of light, wispy shadow tendrils, no clear body boundary, hunched predatory posture, leaning forward, barely visible claws and teeth, faint dark purple core glow, darkness made alive, pure black palette, dark purple glow
```

### boss_fox — 여우 도깨비 (구미호)
**Seed:** 70005

```
slender elegant fox spirit dokkaebi, gumiho, feminine form, pointed fox ears, large fluffy nine-tailed fox tail, pale white porcelain skin, long dark hair, purple highlights, ornate purple Korean hanbok, decorative ribbon accessories, seductive half-lidded eyes, glowing purple irises, subtle dangerous smile, one hand raised gracefully, sharp hidden claws, faint purple magical aura, beautiful but unsettling, predator disguised as beauty, purple palette, lavender, pale white, dark accents
```

### boss_mirror — 거울 도깨비
**Seed:** 70006

```
crystalline dokkaebi, fractured mirror shards, angular geometric body, reflective flat panels, distorted light reflections, each shard reflects different image, two large reflective eyes, reversed reflections, sharp jagged edges on limbs, broken glass texture, remnants of dark robe, mimicking pose, arms raised copying gesture, unsettling doppelganger, faint prismatic rainbow refractions, silver palette, crystal blue, mirror white, dark navy accents
```

### boss_volcano — 화산 도깨비
**Seed:** 70007

```
massive volcanic dokkaebi, erupting mountain body, dark basalt-gray rocky skin, glowing molten orange-red cracks, volcanic crater head, magma bubbling from top, enormous stocky build, wider than tall, walking mountain, thick stubby legs rooted to ground, rocky fists dripping lava, small fierce white-hot eyes, heavy stone brow ridges, rising smoke and volcanic ash, elemental force, basalt gray palette, molten orange, lava red, ash black
```

### boss_gold — 황금 도깨비
**Seed:** 70008

```
regal dokkaebi, entirely gleaming gold, polished golden skin, brilliant light reflection, ornate golden antler horns, encrusted jewels, rubies, sapphires, emeralds, extravagant golden armor, coin motifs, elaborate filigree patterns, wide greedy grin, golden teeth, gold coin eyes with dark pupils, rings on every finger, gold chains around neck, clutching overflowing bag of gold coins, golden dokkaebi club studded with gems, pure opulence, dangerous greed, gold palette, rich amber, jewel red, jewel blue, dark accents
```

### boss_corridor — 회랑 도깨비
**Seed:** 70009

```
tall unnaturally thin dokkaebi, impossibly elongated limbs, stretched vertically, funhouse mirror proportions, pale gray-blue skin, shifting warping optical illusion, long spindly fingers, bending at wrong angles, folding unfolding impossible body, Escher-like quality, perpetual unsettling smile, narrow face, spiraling vortex eyes, flowing dark robes trailing into infinity, endless hallway effect, spatial confusion, endless recursion, gray-blue palette, dark navy, ghostly white, disorienting purple
```

### boss_yeomra — 염라대왕
**Seed:** 70010

```
King Yama, Korean underworld judge, massive imposing deity, divine authority, six arms, holding judgment scroll, punishment sword, skull, karma mirror, scales, lotus flower, elaborate royal Korean robes, deep gold and crimson red, ornate crown of judgment, intricate metalwork, aged but powerful face, deep-set golden glowing eyes, long dark beard braided with gold thread, bronze-gold skin, divine radiance, golden aura emanating from behind, absolute authority, final judge of all souls, gold palette, blood red, deep black, royal purple
```

---

## 재앙 보스 (4종)

### boss_skeleton_general — 백골대장 (윤회 3)
**Seed:** 70011

```
towering skeleton general dokkaebi, made entirely of bones, massive skeletal warrior, countless bones of different sizes, human animal and mythical bones, rusted ancient Korean general armor, dark sinew holding plates over bone frame, horned bone helmet, tattered war banner attached, empty eye sockets, cold blue ghost fire in eyes, skeletal hand gripping massive bone sword, shield made from giant skull plate, bone spurs and extra skulls as trophies, commanding military posture, death general leading army, bone white palette, rusted brown, cold blue flame, dark iron
```

### boss_ninetail_king — 구미호 왕 (윤회 5)
**Seed:** 70012

```
supreme nine-tailed fox king, evolved gumiho, massive elegant beast, standing upright, regal posture, nine enormous tails fanned out, peacock-like tail display, each tail different color, shifting illusion hues, luxurious dark fur, golden markings, fox face, ancient knowing eyes, deceptive golden glowing eyes, elaborate Korean royal crown, ceremonial robes shimmering and shifting, illusion-made fabric, floating phantom cards orbiting, some real some fake, glitching transparent cards, grand deception aura, reality bending, dark fur palette, golden markings, illusion purple-pink shimmer, phantom cyan
```

### boss_imugi — 이무기 (윤회 8)
**Seed:** 70013

```
colossal serpentine imugi, unascended dragon, enormous snake-like body, coiled and rising upward, dark blue-black iridescent scales, massive horned head, piercing yellow dragon eyes, ambition and frustration expression, partially transformed body, emerging dragon claws, wing buds breaking through serpent form, lightning crackling along scales, yeouiju dragon pearl hovering above head, glowing unattainable power, desperate competitive energy, dark blue-black scales palette, lightning yellow, dragon pearl gold-white, iridescent blue-green
```

### boss_underworld_flower — 저승꽃 (윤회 10+)
**Seed:** 70014

```
hauntingly beautiful flower entity, Underworld Flower, humanoid figure, composed entirely of ghostly luminescent flowers, central dark stem-body, pale corpse lilies, ghostly spider lilies, translucent lotus, dark camellias, face partially obscured by petals, sad beautiful eyes visible, long vine-like arms, flowers blooming at fingertips, roots extending downward like dress train, floating flower petals shedding from body, devastating beauty born from death, flowers grown from dead souls, overwhelming melancholic presence, ghostly pale pink palette, spectral white, deep purple stems, luminescent blue-green, blood red spider lily accents
```

# 인게임 보스 스프라이트 (14종: 일반 10 + 재앙 4)

> 컨셉아트(04)와 다름 — **실제 게임 화면에 표시되는 픽셀아트 스프라이트.**

## 생성 환경

```yaml
Model: Flux-dev (ComfyUI)
Resolution: 400 x 400 (내부 100x100 기준, 4x 생성)
       # → 다운스케일 100x100 (640x360 내부)
       # → 1280x720: 200x200 (2x) / 1920x1080: 300x300 (3x)
Steps: 25~30
Guidance: 3.5~4.0
Batch: 8장씩 뽑아서 최선 선택
```

## 공통 프롬프트 프리픽스

```
A low-resolution pixel art game sprite of a Korean dokkaebi demon, made of large visible square pixels like a sprite from Stardew Valley or Undertale. Drawn on a 100x100 pixel grid then scaled up — each individual pixel is clearly visible and distinguishable. Blocky jagged edges, no smooth curves, no anti-aliasing, no soft edges whatsoever. Bold flat color fills with thick black pixel outlines. No gradients, no blending between pixels. NES/SNES era sprite art aesthetic. Plain solid bright green (#00FF00) background for chroma key removal. Limited color palette: dark navy (#1A1A2E), blood red (#C41E3A), ghost fire cyan (#00D4FF), gold (#FFD700), bone white (#E8E8E8), deep purple (#6B2D5B), plus character's unique colors. Fully contained within frame with margins. Front-facing centered composition.
```

## 후처리

```
1. 8장 중 최선 선택
2. 크로마키 그린 배경 제거 → 투명 알파
3. Nearest Neighbor 다운스케일 → 100x100 (640x360 내부 크기)
4. PNG (알파) → Assets/Art/Sprites/Boss/
5. 게임 엔진이 윈도우 크기에 따라 정수 스케일 (2x=200, 3x=300)
```

---

## 일반 보스 (10종)

### boss_glutton — 먹보 도깨비
**Seed:** 70001

```
A large round-bodied gluttonous Korean dokkaebi demon. Massive protruding belly, stubby thick limbs, and a thick bull neck. Reddish-orange skin with rough texture. Short broken horns on top of a round head. An enormous mouth stretched wide showing large uneven teeth, some capped with gold. Small greedy deep-set eyes. Wearing only a tattered dark loincloth. Body covered in food stains. Standing with arms akimbo in a confident laughing pose. The character radiates menacing yet comedic energy — a dangerous overgrown child. Color palette: reddish orange, blood red accents, dark brown.
```

### boss_trickster — 장난꾸러기 도깨비
**Seed:** 70002

```
A lean mischievous Korean dokkaebi prankster demon. Wiry thin body with exaggerated long arms and fingers. Blue-gray skin with a sly grin. Two curved horns pointing backward. Large pointed ears. Wearing a ragged dark vest and shorts. One eye larger than the other giving a crazy asymmetric look. Holding a dokkaebi club (방망이) behind its back in one hand. Crouching in a ready-to-pounce stance with one finger raised as if saying "gotcha." Playful but unsettling — you can't trust this one. Color palette: blue-gray, dark teal, mischief purple accents.
```

### boss_flame — 불꽃 도깨비
**Seed:** 70003

```
A large muscular fire demon dokkaebi completely engulfed in flames. Charcoal-black cracked skin with glowing bright orange lava visible in the body fissures. Sharp angular features — pointed chin and brow ridges. Tall pointed horns fully ablaze with fire. Eyes burning intense orange-white. Smoke and ash rising from shoulders and head. Aggressive wide attack stance with clenched fists dripping liquid flame. Tattered burnt cloth remnants around the waist. Uncontrolled destructive fury made flesh. Color palette: charcoal black, flame orange, fire yellow, ember red.
```

### boss_shadow — 그림자 도깨비
**Seed:** 70004

```
A shadow demon dokkaebi made of living darkness. Semi-transparent shifting form with edges dissolving into dark smoke wisps. The body is ink-black, barely distinguishable from darkness. Only faint glowing purple eyes are clearly visible — two floating points of light in a dark mass. Wispy shadow tendrils extend from the body edges. No clear boundary between creature and surrounding shadow. Hunched predatory posture leaning forward. Suggestions of claws and teeth barely visible within the shadow mass. Faint dark purple glow at the core. The darkness itself is alive. Color palette: pure black, dark purple glow only.
```

### boss_fox — 여우 도깨비 (구미호)
**Seed:** 70005

```
A slender elegant fox spirit dokkaebi — a gumiho. Feminine form with pointed fox ears and a large fluffy nine-tailed fox tail. Pale white porcelain-like skin. Long dark hair with purple highlights. Wearing an ornate purple Korean hanbok with decorative ribbon accessories. Seductive half-lidded eyes with glowing purple irises. A subtle dangerous smile. One hand raised gracefully revealing sharp hidden claws. Faint purple magical aura shimmer around the figure. Beautiful but deeply unsettling — predator disguised as beauty. Color palette: purple, lavender, pale white, dark accents.
```

### boss_mirror — 거울 도깨비
**Seed:** 70006

```
A crystalline dokkaebi made of fractured mirror shards. Angular geometric body assembled from reflective flat panels that catch and distort light. Each mirror shard reflects a different distorted image. Two large reflective eyes showing reversed reflections of the viewer. Sharp jagged edges on limbs like broken glass. Wearing remnants of a dark robe that partially covers the mirror body. Standing in a mimicking pose — arms raised as if copying someone. An unsettling doppelganger feeling. Faint prismatic rainbow refractions along the mirror edges. Color palette: silver, crystal blue, mirror white, dark navy accents.
```

### boss_volcano — 화산 도깨비
**Seed:** 70007

```
A massive volcanic dokkaebi with a body resembling an erupting mountain. Dark basalt-gray rocky skin covered in cracks that glow molten orange-red. The head is shaped like a volcanic crater with magma bubbling from the top instead of hair. Enormous stocky build — wider than tall, like a walking mountain. Thick stubby legs rooted into the ground. Arms ending in rocky fists dripping with lava. Small fierce eyes glowing white-hot beneath heavy stone brow ridges. Smoke and volcanic ash particles rise from the body. More elemental force than creature. Color palette: basalt gray, molten orange, lava red, ash black.
```

### boss_gold — 황금 도깨비
**Seed:** 70008

```
A regal dokkaebi made entirely of gleaming gold. Polished golden skin reflecting light brilliantly. Ornate horns like golden antlers encrusted with jewels — rubies, sapphires, emeralds. Wearing extravagant golden armor with coin motifs and elaborate filigree patterns. A wide greedy grin showing golden teeth. Eyes that are literal gold coins with dark pupils. Rings on every finger, gold chains around the neck. One hand clutching a overflowing bag of gold coins, the other holding a golden dokkaebi club studded with gems. Radiating pure opulence and dangerous greed. Color palette: gold, rich amber, jewel red, jewel blue, dark accents.
```

### boss_corridor — 회랑 도깨비
**Seed:** 70009

```
A tall unnaturally thin dokkaebi with impossibly elongated limbs. Stretched vertically like a reflection in a funhouse mirror. Pale gray-blue skin that seems to shift and warp like an optical illusion. Long spindly fingers that bend at wrong angles. The body appears to fold and unfold like an impossible object — an Escher-like quality. A perpetual unsettling smile on a narrow face. Eyes that are spiraling vortexes pulling inward. Wearing flowing dark robes that trail off into infinity like an endless hallway. The creature embodies spatial confusion and endless recursion. Color palette: gray-blue, dark navy, ghostly white, disorienting purple.
```

### boss_yeomra — 염라대왕
**Seed:** 70010

```
King Yama, the Korean underworld judge. A massive imposing deity figure radiating divine authority. Six arms extending from the body, each holding a symbolic object — judgment scroll, punishment sword, skull, karma mirror, scales, lotus flower. Elaborate royal Korean robes in deep gold and crimson red. An ornate crown of judgment with intricate metalwork. Aged but powerful face with deep-set golden glowing eyes and a long dark beard braided with gold thread. Bronze-gold skin with divine radiance. A golden aura emanates from behind the figure. Absolute divine authority — the final judge of all souls. Color palette: gold, blood red, deep black, royal purple.
```

---

## 재앙 보스 (4종)

### boss_skeleton_general — 백골대장 (윤회 3)
**Seed:** 70011

```
A towering skeleton general dokkaebi made entirely of bones. A massive skeletal warrior assembled from countless bones of different sizes — human, animal, and mythical. Wearing rusted ancient Korean general armor plates held together by dark sinew over the bone frame. A horned bone helmet with a tattered war banner attached. Empty eye sockets burning with cold blue ghost fire. One skeletal hand grips a massive bone sword, the other holds a shield made from a giant skull plate. Bone spurs and extra skulls hang from the armor as trophies. Commanding military posture — even in death, this general leads an army. Color palette: bone white, rusted brown, cold blue flame, dark iron.
```

### boss_ninetail_king — 구미호 왕 (윤회 5)
**Seed:** 70012

```
The supreme nine-tailed fox king — an evolved form far beyond ordinary gumiho. A massive elegant beast standing upright in regal posture. Nine enormous tails fanned out behind the body like a peacock display, each tail a different color shifting between illusion hues. Luxurious dark fur with golden markings. A fox face with ancient knowing eyes that glow with deceptive golden light. Wearing an elaborate Korean royal crown and ceremonial robes that shimmer and shift as if made of illusion itself. Multiple floating phantom cards orbit around the figure, some real and some fake — visually glitching and transparent. An aura of grand deception — reality itself bends around this creature. Color palette: dark fur, golden markings, illusion purple-pink shimmer, phantom cyan.
```

### boss_imugi — 이무기 (윤회 8)
**Seed:** 70013

```
A colossal serpentine imugi — a dragon that has not yet ascended. An enormous snake-like body coiled and rising upward, covered in dark blue-black iridescent scales. A massive horned head with piercing yellow dragon eyes full of ambition and frustration. The body is partially transformed — some sections show emerging dragon claws and wing buds struggling to break through the serpent form. Lightning crackles along the scales. A yeouiju (dragon pearl) hovers just out of reach above the head, glowing with unattainable power. The creature radiates desperate competitive energy — it must win to finally become a dragon. Color palette: dark blue-black scales, lightning yellow, dragon pearl gold-white, iridescent blue-green.
```

### boss_underworld_flower — 저승꽃 (윤회 10+)
**Seed:** 70014

```
A hauntingly beautiful flower entity — the Underworld Flower. A humanoid figure composed entirely of ghostly luminescent flowers growing from a central dark stem-body. Each flower is a different underworld bloom — pale corpse lilies, ghostly spider lilies (피안화), translucent lotus, dark camellias. The face is partially obscured by petals, only sad beautiful eyes visible. Long vine-like arms reaching outward with flowers blooming at the fingertips. Roots extend downward like a dress train. Floating flower petals constantly shed from the body. The overall impression is devastating beauty born from death — every flower grew from a dead soul. An overwhelming melancholic presence. Color palette: ghostly pale pink, spectral white, deep purple stems, luminescent blue-green, blood red spider lily accents.
```

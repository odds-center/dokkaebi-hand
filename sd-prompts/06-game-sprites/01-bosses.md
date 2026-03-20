# 인게임 보스 스프라이트 (6종)

> 컨셉아트(04)와 다름 — **실제 게임 화면에 표시되는 픽셀아트 스프라이트.**

## 생성 환경

```yaml
Model: Flux-dev (ComfyUI)
Resolution: 600 x 600 (→ Nearest Neighbor 다운스케일 300x300)
Steps: 25~30
Guidance: 3.5~4.0
Batch: 8장씩 뽑아서 최선 선택
```

## 공통 프롬프트 프리픽스

```
A pixel art game sprite of a Korean dokkaebi demon on a transparent or solid dark background. 16-bit retro pixel art with crisp sharp pixels, no anti-aliasing. Bold flat colors with thick black outlines. Limited color palette based on game palette: dark navy (#1A1A2E), blood red (#C41E3A), ghost fire cyan (#00D4FF), gold (#FFD700), bone white (#E8E8E8), deep purple (#6B2D5B), plus the character's unique theme colors. The character is fully contained within the image with comfortable margins on all sides — nothing is cropped or cut off. Front-facing or 3/4 view, centered composition. The sprite should be recognizable even at small display sizes.
```

## 후처리

```
1. 8장 중 최선 선택
2. 배경 제거 → 투명 알파
3. Nearest Neighbor 다운스케일 → 300x300
4. PNG (알파) → Assets/Art/Sprites/Boss/
```

---

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

### boss_fox — 여우 도깨비 (구미호)
**Seed:** 70003

```
A slender elegant fox spirit dokkaebi — a gumiho. Feminine form with pointed fox ears and a large fluffy nine-tailed fox tail. Pale white porcelain-like skin. Long dark hair with purple highlights. Wearing an ornate purple Korean hanbok with decorative ribbon accessories. Seductive half-lidded eyes with glowing purple irises. A subtle dangerous smile. One hand raised gracefully revealing sharp hidden claws. Faint purple magical aura shimmer around the figure. Beautiful but deeply unsettling — predator disguised as beauty. Color palette: purple, lavender, pale white, dark accents.
```

### boss_flame — 불꽃 도깨비
**Seed:** 70004

```
A large muscular fire demon dokkaebi completely engulfed in flames. Charcoal-black cracked skin with glowing bright orange lava visible in the body fissures. Sharp angular features — pointed chin and brow ridges. Tall pointed horns fully ablaze with fire. Eyes burning intense orange-white. Smoke and ash rising from shoulders and head. Aggressive wide attack stance with clenched fists dripping liquid flame. Tattered burnt cloth remnants around the waist. Uncontrolled destructive fury made flesh. Color palette: charcoal black, flame orange, fire yellow, ember red.
```

### boss_shadow — 그림자 도깨비
**Seed:** 70005

```
A shadow demon dokkaebi made of living darkness. Semi-transparent shifting form with edges dissolving into dark smoke wisps. The body is ink-black, barely distinguishable from darkness. Only faint glowing purple eyes are clearly visible — two floating points of light in a dark mass. Wispy shadow tendrils extend from the body edges. No clear boundary between creature and surrounding shadow. Hunched predatory posture leaning forward. Suggestions of claws and teeth barely visible within the shadow mass. Faint dark purple glow at the core. The darkness itself is alive. Color palette: pure black, dark purple glow only.
```

### boss_yeomra — 염라대왕
**Seed:** 70006

```
King Yama, the Korean underworld judge. A massive imposing deity figure radiating divine authority. Six arms extending from the body, each holding a symbolic object — judgment scroll, punishment sword, skull, karma mirror, scales, lotus flower. Elaborate royal Korean robes in deep gold and crimson red. An ornate crown of judgment with intricate metalwork. Aged but powerful face with deep-set golden glowing eyes and a long dark beard braided with gold thread. Bronze-gold skin with divine radiance. A golden aura emanates from behind the figure. Absolute divine authority — the final judge of all souls. Color palette: gold, blood red, deep black, royal purple.
```

# 보스 표정 변형 (6 보스 × 3~4 표정 = 21종)

> 설계 문서에 보스별 표정 3~4종이 정의되어 있음.
> 기본 스프라이트(01-bosses.md)를 기반으로 **표정만 다른 변형**을 생성.
> Flux-dev img2img (denoising 0.3~0.4)로 기본 스프라이트에서 변형하는 것이 이상적.

## 생성 환경

```yaml
Model: Flux-dev (ComfyUI)
Resolution: 600 x 600 (→ 다운스케일 300x300)
Steps: 25~30
Guidance: 3.5
Batch: 4장
방법: 기본 보스 스프라이트를 img2img 입력으로 사용 (denoising 0.3~0.4)
      또는 txt2img로 독립 생성 후 스타일 매칭
```

## 공통 프롬프트 프리픽스

```
A pixel art game sprite of a Korean dokkaebi demon on a plain solid bright green (#00FF00) background for easy chroma key removal. 16-bit retro pixel art with crisp sharp pixels, no anti-aliasing. Bold flat colors with thick black outlines. Same character design as the base sprite but with a different facial expression. Fully contained within the image. Front-facing centered composition. No decorative background elements — character only.
```

## 후처리

```
1. 기본 스프라이트와 비교하여 전체 형태/색상 일관성 확인
2. 배경 제거 → 투명 알파
3. Nearest Neighbor 다운스케일 → 300x300
4. PNG (알파) → Assets/Art/Sprites/Boss/[보스명]_[표정].png
```

---

## 먹보 도깨비 — 4종

### boss_glutton_laugh — 웃음 (기본)
**Seed:** 83001
```
The gluttonous reddish-orange dokkaebi with a massive belly, laughing with its enormous mouth wide open. Eyes squeezed into happy crescents. All teeth visible in a joyful roaring laugh. Arms akimbo in confident pose. The default happy-eating expression.
```

### boss_glutton_eat — 먹기
**Seed:** 83002
```
The gluttonous reddish-orange dokkaebi with its enormous mouth stuffed full, cheeks puffed out. Eyes half-closed in bliss. Crumbs or food bits falling from the corners of its mouth. Both hands holding something invisible toward its mouth. Pure gluttonous satisfaction.
```

### boss_glutton_surprise — 놀람
**Seed:** 83003
```
The gluttonous reddish-orange dokkaebi with eyes wide open in shock, mouth forming a round O shape. Eyebrows raised high. Arms thrown outward in surprise. The fat body leaning backward slightly. Something unexpected just happened.
```

### boss_glutton_angry — 분노
**Seed:** 83004
```
The gluttonous reddish-orange dokkaebi with an angry snarl, teeth bared aggressively. Eyebrows furrowed deeply. Small angry veins visible on the forehead. Fists clenched at its sides. The jovial glutton turned dangerous — someone took its food.
```

---

## 장난꾸러기 도깨비 — 4종

### boss_trickster_sly — 교활 (기본)
**Seed:** 83011
```
The lean blue-gray trickster dokkaebi crouching with a sly mischievous grin. One eye winking. One finger raised in a "gotcha" gesture. Curved horns and large pointed ears. The default playful scheming expression.
```

### boss_trickster_cackle — 킬킬
**Seed:** 83012
```
The lean blue-gray trickster dokkaebi throwing its head back in a cackling laugh. Mouth open showing sharp teeth. Both hands covering its stomach from laughing too hard. Eyes squeezed shut in wicked amusement. A prank just succeeded perfectly.
```

### boss_trickster_shock — 당황
**Seed:** 83013
```
The lean blue-gray trickster dokkaebi frozen in surprise, eyes wide and asymmetric — one larger than the other. Mouth hanging open. Its dokkaebi club slipping from its grip. Ears pointed straight up in alarm. The prankster got pranked.
```

### boss_trickster_angry — 짜증
**Seed:** 83014
```
The lean blue-gray trickster dokkaebi with an irritated scowl, arms crossed. One eye twitching. Sharp teeth grinding together. Ears flattened back against the head. Tail (if visible) lashing. The trick failed and it's not happy.
```

---

## 여우 도깨비 — 4종

### boss_fox_seductive — 유혹 (기본)
**Seed:** 83021
```
The elegant fox spirit dokkaebi with half-lidded purple eyes and a subtle dangerous smile. One hand raised gracefully with hidden claws. Fox tail curled elegantly. Long dark hair with purple highlights flowing. The default beautiful but threatening expression.
```

### boss_fox_reveal — 본성
**Seed:** 83022
```
The fox spirit dokkaebi with its true nature showing through — the beautiful face cracks to reveal the skull underneath. One eye is still beautiful purple, the other is a dark hollow socket. The smile becomes a predatory grin with sharp fangs. Beauty and death coexisting in one face.
```

### boss_fox_laugh — 조롱
**Seed:** 83023
```
The fox spirit dokkaebi covering its mouth with one sleeve, laughing mockingly. Eyes narrowed in cruel amusement. The laugh is elegant and dismissive — looking down on the player. Fox tail swaying with amusement.
```

### boss_fox_hurt — 고통
**Seed:** 83024
```
The fox spirit dokkaebi recoiling in pain, the beautiful composure broken. Hair disheveled, eyes wide with shock and anger. One hand clutching a wound. The porcelain mask cracked — underneath is fury. Fox ears flattened back.
```

---

## 불꽃 도깨비 — 4종

### boss_flame_rage — 분노 (기본)
**Seed:** 83031
```
The muscular fire dokkaebi with charcoal-black cracked skin, engulfed in flames. Burning eyes of intense orange-white. Aggressive wide attack stance with clenched flaming fists. The default raging inferno expression.
```

### boss_flame_eruption — 폭발
**Seed:** 83032
```
The fire dokkaebi mid-eruption — flames exploding outward from every crack in its body. Mouth open in a roar of pure destructive fury. Arms thrown wide as fire blasts from its chest. Eyes blazing white-hot. Maximum flame output.
```

### boss_flame_smolder — 잠잠
**Seed:** 83033
```
The fire dokkaebi with flames reduced to smoldering embers. Eyes glowing a dim orange instead of white-hot. Arms hanging at sides. Cracks in skin glow faintly. The fire is low but not out — like coals waiting to reignite. Quiet menace.
```

### boss_flame_extinguish — 소화 (패배)
**Seed:** 83034
```
The fire dokkaebi with flames dying out, smoke rising from its darkening body. Eyes flickering and fading. One knee on the ground. Cracks in skin turning from orange to gray as the fire dies. Defeated — the inferno is ending.
```

---

## 그림자 도깨비 — 3종

### boss_shadow_lurk — 잠복 (기본)
**Seed:** 83041
```
The shadow dokkaebi as a barely visible dark mass with only two faint purple glowing eyes. Hunched predatory posture. Shadow tendrils extending outward. The default lurking-in-darkness expression. Almost invisible.
```

### boss_shadow_manifest — 현현
**Seed:** 83042
```
The shadow dokkaebi partially solidifying — more visible than usual. The dark form is denser and more defined, with claws and teeth clearly visible. Eyes blazing brighter purple. Shadow tendrils reaching aggressively outward. It has decided to attack directly.
```

### boss_shadow_dissolve — 소멸 (패배)
**Seed:** 83043
```
The shadow dokkaebi dissolving into scattered wisps of darkness. The form is breaking apart into fragments of shadow that drift away. The purple eyes are splitting and fading. The darkness is dispersing — the shadow loses coherence and fades to nothing.
```

---

## 염라대왕 — 4종

### boss_yeomra_judge — 심판 (기본)
**Seed:** 83051
```
King Yama with a solemn authoritative expression, golden eyes seeing through all deception. Six arms holding symbolic objects. Elaborate gold and red robes. The default expression of absolute divine judgment — neither angry nor merciful, simply absolute.
```

### boss_yeomra_wrath — 진노
**Seed:** 83052
```
King Yama with divine wrath — golden eyes blazing with fury. Six arms raised in attack position, each weapon glowing with power. Face contorted in righteous anger. Golden aura intensifying to blinding brilliance. The judge has passed sentence — punishment.
```

### boss_yeomra_mercy — 자비
**Seed:** 83053
```
King Yama with an unexpected expression of deep sadness and compassion. Golden eyes softened. The lotus flower in one hand glows brighter while weapons are lowered. A single golden tear on the divine face. Even the judge of the dead feels sorrow.
```

### boss_yeomra_defeat — 인정 (패배)
**Seed:** 83054
```
King Yama with a rare expression of grudging respect. Golden eyes wide in surprise. A slight nod of acknowledgment. Six arms lowered in acceptance. The golden aura dims respectfully. The supreme judge recognizes a worthy soul — you have earned passage.
```

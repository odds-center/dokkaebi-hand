# 동료 도깨비 스프라이트 (7종)

> 이긴 보스를 동료로 부리는 시스템. 보스 스프라이트와 같은 캐릭터지만
> **우호적인 표정/포즈 + 작은 크기**로 차별화.

## 생성 환경

```yaml
Model: Pony Diffusion V6 XL (ComfyUI)
LoRA: Binding of Isaac Style v2.1 (strength 0.70)
Resolution: 320 x 480 → 다운스케일 240x360 (@1920x1080)
Sampler: euler_a
Steps: 30
CFG: 7
Batch: 4~8장
```

## 공통 프롬프트 프리픽스

```
score_9, score_8_up, score_7_up, pixel art, game assets, chibi, simple green background, small friendly companion sprite, tamed Korean dokkaebi, loyal helpful expression, smaller than boss version, front-facing centered, flat colors, thick black outlines, dark fantasy, fully contained with margins, character only
```

## 공통 네거티브 프롬프트

```
score_4, score_3, score_2, score_1, blurry, photo, realistic, 3d render, smooth shading, anti-aliasing, gradient, soft edges, watercolor, text, watermark, signature
```

## 후처리

```
1. 배경 제거 → 투명 알파
2. Nearest Neighbor 다운스케일 → 120x180
3. PNG (알파) → Assets/Art/Sprites/Companion/
```

---

### comp_glutton — 먹보 도깨비 (탐식)
**Seed:** 71001

```
small round-bodied dokkaebi sitting happily, reddish-orange skin, broken horns, friendly goofy grin, chubby mascot body, holding small rice cake in one hand, sitting cross-legged relaxed, cheerful crescent eyes, lovable glutton companion, color palette reddish orange warm brown
```

### comp_trickster — 장난꾸러기 도깨비 (속임수)
**Seed:** 71002

```
small lean dokkaebi crouching playfully, blue-gray skin, curved horns, mischievous wink, holding dokkaebi club over one shoulder, one hand peace sign, crouching like friendly imp, helpful trickster ally, color palette blue-gray teal
```

### comp_fox — 여우 도깨비 (환혹)
**Seed:** 71003

```
small elegant fox spirit sitting gracefully, tail curled around body, pale skin, fox ears, warm gentle eyes, simplified purple hanbok, one hand on lap other holding small glowing orb, wise mystical companion, color palette soft purple lavender pale white
```

### comp_mirror — 거울 도깨비 (반사)
**Seed:** 71004

```
small crystalline dokkaebi, reflective mirror-like surfaces, angular geometric body, flat reflective panels for skin, calm neutral expression, holding small round mirror in both hands, body catching and reflecting light in multiple colors, peaceful standing pose, enigmatic mirror spirit ally, color palette silver crystal blue mirror reflections
```

### comp_flame — 불꽃 도깨비 (소각)
**Seed:** 71005

```
small fire dokkaebi, gentle warming flames not raging inferno, charcoal-black cracked skin, softer orange glow in cracks like campfire embers, calm serious expression, arms crossed confident non-threatening, small controlled flames above horns like candles, controlled warming fire, color palette charcoal warm ember orange gentle flame
```

### comp_shadow — 그림자 도깨비 (잠식)
**Seed:** 71006

```
small shadow dokkaebi hovering slightly, more defined cat-like silhouette, glowing purple eyes softer and curious, small shadow wisps trailing like smoky tail, subtle head tilt suggesting curiosity, quiet shadow cat companion, color palette dark gray-black soft purple glow
```

### comp_boatman — 뱃사공 (항해)
**Seed:** 71007

```
small Sanzu River ferryman companion, weathered elderly Korean man, cone-shaped straw hat casting shadow over face, simple dark ferryman clothes, holding miniature oar in one hand, faint knowing smile under hat brim, standing calmly with stoic dignity, mysterious boatman traveling with you, color palette dark browns straw yellow gray
```

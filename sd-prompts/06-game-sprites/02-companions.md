# 동료 도깨비 스프라이트 (7종)

> 이긴 보스를 동료로 부리는 시스템. 보스 스프라이트와 같은 캐릭터지만
> **우호적인 표정/포즈 + 작은 크기**로 차별화.

## 생성 환경

```yaml
Model: Flux-dev (ComfyUI)
Resolution: 160 x 240 (내부 40x60 기준, 4x 생성)
       # → 다운스케일 40x60 / 윈도우: 2x=80x120, 3x=120x180
Steps: 25~30
Guidance: 3.5
Batch: 4~8장
```

## 공통 프롬프트 프리픽스

```
A small low-resolution pixel art companion sprite of a tamed Korean dokkaebi, made of large visible square pixels like a sprite from Stardew Valley. Drawn on a 40x60 pixel grid then scaled up — each individual pixel is clearly visible. Blocky jagged edges, no smooth curves, no anti-aliasing. Bold flat color fills with thick black pixel outlines. No gradients, no blending between pixels. The character looks loyal and helpful — tamed ally. Smaller and less threatening than boss version. Plain solid bright green (#00FF00) background for chroma key. Fully contained with margins. Centered composition. Character only, no decorative elements.
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
A small round-bodied dokkaebi sitting happily. Same reddish-orange skin and broken horns as the boss version, but with a friendly goofy grin instead of a menacing laugh. Smaller belly, more like a chubby mascot. Holding a small rice cake in one hand. Sitting cross-legged on the ground in a relaxed pose. Eyes are cheerful crescents. The greedy monster is now a lovable glutton companion. Color palette: reddish orange, warm brown.
```

### comp_trickster — 장난꾸러기 도깨비 (속임수)
**Seed:** 71002

```
A small lean dokkaebi crouching playfully. Same blue-gray skin and curved horns as the boss, but with a mischievous wink instead of a crazy stare. Holding its dokkaebi club casually over one shoulder. One hand making a peace sign. Crouching like a friendly imp ready to help with a prank. The chaos gremlin is now a helpful trickster ally. Color palette: blue-gray, teal.
```

### comp_fox — 여우 도깨비 (환혹)
**Seed:** 71003

```
A small elegant fox spirit sitting gracefully with tail curled around its body. Same pale skin and fox ears as the boss version, but with warm gentle eyes instead of predatory ones. Wearing a simplified purple hanbok. One hand resting on its lap, the other holding a small glowing orb. The dangerous beauty is now a wise mystical companion. Color palette: soft purple, lavender, pale white.
```

### comp_mirror — 거울 도깨비 (반사)
**Seed:** 71004

```
A small crystalline dokkaebi made of reflective mirror-like surfaces. Angular geometric body with flat reflective panels for skin. A calm neutral expression. Holding a small round mirror in both hands. The body catches and reflects light in multiple colors. Peaceful standing pose. An enigmatic mirror spirit ally. Color palette: silver, crystal blue, mirror reflections.
```

### comp_flame — 불꽃 도깨비 (소각)
**Seed:** 71005

```
A small fire dokkaebi with gentle warming flames instead of raging inferno. Same charcoal-black cracked skin but with softer orange glow in the cracks — like cozy campfire embers. A calm serious expression instead of pure rage. Arms crossed in a confident but non-threatening pose. Small controlled flames float above its horns like candles. The raging inferno is now a controlled warming fire. Color palette: charcoal, warm ember orange, gentle flame.
```

### comp_shadow — 그림자 도깨비 (잠식)
**Seed:** 71006

```
A small shadow dokkaebi hovering slightly off the ground. Less formless than the boss — more defined cat-like silhouette shape. Same glowing purple eyes but softer and curious instead of predatory. Small shadow wisps trail behind it like a smoky tail. A subtle head tilt suggesting curiosity. The terrifying void is now a quiet shadow cat companion. Color palette: dark gray-black, soft purple glow.
```

### comp_boatman — 뱃사공 (항해)
**Seed:** 71007

```
A small pixel art figure of the Sanzu River ferryman as a companion. Weathered elderly Korean man with cone-shaped straw hat casting shadow over face. Wearing simple dark ferryman clothes. Holding a miniature oar in one hand. A faint knowing smile visible under the hat brim. Standing calmly with stoic dignity. The mysterious boatman now travels with you. Color palette: dark browns, straw yellow, gray.
```

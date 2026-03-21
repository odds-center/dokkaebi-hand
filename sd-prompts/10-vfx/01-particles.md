# VFX 파티클 텍스처 (6종)

> 게임 내 시각 효과에 사용되는 파티클/이펙트 텍스처.
> 현재 코드에서 프로시저럴로 생성하는 것을 고품질 에셋으로 교체.

## 생성 환경

```yaml
Model: Pony Diffusion V6 XL (ComfyUI)
LoRA: Binding of Isaac Style v2.1 (strength 0.50)
Resolution: 256 x 256 (정사각형)
Sampler: euler_a
Steps: 25~30
CFG: 7
Batch: 4장
```

## 공통 프롬프트 프리픽스

```
score_9, score_8_up, score_7_up, pixel art, game assets, chibi, simple black background, VFX particle texture, solid black background for alpha conversion, blocky jagged edges, no smooth curves, no anti-aliasing, flat colors, thick black outlines, stepped brightness levels, NES SNES era particle effect, centered composition, fully contained with margins
```

## 공통 네거티브 프롬프트

```
score_4, score_3, score_2, score_1, blurry, photo, realistic, 3d render, smooth shading, anti-aliasing, gradient, soft edges, watercolor, text, watermark, signature
```

## 후처리

```
1. 검은 배경 → 알파 채널로 변환 (밝은 부분만 남김)
2. PNG (알파) → Assets/Art/VFX/
3. Unity에서 Additive 블렌딩으로 사용
```

## Unity 임포트

```
Texture Type: Sprite (2D and UI)
Filter Mode: Point (Nearest Neighbor) ← 픽셀아트 통일
Compression: None
```

---

### vfx_ghost_fire — 도깨비불 파티클
**Seed:** 79001

```
single ghostly flame particle, large visible square pixels, vivid cyan-blue pixel blocks, brighter white-cyan core, elongated upward teardrop shape, stacked pixel blocks wider at bottom single pixel at top, stair-step edges, stepped brightness white core cyan dark cyan, single dokkaebi ghost fire, color vivid cyan-blue white-cyan center
```

### vfx_ink_bloom — 먹물 퍼짐 파티클
**Seed:** 79002

```
circular ink bloom splash, large visible square pixels, gray-white pixel cluster, irregular blocky edges, scattered pixel blocks radiating from bright center, brightest white center darker gray outer, jagged irregular pixel block shape not smooth circle, ink bloom effect for yokbo activation, color white center pixels gray outer pixels
```

### vfx_blood_splash — 핏빛 스플래시 파티클
**Seed:** 79003

```
blood splash particle, large visible square pixels, vivid crimson red pixel blocks splattered outward, bright red center dark red scattered outer, small secondary pixel dots around main cluster, blocky jagged splash shape, damage effect, color vivid crimson red center dark red scattered pixels
```

### vfx_gold_sparkle — 금빛 광채 파티클
**Seed:** 79004

```
golden star sparkle particle, large visible square pixels, four-pointed star from pixel blocks, cross pattern with single pixels extending four directions, bright gold center pixel gold arm pixels extending outward, stepped brightness no smooth glow, classic NES SNES sparkle effect, color bright gold pixels white center pixel
```

### vfx_burning_paper — 종이 타래 파티클
**Seed:** 79005

```
burning paper fragment particle, small irregular rectangular hanji paper shape, burning at edges, center cream-beige intact paper, edges charred dark brown, glowing orange active fire border, small ember sparks at burning edge, card destruction deck-burning effect, color cream paper center brown char edge orange fire border
```

### vfx_smoke_wisp — 연기/안개 파티클
**Seed:** 79006

```
smoke wisp particle, large visible square pixels, loose cluster of gray pixel blocks, not solid shape scattered pixels forming rough cloud, lighter gray center darker gray edges, blocky chunky clearly pixel art not smooth fog, smoke ghost atmosphere effect, color light gray center pixels dark gray scattered edge pixels
```

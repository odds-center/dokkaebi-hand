# VFX 파티클 텍스처 (6종)

> 게임 내 시각 효과에 사용되는 파티클/이펙트 텍스처.
> 현재 코드에서 프로시저럴로 생성하는 것을 고품질 에셋으로 교체.

## 생성 환경

```yaml
Model: Flux-dev (ComfyUI)
Resolution: 256 x 256 (정사각형)
Steps: 20~25
Guidance: 3.5
Batch: 4장
```

## 공통 프롬프트 프리픽스

```
A single low-resolution pixel art VFX particle texture on a solid black (#000000) background — the black will be converted to transparency via alpha channel in post-processing. Made of large visible square pixels — each pixel clearly distinguishable. Blocky jagged edges, no smooth curves, no anti-aliasing, no soft gradients. The particle shape is made of bright colored pixel blocks on black, with stepped brightness levels (no smooth falloff). Bold flat color fills. NES/SNES era particle effect aesthetic. Centered composition. Only the pixel particle shape, nothing else.
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
A single ghostly flame particle in pixel art on solid black background. Made of large visible square pixels. The flame is vivid cyan-blue pixel blocks with a brighter white-cyan core. Elongated upward teardrop shape built from stacked pixel blocks — wider at bottom, single pixel at top. Blocky jagged stair-step edges, no smooth curves. Stepped brightness: white core → cyan → dark cyan → black. A single dokkaebi ghost fire. Color: vivid cyan-blue, white-cyan center.
```

### vfx_ink_bloom — 먹물 퍼짐 파티클
**Seed:** 79002

```
A circular ink bloom splash in pixel art on solid black background. Made of large visible square pixels. A gray-white pixel cluster with irregular blocky edges — scattered pixel blocks radiating from a bright center. The center is brightest white pixels, outer pixels are darker gray. Jagged irregular shape made of pixel blocks — not a smooth circle. Used for ink bloom effect when yokbo activates. Color: white center pixels, gray outer pixels.
```

### vfx_blood_splash — 핏빛 스플래시 파티클
**Seed:** 79003

```
A blood splash particle in pixel art on solid black background. Made of large visible square pixels. Vivid crimson red pixel blocks splattered outward — the center is bright red pixels, outer scattered single pixels in dark red. Small secondary pixel dots scattered around main cluster. Blocky jagged splash shape. Used for damage effects. Color: vivid crimson red center, dark red scattered pixels.
```

### vfx_gold_sparkle — 금빛 광채 파티클
**Seed:** 79004

```
A golden star sparkle particle in pixel art on solid black background. Made of large visible square pixels. A four-pointed star shape built from pixel blocks — cross pattern with single pixels extending in four directions. Bright gold center pixel, gold arm pixels extending outward. No smooth glow — stepped brightness in pixel blocks only. Classic NES/SNES sparkle effect. Color: bright gold pixels, white center pixel.
```

### vfx_burning_paper — 종이 타래 파티클
**Seed:** 79005

```
A burning paper fragment particle on solid black background. A small irregular rectangular shape like a piece of hanji paper that is burning at its edges. The center is cream-beige (the intact paper), the edges are charred dark brown transitioning to glowing orange where the fire is actively burning. Small ember sparks at the burning edge. Used for card destruction and deck-burning effects. Color: cream paper center, brown char edge, orange fire border.
```

### vfx_smoke_wisp — 연기/안개 파티클
**Seed:** 79006

```
A smoke wisp particle in pixel art on solid black background. Made of large visible square pixels. A loose cluster of gray pixel blocks — not a solid shape but scattered pixels forming a rough cloud. Lighter gray pixels at center, darker gray single pixels at edges. Blocky and chunky — clearly pixel art, not smooth fog. Used for smoke, ghost effects, atmosphere. Color: light gray center pixels, dark gray scattered edge pixels.
```

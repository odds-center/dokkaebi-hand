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
A single VFX particle texture sprite on a solid black background. Simple soft-edged shape designed to be used as a game particle effect texture. The shape glows from center outward with smooth falloff. No hard outlines — soft organic edges that blend into the black background. The black background will be used as transparency in-game. Centered composition.
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
Filter Mode: Bilinear (VFX는 부드럽게)
Compression: None
```

---

### vfx_ghost_fire — 도깨비불 파티클
**Seed:** 79001

```
A single ghostly flame particle on solid black background. The flame is vivid cyan-blue with a brighter white-cyan core at the center. The shape is an elongated upward teardrop — wider at the bottom, tapering to a wispy point at the top. The edges are soft and diffused, fading smoothly into the black background. The glow is ethereal and supernatural — a single dokkaebi ghost fire. Color: vivid cyan-blue, white-cyan hot center.
```

### vfx_ink_bloom — 먹물 퍼짐 파티클
**Seed:** 79002

```
A circular ink bloom splash on solid black background. A dark gray-black ink splatter shape with organic irregular edges — like a drop of sumi-e ink hitting wet paper and spreading outward. The center is darkest (near-white for alpha purposes), edges fade to nothing. The shape has natural organic irregularity — not a perfect circle but a natural fluid splash. Used for the ink bloom effect when yokbo activates. Color: dark gray-white (will appear as ink when alpha-converted).
```

### vfx_blood_splash — 핏빛 스플래시 파티클
**Seed:** 79003

```
A blood splash particle on solid black background. A vivid crimson red fluid splash shape — like a droplet of blood hitting a surface. The center is brightest hot red, edges splash outward in organic tendrils. Small secondary droplets scatter around the main splash. Dramatic and visceral. Used for damage and boss counter-attack effects. Color: vivid crimson red, bright center fading outward.
```

### vfx_gold_sparkle — 금빛 광채 파티클
**Seed:** 79004

```
A golden star sparkle particle on solid black background. A four-pointed star shape with soft glowing edges — the classic RPG sparkle effect. Bright warm gold at the center, rays extend outward in four directions with soft falloff. A faint secondary glow halo surrounds the star shape. Used for yokbo completion, boss defeat, and golden effects. Color: warm brilliant gold, white-hot center point.
```

### vfx_burning_paper — 종이 타래 파티클
**Seed:** 79005

```
A burning paper fragment particle on solid black background. A small irregular rectangular shape like a piece of hanji paper that is burning at its edges. The center is cream-beige (the intact paper), the edges are charred dark brown transitioning to glowing orange where the fire is actively burning. Small ember sparks at the burning edge. Used for card destruction and deck-burning effects. Color: cream paper center, brown char edge, orange fire border.
```

### vfx_smoke_wisp — 연기/안개 파티클
**Seed:** 79006

```
A soft smoke wisp particle on solid black background. A diffuse cloud-like shape with very soft edges — a gentle puff of smoke or mist. The shape is roughly circular but with organic wisping tendrils at the edges. Light gray-white at the center, fading smoothly to nothing at the edges. Very soft and atmospheric — no hard edges anywhere. Used for fog, smoke, ghost effects, and atmosphere. Color: light gray-white, extremely soft and diffused.
```

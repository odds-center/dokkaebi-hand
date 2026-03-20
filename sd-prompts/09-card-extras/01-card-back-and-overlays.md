# 카드 뒷면 + 강화 오버레이

---

## 1. 카드 뒷면 디자인 (1종)

> 48장 전체가 공유하는 단일 뒷면 디자인.
> 한지 배경 + 태극/팔괘 문양 + 도깨비불 — 전통과 저승의 조화.

### 생성 환경

```yaml
Model: Flux-dev (ComfyUI)
Resolution: 270 x 390 (카드 크기 3배)
Steps: 25~30
Guidance: 3.5
Batch: 8장
```

### card_back — 카드 뒷면
**Seed:** 78001

```
A low-resolution pixel art hwatu card back design, made of large visible square pixels where each pixel is clearly distinguishable. Drawn on a 32x45 pixel grid. Blocky jagged edges, no smooth curves, no anti-aliasing, no gradients, no blending between pixels. The design features a traditional Korean taegeuk (yin-yang) symbol at the center in red and blue, surrounded by a circular border of eight trigram (팔괘) symbols. The background is aged hanji paper cream-ivory color with subtle paper fiber texture. A decorative geometric border pattern frames the entire design — traditional Korean interlocking rectangular pattern in dark navy and gold. Four small cyan dokkaebi ghost flames sit in each corner as underworld accents. The overall impression is a blend of traditional Korean cosmology and supernatural underworld energy. All elements are fully contained within the image with comfortable margins. Bold flat colors with thick black outlines throughout. Color palette: cream hanji background, red-blue taegeuk, dark navy border, gold accents, cyan ghost flames.
```

### 후처리

```
1. 8장 중 문양이 가장 깔끔한 것 선택
2. 대칭성 확인 — 포토샵에서 좌우/상하 대칭 보정
3. Nearest Neighbor 다운스케일 → 90x130
4. PNG → Assets/Art/Cards/card_back.png
```

---

## 2. 카드 강화 등급 오버레이 (5종)

> 카드 강화 시 카드 프레임 위에 올라가는 시각 효과 레이어.
> 등급이 올라갈수록 더 화려한 테두리/이펙트.

### 생성 환경

```yaml
Model: Flux-dev (ComfyUI)
Resolution: 270 x 390 (카드 크기 3배)
Steps: 20~25
Guidance: 3.5
Batch: 4장
```

### 공통 프롬프트 프리픽스

```
A low-resolution pixel art card overlay frame effect for a Korean card game, made of large visible square pixels. Each individual pixel clearly visible. Blocky jagged edges, no smooth curves, no anti-aliasing, no gradients, no blending between pixels. Bold flat color fills with thick black pixel outlines. This is an overlay ON TOP of an existing card — center must be completely empty/transparent (green #00FF00 background showing through). Only border edges and corners have visual effects. Central 70% must be completely clear. Fully contained.
```

### enhance_tier0 — 기본 (★)
**Seed:** 78011

```
A simple thin dark border frame with no special effects. Plain clean edge — just a basic card outline. Single tiny star symbol at the bottom center. Minimal and understated. Most of the image is empty transparent space. Color: dark navy thin border.
```

### enhance_tier1 — 연마 (★★)
**Seed:** 78012

```
A slightly thicker border frame with a faint warm glow along the edges. The border has subtle metallic bronze shimmer. Two small star symbols at the bottom center. A very faint warm amber aura hugs the border corners. Most of the image is empty transparent space — only edges glow. Color: warm bronze border with amber edge glow.
```

### enhance_tier2 — 신통 (★★★)
**Seed:** 78013

```
A glowing border frame with visible silver-blue energy running along the edges. Small sparkle particles appear at the four corners. Three star symbols at the bottom glow faintly. The border pulses with a subtle inner light. The energy effect stays tightly on the border — the center is completely clear. Color: silver-blue glowing border, sparkle white corners.
```

### enhance_tier3 — 전설 (★★★★)
**Seed:** 78014

```
A dramatic golden border frame with brilliant golden energy flowing along all edges. The corners have ornate golden filigree decorations that extend slightly inward. Four star symbols at the bottom blaze with gold light. Faint golden particles drift along the border. The border itself appears to be made of liquid gold. Center is completely clear — only edges are decorated. Color: brilliant gold border, warm golden particles, ornate corner decorations.
```

### enhance_tier4 — 해탈 (★★★★★)
**Seed:** 78015

```
A transcendent border frame with prismatic rainbow energy flowing along all edges. The corners have lotus flower motifs radiating divine light. Five star symbols at the bottom blaze with white-gold brilliance. The border shimmers with iridescent colors that shift between gold, white, and celestial blue. Faint mandala patterns appear in the corner decorations. This is the maximum tier — nirvana achieved. Center is completely clear. Color: prismatic iridescent border, white-gold stars, lotus corner motifs.
```

### 오버레이 후처리

```
1. 중앙 영역 완전 투명 확인 — 카드 일러스트가 보여야 함
2. 테두리 효과만 남기고 배경 제거
3. Nearest Neighbor 다운스케일 → 90x130
4. PNG (알파) → Assets/Art/Cards/enhance_tier_*.png
5. 코드에서 카드 스프라이트 위에 오버레이로 합성
```

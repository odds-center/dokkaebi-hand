# 카드 뒷면 + 강화 오버레이

---

## 1. 카드 뒷면 디자인 (1종)

> 48장 전체가 공유하는 단일 뒷면 디자인.
> 한지 배경 + 태극/팔괘 문양 + 도깨비불 — 전통과 저승의 조화.

### 생성 환경

```yaml
Model: Pony Diffusion V6 XL (ComfyUI)
LoRA: Binding of Isaac Style v2.1 (strength 0.65)
Resolution: 270 x 390 (카드 크기 3배)
Sampler: euler_a
Steps: 25~30
CFG: 7
Batch: 8장
```

### card_back — 카드 뒷면
**Seed:** 78001

```
hwatu card back design, 32x45 pixel grid, large visible square pixels, taegeuk yin-yang symbol at center in red and blue, circular border of eight trigram symbols, aged hanji paper cream-ivory background, subtle paper fiber texture, decorative geometric border pattern, traditional Korean interlocking rectangular pattern in dark navy and gold, four small cyan dokkaebi ghost flames in each corner, blend of traditional Korean cosmology and supernatural underworld energy, bold flat colors
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
Model: Pony Diffusion V6 XL (ComfyUI)
LoRA: Binding of Isaac Style v2.1 (strength 0.65)
Resolution: 270 x 390 (카드 크기 3배)
Sampler: euler_a
Steps: 25~30
CFG: 7
Batch: 4장
```

### 공통 프롬프트 프리픽스

```
score_9, score_8_up, score_7_up, pixel art, game assets, chibi, simple green background, card overlay frame effect, Korean card game, blocky jagged edges, no smooth curves, no anti-aliasing, flat colors, thick black outlines, overlay on top of existing card, empty transparent center, border edges and corners only, fully contained with margins
```

### 공통 네거티브 프롬프트

```
score_4, score_3, score_2, score_1, blurry, photo, realistic, 3d render, smooth shading, anti-aliasing, gradient, soft edges, watercolor, text, watermark, signature
```

### enhance_tier0 — 기본 (★)
**Seed:** 78011

```
simple thin dark border frame, no special effects, plain clean edge basic card outline, single tiny star symbol at bottom center, minimal understated, mostly empty transparent space, color dark navy thin border
```

### enhance_tier1 — 연마 (★★)
**Seed:** 78012

```
slightly thicker border frame, faint warm glow along edges, subtle metallic bronze shimmer, two small star symbols at bottom center, very faint warm amber aura at border corners, mostly empty transparent space, color warm bronze border amber edge glow
```

### enhance_tier2 — 신통 (★★★)
**Seed:** 78013

```
glowing border frame, visible silver-blue energy running along edges, small sparkle particles at four corners, three star symbols at bottom glowing faintly, border pulsing with subtle inner light, energy stays tightly on border center completely clear, color silver-blue glowing border sparkle white corners
```

### enhance_tier3 — 전설 (★★★★)
**Seed:** 78014

```
dramatic golden border frame, brilliant golden energy flowing along all edges, ornate golden filigree decorations at corners extending slightly inward, four star symbols at bottom blazing gold light, faint golden particles along border, border of liquid gold, center completely clear edges only, color brilliant gold border warm golden particles ornate corner decorations
```

### enhance_tier4 — 해탈 (★★★★★)
**Seed:** 78015

```
transcendent border frame, prismatic rainbow energy flowing along all edges, lotus flower motifs at corners radiating divine light, five star symbols at bottom blazing white-gold brilliance, iridescent shimmer shifting gold white celestial blue, faint mandala patterns in corner decorations, maximum tier nirvana achieved, center completely clear, color prismatic iridescent border white-gold stars lotus corner motifs
```

### 오버레이 후처리

```
1. 중앙 영역 완전 투명 확인 — 카드 일러스트가 보여야 함
2. 테두리 효과만 남기고 배경 제거
3. Nearest Neighbor 다운스케일 → 90x130
4. PNG (알파) → Assets/Art/Cards/enhance_tier_*.png
5. 코드에서 카드 스프라이트 위에 오버레이로 합성
```

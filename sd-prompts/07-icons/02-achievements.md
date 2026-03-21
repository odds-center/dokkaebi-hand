# 업적(Achievement) 아이콘 (22종)

> **아이작 스타일** — 1:1 정사각, 투명 배경, 오브젝트만. 심플한 도트 실루엣.
> 64x64px 최종 크기. 카테고리 테두리는 게임 UI에서 처리.

## 생성 환경

```yaml
Model: Pony Diffusion V6 XL (ComfyUI)
LoRA: Binding of Isaac Style v2.1 (strength 0.80)
Resolution: 176 x 176 → 다운스케일 132x132 (@1920x1080)
Sampler: euler_a
Steps: 25
CFG: 7
Batch: 4장
```

## 공통 프롬프트 프리픽스

```
score_9, score_8_up, score_7_up, pixel art, game assets, chibi, simple green background, single achievement icon, one simple recognizable object centered, flat colors, thick black outlines, no ground, no shadow, no pedestal, square composition, only the item, nothing else
```

## 공통 네거티브 프롬프트

```
score_4, score_3, score_2, score_1, blurry, photo, realistic, 3d render, smooth shading, anti-aliasing, gradient, soft edges, watercolor, text, watermark, signature
```

## 후처리

```
1. 크로마키 그린 배경 제거 → 투명 알파
2. Nearest Neighbor 다운스케일 → 64x64
3. PNG (알파) → Assets/Art/Icons/Achievement/
4. 게임 UI에서 카테고리별 테두리 색 렌더링 (진행=흰색, 족보=금색, 고스톱=빨강, 특수=보라, 히든=검정)
```

---

## 진행 (Progress) — 7종

### ach_first_step — 첫 발걸음
**Seed:** 74001
```
single pale blue glowing footprint, one bare foot impression, simple step mark
```

### ach_explorer — 저승 탐험가
**Seed:** 74002
```
warm orange paper lantern floating, small glow, simple round lantern shape
```

### ach_yeomra_judgment — 염라의 심판
**Seed:** 74003
```
golden balance scale, perfectly balanced, simple two-pan scale
```

### ach_spiral_2 — 두 번째 윤회
**Seed:** 74004
```
two interlinked spiral circles, one silver one gold, simple double loop
```

### ach_spiral_5 — 저승의 전설
**Seed:** 74005
```
five small cyan ghost flames, arranged in circle crown formation, simple flame ring
```

### ach_spiral_10 — 무한의 끝
**Seed:** 74006
```
golden infinity symbol, cracks breaking at edges, simple cracking infinity
```

### ach_tenth_death — 열 번째 죽음
**Seed:** 74007
```
ten tiny white skulls, two rows of five, simple skull grid
```

---

## 족보 (Yokbo) — 5종

### ach_three_gwang — 삼광 달성
**Seed:** 74011
```
three golden stars, arranged in triangle, simple three-star triangle
```

### ach_four_gwang — 사광 달성
**Seed:** 74012
```
four golden stars, arranged in diamond pattern, simple four-star diamond
```

### ach_five_gwang — 오광 달성
**Seed:** 74013
```
five brilliant golden stars, arranged in pentagon, glowing intensely, simple five-star formation
```

### ach_score_10k — 만점왕
**Seed:** 74014
```
bold golden text reading 10K, small sparkle marks, simple text icon
```

### ach_score_1m — 백만장자
**Seed:** 74015
```
bold golden text reading 1M, golden light rays behind, simple text icon
```

---

## 고스톱 (GoStop) — 4종

### ach_first_go — 첫 Go
**Seed:** 74021
```
single bold red arrow pointing right, speed trail, simple forward arrow
```

### ach_bold_choice — 대담한 선택
**Seed:** 74022
```
two bold red arrows stacked, both pointing right, simple double arrow
```

### ach_mad_gambler — 미친 도박사
**Seed:** 74023
```
three blazing red arrows pointing right, fire trails, simple triple arrow
```

### ach_greed_price — 욕심의 대가
**Seed:** 74024
```
broken red arrow snapped in half, fragments falling, simple broken arrow
```

---

## 특수 (Special) — 3종

### ach_no_talisman — 무부적
**Seed:** 74031
```
empty square outline, red X across it, simple crossed-out slot
```

### ach_curse_lover — 저주 수용자
**Seed:** 74032
```
three dark purple talisman papers stacked, dark wisps rising, simple cursed papers
```

### ach_nirvana_card — 해탈
**Seed:** 74033
```
small card shape radiating golden light, white lotus flower below, simple card-over-lotus
```

---

## 히든 (Hidden) — 3종

### ach_boatman_talk — ??? (뱃사공 대화)
**Seed:** 74041
```
smoky gray question mark, small wooden oar behind, simple question-mark-oar
```

### ach_zero_score — ??? (0점)
**Seed:** 74042
```
large gray stone zero, crumbling with dust particles, simple cracked zero
```

### ach_time_100h — ??? (100시간)
**Seed:** 74043
```
question mark made of clock hands and small gear shapes, simple mechanical question mark
```

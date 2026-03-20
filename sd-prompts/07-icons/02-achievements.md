# 업적(Achievement) 아이콘 (22종)

> **아이작 스타일** — 1:1 정사각, 투명 배경, 오브젝트만. 심플한 도트 실루엣.
> 64x64px 최종 크기. 카테고리 테두리는 게임 UI에서 처리.

## 생성 환경

```yaml
Model: Flux-dev (ComfyUI)
Resolution: 256 x 256 (→ Nearest Neighbor 다운스케일 64x64)
Steps: 20~25
Guidance: 3.5
Batch: 4장
```

## 공통 프롬프트 프리픽스

```
A single low-resolution pixel art item icon in the style of The Binding of Isaac, made of large visible square pixels. Drawn on a 64x64 pixel grid — each individual pixel is clearly visible and you can count them. Blocky jagged edges, no smooth curves, no anti-aliasing, no soft edges, no gradients, no blending between pixels. Bold thick black pixel outlines. Flat color fill only. One simple recognizable object on plain solid bright green (#00FF00) chroma key background. Floats in empty space — no ground, no shadow, no pedestal. Extremely simple silhouette. Square 1:1. Only the item, nothing else.
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
A single pale blue glowing footprint. One bare foot impression. Simple step mark. Nothing else.
```

### ach_explorer — 저승 탐험가
**Seed:** 74002
```
A warm orange paper lantern floating with a small glow. Simple round lantern shape. Nothing else.
```

### ach_yeomra_judgment — 염라의 심판
**Seed:** 74003
```
A golden balance scale perfectly balanced. Simple two-pan scale. Nothing else.
```

### ach_spiral_2 — 두 번째 윤회
**Seed:** 74004
```
Two interlinked spiral circles — one silver, one gold. Simple double loop. Nothing else.
```

### ach_spiral_5 — 저승의 전설
**Seed:** 74005
```
Five small cyan ghost flames arranged in a circle crown formation. Simple flame ring. Nothing else.
```

### ach_spiral_10 — 무한의 끝
**Seed:** 74006
```
A golden infinity symbol with cracks breaking at the edges. Simple cracking infinity. Nothing else.
```

### ach_tenth_death — 열 번째 죽음
**Seed:** 74007
```
Ten tiny white skulls arranged in two rows of five. Simple skull grid. Nothing else.
```

---

## 족보 (Yokbo) — 5종

### ach_three_gwang — 삼광 달성
**Seed:** 74011
```
Three golden stars arranged in a triangle. Simple three-star triangle. Nothing else.
```

### ach_four_gwang — 사광 달성
**Seed:** 74012
```
Four golden stars arranged in a diamond pattern. Simple four-star diamond. Nothing else.
```

### ach_five_gwang — 오광 달성
**Seed:** 74013
```
Five brilliant golden stars arranged in a pentagon, glowing intensely. Simple five-star formation. Nothing else.
```

### ach_score_10k — 만점왕
**Seed:** 74014
```
Bold golden pixel text reading "10K" with small sparkle marks. Simple text icon. Nothing else.
```

### ach_score_1m — 백만장자
**Seed:** 74015
```
Bold golden pixel text reading "1M" with golden light rays behind it. Simple text icon. Nothing else.
```

---

## 고스톱 (GoStop) — 4종

### ach_first_go — 첫 Go
**Seed:** 74021
```
A single bold red arrow pointing right with a speed trail. Simple forward arrow. Nothing else.
```

### ach_bold_choice — 대담한 선택
**Seed:** 74022
```
Two bold red arrows stacked, both pointing right. Simple double arrow. Nothing else.
```

### ach_mad_gambler — 미친 도박사
**Seed:** 74023
```
Three blazing red arrows pointing right with fire trails. Simple triple arrow. Nothing else.
```

### ach_greed_price — 욕심의 대가
**Seed:** 74024
```
A broken red arrow snapped in half with fragments falling. Simple broken arrow. Nothing else.
```

---

## 특수 (Special) — 3종

### ach_no_talisman — 무부적
**Seed:** 74031
```
An empty square outline with a red X across it. Simple crossed-out slot. Nothing else.
```

### ach_curse_lover — 저주 수용자
**Seed:** 74032
```
Three dark purple talisman papers stacked with dark wisps rising. Simple cursed papers. Nothing else.
```

### ach_nirvana_card — 해탈
**Seed:** 74033
```
A small card shape radiating golden light above a white lotus flower. Simple card-over-lotus. Nothing else.
```

---

## 히든 (Hidden) — 3종

### ach_boatman_talk — ??? (뱃사공 대화)
**Seed:** 74041
```
A smoky gray question mark with a small wooden oar behind it. Simple question-mark-oar. Nothing else.
```

### ach_zero_score — ??? (0점)
**Seed:** 74042
```
A large gray stone zero crumbling with dust particles. Simple cracked zero. Nothing else.
```

### ach_time_100h — ??? (100시간)
**Seed:** 74043
```
A question mark made of clock hands and small gear shapes. Simple mechanical question mark. Nothing else.
```

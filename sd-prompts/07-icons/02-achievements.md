# 업적(Achievement) 아이콘 (22종)

> 48~64px 정사각형 아이콘. 업적 리스트에서 표시.
> 카테고리별 테두리 색: 진행=흰색, 족보=금색, 고스톱=빨강, 특수=보라, 히든=검정.

## 생성 환경

```yaml
Model: Flux-dev (ComfyUI)
Resolution: 256 x 256 (→ 다운스케일 64x64)
Steps: 20~25
Guidance: 3.5
Batch: 4장
```

## 공통 프롬프트 프리픽스

```
A single small square pixel art achievement icon. 16-bit retro pixel art with crisp sharp pixels, no anti-aliasing. Bold flat colors with thick black outlines. Limited color palette based on game palette: dark navy (#1A1A2E), blood red (#C41E3A), ghost fire cyan (#00D4FF), gold (#FFD700), bone white (#E8E8E8), deep purple (#6B2D5B). One clear central symbol representing the achievement. Simple enough to read at small sizes. Fully contained within the square frame. Dark navy background. No text unless the achievement specifically involves a number or score — in that case, the number is part of the visual design.
```

## 후처리

```
1. Nearest Neighbor 다운스케일 → 64x64 또는 48x48
2. PNG → Assets/Art/Icons/Achievement/
```

---

## 진행 (Progress) — 7종

### ach_first_step — 첫 발걸음
**Seed:** 74001
```
A single footprint glowing faintly on dark ground. One bare foot impression in pale blue light on dark navy. Simple and quiet — the first step into the underworld.
```

### ach_explorer — 저승 탐험가
**Seed:** 74002
```
A paper lantern illuminating a dark path. A warm orange lantern floating above a winding trail. The explorer who has seen 5 realms.
```

### ach_yeomra_judgment — 염라의 심판
**Seed:** 74003
```
A golden judgment scale perfectly balanced. The scales of divine justice glowing gold against dark navy. Completing the first full spiral — 10 realms conquered.
```

### ach_spiral_2 — 두 번째 윤회
**Seed:** 74004
```
Two interlinked spiral circles in silver and gold. The double loop of reincarnation — reaching spiral 2. The cycle begins again.
```

### ach_spiral_5 — 저승의 전설
**Seed:** 74005
```
A crown made of five ghostly cyan flames arranged in a circle. The legendary soul who has completed 5 full spirals. Cyan ghost fire crown on dark navy.
```

### ach_spiral_10 — 무한의 끝
**Seed:** 74006
```
An infinity symbol made of golden light, cracking and breaking apart at the edges. The impossible achievement — 10 spirals completed. Gold infinity breaking on dark navy.
```

### ach_tenth_death — 열 번째 죽음
**Seed:** 74007
```
Ten small skull symbols arranged in two rows of five. Simple white bone-colored skulls on dark navy. The persistence of dying 10 times and returning.
```

---

## 족보 (Yokbo) — 5종

### ach_three_gwang — 삼광 달성
**Seed:** 74011
```
Three bright stars arranged in a triangle, glowing warm gold. Three points of celestial light on dark navy. Achieving Three Brights yokbo.
```

### ach_four_gwang — 사광 달성
**Seed:** 74012
```
Four bright stars arranged in a diamond pattern, glowing silver-gold. Four celestial lights on dark navy. Achieving Four Brights.
```

### ach_five_gwang — 오광 달성
**Seed:** 74013
```
Five brilliant stars arranged in a pentagon, blazing with intense golden white light. Maximum celestial radiance on dark navy. The ultimate Five Brights achievement.
```

### ach_score_10k — 만점왕
**Seed:** 74014
```
A large number "10K" rendered in bold golden pixel text with sparkle effects around it. Scoring 10,000 in a single round. Gold text on dark navy.
```

### ach_score_1m — 백만장자
**Seed:** 74015
```
A large number "1M" in blazing golden text with an explosion of golden light rays behind it. The million-point milestone. Maximum gold brilliance on dark navy.
```

---

## 고스톱 (GoStop) — 4종

### ach_first_go — 첫 Go
**Seed:** 74021
```
A single bold red arrow pointing forward with a faint speed trail behind it. The first time choosing Go — moving forward into risk. Red arrow on dark navy.
```

### ach_bold_choice — 대담한 선택
**Seed:** 74022
```
Two bold red arrows stacked, both pointing forward with intensifying speed trails. Double Go — doubling down on risk. Orange-red arrows on dark navy.
```

### ach_mad_gambler — 미친 도박사
**Seed:** 74023
```
Three blazing red arrows with fire trails, pointing forward in a reckless charge. Triple Go success — the mad gambler who won against all odds. Fiery red on dark navy.
```

### ach_greed_price — 욕심의 대가
**Seed:** 74024
```
A broken red arrow snapped in half, with fragments falling downward. The price of greed — failing after 3 Go attempts. Broken red pieces on dark navy.
```

---

## 특수 (Special) — 3종

### ach_no_talisman — 무부적
**Seed:** 74031
```
An empty talisman slot outline with a crossed-out circle over it. No talismans — pure skill victory. Empty slot icon with prohibition mark on dark navy.
```

### ach_curse_lover — 저주 수용자
**Seed:** 74032
```
Three dark purple cursed talisman papers stacked together, with dark energy wisps rising from them. Embracing three curses and still winning. Purple curse papers on dark navy.
```

### ach_nirvana_card — 해탈
**Seed:** 74033
```
A hwatu card radiating five-star golden light, floating above an open lotus flower. Achieving the highest Nirvana enhancement tier. Golden card above white lotus on dark navy.
```

---

## 히든 (Hidden) — 3종

### ach_boatman_talk — ??? (뱃사공 대화)
**Seed:** 74041
```
A question mark made of faint smoke wisps with a small wooden oar silhouette barely visible behind it. Hidden achievement — talking to the boatman 5 times. Smoky question mark on dark navy.
```

### ach_zero_score — ??? (0점)
**Seed:** 74042
```
A large zero rendered in cracked gray stone, with dust falling from it. Hidden achievement — ending a round with exactly 0 score. Gray stone zero on dark navy.
```

### ach_time_100h — ??? (100시간)
**Seed:** 74043
```
A question mark made of clock hands and gears, slowly rusting. Hidden achievement — 100 hours of total playtime. Mechanical question mark on dark navy.
```

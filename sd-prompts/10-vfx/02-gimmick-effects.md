# 기믹별 개별 VFX 이펙트 (10종)

> 현재 모든 보스 기믹이 **동일한 마젠타 플래시**로 표시됨.
> 각 기믹마다 고유한 시각 이펙트를 만들어 플레이어가 즉시 구분할 수 있게 한다.

## 생성 환경

```yaml
Model: Flux-dev (ComfyUI)
Resolution: 256 x 256 (정사각형 이펙트 텍스처)
Steps: 20~25
Guidance: 3.5
Batch: 4장
```

## 공통 프롬프트 프리픽스

```
A pixel art visual effect texture on a solid black (#000000) background — the black will be converted to transparency via alpha channel in post-processing. 16-bit retro pixel art with crisp sharp pixels. A single dramatic effect meant to flash on screen when a boss ability activates. Bold and immediately readable. Centered composition. Only the effect, nothing else.
```

## 후처리

```
1. 검정 배경 → 알파 채널 변환
2. PNG (알파) → Assets/Art/VFX/Gimmick/
3. Unity에서 Additive 블렌딩 또는 Flash 오버레이로 사용
4. 기믹 발동 시 0.3~0.5초간 화면에 표시
```

---

### gimmick_consume — 먹보 (최고 카드 먹기)
**Seed:** 82001

```
A large monstrous mouth opening wide on black background. Sharp uneven teeth frame a dark void in the center. The mouth is reddish-orange with dark red gums. A hwatu card is being pulled into the mouth — half-swallowed, disappearing into the darkness. Drool drops hang from the teeth. The effect conveys devouring and consuming. The mouth takes up most of the frame. Color: reddish orange mouth, sharp white teeth, dark void center.
```

### gimmick_flip — 장난꾸러기 (카드 뒤집기)
**Seed:** 82002

```
Multiple hwatu cards spinning and flipping in a chaotic swirl on black background. Five or six card shapes are mid-rotation at different angles — some showing fronts, some showing backs. Circular motion lines indicate spinning movement. The cards rotate in a clockwise spiral pattern. The effect conveys chaos and confusion — you can't see your cards anymore. Color: cream card faces, dark card backs, blue-gray motion trails.
```

### gimmick_reset — 불꽃 (바닥패 초기화)
**Seed:** 82003

```
A wave of fire sweeping horizontally across the frame on black background. Orange-red flames blast from left to right like a firestorm, consuming everything in their path. Small card silhouettes are visible within the flames, burning and curling as they're destroyed. The fire is intense and destructive — a clean sweep of annihilation. Embers and ash trail behind the fire wave. Color: vivid orange fire, red flame base, yellow tips, black charred card silhouettes.
```

### gimmick_disable_talisman — 그림자 (부적 무력화)
**Seed:** 82004

```
A talisman paper being consumed by dark shadow tendrils on black background. The talisman is red with black calligraphy, but dark purple-black shadow hands are wrapping around it and dragging it into darkness. The paper cracks and its glow fades as the shadows tighten. A large X-mark of shadow forms over the talisman. The effect conveys suppression and nullification — your power is being sealed. Color: red talisman fading to gray, dark purple shadow tendrils, dimming glow.
```

### gimmick_no_bright — 염라 (광 카드 무효)
**Seed:** 82005

```
A bright golden gwang (光) symbol being crossed out by a large judgment stamp on black background. The 광 character glows gold but a massive red seal stamp mark slams down over it, creating an X of authority. The golden glow dims and turns gray beneath the seal. Ink splatter from the stamp impact radiates outward. The effect conveys divine prohibition — your brightest cards are worthless here. Color: fading gold 광 symbol, crimson red seal stamp, gray dimming.
```

### gimmick_skullify — 백골대장 (해골 카드화)
**Seed:** 82006

```
A hwatu card transforming into a skull on black background. The left half shows a normal card with flower patterns. The right half shows the same card consumed by bone-white skull imagery — the flowers have become bones, the colors have drained to gray-white. A jagged transition line separates the living and dead halves. Purple-black smoke rises from the skull side. The effect conveys corruption and death — your cards are turning into skull cards. Color: normal card colors on left, bone white and death gray on right, purple corruption smoke.
```

### gimmick_fake — 구미호 (가짜 카드)
**Seed:** 82007

```
A hwatu card that appears normal but has a sinister fox eye peeking through a crack in its surface on black background. The card looks almost right but something is wrong — the pattern shimmers unnaturally. A purple question mark floats above the suspicious card. Fox tail wisps curl from behind the card edges. The effect conveys deception and trickery — you can't trust what you see. Color: normal card tones but with purple shimmer, fox-eye purple, question mark purple.
```

### gimmick_competitive — 이무기 (경쟁 모드)
**Seed:** 82008

```
A split screen effect — two score counters facing each other on black background. The left side shows a player score in blue-white. The right side shows a boss score in red-orange, growing larger and more threatening. A VS symbol sits in the center between them, crackling with energy. Competitive tension lines radiate from the center. The effect conveys head-to-head competition — the boss is scoring too. Color: blue-white player side, red-orange boss side, yellow VS energy.
```

### gimmick_suppress — 저승꽃 (족보 은폐)
**Seed:** 82009

```
Text and symbols being obscured by growing black ink stains on black background. Several Korean text lines are visible but being consumed by spreading ink blots that make them unreadable. The ink bleeds outward like water on paper, swallowing the information. A dark flower (higanbana/spider lily) silhouette blooms within the largest ink blot. The effect conveys information suppression — you can't see your yokbo names anymore. Color: gray text being consumed, black ink blots, dark red flower silhouette.
```

### gimmick_field_burn — 바닥패 소각 (보스 파츠 기믹)
**Seed:** 82010

```
Two hwatu cards catching fire and crumbling to ash on black background. The cards are positioned side by side, each engulfed in small focused flames. The card edges curl inward as they burn. Ash particles drift upward from the burning cards. The fire is localized — not a sweeping inferno but precise targeted destruction of exactly two cards. Color: cream card surface charring to brown, orange focused flames, gray ash particles rising.
```

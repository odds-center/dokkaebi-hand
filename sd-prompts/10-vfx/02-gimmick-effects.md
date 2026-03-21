# 기믹별 개별 VFX 이펙트 (10종)

> 현재 모든 보스 기믹이 **동일한 마젠타 플래시**로 표시됨.
> 각 기믹마다 고유한 시각 이펙트를 만들어 플레이어가 즉시 구분할 수 있게 한다.

## 생성 환경

```yaml
Model: Pony Diffusion V6 XL (ComfyUI)
LoRA: Binding of Isaac Style v2.1 (strength 0.50)
Resolution: 256 x 256 (정사각형 이펙트 텍스처)
Sampler: euler_a
Steps: 25~30
CFG: 7
Batch: 4장
```

## 공통 프롬프트 프리픽스

```
score_9, score_8_up, score_7_up, pixel art, game assets, chibi, simple black background, visual effect texture, solid black background for alpha conversion, blocky jagged edges, no smooth curves, no anti-aliasing, flat colors, thick black outlines, dramatic boss ability effect, centered composition, fully contained with margins
```

## 공통 네거티브 프롬프트

```
score_4, score_3, score_2, score_1, blurry, photo, realistic, 3d render, smooth shading, anti-aliasing, gradient, soft edges, watercolor, text, watermark, signature
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
large monstrous mouth opening wide, sharp uneven teeth framing dark void center, reddish-orange mouth dark red gums, hwatu card half-swallowed disappearing into darkness, drool drops hanging from teeth, devouring consuming effect, mouth takes up most of frame, color reddish orange mouth sharp white teeth dark void center
```

### gimmick_flip — 장난꾸러기 (카드 뒤집기)
**Seed:** 82002

```
multiple hwatu cards spinning and flipping in chaotic swirl, five or six card shapes mid-rotation different angles, some fronts some backs, circular motion lines indicating spinning, clockwise spiral pattern, chaos confusion effect cards hidden, color cream card faces dark card backs blue-gray motion trails
```

### gimmick_reset — 불꽃 (바닥패 초기화)
**Seed:** 82003

```
wave of fire sweeping horizontally across frame, orange-red flames blasting left to right firestorm, small card silhouettes within flames burning and curling, intense destructive clean sweep annihilation, embers and ash trailing behind, color vivid orange fire red flame base yellow tips black charred card silhouettes
```

### gimmick_disable_talisman — 그림자 (부적 무력화)
**Seed:** 82004

```
talisman paper consumed by dark shadow tendrils, red talisman with black calligraphy, dark purple-black shadow hands wrapping and dragging into darkness, paper cracking glow fading, large X-mark of shadow over talisman, suppression nullification effect power sealed, color red talisman fading to gray dark purple shadow tendrils dimming glow
```

### gimmick_no_bright — 염라 (광 카드 무효)
**Seed:** 82005

```
bright golden gwang symbol being crossed out by large judgment stamp, golden glow with massive red seal stamp slamming down creating X of authority, golden glow dimming turning gray beneath seal, ink splatter from stamp impact radiating outward, divine prohibition effect brightest cards worthless, color fading gold symbol crimson red seal stamp gray dimming
```

### gimmick_skullify — 백골대장 (해골 카드화)
**Seed:** 82006

```
hwatu card transforming into skull, left half normal card with flower patterns, right half consumed by bone-white skull imagery flowers become bones colors drain to gray-white, jagged transition line between living and dead halves, purple-black smoke from skull side, corruption death effect cards turning skull, color normal card colors left bone white death gray right purple corruption smoke
```

### gimmick_fake — 구미호 (가짜 카드)
**Seed:** 82007

```
hwatu card appearing normal but sinister fox eye peeking through crack in surface, pattern shimmering unnaturally, purple question mark floating above suspicious card, fox tail wisps curling from behind card edges, deception trickery effect cannot trust what you see, color normal card tones purple shimmer fox-eye purple question mark purple
```

### gimmick_competitive — 이무기 (경쟁 모드)
**Seed:** 82008

```
split screen effect two score counters facing each other, left side player score in blue-white, right side boss score in red-orange growing larger more threatening, VS symbol in center crackling with energy, competitive tension lines from center, head-to-head competition boss scoring too, color blue-white player side red-orange boss side yellow VS energy
```

### gimmick_suppress — 저승꽃 (족보 은폐)
**Seed:** 82009

```
text and symbols obscured by growing black ink stains, Korean text lines consumed by spreading ink blots becoming unreadable, ink bleeding outward like water on paper, dark flower higanbana spider lily silhouette in largest ink blot, information suppression yokbo names hidden, color gray text consumed black ink blots dark red flower silhouette
```

### gimmick_field_burn — 바닥패 소각 (보스 파츠 기믹)
**Seed:** 82010

```
two hwatu cards catching fire and crumbling to ash, side by side each engulfed in small focused flames, card edges curling inward, ash particles drifting upward, localized precise targeted destruction of exactly two cards, color cream card surface charring to brown orange focused flames gray ash particles rising
```

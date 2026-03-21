# 이벤트 일러스트 (10종)

> 저승 장터 이벤트 발생 시 화면 중앙에 표시되는 삽화.
> 분위기 전달이 핵심 — 선택지를 고르기 전 플레이어의 몰입을 높인다.

## 생성 환경

```yaml
Model: Pony Diffusion V6 XL (ComfyUI)
LoRA: Binding of Isaac Style v2.1 (strength 0.55)
Resolution: 512 x 384 (4:3, 이벤트 패널 비율)
Sampler: euler_a
Steps: 25~30
CFG: 7
Batch: 4장
```

## 공통 프롬프트 프리픽스

```
score_9, score_8_up, score_7_up, pixel art, game assets, chibi, scene illustration, Korean underworld card game event, dark fantasy atmosphere, blocky jagged edges, no smooth curves, no anti-aliasing, flat colors, thick black outlines, NES SNES era aesthetic, limited game palette, no text, no UI elements, fully contained with margins
```

## 공통 네거티브 프롬프트

```
score_4, score_3, score_2, score_1, blurry, photo, realistic, 3d render, smooth shading, anti-aliasing, gradient, soft edges, watercolor, text, watermark, signature
```

## 후처리

```
1. 4장 중 최선 선택
2. PNG → Assets/Art/Illustrations/Event/
```

---

### event_01_wanderer — 저승 방랑자
**Seed:** 76001

```
lone ghostly figure crouching in complete darkness, arms wrapped around knees, translucent pale blue-white, barely visible in dark void, single faint cyan ghost flame as only light, face hidden lost soul silhouette, pitiful sorrowful atmosphere, dark navy background, color palette dark navy pale blue-white ghost cyan flame
```

### event_02_auction — 귀신 시장 특별 경매
**Seed:** 76002

```
multiple ghostly merchants gathered around glowing legendary talisman on raised pedestal, brilliant gold talisman illuminating translucent ghost bidders, ghost hands reaching toward talisman, paper lanterns casting warm orange light, competitive tense atmosphere, dark market background, color palette dark navy warm orange lanterns golden talisman glow ghost white figures
```

### event_03_crossroads — 운명의 갈림길
**Seed:** 76003

```
two mystical doorways side by side in misty void, left door glowing warm red-orange with heat waves, right door glowing cold ice-blue with frost crystals, narrow stone path leading to doorways, thick fog surrounding, ominous atmosphere both doors promising neither safe, color palette dark fog gray warm red-orange left door cold ice-blue right door
```

### event_04_riddle — 도깨비불 시험
**Seed:** 76004

```
large floating supernatural ghost fire dokkaebi-bul, center of dark cave, vivid cyan-green pulsing with inner intelligence, small sparks and spirit wisps orbiting main flame, cave walls barely visible in faint glow, mysterious challenging atmosphere, flame alive testing with riddle, color palette dark cave black vivid cyan-green flame faint cave wall gray
```

### event_05_prayer — 삼도천 기도
**Seed:** 76005

```
small stone shrine at edge of Sanzu River, ancient weathered stone altar, burnt incense sticks, dark still river behind, faint golden spiritual energy around altar, small offerings coins and paper on surface, sacred quiet atmosphere, color palette dark navy river stone gray shrine golden spiritual glow incense smoke gray
```

### event_06_challenger — 과거의 도전자
**Seed:** 76006

```
skeleton leaning against dark stone wall, slumped sitting position, one bony hand clutching single hwatu card with faint color, tattered clothes on bones, dim light from above, tragic atmosphere failed player, single remaining card possibly valuable, color palette dark stone gray bone white faint card color dim light
```

### event_07_wager — 도깨비의 내기
**Seed:** 76007

```
mischievous small dokkaebi sitting cross-legged on rock, flipping large golden coin in air, wide grin showing sharp teeth, curved horns, sly narrow eyes, golden coin spinning catching light, darkness behind in all directions, playful but dangerous gambler atmosphere, color palette dark navy blue-gray goblin skin golden coin sharp white teeth
```

### event_08_flowers — 저승꽃밭
**Seed:** 76008

```
desolate field of vivid red spider lilies higanbana, blooming in underworld darkness, striking crimson red against dark ground, rows toward dark horizon, faint red glow from flower field, petals producing own light, hauntingly beautiful boundary of life and death, color palette dark ground vivid crimson red flowers faint red ambient glow dark sky
```

### event_09_mirror_pond — 거울 연못
**Seed:** 76009

```
perfectly still circular pond in dark cavern, mirror-smooth surface, reflection showing different scene alternate path, faint ethereal light from water surface, small ripples at one edge something reaching through, surreal philosophical atmosphere, color palette dark cavern black mirror silver water ethereal pale light subtle alternate-reality colors
```

### event_10_reaper — 저승사자의 제안
**Seed:** 76010

```
ferryman-reaper at edge of dark water, partially turned toward viewer, cone-shaped straw hat casting shadow over knowing face, oar in one hand, other hand extended offering gesture, faint warm golden glow around extended hand, dark river behind, intimate serious atmosphere rare help from reaper at a price, color palette dark navy river dark brown ferryman clothes straw hat golden offering glow
```

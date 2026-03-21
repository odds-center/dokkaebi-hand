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
A lone ghostly figure crouching in complete darkness, arms wrapped around its knees. The figure is translucent pale blue-white, barely visible in the dark void. A single faint cyan ghost flame floats near the figure as its only light source. The figure's face is hidden — only the silhouette of a lost soul is visible. The atmosphere is pitiful and sorrowful — this person is completely lost in the underworld. Should you help them, ignore them, or take what they have? Dark navy background with the pale ghost figure as the only element. Color palette: dark navy, pale blue-white ghost, cyan flame.
```

### event_02_auction — 귀신 시장 특별 경매
**Seed:** 76002

```
Multiple ghostly merchant figures gathered around a glowing legendary talisman on a raised pedestal. The talisman glows brilliant gold, illuminating the translucent ghost bidders around it. Ghost hands reach toward the talisman from all sides. Paper lanterns cast warm orange pools of light around the auction area. The atmosphere is competitive and tense — everyone wants this prize. Dark market background with warm lantern spots and the golden talisman as the bright focal point. Color palette: dark navy, warm orange lanterns, golden talisman glow, ghost white figures.
```

### event_03_crossroads — 운명의 갈림길
**Seed:** 76003

```
Two mystical doorways standing side by side in a misty void. The left door glows warm red-orange with heat waves rising from its frame — the hot door. The right door glows cold ice-blue with frost crystals forming on its surface — the cold door. Between them, a narrow stone path leads to the doorways from the foreground. Thick fog surrounds everything except the two doors. The atmosphere is ominous — both doors promise something but neither feels safe. Color palette: dark fog gray, warm red-orange left door, cold ice-blue right door.
```

### event_04_riddle — 도깨비불 시험
**Seed:** 76004

```
A large floating supernatural ghost fire — a dokkaebi-bul — hovering in the center of a dark cave. The flame is vivid cyan-green, much larger than a normal ghost fire, and it pulses with inner intelligence. Small sparks and spirit wisps orbit the main flame. The cave walls are barely visible in the faint glow. The atmosphere is mysterious and challenging — the flame is alive and is testing you with a riddle. Color palette: dark cave black, vivid cyan-green flame, faint cave wall gray.
```

### event_05_prayer — 삼도천 기도
**Seed:** 76005

```
A small stone shrine at the edge of the Sanzu River. An ancient weathered stone altar with a few burnt incense sticks. The dark still river stretches behind the shrine. A faint golden spiritual energy glows around the altar, suggesting divine presence. Small offerings — coins and paper — are scattered on the altar surface. The atmosphere is sacred and quiet — a moment of peace in the underworld. Color palette: dark navy river, stone gray shrine, golden spiritual glow, incense smoke gray.
```

### event_06_challenger — 과거의 도전자
**Seed:** 76006

```
A skeleton leaning against a dark stone wall, slumped in a sitting position. In one bony hand, it clutches a single hwatu card — the card still has faint color remaining. Tattered clothes hang loosely on the bones. A dim light falls on the skeleton from an unknown source above. The atmosphere is tragic — this person tried to play their way back to life and failed. Their single remaining card might be valuable. Color palette: dark stone gray, bone white skeleton, faint card color (red or gold), dim light.
```

### event_07_wager — 도깨비의 내기
**Seed:** 76007

```
A mischievous small dokkaebi goblin sitting cross-legged on a rock, flipping a large golden coin in the air. The dokkaebi has a wide grin showing sharp teeth, curved horns, and sly narrow eyes. The golden coin spins above its hand, catching the light. Behind the goblin, darkness stretches in all directions. The atmosphere is playful but dangerous — this is a gambler who always has an angle. Color palette: dark navy background, blue-gray goblin skin, golden coin, sharp white teeth.
```

### event_08_flowers — 저승꽃밭
**Seed:** 76008

```
A desolate field filled with vivid red spider lilies — higanbana — blooming in the underworld darkness. The flowers are striking crimson red against the dark ground, stretching in rows toward a dark horizon. A faint red glow emanates from the flower field itself, as if the petals produce their own light. The atmosphere is hauntingly beautiful — these are the flowers of the boundary between life and death. Strange power lives in these petals. Color palette: dark ground, vivid crimson red flowers, faint red ambient glow, dark sky.
```

### event_09_mirror_pond — 거울 연못
**Seed:** 76009

```
A perfectly still circular pond in a dark cavern, its surface mirror-smooth. The pond reflects something different from what stands above it — the reflection shows a slightly different scene, a different path taken. Faint ethereal light rises from the water surface. Small ripples break the perfect reflection at one edge, as if something is trying to reach through from the other side. The atmosphere is surreal and philosophical — the mirror shows what could have been. Color palette: dark cavern black, mirror silver water surface, ethereal pale light, subtle alternate-reality colors in reflection.
```

### event_10_reaper — 저승사자의 제안
**Seed:** 76010

```
The familiar ferryman-reaper figure standing at the edge of dark water, partially turned toward the viewer. His cone-shaped straw hat casts shadow over his knowing face. He holds his oar in one hand and extends the other hand in an offering gesture. A faint warm golden glow surrounds his extended hand — he has something valuable to share. The dark river stretches behind him. The atmosphere is intimate and serious — this is a rare moment of help from the reaper himself, but it comes at a price. Color palette: dark navy river, dark brown ferryman clothes, straw hat, golden offering glow.
```

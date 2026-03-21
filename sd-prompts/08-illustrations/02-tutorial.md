# 튜토리얼 일러스트 (4종)

> 첫 플레이 시 뱃사공이 게임을 가르쳐주는 장면.
> 각 단계의 핵심 개념을 직관적으로 보여주는 삽화.

## 생성 환경

```yaml
Model: Pony Diffusion V6 XL (ComfyUI)
LoRA: Binding of Isaac Style v2.1 (strength 0.55)
Resolution: 512 x 384 (4:3)
Sampler: euler_a
Steps: 25~30
CFG: 7
Batch: 4장
```

## 공통 프롬프트 프리픽스

```
score_9, score_8_up, score_7_up, pixel art, game assets, chibi, tutorial illustration, Korean underworld card game, blocky jagged edges, no smooth curves, no anti-aliasing, flat colors, thick black outlines, NES SNES era aesthetic, limited game palette, instructional composition, weathered old ferryman character, dark fantasy atmosphere, no text overlays, fully contained with margins
```

## 공통 네거티브 프롬프트

```
score_4, score_3, score_2, score_1, blurry, photo, realistic, 3d render, smooth shading, anti-aliasing, gradient, soft edges, watercolor, text, watermark, signature
```

## 후처리

```
1. PNG → Assets/Art/Illustrations/Tutorial/
```

---

### tutorial_01_matching — 카드 매칭
**Seed:** 77001

```
old ferryman sitting beside low table, hwatu cards laid out, hand pointing toward two matching flower pattern cards, matching pair glowing with connecting light line, other cards scattered face-up on table, composition showing these two go together, dark navy background, warm lantern-lit table scene, patient encouraging expression, clear matching concept visual
```

### tutorial_02_yokbo — 족보와 데미지
**Seed:** 77002

```
ferryman standing beside collected hwatu cards in yokbo pattern, three red ribbon cards forming Hong Dan, stylized damage numbers floating upward toward boss silhouette above, visual equation cards form pattern creates damage hits boss, composition flowing bottom cards middle yokbo glow top boss taking damage, warm gold light from completed yokbo
```

### tutorial_03_talisman — 부적 시스템
**Seed:** 77003

```
ferryman holding glowing talisman paper in one hand, other hand pointing to collection of pi junk cards on table, visual connection talisman activates when pi collected, multiplier boost effect as ascending energy lines, talisman glowing cyan, pi cards glowing faintly in response, talisman slot UI area suggested at bottom, concept clear talisman powers up based on card collection
```

### tutorial_04_gostop — 고/스톱 결정
**Seed:** 77004

```
dramatic split-screen composition, left side bold red Go path leading upward, golden multiplier symbols x2 x3 getting brighter, path narrower and more dangerous with cracks, right side calm blue Stop path, safe glowing treasure chest with current score, ferryman at fork between paths arms spread indicating both options, visual tension between greed left bright dangerous and safety right modest secure
```

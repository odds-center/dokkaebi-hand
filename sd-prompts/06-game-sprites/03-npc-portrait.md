# NPC 초상화 (1종)

## 생성 환경

```yaml
Model: Pony Diffusion V6 XL (ComfyUI)
LoRA: Binding of Isaac Style v2.1 (strength 0.65)
Resolution: 528 x 800 (픽셀 그리드 132x200 기준, 4x 생성)
       # → 다운스케일 396x600 (@1920x1080 기본 저장)
Sampler: euler_a
Steps: 25~30
CFG: 7
Batch: 8장
```

## 공통 프롬프트 프리픽스

> 모든 NPC 초상화 프롬프트 **앞에** 이 태그를 붙인다.

```
score_9, score_8_up, score_7_up, pixel art, game assets, chibi, simple green background, character portrait sprite, Korean underworld, blocky jagged edges, no smooth curves, no anti-aliasing, flat colors, thick black outlines, fully contained with margins
```

## 공통 네거티브 프롬프트

```
score_4, score_3, score_2, score_1, blurry, photo, realistic, 3d render, smooth shading, anti-aliasing, gradient, soft edges, watercolor, text, watermark, signature
```

---

### npc_merchant — 귀시장 상인 초상화
**Seed:** 72001

```
ghost merchant portrait, Korean underworld market, large visible square pixels, Stardew Valley Undertale style, upper body visible, lower half pixelates into nothingness, ghostly form, pale white-gray skin, traditional Korean merchant clothes, faded gray-brown, sly knowing smile, shrewd expression, hands spread on counter, warm lantern light from one side, color palette faded whites grays warm amber
```

## 후처리

```
1. 배경 제거 → 투명 알파 (캐릭터만 남김)
2. Nearest Neighbor 다운스케일 → 200x300
3. PNG (알파) → Assets/Art/Sprites/NPC/
```

# NPC 초상화 (1종)

## 생성 환경

```yaml
Model: Flux-dev (ComfyUI)
Resolution: 528 x 800 (픽셀 그리드 132x200 기준, 4x 생성)
       # → 다운스케일 396x600 (@1920x1080 기본 저장)
Steps: 25~30
Guidance: 3.5
Batch: 8장
```

---

### npc_merchant — 귀시장 상인 초상화
**Seed:** 72001

```
A low-resolution pixel art portrait of a ghost merchant in the Korean underworld market, made of large visible square pixels like a character from Stardew Valley or Undertale. Each individual pixel is clearly visible and countable. Blocky jagged edges, no smooth curves, no anti-aliasing, no soft gradients, no blending between pixels. Bold flat color fills with thick black pixel outlines. On plain solid bright green (#00FF00) background for chroma key. Upper body visible — the lower half pixelates into nothingness. Ghostly form with pale white-gray skin. Traditional Korean merchant clothes in faded gray-brown. Sly knowing smile — shrewd but not unfriendly. Hands spread on counter. Warm lantern light from one side. Fully contained with margins. Color palette: faded whites, grays, warm amber.
```

## 후처리

```
1. 배경 제거 → 투명 알파 (캐릭터만 남김)
2. Nearest Neighbor 다운스케일 → 200x300
3. PNG (알파) → Assets/Art/Sprites/NPC/
```

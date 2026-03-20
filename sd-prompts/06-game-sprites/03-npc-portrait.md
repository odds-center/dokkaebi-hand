# NPC 초상화 (1종)

## 생성 환경

```yaml
Model: Flux-dev (ComfyUI)
Resolution: 400 x 600 (→ 다운스케일 200x300)
Steps: 25~30
Guidance: 3.5
Batch: 8장
```

---

### npc_merchant — 귀시장 상인 초상화
**Seed:** 72001

```
A pixel art portrait of a ghost merchant in the Korean underworld market. 16-bit retro pixel art with crisp sharp pixels and thick black outlines. Upper body visible behind a wooden counter — the lower half fades into translucent nothingness. Semi-transparent ghostly form with pale white-gray skin. Wearing traditional Korean merchant clothes in faded gray-brown. A sly knowing smile with crinkled eyes — shrewd and calculating but not unfriendly. Hands spread out on the counter gesturing toward merchandise. Warm lantern light illuminates the figure from one side, casting dramatic shadows. Wispy translucent edges where the body dissolves. Trustworthy enough to buy from, but never fully trust. Fully contained within the image with comfortable margins. Color palette: faded whites, grays, warm amber light accents.
```

## 후처리

```
1. 배경 제거 → 투명 알파 (캐릭터만 남김)
2. Nearest Neighbor 다운스케일 → 200x300
3. PNG (알파) → Assets/Art/Sprites/NPC/
```

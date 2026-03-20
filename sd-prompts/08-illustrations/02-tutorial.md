# 튜토리얼 일러스트 (4종)

> 첫 플레이 시 뱃사공이 게임을 가르쳐주는 장면.
> 각 단계의 핵심 개념을 직관적으로 보여주는 삽화.

## 생성 환경

```yaml
Model: Flux-dev (ComfyUI)
Resolution: 512 x 384 (4:3)
Steps: 25~30
Guidance: 3.5
Batch: 4장
```

## 공통 프롬프트 프리픽스

```
A low-resolution pixel art tutorial illustration for a Korean underworld card game, made of large visible square pixels like a cutscene from Undertale. Each individual pixel is clearly visible. Blocky jagged edges, no smooth curves, no anti-aliasing, no soft gradients, no blending between pixels. Bold flat color fills with thick black pixel outlines. NES/SNES era aesthetic. Limited game palette: dark navy (#1A1A2E), blood red (#C41E3A), ghost fire cyan (#00D4FF), gold (#FFD700), warm orange, bone white (#E8E8E8). Clear instructional composition with weathered old ferryman character (cone straw hat). Dark fantasy atmosphere. Fully contained. No text overlays.
```

## 후처리

```
1. PNG → Assets/Art/Illustrations/Tutorial/
```

---

### tutorial_01_matching — 카드 매칭
**Seed:** 77001

```
The old ferryman sitting beside a low table with hwatu cards laid out. His hand points toward two cards that share the same flower pattern — the matching pair glows faintly with a connecting line of light between them. A few other cards are scattered on the table face-up. The composition clearly shows "these two go together." The dark navy background frames the warm lantern-lit table scene. The ferryman's expression is patient and encouraging. Simple clear visual of the matching concept.
```

### tutorial_02_yokbo — 족보와 데미지
**Seed:** 77002

```
The ferryman standing beside a display of collected hwatu cards arranged in a yokbo (combination) pattern — three red ribbon cards forming Hong Dan. Above the cards, stylized damage numbers float upward toward a boss silhouette at the top. A visual equation is implied: cards form pattern → pattern creates damage → damage hits boss. The composition flows from bottom (cards) to middle (yokbo glow) to top (boss taking damage). Warm gold light emanates from the completed yokbo.
```

### tutorial_03_talisman — 부적 시스템
**Seed:** 77003

```
The ferryman holding a glowing talisman paper in one hand, with his other hand pointing to a collection of pi (junk) cards on the table. A visual connection shows: talisman activates when pi cards are collected, creating a multiplier boost effect shown as ascending energy lines. The talisman glows with cyan light while the pi cards glow faintly in response. A talisman slot UI area is suggested at the bottom of the scene. The concept is clear: talisman powers up based on card collection.
```

### tutorial_04_gostop — 고/스톱 결정
**Seed:** 77004

```
A dramatic split-screen composition. On the left side, a bold red "Go" path leads upward with golden multiplier symbols (×2, ×3) getting progressively brighter but the path gets narrower and more dangerous with cracks. On the right side, a calm blue "Stop" path leads to a safe glowing treasure chest containing the current score. The ferryman stands at the fork between the two paths, arms spread indicating both options. The visual tension between greed (left, bright but dangerous) and safety (right, modest but secure) is the core message.
```

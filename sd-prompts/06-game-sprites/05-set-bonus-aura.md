# 세트 보너스 오라 이펙트 (5종)

> 보스가 같은 세트의 파츠를 2개 이상 장착하면 활성화되는 **전신 오라 이펙트.**
> 보스 스프라이트 + 파츠 오버레이 **위에** 최상위 레이어로 올라간다.
> 세트가 완성되면 보스가 확실히 "다른 단계"로 강해진 것이 보여야 한다.

```
[보스 기본]
    ↑
[파츠 3종 오버레이]
    ↑
[★ 세트 보너스 오라 ★]  ← 이 파일
```

## 생성 환경

```yaml
Model: Flux-dev (ComfyUI)
Resolution: 400 x 400 (보스보다 약간 크게 — 오라가 밖으로 삐져나와야 함)
Steps: 25~30
Guidance: 3.5
Batch: 4장
```

## 공통 프롬프트 프리픽스

```
A low-resolution pixel art aura effect overlay on a plain solid bright green (#00FF00) background for chroma key removal. Made of large visible square pixels — each pixel clearly visible. Blocky jagged edges, no smooth curves, no anti-aliasing, no soft gradients. Bold flat color fills. This is a full-body energy aura that surrounds a character — the CENTER must be completely empty (green background showing through) so the character sprite shows through when composited. Only the edges and surrounding area have the aura effect. Powerful and threatening — set bonus activated.
```

## 후처리

```
1. 중앙 영역(캐릭터 공간) 완전 투명 확인
2. 가장자리 오라만 남기고 배경 제거
3. Nearest Neighbor 다운스케일 → 400x400 (보스 300x300보다 크게 유지 — 오라가 밖으로 삐져나옴)
4. PNG (알파) → Assets/Art/Sprites/BossParts/SetAura/
5. Unity에서 보스 스프라이트 스택 최상위 레이어로 합성 (중앙 정렬, 보스보다 큰 크기)
6. 선택: 애니메이션용 2~3프레임 변형 생성 (약간 다른 seed)
```

---

### set_aura_fire — 불의 군주 오라
**Seed:** 81001

```
A blazing fire aura surrounding an empty center body space. Vivid orange-red flames roar outward from all sides of the empty center. The flames are rendered as bold pixel art fire shapes — flat orange and red with thick black outlines on the largest flame tongues. Embers and sparks scatter upward and outward. The flames are thickest at the bottom (rising from below) and sides, with tongues of fire reaching upward at the top. Small lava drops fall from the flame edges. The empty center space is roughly body-shaped. The fire casts a warm orange ambient glow on everything near it. Color palette: vivid orange, deep red, fire yellow tips, ember orange sparks. This boss is surrounded by an inferno.
```

### set_aura_ice — 얼음의 군주 오라
**Seed:** 81002

```
A freezing ice crystal aura surrounding an empty center body space. Sharp ice crystal formations grow outward from all edges of the empty center. The crystals are pale translucent blue with sharp geometric facets, rendered as angular pixel art shapes. Frost particles float in the air around the ice formations. Frozen mist clings to the bottom area. Icicles hang downward from the upper edges. The empty center space is roughly body-shaped. A cold cyan glow radiates from the ice crystals, with frost patterns spreading outward on the surrounding transparent space. Color palette: pale ice blue, crystal cyan, frost white, deep blue shadows. This boss is encased in a blizzard.
```

### set_aura_shadow — 그림자의 군주 오라
**Seed:** 81003

```
A dark shadow aura surrounding an empty center body space. Living darkness pours outward from the empty center, with tendrils of shadow reaching in all directions. The shadows are dark purple-black with wispy smoke-like edges that dissolve into transparency. The darkness is thickest near the center edges and gets thinner as it extends outward. Faint purple-violet glow points appear within the shadow mass like distant stars. The empty center space is roughly body-shaped but the shadow edges creep slightly inward, partially obscuring the character. The overall effect is of a creature consumed by darkness — barely visible. Color palette: pure black, dark purple, violet glow points. This boss exists within a void of shadow.
```

### set_aura_skull — 해골의 군주 오라
**Seed:** 81004

```
A bone and skull aura surrounding an empty center body space. Small floating skulls orbit around the empty center in a slow circular pattern. Bone fragments and teeth drift in the air around the body space. The skulls are bone-white with dark hollow eye sockets, rendered as small pixel art shapes. A pale white-golden glow connects the orbiting skulls like a ghostly chain. Faint bone dust particles fill the air. The empty center space is roughly body-shaped. The orbiting skulls create a crown-like ring at head level and a scattered field at body level. Color palette: bone white, dark hollow sockets, pale golden connecting glow. This boss commands the dead.
```

### set_aura_seal — 봉인의 군주 오라
**Seed:** 81005

```
A talisman paper vortex aura surrounding an empty center body space. Dozens of red talisman papers with black calligraphy orbit and spiral around the empty center in a swirling vortex pattern. The papers spin at different speeds and distances — some close to the body, some far out. Each paper has bold black calligraphy strokes visible on its red surface. A red-gold energy glow connects the swirling papers. The vortex rotates clockwise with papers trailing energy wisps behind them. The empty center space is roughly body-shaped. The effect is of overwhelming sealing power — talisman magic run wild. Color palette: vivid red papers, black calligraphy, golden-red energy glow. This boss has absorbed all talisman power.
```

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
Model: Pony Diffusion V6 XL (ComfyUI)
LoRA: Binding of Isaac Style v2.1 (strength 0.50)
Resolution: 400 x 400 (보스보다 약간 크게 — 오라가 밖으로 삐져나와야 함)
Sampler: euler_a
Steps: 25~30
CFG: 7
Batch: 4장
```

## 공통 프롬프트 프리픽스

```
score_9, score_8_up, score_7_up, pixel art, game assets, chibi, simple green background, aura effect overlay, chroma key green background, blocky jagged edges, no smooth curves, no anti-aliasing, flat colors, thick black outlines, full-body energy aura, empty center for character composite, edges and surrounding area only, fully contained with margins
```

## 공통 네거티브 프롬프트

```
score_4, score_3, score_2, score_1, blurry, photo, realistic, 3d render, smooth shading, anti-aliasing, gradient, soft edges, watercolor, text, watermark, signature
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
blazing fire aura, empty center body space, vivid orange-red flames roaring outward from all sides, bold pixel art fire shapes, flat orange and red, embers and sparks scattering upward, flames thickest at bottom and sides, tongues of fire reaching upward at top, small lava drops from flame edges, roughly body-shaped empty center, warm orange ambient glow, color palette vivid orange deep red fire yellow tips ember orange sparks, inferno surrounding
```

### set_aura_ice — 얼음의 군주 오라
**Seed:** 81002

```
freezing ice crystal aura, empty center body space, sharp ice crystal formations growing outward from all edges, pale translucent blue shards, angular pixel art shapes, frost particles floating, frozen mist at bottom, icicles hanging from upper edges, roughly body-shaped empty center, cold cyan glow from crystals, frost patterns spreading outward, color palette pale ice blue crystal cyan frost white deep blue shadows, blizzard encasing
```

### set_aura_shadow — 그림자의 군주 오라
**Seed:** 81003

```
dark shadow aura, empty center body space, living darkness pouring outward, shadow tendrils reaching all directions, dark purple-black wispy smoke-like edges dissolving into transparency, thickest near center edges thinner outward, faint purple-violet glow points like distant stars, roughly body-shaped empty center, shadow edges creeping slightly inward, creature consumed by darkness, color palette pure black dark purple violet glow points, void of shadow
```

### set_aura_skull — 해골의 군주 오라
**Seed:** 81004

```
bone and skull aura, empty center body space, small floating skulls orbiting in slow circular pattern, bone fragments and teeth drifting in air, bone-white dark hollow eye sockets, small pixel art skull shapes, pale white-golden glow connecting orbiting skulls like ghostly chain, faint bone dust particles, roughly body-shaped empty center, crown-like skull ring at head level, scattered field at body level, color palette bone white dark sockets pale golden connecting glow, commanding the dead
```

### set_aura_seal — 봉인의 군주 오라
**Seed:** 81005

```
talisman paper vortex aura, empty center body space, dozens of red talisman papers with black calligraphy orbiting and spiraling in swirling vortex, papers spinning at different speeds and distances, bold black calligraphy strokes on red surface, red-gold energy glow connecting papers, clockwise rotation with trailing energy wisps, roughly body-shaped empty center, overwhelming sealing power, color palette vivid red papers black calligraphy golden-red energy glow, absorbed all talisman power
```

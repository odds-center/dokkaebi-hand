# 텍스처 프롬프트 — 바로 사용 가능한 타일링 텍스처

텍스처도 **픽셀아트 스타일**로 생성 — 부드러운 사진 텍스처가 아닌 도트 텍스처.
타일링 가능하게 만들면 UI, 카드 배경, 테이블 등에 범용 사용.

> **중요:** 모든 텍스처 프롬프트에 "low-resolution pixel art texture, each pixel visible" 추가.
> 게임 전체가 픽셀아트이므로 텍스처도 도트 느낌이어야 일관성 유지.

---

## 생성 환경 (텍스처 전용)

```yaml
Model: Pony Diffusion V6 XL (ComfyUI)
LoRA: Binding of Isaac Style v2.1 (strength 0.50)
Resolution: 512 x 512 (정사각형 타일)
Sampler: euler_a
Steps: 25~30
CFG: 7
Batch: 2~4장
# ComfyUI에서 Tiled 관련 노드 사용 시 타일링 품질 향상
```

## 공통 프롬프트 프리픽스

> 모든 텍스처 프롬프트 **앞에** 이 태그를 붙인다.

```
score_9, score_8_up, score_7_up, pixel art, game assets, seamless tileable pattern, low-resolution pixel art texture, each pixel visible, blocky edges, no anti-aliasing, flat colors, thick black outlines, fully contained with margins
```

## 공통 네거티브 프롬프트

```
score_4, score_3, score_2, score_1, blurry, photo, realistic, 3d render, smooth shading, anti-aliasing, gradient, soft edges, watercolor, text, watermark, signature
```

## 후처리

```
1. 타일링 테스트 (2x2로 반복 배치해서 이음새 확인)
2. 이음새 보이면 Inpaint로 가장자리 블렌딩
3. PNG 저장 → Assets/Art/Textures/
```

## Unity 임포트

```
Texture Type: Default (2D)
Wrap Mode: Repeat       ← 타일링 필수
Filter Mode: Point       ← 카드/UI용
             Point    ← 배경/테이블용
Compression: None
```

---

## tex_hanji — 한지 텍스처
**Seed:** 50001
**용도:** 카드 앞면 배경, UI 패널 배경, 대화창 배경
**참고:** 카드 앞면 배경 크기: 90x130 (UI) / 80x120 (텍스처)

```
Korean handmade hanji paper, visible square pixels, warm beige with subtle cream variations, natural plant fiber texture, organic irregularities tiny visible fibers embedded, slightly rough uneven surface, gently aged antique quality subtle yellowing, uniform flat lighting no shadows, pure material texture only, no patterns no symbols no objects, tiles perfectly no visible seams
```

**변형 — 오래된 한지:**
```
heavily aged Korean hanji paper, visible square pixels, darker beige with brown age spots scattered randomly, creased wrinkled surface visible fold lines, some areas thinner more translucent, centuries of wear visible, uniform flat lighting pure texture only, tiles seamlessly
```

---

## tex_ink_stain — 먹물 얼룩
**Seed:** 50002
**용도:** 점수판 배경, 장식 오버레이, 전환 효과

```
Korean ink spill patterns on light paper, visible square pixels, dark black ink splattered varying opacity, dense opaque black areas and thin gray wash areas, organic flowing ink spread feathered wet edges, calligraphy brush splash marks different sizes, abstract pattern no recognizable shapes or letters, uniform flat lighting no 3D shadows, tiles seamlessly
```

---

## tex_dark_cloth — 어두운 천 (게임 테이블)
**Seed:** 50003
**용도:** 카드 놀이 테이블 표면
**참고:** 게임 테이블 영역: 950x160 (손패/바닥패 각각)

```
dark fabric cloth material, visible square pixels, very dark navy woven textile, subtle thread weave pattern barely visible, felt-like soft matte finish no shine, slight color variation between threads organic textile depth, uniform flat lighting pure fabric texture, game table surface, tiles seamlessly
```

**변형 — 붉은 천 (상점/보스전):**
```
dark crimson woven fabric, visible square pixels, deep blood red cloth subtle thread weave pattern, rich heavy silk-like feel no shine deep saturated color, uniform flat lighting pure texture, tiles seamlessly
```

---

## tex_stone — 돌 텍스처 (다리, 궁전 바닥)
**Seed:** 50004
**용도:** 삼도천 다리, 염라전 바닥, 이정표

```
dark stone surface, visible square pixels, gray-brown rough hewn stone, subtle crack lines, weathering marks centuries of erosion, occasional darker mineral veins, natural rock irregularities relatively flat, uniform flat lighting pure natural rock texture, no carved patterns no symbols, tiles seamlessly
```

---

## tex_wood — 나무 텍스처 (가판대, 선반)
**Seed:** 50005
**용도:** 상점 카운터, 서가, 뱃사공 배

```
dark aged wood grain, visible square pixels, deep brown clearly visible grain lines one direction, worn smooth from years of use, occasional knot holes darker patches, traditional Korean furniture wood feel, uniform flat lighting pure wood material texture, tiles seamlessly
```

---

## tex_gold_surface — 금 표면 (황금 미궁용)
**Seed:** 50006
**용도:** 7영역 황금 미궁 벽면

```
hammered gold metal surface, visible square pixels, warm gold slightly uneven hammered texture, subtle dents and tool marks, reflective but not mirror-smooth handcrafted beaten metal quality, uniform flat lighting pure precious metal surface, tiles seamlessly
```

---

## tex_lava_crack — 용암 균열 (지옥 바닥용)
**Seed:** 50007
**용도:** 3영역, 6영역 바닥 오버레이

```
cracked dark ground with lava in cracks, visible square pixels, black charred earth broken into irregular plates, bright glowing orange molten lava in fissures, crack edges glowing with heat orange light bleeding into dark stone, irregular organic crack pattern, dark overall bright orange accent lines, tiles seamlessly
```

---

## tex_ui_panel — UI 패널 배경
**Seed:** 50008
**용도:** 게임 내 모든 패널 배경 (상점, 이벤트, 축복선택 등)
**크기:** 512x512 (타일링)

```
dark UI panel background, very dark navy subtle purple undertone, faint geometric pattern barely visible beneath surface, subtle ink wash texture layered under geometric hints, smooth matte no shine, dark elegant unobtrusive supporting overlaid content, uniform flat lighting, tiles seamlessly
```

---

## tex_button — 버튼 배경
**Seed:** 50009
**용도:** 모든 UI 버튼의 배경 이미지
**크기:** 600x110 (2x of 300x55 실제 버튼 크기)

```
button background texture, dark navy rectangular panel slightly rounded corners, subtle border glow faint cyan along edges, very dark navy interior slight lighter center to darker edges, thin bright edge highlight top and left sides, darker shadow bottom and right sides subtle raised effect, clean minimal no text no symbols just button shape, color palette dark navy faint cyan edge glow near-black center
```

---

## tex_card_table — 카드 테이블 (바닥패/손패 영역)
**Seed:** 50010
**용도:** 손패/바닥패 놓는 영역 배경
**크기:** 950x160 (실제 영역 크기) 또는 475x80 (절반 크기로 생성 후 2x 업스케일)

```
game table surface texture, dark navy felt-like material, wide rectangular card-laying area, thin decorative border line faint gold along edges, center slightly lighter card placement zone, faint traditional Korean pattern embossed at corners, subtle worn texture from card play, wide rectangular format for laying cards in row, uniform flat lighting, color palette dark navy faint gold border near-black
```

---

## tex_boss_hp_bar — 보스 HP 바
**Seed:** 50011
**용도:** 보스 체력바 배경
**크기:** 1200x60 (2x of 600x30 실제 크기)

```
health bar background texture, dark ornate horizontal bar frame, dark metal subtle engravings, Korean traditional cloud pattern etched into metal surface, faint blood red inner glow from center, very dark navy base, metallic edge highlights top and bottom borders, wide narrow rectangular health bar container, color palette dark metal blood red accent navy base
```

---

## tex_score_panel — 점수 패널
**Seed:** 50012
**용도:** 칩/배수 표시 패널 배경
**크기:** 800x160 (2x of 400x80 실제 크기)

```
score display panel texture, dark ornate rectangular frame, dark navy with subtle ink wash texture, thin gold border line framing rectangle, faint hanji paper texture underneath dark surface, faint ink splatter accents at corners, center clean uncluttered for text overlay, uniform flat lighting, color palette dark navy base gold border line parchment hint underneath
```

---

## 텍스처 활용 요약

| 텍스처 | 주 사용처 | 크기 | Filter Mode |
|--------|----------|------|-------------|
| 한지 | 카드 배경, UI 패널 | 512x512 | Point |
| 먹물 얼룩 | 점수판, 장식 오버레이 | 512x512 | Point |
| 어두운 천 | 게임 테이블 | 512x512 | Point |
| 붉은 천 | 보스전 테이블 | 512x512 | Point |
| 돌 | 다리, 궁전 바닥 | 512x512 | Point |
| 나무 | 상점, 서가 | 512x512 | Point |
| 금 표면 | 황금 미궁 | 512x512 | Point |
| 용암 균열 | 지옥 바닥 | 512x512 | Point |
| UI 패널 | 상점/이벤트/축복 패널 | 512x512 | Point |
| 버튼 | UI 버튼 배경 | 600x110 | Point |
| 카드 테이블 | 손패/바닥패 영역 | 950x160 | Point |
| 보스 HP 바 | 보스 체력바 | 1200x60 | Point |
| 점수 패널 | 칩/배수 표시 | 800x160 | Point |

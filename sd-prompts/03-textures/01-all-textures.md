# 텍스처 프롬프트 — 바로 사용 가능한 타일링 텍스처

텍스처도 **픽셀아트 스타일**로 생성 — 부드러운 사진 텍스처가 아닌 도트 텍스처.
타일링 가능하게 만들면 UI, 카드 배경, 테이블 등에 범용 사용.

> **중요:** 모든 텍스처 프롬프트에 "low-resolution pixel art texture, each pixel visible" 추가.
> 게임 전체가 픽셀아트이므로 텍스처도 도트 느낌이어야 일관성 유지.

---

## 생성 환경 (텍스처 전용)

```yaml
Model: Flux-dev (ComfyUI)
Resolution: 512 x 512 (정사각형 타일)
Steps: 20~25
Guidance: 3.5
Sampler: euler
Scheduler: normal
Batch: 2~4장
# ComfyUI에서 Tiled 관련 노드 사용 시 타일링 품질 향상
```

### Flux-dev 프롬프트 규칙
- 네거티브 프롬프트 없음 — 원하지 않는 요소는 긍정 프롬프트에서 배제
- 가중치 문법 미사용 — 자연어로 강조
- LoRA는 ComfyUI 노드에서 별도 연결

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
A seamless tileable low-resolution pixel art texture of Korean handmade hanji paper, made of visible square pixels with blocky edges and no anti-aliasing. Warm beige color with subtle cream variations throughout. Natural plant fiber texture with organic irregularities — tiny visible fibers are embedded in the paper surface. The surface is slightly rough and uneven to the touch. The paper has a gently aged antique quality with very subtle yellowing. Uniform flat lighting with no shadows or highlights — pure material texture only. No patterns, no symbols, no objects — just the paper surface itself. The texture must tile perfectly with no visible seams when repeated.
```

**변형 — 오래된 한지:**
```
A seamless tileable low-resolution pixel art texture of heavily aged Korean hanji paper, made of visible square pixels with blocky edges. Darker beige color with brown age spots scattered randomly. The surface is creased and wrinkled with visible fold lines. Some areas appear thinner and more translucent than others. Centuries of use and handling are visible in the worn texture. Uniform flat lighting, pure texture only — no objects or patterns. Must tile seamlessly.
```

---

## tex_ink_stain — 먹물 얼룩
**Seed:** 50002
**용도:** 점수판 배경, 장식 오버레이, 전환 효과

```
A seamless tileable low-resolution pixel art texture of Korean ink spill patterns on light paper, made of visible square pixels with blocky edges. Dark black pixel ink is splattered across the surface with varying opacity — some areas are dense opaque black while others are thin gray wash. Organic flowing ink spread with feathered wet edges where the ink bled into paper. Calligraphy brush splash marks of different sizes are scattered throughout. The pattern is abstract with no recognizable shapes or letters. Uniform flat lighting with no 3D shadows. Must tile seamlessly when repeated.
```

---

## tex_dark_cloth — 어두운 천 (게임 테이블)
**Seed:** 50003
**용도:** 카드 놀이 테이블 표면
**참고:** 게임 테이블 영역: 950x160 (손패/바닥패 각각)

```
A seamless tileable low-resolution pixel art texture of dark fabric cloth material, made of visible square pixels with blocky edges. Very dark navy woven textile with a subtle thread weave pattern that is barely visible. The surface has a felt-like soft matte finish with no shine or reflection. Slight color variation between individual threads creates organic textile depth. Uniform flat lighting — pure fabric texture only, resembling a high-quality game table surface. Must tile seamlessly.
```

**변형 — 붉은 천 (상점/보스전):**
```
A seamless tileable low-resolution pixel art texture of dark crimson woven fabric. Deep blood red cloth material with a subtle thread weave pattern. Rich heavy fabric feel like silk or satin, but with no shine — just deep saturated color. Uniform flat lighting, pure texture. Must tile seamlessly.
```

---

## tex_stone — 돌 텍스처 (다리, 궁전 바닥)
**Seed:** 50004
**용도:** 삼도천 다리, 염라전 바닥, 이정표

```
A seamless tileable low-resolution pixel art texture of a dark stone surface. Gray-brown rough hewn stone with subtle crack lines and weathering marks from centuries of erosion. Occasional darker mineral veins run through the stone. The surface has natural rock irregularities but is relatively flat. Uniform flat lighting — pure natural rock texture with no carved patterns or symbols. Must tile seamlessly.
```

---

## tex_wood — 나무 텍스처 (가판대, 선반)
**Seed:** 50005
**용도:** 상점 카운터, 서가, 뱃사공 배

```
A seamless tileable low-resolution pixel art texture of dark aged wood grain. Deep brown wood with clearly visible grain lines running in one direction. The surface has been worn smooth from years of use. Occasional knot holes and darker patches add character. The color and feel is like traditional Korean furniture wood. Uniform flat lighting — pure wood material texture only. Must tile seamlessly.
```

---

## tex_gold_surface — 금 표면 (황금 미궁용)
**Seed:** 50006
**용도:** 7영역 황금 미궁 벽면

```
A seamless tileable low-resolution pixel art texture of a hammered gold metal surface. Warm gold color with a slightly uneven hammered texture showing subtle dents and tool marks. The surface is reflective but not mirror-smooth — it has a handcrafted beaten metal quality. Uniform flat lighting — pure precious metal surface texture only. Must tile seamlessly.
```

---

## tex_lava_crack — 용암 균열 (지옥 바닥용)
**Seed:** 50007
**용도:** 3영역, 6영역 바닥 오버레이

```
A seamless tileable low-resolution pixel art texture of cracked dark ground with lava visible in the cracks. The surface is black charred earth broken into irregular plates. Bright glowing orange molten lava is visible in the fissures between the dark plates. The crack edges glow with heat — orange light bleeds slightly into the surrounding dark stone. The crack pattern is irregular and organic. Dark overall with bright orange accent lines. Must tile seamlessly.
```

---

## tex_ui_panel — UI 패널 배경
**Seed:** 50008
**용도:** 게임 내 모든 패널 배경 (상점, 이벤트, 축복선택 등)
**크기:** 512x512 (타일링)

```
A seamless tileable texture for a dark UI panel background. Very dark navy color with a subtle purple undertone. A faint geometric pattern is barely visible beneath the surface. Subtle ink wash texture is layered under the geometric hints. The surface is smooth and matte with no shine. The overall impression is dark, elegant, and unobtrusive — a background that supports overlaid content without competing for attention. Uniform flat lighting. Must tile seamlessly.
```

---

## tex_button — 버튼 배경
**Seed:** 50009
**용도:** 모든 UI 버튼의 배경 이미지
**크기:** 600x110 (2x of 300x55 실제 버튼 크기)

```
A button background texture — a dark navy rectangular panel with slightly rounded corners. The panel has a subtle border glow in faint cyan along its edges. The interior is very dark navy with a slight gradient from slightly lighter center to darker edges. A thin bright edge highlight runs along the top and left sides. A darker shadow sits on the bottom and right sides, creating a subtle raised effect. Clean minimal design with no text, no symbols — just the button shape itself. Color palette: dark navy, faint cyan edge glow, near-black center.
```

---

## tex_card_table — 카드 테이블 (바닥패/손패 영역)
**Seed:** 50010
**용도:** 손패/바닥패 놓는 영역 배경
**크기:** 950x160 (실제 영역 크기) 또는 475x80 (절반 크기로 생성 후 2x 업스케일)

```
A game table surface texture — a dark navy felt-like material forming a wide rectangular card-laying area. A thin decorative border line runs along the edges in faint gold. The center area is very slightly lighter where cards would be placed, creating a subtle play zone. A faint traditional Korean pattern is embossed at the corners as decoration. The surface has a subtle worn texture from card play. Wide rectangular format optimized for laying cards in a row. Uniform flat lighting. Color palette: dark navy, faint gold border, near-black.
```

---

## tex_boss_hp_bar — 보스 HP 바
**Seed:** 50011
**용도:** 보스 체력바 배경
**크기:** 1200x60 (2x of 600x30 실제 크기)

```
A health bar background texture — a dark ornate horizontal bar frame. The frame is made of dark metal with subtle engravings — a Korean traditional cloud pattern is etched into the metal surface. A faint blood red inner glow emanates from the center of the bar. The base color is very dark navy. Metallic edge highlights run along the top and bottom borders. Wide narrow rectangular format designed as a health bar container. Color palette: dark metal, blood red accent, navy base.
```

---

## tex_score_panel — 점수 패널
**Seed:** 50012
**용도:** 칩/배수 표시 패널 배경
**크기:** 800x160 (2x of 400x80 실제 크기)

```
A score display panel texture — a dark ornate rectangular frame. The background is dark navy with a subtle ink wash texture layered beneath. A thin gold border line frames the rectangle. Subtle hanji paper texture is faintly visible underneath the dark surface. Faint ink splatter accents decorate the corners. The center area is clean and uncluttered for text overlay. Uniform flat lighting throughout. Color palette: dark navy base, gold border line, parchment hint underneath.
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

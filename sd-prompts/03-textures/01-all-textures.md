# 텍스처 프롬프트 — 바로 사용 가능한 타일링 텍스처

텍스처는 SD가 **가장 안정적으로 좋은 결과**를 내는 영역.
타일링 가능하게 만들면 UI, 카드 배경, 테이블 등에 범용 사용.

---

## SD 설정 (텍스처 전용)

```yaml
Model: SD 1.5 (LoRA 없이도 가능)
Resolution: 512 x 512 (정사각형 타일)
Steps: 30
CFG Scale: 7
Sampler: DPM++ 2M Karras
Tiled VAE: 활성화 (ComfyUI에서 Tiled KSampler 사용)
Batch: 2~4장
```

## 공통 부정 프롬프트

```
text, letters, numbers, face, person, character,
3d render, blurry, low quality, watermark,
frame, border, pattern break, seam visible
```

## 후처리

```
1. 타일링 테스트 (2x2로 반복 배치해서 이음새 확인)
2. 이음새 보이면 SD Inpaint로 가장자리 블렌딩
3. PNG 저장 → Assets/Art/Textures/
```

## Unity 임포트

```
Texture Type: Default (2D)
Wrap Mode: Repeat       ← 타일링 필수
Filter Mode: Point       ← 카드/UI용
             Bilinear    ← 배경/테이블용
Compression: None
```

---

## tex_hanji — 한지 텍스처
**Seed:** 50001
**용도:** 카드 앞면 배경, UI 패널 배경, 대화창 배경
**참고:** 카드 앞면 배경 크기: 90x130 (UI) / 80x120 (텍스처)

```
(seamless tileable texture:1.4),
(korean handmade hanji paper:1.3),
warm beige color (#F5E6CA) with subtle cream variations,
(natural fiber texture:1.2) with organic irregularities,
tiny visible plant fibers embedded in paper,
slightly rough uneven surface,
aged antique paper with gentle yellowing at edges,
(uniform flat lighting:1.3) no shadows no highlights,
pure material texture no patterns no symbols no objects
```

**변형 — 오래된 한지:**
```
(seamless tileable texture:1.4),
aged korean hanji paper heavily worn,
darker beige with brown age spots,
creased and wrinkled surface,
some areas thinner and more translucent,
centuries of use visible in the texture,
(uniform flat lighting:1.3), pure texture
```

---

## tex_ink_stain — 먹물 얼룩
**Seed:** 50002
**용도:** 점수판 배경, 장식 오버레이, 전환 효과

```
(seamless tileable texture:1.4),
(korean ink painting spill pattern:1.3),
(sumi-e ink:1.2) splattered on light paper,
dark black ink (#1A1A2E) with varying opacity,
organic flowing ink spread with feathered wet edges,
calligraphy brush splash marks of different sizes,
some areas dense black others thin gray wash,
(uniform flat lighting:1.3) no 3d shadows,
abstract ink pattern no recognizable shapes
```

---

## tex_dark_cloth — 어두운 천 (게임 테이블)
**Seed:** 50003
**용도:** 카드 놀이 테이블 표면
**참고:** 게임 테이블 영역: 950x160 (손패/바닥패 각각)

```
(seamless tileable texture:1.4),
(dark fabric cloth material:1.3),
very dark navy (#1A1A2E) woven textile,
subtle thread weave pattern barely visible,
(felt-like surface:1.2) soft matte finish,
no shine no reflection,
slight color variation between threads,
(uniform flat lighting:1.3),
pure fabric texture resembling a game table surface
```

**변형 — 붉은 천 (상점/보스전):**
```
(seamless tileable texture:1.4),
dark crimson (#C41E3A) woven fabric,
deep blood red cloth material,
subtle thread pattern,
rich heavy fabric feel like silk or satin,
no shine just deep saturated color,
(uniform flat lighting:1.3)
```

---

## tex_stone — 돌 텍스처 (다리, 궁전 바닥)
**Seed:** 50004
**용도:** 삼도천 다리, 염라전 바닥, 이정표

```
(seamless tileable texture:1.4),
(dark stone surface:1.3),
gray-brown rough hewn stone,
subtle crack lines and weathering marks,
centuries of erosion visible in surface,
occasional darker mineral veins,
(uniform flat lighting:1.3),
natural rock texture no carved patterns
```

---

## tex_wood — 나무 텍스처 (가판대, 선반)
**Seed:** 50005
**용도:** 상점 카운터, 서가, 뱃사공 배

```
(seamless tileable texture:1.4),
(dark aged wood grain:1.3),
deep brown wood with visible grain lines,
worn smooth surface from years of use,
occasional knot holes and darker patches,
traditional korean furniture wood tone,
(uniform flat lighting:1.3),
pure wood material texture
```

---

## tex_gold_surface — 금 표면 (황금 미궁용)
**Seed:** 50006
**용도:** 7영역 황금 미궁 벽면

```
(seamless tileable texture:1.4),
(hammered gold surface:1.3),
warm gold color (#FFD700),
slightly uneven hammered metal texture,
subtle dents and tool marks,
reflective but not mirror-smooth,
(uniform flat lighting:1.3),
precious metal surface texture
```

---

## tex_lava_crack — 용암 균열 (지옥 바닥용)
**Seed:** 50007
**용도:** 3영역, 6영역 바닥 오버레이

```
(seamless tileable texture:1.4),
(cracked dark ground with lava:1.3),
black charred earth surface,
(glowing orange fissures:1.3) between dark plates,
molten lava (#FF4500) visible in the cracks,
heat glow at crack edges,
irregular organic crack pattern,
dark with bright orange accent lines
```

---

---

## tex_ui_panel — UI 패널 배경
**Seed:** 50008
**용도:** 게임 내 모든 패널 배경 (상점, 이벤트, 축복선택 등)
**크기:** 512x512 (타일링)

```
(seamless tileable texture:1.4),
(dark navy-purple panel background:1.3),
very dark navy (#1A1A2E) with subtle purple undertone,
faint geometric pattern barely visible,
(subtle ink wash texture:1.2) layered under the pattern,
smooth matte surface with no shine,
slight gradient from center lighter to edges darker,
(uniform flat lighting:1.3),
pure background texture for UI overlay panels
```

---

## tex_button — 버튼 배경
**Seed:** 50009
**용도:** 모든 UI 버튼의 배경 이미지
**크기:** 600x110 (2x of 300x55 실제 버튼 크기)

```
(button background texture:1.4),
dark navy rectangular panel with rounded corners,
(subtle border glow:1.3) in faint cyan (#00D4FF) along edges,
dark interior (#1A1A2E) with slight gradient,
thin bright edge highlight on top and left,
darker shadow on bottom and right,
(clean minimal design:1.2),
no text no symbols just the button shape,
color palette: dark navy, faint cyan edge glow, near-black center
```

---

## tex_card_table — 카드 테이블 (바닥패/손패 영역)
**Seed:** 50010
**용도:** 손패/바닥패 놓는 영역 배경
**크기:** 950x160 (실제 영역 크기) 또는 475x80 (절반 크기로 생성 후 2x 업스케일)

```
(game table surface texture:1.4),
(dark fabric with subtle border:1.3),
very dark navy (#1A1A2E) felt-like material,
thin decorative border line along edges in faint gold,
(subtle worn texture:1.2) from card play,
slightly lighter center area where cards are placed,
traditional korean pattern faintly embossed at corners,
(uniform flat lighting:1.3),
wide rectangular format for card laying area,
color palette: dark navy, faint gold border, near-black
```

---

## tex_boss_hp_bar — 보스 HP 바
**Seed:** 50011
**용도:** 보스 체력바 배경
**크기:** 1200x60 (2x of 600x30 실제 크기)

```
(health bar background texture:1.4),
dark ornate horizontal bar frame,
(dark metal frame:1.3) with subtle engravings,
korean traditional cloud pattern etched into metal,
(blood red (#C41E3A) inner glow:1.1) at the center,
dark navy (#1A1A2E) base color,
metallic edge highlights,
wide narrow rectangular format,
color palette: dark metal, blood red accent, navy
```

---

## tex_score_panel — 점수 패널
**Seed:** 50012
**용도:** 칩/배수 표시 패널 배경
**크기:** 800x160 (2x of 400x80 실제 크기)

```
(score display panel texture:1.4),
dark ornate rectangular frame,
(dark navy background:1.3) (#1A1A2E) with ink wash texture,
thin gold (#FFD700) border line,
subtle hanji paper texture underneath,
(faint ink splatter:1.1) decorative accents in corners,
clean center area for text overlay,
(uniform flat lighting:1.3),
color palette: dark navy, gold border, parchment hint
```

---

## 텍스처 활용 요약

| 텍스처 | 주 사용처 | 크기 | Filter Mode |
|--------|----------|------|-------------|
| 한지 | 카드 배경, UI 패널 | 512x512 | Point |
| 먹물 얼룩 | 점수판, 장식 오버레이 | 512x512 | Point |
| 어두운 천 | 게임 테이블 | 512x512 | Bilinear |
| 붉은 천 | 보스전 테이블 | 512x512 | Bilinear |
| 돌 | 다리, 궁전 바닥 | 512x512 | Bilinear |
| 나무 | 상점, 서가 | 512x512 | Bilinear |
| 금 표면 | 황금 미궁 | 512x512 | Bilinear |
| 용암 균열 | 지옥 바닥 | 512x512 | Bilinear |
| UI 패널 | 상점/이벤트/축복 패널 | 512x512 | Bilinear |
| 버튼 | UI 버튼 배경 | 600x110 | Bilinear |
| 카드 테이블 | 손패/바닥패 영역 | 950x160 | Bilinear |
| 보스 HP 바 | 보스 체력바 | 1200x60 | Bilinear |
| 점수 패널 | 칩/배수 표시 | 800x160 | Bilinear |

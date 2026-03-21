# UI 패널 프레임 & 장식 요소

> 게임 내 모든 패널/팝업/다이얼로그의 **테두리 프레임, 배경, 장식 요소.**
> 현재 코드에서 `MockupSpriteFactory.GetPanelSprite()`로 단색 둥근 사각형만 생성 중.
> 전통 한국 문양 + 저승 분위기의 장식적 프레임으로 교체.

## 생성 환경

```yaml
Model: Pony Diffusion V6 XL (ComfyUI)
LoRA: Binding of Isaac Style v2.1 (strength 0.70)
Resolution: 용도별 상이 (아래 참조)
Sampler: euler_a
Steps: 25~30
CFG: 7
Batch: 4장
```

## 공통 프롬프트 프리픽스

```
score_9, score_8_up, score_7_up, pixel art, game assets, chibi, simple green background, UI frame element, Korean underworld card game, blocky jagged edges, no smooth curves, no anti-aliasing, flat colors, thick black outlines, NES SNES era UI aesthetic, dark navy blood red gold bone white palette, traditional Korean patterns dark fantasy, empty center for content overlay, fully contained with margins
```

## 공통 네거티브 프롬프트

```
score_4, score_3, score_2, score_1, blurry, photo, realistic, 3d render, smooth shading, anti-aliasing, gradient, soft edges, watercolor, text, watermark, signature
```

## 후처리

```
1. 중앙 영역 투명/반투명 확인 (콘텐츠가 올라갈 공간)
2. 9-slice 사용 가능하도록 모서리/변/중앙 구분 확인
3. PNG (알파) → Assets/Art/UI/Frames/
```

---

## 1. 메인 패널 프레임 (범용) — 3종

> 상점, 이벤트, 축복 선택, 강화 트리 등 **대부분의 팝업 패널**에 사용.
> 9-slice 스프라이트로 제작하여 다양한 크기에 적용 가능.

### frame_panel_default — 기본 패널
**Seed:** 84001 | **크기:** 512x512

```
decorative rectangular panel frame, Korean traditional border patterns, dark navy border, thin gold inner-line trim, four corners with Korean interlocking geometric patterns in gold on dark navy, border width approximately 16 pixels each side, semi-transparent dark navy center, subtle hanji paper texture underneath, elegant dark authoritative Korean underworld aesthetic, suitable for 9-slice scaling
```

### frame_panel_ornate — 화려한 패널 (보스전/중요 이벤트용)
**Seed:** 84002 | **크기:** 512x512

```
ornate decorative rectangular panel frame, elaborate Korean traditional patterns, wider border about 24 pixels, gold and blood red decorative motifs, four corners with cloud-and-crane patterns in gold, small dokkaebi ghost fire cyan accent dots at each corner, layered border outer dark navy edge middle gold pattern band inner blood red thin line, semi-transparent dark navy center, elaborate imposing important game moments, suitable for 9-slice scaling
```

### frame_panel_shop — 상점 패널
**Seed:** 84003 | **크기:** 512x512

```
warm-toned decorative panel frame, shop merchant UI, dark brown wood texture border, gold coin motifs at corners, warm orange-amber inner glow along border edges, lantern-lit appearance, carved wood border with subtle grain texture, small hanging paper lantern decorations at top corners, semi-transparent warm dark brown center, inviting cozy merchant display case underworld market, suitable for 9-slice scaling
```

---

## 2. 버튼 프레임 — 4종 (상태별)

> 게임 내 모든 버튼의 배경 이미지. Normal / Hover / Pressed / Disabled 4가지 상태.
> **크기:** 600x110 (실제 300x55의 2배)

### btn_normal — 기본 상태
**Seed:** 84011

```
button background normal idle state, dark navy rectangular panel, slightly rounded corners, thin gold border line all edges, dark navy #1A1A2E interior, subtle lighter center, thin bright highlight line along top edge only, slight raised 3D effect, clean minimal ready for text overlay, no text no symbols, wide rectangular format
```

### btn_hover — 호버 상태
**Seed:** 84012

```
button background hover highlighted state, same shape as normal, brighter gold border glowing slightly, slightly lighter dark navy interior, faint cyan #00D4FF inner glow along border edges, active highlighted, overall brightness increased, button looks alive ready to click
```

### btn_pressed — 눌린 상태
**Seed:** 84013

```
button background pressed clicked state, same shape pushed inward, highlight line moved from top to bottom edge, interior slightly darker than normal, gold border dims slightly, subtle shadow at top edge instead of highlight, visually depressed button
```

### btn_disabled — 비활성 상태
**Seed:** 84014

```
button background disabled grayed-out state, same shape all colors desaturated and dimmed, gold border becomes dull gray, flat dark gray interior no glow no highlight, inactive unresponsive clearly not clickable
```

---

## 3. 대화/말풍선 프레임 — 2종

> 뱃사공 대사, 보스 대사, 이벤트 NPC 대사에 사용.

### frame_dialog_normal — 일반 대화
**Seed:** 84021 | **크기:** 800x200

```
dialog box background for character speech, wide horizontal panel, rounded corners dark navy, thin gold border frame, left side small square portrait area about 120x120 pixels thicker gold frame, rest open for text content, small triangular speech indicator pointing downward from portrait area bottom, Korean underworld aesthetic, semi-transparent dark navy interior
```

### frame_dialog_boss — 보스 대화 (위협적)
**Seed:** 84022 | **크기:** 800x200

```
dialog box for boss character speech, same layout as normal, blood red accent border instead of gold, subtle claw-scratch marks or crack patterns at corners, faint red inner glow along edges, portrait area frame thicker more aggressive blood red with dark spikes, threatening ominous dangerous speaker, semi-transparent dark navy-red interior
```

---

## 4. Go/Stop 결정 패널
**Seed:** 84031 | **크기:** 960x400

```
split-screen decision panel for Go Stop choice, divided vertically into two halves, jagged lightning-bolt line down center, LEFT half warm red-orange background tint bold energy Go side risk and greed, subtle upward arrow motif suggesting escalation, RIGHT half cool blue-cyan background tint calm stability Stop side safety, subtle shield motif suggesting protection, both halves thin gold borders outer edges, center dividing line crackling with energy decision tension, dark navy base, no text just visual split risk left red safety right blue
```

---

## 5. 축복 선택 카드 프레임 — 4종

> 축복(업화/빙결/공허/혼돈) 선택 시 각 축복 카드의 프레임.
> **크기:** 300x400 (카드 형태)

### frame_blessing_fire — 업화
**Seed:** 84041

```
blessing card frame fire theme, tall card-shaped frame dark border, orange-red flame motifs along edges, small pixel art flames licking upward both sides, ember spark decorations at corners, thin orange inner-glow line, center empty transparent for content, small flame icon badge at top, color palette flame orange deep red dark navy
```

### frame_blessing_ice — 빙결
**Seed:** 84042

```
blessing card frame ice theme, tall card-shaped frame dark border, ice crystal formations along edges, sharp angular frost patterns, snowflake decorations at corners, thin cyan inner-glow line, center empty transparent, small ice crystal icon badge at top, color palette ice cyan pale blue dark navy
```

### frame_blessing_void — 공허
**Seed:** 84043

```
blessing card frame void emptiness theme, tall card-shaped frame dark border, border dissolving at edges crumbling into dark particles, void-hole decorations at corners frame breaking into nothingness, thin purple inner-glow line, center empty transparent, small void symbol badge at top, color palette deep purple near-black dark navy
```

### frame_blessing_chaos — 혼돈
**Seed:** 84044

```
blessing card frame chaos theme, tall card-shaped frame dark border, distorted warped patterns along edges reality unstable, decorations glitching between red green purple chaotic pattern, spiral vortex decorations at corners, thin multicolor shifting inner-glow line, center empty transparent, small chaos spiral badge at top, color palette crimson toxic green purple all clashing
```

---

## 6. 구분선 장식 — 2종

> 패널 내부 섹션 사이의 장식적 구분선.
> **크기:** 800x16 (가로로 길고 얇음)

### separator_default — 기본 구분선
**Seed:** 84051

```
thin horizontal decorative separator line, Korean traditional pattern, dark navy line, small diamond-shaped gold ornament at center, thin gold pinstripes along both sides, full width minimal height, clean elegant divider, transparent background above and below
```

### separator_ornate — 화려한 구분선
**Seed:** 84052

```
wider horizontal decorative separator, elaborate Korean cloud pattern, gold interlocking cloud motifs on dark navy band, small red accent dots at regular intervals, more decorative than default for important section dividers, transparent background above and below
```

---

## 7. 상점 아이템 카드 프레임
**Seed:** 84061 | **크기:** 360x480

```
shop item card frame for purchasable items, tall card-shaped frame, dark brown wood border merchant display, gold price tag area at bottom about 60 pixels for cost, small banner area at top for item name, center empty transparent for item icon, small coin decorations at bottom corners near price area, merchant product display card underworld bazaar, color palette dark brown wood gold trim warm amber accents dark navy
```

---

## 8. 카드 선택 하이라이트
**Seed:** 84071 | **크기:** 270x390 (카드 크기와 동일)

```
card selection highlight overlay, glowing golden border fitting hwatu card shape, warm gold light thicker brighter than normal card frame, center completely transparent card underneath shows through, small sparkle effects at four corners, glow extends slightly beyond card edges selected aura effect, player selected this card indicator, color warm gold glow border transparent center
```

---

## 9. 페이즈 표시 배너 — 2종

> 현재 게임 페이즈(고스톱 페이즈 / 공격 페이즈)를 표시하는 배너.
> **크기:** 400x80

### banner_gostop_phase — 고스톱 페이즈
**Seed:** 84081

```
phase indicator banner for card matching phase, horizontal banner dark navy background gold border trim, small hwatu card icon motif on left, decorative tassel end on right, warm amber-gold coloring collection phase gathering cards, center open for text overlay, color dark navy gold trim warm amber accents
```

### banner_attack_phase — 공격 페이즈
**Seed:** 84082

```
phase indicator banner for attack scoring phase, same shape as gostop banner, blood red accent coloring instead of amber, small sword or fist icon motif on left suggesting attack, more aggressive intense than collection phase, center open for text overlay, color dark navy gold trim blood red accents
```

---

## 10. 승리/패배 화면 배경 — 2종

> **크기:** 960x540 (→ 업스케일 1920x1080)

### screen_victory — 승리 (관문 돌파)
**Seed:** 84091

```
victory screen background, dramatic dark navy background, brilliant golden light rays bursting from center outward, small gold particles and sparkles drifting, faint traditional Korean celebratory patterns flying cranes auspicious clouds in golden light, triumphant liberating atmosphere gate passed, center area clear for text score overlay, 16-bit retro crisp pixels, color palette dark navy brilliant gold warm white light
```

### screen_defeat — 패배 (게임 오버)
**Seed:** 84092

```
game over screen background, dark scene fading to near-black from edges inward, faint red cracks across dark surface like broken glass, dim blood red glow from center fading, ghost fire wisps pale blue drifting slowly downward souls descending, somber final atmosphere everything lost, center area enough contrast for text overlay, 16-bit retro, color palette near-black fading blood red dim ghost blue wisps
```

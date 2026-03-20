# UI 패널 프레임 & 장식 요소

> 게임 내 모든 패널/팝업/다이얼로그의 **테두리 프레임, 배경, 장식 요소.**
> 현재 코드에서 `MockupSpriteFactory.GetPanelSprite()`로 단색 둥근 사각형만 생성 중.
> 전통 한국 문양 + 저승 분위기의 장식적 프레임으로 교체.

## 생성 환경

```yaml
Model: Flux-dev (ComfyUI)
Resolution: 용도별 상이 (아래 참조)
Steps: 20~25
Guidance: 3.5
Batch: 4장
```

## 공통 프롬프트 프리픽스

```
A low-resolution pixel art UI frame element for a Korean underworld card game, made of large visible square pixels. Each individual pixel is clearly visible and countable. Blocky jagged edges, no smooth curves, no anti-aliasing, no soft gradients, no blending between pixels. Bold flat color fills with thick black pixel outlines. NES/SNES era UI aesthetic. Game palette: dark navy (#1A1A2E), blood red (#C41E3A), gold (#FFD700), bone white (#E8E8E8). Traditional Korean patterns adapted for dark fantasy. Center area empty/semi-transparent for content overlay. All elements fully contained.
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
A decorative rectangular panel frame with Korean traditional border patterns. The border is dark navy with thin gold inner-line trim. The four corners have subtle Korean interlocking geometric patterns (격자문) rendered in gold on dark navy. The border width is approximately 16 pixels on each side. The center area is semi-transparent dark navy with very subtle hanji paper texture underneath. The overall impression is elegant, dark, and authoritative — fitting for a Korean underworld aesthetic. Suitable for 9-slice scaling.
```

### frame_panel_ornate — 화려한 패널 (보스전/중요 이벤트용)
**Seed:** 84002 | **크기:** 512x512

```
An ornate decorative rectangular panel frame with elaborate Korean traditional patterns. The border is wider (about 24 pixels) with gold and blood red decorative motifs. The four corners have elaborate cloud-and-crane (운학문) patterns in gold. Small dokkaebi ghost fire cyan accent dots at each corner. The border has layered detail — outer dark navy edge, middle gold pattern band, inner blood red thin line. The center is semi-transparent dark navy. More elaborate and imposing than the default panel — used for important game moments. Suitable for 9-slice scaling.
```

### frame_panel_shop — 상점 패널
**Seed:** 84003 | **크기:** 512x512

```
A warm-toned decorative panel frame for a shop/merchant UI. The border uses dark brown wood texture with gold coin motifs at the corners. Warm orange-amber inner glow along the border edges, as if lit by nearby lanterns. The border has a carved wood appearance with subtle grain texture. Small hanging paper lantern decorations at the top corners. The center is semi-transparent warm dark brown. The frame feels inviting and cozy — a merchant's display case in the underworld market. Suitable for 9-slice scaling.
```

---

## 2. 버튼 프레임 — 4종 (상태별)

> 게임 내 모든 버튼의 배경 이미지. Normal / Hover / Pressed / Disabled 4가지 상태.
> **크기:** 600x110 (실제 300x55의 2배)

### btn_normal — 기본 상태
**Seed:** 84011

```
A pixel art button background in normal/idle state. A dark navy rectangular panel with slightly rounded corners. A thin gold border line runs along all edges. The interior is dark navy (#1A1A2E) with a very subtle lighter center gradient. A thin bright highlight line runs along the top edge only, suggesting a slight raised 3D effect. Clean and minimal — ready for text overlay. No text or symbols on the button. Wide rectangular format.
```

### btn_hover — 호버 상태
**Seed:** 84012

```
A pixel art button background in hover/highlighted state. Same shape as normal button but with brighter gold border that glows slightly. The interior is slightly lighter dark navy. A faint cyan (#00D4FF) inner glow along the border edges suggests the button is active/highlighted. The overall brightness is increased compared to normal state. The button looks "alive" and ready to be clicked.
```

### btn_pressed — 눌린 상태
**Seed:** 84013

```
A pixel art button background in pressed/clicked state. Same shape but the button appears pushed inward — the highlight line moves from top to bottom edge, and the interior is slightly darker than normal. The gold border remains but dims slightly. A subtle shadow appears at the top edge instead of highlight. The button is visually depressed.
```

### btn_disabled — 비활성 상태
**Seed:** 84014

```
A pixel art button background in disabled/grayed-out state. Same shape but all colors are desaturated and dimmed. The gold border becomes dull gray. The interior is flat dark gray without any glow or highlight. The button looks inactive and unresponsive — clearly not clickable.
```

---

## 3. 대화/말풍선 프레임 — 2종

> 뱃사공 대사, 보스 대사, 이벤트 NPC 대사에 사용.

### frame_dialog_normal — 일반 대화
**Seed:** 84021 | **크기:** 800x200

```
A pixel art dialog box background for character speech. A wide horizontal panel with rounded corners in dark navy. A thin gold border frames the box. The left side has a small square portrait area (about 120x120 pixels) outlined in a thicker gold frame — where the speaker's portrait goes. The rest of the panel is open for text content. A small triangular speech indicator points downward from the bottom of the portrait area. The style matches the game's Korean underworld aesthetic. Semi-transparent dark navy interior.
```

### frame_dialog_boss — 보스 대화 (위협적)
**Seed:** 84022 | **크기:** 800x200

```
A pixel art dialog box for boss character speech. Same layout as normal dialog but with blood red accent border instead of gold. The corners have subtle claw-scratch marks or crack patterns. A faint red inner glow along the edges. The portrait area frame is thicker and more aggressive — blood red with dark spikes. The overall impression is threatening and ominous — this speaker is dangerous. Semi-transparent dark navy-red interior.
```

---

## 4. Go/Stop 결정 패널
**Seed:** 84031 | **크기:** 960x400

```
A pixel art split-screen decision panel for the Go/Stop choice in a card game. The panel is divided vertically into two halves with a jagged lightning-bolt line down the center. The LEFT half has a warm red-orange background tint with bold energy — this is the "Go" side, representing risk and greed. A subtle upward arrow motif in the background suggests escalation. The RIGHT half has a cool blue-cyan background tint with calm stability — this is the "Stop" side, representing safety. A subtle shield motif in the background suggests protection. Both halves have thin gold borders on their outer edges. The center dividing line crackles with energy — the tension of the decision. The panel sits on a dark navy base. No text — just the visual split between risk (left/red) and safety (right/blue).
```

---

## 5. 축복 선택 카드 프레임 — 4종

> 축복(업화/빙결/공허/혼돈) 선택 시 각 축복 카드의 프레임.
> **크기:** 300x400 (카드 형태)

### frame_blessing_fire — 업화
**Seed:** 84041

```
A pixel art blessing card frame with fire theme. A tall card-shaped frame with dark border. The border has orange-red flame motifs running along the edges — small pixel art flames licking upward along both sides. The corners have ember/spark decorations. A thin orange inner-glow line. The center is empty/transparent for blessing content. The top has a small flame icon badge. Color palette: flame orange, deep red, dark navy.
```

### frame_blessing_ice — 빙결
**Seed:** 84042

```
A pixel art blessing card frame with ice theme. A tall card-shaped frame with dark border. The border has ice crystal formations growing along the edges — sharp angular frost patterns. The corners have snowflake decorations. A thin cyan inner-glow line. The center is empty/transparent. The top has a small ice crystal icon badge. Color palette: ice cyan, pale blue, dark navy.
```

### frame_blessing_void — 공허
**Seed:** 84043

```
A pixel art blessing card frame with void/emptiness theme. A tall card-shaped frame with dark border. The border appears to be dissolving at the edges — pieces crumbling away into dark particles. The corners have void-hole decorations where the frame seems to break into nothingness. A thin purple inner-glow line. The center is empty/transparent. The top has a small void symbol badge. Color palette: deep purple, near-black, dark navy.
```

### frame_blessing_chaos — 혼돈
**Seed:** 84044

```
A pixel art blessing card frame with chaos theme. A tall card-shaped frame with dark border. The border has distorted warped patterns — as if reality is unstable along the edges. The decorations glitch between multiple colors (red, green, purple) in a chaotic pattern. The corners have spiral/vortex decorations. A thin multicolor shifting inner-glow line. The center is empty/transparent. The top has a small chaos spiral badge. Color palette: crimson, toxic green, purple — all clashing.
```

---

## 6. 구분선 장식 — 2종

> 패널 내부 섹션 사이의 장식적 구분선.
> **크기:** 800x16 (가로로 길고 얇음)

### separator_default — 기본 구분선
**Seed:** 84051

```
A thin horizontal decorative separator line with Korean traditional pattern. A dark navy line with a small diamond-shaped gold ornament at the center. Very thin gold pinstripes run along both sides of the main line. The overall width fills the image and the height is minimal — a clean elegant divider. Transparent background above and below the line.
```

### separator_ornate — 화려한 구분선
**Seed:** 84052

```
A wider horizontal decorative separator with elaborate Korean cloud pattern (구름문). Gold interlocking cloud motifs spread across a dark navy band. Small red accent dots punctuate the pattern at regular intervals. More decorative than the default — used for important section dividers. Transparent background above and below.
```

---

## 7. 상점 아이템 카드 프레임
**Seed:** 84061 | **크기:** 360x480

```
A pixel art shop item card frame for displaying purchasable items. A tall card-shaped frame with dark brown wood border suggesting a merchant's display. A gold price tag area at the bottom (about 60 pixels tall) for showing the cost. The top has a small banner area for the item name. The center is empty/transparent for the item icon/illustration. Small coin decorations at the bottom corners near the price area. The frame feels like a merchant's product display card in an underworld bazaar. Color palette: dark brown wood, gold trim, warm amber accents on dark navy.
```

---

## 8. 카드 선택 하이라이트
**Seed:** 84071 | **크기:** 270x390 (카드 크기와 동일)

```
A pixel art card selection highlight overlay. A glowing golden border that fits exactly over a hwatu card shape. The border glows with warm gold light — thicker and brighter than a normal card frame. The center is completely transparent so the card underneath shows through. Small sparkle effects at the four corners. The glow extends slightly beyond the card edges, creating a "selected" aura effect. This overlay indicates the player has selected this card. Color: warm gold glow border, transparent center.
```

---

## 9. 페이즈 표시 배너 — 2종

> 현재 게임 페이즈(고스톱 페이즈 / 공격 페이즈)를 표시하는 배너.
> **크기:** 400x80

### banner_gostop_phase — 고스톱 페이즈
**Seed:** 84081

```
A pixel art phase indicator banner reading area for the card matching phase. A horizontal banner with dark navy background and gold border trim. The left side has a small hwatu card icon motif. The right side has a decorative tassel/end. Warm amber-gold coloring suggesting the collection phase — gathering cards. The center is open for text overlay. Color: dark navy, gold trim, warm amber accents.
```

### banner_attack_phase — 공격 페이즈
**Seed:** 84082

```
A pixel art phase indicator banner for the attack/scoring phase. Same shape as the gostop phase banner but with blood red accent coloring instead of amber. The left side has a small sword or fist icon motif suggesting attack. More aggressive and intense than the collection phase banner. The center is open for text overlay. Color: dark navy, gold trim, blood red accents.
```

---

## 10. 승리/패배 화면 배경 — 2종

> **크기:** 960x540 (→ 업스케일 1920x1080)

### screen_victory — 승리 (관문 돌파)
**Seed:** 84091

```
A pixel art victory screen background. A dramatic dark navy background with brilliant golden light rays bursting from the center outward. Small gold particles and sparkles drift across the scene. Faint traditional Korean celebratory patterns (like flying cranes or auspicious clouds) are visible in the golden light. The atmosphere is triumphant and liberating — a gate has been passed. The center area is relatively clear for text/score overlay. 16-bit retro pixel art with crisp pixels. Color palette: dark navy, brilliant gold, warm white light.
```

### screen_defeat — 패배 (게임 오버)
**Seed:** 84092

```
A pixel art game over screen background. A dark scene fading to near-black from the edges inward. Faint red cracks spread across the dark surface like broken glass. A dim blood red glow emanates weakly from the center, fading. Ghost fire wisps in pale blue drift slowly downward — souls descending. The atmosphere is somber and final — everything is lost. The center area has enough contrast for text overlay. 16-bit retro pixel art. Color palette: near-black, fading blood red, dim ghost blue wisps.
```

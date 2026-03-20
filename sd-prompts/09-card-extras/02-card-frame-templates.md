# 화투패 프레임 템플릿 (카드 타입별 4종)

> **핵심 개념:** 카드 = 프레임(고정) + 일러스트(교체 가능)
> 프레임은 카드 타입별로 고정. 일러스트만 바꾸면 디자인 변경 가능.
> 프레임은 AI 생성이 아닌 **코드 또는 도트 에디터**로 만드는 것을 권장.
> AI로 생성 시 아래 프롬프트 사용.

## 레이아웃 구조

```
┌─────────────────┐
│ [타입 헤더바]     │ ← 26px: 타입 색상 + 라벨
├─────────────────┤
│                 │
│  [일러스트 영역]  │ ← 중앙: AI 생성 일러스트가 들어가는 곳
│                 │
│                 │
├─────────────────┤
│ [카드 이름]      │ ← 하단: 이름 텍스트
│ [포인트]         │ ← 최하단: 점수
└─────────────────┘

프레임 생성 시:
- 일러스트 영역은 투명 (빈 공간)
- 헤더, 테두리, 하단 바만 그린다
- 코드에서 프레임 + 일러스트를 합성
```

## 카드 크기

```yaml
최종 표시 크기: 88 x 125 px (게임 내)
프레임 생성 크기: 264 x 375 (3배, → Nearest Neighbor 다운스케일)
일러스트 삽입 영역: 프레임 내부 74 x 70 px (중앙)
```

## 합성 순서 (코드에서 처리)

```
1. 프레임 PNG 로드 (타입별)
2. 일러스트 PNG 로드 (월별)
3. 일러스트를 프레임의 투명 영역에 삽입
4. 텍스트(카드 이름, 포인트) 오버레이
5. → 완성된 카드
```

## 프레임 타입 (4종)

### 생성 환경

```yaml
Model: Flux-dev (ComfyUI)
Resolution: 264 x 375 (88x125 × 3배)
Steps: 20~25
Guidance: 3.5
Batch: 4장
```

### 공통 프롬프트 프리픽스

```
A low-resolution pixel art card frame template, made of large visible square pixels where each pixel is clearly distinguishable. Drawn on a 88x125 pixel grid. Blocky jagged edges, no smooth curves, no anti-aliasing, no gradients, no blending between pixels. Bold flat color fills with thick black pixel outlines. This is ONLY the frame border — the CENTER must be completely empty (plain solid bright green #00FF00 showing through) for card illustration to be inserted later. Top has a colored header bar, bottom has space for text. The frame is the card's outer shell only.
```

---

### frame_gwang — 광 프레임 (금색)
**Seed:** 78101

```
A golden card frame for the highest-tier Gwang (bright) card type. Bold gold (#FFD700) header bar at top. Thick gold border with subtle decorative pixel notches at corners. A tiny star symbol in the top-left corner of the header. The center is completely empty bright green — only the outer frame exists. Bottom section has a dark bar for text. The gold frame radiates prestige — this is the best card type. Frame colors: gold border, dark navy (#1A1A2E) bottom bar, black outlines.
```

### frame_tti — 띠 프레임 (3종 겸용: 홍단/청단/초단)
**Seed:** 78102

```
A ribbon card frame for the Tti (ribbon) card type. The header bar color will be set by code (red/blue/green). For this template, use a neutral red (#C41E3A) header bar at top. Thin clean border with a small horizontal ribbon decoration at the mid-right edge. The center is completely empty bright green — only the outer frame exists. Bottom section has dark bar for text. Simple and clean — the ribbon color tells the player what type it is. Frame colors: neutral border, dark navy bottom bar, black outlines.
```

### frame_yeolkkeut — 열끗 프레임 (하늘색)
**Seed:** 78103

```
A card frame for the Yeolkkeut (animal/10-point) card type. Light blue (#4488CC) header bar at top. Medium-weight border with a small diamond symbol at the top-right corner of the header. The center is completely empty bright green — only the outer frame exists. Bottom section has dark bar for text. Moderate prestige — better than Pi but not as grand as Gwang. Frame colors: light blue border, dark navy bottom bar, black outlines.
```

### frame_pi — 피 프레임 (회색)
**Seed:** 78104

```
A card frame for the Pi (chaff/1-point) card type. Muted gray (#666666) header bar at top. Thin minimal border — the simplest and most basic frame. No decorative elements. The center is completely empty bright green — only the outer frame exists. Bottom section has dark bar for text. Plain and humble — the lowest card tier. Frame colors: gray border, dark navy bottom bar, black outlines.
```

## 후처리

```
1. 크로마키 그린(#00FF00) 영역 → 투명 알파 (일러스트 삽입 영역)
2. Nearest Neighbor 다운스케일 → 88x125
3. PNG (알파) → Assets/Art/Cards/Frames/
4. 코드에서 frame + illustration 합성
```

## 코드 합성 예시 (Love2D)

```lua
-- 카드 렌더링 시
local frame = card_frames[card.card_type]  -- 프레임 이미지
local illust = card_illusts[card.id]       -- 일러스트 이미지

-- 일러스트 먼저 그리기
love.graphics.draw(illust, x + illust_offset_x, y + illust_offset_y)
-- 프레임을 위에 그리기 (투명 영역으로 일러스트가 보임)
love.graphics.draw(frame, x, y)
-- 텍스트 오버레이
love.graphics.printf(card.name_kr, x, y + name_y, w, "center")
```

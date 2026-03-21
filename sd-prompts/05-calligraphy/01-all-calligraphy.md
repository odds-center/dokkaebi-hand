# 서예/캘리그래피 이미지 프롬프트 — 게임 내 장식 텍스트

Pony Diffusion V6 XL + Isaac LoRA로 **픽셀아트 스타일의 장식 텍스트 이미지**를 생성한다.
부드러운 붓글씨가 아닌 **도트로 찍힌 굵은 글씨** — 픽셀 폰트 느낌.
저승 세계관 분위기를 극대화하되 전체 아트 스타일(픽셀아트)과 통일.

> **Pony + Isaac LoRA:** SD 1.5보다 텍스트 생성 능력이 뛰어남.
> 한자/한글을 프롬프트에 직접 지정하면 어느 정도 정확하게 생성 가능.
> 그래도 100% 정확하지 않으므로 후처리에서 보정하거나 서예 폰트로 교체.

---

## 생성 환경 (캘리그래피 전용)

```yaml
Model: Pony Diffusion V6 XL (ComfyUI)
LoRA: Binding of Isaac Style v2.1 (strength 0.75)
Resolution: 용도별 상이 (아래 참조)
Sampler: euler_a
Steps: 25~30
CFG: 7
Batch: 4~8장 뽑아서 최선 선택
```

### 픽셀아트 텍스트 핵심 원칙
1. **도트 글씨:** 매끄러운 붓글씨가 아닌, 픽셀 블록으로 구성된 굵은 글씨.
2. **계단식 가장자리:** 모든 획이 직각 계단형(jagged stair-step) — 부드러운 곡선 없음.
3. **안티앨리어싱 없음:** 글씨 가장자리에 중간색이나 블러 없음. 검정 아니면 배경색.
4. **두꺼운 획:** 최소 2~3픽셀 두께의 굵은 획으로 작은 크기에서도 읽힘.
5. **플랫 컬러:** 그라디언트나 번짐 없이 단색 면 채우기.
6. **이미지 넘침 방지:** 모든 글씨가 이미지 경계 안에 완전히 들어와야 함.

## 공통 프롬프트 프리픽스

> 모든 캘리그래피 프롬프트 **앞에** 이 문장을 붙인다.

```
score_9, score_8_up, score_7_up, pixel art, game assets, chibi, simple green background, pixel art text logo, Korean underworld card game, thick blocky pixel letters, jagged stair-step edges, no smooth curves, no anti-aliasing, flat colors, thick black outlines, NES SNES era pixel font aesthetic, chroma key green background, fully contained with margins
```

## 공통 네거티브 프롬프트

```
score_4, score_3, score_2, score_1, blurry, photo, realistic, 3d render, smooth shading, anti-aliasing, gradient, soft edges, watercolor, text, watermark, signature
```

## 후처리 (공통)

```
1. 4~8장 중 가장 분위기 좋은 1장 선택
2. 글자 정확도 확인:
   - 정확하게 생성된 경우 → 그대로 사용
   - 글자가 부정확한 경우 → 배경/분위기 텍스처만 살리고
     실제 글자를 서예 폰트로 오버레이
     (추천 폰트: 궁서체, 한겨레결체, 나눔붓글씨)
3. 레벨 보정 (Levels): 배경 완전 투명, 먹물 부분만 선명하게
4. PNG 저장 (알파 포함) → Assets/Art/Calligraphy/
```

## Unity 임포트

```
Texture Type: Sprite (2D and UI)
Sprite Mode: Single
Filter Mode: Point (Nearest Neighbor)
Compression: None
Pixels Per Unit: 100
```

---

## 1. 게임 타이틀 — "도깨비의 패"

**Seed:** 60001 | 8장 배치
**크기:** 1024x256
**용도:** 메인 메뉴 타이틀 로고, 로딩 화면

### 설정
게임의 얼굴. 금빛 먹물로 쓴 전통 서예 느낌.
어두운 배경 위에 극적인 붓놀림. 도깨비의 괴기한 분위기와 화투의 화려함을 동시에.

### 프롬프트
```
Korean title text 도깨비의 패, dramatic golden ink, very dark navy background, large brush sweeping powerful strokes, pressure variation thick to thin, rich gold with warm orange undertones, molten gold ink, ink splatter and drips, ghostly smoke wisps, red seal stamp in corner, ornate grand strokes, thin elegant trailing tails, wide horizontal banner, centered composition with generous margins, supernatural eerie atmosphere, dark fantasy, beautiful calligraphy
```

### 후처리
```
1. 배경은 유지 (타이틀이므로 배경 포함)
2. 금색 부분 색감 강화 — Hue/Saturation에서 Gold 강조
3. 글자 정확도 확인 — 부정확하면 서예 폰트로 "도깨비의 패" 합성
4. 연기/안개 효과가 부족하면 별도 오버레이 추가
5. 1024x256 PNG → Assets/Art/Calligraphy/title_dokkaebi.png
```

---

## 2. 축복 이름 (4종)

축복(Blessing) 선택 화면에서 표시되는 이름 뱃지.
각 축복의 속성에 맞는 서예 스타일로 분위기를 강조한다.

**크기:** 512x128 (각각)

### 2-1. 업화(業火) — 화염 서예
**Seed:** 60011
**용도:** 축복 "업화" 이름 뱃지

```
Chinese characters 業火, fierce burning text, dark background, fire-made letter blocks, glowing orange-red molten lava ink, flickering ablaze edges, sparks and floating embers, aggressive wild strokes, charred black edges, smoky heat haze distortion, wide horizontal banner, centered with comfortable margins, deep red, flame orange, charcoal black
```

### 2-2. 빙결(氷結) — 빙결 서예
**Seed:** 60012
**용도:** 축복 "빙결" 이름 뱃지

```
Chinese characters 氷結, frozen crystalline text, dark background, ice-made letter blocks, pale blue with crystalline frost edges, frozen ink, ice crystal formations on stroke edges, cold mist, snowflakes, icicle formations dripping downward, precise sharp brittle strokes, wide horizontal banner, centered with generous margins, ice blue, pale white, dark navy background
```

### 2-3. 공허(空虛) — 공허 서예
**Seed:** 60013
**용도:** 축복 "공허" 이름 뱃지

```
Chinese characters 空虛, dissolving dark text, pitch black background, void-consumed letters, fading into nothingness, ink fragments disintegrating into dark particles, faint deep purple glow outline, bold strokes erased by darkness, cosmic void atmosphere, wide horizontal banner, centered composition within bounds, deep purple, pitch black, faint violet
```

### 2-4. 혼돈(混沌) — 혼돈 서예
**Seed:** 60014
**용도:** 축복 "혼돈" 이름 뱃지

```
Chinese characters 混沌, chaotic swirling text, dark background, warped distorted letters, unnatural bending, reality unstable, clashing colors within strokes, crimson bleeding into toxic green shifting to purple, chaotic energy spirals, vortex patterns, prismatic color splits, glitch fragmentation, wild unpredictable strokes, wide horizontal banner, centered within bounds, crimson, toxic green, purple, clashing colors
```

### 축복 후처리
```
1. 배경 제거 → 알파 채널로 변환
2. 각 축복 컬러에 맞게 색감 보정
3. 글자 확인 — 부정확하면 서예 폰트로 한자+한글 합성
   - "業火" (큰 글자) + "업화" (작은 글자)
4. 512x128 PNG (알파) → Assets/Art/Calligraphy/blessing_*.png
```

---

## 3. 족보 이름 (주요 10종)

고스톱 족보 완성 시 화면에 표시되는 족보 이름 뱃지.
각 족보 테마에 맞는 색상 악센트를 넣어 시각적 구분.

**크기:** 384x128 (각각)
**기본 스타일:** 먹물 붓글씨 + 테마 컬러 악센트

### 3-1. 오광 (五光)
**Seed:** 60021
**용도:** 족보 "오광" 달성 표시

```
Korean text 오광, bold golden text, radiant light, thick confident letters, rich gold ink, brilliant glow, golden light rays bursting outward, five star-like light accent points, divine heavenly illumination, sacred energy, dark background, gold focal point, horizontal banner, centered and fully contained, brilliant gold, white light, dark navy
```

### 3-2. 사광 (四光)
**Seed:** 60022
**용도:** 족보 "사광" 달성 표시

```
Korean text 사광, silver-gold text, bright moonlight glow, bold graceful strokes, mixed silver and pale gold, four subtle light points, celestial atmosphere, subdued luminance, dark background, horizontal banner, centered and fully contained, silver, pale gold, dark navy
```

### 3-3. 삼광 (三光)
**Seed:** 60023
**용도:** 족보 "삼광" 달성 표시

```
Korean text 삼광, warm amber text, soft golden glow, bold warm letters, amber-gold color, three gentle light accents, warmly illuminated atmosphere, gentle and inviting, dark background, horizontal banner, centered and fully contained, amber, warm gold, dark background
```

### 3-4. 홍단 (紅丹)
**Seed:** 60024
**용도:** 족보 "홍단" 달성 표시

```
Korean text 홍단, deep crimson red text, bold flowing letters, rich blood-red color, dark background, red ribbon accent element, deep crimson with darker shadows, elegant traditional style, horizontal banner, centered and fully contained, crimson red, dark red, black
```

### 3-5. 청단 (靑丹)
**Seed:** 60025
**용도:** 족보 "청단" 달성 표시

```
Korean text 청단, deep royal blue text, bold refined letters, rich blue color, dark background, blue ribbon accent element, cyan highlights, cool refined style, horizontal banner, centered and fully contained, royal blue, cyan accents, dark navy
```

### 3-6. 초단 (草丹)
**Seed:** 60026
**용도:** 족보 "초단" 달성 표시

```
Korean text 초단, dark forest green text, bold organic letters, deep green color, dark background, grass and vine accents on stroke edges, natural decoration, brighter green highlights, organic natural quality, horizontal banner, centered and fully contained, forest green, bright green accents, dark background
```

### 3-7. 고도리
**Seed:** 60027
**용도:** 족보 "고도리" 달성 표시

```
Korean text 고도리, warm brown text, bird silhouette accents, elegant flowing letters, warm brown-orange color, dark background, tiny flying bird silhouettes scattered decoratively, warm autumnal atmosphere, naturalistic style, horizontal banner, centered and fully contained, warm brown, orange, dark background
```

### 3-8. 총통
**Seed:** 60028
**용도:** 족보 "총통" 달성 표시

```
Korean text 총통, explosive bold text, impact energy, extremely thick aggressive letters, black color with bright yellow flash accents, shockwave radial lines bursting outward, powerful commanding force, maximum impact strokes, dark background, bright yellow flash energy, horizontal banner, centered and fully contained, bright yellow, white flash, dark navy
```

### 3-9. 사계 (四季)
**Seed:** 60029
**용도:** 족보 "사계" 달성 표시 (저승 족보)

```
Korean text 사계, flowing text, four-season color transitions within strokes, left to right color flow, pink cherry blossom tones, green summer, orange autumn, white winter, seasonal elements in brush texture, petals and snowflakes, dark background, colorful calligraphy, horizontal banner, centered and fully contained, pink, green, orange, white transitioning on dark
```

### 3-10. 도깨비불
**Seed:** 60030
**용도:** 족보 "도깨비불" 달성 표시 (저승 족보)

```
Korean text 도깨비불, ghostly blue-green text, supernatural fire, spectral blue-green ink, eerie inner glow, will-o-wisp flames dancing and flickering, small floating supernatural fires, ghostly otherworldly atmosphere, calligraphy glowing from within, ghost flame, dark background, spectral green glow, horizontal banner, centered and fully contained, spectral green, ghostly blue, dark navy
```

### 족보 후처리
```
1. 배경 제거 → 알파 채널
2. 각 족보 테마 컬러에 맞게 색감 보정
3. 글자 확인 — 부정확하면 서예 폰트로 족보 이름 합성
4. 384x128 PNG (알파) → Assets/Art/Calligraphy/jokbo_*.png
```

---

## 4. 보스 이름 (6종)

보스 등장 시 화면에 크게 표시되는 이름 뱃지.
위협적이고 극적인 붓놀림으로 보스의 포스를 전달.

**크기:** 512x128 (각각)
**기본 스타일:** 공포스럽고 강렬한 먹물 서예, 다크 판타지

### 4-1. 먹보 도깨비
**Seed:** 60041
**용도:** 보스 "먹보 도깨비" 등장 연출

```
Korean text 먹보 도깨비, thick greedy text, dripping ink, bloated heavy letters, overloaded ink, dripping and splattering, gluttonous brush, dark black with reddish-orange undertones, glowing from within, excess and gluttony, menacing ominous, dark fantasy atmosphere, dark background, reddish-orange glow, horizontal banner, centered and fully contained, reddish orange, blood red, black
```

### 4-2. 여우 도깨비
**Seed:** 60042
**용도:** 보스 "여우 도깨비" 등장 연출

```
Korean text 여우 도깨비, elegant sinuous text, seductive curves, thin graceful dangerously beautiful letters, fox tail curved strokes, dark ink with purple fox-fire glow, purple energy wisps like smoke, beautiful but unsettling, elegant danger, dark background, purple glow, horizontal banner, centered and fully contained, purple, lavender, dark navy
```

### 4-3. 불꽃 도깨비
**Seed:** 60043
**용도:** 보스 "불꽃 도깨비" 등장 연출

```
Korean text 불꽃 도깨비, burning aggressive text, fire and rage, strokes on fire, trailing sparks and embers, orange-red flame ink, charred cracked black edges, scorching heat distortion, violent aggressive strokes, dark background, intense flame glow, horizontal banner, centered and fully contained, flame orange, bright orange, charcoal black
```

### 4-4. 그림자 도깨비
**Seed:** 60044
**용도:** 보스 "그림자 도깨비" 등장 연출

```
Korean text 그림자 도깨비, fading shadow text, partially dissolving into darkness, strokes appearing and disappearing, shadow-consumed characters, shadowy tendrils extending into darkness, near-black background, faint dark blue undertone, oppressive suffocating darkness, horizontal banner, centered within bounds, near-black, dark blue, pitch black
```

### 4-5. 염라대왕
**Seed:** 60045
**용도:** 보스 "염라대왕" 등장 연출

```
Korean text 염라대왕, Chinese characters 閻羅大王 smaller beneath, commanding imperial text, divine authority, large bold Korean text, regal power, thick commanding confident strokes, blood red ink with gold accents, royal gold detailing, absolute authority of judge of the dead, dark background, blood red and gold glow, horizontal banner, centered and fully contained, blood red, gold, black
```

### 4-6. 오도전륜왕
**Seed:** 60046
**용도:** 최종 보스 "오도전륜왕" 등장 연출

```
Korean text 오도전륜왕, cosmic overwhelming text, transcendent power, impossibly large powerful letters, reality-warping strokes, ink shifting through cosmic purple divine gold ethereal white, otherworldly color shifts, reality-warping distortion, cosmic energy, circular dharma wheel motifs orbiting, beyond mortal comprehension, transcendent atmosphere, dark background, otherworldly multicolor glow, horizontal banner, centered and fully contained, cosmic purple, gold, white light, deep black
```

### 보스 후처리
```
1. 배경은 반투명으로 유지 (등장 연출에 배경 포함)
2. 보스 테마 컬러 강화
3. 글자 확인 — 부정확하면 서예 폰트로 보스 이름 합성
4. 등장 연출용이므로 약간 과장된 효과 OK
5. 512x128 PNG → Assets/Art/Calligraphy/boss_*.png
```

---

## 5. UI 텍스트 뱃지 (8종)

게임 플레이 중 화면에 팝업되는 액션 텍스트.
임팩트 있는 굵은 붓글씨로 순간적인 피드백 전달.

**크기:** 256x128 (각각)
**기본 스타일:** 굵고 강렬한 임팩트 서예, 다이나믹

### 5-1. 고! (GO!)
**Seed:** 60051
**용도:** "고" 선택 시 화면 팝업

```
Korean text 고!, single explosive bold brush stroke, impact badge, maximum energy, bright cyan energy burst shockwave, dynamic speed lines radiating outward, thick bold stroke, forward momentum, dark background, bright cyan energy glow, square badge format, centered with comfortable margins, bright cyan, white flash, dark navy
```

### 5-2. 스톱! (STOP!)
**Seed:** 60052
**용도:** "스톱" 선택 시 화면 팝업

```
Korean text 스톱!, heavy final brush stroke, impact badge, decisive weight, thick absolute stroke, maximum force, crimson red energy, impact crack lines radiating, absolute finality, dark background, crimson red glow, square badge format, centered and fully contained, crimson red, dark red, white impact flash
```

### 5-3. 격파! (DEFEATED!)
**Seed:** 60053
**용도:** 보스 격파 시 화면 팝업

```
Korean text 격파!, shattering explosive text, destructive triumphant force, letters breaking apart, ink fragments flying outward like explosion, golden burst of victory energy, cracks and fragments radiating, triumphant victorious atmosphere, dark background, golden explosion glow, square badge format, centered within bounds, gold, bright yellow, dark background
```

### 5-4. 매칭! (MATCH!)
**Seed:** 60054
**용도:** 카드 매칭 성공 시 피드백

```
Korean text 매칭!, swift connecting text, linking energy, two brush elements merging at center, connection and combination, green success glow at connection point, swift dynamic strokes, quick confident, dark background, green success glow, square badge format, centered and fully contained, green, bright green, white, dark background
```

### 5-5. 쓸! (SWEEP!)
**Seed:** 60055
**용도:** 바닥패 쓸 시 피드백

```
Korean text 쓸!, sweeping horizontal brush stroke, gathering motion, powerful wide horizontal sweep, collecting motion, golden sweep glow trailing behind, horizontal sweeping motion lines, dark background, golden sweep glow, square badge format, centered and fully contained, gold, warm amber, dark navy
```

### 5-6. 관문 돌파! (GATE CLEAR!)
**Seed:** 60056
**용도:** 관문(스테이지) 클리어 시 팝업

```
Korean text 관문 돌파!, breakthrough ascending text, rising energy, letters angling upward dramatically, piercing through invisible barrier, bright white-gold light streaming upward, triumphant ascension, breaking through and rising, dark background, bright white-gold upward light, square badge format, centered and fully contained, white, gold, bright light, dark navy
```

### 5-7. 게임 오버 (GAME OVER)
**Seed:** 60057
**용도:** 사망 시 화면 표시

```
Korean text 게임 오버, somber fading text, dissolving strokes, crumbling disintegrating letters, ink falling apart into particles drifting downward, faint red glow fading, everything fading to darkness, dying calligraphy, mournful final atmosphere, dark background, fading gray tones, square badge format, centered within bounds, fading gray, dark red, near-black
```

### 5-8. 윤회 (REINCARNATION)
**Seed:** 60058
**용도:** 윤회(새 사이클) 시작 표시

```
Korean text 윤회, mystical circular flowing text, spiral cycle, circular pattern flow, ouroboros-like loop connecting last stroke to first, ethereal blue-white glow, cyclical spiraling energy orbiting, eternal renewal, death and rebirth cycle, dark background, ethereal blue-white glow, square badge format, centered and fully contained, ethereal blue, white spirit-glow, dark navy
```

### UI 텍스트 후처리
```
1. 배경 완전 제거 → 투명 알파
2. 텍스트 효과만 남기고, 글자 부정확 시 서예 폰트로 합성
3. 팝업 애니메이션용이므로 여백 충분히 확보
4. 256x128 PNG (알파) → Assets/Art/Calligraphy/ui_*.png
```

---

## 6. 시스템 아이콘/뱃지 (5종)

단일 한자 뱃지. 카드 분류 아이콘이나 UI 표시에 사용.
정사각형 포맷, 굵은 단일 글자, 배경색으로 타입 구분.

**크기:** 128x128 (각각, 정사각형)
**기본 스타일:** 단일 한자를 큰 붓으로 힘차게 쓴 서예

### 6-1. 光 (광) 뱃지
**Seed:** 60061
**용도:** 광 카드 분류 아이콘

```
single large Chinese character 光, meaning light, bold text, centered, golden yellow background, thick confident black color, powerful brush strokes, filling most of square frame, subtle radiance glow, clear pressure variation, natural ink texture, square 1:1 format, fully contained with comfortable margins, gold background, black color, white highlight accents
```

### 6-2. 紅 (홍) 뱃지
**Seed:** 60062
**용도:** 홍단 카드 분류 아이콘

```
single large Chinese character 紅, meaning red, bold text, centered, deep crimson red background, thick confident black color, powerful letter blocks, deep rich blood-like crimson, natural variation and texture, square 1:1 format, fully contained with margins, crimson red background, black color, dark red shadows
```

### 6-3. 靑 (청) 뱃지
**Seed:** 60063
**용도:** 청단 카드 분류 아이콘

```
single large Chinese character 靑, meaning blue/green, bold text, centered, deep royal blue background, thick confident white color, standing out brightly against blue, deep rich royal blue, square 1:1 format, fully contained with margins, royal blue background, white color, navy shadows
```

### 6-4. 草 (초) 뱃지
**Seed:** 60064
**용도:** 초단 카드 분류 아이콘

```
single large Chinese character 草, meaning grass, bold text, centered, deep forest green background, thick confident black color, deep natural forest green, square 1:1 format, fully contained with margins, forest green background, black color, dark green shadows
```

### 6-5. 피 뱃지
**Seed:** 60065
**용도:** 피/쌍피 카드 분류 아이콘

```
single large Korean character 피, meaning junk card, bold text, centered, warm amber-orange background, thick confident black color, warm fiery glow, square 1:1 format, fully contained with margins, amber orange background, black color, dark red accents
```

### 시스템 뱃지 후처리
```
1. 정사각형 비율 확인 (128x128)
2. 배경색 균일하게 보정
3. 글자 확인 — 정확하게 생성된 경우 그대로 사용
   부정확한 경우 서예 폰트로 한자 1글자 교체
4. 128x128 PNG → Assets/Art/Calligraphy/badge_*.png
```

---

## 7. 화투 카드 위 띠(리본) 텍스트 (3종)

카드 일러스트 위에 올라가는 띠(리본)의 텍스트 이미지.
홍단/청단/초단 글씨를 붓글씨 캘리그래피로 생성.

**크기:** 64x192 (세로로 긴 형태 — 띠 위에 세로 쓰기)
**기본 스타일:** 리본 위에 세로로 쓴 굵은 붓글씨

### 7-1. 홍단 띠 텍스트
**Seed:** 60071

```
Korean characters 홍단, vertical writing, bold black text, bright vivid red ribbon background, top-to-bottom traditional vertical direction, red ribbon filling tall narrow image, thick confident letters, blocky edges, horsehair brush, visible pressure variation, slight ink bleed, tall narrow vertical format, centered on red ribbon with top and bottom margins
```

### 7-2. 청단 띠 텍스트
**Seed:** 60072

```
Korean characters 청단, vertical writing, bold white text, bright vivid blue ribbon background, top-to-bottom traditional vertical direction, blue ribbon filling tall narrow image, thick confident letters, blocky edges, white ink standing out brightly against blue, tall narrow vertical format, centered with margins, fully contained
```

### 7-3. 초단 띠 텍스트
**Seed:** 60073

```
Korean characters 초단, vertical writing, bold black text, red ribbon with grass-green tint, top-to-bottom direction, ribbon filling tall narrow image, thick letters, blocky edges, tall narrow vertical format, centered with margins, fully contained
```

### 띠 텍스트 후처리
```
1. 글자 정확도 확인 — 필수적으로 정확해야 함
2. 부정확 시 서예 폰트로 교체 (배경 리본 색상은 유지)
3. 64x192 PNG → Assets/Art/Calligraphy/ribbon_*.png
4. 카드 일러스트 합성 방법:
   - MockupSpriteFactory에서 카드 앞면 스프라이트 생성 시
   - 02-card-illustrations의 카드 일러스트 위에
   - 이 띠 텍스트 이미지를 대각선으로 회전+배치하여 오버레이
   - 즉: [카드 일러스트] + [띠 리본 텍스트] + [카드 프레임] = 완성 카드
```

---

## 서예 이미지 활용 요약

| 카테고리 | 수량 | 크기 | 용도 | Seeds |
|----------|------|------|------|-------|
| 게임 타이틀 | 1 | 1024x256 | 메인 메뉴 로고 | 60001 |
| 축복 이름 | 4 | 512x128 | 축복 선택 화면 | 60011~60014 |
| 족보 이름 | 10 | 384x128 | 족보 달성 표시 | 60021~60030 |
| 보스 이름 | 6 | 512x128 | 보스 등장 연출 | 60041~60046 |
| UI 텍스트 | 8 | 256x128 | 게임 플레이 피드백 | 60051~60058 |
| 시스템 뱃지 | 5 | 128x128 | 카드 분류 아이콘 | 60061~60065 |
| 띠 텍스트 | 3 | 64x192 | 카드 리본 텍스트 | 60071~60073 |
| **합계** | **37** | — | — | — |

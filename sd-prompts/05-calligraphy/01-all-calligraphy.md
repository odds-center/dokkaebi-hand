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
The Korean title "도깨비의 패" written in dramatic golden ink pixel art text on a very dark navy background. The characters are written with a large brush in sweeping powerful strokes — each stroke shows clear pressure variation from thick to thin. The ink color is rich gold with subtle warm orange undertones, as if written with molten gold ink. Dramatic ink splatter and drips surround the main text, adding energy and chaos. Ghostly wisps of faint smoke curl around the edges of the characters. A small red seal stamp impression sits in one corner as a traditional artist's mark. The pixel rendering is ornate and grand — bold thick strokes with thin elegant tails that trail off into wisps. Wide horizontal banner composition. The calligraphy sits centered with generous margins — nothing touches or extends beyond any edge of the image. The overall atmosphere is supernatural and eerie yet beautiful.
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
The Chinese characters "業火" written in fierce burning pixel art text on a dark background. The pixel letter blocks appear to be made of fire — the ink is glowing orange-red like molten lava, with the edges of each stroke flickering as if ablaze. Sparks and floating embers drift away from the character strokes. The pixel rendering is aggressive and wild — fast powerful strokes with charred black edges where the fire burned hottest. A smoky heat haze distortion surrounds the text. Wide horizontal banner format. The characters are centered with comfortable margins — fully contained within the image. Color palette: deep red, flame orange, charcoal black.
```

### 2-2. 빙결(氷結) — 빙결 서예
**Seed:** 60012
**용도:** 축복 "빙결" 이름 뱃지

```
The Chinese characters "氷結" written in frozen crystalline pixel art text on a dark background. The pixel letter blocks appear to be made of ice — pale blue with crystalline frost forming along every edge. The ink looks as if it froze the moment it touched the paper, with tiny ice crystal formations growing outward from the stroke edges. Cold mist and a few snowflakes drift in the air around the characters. Small icicle formations drip downward from the lowest strokes. The pixel rendering is precise and sharp — the cold made every stroke brittle and angular. Wide horizontal banner format. Characters centered with generous margins. Color palette: ice blue, pale white, dark navy background.
```

### 2-3. 공허(空虛) — 공허 서예
**Seed:** 60013
**용도:** 축복 "공허" 이름 뱃지

```
The Chinese characters "空虛" written in dissolving dark pixel art text on a pitch black background. The pixel letter blocks appear to be consumed by void — parts of each character are fading away into nothingness, with fragments of ink floating and disintegrating into dark particles. A faint deep purple glow outlines the remaining visible portions. The pixel rendering shows strokes that were once bold but are now being erased by darkness itself. The surrounding space feels like a cosmic void — an absence of everything. Wide horizontal banner format. Characters centered with margins — parts dissolve but the composition stays within bounds. Color palette: deep purple, pitch black, faint violet.
```

### 2-4. 혼돈(混沌) — 혼돈 서예
**Seed:** 60014
**용도:** 축복 "혼돈" 이름 뱃지

```
The Chinese characters "混沌" written in chaotic swirling pixel art text on a dark background. The pixel letters are warped and distorted — bending in unnatural directions as if reality itself is unstable. Multiple clashing colors appear within the same strokes — crimson bleeds into toxic green which shifts to purple. Chaotic energy spirals and vortex patterns swirl around the characters. The ink appears to glitch with prismatic color splits and fragmentation. The pixel rendering is wild and unpredictable — no two strokes follow the same rules. Wide horizontal banner format. Characters centered within the image bounds despite the chaos. Color palette: crimson, toxic green, purple, all clashing on dark.
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
The Korean text "오광" written in bold golden pixel art text with radiant light. The pixel letters are thick and confident, made with rich gold ink that glows brilliantly. Golden light rays burst outward from behind the characters. Five small light accent points are scattered around the text like stars. The pixel rendering conveys divine heavenly illumination — powerful strokes that radiate sacred energy. Dark background with the gold calligraphy as the brilliant focal point. Horizontal banner format. Characters centered and fully contained within the image. Color palette: brilliant gold, white light, dark navy background.
```

### 3-2. 사광 (四光)
**Seed:** 60022
**용도:** 족보 "사광" 달성 표시

```
The Korean text "사광" written in silver-gold pixel art text with bright moonlight glow. The strokes are bold and graceful in mixed silver and pale gold pixel color. Four subtle light points are arranged around the text. The atmosphere is celestial — bright but slightly more subdued than 오광. Pixel art style with silver-gold coloring on a dark background. Horizontal banner format. Characters centered and fully contained. Color palette: silver, pale gold, dark navy.
```

### 3-3. 삼광 (三光)
**Seed:** 60023
**용도:** 족보 "삼광" 달성 표시

```
The Korean text "삼광" written in warm amber pixel art text with a soft golden glow. The pixel letters are bold and warm, in amber-gold pixel color. Three gentle light accents surround the text. The atmosphere is warmly illuminated — gentle and inviting. Pixel art style with amber-gold tones on a dark background. Horizontal banner format. Characters centered and fully contained. Color palette: amber, warm gold, dark background.
```

### 3-4. 홍단 (紅丹)
**Seed:** 60024
**용도:** 족보 "홍단" 달성 표시

```
The Korean text "홍단" written in deep crimson red pixel art text. The pixel letters are bold and flowing, in rich blood-red pixel color on a dark background. A red ribbon accent element flows elegantly around the text. The ink is deep crimson with darker shadows in the thickest parts of each stroke. The pixel rendering is elegant and traditional. Horizontal banner format. Characters centered and fully contained. Color palette: crimson red, dark red, black.
```

### 3-5. 청단 (靑丹)
**Seed:** 60025
**용도:** 족보 "청단" 달성 표시

```
The Korean text "청단" written in deep royal blue pixel art text. The pixel letters are bold and refined, in rich blue pixel color on a dark background. A blue ribbon accent element flows around the text. The color is deep royal blue with cyan highlights catching the light. The pixel rendering is cool and refined. Horizontal banner format. Characters centered and fully contained. Color palette: royal blue, cyan accents, dark navy.
```

### 3-6. 초단 (草丹)
**Seed:** 60026
**용도:** 족보 "초단" 달성 표시

```
The Korean text "초단" written in dark forest green pixel art text. The pixel letters are bold and organic, in deep green pixel color on a dark background. Subtle grass and vine accents grow along the edges of the strokes as natural decoration. The color is deep forest green with brighter green highlights. The pixel rendering has an organic natural quality. Horizontal banner format. Characters centered and fully contained. Color palette: forest green, bright green accents, dark background.
```

### 3-7. 고도리
**Seed:** 60027
**용도:** 족보 "고도리" 달성 표시

```
The Korean text "고도리" written in warm brown pixel art text with bird silhouette accents. The pixel letters are elegant and flowing, in warm brown-orange pixel color on a dark background. Tiny bird silhouette shapes are scattered decoratively around the text — small flying birds in ink. The atmosphere is warm and autumnal. Naturalistic pixel art style. Horizontal banner format. Characters centered and fully contained. Color palette: warm brown, orange, dark background.
```

### 3-8. 총통
**Seed:** 60028
**용도:** 족보 "총통" 달성 표시

```
The Korean text "총통" written in explosive bold pixel art text with impact energy. The pixel letters are extremely thick and aggressive, made with black pixel color with bright yellow flash accents. Shockwave-like radial lines burst outward from the center of the text. The pixel rendering conveys powerful commanding force — each stroke slams onto the paper with maximum impact. Dark background with bright yellow flash energy. Horizontal banner format. Characters centered and fully contained. Color palette: bright yellow, white flash, dark navy.
```

### 3-9. 사계 (四季)
**Seed:** 60029
**용도:** 족보 "사계" 달성 표시 (저승 족보)

```
The Korean text "사계" written in flowing pixel art text with four-season color transitions within the strokes. The pixel rendering flows from left to right, with the ink color transitioning smoothly: pink cherry blossom tones at the start, transitioning through green summer, then orange autumn, ending in white winter. Seasonal elements are subtly woven into the brush texture — a petal here, a snowflake there. Dark background behind the colorful calligraphy. Horizontal banner format. Characters centered and fully contained. Color palette: pink, green, orange, white — all transitioning on dark.
```

### 3-10. 도깨비불
**Seed:** 60030
**용도:** 족보 "도깨비불" 달성 표시 (저승 족보)

```
The Korean text "도깨비불" written in ghostly blue-green pixel art text with supernatural fire. The pixel letters are made with spectral blue-green ink that glows with an eerie inner light. Will-o-wisp flames dance and flicker around the characters — small floating supernatural fires in pale blue-green. The atmosphere is ghostly and otherworldly. The ink seems to glow from within, as if the calligraphy itself is a ghost flame. Dark background with spectral green glow. Horizontal banner format. Characters centered and fully contained. Color palette: spectral green, ghostly blue, dark navy.
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
The Korean text "먹보 도깨비" written in thick greedy pixel art text with dripping ink. The pixel letters are bloated and heavy — overloaded with too much ink, dripping and splattering as if the brush itself is gluttonous. The ink is dark black with reddish-orange undertones glowing from within. Ink drips and splatters suggest excess and gluttony. The pixel rendering is menacing and ominous with a dark fantasy atmosphere. Dark background with reddish-orange glow behind the text. Horizontal banner format. Characters centered and fully contained with no overflow. Color palette: reddish orange, blood red, black.
```

### 4-2. 여우 도깨비
**Seed:** 60042
**용도:** 보스 "여우 도깨비" 등장 연출

```
The Korean text "여우 도깨비" written in elegant sinuous pixel art text with seductive curves. The pixel letters are thin, graceful, and dangerously beautiful — each stroke curves like a fox's tail. The ink is dark with purple fox-fire glow along the edges. Wisps of purple energy curl around the characters like smoke. The pixel rendering is beautiful but unsettling — elegant danger. Dark background with purple glow. Horizontal banner format. Characters centered and fully contained. Color palette: purple, lavender, dark navy.
```

### 4-3. 불꽃 도깨비
**Seed:** 60043
**용도:** 보스 "불꽃 도깨비" 등장 연출

```
The Korean text "불꽃 도깨비" written in burning aggressive pixel art text made of fire and rage. The strokes appear to be literally on fire — trailing sparks and embers fly from each character. The ink is orange-red flame with charred cracked black edges. Scorching heat distortion warps the air around the text. The pixel rendering is violent and aggressive — each stroke attacks the paper. Dark background with intense flame glow. Horizontal banner format. Characters centered and fully contained. Color palette: flame orange, bright orange, charcoal black.
```

### 4-4. 그림자 도깨비
**Seed:** 60044
**용도:** 보스 "그림자 도깨비" 등장 연출

```
The Korean text "그림자 도깨비" written in fading shadow pixel art text that partially dissolves into darkness. The strokes appear and disappear — parts of each character are invisible, consumed by shadow. Shadowy tendrils extend from the remaining visible pixel letter blocks into the surrounding darkness. The near-black background barely distinguishes the dark ink from the void. Only a faint dark blue undertone reveals where the characters are. The pixel rendering conveys oppressive suffocating darkness. Horizontal banner format. Characters centered within the image bounds. Color palette: near-black, dark blue, pitch black.
```

### 4-5. 염라대왕
**Seed:** 60045
**용도:** 보스 "염라대왕" 등장 연출

```
The Korean text "염라대왕" and Chinese characters "閻羅大王" written in commanding imperial pixel art text with divine authority. The main Korean text is large and bold; the Chinese characters are smaller beneath. The pixel letter blocks radiate regal power — thick commanding strokes made with absolute confidence. The ink is blood red with gold accents highlighting the edges of the most powerful strokes. Royal gold detailing ornaments the characters. The atmosphere conveys the absolute authority of the judge of the dead. Dark background with blood red and gold glow. Horizontal banner format. All text centered and fully contained. Color palette: blood red, gold, black.
```

### 4-6. 오도전륜왕
**Seed:** 60046
**용도:** 최종 보스 "오도전륜왕" 등장 연출

```
The Korean text "오도전륜왕" written in cosmic overwhelming pixel art text with transcendent power. The pixel letters are impossibly large and powerful — each stroke seems to warp reality around it. The ink shifts through multiple otherworldly colors — cosmic purple, divine gold, ethereal white — all within the same characters. Reality-warping distortion bends the space around each stroke. Cosmic energy and circular dharma wheel motifs orbit the characters. The atmosphere is beyond mortal comprehension — not merely powerful but transcendent. Dark background with otherworldly multicolor glow. Horizontal banner format. Characters centered and fully contained. Color palette: cosmic purple, gold, white light, deep black.
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
The Korean text "고!" written as a single explosive bold brush stroke impact badge. One powerful character with maximum energy — the brush hit the paper hard and fast. Bright cyan energy bursts outward from the character like a shockwave. Dynamic speed lines radiate outward from the text. The brush stroke is thick, bold, and charged with forward momentum. Dark background with bright cyan energy glow. Square badge format. The character is centered with comfortable margins — fully contained within the image. Color palette: bright cyan, white flash, dark navy.
```

### 5-2. 스톱! (STOP!)
**Seed:** 60052
**용도:** "스톱" 선택 시 화면 팝업

```
The Korean text "스톱!" written as a heavy final brush stroke impact badge that slams down with decisive weight. The brush stroke is thick and absolute — it hit the paper with maximum force and stopped dead. Crimson red energy and impact crack lines radiate from where the stroke landed. The feeling is of absolute finality — no going back. Dark background with crimson red glow. Square badge format. Text centered and fully contained. Color palette: crimson red, dark red, white impact flash.
```

### 5-3. 격파! (DEFEATED!)
**Seed:** 60053
**용도:** 보스 격파 시 화면 팝업

```
The Korean text "격파!" written in shattering explosive pixel art text with destructive triumphant force. The pixel letters are breaking apart — fragments of ink fly outward from the characters like an explosion. A golden burst of victory energy radiates from the center. Cracks and fragments radiate outward in all directions. The atmosphere is triumphant and victorious. Dark background with golden explosion glow. Square badge format. The main characters are centered — fragments spread but the core composition stays within bounds. Color palette: gold, bright yellow, dark background.
```

### 5-4. 매칭! (MATCH!)
**Seed:** 60054
**용도:** 카드 매칭 성공 시 피드백

```
The Korean text "매칭!" written in swift connecting pixel art text with linking energy. Two brush elements visually merge together at the center of the text, suggesting connection and combination. A green success glow surrounds the point where the elements connect. The pixel rendering is swift and dynamic — quick confident strokes that found each other. Dark background with green success glow. Square badge format. Text centered and fully contained. Color palette: green, bright green, white, dark background.
```

### 5-5. 쓸! (SWEEP!)
**Seed:** 60055
**용도:** 바닥패 쓸 시 피드백

```
The Korean text "쓸!" written as a sweeping horizontal brush stroke with gathering motion. One powerful wide horizontal sweep — the brush moved fast across the paper in a collecting motion, gathering everything in one stroke. A golden sweep glow trails behind the stroke's motion. Horizontal sweeping motion lines emphasize the direction of movement. Dark background with golden sweep glow. Square badge format. Text centered and fully contained. Color palette: gold, warm amber, dark navy.
```

### 5-6. 관문 돌파! (GATE CLEAR!)
**Seed:** 60056
**용도:** 관문(스테이지) 클리어 시 팝업

```
The Korean text "관문 돌파!" written in breakthrough ascending pixel art text with rising energy. The pixel letter blocks angle upward dramatically — piercing through an invisible barrier above. Bright white-gold light streams upward from the characters. The feeling is of triumphant ascension — breaking through and rising. Dark background with bright white-gold upward light. Square badge format. Text centered and fully contained. Color palette: white, gold, bright light, dark navy.
```

### 5-7. 게임 오버 (GAME OVER)
**Seed:** 60057
**용도:** 사망 시 화면 표시

```
The Korean text "게임 오버" written in somber fading pixel art text with dissolving strokes. The pixel letters are crumbling and disintegrating — the ink is falling apart into particles that drift downward. A faint red glow fades behind the dissolving text. Everything is fading to darkness — the calligraphy itself is dying. The atmosphere is mournful and final. Dark background with fading gray tones. Square badge format. Text centered — the dissolution stays within image bounds. Color palette: fading gray, dark red, near-black.
```

### 5-8. 윤회 (REINCARNATION)
**Seed:** 60058
**용도:** 윤회(새 사이클) 시작 표시

```
The Korean text "윤회" written in mystical circular flowing pixel art text that forms a spiral cycle. The pixel letter blocks flow in a circular pattern — the end of the last stroke connects back to the beginning of the first, creating an ouroboros-like loop. Ethereal blue-white glow emanates from the circular composition. Cyclical spiraling energy orbits around the text. The feeling is of eternal renewal — death leading to rebirth leading to death. Dark background with ethereal blue-white glow. Square badge format. The circular composition is centered and fully contained. Color palette: ethereal blue, white spirit-glow, dark navy.
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
A single large Chinese character "光" (meaning light) written in bold pixel art text, centered on a golden yellow background. The character is written in thick confident black pixel color — one powerful brush stroke per element, filling most of the square frame. The golden background glows with subtle radiance. The pixel rendering shows clear pressure variation and natural ink texture. Square 1:1 format. The character is fully contained with comfortable margins on all sides. Color palette: gold background, black pixel color, white highlight accents.
```

### 6-2. 紅 (홍) 뱃지
**Seed:** 60062
**용도:** 홍단 카드 분류 아이콘

```
A single large Chinese character "紅" (meaning red) written in bold pixel art text, centered on a deep crimson red background. The character is written in thick confident black pixel color with powerful pixel letter blocks. The crimson background is deep and rich like blood. The pixel rendering shows natural variation and pixel texture. Square 1:1 format. Character fully contained with margins. Color palette: crimson red background, black pixel color, dark red shadows.
```

### 6-3. 靑 (청) 뱃지
**Seed:** 60063
**용도:** 청단 카드 분류 아이콘

```
A single large Chinese character "靑" (meaning blue/green) written in bold pixel art text, centered on a deep royal blue background. The character is written in thick confident white pixel color — standing out brightly against the blue. The royal blue background is deep and rich. Square 1:1 format. Character fully contained with margins. Color palette: royal blue background, white pixel color, navy shadows.
```

### 6-4. 草 (초) 뱃지
**Seed:** 60064
**용도:** 초단 카드 분류 아이콘

```
A single large Chinese character "草" (meaning grass) written in bold pixel art text, centered on a deep forest green background. The character is written in thick confident black pixel color. The forest green background is deep and natural. Square 1:1 format. Character fully contained with margins. Color palette: forest green background, black pixel color, dark green shadows.
```

### 6-5. 피 뱃지
**Seed:** 60065
**용도:** 피/쌍피 카드 분류 아이콘

```
A single large Korean character "피" (meaning junk card) written in bold pixel art text, centered on a warm amber-orange background. The character is written in thick confident black pixel color. The amber-orange background has a warm fiery glow. Square 1:1 format. Character fully contained with margins. Color palette: amber orange background, black pixel color, dark red accents.
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
The Korean characters "홍단" written vertically in bold black pixel art text on a bright vivid red ribbon background. The text is written top-to-bottom in traditional vertical Korean writing direction. The red ribbon fills the entire tall narrow image. The pixel letters are thick and confident with blocky pixel edges — written with a traditional horsehair brush. The calligraphy has visible pressure variation and slight ink bleed into the ribbon surface. Tall narrow vertical format. Characters centered on the red ribbon with margins at top and bottom — nothing extends beyond the edges.
```

### 7-2. 청단 띠 텍스트
**Seed:** 60072

```
The Korean characters "청단" written vertically in bold white pixel art text on a bright vivid blue ribbon background. The text is written top-to-bottom in traditional vertical direction. The blue ribbon fills the entire tall narrow image. The pixel letters are thick and confident with blocky pixel edges. White ink stands out brightly against the blue ribbon. Tall narrow vertical format. Characters centered with margins — fully contained.
```

### 7-3. 초단 띠 텍스트
**Seed:** 60073

```
The Korean characters "초단" written vertically in bold black pixel art text on a red ribbon with grass-green tint. The text is written top-to-bottom. The ribbon fills the entire tall narrow image. The pixel letters are thick with blocky pixel edges. Tall narrow vertical format. Characters centered with margins — fully contained.
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

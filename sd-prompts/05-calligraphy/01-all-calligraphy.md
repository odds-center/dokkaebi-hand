# 서예/캘리그래피 이미지 프롬프트 — 게임 내 장식 텍스트

Flux-dev로 **붓글씨 캘리그래피 스타일의 텍스트 이미지**를 생성한다.
딱딱한 폰트 렌더링 대신 **먹물 붓으로 힘차게 쓴 서예** 느낌을 만들어
저승 세계관 분위기를 극대화한다.

> **Flux-dev 장점:** SD 1.5보다 텍스트 생성 능력이 뛰어남.
> 한자/한글을 프롬프트에 직접 지정하면 어느 정도 정확하게 생성 가능.
> 그래도 100% 정확하지 않으므로 후처리에서 보정하거나 서예 폰트로 교체.

---

## 생성 환경 (캘리그래피 전용)

```yaml
Model: Flux-dev (ComfyUI)
Resolution: 용도별 상이 (아래 참조)
Steps: 25~30
Guidance: 3.5~4.0
Sampler: euler
Scheduler: normal
Batch: 4~8장 뽑아서 최선 선택
```

### Flux-dev 프롬프트 규칙
- 네거티브 프롬프트 없음
- 가중치 문법 미사용 — 자연어로 강조
- LoRA는 ComfyUI 노드에서 별도 연결
- **한자/한글을 프롬프트에 직접 포함** — Flux-dev가 렌더링 시도

### 캘리그래피 스타일 핵심 원칙
1. **먹물 붓글씨:** 딱딱한 인쇄체가 아닌, 붓으로 직접 쓴 듯한 유기적 획.
2. **붓 압력 변화:** 시작은 가볍고 중간에 힘을 주고 끝에서 날카롭게 빠지는 전통 필법.
3. **먹물 번짐:** 한지에 먹물이 살짝 번진 듯한 가장자리 — 날카롭지 않고 유기적.
4. **비백(飛白):** 붓이 빠르게 지나가며 생기는 마른 붓 자국 — 획 안에 흰 줄 드러남.
5. **먹물 튀김:** 글씨 주변에 작은 먹물 방울이 튄 자국.
6. **이미지 넘침 방지:** 모든 글씨와 장식 요소가 이미지 경계 안에 완전히 들어와야 함. 잘리거나 프레임 밖으로 넘치지 않도록 사방에 충분한 여백 확보.

## 공통 프롬프트 프리픽스

> 모든 캘리그래피 프롬프트 **앞에** 이 문장을 붙인다.

```
East Asian brush calligraphy artwork. Traditional Korean and Chinese ink brush calligraphy written with a large horsehair brush on aged hanji paper. Bold confident brush strokes with visible pressure variation — thick where the brush pressed hard, thin where it lifted. Sumi-e ink with natural bleed edges where wet ink spread into the paper fibers. Occasional dry brush marks (비백/飛白) showing white streaks within the strokes. Small ink splatter droplets around the main strokes. The calligraphy is fully contained within the image with comfortable margins on all sides — nothing is cropped or extends beyond the edges.
```

## 후처리 (공통)

```
1. 4~8장 중 가장 분위기 좋은 1장 선택
2. 글자 정확도 확인:
   - Flux-dev가 정확하게 쓴 경우 → 그대로 사용
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
Filter Mode: Bilinear
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
The Korean title "도깨비의 패" written in dramatic golden ink brush calligraphy on a very dark navy background. The characters are written with a large brush in sweeping powerful strokes — each stroke shows clear pressure variation from thick to thin. The ink color is rich gold with subtle warm orange undertones, as if written with molten gold ink. Dramatic ink splatter and drips surround the main text, adding energy and chaos. Ghostly wisps of faint smoke curl around the edges of the characters. A small red seal stamp impression sits in one corner as a traditional artist's mark. The brush work is ornate and grand — bold thick strokes with thin elegant tails that trail off into wisps. Wide horizontal banner composition. The calligraphy sits centered with generous margins — nothing touches or extends beyond any edge of the image. The overall atmosphere is supernatural and eerie yet beautiful.
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
The Chinese characters "業火" written in fierce burning brush calligraphy on a dark background. The brush strokes appear to be made of fire — the ink is glowing orange-red like molten lava, with the edges of each stroke flickering as if ablaze. Sparks and floating embers drift away from the character strokes. The brush work is aggressive and wild — fast powerful strokes with charred black edges where the fire burned hottest. A smoky heat haze distortion surrounds the text. Wide horizontal banner format. The characters are centered with comfortable margins — fully contained within the image. Color palette: deep red, flame orange, charcoal black.
```

### 2-2. 빙결(氷結) — 빙결 서예
**Seed:** 60012
**용도:** 축복 "빙결" 이름 뱃지

```
The Chinese characters "氷結" written in frozen crystalline brush calligraphy on a dark background. The brush strokes appear to be made of ice — pale blue with crystalline frost forming along every edge. The ink looks as if it froze the moment it touched the paper, with tiny ice crystal formations growing outward from the stroke edges. Cold mist and a few snowflakes drift in the air around the characters. Small icicle formations drip downward from the lowest strokes. The brush work is precise and sharp — the cold made every stroke brittle and angular. Wide horizontal banner format. Characters centered with generous margins. Color palette: ice blue, pale white, dark navy background.
```

### 2-3. 공허(空虛) — 공허 서예
**Seed:** 60013
**용도:** 축복 "공허" 이름 뱃지

```
The Chinese characters "空虛" written in dissolving dark brush calligraphy on a pitch black background. The brush strokes appear to be consumed by void — parts of each character are fading away into nothingness, with fragments of ink floating and disintegrating into dark particles. A faint deep purple glow outlines the remaining visible portions. The brush work shows strokes that were once bold but are now being erased by darkness itself. The surrounding space feels like a cosmic void — an absence of everything. Wide horizontal banner format. Characters centered with margins — parts dissolve but the composition stays within bounds. Color palette: deep purple, pitch black, faint violet.
```

### 2-4. 혼돈(混沌) — 혼돈 서예
**Seed:** 60014
**용도:** 축복 "혼돈" 이름 뱃지

```
The Chinese characters "混沌" written in chaotic swirling brush calligraphy on a dark background. The brush strokes are warped and distorted — bending in unnatural directions as if reality itself is unstable. Multiple clashing colors appear within the same strokes — crimson bleeds into toxic green which shifts to purple. Chaotic energy spirals and vortex patterns swirl around the characters. The ink appears to glitch with prismatic color splits and fragmentation. The brush work is wild and unpredictable — no two strokes follow the same rules. Wide horizontal banner format. Characters centered within the image bounds despite the chaos. Color palette: crimson, toxic green, purple, all clashing on dark.
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
The Korean text "오광" written in bold golden brush calligraphy with radiant light. The brush strokes are thick and confident, made with rich gold ink that glows brilliantly. Golden light rays burst outward from behind the characters. Five small light accent points are scattered around the text like stars. The brush work conveys divine heavenly illumination — powerful strokes that radiate sacred energy. Dark background with the gold calligraphy as the brilliant focal point. Horizontal banner format. Characters centered and fully contained within the image. Color palette: brilliant gold, white light, dark navy background.
```

### 3-2. 사광 (四光)
**Seed:** 60022
**용도:** 족보 "사광" 달성 표시

```
The Korean text "사광" written in silver-gold brush calligraphy with bright moonlight glow. The strokes are bold and graceful in mixed silver and pale gold ink. Four subtle light points are arranged around the text. The atmosphere is celestial — bright but slightly more subdued than 오광. Ink brush style with silver-gold coloring on a dark background. Horizontal banner format. Characters centered and fully contained. Color palette: silver, pale gold, dark navy.
```

### 3-3. 삼광 (三光)
**Seed:** 60023
**용도:** 족보 "삼광" 달성 표시

```
The Korean text "삼광" written in warm amber brush calligraphy with a soft golden glow. The brush strokes are bold and warm, made with amber-gold ink. Three gentle light accents surround the text. The atmosphere is warmly illuminated — gentle and inviting. Ink brush style with amber-gold tones on a dark background. Horizontal banner format. Characters centered and fully contained. Color palette: amber, warm gold, dark background.
```

### 3-4. 홍단 (紅丹)
**Seed:** 60024
**용도:** 족보 "홍단" 달성 표시

```
The Korean text "홍단" written in deep crimson red brush calligraphy. The brush strokes are bold and flowing, made with rich blood-red ink on a dark background. A red ribbon accent element flows elegantly around the text. The ink is deep crimson with darker shadows in the thickest parts of each stroke. The brush work is elegant and traditional. Horizontal banner format. Characters centered and fully contained. Color palette: crimson red, dark red, black.
```

### 3-5. 청단 (靑丹)
**Seed:** 60025
**용도:** 족보 "청단" 달성 표시

```
The Korean text "청단" written in deep royal blue brush calligraphy. The brush strokes are bold and refined, made with rich blue ink on a dark background. A blue ribbon accent element flows around the text. The color is deep royal blue with cyan highlights catching the light. The brush work is cool and refined. Horizontal banner format. Characters centered and fully contained. Color palette: royal blue, cyan accents, dark navy.
```

### 3-6. 초단 (草丹)
**Seed:** 60026
**용도:** 족보 "초단" 달성 표시

```
The Korean text "초단" written in dark forest green brush calligraphy. The brush strokes are bold and organic, made with deep green ink on a dark background. Subtle grass and vine accents grow along the edges of the strokes as natural decoration. The color is deep forest green with brighter green highlights. The brush work has an organic natural quality. Horizontal banner format. Characters centered and fully contained. Color palette: forest green, bright green accents, dark background.
```

### 3-7. 고도리
**Seed:** 60027
**용도:** 족보 "고도리" 달성 표시

```
The Korean text "고도리" written in warm brown brush calligraphy with bird silhouette accents. The brush strokes are elegant and flowing, made with warm brown-orange ink on a dark background. Tiny bird silhouette shapes are scattered decoratively around the text — small flying birds in ink. The atmosphere is warm and autumnal. Naturalistic ink painting brush style. Horizontal banner format. Characters centered and fully contained. Color palette: warm brown, orange, dark background.
```

### 3-8. 총통
**Seed:** 60028
**용도:** 족보 "총통" 달성 표시

```
The Korean text "총통" written in explosive bold brush calligraphy with impact energy. The brush strokes are extremely thick and aggressive, made with black ink with bright yellow flash accents. Shockwave-like radial lines burst outward from the center of the text. The brush work conveys powerful commanding force — each stroke slams onto the paper with maximum impact. Dark background with bright yellow flash energy. Horizontal banner format. Characters centered and fully contained. Color palette: bright yellow, white flash, dark navy.
```

### 3-9. 사계 (四季)
**Seed:** 60029
**용도:** 족보 "사계" 달성 표시 (저승 족보)

```
The Korean text "사계" written in flowing brush calligraphy with four-season color transitions within the strokes. The brush work flows from left to right, with the ink color transitioning smoothly: pink cherry blossom tones at the start, transitioning through green summer, then orange autumn, ending in white winter. Seasonal elements are subtly woven into the brush texture — a petal here, a snowflake there. Dark background behind the colorful calligraphy. Horizontal banner format. Characters centered and fully contained. Color palette: pink, green, orange, white — all transitioning on dark.
```

### 3-10. 도깨비불
**Seed:** 60030
**용도:** 족보 "도깨비불" 달성 표시 (저승 족보)

```
The Korean text "도깨비불" written in ghostly blue-green brush calligraphy with supernatural fire. The brush strokes are made with spectral blue-green ink that glows with an eerie inner light. Will-o-wisp flames dance and flicker around the characters — small floating supernatural fires in pale blue-green. The atmosphere is ghostly and otherworldly. The ink seems to glow from within, as if the calligraphy itself is a ghost flame. Dark background with spectral green glow. Horizontal banner format. Characters centered and fully contained. Color palette: spectral green, ghostly blue, dark navy.
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
The Korean text "먹보 도깨비" written in thick greedy brush calligraphy with dripping ink. The brush strokes are bloated and heavy — overloaded with too much ink, dripping and splattering as if the brush itself is gluttonous. The ink is dark black with reddish-orange undertones glowing from within. Ink drips and splatters suggest excess and gluttony. The brush work is menacing and ominous with a dark fantasy atmosphere. Dark background with reddish-orange glow behind the text. Horizontal banner format. Characters centered and fully contained with no overflow. Color palette: reddish orange, blood red, black.
```

### 4-2. 여우 도깨비
**Seed:** 60042
**용도:** 보스 "여우 도깨비" 등장 연출

```
The Korean text "여우 도깨비" written in elegant sinuous brush calligraphy with seductive curves. The brush strokes are thin, graceful, and dangerously beautiful — each stroke curves like a fox's tail. The ink is dark with purple fox-fire glow along the edges. Wisps of purple energy curl around the characters like smoke. The brush work is beautiful but unsettling — elegant danger. Dark background with purple glow. Horizontal banner format. Characters centered and fully contained. Color palette: purple, lavender, dark navy.
```

### 4-3. 불꽃 도깨비
**Seed:** 60043
**용도:** 보스 "불꽃 도깨비" 등장 연출

```
The Korean text "불꽃 도깨비" written in burning aggressive brush calligraphy made of fire and rage. The strokes appear to be literally on fire — trailing sparks and embers fly from each character. The ink is orange-red flame with charred cracked black edges. Scorching heat distortion warps the air around the text. The brush work is violent and aggressive — each stroke attacks the paper. Dark background with intense flame glow. Horizontal banner format. Characters centered and fully contained. Color palette: flame orange, bright orange, charcoal black.
```

### 4-4. 그림자 도깨비
**Seed:** 60044
**용도:** 보스 "그림자 도깨비" 등장 연출

```
The Korean text "그림자 도깨비" written in fading shadow brush calligraphy that partially dissolves into darkness. The strokes appear and disappear — parts of each character are invisible, consumed by shadow. Shadowy tendrils extend from the remaining visible brush strokes into the surrounding darkness. The near-black background barely distinguishes the dark ink from the void. Only a faint dark blue undertone reveals where the characters are. The brush work conveys oppressive suffocating darkness. Horizontal banner format. Characters centered within the image bounds. Color palette: near-black, dark blue, pitch black.
```

### 4-5. 염라대왕
**Seed:** 60045
**용도:** 보스 "염라대왕" 등장 연출

```
The Korean text "염라대왕" and Chinese characters "閻羅大王" written in commanding imperial brush calligraphy with divine authority. The main Korean text is large and bold; the Chinese characters are smaller beneath. The brush strokes radiate regal power — thick commanding strokes made with absolute confidence. The ink is blood red with gold accents highlighting the edges of the most powerful strokes. Royal gold detailing ornaments the characters. The atmosphere conveys the absolute authority of the judge of the dead. Dark background with blood red and gold glow. Horizontal banner format. All text centered and fully contained. Color palette: blood red, gold, black.
```

### 4-6. 오도전륜왕
**Seed:** 60046
**용도:** 최종 보스 "오도전륜왕" 등장 연출

```
The Korean text "오도전륜왕" written in cosmic overwhelming brush calligraphy with transcendent power. The brush strokes are impossibly large and powerful — each stroke seems to warp reality around it. The ink shifts through multiple otherworldly colors — cosmic purple, divine gold, ethereal white — all within the same characters. Reality-warping distortion bends the space around each stroke. Cosmic energy and circular dharma wheel motifs orbit the characters. The atmosphere is beyond mortal comprehension — not merely powerful but transcendent. Dark background with otherworldly multicolor glow. Horizontal banner format. Characters centered and fully contained. Color palette: cosmic purple, gold, white light, deep black.
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
The Korean text "격파!" written in shattering explosive brush calligraphy with destructive triumphant force. The brush strokes are breaking apart — fragments of ink fly outward from the characters like an explosion. A golden burst of victory energy radiates from the center. Cracks and fragments radiate outward in all directions. The atmosphere is triumphant and victorious. Dark background with golden explosion glow. Square badge format. The main characters are centered — fragments spread but the core composition stays within bounds. Color palette: gold, bright yellow, dark background.
```

### 5-4. 매칭! (MATCH!)
**Seed:** 60054
**용도:** 카드 매칭 성공 시 피드백

```
The Korean text "매칭!" written in swift connecting brush calligraphy with linking energy. Two brush elements visually merge together at the center of the text, suggesting connection and combination. A green success glow surrounds the point where the elements connect. The brush work is swift and dynamic — quick confident strokes that found each other. Dark background with green success glow. Square badge format. Text centered and fully contained. Color palette: green, bright green, white, dark background.
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
The Korean text "관문 돌파!" written in breakthrough ascending brush calligraphy with rising energy. The brush strokes angle upward dramatically — piercing through an invisible barrier above. Bright white-gold light streams upward from the characters. The feeling is of triumphant ascension — breaking through and rising. Dark background with bright white-gold upward light. Square badge format. Text centered and fully contained. Color palette: white, gold, bright light, dark navy.
```

### 5-7. 게임 오버 (GAME OVER)
**Seed:** 60057
**용도:** 사망 시 화면 표시

```
The Korean text "게임 오버" written in somber fading brush calligraphy with dissolving strokes. The brush strokes are crumbling and disintegrating — the ink is falling apart into particles that drift downward. A faint red glow fades behind the dissolving text. Everything is fading to darkness — the calligraphy itself is dying. The atmosphere is mournful and final. Dark background with fading gray tones. Square badge format. Text centered — the dissolution stays within image bounds. Color palette: fading gray, dark red, near-black.
```

### 5-8. 윤회 (REINCARNATION)
**Seed:** 60058
**용도:** 윤회(새 사이클) 시작 표시

```
The Korean text "윤회" written in mystical circular flowing brush calligraphy that forms a spiral cycle. The brush strokes flow in a circular pattern — the end of the last stroke connects back to the beginning of the first, creating an ouroboros-like loop. Ethereal blue-white glow emanates from the circular composition. Cyclical spiraling energy orbits around the text. The feeling is of eternal renewal — death leading to rebirth leading to death. Dark background with ethereal blue-white glow. Square badge format. The circular composition is centered and fully contained. Color palette: ethereal blue, white spirit-glow, dark navy.
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
A single large Chinese character "光" (meaning light) written in bold brush calligraphy, centered on a golden yellow background. The character is written in thick confident black ink — one powerful brush stroke per element, filling most of the square frame. The golden background glows with subtle radiance. The brush work shows clear pressure variation and natural ink texture. Square 1:1 format. The character is fully contained with comfortable margins on all sides. Color palette: gold background, black ink, white highlight accents.
```

### 6-2. 紅 (홍) 뱃지
**Seed:** 60062
**용도:** 홍단 카드 분류 아이콘

```
A single large Chinese character "紅" (meaning red) written in bold brush calligraphy, centered on a deep crimson red background. The character is written in thick confident black ink with powerful brush strokes. The crimson background is deep and rich like blood. The brush work shows natural variation and sumi-e texture. Square 1:1 format. Character fully contained with margins. Color palette: crimson red background, black ink, dark red shadows.
```

### 6-3. 靑 (청) 뱃지
**Seed:** 60063
**용도:** 청단 카드 분류 아이콘

```
A single large Chinese character "靑" (meaning blue/green) written in bold brush calligraphy, centered on a deep royal blue background. The character is written in thick confident white ink — standing out brightly against the blue. The royal blue background is deep and rich. Square 1:1 format. Character fully contained with margins. Color palette: royal blue background, white ink, navy shadows.
```

### 6-4. 草 (초) 뱃지
**Seed:** 60064
**용도:** 초단 카드 분류 아이콘

```
A single large Chinese character "草" (meaning grass) written in bold brush calligraphy, centered on a deep forest green background. The character is written in thick confident black ink. The forest green background is deep and natural. Square 1:1 format. Character fully contained with margins. Color palette: forest green background, black ink, dark green shadows.
```

### 6-5. 피 뱃지
**Seed:** 60065
**용도:** 피/쌍피 카드 분류 아이콘

```
A single large Korean character "피" (meaning junk card) written in bold brush calligraphy, centered on a warm amber-orange background. The character is written in thick confident black ink. The amber-orange background has a warm fiery glow. Square 1:1 format. Character fully contained with margins. Color palette: amber orange background, black ink, dark red accents.
```

### 시스템 뱃지 후처리
```
1. 정사각형 비율 확인 (128x128)
2. 배경색 균일하게 보정
3. 글자 확인 — Flux-dev가 정확하게 생성한 경우 그대로 사용
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
The Korean characters "홍단" written vertically in bold black brush calligraphy on a bright vivid red ribbon background. The text is written top-to-bottom in traditional vertical Korean writing direction. The red ribbon fills the entire tall narrow image. The brush strokes are thick and confident with natural ink texture — written with a traditional horsehair brush. The calligraphy has visible pressure variation and slight ink bleed into the ribbon surface. Tall narrow vertical format. Characters centered on the red ribbon with margins at top and bottom — nothing extends beyond the edges.
```

### 7-2. 청단 띠 텍스트
**Seed:** 60072

```
The Korean characters "청단" written vertically in bold white brush calligraphy on a bright vivid blue ribbon background. The text is written top-to-bottom in traditional vertical direction. The blue ribbon fills the entire tall narrow image. The brush strokes are thick and confident with natural ink texture. White ink stands out brightly against the blue ribbon. Tall narrow vertical format. Characters centered with margins — fully contained.
```

### 7-3. 초단 띠 텍스트
**Seed:** 60073

```
The Korean characters "초단" written vertically in bold black brush calligraphy on a red ribbon with grass-green tint. The text is written top-to-bottom. The ribbon fills the entire tall narrow image. The brush strokes are thick with natural ink texture. Tall narrow vertical format. Characters centered with margins — fully contained.
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

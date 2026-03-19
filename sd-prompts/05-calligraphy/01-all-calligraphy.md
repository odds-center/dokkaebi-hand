# 서예/텍스트 이미지 프롬프트 — 게임 내 장식 텍스트

SD로 서예/캘리그래피 텍스트 이미지를 생성한다.
폰트 렌더링 대신 **붓글씨 느낌의 장식 텍스트 이미지**를 사용하여
저승 세계관 분위기를 극대화한다.

> **주의:** SD는 정확한 글자를 쓰지 못한다.
> 생성된 이미지는 **배경/분위기 텍스처**로 쓰고,
> 실제 글자는 포토샵/클립스튜디오에서 서예 폰트로 합성하거나
> ControlNet + 글자 마스크로 유도한다.

---

## SD 설정 (서예 전용)

```yaml
Model: SD 1.5 (LoRA 없음)
Resolution: 용도별 상이 (아래 참조)
Steps: 30~35
CFG Scale: 8
Sampler: DPM++ 2M Karras
Batch: 4~8장 뽑아서 최선 선택
```

## 공통 긍정 프롬프트 (모든 서예 앞에 붙임)

```
(east asian calligraphy artwork:1.4),
(korean brush calligraphy style:1.3),
(ink brush strokes:1.3), (traditional sumi-e:1.1),
bold confident brush work, dramatic ink splatter,
high contrast, (dark background:1.2),
no realistic photo, no 3d render
```

## 공통 부정 프롬프트

```
(blurry:1.3), (3d render:1.4), (realistic photograph:1.4),
(anime style:1.2), (cartoon:1.2),
bright cheerful colors, modern font, digital text, typed text,
person, face, character, full body,
(low quality:1.3), jpeg artifacts, watermark, signature,
frame, thick border, cluttered background
```

## 후처리 (공통)

```
1. 4~8장 중 가장 분위기 좋은 1장 선택
2. 배경 제거 또는 알파 채널 추출 (검은 배경 → 알파)
3. 실제 한글 텍스트를 서예 폰트로 오버레이
   - 추천 폰트: 궁서체, 한겨레결체, 나눔붓글씨
   - 또는 ControlNet Canny + 글자 마스크로 SD 재생성
4. 레벨 보정 (Levels): 배경 완전 투명, 먹물 부분만 선명하게
5. PNG 저장 (알파 포함) → Assets/Art/Calligraphy/
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

---

## 1. 게임 타이틀 — "도깨비의 패"

**Seed:** 60001 | 8장 배치
**크기:** 1024x256
**용도:** 메인 메뉴 타이틀 로고, 로딩 화면

### 설정
게임의 얼굴. 금빛 먹물로 쓴 전통 서예 느낌.
어두운 배경 위에 극적인 붓놀림. 도깨비의 괴기한 분위기와 화투의 화려함을 동시에.

### 긍정 프롬프트
```
(grand title calligraphy banner:1.4),
(golden ink brush strokes:1.4) on (very dark navy background:1.3) (#1A1A2E),
(dramatic sweeping brush work:1.3) with ink splatter and drips,
(gold color:1.3) (#FFD700) with subtle orange glow (#FFA500),
wide horizontal banner composition,
(supernatural eerie atmosphere:1.2),
ghostly wisps of smoke around the text area,
faint red seal stamp accent in corner,
ornate traditional korean calligraphy style,
bold thick strokes with thin elegant tails,
(masterpiece quality:1.2)
```

### 부정 프롬프트
공통 부정 프롬프트 사용

### 후처리
```
1. 배경은 유지 (타이틀이므로 배경 포함)
2. 금색 부분 색감 강화 — Hue/Saturation에서 Gold 강조
3. 실제 "도깨비의 패" 텍스트를 서예 폰트로 합성
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
(fire calligraphy text banner:1.4),
(burning brush strokes:1.3) made of (flames and embers:1.3),
dark background with (orange-red fire glow:1.3) (#FF4500),
sparks and floating embers around text area,
(charred edges:1.2) on brush strokes,
smoky atmosphere, heat haze distortion,
wide horizontal banner format,
color palette: deep red (#C41E3A) orange (#FF4500) black
```

### 2-2. 빙결(氷結) — 빙결 서예
**Seed:** 60012
**용도:** 축복 "빙결" 이름 뱃지

```
(ice calligraphy text banner:1.4),
(frozen crystalline brush strokes:1.3),
dark background with (pale blue ice glow:1.3) (#00D4FF),
(frost crystals:1.2) forming along stroke edges,
cold mist and snowflakes in the air,
icicle formations dripping from brush strokes,
wide horizontal banner format,
color palette: ice blue (#00D4FF) pale white dark navy (#1A1A2E)
```

### 2-3. 공허(空虛) — 공허 서예
**Seed:** 60013
**용도:** 축복 "공허" 이름 뱃지

```
(void calligraphy text banner:1.4),
(dissolving dark brush strokes:1.3) fading into (void darkness:1.3),
pitch black background with (deep purple glow:1.2) (#7C3AED),
strokes appear to be (consumed by darkness:1.2),
fragments of brush strokes floating and disintegrating,
cosmic void energy, absence of light,
wide horizontal banner format,
color palette: deep purple (#7C3AED) pitch black faint violet
```

### 2-4. 혼돈(混沌) — 혼돈 서예
**Seed:** 60014
**용도:** 축복 "혼돈" 이름 뱃지

```
(chaos calligraphy text banner:1.4),
(swirling distorted brush strokes:1.3),
dark background with (multiple clashing colors:1.2),
(warped and twisted:1.2) ink strokes bending unnaturally,
chaotic energy spirals and vortex patterns,
glitch-like color splits, prismatic distortion,
wide horizontal banner format,
color palette: crimson (#C41E3A) toxic green (#39FF14) purple (#A855F7) dark
```

### 축복 공통 부정 프롬프트
공통 부정 프롬프트 사용

### 축복 후처리
```
1. 배경 제거 → 알파 채널로 변환
2. 각 축복 컬러에 맞게 색감 보정
3. 서예 폰트로 실제 한자+한글 텍스트 합성
   - "業火" (큰 글자) + "업화" (작은 글자)
4. 512x128 PNG (알파) → Assets/Art/Calligraphy/blessing_*.png
```

---

## 3. 족보 이름 (주요 10종)

고스톱 족보 완성 시 화면에 표시되는 족보 이름 뱃지.
각 족보 테마에 맞는 색상 악센트를 넣어 시각적 구분.

**크기:** 384x128 (각각)
**기본 스타일:** 먹물 붓글씨 + 테마 컬러 악센트

### 3-1. 오광
**Seed:** 60021
**용도:** 족보 "오광" 달성 표시

```
(calligraphy text banner:1.4),
(bold golden brush strokes:1.3) with (radiant light burst:1.3),
dark background with (brilliant gold rays:1.3) (#FFD700),
(five-pointed light accents:1.1) scattered around,
divine heavenly glow, sacred illumination,
ink brush style with gold color dominating,
horizontal banner format,
color palette: gold (#FFD700) white light dark navy
```

### 3-2. 사광
**Seed:** 60022
**용도:** 족보 "사광" 달성 표시

```
(calligraphy text banner:1.4),
(silver-gold brush strokes:1.3) with (bright moonlight glow:1.2),
dark background with (silvery light:1.2) (#C0C0C0),
four subtle light points arranged around text,
celestial atmosphere, bright but slightly subdued,
ink brush style with silver-gold coloring,
horizontal banner format,
color palette: silver (#C0C0C0) pale gold dark navy
```

### 3-3. 삼광
**Seed:** 60023
**용도:** 족보 "삼광" 달성 표시

```
(calligraphy text banner:1.4),
(warm amber brush strokes:1.3) with (soft golden glow:1.2),
dark background with amber light (#FFBF00),
three light accents around text area,
gentle warm illumination,
ink brush style with amber-gold tones,
horizontal banner format,
color palette: amber (#FFBF00) warm gold dark background
```

### 3-4. 홍단
**Seed:** 60024
**용도:** 족보 "홍단" 달성 표시

```
(calligraphy text banner:1.4),
(crimson red brush strokes:1.3) on dark background,
(red ribbon accent:1.2) flowing around text area,
deep blood red color (#C41E3A) with darker shadows,
elegant flowing composition,
ink brush style with bold red coloring,
horizontal banner format,
color palette: crimson (#C41E3A) dark red (#8B0000) black
```

### 3-5. 청단
**Seed:** 60025
**용도:** 족보 "청단" 달성 표시

```
(calligraphy text banner:1.4),
(deep blue brush strokes:1.3) on dark background,
(blue ribbon accent:1.2) flowing around text area,
deep royal blue (#1E40AF) with cyan highlights,
cool refined composition,
ink brush style with bold blue coloring,
horizontal banner format,
color palette: royal blue (#1E40AF) cyan (#00D4FF) dark navy
```

### 3-6. 초단
**Seed:** 60026
**용도:** 족보 "초단" 달성 표시

```
(calligraphy text banner:1.4),
(dark green brush strokes:1.3) on dark background,
(grass and vine accent:1.2) subtle organic elements,
deep forest green (#166534) with bright green highlights,
natural organic composition,
ink brush style with bold green coloring,
horizontal banner format,
color palette: forest green (#166534) bright green (#22C55E) dark
```

### 3-7. 고도리
**Seed:** 60027
**용도:** 족보 "고도리" 달성 표시

```
(calligraphy text banner:1.4),
(elegant brush strokes:1.3) with (bird silhouette accents:1.2),
dark background with warm orange-brown tones,
tiny bird shapes scattered around text as decoration,
naturalistic ink painting style,
warm autumn color palette,
horizontal banner format,
color palette: warm brown (#8B4513) orange (#FF8C00) dark
```

### 3-8. 총통
**Seed:** 60028
**용도:** 족보 "총통" 달성 표시

```
(calligraphy text banner:1.4),
(explosive bold brush strokes:1.3) with (impact energy burst:1.3),
dark background with (bright yellow flash:1.2) (#FACC15),
shockwave-like radial lines from center,
powerful commanding presence,
thick aggressive ink brush strokes,
horizontal banner format,
color palette: bright yellow (#FACC15) white flash dark navy
```

### 3-9. 사계
**Seed:** 60029
**용도:** 족보 "사계" 달성 표시 (저승 족보)

```
(calligraphy text banner:1.4),
(flowing brush strokes:1.3) with (four-season color gradient:1.3),
dark background,
(color transitions:1.2): pink cherry blossom → green summer → orange autumn → white winter,
seasonal elements subtly woven into brush texture,
elegant flowing composition,
horizontal banner format,
color palette: pink green orange white on dark
```

### 3-10. 도깨비불
**Seed:** 60030
**용도:** 족보 "도깨비불" 달성 표시 (저승 족보)

```
(calligraphy text banner:1.4),
(ghostly blue-green brush strokes:1.3) with (supernatural fire:1.3),
dark background with (eerie will-o-wisp flames:1.3),
(spectral blue-green fire:1.2) (#00FF88) dancing around text,
ghostly supernatural atmosphere,
ethereal floating flames and wisps,
horizontal banner format,
color palette: spectral green (#00FF88) ghostly blue dark navy
```

### 족보 공통 부정 프롬프트
공통 부정 프롬프트 사용

### 족보 후처리
```
1. 배경 제거 → 알파 채널
2. 각 족보 테마 컬러에 맞게 색감 보정
3. 서예 폰트로 족보 이름 한글 합성
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
(menacing calligraphy text banner:1.4),
(thick greedy brush strokes:1.3) with (dripping ink:1.2),
dark background with (reddish-orange glow:1.2) (#FF6B35),
ink drips and splatters suggesting gluttony,
heavy bloated brush work with excess ink,
ominous dark fantasy atmosphere,
horizontal banner format,
color palette: reddish orange (#FF6B35) blood red (#C41E3A) black
```

### 4-2. 여우 도깨비
**Seed:** 60042
**용도:** 보스 "여우 도깨비" 등장 연출

```
(menacing calligraphy text banner:1.4),
(elegant sinuous brush strokes:1.3) with (seductive curves:1.2),
dark background with (purple fox-fire glow:1.2) (#A855F7),
thin graceful yet dangerous brush work,
wisps of purple energy curling around text,
beautiful but unsettling atmosphere,
horizontal banner format,
color palette: purple (#A855F7) lavender (#E879F9) dark navy
```

### 4-3. 불꽃 도깨비
**Seed:** 60043
**용도:** 보스 "불꽃 도깨비" 등장 연출

```
(menacing calligraphy text banner:1.4),
(burning aggressive brush strokes:1.3) made of (fire and rage:1.3),
dark background with (intense flame glow:1.3) (#FF4500),
strokes appear to be on fire with trailing sparks,
scorching heat distortion, charred cracked edges,
wrathful destructive atmosphere,
horizontal banner format,
color palette: flame orange (#FF4500) bright orange (#FFA500) charcoal black
```

### 4-4. 그림자 도깨비
**Seed:** 60044
**용도:** 보스 "그림자 도깨비" 등장 연출

```
(menacing calligraphy text banner:1.4),
(fading shadow brush strokes:1.3) partially (dissolving into darkness:1.3),
near-black background with faint (dark blue undertone:1.1),
strokes appear and disappear, partially invisible,
shadowy tendrils extending from brush work,
oppressive suffocating darkness,
horizontal banner format,
color palette: near-black (#0A0A0A) dark blue (#1E3A5F) pitch black
```

### 4-5. 염라대왕
**Seed:** 60045
**용도:** 보스 "염라대왕" 등장 연출

```
(menacing calligraphy text banner:1.4),
(commanding imperial brush strokes:1.4) with (divine authority:1.3),
dark background with (blood red and gold:1.3),
(royal gold accents:1.2) (#FFD700) on crimson (#C41E3A),
regal power radiating from brush work,
judge of the dead atmosphere, absolute authority,
horizontal banner format,
color palette: blood red (#C41E3A) gold (#FFD700) black
```

### 4-6. 오도전륜왕
**Seed:** 60046
**용도:** 최종 보스 "오도전륜왕" 등장 연출

```
(menacing calligraphy text banner:1.4),
(cosmic overwhelming brush strokes:1.4) with (transcendent power:1.3),
dark background with (otherworldly multicolor glow:1.3),
(reality-warping distortion:1.2) around brush strokes,
cosmic energy and dharma wheel motifs,
beyond mortal comprehension atmosphere,
horizontal banner format,
color palette: cosmic purple (#7C3AED) gold (#FFD700) white light deep black
```

### 보스 공통 부정 프롬프트
공통 부정 프롬프트 사용

### 보스 후처리
```
1. 배경은 반투명으로 유지 (등장 연출에 배경 포함)
2. 보스 테마 컬러 강화
3. 서예 폰트로 보스 이름 합성
4. 등장 연출용이므로 약간 과장된 효과 OK
5. 512x128 PNG → Assets/Art/Calligraphy/boss_*.png
```

---

## 5. UI 텍스트 뱃지 (8종)

게임 플레이 중 화면에 팝업되는 액션 텍스트.
임팩트 있는 굵은 붓글씨로 순간적인 피드백 전달.

**크기:** 256x128 (각각)
**기본 스타일:** 굵고 강렬한 임팩트 서예, 다이나믹

### 5-1. GO!
**Seed:** 60051
**용도:** "고" 선택 시 화면 팝업

```
(impact calligraphy text badge:1.4),
(explosive bold brush stroke:1.4) with (forward momentum:1.3),
dark background with (bright cyan energy burst:1.3) (#00D4FF),
dynamic speed lines radiating outward,
powerful forward-charging energy,
single bold stroke composition,
square badge format,
color palette: bright cyan (#00D4FF) white flash dark navy
```

### 5-2. STOP!
**Seed:** 60052
**용도:** "스톱" 선택 시 화면 팝업

```
(impact calligraphy text badge:1.4),
(heavy final brush stroke:1.4) slamming down with (decisive weight:1.3),
dark background with (crimson red glow:1.3) (#C41E3A),
impact crack lines from where the stroke lands,
absolute finality, no going back,
single powerful downward stroke composition,
square badge format,
color palette: crimson (#C41E3A) dark red white impact flash
```

### 5-3. 격파!
**Seed:** 60053
**용도:** 보스 격파 시 화면 팝업

```
(impact calligraphy text badge:1.4),
(shattering explosive brush strokes:1.4) with (destructive force:1.3),
dark background with (golden explosion:1.3) (#FFD700),
cracks and fragments flying outward,
triumphant victorious energy burst,
shattered pieces radiating from center,
square badge format,
color palette: gold (#FFD700) bright yellow (#FACC15) dark
```

### 5-4. 매칭!
**Seed:** 60054
**용도:** 카드 매칭 성공 시 피드백

```
(impact calligraphy text badge:1.4),
(swift connecting brush strokes:1.3) with (linking energy:1.2),
dark background with (green success glow:1.2) (#22C55E),
two brush elements merging together,
satisfying connection feedback,
dynamic linking composition,
square badge format,
color palette: green (#22C55E) bright green white dark
```

### 5-5. 쓸!
**Seed:** 60055
**용도:** 바닥패 쓸 시 피드백

```
(impact calligraphy text badge:1.4),
(sweeping horizontal brush stroke:1.4) with (collecting motion:1.3),
dark background with (golden sweep glow:1.2) (#FFD700),
horizontal sweeping motion lines,
gathering everything in one powerful stroke,
wide horizontal sweep composition,
square badge format,
color palette: gold (#FFD700) warm amber dark navy
```

### 5-6. 관문 돌파!
**Seed:** 60056
**용도:** 관문(스테이지) 클리어 시 팝업

```
(impact calligraphy text badge:1.4),
(breakthrough ascending brush strokes:1.4) with (rising energy:1.3),
dark background with (bright white-gold light:1.3),
upward piercing motion, breaking through barriers,
triumphant ascending energy,
vertical breakthrough composition,
square badge format,
color palette: white gold (#FFD700) bright light dark navy
```

### 5-7. 게임 오버
**Seed:** 60057
**용도:** 사망 시 화면 표시

```
(somber calligraphy text badge:1.4),
(fading dissolving brush strokes:1.3) with (death and loss:1.2),
dark background with (faint red fading glow:1.1),
brush strokes crumbling and disintegrating,
mournful final moment, everything fading to darkness,
dissolving downward composition,
square badge format,
color palette: fading gray dark red (#8B0000) near-black
```

### 5-8. 윤회
**Seed:** 60058
**용도:** 윤회(새 사이클) 시작 표시

```
(mystical calligraphy text badge:1.4),
(circular flowing brush strokes:1.4) forming (spiral cycle:1.3),
dark background with (ethereal blue-white glow:1.3),
(ouroboros-like circular composition:1.2),
eternal cycle of rebirth and renewal,
cyclical spiraling energy,
square badge format,
color palette: ethereal blue (#60A5FA) white spirit-glow dark navy
```

### UI 텍스트 공통 부정 프롬프트
공통 부정 프롬프트 사용

### UI 텍스트 후처리
```
1. 배경 완전 제거 → 투명 알파
2. 텍스트 효과만 남기고 서예 폰트로 글자 합성
3. 팝업 애니메이션용이므로 여백 충분히 확보
4. 256x128 PNG (알파) → Assets/Art/Calligraphy/ui_*.png
```

---

## 6. 시스템 아이콘/뱃지 (5종)

단일 한자 뱃지. 카드 분류 아이콘이나 UI 표시에 사용.
정사각형 포맷, 굵은 단일 글자, 배경색으로 타입 구분.

**크기:** 128x128 (각각, 정사각형)
**기본 스타일:** 단일 글자 붓글씨, 굵은 획, 타입별 배경색

### 6-1. 광(光) 뱃지
**Seed:** 60061
**용도:** 광 카드 분류 아이콘

```
(single character calligraphy badge:1.4),
(one bold brush stroke character:1.4) centered on (golden yellow background:1.3),
(radiant golden:1.3) (#FFD700) background with subtle glow,
single large black ink character filling the frame,
powerful centered composition,
thick confident brush stroke,
square badge format 1:1 ratio,
color palette: gold (#FFD700) black ink white highlight
```

### 6-2. 홍(紅) 뱃지
**Seed:** 60062
**용도:** 홍단 카드 분류 아이콘

```
(single character calligraphy badge:1.4),
(one bold brush stroke character:1.4) centered on (deep crimson background:1.3),
(blood red:1.3) (#C41E3A) background with subtle dark gradient,
single large black ink character filling the frame,
powerful centered composition,
thick confident brush stroke,
square badge format 1:1 ratio,
color palette: crimson (#C41E3A) black ink dark red
```

### 6-3. 청(靑) 뱃지
**Seed:** 60063
**용도:** 청단 카드 분류 아이콘

```
(single character calligraphy badge:1.4),
(one bold brush stroke character:1.4) centered on (deep blue background:1.3),
(royal blue:1.3) (#1E40AF) background with subtle dark gradient,
single large white ink character filling the frame,
powerful centered composition,
thick confident brush stroke,
square badge format 1:1 ratio,
color palette: royal blue (#1E40AF) white ink navy
```

### 6-4. 초(草) 뱃지
**Seed:** 60064
**용도:** 초단 카드 분류 아이콘

```
(single character calligraphy badge:1.4),
(one bold brush stroke character:1.4) centered on (deep green background:1.3),
(forest green:1.3) (#166534) background with subtle dark gradient,
single large black ink character filling the frame,
powerful centered composition,
thick confident brush stroke,
square badge format 1:1 ratio,
color palette: forest green (#166534) black ink dark green
```

### 6-5. 열(熱) 뱃지
**Seed:** 60065
**용도:** 열(피/쌍피) 카드 분류 아이콘

```
(single character calligraphy badge:1.4),
(one bold brush stroke character:1.4) centered on (fiery orange background:1.3),
(flame orange:1.3) (#FF4500) background with subtle heat glow,
single large black ink character filling the frame,
powerful centered composition,
thick confident brush stroke,
square badge format 1:1 ratio,
color palette: flame orange (#FF4500) black ink dark red
```

### 시스템 뱃지 공통 부정 프롬프트
공통 부정 프롬프트 + `multiple characters, two or more letters, complex scene`

### 시스템 뱃지 후처리
```
1. 정사각형 비율 확인 (128x128)
2. 배경색 균일하게 보정
3. 서예 폰트로 실제 한자 1글자 합성 (또는 SD 결과 직접 사용)
4. 128x128 PNG → Assets/Art/Calligraphy/badge_*.png
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
| **합계** | **34** | — | — | — |

# 통화, 영구 강화, 보스 파츠 아이콘

> **아이작 스타일** — 1:1 정사각, 투명 배경, 오브젝트만. 심플한 도트 실루엣.

## 공통 네거티브 프롬프트 (모든 섹션에 적용)

```
score_4, score_3, score_2, score_1, blurry, photo, realistic, 3d render, smooth shading, anti-aliasing, gradient, soft edges, watercolor, text, watermark, signature
```

---

## 1. 통화 아이콘 (2종)

**크기:** 128x128 (픽셀 그리드 32x32 기준, 4x 생성 → 다운스케일 96x96)

### 공통 프롬프트 프리픽스

```
score_9, score_8_up, score_7_up, pixel art, game assets, chibi, simple green background, single item icon, one simple recognizable object centered, flat colors, thick black outlines, no ground, no shadow, no pedestal, square composition, only the item, nothing else
```

### icon_yeop — 엽전 (런 내 화폐)
**Seed:** 75001
```
three traditional Korean brass coins, stacked slightly offset, round golden-brown coins, square holes in center, simple coin stack
```

### icon_soul — 넋 (영구 강화 화폐)
**Seed:** 75002
```
small floating pale blue-white spirit orb, tiny wisp trails, translucent glowing blue-cyan sphere, simple soul fragment
```

---

## 2. 영구 강화 노드 아이콘 (19종)

> 영구 강화 트리 노드 아이콘. 3경로: 패의 길(빨강), 부적의 길(파랑), 생존의 길(초록).
> 경로 색상은 게임 UI 테두리에서 처리. 아이콘 자체는 오브젝트만.

**크기:** 128x128 (픽셀 그리드 32x32 기준, 4x 생성 → 다운스케일 96x96)

### 공통 프롬프트 프리픽스

```
score_9, score_8_up, score_7_up, pixel art, game assets, chibi, simple green background, single item icon, one simple recognizable object centered, flat colors, thick black outlines, no ground, no shadow, no pedestal, square composition, only the item, nothing else
```

### 패의 길 (Card Path) — 6종

**Seed:** 75011~75016

#### upgrade_base_chips — 기본 칩 증가
```
three stacked red poker chips, small white plus symbol above, simple chip stack
```

#### upgrade_base_mult — 기본 배수 증가
```
bold red multiplication symbol, small radiating lines around it, simple math symbol
```

#### upgrade_start_hand — 시작 손패 증가
```
fan of three small card shapes spreading outward, plus symbol, simple card fan
```

#### upgrade_deck_compress — 덱 압축
```
deck of cards squeezed by two inward-pointing arrows from both sides, simple compressed deck
```

#### upgrade_yokbo_bonus — 족보 보너스
```
small scroll with golden star on it, simple scroll with star
```

#### upgrade_sweep_bonus — 쓸 보너스
```
horizontal brush stroke, small gold sparkles trailing behind, simple sweep line
```

### 부적의 길 (Talisman Path) — 6종

**Seed:** 75021~75026

#### upgrade_talisman_slots — 부적 슬롯 확장
```
empty square outline, plus symbol next to it, second square appearing, simple slot expansion
```

#### upgrade_talisman_trigger — 부적 발동률 증가
```
talisman paper with small lightning bolt on it, simple paper with bolt
```

#### upgrade_talisman_fusion — 부적 합성 해금
```
two small talisman papers merging into one, fusion sparks between them, simple merge icon
```

#### upgrade_legend_rate — 전설 등장률 증가
```
golden star rising above small gray pile, simple star-over-pile
```

#### upgrade_start_talisman — 시작 부적
```
talisman paper with small gift ribbon bow on top, simple paper with bow
```

#### upgrade_curse_resist — 저주 저항
```
small dark purple talisman, tiny shield symbol blocking it, simple curse-blocked icon
```

### 생존의 길 (Survival Path) — 7종

**Seed:** 75031~75037

#### upgrade_max_lives — 최대 목숨 증가
```
red heart, small white plus symbol next to it, simple heart-plus
```

#### upgrade_go_insurance — Go 보험
```
red downward arrow caught by small safety net below, simple net-catch
```

#### upgrade_start_yeop — 시작 엽전 증가
```
small brown pouch, golden coins spilling out of top, simple coin pouch
```

#### upgrade_shop_discount — 상점 할인
```
small tag with red downward arrow on it, simple discount tag
```

#### upgrade_event_bonus — 이벤트 보너스
```
small gift box, sparkle marks around it, simple gift box
```

#### upgrade_revive — 부활
```
cracked skull, golden light shining through crack, simple cracked-skull-glow
```

#### upgrade_target_reduce — 목표 점수 감소
```
number symbol, red downward arrow beside it, simple score-reduction icon
```

---

## 3. 보스 파츠 아이콘 (24종)

> 보스 장비 파츠 아이콘. 등급 테두리는 게임 UI에서 처리.
> 아이콘 자체는 투명 배경 + 오브젝트만.

**크기:** 88x88 (픽셀 그리드 22x22 기준, 4x 생성 → 다운스케일 66x66)

### 공통 프롬프트 프리픽스

```
score_9, score_8_up, score_7_up, pixel art, game assets, chibi, simple green background, very small equipment icon, one extremely simple object centered, flat colors, thick black outlines, no ground, no shadow, maximally simple, square composition, only the item, nothing else
```

### 머리(Head) 파츠 — 8종
**Seed:** 75101~75108

#### parts_iron_horn — 쇠뿔
```
single short gray iron horn pointing upward, simple horn shape
```

#### parts_fire_horn — 화염 뿔
```
horn with orange flame at tip, dark horn, orange fire top
```

#### parts_ice_crown — 얼음 왕관
```
small crown of pale blue ice crystal spikes, simple frozen crown
```

#### parts_third_eye — 제3의 눈
```
single large eye with red iris, simple floating eye
```

#### parts_ghost_helm — 도깨비불 투구
```
dark helmet, cyan flame burning on top as crest, simple helmet-flame
```

#### parts_skull_crown — 해골 면류관
```
crown made of small white skulls, simple bone crown
```

#### parts_fog_mask — 독안개 면
```
face mask, green wisps leaking from it, simple mask with fog
```

#### parts_king_helm — 천왕 투구
```
grand golden helmet, wing decorations on sides, simple royal helmet
```

### 팔(Arm) 파츠 — 8종
**Seed:** 75111~75118

#### parts_chain_arm — 쇠사슬
```
dark iron chain link with small lock, simple chain-lock
```

#### parts_fire_glove — 불꽃 장갑
```
gauntlet glove, orange flame aura around fist, simple fiery glove
```

#### parts_shadow_arm — 그림자 팔
```
dark arm silhouette, purple glow edges, simple shadow arm shape
```

#### parts_gold_brace — 황금 팔찌
```
golden bracelet ring shape, simple gold circle brace
```

#### parts_poison_claw — 독 발톱
```
sharp claw, green poison drops dripping from tip, simple toxic claw
```

#### parts_seal_arm — 봉인 부적 팔
```
arm shape wrapped in red talisman papers, simple sealed arm
```

#### parts_web_hand — 거미줄 손
```
hand with sticky white web strands between spread fingers, simple web hand
```

#### parts_bone_pincer — 뼈 집게
```
white bone pincers like crab claws, simple bone claw
```

### 몸통(Body) 파츠 — 8종
**Seed:** 75121~75128

#### parts_iron_plate — 철갑
```
dark iron chest plate armor shape, simple armor front
```

#### parts_fire_mark — 화문
```
body outline, glowing orange fire rune symbol on chest, simple fire-marked torso
```

#### parts_ice_armor — 빙결 갑옷
```
chest covered in blue ice crystal formations, simple frozen armor
```

#### parts_shadow_armor — 그림자 갑옷
```
dark shifting chest shape, purple edge glow, simple shadow torso
```

#### parts_talisman_absorb — 부적 흡수체
```
dark body shape, small talisman papers pulled into surface, simple absorb effect
```

#### parts_mirror_plate — 거울 흉갑
```
chest plate with bright reflective silver surface, simple mirror armor
```

#### parts_thorn_armor — 가시 갑옷
```
armor shape with sharp thorns sticking outward, simple thorny armor
```

#### parts_smoke_body — 연기 몸
```
body outline dissolving into wispy smoke at edges, simple smoky form
```

## 후처리 (공통)

```
1. 크로마키 그린 배경 제거 → 투명 알파
2. Nearest Neighbor 다운스케일 → 목적 크기 (48x48 or 32x32)
3. PNG (알파) → Assets/Art/Icons/ 하위 폴더
```

# 통화, 영구 강화, 보스 파츠 아이콘

> **아이작 스타일** — 1:1 정사각, 투명 배경, 오브젝트만. 심플한 도트 실루엣.

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
Three traditional Korean brass coins stacked slightly offset. Round golden-brown coins with square holes in the center. Simple coin stack. Nothing else.
```

### icon_soul — 넋 (영구 강화 화폐)
**Seed:** 75002
```
A small floating pale blue-white spirit orb with tiny wisp trails. Translucent glowing blue-cyan sphere. Simple soul fragment. Nothing else.
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
Three stacked red poker chips with a small white plus symbol above. Simple chip stack. Nothing else.
```

#### upgrade_base_mult — 기본 배수 증가
```
A bold red multiplication symbol (×) with small radiating lines around it. Simple math symbol. Nothing else.
```

#### upgrade_start_hand — 시작 손패 증가
```
A fan of three small card shapes spreading outward with a plus symbol. Simple card fan. Nothing else.
```

#### upgrade_deck_compress — 덱 압축
```
A deck of cards being squeezed by two inward-pointing arrows from both sides. Simple compressed deck. Nothing else.
```

#### upgrade_yokbo_bonus — 족보 보너스
```
A small scroll with a golden star on it. Simple scroll with star. Nothing else.
```

#### upgrade_sweep_bonus — 쓸 보너스
```
A horizontal brush stroke with small gold sparkles trailing behind. Simple sweep line. Nothing else.
```

### 부적의 길 (Talisman Path) — 6종

**Seed:** 75021~75026

#### upgrade_talisman_slots — 부적 슬롯 확장
```
An empty square outline with a plus symbol next to it and a second square appearing. Simple slot expansion. Nothing else.
```

#### upgrade_talisman_trigger — 부적 발동률 증가
```
A talisman paper with a small lightning bolt on it. Simple paper with bolt. Nothing else.
```

#### upgrade_talisman_fusion — 부적 합성 해금
```
Two small talisman papers merging into one with fusion sparks between them. Simple merge icon. Nothing else.
```

#### upgrade_legend_rate — 전설 등장률 증가
```
A golden star rising above a small gray pile. Simple star-over-pile. Nothing else.
```

#### upgrade_start_talisman — 시작 부적
```
A talisman paper with a small gift ribbon bow on top. Simple paper with bow. Nothing else.
```

#### upgrade_curse_resist — 저주 저항
```
A small dark purple talisman with a tiny shield symbol blocking it. Simple curse-blocked icon. Nothing else.
```

### 생존의 길 (Survival Path) — 7종

**Seed:** 75031~75037

#### upgrade_max_lives — 최대 목숨 증가
```
A red heart with a small white plus symbol next to it. Simple heart-plus. Nothing else.
```

#### upgrade_go_insurance — Go 보험
```
A red downward arrow caught by a small safety net below it. Simple net-catch. Nothing else.
```

#### upgrade_start_yeop — 시작 엽전 증가
```
A small brown pouch with golden coins spilling out of the top. Simple coin pouch. Nothing else.
```

#### upgrade_shop_discount — 상점 할인
```
A small tag with a red downward arrow on it. Simple discount tag. Nothing else.
```

#### upgrade_event_bonus — 이벤트 보너스
```
A small gift box with sparkle marks around it. Simple gift box. Nothing else.
```

#### upgrade_revive — 부활
```
A cracked skull with a golden light shining through the crack. Simple cracked-skull-glow. Nothing else.
```

#### upgrade_target_reduce — 목표 점수 감소
```
A number symbol with a red downward arrow beside it. Simple score-reduction icon. Nothing else.
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
A single short gray iron horn pointing upward. Simple horn shape. Nothing else.
```

#### parts_fire_horn — 화염 뿔
```
A horn with orange flame at its tip. Dark horn, orange fire top. Nothing else.
```

#### parts_ice_crown — 얼음 왕관
```
A small crown made of pale blue ice crystal spikes. Simple frozen crown. Nothing else.
```

#### parts_third_eye — 제3의 눈
```
A single large eye with a red iris. Simple floating eye. Nothing else.
```

#### parts_ghost_helm — 도깨비불 투구
```
A dark helmet with a cyan flame burning on top as a crest. Simple helmet-flame. Nothing else.
```

#### parts_skull_crown — 해골 면류관
```
A crown made of small white skulls. Simple bone crown. Nothing else.
```

#### parts_fog_mask — 독안개 면
```
A face mask with green wisps leaking from it. Simple mask with fog. Nothing else.
```

#### parts_king_helm — 천왕 투구
```
A grand golden helmet with wing decorations on the sides. Simple royal helmet. Nothing else.
```

### 팔(Arm) 파츠 — 8종
**Seed:** 75111~75118

#### parts_chain_arm — 쇠사슬
```
A dark iron chain link with a small lock. Simple chain-lock. Nothing else.
```

#### parts_fire_glove — 불꽃 장갑
```
A gauntlet glove with orange flame aura around the fist. Simple fiery glove. Nothing else.
```

#### parts_shadow_arm — 그림자 팔
```
A dark arm silhouette with purple glow edges. Simple shadow arm shape. Nothing else.
```

#### parts_gold_brace — 황금 팔찌
```
A golden bracelet ring shape. Simple gold circle brace. Nothing else.
```

#### parts_poison_claw — 독 발톱
```
A sharp claw with green poison drops dripping from the tip. Simple toxic claw. Nothing else.
```

#### parts_seal_arm — 봉인 부적 팔
```
An arm shape wrapped in red talisman papers. Simple sealed arm. Nothing else.
```

#### parts_web_hand — 거미줄 손
```
A hand with sticky white web strands between spread fingers. Simple web hand. Nothing else.
```

#### parts_bone_pincer — 뼈 집게
```
White bone pincers like crab claws. Simple bone claw. Nothing else.
```

### 몸통(Body) 파츠 — 8종
**Seed:** 75121~75128

#### parts_iron_plate — 철갑
```
A dark iron chest plate armor shape. Simple armor front. Nothing else.
```

#### parts_fire_mark — 화문
```
A body outline with a glowing orange fire rune symbol on the chest. Simple fire-marked torso. Nothing else.
```

#### parts_ice_armor — 빙결 갑옷
```
A chest covered in blue ice crystal formations. Simple frozen armor. Nothing else.
```

#### parts_shadow_armor — 그림자 갑옷
```
A dark shifting chest shape with purple edge glow. Simple shadow torso. Nothing else.
```

#### parts_talisman_absorb — 부적 흡수체
```
A dark body shape with small talisman papers being pulled into its surface. Simple absorb effect. Nothing else.
```

#### parts_mirror_plate — 거울 흉갑
```
A chest plate with bright reflective silver surface. Simple mirror armor. Nothing else.
```

#### parts_thorn_armor — 가시 갑옷
```
An armor shape with sharp thorns sticking outward from the surface. Simple thorny armor. Nothing else.
```

#### parts_smoke_body — 연기 몸
```
A body outline dissolving into wispy smoke at the edges. Simple smoky form. Nothing else.
```

## 후처리 (공통)

```
1. 크로마키 그린 배경 제거 → 투명 알파
2. Nearest Neighbor 다운스케일 → 목적 크기 (48x48 or 32x32)
3. PNG (알파) → Assets/Art/Icons/ 하위 폴더
```

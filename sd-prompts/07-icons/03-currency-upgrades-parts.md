# 통화, 영구 강화, 보스 파츠 아이콘

---

## 1. 통화 아이콘 (2종)

**크기:** 192x192 (→ 48x48 다운스케일)

### 공통 프롬프트 프리픽스

```
A single small square pixel art currency icon. 16-bit retro pixel art with crisp sharp pixels, no anti-aliasing. Bold flat colors with thick black outlines. Limited color palette based on game palette: dark navy (#1A1A2E), blood red (#C41E3A), ghost fire cyan (#00D4FF), gold (#FFD700), bone white (#E8E8E8). One clear central object. Fully contained within the square frame. No text. Transparent background.
```

### icon_yeop — 엽전 (런 내 화폐)
**Seed:** 75001
```
A stack of three traditional Korean brass coins — yeop-jeon — with square holes in the center. The coins are golden-brown brass with visible square cutouts in each center. Stacked slightly offset so all three are visible. Metallic warm golden color with dark outlines. Simple clean icon on transparent background.
```

### icon_soul — 넋 (영구 강화 화폐)
**Seed:** 75002
```
A small floating ethereal blue-white soul fragment — a wispy glowing spirit orb. The orb is translucent pale blue-white with a soft cyan glow around it. Small spirit wisps trail from the orb. Ghostly and beautiful — a fragment of a dead soul. Simple clean icon on transparent background. Color palette: pale blue-white, cyan glow.
```

---

## 2. 영구 강화 노드 아이콘 (19종)

> 영구 강화 트리에서 각 노드를 표시하는 아이콘.
> 3개 경로: 패의 길(빨강), 부적의 길(파랑), 생존의 길(초록).

**크기:** 192x192 (→ 48x48)

### 공통 프롬프트 프리픽스

```
A single small square pixel art upgrade node icon for a Korean underworld card game. 16-bit retro pixel art with crisp sharp pixels. Bold flat colors with thick black outlines. One clear symbol representing the upgrade ability. Fully contained. No text. Dark background with colored border glow matching the upgrade path.
```

### 패의 길 (Card Path) — 빨강 테두리 6종

**Seed:** 75011~75016

```
# base_chips — 기본 칩 증가
A stack of poker-style chips glowing warm red. Three chips stacked with a plus symbol above them. Red border glow on dark background.

# base_mult — 기본 배수 증가
A multiplication symbol (×) rendered in bold red with radiating power lines. Red border glow.

# start_hand — 시작 손패 증가
A fan of three hwatu cards spreading outward, with a plus symbol and a fourth card appearing. Red border glow.

# deck_compress — 덱 압축
A deck of cards being squeezed together by two arrows pressing inward from both sides. Red border glow.

# yokbo_bonus — 족보 보너스
A scroll unfurling to reveal a golden star symbol inside. The yokbo completion bonus. Red border glow.

# sweep_bonus — 쓸 보너스
A sweeping horizontal brush stroke with golden sparkles trailing behind it. The sweep power bonus. Red border glow.
```

### 부적의 길 (Talisman Path) — 파랑 테두리 6종

**Seed:** 75021~75026

```
# talisman_slots — 부적 슬롯 확장
An empty talisman slot outline with a plus symbol, and a new slot appearing beside it. Blue border glow.

# talisman_trigger — 부적 발동률 증가
A talisman paper with a glowing lightning bolt symbol in the center — increased activation chance. Blue border glow.

# talisman_fusion — 부적 합성 해금
Two talisman papers merging together into one brighter, more powerful talisman with fusion energy. Blue border glow.

# legend_rate — 전설 등장률 증가
A golden star rising from a pile of regular gray talismans. The legendary appears more often. Blue border glow.

# start_talisman — 시작 부적
A talisman paper with a gift ribbon bow on it — starting the run with a free talisman choice. Blue border glow.

# curse_resist — 저주 저항
A dark purple cursed talisman with a shield symbol blocking its energy. Curse resistance. Blue border glow.
```

### 생존의 길 (Survival Path) — 초록 테두리 7종

**Seed:** 75031~75037

```
# max_lives — 최대 목숨 증가
A red heart with a plus symbol and a second smaller heart appearing beside it. Green border glow.

# go_insurance — Go 보험
A safety net catching a falling red Go arrow. Insurance against Go failure. Green border glow.

# start_yeop — 시작 엽전 증가
A small pouch of coins with brass yeop-jeon spilling out. Starting with more money. Green border glow.

# shop_discount — 상점 할인
A price tag with a downward red arrow showing reduced cost. Shop discount. Green border glow.

# event_bonus — 이벤트 보너스
A gift box with a plus symbol and sparkles. Enhanced event rewards. Green border glow.

# revive — 부활
A cracked skull with a golden light healing the crack — one-time revival from death. Green border glow.

# target_reduce — 목표 점수 감소
A boss target score number with a downward arrow reducing it. Lower boss requirements. Green border glow.
```

---

## 3. 보스 파츠 아이콘 (24종)

> 보스가 장비하는 파츠(머리/팔/몸통)를 표시하는 작은 아이콘.
> 등급별 배경: 일반=회색, 희귀=파랑, 전설=금색.
> 세트별 추가 색상 힌트: 불(주황), 얼음(하늘), 그림자(보라), 해골(흰색).

**크기:** 128x128 (→ 32x32)

### 공통 프롬프트 프리픽스

```
A very small square pixel art boss equipment icon. 16-bit retro pixel art with crisp sharp pixels. Bold flat colors with thick black outlines. One simple recognizable symbol for a boss part. Must be readable even at 32x32 pixels — keep extremely simple. Fully contained. No text.
```

### 머리(Head) 파츠 — 8종
**Seed:** 75101~75108

```
# iron_horn — 쇠뿔 (일반)
A single short iron horn. Gray metallic horn on gray background.

# fire_horn — 화염 뿔 (희귀, 불 세트)
A horn with orange flames burning from its tip. Fiery horn on blue background with orange accent.

# ice_crown — 얼음 왕관 (희귀, 얼음 세트)
A small crown made of blue ice crystals. Frozen crown on blue background.

# third_eye — 제3의 눈 (일반)
A single large eye with red iris floating above. All-seeing eye on gray background.

# ghost_helm — 도깨비불 투구 (희귀)
A dark helmet with cyan ghost flame crest on top. Ghost fire helmet on blue background.

# skull_crown — 해골 면류관 (전설, 해골 세트)
A crown made of tiny skulls stacked together. Bone crown on gold background.

# fog_mask — 독안개 면 (희귀)
A face mask with green toxic fog wisps leaking from it. Poison mask on blue background.

# king_helm — 천왕 투구 (전설)
A grand ornate golden warrior helmet with wing decorations. Royal helm on gold background.
```

### 팔(Arm) 파츠 — 8종
**Seed:** 75111~75118

```
# chain_arm — 쇠사슬 (희귀)
A chain link with a lock. Dark iron chain on blue background.

# fire_glove — 불꽃 장갑 (일반, 불 세트)
A gauntlet glove with orange flame aura. Fiery glove on gray background with orange accent.

# shadow_arm — 그림자 팔 (희귀, 그림자 세트)
A dark shadowy arm silhouette with purple glow. Shadow arm on blue background.

# gold_brace — 황금 팔찌 (일반)
A golden bracelet with coin symbols. Gold brace on gray background.

# poison_claw — 독 발톱 (희귀)
A sharp claw dripping green poison drops. Toxic claw on blue background.

# seal_arm — 봉인 부적 팔 (전설)
An arm wrapped in glowing red talisman papers. Sealed arm on gold background.

# web_hand — 거미줄 손 (희귀)
A hand with sticky web strands between the fingers. Web hand on blue background.

# bone_pincer — 뼈 집게 (전설, 해골 세트)
Bone pincers like crab claws made of white bone. Bone pincer on gold background.
```

### 몸통(Body) 파츠 — 8종
**Seed:** 75121~75128

```
# iron_plate — 철갑 (일반)
A dark iron chest plate. Simple armor on gray background.

# fire_mark — 화문 (희귀, 불 세트)
A body silhouette with glowing orange fire rune on the chest. Fire mark on blue background.

# ice_armor — 빙결 갑옷 (희귀, 얼음 세트)
A chest covered in blue ice crystal armor. Frozen armor on blue background.

# shadow_armor — 그림자 갑옷 (일반, 그림자 세트)
A dark shifting shadow covering a body outline. Shadow armor on gray background with purple accent.

# talisman_absorb — 부적 흡수체 (전설)
A dark body with talisman papers being sucked into its surface. Absorbing talismans on gold background.

# mirror_plate — 거울 흉갑 (전설)
A chest plate made of reflective mirror surface. Silver mirror armor on gold background.

# thorn_armor — 가시 갑옷 (희귀)
Armor covered in sharp protruding thorns. Thorny armor on blue background.

# smoke_body — 연기 몸 (일반)
A body outline dissolving into smoke wisps. Smoky form on gray background.
```

## 후처리 (공통)

```
1. Nearest Neighbor 다운스케일 → 아이콘 목적 크기
2. PNG (알파) → Assets/Art/Icons/ 하위 폴더
```

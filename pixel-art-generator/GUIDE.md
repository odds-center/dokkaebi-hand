# 도깨비의 패 — 픽셀아트 에셋 생성기 가이드

Replicate API (FLUX Dev 무료 모델)를 사용한 16-bit 픽셀아트 게임 에셋 자동 생성 도구.
기존 `sd-prompts-flux/` 폴더의 md 파일을 자동 파싱하여 이미지를 생성합니다.

---

## 1. 초기 설정

### 1-1. Replicate 계정 및 API 토큰 발급

1. [https://replicate.com](https://replicate.com) 접속 → 회원가입 (GitHub 로그인 가능)
2. [https://replicate.com/account/api-tokens](https://replicate.com/account/api-tokens) 접속
3. **Create token** 클릭 → 토큰 복사

### 1-2. 환경 설정

```bash
# 프로젝트 폴더로 이동
cd dokkaebi-hand/pixel-art-generator

# Python 가상환경 생성 (권장)
python -m venv venv
source venv/Scripts/activate   # Windows Git Bash
# 또는
# venv\Scripts\activate        # Windows CMD

# 패키지 설치
pip install -r requirements.txt
```

### 1-3. API 토큰 등록

```bash
cp .env.example .env
```

`.env` 파일을 열고 토큰 입력:
```
REPLICATE_API_TOKEN=r8_여기에_복사한_토큰_붙여넣기
```

### 1-4. 설정 확인

```bash
python -c "from config import REPLICATE_API_TOKEN; print('OK' if REPLICATE_API_TOKEN else 'TOKEN 없음')"
```

---

## 2. 프롬프트 소스

프롬프트는 **직접 작성하지 않습니다.** 기존 `sd-prompts-flux/` 폴더의 md 파일을 자동으로 파싱합니다.

```
dokkaebi-hand/
├── sd-prompts-flux/                    ← 프롬프트 원본 (FLUX Dev 전용)
│   ├── 01-bosses.md               보스 스프라이트 10+
│   ├── 02-boss-expressions.md     보스 표정 변형
│   ├── 03-companions.md           동료 도깨비 7+
│   ├── 04-talismans.md            부적 아이콘 20+
│   ├── 05-backgrounds.md          배경 7+
│   ├── 06-card-illustrations.md   화투 카드 48장
│   ├── 07-card-extras.md          카드 뒷면/강화 10+
│   ├── 08-icons.md                아이콘 87+
│   ├── 09-vfx.md                  VFX 16+
│   ├── 10-ui-frames.md            UI 프레임 25+
│   └── 11-hud-icons.md            HUD 아이콘 21+
│
└── pixel-art-generator/           ← 생성 도구 (이 폴더)
    └── output/                    ← 생성된 이미지가 여기에 저장
```

### 파싱 과정

1. 각 카테고리의 `00-common.md`에서 **공통 프리픽스 + 네거티브** 추출
2. 개별 md 파일에서 `### asset_name` + `**Seed:**` + ` ``` prompt ``` ` 추출
3. Pony/ComfyUI 전용 태그 (`score_9`, `source_anime`, `chibi` 등) 자동 제거
4. FLUX Dev에 맞는 순수 영어 프롬프트로 변환하여 생성

---

## 3. 에셋 목록 확인

### 전체 목록

```bash
python batch_generate.py list
```

### 특정 카테고리 상세 목록

```bash
python batch_generate.py cards --detail
python batch_generate.py sprites --detail
python batch_generate.py icons --detail
```

### 미리보기 (실제 생성 없이 비용 확인)

```bash
python batch_generate.py all --dry-run
python batch_generate.py cards --dry-run
```

---

## 4. 이미지 생성

### 4-1. 카테고리 단축어

| 단축어 | 폴더 | 설명 |
|--------|------|------|
| `bg` | 01-backgrounds | 배경 |
| `cards` | 02-card-illustrations | 화투 카드 48장 |
| `tex` | 03-textures | 텍스처 |
| `concept` | 04-concept-art | 컨셉아트 |
| `calli` | 05-calligraphy | 서예 |
| `sprites` | 06-game-sprites | 보스/동료/NPC 스프라이트 |
| `icons` | 07-icons | 아이콘 (부적/업적/통화) |
| `illust` | 08-illustrations | 이벤트/튜토리얼 삽화 |
| `card-extras` | 09-card-extras | 카드 뒷면/강화 오버레이 |
| `vfx` | 10-vfx | VFX 이펙트 |
| `ui` | 11-ui-frames | UI 프레임/패널 |
| `hud` | 12-hud-icons | HUD 아이콘 |

### 4-2. 카테고리별 생성

```bash
# 화투 카드 48장 생성
python batch_generate.py cards

# 스프라이트 (보스/동료/NPC) 생성
python batch_generate.py sprites

# 배경 생성
python batch_generate.py bg

# 아이콘 전체 생성
python batch_generate.py icons

# UI 프레임 생성
python batch_generate.py ui

# VFX 생성
python batch_generate.py vfx

# HUD 아이콘
python batch_generate.py hud

# 전부 다 생성
python batch_generate.py all
```

### 4-3. 특정 에셋만 생성

```bash
# 보스 중 특정 것만
python batch_generate.py sprites --only boss_glutton boss_flame

# 카드 중 특정 것만
python batch_generate.py cards --only m01_gwang m02_yeolkkeut
```

### 4-4. 배치 생성 (같은 프롬프트로 여러 장)

```bash
# 카드 48장을 각각 4장씩 뽑아서 최선 선택 (총 192장)
python batch_generate.py cards --batch 4

# 보스만 8장씩 뽑기
python batch_generate.py sprites --only boss_glutton --batch 8
```

### 4-5. 커스텀 프롬프트로 단일 생성

```python
# Python에서 직접
from generate import generate_single

generate_single(
    prompt="giant stone golem dokkaebi, gray rock body with glowing red runes, massive fists",
    name="boss_stone_golem",
    category="06-game-sprites",
    width=800,
    height=800,
    seed=70020,
)
```

---

## 5. 후처리

### 5-1. 녹색 배경 제거 (크로마키)

스프라이트/아이콘은 녹색 배경으로 생성되므로 투명 배경으로 변환이 필요합니다.
(배경, 카드 일러스트는 배경 제거 불필요)

```bash
# 폴더 전체 (transparent/ 하위 폴더에 저장)
python post_process.py remove-bg output/game-sprites/
python post_process.py remove-bg output/icons/
python post_process.py remove-bg output/vfx/
python post_process.py remove-bg output/ui-frames/
python post_process.py remove-bg output/hud-icons/

# 허용 범위 조절 (기본 80, 높이면 더 많이 제거)
python post_process.py remove-bg output/game-sprites/ --tolerance 100
```

### 5-2. 게임용 크기로 리사이즈 (Nearest Neighbor)

sd-prompts-flux/README.md의 해상도 체계에 따라 다운스케일합니다.

```bash
# 보스 스프라이트: 800x800 → 600x600 (@1920x1080)
python post_process.py resize output/game-sprites/transparent/ --size 600x600

# 카드 일러스트: 240x336 → 180x252 (@1920x1080)
python post_process.py resize output/card-illustrations/ --size 180x252

# 부적 아이콘: 128x128 → 96x96 (@1920x1080)
python post_process.py resize output/icons/transparent/ --size 96x96

# HUD 아이콘: 128x128 → 96x96
python post_process.py resize output/hud-icons/transparent/ --size 96x96

# 배경: 640x360 → 1920x1080 (3x 업스케일)
python post_process.py resize output/backgrounds/ --size 1920x1080
```

### 5-3. 스프라이트 시트 생성

```bash
# 아이콘 스프라이트 시트 (8열)
python post_process.py spritesheet output/icons/transparent/ --output output/icon_sheet.png --columns 8

# 카드 일러스트 시트 (12열 = 12개월)
python post_process.py spritesheet output/card-illustrations/ --output output/card_sheet.png --columns 12 --cell-size 180x252
```

---

## 6. Unity에 적용하기

### 6-1. 파일 복사

```bash
# 보스/동료/NPC 스프라이트
cp output/game-sprites/transparent/*.png Assets/Art/Sprites/Boss/

# 카드 일러스트
cp output/card-illustrations/*.png Assets/Art/Cards/Illustrations/

# 배경
cp output/backgrounds/*.png Assets/Art/Backgrounds/

# 아이콘
cp output/icons/transparent/*.png Assets/Art/Icons/

# UI 프레임
cp output/ui-frames/transparent/*.png Assets/Art/UI/Frames/
```

### 6-2. Unity Import 설정 (필수!)

| 설정 | 값 | 이유 |
|------|-----|------|
| **Texture Type** | Sprite (2D and UI) | 2D 게임용 |
| **Sprite Mode** | Single | 개별 스프라이트 |
| **Pixels Per Unit** | 3 (배경) / 1 (스프라이트) | 해상도 체계에 맞게 |
| **Filter Mode** | **Point (no filter)** | 픽셀아트 필수! |
| **Compression** | None | 품질 보존 |

---

## 7. 비용 안내

### 모델: FLUX Dev (무료 티어 포함)

Replicate 무료 티어로 일정 횟수 무료 생성 가능.
유료 전환 시: GPU 시간당 과금 (~$0.004/이미지)

### 전체 비용 예상

| 카테고리 | 수량 | ×1장 | ×4장 |
|---------|------|------|------|
| 배경 | ~20 | $0.08 | $0.32 |
| 화투 카드 | 48 | $0.19 | $0.77 |
| 텍스처 | ~15 | $0.06 | $0.24 |
| 컨셉아트 | ~9 | $0.04 | $0.14 |
| 서예 | ~37 | $0.15 | $0.59 |
| 스프라이트 | ~121 | $0.48 | $1.94 |
| 아이콘 | ~87 | $0.35 | $1.39 |
| 삽화 | ~14 | $0.06 | $0.22 |
| 카드 추가 | ~10 | $0.04 | $0.16 |
| VFX | ~16 | $0.06 | $0.26 |
| UI 프레임 | ~25 | $0.10 | $0.40 |
| HUD | ~21 | $0.08 | $0.34 |
| **총계** | **~414** | **~$1.65** | **~$6.60** |

---

## 8. 폴더 구조

```
pixel-art-generator/
├── .env                    # API 토큰 (git에 올리지 말 것!)
├── .env.example            # 환경변수 예시
├── requirements.txt        # Python 패키지
├── config.py               # 설정 (모델, 크기, 경로)
├── parse_prompts.py        # sd-prompts-flux/ md 파일 파서
├── generate.py             # Replicate API 호출 + 이미지 다운로드
├── batch_generate.py       # 배치 생성 CLI (메인 진입점)
├── post_process.py         # 후처리 (배경제거, 리사이즈, 스프라이트시트)
├── GUIDE.md                # 이 문서
└── output/                 # 생성된 이미지
    ├── backgrounds/
    ├── card-illustrations/
    ├── textures/
    ├── concept-art/
    ├── calligraphy/
    ├── game-sprites/
    │   └── transparent/    # 배경 제거 버전
    ├── icons/
    │   └── transparent/
    ├── illustrations/
    ├── card-extras/
    ├── vfx/
    ├── ui-frames/
    └── hud-icons/
```

---

## 9. 권장 작업 순서

sd-prompts-flux/README.md의 권장 순서를 따릅니다:

```bash
# 1단계: 목록/비용 확인
python batch_generate.py list
python batch_generate.py all --dry-run

# 2단계: 텍스처 (빠르고 확실, 자신감 획득)
python batch_generate.py tex --batch 4

# 3단계: 배경 (게임 분위기 확정)
python batch_generate.py bg --batch 4

# 4단계: 카드 일러스트 48장 (핵심 에셋)
python batch_generate.py cards --batch 4

# 5단계: 카드 추가 에셋
python batch_generate.py card-extras --batch 4

# 6단계: 서예/캘리그래피
python batch_generate.py calli --batch 4

# 7단계: 아이콘 87종 (대량 생산)
python batch_generate.py icons --batch 4

# 8단계: 스프라이트 (보스/동료/NPC)
python batch_generate.py sprites --batch 4

# 9단계: 삽화
python batch_generate.py illust --batch 4

# 10단계: VFX + UI + HUD
python batch_generate.py vfx --batch 4
python batch_generate.py ui --batch 4
python batch_generate.py hud --batch 4

# 11단계: 후처리
python post_process.py remove-bg output/game-sprites/
python post_process.py remove-bg output/icons/
python post_process.py remove-bg output/vfx/
python post_process.py remove-bg output/ui-frames/
python post_process.py remove-bg output/hud-icons/

# 12단계: 리사이즈
python post_process.py resize output/game-sprites/transparent/ --size 600x600
python post_process.py resize output/card-illustrations/ --size 180x252
python post_process.py resize output/icons/transparent/ --size 96x96
python post_process.py resize output/backgrounds/ --size 1920x1080
```

---

## 10. 모델 변경

`config.py`에서 모델을 변경할 수 있습니다:

```python
# 무료 모델 (기본)
MODEL_ID = "black-forest-labs/flux-dev"

# 고품질 유료 모델
MODEL_ID = "black-forest-labs/flux-1.1-pro"

# 픽셀아트 전용 (유료, 최고 품질)
MODEL_ID = "retro-diffusion/rd-plus"
```

---

## 11. 문제 해결

| 문제 | 해결 |
|------|------|
| `REPLICATE_API_TOKEN not set` | `.env` 파일에 토큰이 올바르게 입력되었는지 확인 |
| `Rate limit exceeded` | 1~2분 기다린 후 재시도. 배치 생성시 자동 1초 대기 포함 |
| 이미지가 픽셀아트 같지 않음 | 프롬프트에 `pixel art, 16-bit` 포함 확인. 모델을 `rd-plus`로 변경 고려 |
| 배경 제거가 깨끗하지 않음 | `--tolerance` 값 조절 (기본 80, 60~120 사이 실험) |
| 리사이즈 후 흐려짐 | `post_process.py`는 자동으로 NEAREST 사용 — Unity Filter Mode: Point 확인 |
| 스타일이 일관적이지 않음 | 같은 카테고리는 공통 프리픽스가 자동 적용됨. seed 고정 확인 |
| 파싱 결과가 이상함 | `python parse_prompts.py` 로 파싱 결과 확인 |
| 프롬프트 수정하고 싶음 | `sd-prompts-flux/` 의 md 파일을 직접 수정하면 자동 반영 |

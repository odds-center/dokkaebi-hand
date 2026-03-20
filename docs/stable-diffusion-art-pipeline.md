# Stable Diffusion 완전 자동화 아트 파이프라인 계획서

## 1. 목표

**명령 하달만으로** 모든 게임 에셋을 생성한다.
수동 편집 도구(Aseprite, Photoshop 등) 없이, 터미널 명령 + Python 스크립트로 전 과정을 자동화한다.

```
명령 입력 → SD API 호출 → 자동 후처리 → Unity 폴더에 최종 파일 배치
```

---

## 2. 자동화 아키텍처

### 2.1 전체 흐름

```
┌─────────────────────────────────────────────────────┐
│                    generate.py                       │
│  (마스터 스크립트 — 명령 하나로 전체 실행)             │
├─────────────────────────────────────────────────────┤
│                                                      │
│  1. config/*.json    ← 에셋별 프롬프트/설정 정의       │
│         ↓                                            │
│  2. SD WebUI API     ← txt2img / img2img 호출        │
│         ↓                                            │
│  3. postprocess.py   ← 리사이즈, 팔레트 제한, 배경 제거│
│         ↓                                            │
│  4. Assets/Art/      ← Unity 프로젝트에 최종 배치      │
│                                                      │
└─────────────────────────────────────────────────────┘
```

### 2.2 필요 환경

| 구성요소 | 역할 | 설치 방법 |
|---------|------|----------|
| **Stable Diffusion WebUI (A1111)** | 이미지 생성 서버 | `git clone` + `webui.sh --api` |
| **Python 3.10+** | 자동화 스크립트 | 기본 설치 |
| **Pillow (PIL)** | 이미지 후처리 | `pip install Pillow` |
| **rembg** | 자동 배경 제거 | `pip install rembg` |
| **requests** | SD API 통신 | `pip install requests` |

> **핵심:** A1111을 `--api` 플래그로 실행하면 REST API가 열린다.
> 이 API로 모든 생성/변환을 명령어로 제어한다.

---

## 3. 환경 세팅 (한 번만)

### 3.1 SD WebUI 설치 & API 모드 실행

```bash
# 1. SD WebUI 클론
git clone https://github.com/AUTOMATIC1111/stable-diffusion-webui.git
cd stable-diffusion-webui

# 2. 모델 다운로드 (models/Stable-diffusion/ 에 배치)
#    - SDXL base: sd_xl_base_1.0.safetensors
#    - SD 1.5:    v1-5-pruned.safetensors

# 3. 픽셀아트 LoRA 다운로드 (models/Lora/ 에 배치)
#    - pixel-art-xl.safetensors
#    - pixelart-style.safetensors

# 4. ControlNet 확장 설치
cd extensions
git clone https://github.com/Mikubill/sd-webui-controlnet.git

# 5. API 모드로 실행
cd ..
./webui.sh --api --listen --port 7860
```

### 3.2 프로젝트 스크립트 구조

```
dokkaebi-hand/
  sd-pipeline/               ← 이 폴더를 새로 만듦
    generate.py              ← 마스터 실행 스크립트
    sd_api.py                ← SD WebUI API 래퍼
    postprocess.py           ← 후처리 (리사이즈, 팔레트, 배경 제거)
    config/
      cards.json             ← 카드 48장 프롬프트 정의
      characters.json        ← 캐릭터 46장 프롬프트 정의
      backgrounds.json       ← 배경 7종 프롬프트 정의
      talismans.json         ← 부적 아이콘 프롬프트 정의
      ui.json                ← UI 텍스처 프롬프트 정의
      common.json            ← 공통 프롬프트/네거티브/설정
    palette/
      dokkaebi_palette.png   ← 9색 팔레트 이미지 (스크립트로 생성)
    output/                  ← SD 원본 출력 (중간 파일)
    README.md                ← 사용법
```

---

## 4. 핵심 스크립트 설계

### 4.1 공통 설정 (`config/common.json`)

```json
{
  "sd_url": "http://127.0.0.1:7860",
  "common_positive": "pixel art, 16-bit style, limited color palette, korean traditional aesthetic, ink painting style, dark fantasy, occult atmosphere, sharp pixels, clean edges, no anti-aliasing",
  "common_negative": "blurry, smooth gradients, 3d render, realistic photo, anti-aliasing, soft edges, watermark, signature, low quality, jpeg artifacts, deformed, text, letters",
  "palette": [
    {"name": "ink_black",    "hex": "#1A1A2E"},
    {"name": "ink_gray",     "hex": "#2D2D44"},
    {"name": "hanji_beige",  "hex": "#F5E6CA"},
    {"name": "blood_red",    "hex": "#C41E3A"},
    {"name": "ghost_blue",   "hex": "#00D4FF"},
    {"name": "ghost_green",  "hex": "#39FF14"},
    {"name": "gold",         "hex": "#FFD700"},
    {"name": "purple",       "hex": "#6B2D5B"},
    {"name": "white",        "hex": "#E8E8E8"}
  ],
  "output_base": "../Assets/Art"
}
```

### 4.2 카드 설정 예시 (`config/cards.json`)

```json
{
  "type": "cards",
  "generation": {
    "model": "v1-5-pruned",
    "lora": "<lora:pixelart-style:0.8>",
    "width": 512,
    "height": 768,
    "steps": 35,
    "cfg_scale": 8,
    "sampler": "DPM++ 2M Karras",
    "batch_count": 4
  },
  "postprocess": {
    "target_width": 128,
    "target_height": 192,
    "resize_method": "nearest",
    "apply_palette": true,
    "remove_background": true,
    "add_frame": true
  },
  "output_dir": "Cards/Fronts",
  "items": [
    {
      "id": "m01_gwang",
      "name": "1월 광",
      "prompt": "hwatu card illustration, skeletal pine tree with twisted dead branches, ghost crane with glowing cyan eyes perched on top, dark underworld atmosphere, moonlight through bones, ink wash style",
      "frame": "gwang",
      "seed": 1001
    },
    {
      "id": "m01_tti_hongdan",
      "name": "1월 홍단",
      "prompt": "hwatu card illustration, skeletal pine tree, red ribbon with mystical writing floating between branches, dark mist, blood red accents, ink wash style",
      "frame": "tti_hong",
      "seed": 1002
    },
    {
      "id": "m01_pi_1",
      "name": "1월 피1",
      "prompt": "hwatu card illustration, small skeletal pine branch, simple dark composition, single dead pine needle cluster, minimal ink wash style",
      "frame": "pi",
      "seed": 1003
    },
    {
      "id": "m01_pi_2",
      "name": "1월 피2",
      "prompt": "hwatu card illustration, small skeletal pine branch, withered pine cone, simple dark composition, minimal ink wash style",
      "frame": "pi",
      "seed": 1004
    },
    {
      "id": "m02_tti_hongdan",
      "name": "2월 홍단",
      "prompt": "hwatu card illustration, blood-red plum blossoms on dark branches, red ribbon with cursed text, raven silhouette, dark mist, ink wash style",
      "frame": "tti_hong",
      "seed": 2001
    },
    {
      "id": "m02_pi_1",
      "name": "2월 피1",
      "prompt": "hwatu card illustration, single blood-red plum blossom branch, dark background, minimal composition, ink wash style",
      "frame": "pi",
      "seed": 2002
    }
  ]
}
```

> 48장 전체를 이 형식으로 정의한다. `prompt`만 바꾸면 됨.

### 4.3 캐릭터 설정 예시 (`config/characters.json`)

```json
{
  "type": "characters",
  "generation": {
    "model": "sd_xl_base_1.0",
    "lora": "<lora:pixel-art-xl:0.7>",
    "width": 768,
    "height": 1152,
    "steps": 40,
    "cfg_scale": 7,
    "sampler": "DPM++ 2M Karras",
    "batch_count": 4
  },
  "postprocess": {
    "target_width": 192,
    "target_height": 288,
    "resize_method": "nearest",
    "apply_palette": false,
    "remove_background": true,
    "add_frame": false
  },
  "items": [
    {
      "id": "mukbo_laugh_pose1",
      "name": "먹보 도깨비 — 웃음 포즈1",
      "prompt": "pixel art character, full body, gluttonous dokkaebi korean goblin, fat round body, huge mouth with sharp teeth, holding food, orange and blood red color scheme, dark fantasy korean folklore, thick ink outlines, laughing expression, menacing yet comedic",
      "output_dir": "Characters/Bosses/Mukbo",
      "seed": 5001
    },
    {
      "id": "mukbo_eating_pose1",
      "name": "먹보 도깨비 — 먹는 포즈1",
      "prompt": "pixel art character, full body, gluttonous dokkaebi korean goblin, fat round body, huge mouth with sharp teeth, eating ravenously, orange and blood red color scheme, dark fantasy korean folklore, thick ink outlines, greedy expression",
      "output_dir": "Characters/Bosses/Mukbo",
      "seed": 5001
    }
  ]
}
```

### 4.4 배경 설정 예시 (`config/backgrounds.json`)

```json
{
  "type": "backgrounds",
  "generation": {
    "model": "sd_xl_base_1.0",
    "lora": "<lora:pixel-art-xl:0.5>",
    "width": 1280,
    "height": 720,
    "steps": 50,
    "cfg_scale": 7,
    "sampler": "DPM++ 2M Karras",
    "batch_count": 4
  },
  "postprocess": {
    "target_width": 2560,
    "target_height": 1440,
    "resize_method": "nearest",
    "apply_palette": false,
    "remove_background": false,
    "add_frame": false
  },
  "items": [
    {
      "id": "main_menu_sanzu",
      "name": "메인 메뉴 — 삼도천",
      "prompt": "pixel art game background, wide landscape, Sanzu River korean underworld river crossing, thick mist over dark water, blue ghost fire floating, silhouette of old wooden boat, distant mountains, ink painting atmosphere, dark navy sky, cyan ghost lights, eerie calm",
      "output_dir": "Backgrounds/MainMenu",
      "seed": 9001
    },
    {
      "id": "area01_market",
      "name": "1영역 — 저승시장",
      "prompt": "pixel art game background, wide landscape, korean ghost night market, paper lanterns glowing warm orange, ghostly vendor silhouettes, wooden stalls with mystical items, smoke and mist, dark alley atmosphere, ink painting style",
      "output_dir": "Backgrounds/Area01_Market",
      "seed": 9002
    }
  ]
}
```

---

## 5. SD API 래퍼 (`sd_api.py`)

```python
"""
SD WebUI API 래퍼 — 이 파일 하나로 SD와 통신한다.
사용법: sd_api.py를 직접 실행하지 않고, generate.py에서 import하여 사용.
"""

import requests
import base64
import json
import io
from pathlib import Path
from PIL import Image

class StableDiffusionAPI:
    def __init__(self, url="http://127.0.0.1:7860"):
        self.url = url

    def set_model(self, model_name: str):
        """체크포인트 모델 전환"""
        payload = {"sd_model_checkpoint": model_name}
        requests.post(f"{self.url}/sdapi/v1/options", json=payload)

    def txt2img(self, prompt: str, negative: str, width: int, height: int,
                steps: int = 35, cfg_scale: float = 8, sampler: str = "DPM++ 2M Karras",
                seed: int = -1, batch_size: int = 1, lora: str = "") -> list[Image.Image]:
        """txt2img 생성 — 프롬프트만 넣으면 이미지 리스트 반환"""
        full_prompt = f"{prompt}, {lora}" if lora else prompt

        payload = {
            "prompt": full_prompt,
            "negative_prompt": negative,
            "width": width,
            "height": height,
            "steps": steps,
            "cfg_scale": cfg_scale,
            "sampler_name": sampler,
            "seed": seed,
            "batch_size": batch_size
        }
        r = requests.post(f"{self.url}/sdapi/v1/txt2img", json=payload)
        r.raise_for_status()

        images = []
        for img_b64 in r.json()["images"]:
            img = Image.open(io.BytesIO(base64.b64decode(img_b64)))
            images.append(img)
        return images

    def img2img(self, init_image: Image.Image, prompt: str, negative: str,
                denoising: float = 0.5, steps: int = 30, cfg_scale: float = 7,
                seed: int = -1, lora: str = "") -> list[Image.Image]:
        """img2img — 기존 이미지 기반 변형"""
        buffered = io.BytesIO()
        init_image.save(buffered, format="PNG")
        img_b64 = base64.b64encode(buffered.getvalue()).decode()

        full_prompt = f"{prompt}, {lora}" if lora else prompt

        payload = {
            "init_images": [img_b64],
            "prompt": full_prompt,
            "negative_prompt": negative,
            "denoising_strength": denoising,
            "steps": steps,
            "cfg_scale": cfg_scale,
            "seed": seed,
            "width": init_image.width,
            "height": init_image.height
        }
        r = requests.post(f"{self.url}/sdapi/v1/img2img", json=payload)
        r.raise_for_status()

        images = []
        for img_b64 in r.json()["images"]:
            img = Image.open(io.BytesIO(base64.b64decode(img_b64)))
            images.append(img)
        return images

    def ping(self) -> bool:
        """SD 서버 상태 확인"""
        try:
            r = requests.get(f"{self.url}/sdapi/v1/sd-models", timeout=5)
            return r.status_code == 200
        except:
            return False
```

---

## 6. 자동 후처리 (`postprocess.py`)

```python
"""
후처리 자동화 — SD 출력을 게임용 최종 스프라이트로 변환.
수동 편집 도구 없이 모든 처리를 수행한다.
"""

from PIL import Image, ImageDraw
import numpy as np

# 게임 팔레트 (RGB)
DOKKAEBI_PALETTE = [
    (26, 26, 46),     # ink_black    #1A1A2E
    (45, 45, 68),     # ink_gray     #2D2D44
    (245, 230, 202),  # hanji_beige  #F5E6CA
    (196, 30, 58),    # blood_red    #C41E3A
    (0, 212, 255),    # ghost_blue   #00D4FF
    (57, 255, 20),    # ghost_green  #39FF14
    (255, 215, 0),    # gold         #FFD700
    (107, 45, 91),    # purple       #6B2D5B
    (232, 232, 232),  # white        #E8E8E8
    (0, 0, 0, 0),     # transparent
]

# 카드 프레임 색상 정의
FRAME_COLORS = {
    "gwang":     (255, 215, 0),    # 금색
    "tti_hong":  (196, 30, 58),    # 홍단 빨강
    "tti_cheong":(0, 212, 255),    # 청단 파랑
    "tti_cho":   (57, 255, 20),    # 초단 초록
    "yeolkkeut": (135, 206, 235),  # 열끗 하늘색
    "pi":        (150, 150, 150),  # 피 회색
}

FRAME_SYMBOLS = {
    "gwang": "★",
    "tti_hong": "═", "tti_cheong": "═", "tti_cho": "═",
    "yeolkkeut": "◆",
    "pi": "●",
}


def resize_nearest(img: Image.Image, target_w: int, target_h: int) -> Image.Image:
    """Nearest Neighbor 리사이즈 — 픽셀 경계 유지"""
    return img.resize((target_w, target_h), Image.NEAREST)


def apply_palette(img: Image.Image, palette: list = DOKKAEBI_PALETTE) -> Image.Image:
    """가장 가까운 팔레트 색상으로 모든 픽셀을 매핑"""
    img_rgba = img.convert("RGBA")
    pixels = np.array(img_rgba)

    palette_rgb = np.array([c[:3] for c in palette if len(c) >= 3])

    h, w, _ = pixels.shape
    flat = pixels[:, :, :3].reshape(-1, 3).astype(np.float32)

    # 각 픽셀에서 가장 가까운 팔레트 색 찾기
    distances = np.linalg.norm(flat[:, None] - palette_rgb[None, :], axis=2)
    nearest_idx = np.argmin(distances, axis=1)

    new_pixels = palette_rgb[nearest_idx].reshape(h, w, 3).astype(np.uint8)

    # 알파 채널 유지
    result = np.dstack([new_pixels, pixels[:, :, 3]])
    return Image.fromarray(result, "RGBA")


def remove_background(img: Image.Image) -> Image.Image:
    """rembg로 배경 자동 제거"""
    from rembg import remove
    return remove(img)


def add_card_frame(img: Image.Image, frame_type: str) -> Image.Image:
    """카드에 타입별 프레임(테두리) 자동 추가"""
    color = FRAME_COLORS.get(frame_type, (150, 150, 150))
    w, h = img.size
    border = max(2, w // 26)  # 비율 기반 테두리 두께

    framed = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    draw = ImageDraw.Draw(framed)

    # 테두리 그리기
    draw.rectangle([0, 0, w-1, h-1], outline=color, width=border)

    # 내부에 원본 이미지 합성
    inner = img.crop((border, border, w-border, h-border))
    framed.paste(inner, (border, border))

    # 테두리 다시 그리기 (위에 덮기)
    draw = ImageDraw.Draw(framed)
    draw.rectangle([0, 0, w-1, h-1], outline=color, width=border)

    return framed


def full_postprocess(img: Image.Image, config: dict) -> Image.Image:
    """설정에 따라 전체 후처리 파이프라인 실행"""
    # 1. 배경 제거
    if config.get("remove_background", False):
        img = remove_background(img)

    # 2. Nearest Neighbor 리사이즈
    target_w = config.get("target_width", img.width)
    target_h = config.get("target_height", img.height)
    if config.get("resize_method") == "nearest":
        img = resize_nearest(img, target_w, target_h)

    # 3. 팔레트 제한
    if config.get("apply_palette", False):
        img = apply_palette(img)

    # 4. 카드 프레임 추가
    if config.get("add_frame", False) and config.get("frame_type"):
        img = add_card_frame(img, config["frame_type"])

    return img
```

---

## 7. 마스터 실행 스크립트 (`generate.py`)

```python
#!/usr/bin/env python3
"""
도깨비의 패 — 에셋 자동 생성 마스터 스크립트

사용법:
  python generate.py --all                    # 전체 에셋 생성
  python generate.py --type cards             # 카드만 생성
  python generate.py --type characters        # 캐릭터만 생성
  python generate.py --type backgrounds       # 배경만 생성
  python generate.py --type talismans         # 부적만 생성
  python generate.py --type ui               # UI만 생성
  python generate.py --type cards --id m01_gwang  # 특정 카드 1장만 생성
  python generate.py --type cards --pick      # 배치 생성 후 최선 선택 모드
"""

import argparse
import json
import sys
from pathlib import Path
from sd_api import StableDiffusionAPI
from postprocess import full_postprocess

SCRIPT_DIR = Path(__file__).parent
CONFIG_DIR = SCRIPT_DIR / "config"
OUTPUT_DIR = SCRIPT_DIR / "output"


def load_config(config_type: str) -> dict:
    common = json.loads((CONFIG_DIR / "common.json").read_text())
    specific = json.loads((CONFIG_DIR / f"{config_type}.json").read_text())
    return {**specific, "common": common}


def generate_asset(sd: StableDiffusionAPI, item: dict, gen_config: dict,
                   post_config: dict, common: dict, output_base: Path):
    """단일 에셋 생성 + 후처리 + 저장"""
    # 프롬프트 조합
    full_prompt = f"{common['common_positive']}, {item['prompt']}"
    if gen_config.get("lora"):
        full_prompt += f", {gen_config['lora']}"

    full_negative = common["common_negative"]

    print(f"  생성 중: {item['name']} (seed: {item.get('seed', -1)})")

    # SD API 호출
    images = sd.txt2img(
        prompt=full_prompt,
        negative=full_negative,
        width=gen_config["width"],
        height=gen_config["height"],
        steps=gen_config["steps"],
        cfg_scale=gen_config["cfg_scale"],
        sampler=gen_config["sampler"],
        seed=item.get("seed", -1),
        batch_size=gen_config.get("batch_count", 1)
    )

    # 후처리 설정
    proc_config = {**post_config}
    if item.get("frame"):
        proc_config["frame_type"] = item["frame"]

    # 출력 경로
    out_dir = output_base / item.get("output_dir", post_config.get("output_dir", ""))
    out_dir.mkdir(parents=True, exist_ok=True)

    # 배치에서 첫 번째 사용 (또는 --pick 모드에서 선택)
    for i, img in enumerate(images):
        processed = full_postprocess(img, proc_config)

        if len(images) == 1:
            filename = f"{item['id']}.png"
        else:
            filename = f"{item['id']}_v{i}.png"

        processed.save(out_dir / filename, "PNG")
        print(f"    → 저장: {out_dir / filename}")

    # 배치 1장일 때는 바로 최종 저장
    if len(images) == 1:
        # Unity 폴더에도 복사
        unity_dir = SCRIPT_DIR.parent / "Assets" / "Art" / item.get("output_dir", "")
        unity_dir.mkdir(parents=True, exist_ok=True)
        processed.save(unity_dir / f"{item['id']}.png", "PNG")


def run(args):
    # 설정 로드
    config = load_config(args.type)
    common = config["common"]

    # SD 연결
    sd = StableDiffusionAPI(common["sd_url"])
    if not sd.ping():
        print("❌ SD WebUI에 연결할 수 없습니다.")
        print(f"   {common['sd_url']} 에서 --api 모드로 실행 중인지 확인하세요.")
        sys.exit(1)
    print("✅ SD WebUI 연결 성공")

    # 모델 전환
    model = config["generation"].get("model")
    if model:
        print(f"  모델 전환: {model}")
        sd.set_model(model)

    # 출력 베이스
    output_base = SCRIPT_DIR / "output"

    # 대상 아이템 필터
    items = config["items"]
    if args.id:
        items = [i for i in items if i["id"] == args.id]
        if not items:
            print(f"❌ ID '{args.id}'를 찾을 수 없습니다.")
            sys.exit(1)

    print(f"\n🎨 {config['type']} 생성 시작 ({len(items)}개)")
    print("=" * 50)

    for item in items:
        generate_asset(sd, item, config["generation"],
                       config["postprocess"], common, output_base)

    print("=" * 50)
    print(f"✅ 완료! {len(items)}개 에셋 생성됨")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="도깨비의 패 에셋 자동 생성")
    parser.add_argument("--all", action="store_true", help="전체 에셋 생성")
    parser.add_argument("--type", choices=["cards", "characters", "backgrounds", "talismans", "ui"],
                        help="에셋 타입 선택")
    parser.add_argument("--id", type=str, help="특정 에셋 ID만 생성")
    parser.add_argument("--pick", action="store_true", help="배치 생성 후 최선 선택 모드")
    args = parser.parse_args()

    if args.all:
        for t in ["cards", "characters", "backgrounds", "talismans", "ui"]:
            args.type = t
            run(args)
    elif args.type:
        run(args)
    else:
        parser.print_help()
```

---

## 8. 실행 명령어 모음 (복사해서 쓰면 됨)

### 8.1 최초 세팅

```bash
# 파이프라인 폴더 생성 & 의존성 설치
cd dokkaebi-hand
mkdir -p sd-pipeline/config sd-pipeline/output sd-pipeline/palette
pip install Pillow rembg requests numpy
```

### 8.2 SD 서버 실행 (별도 터미널)

```bash
cd stable-diffusion-webui
./webui.sh --api --listen --port 7860
```

### 8.3 에셋 생성 명령어

```bash
cd dokkaebi-hand/sd-pipeline

# === 전체 생성 (모든 에셋) ===
python generate.py --all

# === 카테고리별 생성 ===
python generate.py --type cards           # 화투 카드 48장
python generate.py --type characters      # 캐릭터 46장
python generate.py --type backgrounds     # 배경 7종
python generate.py --type talismans       # 부적 아이콘
python generate.py --type ui             # UI 텍스처

# === 개별 에셋 생성 ===
python generate.py --type cards --id m01_gwang          # 1월 광 카드만
python generate.py --type characters --id mukbo_laugh   # 먹보 웃음만

# === 배치 비교 모드 (4장 생성해서 골라쓰기) ===
python generate.py --type cards --id m01_gwang --pick
```

### 8.4 결과물 Unity에 일괄 복사

```bash
# output → Assets/Art 로 최종 복사 (generate.py가 자동으로 하지만 수동 실행도 가능)
cp -r sd-pipeline/output/Cards/* Assets/Art/Cards/
cp -r sd-pipeline/output/Characters/* Assets/Art/Characters/
cp -r sd-pipeline/output/Backgrounds/* Assets/Art/Backgrounds/
```

---

## 9. 카드 48장 전체 프롬프트 정의

### 명령 하나로 48장 생성하기 위한 전체 목록

| ID | 월 | 타입 | 프롬프트 핵심 |
|----|---|------|-------------|
| `m01_gwang` | 1 | 광 | skeletal pine, ghost crane, glowing eyes, moonlight |
| `m01_tti_hongdan` | 1 | 홍단 | skeletal pine, red ribbon, cursed text |
| `m01_pi_1` | 1 | 피 | small skeletal pine branch |
| `m01_pi_2` | 1 | 피 | withered pine cone |
| `m02_tti_hongdan` | 2 | 홍단 | blood-red plum blossoms, raven, red ribbon |
| `m02_pi_1~3` | 2 | 피×3 | blood plum branches (각각 다른 구도) |
| `m03_gwang` | 3 | 광 | higanbana (피안화), crimson curtain veil |
| `m03_tti_hongdan` | 3 | 홍단 | higanbana, red ribbon |
| `m03_pi_1~2` | 3 | 피×2 | scattered higanbana petals |
| `m04_tti_chodan` | 4 | 초단 | black vines (검은 덩굴), spirit bird, green ribbon |
| `m04_pi_1~3` | 4 | 피×3 | dark hanging vines |
| `m05_tti_chodan` | 5 | 초단 | underworld orchid, Sanzu River bridge, green ribbon |
| `m05_pi_1~3` | 5 | 피×3 | pale orchid petals |
| `m06_tti_cheongdan` | 6 | 청단 | ghost peony, spirit butterfly, blue ribbon |
| `m06_pi_1~3` | 6 | 피×3 | fading peony |
| `m07_tti_cheongdan` | 7 | 청단 | flame vines (화염 덩굴), hell boar silhouette, blue ribbon |
| `m07_pi_1~3` | 7 | 피×3 | burning vine fragments |
| `m08_gwang` | 8 | 광 | reeds in wind, blood moon (적월), ominous red glow |
| `m08_yeolkkeut` | 8 | 열끗 | flying geese under blood moon |
| `m08_pi_1~2` | 8 | 피×2 | reed stalks |
| `m09_tti_cheongdan` | 9 | 청단 | underworld chrysanthemum, wanderer's cup, blue ribbon |
| `m09_pi_1~3` | 9 | 피×3 | wilting chrysanthemum |
| `m10_tti_chodan` | 10 | 초단 | blood-red maple leaves, skeletal deer, green ribbon |
| `m10_pi_1~3` | 10 | 피×3 | falling blood maple leaves |
| `m11_gwang` | 11 | 광 | immortal paulownia tree, hell phoenix in flames |
| `m11_tti_hongdan` | 11 | 홍단 | paulownia leaves, red ribbon |
| `m11_pi_1~2` | 11 | 피×2 | paulownia seed pods |
| `m12_gwang` | 12 | 광 | blood rain falling, death messenger (사신) figure |
| `m12_tti_hongdan` | 12 | 홍단 | rain streaks, red umbrella, red ribbon |
| `m12_pi_1~2` | 12 | 피×2 | rain drops, dark puddles |

---

## 10. 캐릭터 46장 자동 생성 전략

### 한 캐릭터의 표정/포즈 변형 자동화

```
기본 원리:
1. 기본 포즈를 txt2img로 생성 (seed 고정)
2. 표정 변형은 img2img + 프롬프트 변경으로 자동 생성
3. seed 동일 → 같은 캐릭터, 프롬프트만 바꿈 → 표정만 변화
```

```json
{
  "character": "mukbo",
  "base_seed": 5001,
  "base_prompt": "pixel art character, full body, gluttonous dokkaebi korean goblin, fat round body, huge mouth with sharp teeth, orange and blood red color scheme, dark fantasy korean folklore, thick ink outlines",
  "variations": [
    {"suffix": "laugh_pose1",  "add": "laughing expression, arms wide open"},
    {"suffix": "eating_pose1", "add": "eating ravenously, holding food"},
    {"suffix": "surprise_pose1", "add": "shocked expression, eyes wide, mouth open"},
    {"suffix": "anger_pose1",  "add": "furious expression, clenched fists, veins visible"},
    {"suffix": "laugh_pose2",  "add": "laughing expression, leaning forward, belly jiggling"},
    {"suffix": "eating_pose2", "add": "eating expression, sitting cross-legged, plates around"},
    {"suffix": "surprise_pose2", "add": "shocked expression, jumping back, arms up"},
    {"suffix": "anger_pose2",  "add": "furious expression, slamming table, dark aura"}
  ]
}
```

---

## 11. 배경 7종 자동 생성

배경은 배경 제거 없이, 해상도만 조절하면 된다.

```bash
# 배경 전체 생성 (7종 × 4배치 = 28장 중 선택)
python generate.py --type backgrounds

# 특정 배경만 재생성
python generate.py --type backgrounds --id area01_market
```

배경은 **1280×720으로 생성 → Nearest Neighbor로 2560×1440 업스케일**.
이렇게 하면 자연스러운 픽셀아트 느낌이 유지된다.

---

## 12. 부적 아이콘 자동 생성

```bash
# 부적 아이콘 전체 생성
python generate.py --type talismans
```

64×64 최종 크기. 256×256으로 생성 → 다운스케일.
등급별 색상 자동 적용 (postprocess에서 프레임 색 입힘).

---

## 13. 품질 관리 자동화

### 13.1 배치 비교 스크립트 (선택용)

```bash
# 4장 생성 → output/에 v0~v3으로 저장 → 터미널에서 미리보기
python generate.py --type cards --id m01_gwang --pick

# macOS에서 이미지 바로 열기
open sd-pipeline/output/Cards/Fronts/m01_gwang_v*.png
```

마음에 드는 버전을 고른 뒤:
```bash
# v2를 최종 선택
cp sd-pipeline/output/Cards/Fronts/m01_gwang_v2.png Assets/Art/Cards/Fronts/m01_gwang.png
```

### 13.2 일괄 재생성 (불만족 시)

```bash
# seed만 바꿔서 같은 에셋 다시 생성
python generate.py --type cards --id m01_gwang  # config에서 seed 변경 후 재실행
```

---

## 14. Unity 임포트 설정

모든 생성된 PNG는 아래 설정으로 자동 임포트되도록 Unity에서 프리셋 설정:

```
Texture Type:    Sprite (2D and UI)
Sprite Mode:     Single
Pixels Per Unit: 100
Filter Mode:     Point (no filter)     ← 필수!
Compression:     None                  ← 픽셀아트 손상 방지
Max Size:        2048
```

> **팁:** Unity Editor 스크립트(`AssetPostprocessor`)로 Art/ 폴더 하위 파일에
> 자동으로 위 설정을 적용할 수 있다. 이것도 명령 하나로 끝남.

---

## 15. 디렉토리 구조 (최종)

```
dokkaebi-hand/
  sd-pipeline/                    ← 자동화 파이프라인 (Git 추적)
    generate.py                   ← 마스터 명령 스크립트
    sd_api.py                     ← SD API 래퍼
    postprocess.py                ← 후처리 자동화
    config/                       ← JSON 설정 파일
      common.json
      cards.json                  ← 48장 프롬프트
      characters.json             ← 46장 프롬프트
      backgrounds.json            ← 7종 프롬프트
      talismans.json
      ui.json
    output/                       ← SD 원본 출력 (.gitignore)
  Assets/Art/                     ← Unity 최종 에셋 (Git 추적, LFS)
    Cards/Fronts/                 ← 카드 앞면 48장
    Cards/Backs/                  ← 카드 뒷면 1장
    Characters/Bosses/Mukbo/      ← 캐릭터 스프라이트
    Characters/Bosses/Trickster/
    Characters/Bosses/Flame/
    Characters/Bosses/Shadow/
    Characters/Bosses/Yama/
    Characters/Protagonist/
    Characters/NPCs/
    Backgrounds/                  ← 배경 7종
    Talismans/                    ← 부적 아이콘
    UI/                           ← UI 텍스처
```

---

## 16. 요약 — 명령 하달 흐름

```
1. SD 서버 켜기
   $ ./webui.sh --api

2. 원하는 에셋 생성 명령
   $ python generate.py --all              ← 전체
   $ python generate.py --type cards       ← 카드만
   $ python generate.py --type cards --id m01_gwang  ← 1장만

3. 결과 확인
   $ open Assets/Art/Cards/Fronts/m01_gwang.png

4. 불만족 시 → config/cards.json에서 프롬프트/seed 수정 → 재실행
```

**수동 작업 = 0. 프롬프트 수정 + 명령 실행만 반복.**

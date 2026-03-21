# ComfyUI 아트 파이프라인 계획서

## 1. 목표

**ComfyUI 워크플로우 + Python API**로 모든 게임 에셋을 **일관성 있게** 생성한다.
노드 기반 워크플로우를 JSON으로 저장하고, 프롬프트만 바꿔서 반복 생성한다.

```
워크플로우 JSON + 프롬프트 → ComfyUI API → 자동 후처리 → Assets/Art/ 배치
```

### A1111 대비 ComfyUI 장점

| 항목 | A1111 | ComfyUI |
|------|-------|---------|
| Mac Metal 가속 | 느림 | **네이티브 MPS, 빠름** |
| 워크플로우 재사용 | 불가 | **JSON 저장/로드** |
| 일관성 제어 | 프롬프트 의존 | **ControlNet + IP-Adapter 노드** |
| 배치 자동화 | REST API | **REST API + 노드 조합** |
| 메모리 효율 | 보통 | **우수 (18GB M3 Pro 최적)** |

---

## 2. 자동화 아키텍처

### 2.1 전체 흐름

```
┌──────────────────────────────────────────────────────┐
│                    generate.py                        │
│  (마스터 스크립트 — 명령 하나로 전체 실행)              │
├──────────────────────────────────────────────────────┤
│                                                       │
│  1. workflows/*.json  ← 에셋별 ComfyUI 워크플로우      │
│  2. config/*.json     ← 에셋별 프롬프트/설정 정의        │
│         ↓                                             │
│  3. ComfyUI API       ← /prompt 엔드포인트 호출         │
│         ↓                                             │
│  4. postprocess.py    ← 리사이즈, 팔레트 제한, 배경 제거  │
│         ↓                                             │
│  5. Assets/Art/       ← 최종 배치                       │
│                                                       │
└──────────────────────────────────────────────────────┘
```

### 2.2 필요 환경

| 구성요소 | 역할 | 설치 방법 |
|---------|------|----------|
| **ComfyUI** | 이미지 생성 서버 | `git clone` + `python main.py` |
| **Python 3.11** | 자동화 스크립트 | pyenv (3.13 호환 이슈 회피) |
| **Pillow (PIL)** | 이미지 후처리 | `pip install Pillow` |
| **rembg** | 자동 배경 제거 | `pip install rembg` |
| **websocket-client** | ComfyUI 실시간 상태 | `pip install websocket-client` |

> **핵심:** ComfyUI를 실행하면 `http://127.0.0.1:8188`에 API가 열린다.
> `/prompt` 엔드포인트로 워크플로우 JSON을 전송하면 이미지가 생성된다.

---

## 3. 환경 세팅

### 3.1 ComfyUI 실행 (설치는 setup-guide 참조)

```bash
cd ~/Desktop/ComfyUI
source venv/bin/activate
python main.py --listen --port 8188
```

### 3.2 프로젝트 스크립트 구조

```
dokkaebi-hand/
  sd-pipeline/
    generate.py              ← 마스터 실행 스크립트
    comfy_api.py             ← ComfyUI API 래퍼
    postprocess.py           ← 후처리 (리사이즈, 팔레트, 배경 제거)
    workflows/               ← ComfyUI 워크플로우 JSON
      card_base.json         ← 카드 생성 워크플로우
      character_base.json    ← 캐릭터 생성 워크플로우
      character_variation.json ← 표정/포즈 변형 (img2img)
      background_base.json   ← 배경 생성 워크플로우
      talisman_base.json     ← 부적 아이콘 워크플로우
    config/
      cards.json             ← 카드 48장 프롬프트 정의
      characters.json        ← 캐릭터 46장 프롬프트 정의
      backgrounds.json       ← 배경 7종 프롬프트 정의
      talismans.json         ← 부적 아이콘 프롬프트 정의
      style_guide.json       ← 공통 스타일 토큰 + 네거티브
    palette/
      dokkaebi_palette.png   ← 9색 팔레트 이미지
    reference/               ← IP-Adapter 참조 이미지 (스타일 고정용)
      style_ref_card.png     ← 카드 스타일 참조
      style_ref_boss.png     ← 보스 스타일 참조
    output/                  ← 중간 출력 (.gitignore)
```

---

## 4. 일관성 확보 전략

### 4.1 문제: "같은 프롬프트인데 매번 다른 느낌"

단순 프롬프트만으로는 일관된 스타일을 유지할 수 없다. ComfyUI의 노드 조합으로 해결한다.

### 4.2 해결: 3단계 일관성 레이어

```
Layer 1: 스타일 토큰 고정 (프롬프트 프리픽스)
  → 모든 프롬프트 앞에 동일한 스타일 문구 강제 삽입

Layer 2: LoRA 가중치 고정
  → 픽셀아트 LoRA를 정확한 가중치로 항상 적용

Layer 3: IP-Adapter (스타일 참조 이미지)
  → 수동으로 "이 느낌"인 참조 이미지 1장을 지정
  → 모든 생성에 스타일 참조로 주입 → 톤/질감 통일
```

### 4.3 스타일 토큰 체계 (`config/style_guide.json`)

```json
{
  "comfyui_url": "http://127.0.0.1:8188",

  "style_prefix": {
    "all": "pixel art, retro 16-bit RPG style, limited color palette, sharp pixels, clean edges, no anti-aliasing, no smooth gradients, thick black outlines",
    "card": "hwatu card illustration, centered composition, dark background, ink wash texture, single subject",
    "character": "full body character sprite, front-facing, symmetrical pose, transparent background, thick ink outlines",
    "background": "wide landscape, atmospheric perspective, layered parallax depth, subtle pixel dithering",
    "talisman": "small icon, centered object, simple silhouette, glowing edges, dark background"
  },

  "style_suffix": {
    "all": "korean underworld aesthetic, dark fantasy, occult ink painting atmosphere, muted earth tones with cyan and crimson accents"
  },

  "negative": {
    "all": "blurry, smooth shading, soft edges, anti-aliasing, 3d render, realistic photo, watermark, signature, text, letters, jpeg artifacts, deformed, extra limbs, bad anatomy, low quality, oversaturated, neon colors",
    "card": "multiple subjects, busy composition, white background, modern style",
    "character": "cropped, partial body, background scenery, multiple characters",
    "background": "characters, text overlay, UI elements, close-up"
  },

  "palette": [
    {"name": "ink_black",    "hex": "#1A1A2E", "usage": "배경, 윤곽선"},
    {"name": "ink_gray",     "hex": "#2D2D44", "usage": "그림자, 부배경"},
    {"name": "hanji_beige",  "hex": "#F5E6CA", "usage": "피부, 종이, 하이라이트"},
    {"name": "blood_red",    "hex": "#C41E3A", "usage": "홍단, 피, 위험"},
    {"name": "ghost_cyan",   "hex": "#00D4FF", "usage": "귀신불, 청단, 정보"},
    {"name": "ghost_green",  "hex": "#39FF14", "usage": "초단, 독, 자연"},
    {"name": "gold",         "hex": "#FFD700", "usage": "광, 보상, 강조"},
    {"name": "purple",       "hex": "#6B2D5B", "usage": "저주, 봉인, 전설"},
    {"name": "bone_white",   "hex": "#E8E8E8", "usage": "뼈, 귀신, 텍스트"}
  ],

  "lora": {
    "sd15": {
      "name": "pixelart-style",
      "weight": 0.75,
      "trigger": "pixel art style"
    },
    "sdxl": {
      "name": "pixel-art-xl",
      "weight": 0.65,
      "trigger": "pixel art"
    }
  },

  "ip_adapter": {
    "enabled": true,
    "weight": 0.35,
    "noise": 0.1,
    "comment": "너무 높으면 참조 이미지 복사, 0.3~0.4가 스타일만 전이"
  }
}
```

---

## 5. ComfyUI 워크플로우 설계

### 5.1 카드 워크플로우 (`workflows/card_base.json`)

노드 구성:

```
[KSampler]
  ├── model ← [CheckpointLoader] → SD 1.5
  │            └── [LoraLoader] → pixelart-style (0.75)
  │                 └── [IPAdapterApply] → style_ref_card.png (0.35)
  ├── positive ← [CLIPTextEncode] → style_prefix.all + style_prefix.card + item.prompt + style_suffix.all
  ├── negative ← [CLIPTextEncode] → negative.all + negative.card
  ├── latent_image ← [EmptyLatentImage] → 512×768
  └── settings: steps=35, cfg=7.5, sampler=dpmpp_2m, scheduler=karras, seed=item.seed

[VAEDecode] → [SaveImage]
```

### 5.2 캐릭터 워크플로우 (`workflows/character_base.json`)

```
[KSampler]
  ├── model ← [CheckpointLoader] → SDXL Base
  │            └── [LoraLoader] → pixel-art-xl (0.65)
  │                 └── [IPAdapterApply] → style_ref_boss.png (0.35)
  ├── positive ← [CLIPTextEncode] → style_prefix.all + style_prefix.character + item.prompt + style_suffix.all
  ├── negative ← [CLIPTextEncode] → negative.all + negative.character
  ├── latent_image ← [EmptyLatentImage] → 768×1152
  └── settings: steps=40, cfg=7, sampler=dpmpp_2m, scheduler=karras

[VAEDecode] → [SaveImage]
```

### 5.3 캐릭터 변형 워크플로우 (`workflows/character_variation.json`)

```
[KSampler]
  ├── model ← (동일)
  ├── positive ← base_prompt + variation.add
  ├── negative ← (동일)
  ├── latent_image ← [VAEEncode] ← [LoadImage] → base_pose 이미지
  └── settings: steps=30, cfg=7, denoise=0.45, seed=동일

→ 같은 캐릭터, 표정/포즈만 변경
```

### 5.4 배경 워크플로우 (`workflows/background_base.json`)

```
[KSampler]
  ├── model ← [CheckpointLoader] → SDXL Base
  │            └── [LoraLoader] → pixel-art-xl (0.5)
  ├── positive ← style_prefix.all + style_prefix.background + item.prompt + style_suffix.all
  ├── negative ← negative.all + negative.background
  ├── latent_image ← [EmptyLatentImage] → 1280×720
  └── settings: steps=50, cfg=7, sampler=dpmpp_2m, scheduler=karras

[VAEDecode] → [SaveImage]
```

### 5.5 부적 워크플로우 (`workflows/talisman_base.json`)

```
[KSampler]
  ├── model ← SD 1.5 + pixelart-style (0.8)
  ├── positive ← style_prefix.all + style_prefix.talisman + item.prompt + style_suffix.all
  ├── negative ← negative.all
  ├── latent_image ← [EmptyLatentImage] → 256×256
  └── settings: steps=30, cfg=8, sampler=dpmpp_2m, scheduler=karras

[VAEDecode] → [SaveImage]
```

---

## 6. 프롬프트 설계 원칙

### 6.1 프롬프트 조립 공식

```
최종 프롬프트 = style_prefix.all + style_prefix.{type} + item.prompt + style_suffix.all
최종 네거티브 = negative.all + negative.{type}
```

예시 — 1월 광 카드:
```
pixel art, retro 16-bit RPG style, limited color palette, sharp pixels, clean edges,
no anti-aliasing, no smooth gradients, thick black outlines,
hwatu card illustration, centered composition, dark background, ink wash texture, single subject,
skeletal pine tree with twisted dead branches, ghost crane with glowing cyan eyes,
dark underworld moonlight filtering through bones,
korean underworld aesthetic, dark fantasy, occult ink painting atmosphere,
muted earth tones with cyan and crimson accents
```

### 6.2 프롬프트 작성 규칙

1. **구체적 명사 우선** — "tree" 대신 "skeletal pine tree with twisted dead branches"
2. **색상 명시** — "blood red accents", "cyan ghost light", "golden glow"
3. **분위기 키워드** — "eerie", "ominous", "somber", "otherworldly"
4. **구도 지시** — "centered", "front-facing", "wide landscape", "close-up icon"
5. **금지어** — "realistic", "photograph", "3D", "modern", "cute", "anime"
6. **한 프롬프트 = 한 주제** — 카드 1장에 소나무 하나, 학 하나만

### 6.3 에셋별 프롬프트 강도 가이드

| 에셋 | CFG | LoRA 가중치 | IP-Adapter | 비고 |
|------|-----|-----------|------------|------|
| 카드 | 7.5 | 0.75 | 0.35 | 강한 픽셀 느낌, 참조 약하게 |
| 캐릭터 | 7.0 | 0.65 | 0.35 | 캐릭터 디테일 보존 |
| 배경 | 7.0 | 0.50 | 0.30 | 자연스러운 분위기 |
| 부적 | 8.0 | 0.80 | 0.40 | 작은 아이콘, 명확한 실루엣 |

---

## 7. ComfyUI API 래퍼 (`comfy_api.py`)

```python
"""
ComfyUI API 래퍼 — 워크플로우 JSON을 전송하고 결과 이미지를 수신한다.
"""

import json
import urllib.request
import urllib.parse
import uuid
import io
import websocket
from pathlib import Path
from PIL import Image


class ComfyUIAPI:
    def __init__(self, url="http://127.0.0.1:8188"):
        self.url = url
        self.client_id = str(uuid.uuid4())

    def queue_prompt(self, workflow: dict) -> str:
        """워크플로우를 큐에 등록하고 prompt_id 반환"""
        payload = {
            "prompt": workflow,
            "client_id": self.client_id
        }
        data = json.dumps(payload).encode("utf-8")
        req = urllib.request.Request(
            f"{self.url}/prompt",
            data=data,
            headers={"Content-Type": "application/json"}
        )
        resp = json.loads(urllib.request.urlopen(req).read())
        return resp["prompt_id"]

    def wait_for_result(self, prompt_id: str) -> list[Image.Image]:
        """WebSocket으로 생성 완료를 기다리고 결과 이미지 반환"""
        ws_url = f"ws://{self.url.split('//')[1]}/ws?clientId={self.client_id}"
        ws = websocket.WebSocket()
        ws.connect(ws_url)

        images = []
        try:
            while True:
                msg = json.loads(ws.recv())
                if msg["type"] == "executing":
                    data = msg["data"]
                    if data["node"] is None and data["prompt_id"] == prompt_id:
                        break  # 실행 완료
        finally:
            ws.close()

        # 히스토리에서 출력 이미지 가져오기
        history_url = f"{self.url}/history/{prompt_id}"
        history = json.loads(urllib.request.urlopen(history_url).read())

        outputs = history[prompt_id]["outputs"]
        for node_id in outputs:
            for img_data in outputs[node_id].get("images", []):
                img_url = f"{self.url}/view?{urllib.parse.urlencode(img_data)}"
                img_bytes = urllib.request.urlopen(img_url).read()
                img = Image.open(io.BytesIO(img_bytes))
                images.append(img)

        return images

    def generate(self, workflow: dict) -> list[Image.Image]:
        """워크플로우 전송 → 완료 대기 → 이미지 반환 (원스텝)"""
        prompt_id = self.queue_prompt(workflow)
        return self.wait_for_result(prompt_id)

    def load_workflow(self, path: str, overrides: dict = None) -> dict:
        """워크플로우 JSON 로드 + 프롬프트/seed 등 오버라이드"""
        wf = json.loads(Path(path).read_text())
        if overrides:
            for node_id, values in overrides.items():
                if node_id in wf:
                    wf[node_id]["inputs"].update(values)
        return wf

    def ping(self) -> bool:
        """ComfyUI 서버 상태 확인"""
        try:
            urllib.request.urlopen(f"{self.url}/system_stats", timeout=5)
            return True
        except Exception:
            return False
```

---

## 8. 자동 후처리 (`postprocess.py`)

```python
"""
후처리 자동화 — ComfyUI 출력을 게임용 최종 스프라이트로 변환.
"""

from PIL import Image, ImageDraw
import numpy as np

DOKKAEBI_PALETTE = [
    (26, 26, 46),     # ink_black    #1A1A2E
    (45, 45, 68),     # ink_gray     #2D2D44
    (245, 230, 202),  # hanji_beige  #F5E6CA
    (196, 30, 58),    # blood_red    #C41E3A
    (0, 212, 255),    # ghost_cyan   #00D4FF
    (57, 255, 20),    # ghost_green  #39FF14
    (255, 215, 0),    # gold         #FFD700
    (107, 45, 91),    # purple       #6B2D5B
    (232, 232, 232),  # bone_white   #E8E8E8
]

FRAME_COLORS = {
    "gwang":     (255, 215, 0),
    "tti_hong":  (196, 30, 58),
    "tti_cheong":(0, 212, 255),
    "tti_cho":   (57, 255, 20),
    "yeolkkeut": (135, 206, 235),
    "pi":        (150, 150, 150),
}


def resize_nearest(img, target_w, target_h):
    return img.resize((target_w, target_h), Image.NEAREST)


def apply_palette(img, palette=DOKKAEBI_PALETTE):
    img_rgba = img.convert("RGBA")
    pixels = np.array(img_rgba)
    palette_rgb = np.array(palette)
    h, w, _ = pixels.shape
    flat = pixels[:, :, :3].reshape(-1, 3).astype(np.float32)
    distances = np.linalg.norm(flat[:, None] - palette_rgb[None, :], axis=2)
    nearest_idx = np.argmin(distances, axis=1)
    new_pixels = palette_rgb[nearest_idx].reshape(h, w, 3).astype(np.uint8)
    result = np.dstack([new_pixels, pixels[:, :, 3]])
    return Image.fromarray(result, "RGBA")


def remove_background(img):
    from rembg import remove
    return remove(img)


def add_card_frame(img, frame_type):
    color = FRAME_COLORS.get(frame_type, (150, 150, 150))
    w, h = img.size
    border = max(2, w // 26)
    framed = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    draw = ImageDraw.Draw(framed)
    draw.rectangle([0, 0, w-1, h-1], outline=color, width=border)
    inner = img.crop((border, border, w-border, h-border))
    framed.paste(inner, (border, border))
    draw = ImageDraw.Draw(framed)
    draw.rectangle([0, 0, w-1, h-1], outline=color, width=border)
    return framed


def full_postprocess(img, config):
    if config.get("remove_background", False):
        img = remove_background(img)
    target_w = config.get("target_width", img.width)
    target_h = config.get("target_height", img.height)
    if config.get("resize_method") == "nearest":
        img = resize_nearest(img, target_w, target_h)
    if config.get("apply_palette", False):
        img = apply_palette(img)
    if config.get("add_frame", False) and config.get("frame_type"):
        img = add_card_frame(img, config["frame_type"])
    return img
```

---

## 9. 에셋별 설정

### 9.1 카드 (`config/cards.json`)

```json
{
  "type": "cards",
  "workflow": "workflows/card_base.json",
  "generation": {
    "model": "v1-5-pruned-emaonly",
    "lora": "pixelart-style",
    "lora_weight": 0.75,
    "width": 512,
    "height": 768,
    "steps": 35,
    "cfg_scale": 7.5,
    "sampler": "dpmpp_2m",
    "scheduler": "karras",
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
  "ip_adapter": {
    "reference": "reference/style_ref_card.png",
    "weight": 0.35
  },
  "output_dir": "Cards/Fronts",
  "items": [
    {
      "id": "m01_gwang",
      "name": "1월 광",
      "prompt": "skeletal pine tree with twisted dead branches, ghost crane with glowing cyan eyes perched on top, dark underworld moonlight filtering through bones, single pine tree centered",
      "frame": "gwang",
      "seed": 1001
    },
    {
      "id": "m01_tti_hongdan",
      "name": "1월 홍단",
      "prompt": "skeletal pine tree, blood-red ribbon with ancient cursed text floating between branches, dark mist rising, crimson accents on dark ink background",
      "frame": "tti_hong",
      "seed": 1002
    },
    {
      "id": "m01_pi_1",
      "name": "1월 피1",
      "prompt": "small skeletal pine branch, single dead pine needle cluster, minimal dark composition, sparse ink wash",
      "frame": "pi",
      "seed": 1003
    },
    {
      "id": "m01_pi_2",
      "name": "1월 피2",
      "prompt": "withered pine cone on skeletal branch, simple dark composition, minimal ink wash, sparse layout",
      "frame": "pi",
      "seed": 1004
    }
  ]
}
```

### 9.2 캐릭터 (`config/characters.json`)

```json
{
  "type": "characters",
  "workflow": "workflows/character_base.json",
  "variation_workflow": "workflows/character_variation.json",
  "generation": {
    "model": "sd_xl_base_1.0",
    "lora": "pixel-art-xl",
    "lora_weight": 0.65,
    "width": 768,
    "height": 1152,
    "steps": 40,
    "cfg_scale": 7,
    "sampler": "dpmpp_2m",
    "scheduler": "karras",
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
  "ip_adapter": {
    "reference": "reference/style_ref_boss.png",
    "weight": 0.35
  },
  "characters": [
    {
      "id": "mukbo",
      "name_kr": "먹보 도깨비",
      "base_seed": 5001,
      "base_prompt": "gluttonous dokkaebi korean goblin, fat round body, huge gaping mouth with sharp fangs, orange and blood red color scheme, dark fantasy korean folklore, menacing yet comedic, ink outline style",
      "output_dir": "Characters/Bosses/Mukbo",
      "variations": [
        {"suffix": "laugh_pose1",    "add": "laughing expression, arms wide open, belly shaking"},
        {"suffix": "eating_pose1",   "add": "eating ravenously, holding a bone, grease dripping"},
        {"suffix": "surprise_pose1", "add": "shocked expression, eyes bulging, mouth agape"},
        {"suffix": "anger_pose1",    "add": "furious expression, clenched fists, dark red aura"}
      ]
    },
    {
      "id": "trickster",
      "name_kr": "장난 도깨비",
      "base_seed": 5101,
      "base_prompt": "trickster dokkaebi korean goblin, thin wiry body, mischievous grin, holding a glowing bangmangi club, purple and cyan color scheme, dark fantasy korean folklore, sly and cunning, ink outline style",
      "output_dir": "Characters/Bosses/Trickster",
      "variations": [
        {"suffix": "laugh_pose1",    "add": "cackling, leaning forward, pointing finger"},
        {"suffix": "cast_pose1",     "add": "casting spell, bangmangi raised high, magical particles"},
        {"suffix": "surprise_pose1", "add": "startled, jumping back, wide eyes"},
        {"suffix": "anger_pose1",    "add": "enraged, swinging bangmangi, ghostfire erupting"}
      ]
    }
  ]
}
```

### 9.3 배경 (`config/backgrounds.json`)

```json
{
  "type": "backgrounds",
  "workflow": "workflows/background_base.json",
  "generation": {
    "model": "sd_xl_base_1.0",
    "lora": "pixel-art-xl",
    "lora_weight": 0.50,
    "width": 1280,
    "height": 720,
    "steps": 50,
    "cfg_scale": 7,
    "sampler": "dpmpp_2m",
    "scheduler": "karras",
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
  "ip_adapter": {
    "reference": "reference/style_ref_card.png",
    "weight": 0.30
  },
  "items": [
    {
      "id": "main_menu_sanzu",
      "name": "메인 메뉴 — 삼도천",
      "prompt": "Sanzu River korean underworld crossing, thick ghostly mist over dark water, cyan ghost fires floating above surface, silhouette of old wooden boat, distant jagged mountains, ink wash atmosphere, dark navy sky, eerie calm, layered fog",
      "output_dir": "Backgrounds/MainMenu",
      "seed": 9001
    },
    {
      "id": "area01_market",
      "name": "1영역 — 저승시장",
      "prompt": "korean ghost night market, warm orange paper lanterns hanging, ghostly translucent vendor silhouettes, wooden stalls displaying mystical objects, smoke and mist between stalls, dark alley perspective, cobblestone path",
      "output_dir": "Backgrounds/Area01_Market",
      "seed": 9002
    },
    {
      "id": "area02_bridge",
      "name": "2영역 — 삼도천 다리",
      "prompt": "ancient crumbling stone bridge over dark river, cyan ghost flames on bridge pillars, thick fog below, blood moon reflecting on water surface, dead willow trees on far bank, oppressive atmosphere",
      "output_dir": "Backgrounds/Area02_Bridge",
      "seed": 9003
    },
    {
      "id": "area03_court",
      "name": "3영역 — 저승 법정",
      "prompt": "dark underworld courthouse, massive stone pillars with ghost flame torches, judge desk elevated on stone platform, scrolls floating in air, ink wash ceiling, ominous red glow from cracks in floor",
      "output_dir": "Backgrounds/Area03_Court",
      "seed": 9004
    },
    {
      "id": "area04_palace",
      "name": "4영역 — 염라대왕 궁전",
      "prompt": "grand dark palace interior, massive throne with skull carvings, ghost flames in golden braziers, torn silk banners hanging, crimson and gold color accents, oppressive dark ceiling, ink wash shadows",
      "output_dir": "Backgrounds/Area04_Palace",
      "seed": 9005
    },
    {
      "id": "battle_bg",
      "name": "전투 배경",
      "prompt": "dark ritual circle on stone floor, ghost flames in four corners, ink wash smoke rising, subtle crimson glow from below, minimal composition, dark atmosphere, flat perspective from above",
      "output_dir": "Backgrounds/Battle",
      "seed": 9006
    },
    {
      "id": "ending_gate",
      "name": "엔딩 — 이승의 문",
      "prompt": "massive glowing golden gate, bright warm light pouring through opening, silhouette of sakura petals in light, dark surroundings contrasting with golden radiance, hope and warmth, ascending steps leading to gate",
      "output_dir": "Backgrounds/Ending",
      "seed": 9007
    }
  ]
}
```

---

## 10. 카드 48장 전체 프롬프트

### 프롬프트 핵심만 기재 (style_prefix + style_suffix 자동 추가됨)

| ID | 월 | 타입 | item.prompt 핵심 |
|----|---|------|-----------------|
| `m01_gwang` | 1 | 광 | skeletal pine, ghost crane with glowing cyan eyes, moonlight through bones |
| `m01_tti_hongdan` | 1 | 홍단 | skeletal pine, blood-red ribbon with cursed text, dark mist |
| `m01_pi_1` | 1 | 피 | small skeletal pine branch, sparse layout |
| `m01_pi_2` | 1 | 피 | withered pine cone on branch |
| `m02_tti_hongdan` | 2 | 홍단 | blood-red plum blossoms, raven silhouette, crimson ribbon |
| `m02_pi_1~3` | 2 | 피×3 | blood plum branches (각각 다른 구도) |
| `m03_gwang` | 3 | 광 | higanbana (피안화), crimson curtain veil, ghostly glow |
| `m03_tti_hongdan` | 3 | 홍단 | higanbana petals, red ribbon floating |
| `m03_pi_1~2` | 3 | 피×2 | scattered higanbana petals on dark ground |
| `m04_tti_chodan` | 4 | 초단 | black vines (검은 덩굴), spirit bird, green ribbon |
| `m04_pi_1~3` | 4 | 피×3 | dark hanging vines, minimal |
| `m05_tti_chodan` | 5 | 초단 | underworld orchid, Sanzu River bridge, green ribbon |
| `m05_pi_1~3` | 5 | 피×3 | pale orchid petals floating |
| `m06_tti_cheongdan` | 6 | 청단 | ghost peony, spirit butterfly, blue ribbon |
| `m06_pi_1~3` | 6 | 피×3 | fading peony petals |
| `m07_tti_cheongdan` | 7 | 청단 | flame vines (화염 덩굴), hell boar silhouette, blue ribbon |
| `m07_pi_1~3` | 7 | 피×3 | burning vine fragments |
| `m08_gwang` | 8 | 광 | reeds in wind, blood moon (적월), ominous crimson glow |
| `m08_yeolkkeut` | 8 | 열끗 | flying geese formation under blood moon |
| `m08_pi_1~2` | 8 | 피×2 | reed stalks, dark water |
| `m09_tti_cheongdan` | 9 | 청단 | underworld chrysanthemum, wanderer's cup, blue ribbon |
| `m09_pi_1~3` | 9 | 피×3 | wilting chrysanthemum petals |
| `m10_tti_chodan` | 10 | 초단 | blood-red maple leaves, skeletal deer, green ribbon |
| `m10_pi_1~3` | 10 | 피×3 | falling blood-red maple leaves |
| `m11_gwang` | 11 | 광 | immortal paulownia tree, hell phoenix in crimson flames |
| `m11_tti_hongdan` | 11 | 홍단 | paulownia leaves, red ribbon hanging |
| `m11_pi_1~2` | 11 | 피×2 | paulownia seed pods, dark |
| `m12_gwang` | 12 | 광 | blood rain falling, death messenger (사신) cloaked figure |
| `m12_tti_hongdan` | 12 | 홍단 | rain streaks, red umbrella silhouette, crimson ribbon |
| `m12_pi_1~2` | 12 | 피×2 | rain drops, dark puddles reflecting ghost light |

---

## 11. 마스터 실행 스크립트 (`generate.py`)

```python
#!/usr/bin/env python3
"""
도깨비의 패 — ComfyUI 에셋 자동 생성

사용법:
  python generate.py --all                          # 전체 에셋
  python generate.py --type cards                   # 카드만
  python generate.py --type characters              # 캐릭터만
  python generate.py --type cards --id m01_gwang    # 특정 1장
  python generate.py --type cards --pick            # 4장 생성 후 선택
"""

import argparse
import json
import sys
from pathlib import Path
from comfy_api import ComfyUIAPI
from postprocess import full_postprocess

SCRIPT_DIR = Path(__file__).parent
CONFIG_DIR = SCRIPT_DIR / "config"
OUTPUT_DIR = SCRIPT_DIR / "output"


def load_style_guide():
    return json.loads((CONFIG_DIR / "style_guide.json").read_text())


def load_config(config_type):
    return json.loads((CONFIG_DIR / f"{config_type}.json").read_text())


def build_prompt(style, asset_type, item_prompt):
    """스타일 가이드에 따라 최종 프롬프트 조립"""
    parts = [
        style["style_prefix"]["all"],
        style["style_prefix"].get(asset_type, ""),
        item_prompt,
        style["style_suffix"]["all"],
    ]
    return ", ".join(p for p in parts if p)


def build_negative(style, asset_type):
    parts = [
        style["negative"]["all"],
        style["negative"].get(asset_type, ""),
    ]
    return ", ".join(p for p in parts if p)


def generate_asset(api, item, config, style, output_base):
    asset_type = config["type"].rstrip("s")  # cards → card
    full_prompt = build_prompt(style, asset_type, item["prompt"])
    full_negative = build_negative(style, asset_type)

    # 워크플로우 로드 + 오버라이드
    wf_path = SCRIPT_DIR / config["workflow"]
    gen = config["generation"]

    # ComfyUI 워크플로우 노드 오버라이드 (노드 ID는 워크플로우마다 다름)
    # 실제 사용 시 워크플로우 JSON의 노드 ID에 맞춰 수정
    overrides = {
        "positive_prompt": {"text": full_prompt},
        "negative_prompt": {"text": full_negative},
        "sampler": {
            "seed": item.get("seed", -1),
            "steps": gen["steps"],
            "cfg": gen["cfg_scale"],
            "sampler_name": gen["sampler"],
            "scheduler": gen["scheduler"],
        },
        "latent": {
            "width": gen["width"],
            "height": gen["height"],
        },
    }

    workflow = api.load_workflow(str(wf_path), overrides)

    print(f"  생성 중: {item.get('name', item['id'])} (seed: {item.get('seed', -1)})")
    images = api.generate(workflow)

    # 후처리
    proc_config = {**config["postprocess"]}
    if item.get("frame"):
        proc_config["frame_type"] = item["frame"]

    out_dir = output_base / item.get("output_dir", config.get("output_dir", ""))
    out_dir.mkdir(parents=True, exist_ok=True)

    for i, img in enumerate(images):
        processed = full_postprocess(img, proc_config)
        suffix = f"_v{i}" if len(images) > 1 else ""
        filename = f"{item['id']}{suffix}.png"
        processed.save(out_dir / filename, "PNG")
        print(f"    → {out_dir / filename}")


def run(args):
    style = load_style_guide()
    config = load_config(args.type)

    api = ComfyUIAPI(style["comfyui_url"])
    if not api.ping():
        print("ComfyUI 서버에 연결할 수 없습니다.")
        print(f"  {style['comfyui_url']} 에서 실행 중인지 확인하세요.")
        sys.exit(1)
    print("ComfyUI 연결 성공")

    items = config.get("items", [])
    # 캐릭터는 characters 키 사용
    if not items and "characters" in config:
        items = []
        for char in config["characters"]:
            for var in char.get("variations", [{}]):
                items.append({
                    "id": f"{char['id']}_{var.get('suffix', 'base')}",
                    "name": f"{char['name_kr']} — {var.get('suffix', 'base')}",
                    "prompt": f"{char['base_prompt']}, {var.get('add', '')}",
                    "output_dir": char.get("output_dir", ""),
                    "seed": char.get("base_seed", -1),
                })

    if args.id:
        items = [i for i in items if i["id"] == args.id]
        if not items:
            print(f"ID '{args.id}'를 찾을 수 없습니다.")
            sys.exit(1)

    print(f"\n{config['type']} 생성 시작 ({len(items)}개)")
    for item in items:
        generate_asset(api, item, config, style, OUTPUT_DIR)
    print(f"완료! {len(items)}개 에셋 생성됨")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="도깨비의 패 에셋 자동 생성")
    parser.add_argument("--all", action="store_true")
    parser.add_argument("--type", choices=["cards", "characters", "backgrounds", "talismans"])
    parser.add_argument("--id", type=str)
    parser.add_argument("--pick", action="store_true")
    args = parser.parse_args()

    if args.all:
        for t in ["cards", "characters", "backgrounds", "talismans"]:
            args.type = t
            run(args)
    elif args.type:
        run(args)
    else:
        parser.print_help()
```

---

## 12. 실행 명령어

### 12.1 서버 실행

```bash
cd ~/Desktop/ComfyUI && source venv/bin/activate && python main.py --listen
```

### 12.2 에셋 생성

```bash
cd dokkaebi-hand/sd-pipeline

python generate.py --all                          # 전체
python generate.py --type cards                   # 카드 48장
python generate.py --type characters              # 캐릭터 전체
python generate.py --type backgrounds             # 배경 7종
python generate.py --type talismans               # 부적 아이콘
python generate.py --type cards --id m01_gwang    # 1장만
python generate.py --type cards --pick            # 4장 중 선택
```

---

## 13. IP-Adapter 참조 이미지 준비

### 일관성의 핵심: 스타일 참조 이미지

1. ComfyUI에서 **수동으로** 마음에 드는 카드/캐릭터 1장을 생성
2. 그 이미지를 `reference/style_ref_card.png`, `reference/style_ref_boss.png`로 저장
3. 이후 모든 자동 생성에 IP-Adapter가 이 이미지의 **톤/질감/색감**을 참조

```
참조 이미지 선정 기준:
- 원하는 픽셀 크기와 선 굵기가 정확히 맞는 것
- 팔레트 색상이 잘 반영된 것
- 구도가 "평균적"인 것 (극단적이지 않은)
```

### ComfyUI에서 IP-Adapter 설치

```bash
cd ~/Desktop/ComfyUI/custom_nodes
git clone https://github.com/cubiq/ComfyUI_IPAdapter_plus.git

# 모델 다운로드 (models/ipadapter/ 에 배치)
# ip-adapter_sd15.safetensors (SD 1.5용)
# ip-adapter_sdxl.safetensors (SDXL용)
```

---

## 14. 성능 예상 (M3 Pro 18GB)

| 에셋 | 모델 | 해상도 | Steps | 예상 시간 |
|------|------|--------|-------|----------|
| 카드 | SD 1.5 | 512×768 | 35 | ~25초 |
| 캐릭터 | SDXL | 768×1152 | 40 | ~80초 |
| 배경 | SDXL | 1280×720 | 50 | ~90초 |
| 부적 | SD 1.5 | 256×256 | 30 | ~10초 |

> ComfyUI는 A1111 대비 Mac에서 약 20~30% 빠르다.

---

## 15. 디렉토리 구조 (최종)

```
dokkaebi-hand/
  sd-pipeline/
    generate.py                   ← 마스터 명령 스크립트
    comfy_api.py                  ← ComfyUI API 래퍼
    postprocess.py                ← 후처리 자동화
    workflows/                    ← ComfyUI 워크플로우 JSON
      card_base.json
      character_base.json
      character_variation.json
      background_base.json
      talisman_base.json
    config/                       ← 설정 + 프롬프트
      style_guide.json            ← 공통 스타일/네거티브/팔레트
      cards.json                  ← 48장 프롬프트
      characters.json             ← 캐릭터 + 변형 정의
      backgrounds.json            ← 7종 프롬프트
      talismans.json
    reference/                    ← IP-Adapter 참조 이미지
      style_ref_card.png
      style_ref_boss.png
    palette/
      dokkaebi_palette.png
    output/                       ← 중간 출력 (.gitignore)
  Assets/Art/                     ← 최종 에셋
    Cards/Fronts/
    Characters/Bosses/
    Backgrounds/
    Talismans/
```

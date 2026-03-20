# Stable Diffusion 설치 & 실행 가이드 (Mac M3 Pro)

## 현재 시스템 사양

| 항목 | 값 |
|------|-----|
| CPU | Apple M3 Pro |
| RAM | 18GB (통합 메모리 = GPU와 공유) |
| GPU | M3 Pro 내장 (Metal 4, 18코어) |
| OS | macOS 26.3.1 (arm64) |
| Python | 3.13.1 |
| Homebrew | 설치됨 |
| Git | 설치됨 |

> **M3 Pro 18GB로 SD 돌릴 수 있나?**
> - SD 1.5: **충분히 가능** (4~6GB 사용)
> - SDXL: **가능하지만 느림** (10~12GB 사용, 1장 생성에 1~3분)
> - 권장: **SD 1.5 + 픽셀아트 LoRA** (속도, 메모리 모두 유리)

---

## 방법 1: ComfyUI (권장 — Mac 최적화 좋음)

ComfyUI가 Mac Metal 가속을 가장 잘 지원하며, 노드 기반이라 워크플로우 재사용이 쉽다.

### 1단계: ComfyUI 설치

```bash
# 1. 작업 폴더로 이동
cd ~/Desktop

# 2. ComfyUI 클론
git clone https://github.com/comfyanonymous/ComfyUI.git
cd ComfyUI

# 3. 가상환경 생성 (Python 3.10~3.12 권장, 3.13은 호환 이슈 가능)
#    만약 3.13에서 문제가 생기면 아래 pyenv로 3.11 설치
python3 -m venv venv
source venv/bin/activate

# 4. PyTorch (Mac MPS 가속) 설치
pip install --pre torch torchvision torchaudio --index-url https://download.pytorch.org/whl/nightly/cpu

# 5. ComfyUI 의존성 설치
pip install -r requirements.txt
```

### Python 3.13 호환 문제 시

```bash
# pyenv로 Python 3.11 설치
brew install pyenv
pyenv install 3.11.9
pyenv local 3.11.9

# 가상환경 재생성
~/.pyenv/versions/3.11.9/bin/python -m venv venv
source venv/bin/activate
pip install --pre torch torchvision torchaudio --index-url https://download.pytorch.org/whl/nightly/cpu
pip install -r requirements.txt
```

### 2단계: 모델 다운로드

모델 파일은 용량이 크다. 아래 순서대로 하나씩 받으면 된다.

#### 필수 모델: SD 1.5 (약 4GB)

```bash
# models 폴더 확인
cd ~/Desktop/ComfyUI

# SD 1.5 체크포인트 다운로드 (Hugging Face에서)
# 브라우저에서 아래 페이지 방문 → 파일 다운로드
# https://huggingface.co/stable-diffusion-v1-5/stable-diffusion-v1-5
# → v1-5-pruned-emaonly.safetensors (약 4.2GB)
# → 다운로드 후 아래 폴더로 이동:
mv ~/Downloads/v1-5-pruned-emaonly.safetensors models/checkpoints/
```

또는 커맨드로:
```bash
# Hugging Face CLI로 다운로드 (선택)
pip install huggingface_hub
huggingface-cli download stable-diffusion-v1-5/stable-diffusion-v1-5 \
  v1-5-pruned-emaonly.safetensors \
  --local-dir models/checkpoints/
```

#### 선택 모델: SDXL (약 6.5GB) — 느리지만 고품질

```bash
# SDXL Base 1.0
# https://huggingface.co/stabilityai/stable-diffusion-xl-base-1.0
# → sd_xl_base_1.0.safetensors 다운로드 → models/checkpoints/에 배치
```

#### 픽셀아트 LoRA 다운로드

```bash
# LoRA 저장 폴더
mkdir -p models/loras

# CivitAI에서 픽셀아트 LoRA 다운로드 (브라우저에서):
# 검색: "pixel art" → SD 1.5 호환 LoRA 선택
# 다운로드한 .safetensors 파일을 models/loras/ 에 배치

# 추천 LoRA (CivitAI 검색):
# - "Pixel Art Style" (SD 1.5)
# - "Pixel Art XL" (SDXL용)
```

### 3단계: ComfyUI 실행

```bash
cd ~/Desktop/ComfyUI
source venv/bin/activate

# Mac MPS 가속으로 실행
python main.py --force-fp16

# 실행 성공 시 출력:
# Starting server
# To see the GUI go to: http://127.0.0.1:8188
```

**브라우저에서 http://127.0.0.1:8188 접속** → ComfyUI 인터페이스가 뜬다.

### 4단계: 첫 이미지 생성 (테스트)

ComfyUI가 열리면 기본 워크플로우가 로드되어 있다.

1. **Load Checkpoint** 노드에서 → `v1-5-pruned-emaonly.safetensors` 선택
2. **CLIP Text Encode (Prompt)** 노드에 긍정 프롬프트 입력:
   ```
   pixel art, korean traditional hwatu card, dark fantasy,
   ink painting style, skeletal pine tree, ghost crane,
   16-bit style, limited color palette, sharp pixels
   ```
3. **CLIP Text Encode (Negative)** 노드에:
   ```
   blurry, 3d render, realistic photo, anti-aliasing, soft edges
   ```
4. **Empty Latent Image** 노드: 너비 320, 높이 480 (카드 비율)
5. **Queue Prompt** 버튼 클릭 → 생성 시작

> M3 Pro에서 SD 1.5 기준 512x512 이미지 **약 15~30초** 소요.

---

## 방법 2: A1111 WebUI (전통적, API 자동화에 유리)

자동화 스크립트(`generate.py`)와 연동하려면 이 방식이 더 편하다.

### 설치

```bash
cd ~/Desktop

# A1111 WebUI 클론
git clone https://github.com/AUTOMATIC1111/stable-diffusion-webui.git
cd stable-diffusion-webui

# Mac용 실행 스크립트 (자동으로 venv, 의존성 설치)
./webui.sh --skip-torch-cuda-test

# 최초 실행 시 자동으로:
# - 가상환경 생성
# - PyTorch (MPS) 설치
# - 의존성 설치
# → 시간이 좀 걸림 (5~10분)
```

### 모델 배치

```bash
# 체크포인트
mv ~/Downloads/v1-5-pruned-emaonly.safetensors \
   ~/Desktop/stable-diffusion-webui/models/Stable-diffusion/

# LoRA
mkdir -p ~/Desktop/stable-diffusion-webui/models/Lora/
# → LoRA 파일을 이 폴더에 배치
```

### API 모드로 실행 (자동화 스크립트용)

```bash
cd ~/Desktop/stable-diffusion-webui

# 일반 실행 (브라우저 UI)
./webui.sh --skip-torch-cuda-test

# API 모드 실행 (generate.py 연동용)
./webui.sh --skip-torch-cuda-test --api --listen
```

**브라우저에서 http://127.0.0.1:7860 접속**

---

## 방법 3: Diffusers (Python 코드만으로, UI 없음)

가장 가볍고 단순한 방법. UI 없이 Python 스크립트로만 이미지 생성.

### 설치

```bash
# 프로젝트 폴더에 가상환경 생성
cd ~/Desktop/work/dokkaebi-hand
python3 -m venv sd-env
source sd-env/bin/activate

# 필요 패키지 설치
pip install diffusers transformers accelerate safetensors
pip install --pre torch torchvision --index-url https://download.pytorch.org/whl/nightly/cpu
pip install Pillow
```

### 테스트 스크립트

```python
#!/usr/bin/env python3
"""sd_test.py — 첫 이미지 생성 테스트"""

from diffusers import StableDiffusionPipeline
import torch

# 모델 로드 (최초 실행 시 자동 다운로드 ~4GB)
pipe = StableDiffusionPipeline.from_pretrained(
    "stable-diffusion-v1-5/stable-diffusion-v1-5",
    torch_dtype=torch.float16,
    use_safetensors=True
)

# Mac MPS 가속 사용
pipe = pipe.to("mps")

# 메모리 최적화 (18GB 통합 메모리용)
pipe.enable_attention_slicing()

# 이미지 생성
prompt = """pixel art, korean traditional hwatu card,
dark fantasy, ink painting style,
skeletal pine tree, ghost crane with glowing cyan eyes,
16-bit style, limited color palette, sharp pixels,
dark navy background, beige card face"""

negative = "blurry, 3d, realistic, anti-aliasing, soft edges"

image = pipe(
    prompt=prompt,
    negative_prompt=negative,
    width=320,
    height=480,
    num_inference_steps=30,
    guidance_scale=8,
    generator=torch.Generator("mps").manual_seed(1001)
).images[0]

# 저장
image.save("test_card.png")
print("✅ 생성 완료: test_card.png")
```

### 실행

```bash
source sd-env/bin/activate
python sd_test.py
# → test_card.png 생성됨
open test_card.png  # 미리보기
```

---

## 어떤 방법을 선택할까?

| 방법 | 장점 | 단점 | 추천 대상 |
|------|------|------|----------|
| **ComfyUI** | Mac 최적화, 시각적 워크플로우, LoRA 쉬움 | 노드 개념 학습 필요 | 비주얼하게 작업하고 싶을 때 |
| **A1111 WebUI** | UI 직관적, API 자동화 가능, 커뮤니티 최대 | 설치 무거움, Mac 지원 불안정할 수 있음 | 자동화 파이프라인 쓸 때 |
| **Diffusers** | 가장 가벼움, 코드로 완전 제어 | UI 없음, LoRA 적용 좀 복잡 | 코드로만 빠르게 돌릴 때 |

### 내 추천 (M3 Pro 18GB 기준)

**1순위: ComfyUI** — Mac Metal 최적화가 가장 좋고, 워크플로우 저장/재사용이 편리.
**2순위: Diffusers** — 가볍게 코드만으로 돌리고 싶으면 이것.

---

## 빠른 시작 (지금 바로 해보기)

```bash
# 1. ComfyUI 설치 (5분)
cd ~/Desktop
git clone https://github.com/comfyanonymous/ComfyUI.git
cd ComfyUI
python3 -m venv venv
source venv/bin/activate
pip install --pre torch torchvision torchaudio --index-url https://download.pytorch.org/whl/nightly/cpu
pip install -r requirements.txt

# 2. SD 1.5 모델 다운로드 (브라우저에서 Hugging Face 접속)
#    → models/checkpoints/ 에 배치

# 3. 실행
python main.py --force-fp16

# 4. 브라우저에서 http://127.0.0.1:8188 접속

# 5. 프롬프트 입력 → Queue Prompt → 이미지 생성!
```

---

## 문제 해결

### "MPS backend out of memory"
```bash
# 해상도를 낮추거나 attention slicing 활성화
python main.py --force-fp16 --lowvram
```

### Python 3.13 호환 문제
```bash
# Python 3.11로 다운그레이드
brew install pyenv
pyenv install 3.11.9
~/.pyenv/versions/3.11.9/bin/python -m venv venv
```

### PyTorch MPS 지원 확인
```python
import torch
print(torch.backends.mps.is_available())  # True 여야 함
print(torch.backends.mps.is_built())      # True 여야 함
```

### SDXL에서 메모리 부족
```
18GB에서 SDXL은 빠듯하다.
→ SD 1.5 사용을 권장.
→ 또는 생성 해상도를 512x512 이하로 제한.
```

---

## 성능 예상치 (M3 Pro 18GB)

| 모델 | 해상도 | Steps | 예상 시간 |
|------|--------|-------|----------|
| SD 1.5 | 512×768 (카드) | 35 | ~30초 |
| SD 1.5 | 512×512 | 30 | ~20초 |
| SD 1.5 | 768×1152 (캐릭터) | 40 | ~50초 |
| SD 1.5 | 1280×720 (배경) | 50 | ~90초 |
| SDXL | 512×512 | 30 | ~60초 |
| SDXL | 1024×1024 | 40 | ~3분 |

> SD 1.5가 훨씬 빠르고 18GB에서 안정적이다.
> 픽셀아트는 고해상도가 필요 없으므로 SD 1.5가 최적 선택.

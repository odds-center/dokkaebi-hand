# ComfyUI 모델 다운로드 목록

> 도깨비의 패 아트 파이프라인에 필요한 모든 모델 파일.
> 모두 `~/Desktop/ComfyUI/` 기준 경로.

---

## 필수 모델

### 1. Pony Diffusion V6 XL (체크포인트)

| 항목 | 값 |
|------|-----|
| 용도 | 베이스 체크포인트 (SDXL 계열) |
| 파일 | `ponyDiffusionV6XL.safetensors` (~6.5GB) |
| 배치 경로 | `models/checkpoints/` |
| 다운로드 | https://civitai.com/api/download/models/290640 |
| CivitAI 페이지 | https://civitai.com/models/257749/pony-diffusion-v6-xl |

### 2. TBOI LoRA — The Binding of Isaac Style

| 항목 | 값 |
|------|-----|
| 용도 | 픽셀아트 스타일 LoRA (아이작 풍) |
| 파일 | `Tboi.safetensors` (~218MB) |
| 배치 경로 | `models/loras/` |
| 다운로드 | https://civitai.com/api/download/models/828975 |
| CivitAI 페이지 | https://civitai.com/models/740858/the-binding-of-isaac-style |
| 트리거 워드 | `pixel art`, `game assets`, `chibi` |
| 권장 강도 | model: 0.8 / clip: 0.8 |
| 주의 | `score_9, score_8_up` 등 Pony 품질 태그를 **네거티브**에 넣을 것 |

---

## 선택 모델 (일관성 강화용)

### 3. IP-Adapter Plus (SDXL)

| 항목 | 값 |
|------|-----|
| 용도 | 참조 이미지로 스타일 통일 |
| 파일 | `ip-adapter-plus_sdxl_vit-h.bin` |
| 배치 경로 | `models/ipadapter/` |
| 다운로드 | https://huggingface.co/h94/IP-Adapter/resolve/main/sdxl_models/ip-adapter-plus_sdxl_vit-h.bin |

### 4. CLIP Vision 인코더 (IP-Adapter 필수 동반)

| 항목 | 값 |
|------|-----|
| 용도 | IP-Adapter가 참조 이미지를 해석하는 데 필요 |
| 파일 | `model.safetensors` → `sdxl_image_encoder.safetensors`로 이름 변경 권장 |
| 배치 경로 | `models/clip_vision/` |
| 다운로드 | https://huggingface.co/h94/IP-Adapter/resolve/main/sdxl_models/image_encoder/model.safetensors |

### 5. IP-Adapter ComfyUI 커스텀 노드

| 항목 | 값 |
|------|-----|
| 용도 | ComfyUI에서 IP-Adapter 노드 사용 |
| 설치 | `cd custom_nodes && git clone https://github.com/cubiq/ComfyUI_IPAdapter_plus.git` |

---

## 터미널에서 한번에 받기

```bash
cd ~/Desktop/ComfyUI

# ===== 필수 =====

# 1. Pony Diffusion V6 XL 체크포인트 (~6.5GB)
curl -L -o models/checkpoints/ponyDiffusionV6XL.safetensors \
  "https://civitai.com/api/download/models/290640"

# 2. TBOI LoRA (~218MB)
curl -L -o models/loras/Tboi.safetensors \
  "https://civitai.com/api/download/models/828975"

# ===== 선택 (일관성 강화) =====

# 3. IP-Adapter Plus SDXL
mkdir -p models/ipadapter models/clip_vision
curl -L -o models/ipadapter/ip-adapter-plus_sdxl_vit-h.bin \
  "https://huggingface.co/h94/IP-Adapter/resolve/main/sdxl_models/ip-adapter-plus_sdxl_vit-h.bin"

# 4. CLIP Vision 인코더
curl -L -o models/clip_vision/sdxl_image_encoder.safetensors \
  "https://huggingface.co/h94/IP-Adapter/resolve/main/sdxl_models/image_encoder/model.safetensors"

# 5. IP-Adapter 커스텀 노드
cd custom_nodes
git clone https://github.com/cubiq/ComfyUI_IPAdapter_plus.git
cd ..
```

> CivitAI는 curl로 HTML이 나올 수 있음 → 브라우저에서 직접 다운로드 권장.

---

## 폴더 구조 확인

```
~/Desktop/ComfyUI/
  models/
    checkpoints/
      ponyDiffusionV6XL.safetensors     ← 필수
    loras/
      Tboi.safetensors                   ← 필수
    ipadapter/
      ip-adapter-plus_sdxl_vit-h.bin     ← 선택
    clip_vision/
      sdxl_image_encoder.safetensors     ← IP-Adapter 쓸 때 필수
  custom_nodes/
    ComfyUI_IPAdapter_plus/              ← IP-Adapter 쓸 때 필수
```

# 배경 — 공통 설정

배경은 이미지 생성 AI의 최대 강점. 큰 해상도, 분위기 전달이 핵심이므로
정밀한 디테일보다 **전체 무드와 색감**이 중요하다.

---

## 생성 환경

```yaml
Model: Pony Diffusion V6 XL (ComfyUI)
LoRA: Binding of Isaac Style v2.1 (strength 0.55)
Resolution: 640 x 360 (픽셀아트 그리드 = 이 크기 그대로)
       # → Nearest Neighbor 3x 업스케일 = 1920x1080 (기본 저장)
       # → 1280x720에서는 2x 또는 축소 표시
Sampler: euler_a
Steps: 25~30
CFG: 7
Batch: 4장씩 뽑아서 최선 선택
```

## 공통 프롬프트 프리픽스

> 모든 배경 프롬프트 **앞에** 이 태그를 붙인다.

```
score_9, score_8_up, score_7_up, pixel art, game assets, chibi, wide 16:9 landscape game background, Korean dark fantasy, low-resolution pixel art, 640x360 pixel canvas, blocky jagged edges, no smooth curves, no anti-aliasing, flat colors, thick black outlines, NES SNES era aesthetic, limited color palette, no characters, no text, no UI elements, fully contained with margins
```

## 공통 네거티브 프롬프트

```
score_4, score_3, score_2, score_1, blurry, photo, realistic, 3d render, smooth shading, anti-aliasing, gradient, soft edges, watercolor, text, watermark, signature
```

### 중요: 공통 프리픽스에 "pixel art" 등 스타일 태그가 이미 포함됨
개별 프롬프트는 Pony 태그 스타일(쉼표 구분)로 작성하며,
"pixel art", "flat colors", "no anti-aliasing", "16:9", "no characters" 등은
공통 프리픽스에 포함되어 있으므로 개별 프롬프트에서 반복하지 않는다.

## 후처리

```
1. 4장 중 최선 선택
2. Nearest Neighbor 3x 업스케일 → 1920x1080 (기본 에셋 크기)
3. 필요 시 밝기/대비 약간 조정
4. PNG 저장 → Assets/Art/Backgrounds/
5. 게임 엔진이 윈도우 크기에 맞춰 Nearest Neighbor 스케일
```

## 임포트 설정

```
Filter Mode: Point (Nearest Neighbor) ← 픽셀아트 필수!
Compression: None
```

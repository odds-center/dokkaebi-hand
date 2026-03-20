# 배경 — 공통 설정

배경은 이미지 생성 AI의 최대 강점. 큰 해상도, 분위기 전달이 핵심이므로
정밀한 디테일보다 **전체 무드와 색감**이 중요하다.

---

## 생성 환경

```yaml
Model: Flux-dev (ComfyUI)
Resolution: 640 x 360 (픽셀아트 그리드 = 이 크기 그대로)
       # → Nearest Neighbor 3x 업스케일 = 1920x1080 (기본 저장)
       # → 1280x720에서는 2x 또는 축소 표시
Steps: 20~30
Guidance: 3.5~4.0
Sampler: euler
Scheduler: normal
Batch: 4장씩 뽑아서 최선 선택
```

### Flux-dev 프롬프트 규칙
- **네거티브 프롬프트 없음** — 원하지 않는 요소는 긍정 프롬프트에서 명시적으로 배제.
- **가중치 문법 미사용** — 자연어로 강조.
- **LoRA는 ComfyUI 노드에서 연결** — 프롬프트에 태그 넣지 않음.
- **자연어 서술** — 문장 형태로 장면을 묘사.

## 공통 프롬프트 프리픽스

> 모든 배경 프롬프트 **앞에** 이 문장을 붙인다.

```
A wide 16:9 landscape game background in Korean dark fantasy style, rendered as low-resolution pixel art like a background from Celeste, Stardew Valley, or Shovel Knight. The scene looks like it was drawn on a 640x360 pixel canvas — pixels are visible but the scene has enough detail to be a rich environment. Blocky jagged edges on all shapes, no smooth curves, no anti-aliasing, no soft gradients. Bold flat color fills with clear pixel structure. NES/SNES era background art aesthetic. Limited color palette. No characters, no text, no UI elements. Scene fills the entire frame edge to edge. Not a photograph — a stylized pixel art game background.
```

### 중요: 모든 배경 개별 프롬프트에도 "pixel art" 스타일을 반복 명시할 것
Flux-dev는 프롬프트 앞부분에 집중하므로, 개별 프롬프트 첫 문장에
"A pixel art scene of..." 형태로 시작하는 것이 안전하다.

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

# 배경 — 공통 설정

배경은 이미지 생성 AI의 최대 강점. 큰 해상도, 분위기 전달이 핵심이므로
정밀한 디테일보다 **전체 무드와 색감**이 중요하다.

---

## 생성 환경

```yaml
Model: Flux-dev (ComfyUI)
Resolution: 960 x 540
       # → Nearest Neighbor 2x 업스케일 = 1920x1080
       # 게임 UI reference resolution = 1920x1080, 16:9 (CanvasScaler)
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
A wide 16:9 landscape game background in Korean dark fantasy ink painting style. 16-bit retro pixel art with crisp sharp pixels, no anti-aliasing, no smooth gradients. Atmospheric lighting with limited color palette. Bold flat colors with visible pixel structure. No characters, no text, no UI elements visible. The scene fills the entire frame edge to edge as a seamless game background. Not a photograph — stylized pixel art illustration.
```

### 중요: 모든 배경 개별 프롬프트에도 "pixel art" 스타일을 반복 명시할 것
Flux-dev는 프롬프트 앞부분에 집중하므로, 개별 프롬프트 첫 문장에
"A pixel art scene of..." 형태로 시작하는 것이 안전하다.

## 후처리

```
1. 4장 중 최선 선택
2. Pillow로 Nearest Neighbor 2x 업스케일 (960x540 → 1920x1080)
3. 필요 시 밝기/대비 약간 조정
4. PNG 저장 → Assets/Art/Backgrounds/
```

## Unity 임포트

```
Filter Mode: Bilinear (배경은 Point가 아님 — 부드러운 렌더링)
Compression: None
Max Size: 2048
```

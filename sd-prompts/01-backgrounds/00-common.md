# 배경 — 공통 설정

배경은 SD의 최대 강점. 큰 해상도, 분위기 전달이 핵심이므로
정밀한 디테일보다 **전체 무드와 색감**이 중요하다.

---

## SD 설정

```yaml
Model: SD 1.5 + pixel-art LoRA (0.5~0.6)
       # 배경은 LoRA 가중치를 낮게 — 너무 높으면 도트가 과해짐
Resolution: 960 x 540
       # → Nearest Neighbor 2x 업스케일 = 1920x1080
       # 처음부터 1920x1080으로 뽑으면 메모리 부족 + 구도 깨짐
Steps: 40~50
CFG Scale: 7
Sampler: DPM++ 2M Karras
Batch: 4장씩 뽑아서 최선 선택
```

## 프롬프트 결합 방법

```
[공통 긍정] + [개별 긍정]
```

## 공통 긍정 프롬프트 (모든 배경 앞에 붙임)

```
(pixel art game background:1.3), wide 16:9 landscape,
(korean ink painting style:1.2), (dark fantasy:1.2),
limited color palette, atmospheric lighting,
(no characters:1.4), no text, no UI elements,
<lora:pixelart-style:0.55>
```

## 공통 부정 프롬프트

```
(blurry:1.3), (3d render:1.4), (realistic photograph:1.4),
(anime style:1.2), bright cheerful colors, daylight,
modern buildings, cars, technology, people, characters,
text, letters, watermark, signature, logo,
(low quality:1.3), jpeg artifacts, cropped, frame, border,
(anti-aliasing:1.2), soft focus, depth of field, bokeh
```

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

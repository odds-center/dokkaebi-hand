# 카드 일러스트 — 공통 설정

## 역할
카드 **내부 일러스트만** SD로 생성한다.
프레임(테두리, 심볼, 월 표기)은 코드(`MockupSpriteFactory`)로 합성.

```
[SD가 만드는 것]        [코드가 만드는 것]
 카드 안쪽 그림    +     테두리 + 심볼 + 텍스트
```

## SD 설정

```yaml
Model: SD 1.5 + pixel-art LoRA (0.75)
Resolution: 256 x 384
       # 카드 비율 2:3 (80x120의 정확히 3.2배)
       # 작게 뽑아야 도트 느낌이 살아남
Steps: 30~35
CFG Scale: 8
Sampler: DPM++ 2M Karras
Batch: 4장씩 뽑아서 최선 선택
```

## 왜 256x384인가
- 320x480은 SD 1.5에서 비표준 해상도 → 구도가 깨지기 쉬움
- 256x384는 512의 절반 기반 → SD가 잘 처리하는 범위
- 최종 80x120으로 Nearest Neighbor 다운스케일하면 3.2:1 비율
- 다운스케일 시 충분한 디테일 유지

## 공통 긍정 프롬프트

```
(pixel art:1.3), (traditional korean ink painting:1.2),
(single centered illustration:1.3), dark fantasy,
(hanji paper texture background:1.1),
limited color palette, thick ink outlines,
16-bit style, (clean composition:1.2),
<lora:pixelart-style:0.75>
```

## 공통 부정 프롬프트

```
(blurry:1.3), (3d render:1.4), (realistic:1.4),
(multiple subjects:1.3), (busy cluttered composition:1.3),
text, letters, numbers, frame, border, card frame,
watermark, signature, logo,
(anti-aliasing:1.2), soft edges, smooth gradients,
modern elements, cute style, chibi,
(human face:1.2), (human figure:1.2),
bright white background
```

## 후처리

```
1. 4장 중 최선 선택
2. Nearest Neighbor 다운스케일 → 80x120 (또는 우선 160x240 중간)
3. 투명 배경 처리 불필요 — 한지 배경 유지
4. PNG 저장 → 코드에서 프레임 합성
```

## 월별 카드 구성 (48장)
| 월 | 광 | 홍단 | 청단 | 초단 | 열끗 | 피 | 합계 |
|----|---|------|------|------|------|---|------|
| 1 | 1 | 1 | - | - | - | 2 | 4 |
| 2 | - | 1 | - | - | - | 3 | 4 |
| 3 | 1 | 1 | - | - | - | 2 | 4 |
| 4 | - | - | - | 1 | - | 3 | 4 |
| 5 | - | - | - | 1 | - | 3 | 4 |
| 6 | - | - | 1 | - | - | 3 | 4 |
| 7 | - | - | 1 | - | - | 3 | 4 |
| 8 | 1 | - | - | - | 1 | 2 | 4 |
| 9 | - | - | 1 | - | - | 3 | 4 |
| 10 | - | - | - | 1 | - | 3 | 4 |
| 11 | 1 | 1 | - | - | - | 2 | 4 |
| 12 | 1 | 1 | - | - | - | 2 | 4 |

## 카드 등급별 일러스트 밀도
- **광:** 가장 화려하고 가득 찬 구도. 주인공 오브젝트가 크고 빛남.
- **띠(홍/청/초):** 중간 밀도. 주제 + 띠(리본) 요소.
- **열끗:** 중간. 동물/사물이 주제.
- **피:** 가장 미니멀. 여백이 많고 오브젝트가 작음.

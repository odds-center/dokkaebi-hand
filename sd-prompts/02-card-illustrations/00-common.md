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
Resolution: 270 x 390
       # 카드 UI 표시 크기: 90x130 (CardWidth=90, CardHeight=130)
       # 270x390 = 90x130의 정확히 3배 → 깔끔한 다운스케일
       # 텍스처 생성 크기: 80x120 (MockupSpriteFactory)
Steps: 30~35
CFG Scale: 8
Sampler: DPM++ 2M Karras
Batch: 4장씩 뽑아서 최선 선택
```

## 카드 크기 참조
- **UI 표시 크기:** 90x130px (게임 화면에서 보이는 크기)
- **텍스처 생성 크기:** 80x120px (MockupSpriteFactory CardWidth/CardHeight)
- **SD 생성 크기:** 270x390px (UI 크기의 3배)
- **카드 프레임 오버레이 영역:**
  - 상단 25px: 월 헤더 바 (텍스트로 가려짐)
  - 하단 22px: 강화 등급 바 (텍스트로 가려짐)
  - 테두리: 3px 전체
  - 실제 보이는 일러스트 영역 ≈ 74x83 중앙 부분

## 왜 270x390인가
- 90x130 UI 크기의 정확히 3배 → 깔끔한 Nearest Neighbor 다운스케일
- 256x384는 SD 1.5에서 안정적이나 90x130과 비율이 정확히 맞지 않음
- 270x390도 SD 1.5가 처리 가능한 범위 (512 이하)
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
2. Nearest Neighbor 다운스케일 → 90x130 (UI 표시 크기) 또는 80x120 (텍스처 크기)
3. 투명 배경 처리 불필요 — 한지 배경 유지
4. PNG 저장 → 코드에서 프레임 합성 (MockupSpriteFactory)
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

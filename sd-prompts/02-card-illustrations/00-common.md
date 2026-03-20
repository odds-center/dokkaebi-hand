# 카드 일러스트 — 공통 설정

## 역할
카드 **내부 일러스트만** 이미지 생성 AI로 만든다.
프레임(테두리, 심볼, 월 표기)은 코드(`MockupSpriteFactory`)로 합성.

```
[AI가 만드는 것]          [코드가 만드는 것]
 카드 안쪽 그림    +     테두리 + 심볼 + 텍스트
```

## 생성 환경

```yaml
Model: Flux-dev (ComfyUI)
Resolution: 240 x 336 (픽셀 그리드 60x84 기준, 4x 생성)
       # → 다운스케일 180x252 (@1920x1080 기본 저장)
Steps: 20~30
Guidance: 3.5~4.0
Sampler: euler
Scheduler: normal
Batch: 4장씩 뽑아서 최선 선택
```

### Flux-dev 프롬프트 규칙
- **네거티브 프롬프트 없음** — Flux-dev는 네거티브 프롬프트를 지원하지 않음. 원하지 않는 요소는 긍정 프롬프트에서 명시적으로 배제하는 식으로 작성.
- **가중치 문법 미사용** — `(keyword:1.3)` 같은 SD 문법 대신 자연어로 강조. "very detailed", "prominently placed" 등.
- **LoRA는 ComfyUI 노드에서 연결** — 프롬프트에 `<lora:...>` 태그 넣지 않음.
- **자연어 서술** — 문장 형태로 장면을 묘사. 쉼표 나열보다 문장이 효과적.

## 카드 크기 참조
- **UI 표시 크기:** 90x130px (게임 화면에서 보이는 크기)
- **텍스처 생성 크기:** 80x120px (MockupSpriteFactory CardWidth/CardHeight)
- **AI 생성 크기:** 270x390px (UI 크기의 3배)
- **카드 프레임 오버레이 영역:**
  - 상단 25px: 월 헤더 바 (텍스트로 가려짐)
  - 하단 22px: 강화 등급 바 (텍스트로 가려짐)
  - 테두리: 3px 전체
  - 실제 보이는 일러스트 영역 ≈ 74x83 중앙 부분

## 화투 카드 비주얼 원칙

전통 한국 화투(花鬪) 48장의 시각 언어를 충실히 따르되,
"저승 도깨비" 세계관을 은은하게 반영한다.

### 핵심 스타일 규칙
1. **배경:** 밝은 크림-아이보리 또는 연한 한지 색. 어두운 배경 사용하지 않는다.
2. **윤곽선:** 굵고 선명한 검정 아웃라인. 모든 오브젝트에 두꺼운 경계선.
3. **채색:** 플랫 컬러 — 그라디언트 없이 면 단위로 색을 채운다.
4. **색상 팔레트:** 빨강, 검정, 금/노랑, 파랑, 초록, 흰색. 이 6색 + 월별 식물 고유색만 사용.
5. **구도:** 전통 화투 카드의 레이아웃을 따름 — 식물은 아래에서 위로, 동물은 중앙~상단.
6. **질감:** 판화/목판화 느낌의 평면적 표현. 나뭇결 텍스처 힌트.
7. **저승 트위스트:** 전통 모티프를 80% 유지하되, 20%만 저승 요소로 변형.
8. **픽셀아트:** 16비트 스타일 픽셀아트로 렌더링. 안티앨리어싱 없이 선명한 픽셀 경계.

### 카드 등급별 밀도
- **광(光):** 가장 화려. 주인공 오브젝트가 크고, 배경 식물이 풍성. 좌하단에 붉은 원+광 표시 공간.
- **띠(홍단/청단/초단):** 중간 밀도. 식물 가지 + 대각선 띠(리본). 띠 위에 세로 텍스트.
- **열끗(10점):** 중간. 동물/사물이 주제. 금색 띠(노란 리본) 대각선 배치.
- **피(쌍피/일반피):** 식물 위주 간결한 구도. 잎/가지가 하단~중앙, 상단은 여백.

### 전통 화투 월별 모티프 (반드시 따를 것)
| 월 | 식물 | 광/열끗 동물 | 띠 색 |
|----|------|-------------|-------|
| 1 | 소나무 (松) | 학 (鶴) | 홍단 |
| 2 | 매화 (梅) | 꾀꼬리 (鶯) | 홍단 |
| 3 | 벚꽃 (桜) | — (장막/커튼) | 홍단 |
| 4 | 흑싸리 (藤) | 두견새 (杜鵑) | 초단 |
| 5 | 난초/창포 (菖蒲) | — (나무다리) | 초단 |
| 6 | 모란 (牡丹) | 나비 (蝶) | 청단 |
| 7 | 홍싸리 (萩) | 멧돼지 (猪) | 청단 |
| 8 | 억새/공산 (芒) | 기러기 (雁) | — |
| 9 | 국화 (菊) | 잔/술잔 (盃) | 청단 |
| 10 | 단풍 (楓) | 사슴 (鹿) | 청단 |
| 11 | 오동 (桐) | 봉황 (鳳) | — |
| 12 | 비 (雨) | 버드나무+제비 or 우산 사내 | — |

## 공통 프롬프트 프리픽스

> 모든 개별 카드 프롬프트 **앞에** 이 문장을 붙여 사용한다.

```
A single low-resolution pixel art illustration of a traditional Korean hwatu (flower card), made of large visible square pixels like a sprite from Stardew Valley. Drawn on a 60x84 pixel grid then scaled up — each individual pixel is clearly visible and you can count them. Blocky jagged edges, no smooth curves, no anti-aliasing, no soft gradients, no blending between pixels. Flat bold color fills with thick black pixel outlines on every shape. Woodblock print aesthetic. Limited color palette: red, black, gold, blue, green, and white only. Light cream-ivory background like aged hanji paper. No card frame, no border, no text overlay — only the interior illustration. All elements fully contained within image boundaries with comfortable margins — nothing cropped. Centered composition with breathing room on all sides.
```

### 이미지 넘침 방지 (필수)
모든 카드 프롬프트에 다음 원칙을 적용한다:
- **모든 요소가 이미지 경계 안에 완전히 들어와야 한다.** 잘리거나 프레임 밖으로 넘치는 요소 없음.
- **사방에 여유 마진을 확보한다.** 식물 가지, 동물 꼬리, 리본 끝 등이 경계에 닿지 않도록.
- **구도는 중앙 정렬.** 주요 오브젝트가 카드 중심에 오도록 배치.
- 코드에서 프레임(테두리 3px + 상단 25px + 하단 22px)을 씌우므로, 가장자리에 중요한 요소가 있으면 가려진다.

## 월별 카드 구성 (48장)
| 월 | 광 | 홍단 | 청단 | 초단 | 열끗 | 피 | 합계 |
|----|---|------|------|------|------|---|------|
| 1 | 1 | 1 | - | - | - | 2 | 4 |
| 2 | - | 1 | - | - | 1 | 2 | 4 |
| 3 | 1 | 1 | - | - | - | 2 | 4 |
| 4 | - | - | - | 1 | 1 | 2 | 4 |
| 5 | - | - | - | 1 | 1 | 2 | 4 |
| 6 | - | - | 1 | - | 1 | 2 | 4 |
| 7 | - | - | 1 | - | 1 | 2 | 4 |
| 8 | 1 | - | - | - | 1 | 2 | 4 |
| 9 | - | - | 1 | - | 1 | 2 | 4 |
| 10 | - | - | 1 | - | 1 | 2 | 4 |
| 11 | 1 | - | - | - | - | 3 | 4 |
| 12 | 1 | - | - | - | 1 | 2 | 4 |

## 후처리

```
1. 4장 중 최선 선택
2. Nearest Neighbor 다운스케일 → 90x130 (UI 표시 크기) 또는 80x120 (텍스처 크기)
3. 투명 배경 처리 불필요 — 한지 배경 유지
4. PNG 저장 → 코드에서 프레임 합성 (MockupSpriteFactory)
```

# 컨셉아트 — 공통 설정

## 역할
컨셉아트는 **게임에 직접 사용하지 않는다.**
캐릭터/보스의 **디자인 방향을 확정**하기 위한 레퍼런스.

```
컨셉아트 → "이 느낌으로 가자" 확정
             ↓
         도트 작업 또는 코드 스프라이트 개선의 기준점
```

## 생성 환경

```yaml
Model: Flux-dev (ComfyUI)
Resolution: 512 x 768 (세로 전신)
Steps: 20~30
Guidance: 3.5~4.0
Sampler: euler
Scheduler: normal
Batch: 8장씩 뽑아서 최선 선택 (컨셉은 많이 뽑아야 함)
```

### Flux-dev 프롬프트 규칙
- 네거티브 프롬프트 없음 — 원하지 않는 요소는 긍정 프롬프트에서 배제
- 가중치 문법 미사용 — 자연어로 강조
- LoRA는 ComfyUI 노드에서 별도 연결

## 공통 프롬프트 프리픽스

> 모든 컨셉아트 프롬프트 **앞에** 이 문장을 붙인다.

```
A character concept art in low-resolution pixel art style, made of large visible square pixels like a sprite from Undertale or Celeste. Full body view centered on plain solid bright green (#00FF00) background. Each individual pixel clearly visible. Blocky jagged edges, no smooth curves, no anti-aliasing, no soft gradients, no blending. Korean dark fantasy style with thick black pixel outlines, expressive face, bold flat color fills. Limited game palette: dark navy (#1A1A2E), blood red (#C41E3A), ghost fire cyan (#00D4FF), gold (#FFD700), hanji beige (#F5E6CA), bone white (#E8E8E8), deep purple (#6B2D5B). Standing pose. Fully contained with comfortable margins.
```

## 게임 내 캐릭터 표시 크기
- **보스 표시 영역:** 약 200x300px (화면 상단 중앙)
- **동료 도깨비:** 약 120x180px
- 캐릭터는 전투 화면 상단에 표시되며, 하단은 카드 영역(950x160)이 차지
- 컨셉아트는 직접 게임에 사용하지 않으므로 크기 제약 없음 (레퍼런스용)

## 활용 방법

1. **8장 배치 생성** → 느낌이 맞는 1~2장 선택
2. 선택한 이미지를 **팀 레퍼런스**로 저장
3. img2img로 표정/포즈 변형 시도
4. 최종적으로 이 레퍼런스를 보면서 **도트 스프라이트 제작**
5. 또는 결과물 자체를 게임 내 "일러스트 컷"으로 활용 (대화 장면 등)

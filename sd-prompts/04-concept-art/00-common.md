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
Model: Pony Diffusion V6 XL (ComfyUI)
LoRA: Binding of Isaac Style v2.1 (strength 0.60)
Resolution: 512 x 768 (세로 전신)
Sampler: euler_a
Steps: 25~30
CFG: 7
Batch: 8장씩 뽑아서 최선 선택 (컨셉은 많이 뽑아야 함)
```

## 공통 프롬프트 프리픽스

> 모든 컨셉아트 프롬프트 **앞에** 이 태그를 붙인다.

```
score_9, score_8_up, score_7_up, pixel art, game assets, chibi, simple green background, character concept art, full body view, Korean dark fantasy, blocky jagged edges, no smooth curves, no anti-aliasing, flat colors, thick black outlines, expressive face, limited game palette, standing pose, fully contained with margins
```

## 공통 네거티브 프롬프트

```
score_4, score_3, score_2, score_1, blurry, photo, realistic, 3d render, smooth shading, anti-aliasing, gradient, soft edges, watercolor, text, watermark, signature
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

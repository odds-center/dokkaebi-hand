# Dokkaebi's Hand — FLUX Dev LoRA 에셋 프롬프트

> **모델:** `black-forest-labs/flux-dev-lora` (Replicate)
> **LoRA:** 카테고리별 최적 LoRA 사용
> Replicate Playground JSON 탭에서 바로 복붙 가능.

---

## LoRA 매핑

**LoRA 없이 순수 FLUX Dev 사용** — 테스트 결과 LoRA 없는 FLUX Dev가 가장 좋은 픽셀아트 결과를 생성.

> 스타일 레퍼런스: Binding of Isaac + Shovel Knight
> 일관성을 위해 1장씩 생성 (num_outputs: 1) + seed 고정

---

## 공통 JSON 템플릿

```json
{
  "prompt": "[프롬프트]",
  "go_fast": false,
  "guidance": 7,
  "megapixels": "1",
  "num_outputs": 1,
  "aspect_ratio": "1:1",
  "output_format": "png",
  "output_quality": 100,
  "num_inference_steps": 50,
  "seed": [시드번호]
}
```

---

## 보스 표정 공통 색상 시스템

> 모든 보스가 상태별로 동일한 색상 효과를 공유. 개별 보스 색상 위에 오버레이.

| 상태 | 공통 색상 효과 | 설명 |
|------|--------------|------|
| `idle` | 없음 (기본 색상) | 평상시 |
| `hit` | **전신 흰색 플래시** + 빨간 테두리 | 피격 순간 0.3초 |
| `wounded` | **채도 -20%** + 균열/상처에서 **붉은 빛** | HP 50% 이하 |
| `critical` | **채도 -40%** + **붉은 맥동 글로우** + 떨림 | HP 20% 이하 |
| `defeat` | **전체 탈색 (거의 회색)** + **영혼 이탈 파란 빛** | HP 0 |
| `gimmick` | **보라색 마력 글로우** + 눈 발광 | 기믹 발동 |

> 이 색상 효과는 셰이더/코드로 처리 가능하지만, 프롬프트에서도 공통 묘사를 포함하여
> AI 생성 시 일관된 시각적 단서를 줌.

---

## 배경 제거 전략

- 캐릭터/아이콘: `solid pure green chroma key background` → 후처리 크로마키 제거
- 배경: 크로마키 없이 직접 사용 (dark purple 배경 유지)
- 카드: 크로마키 → 프레임 안에 합성

---

## 후처리

```
1. 4장 중 최선 선택
2. 크로마키 녹색 배경 제거 → 투명 알파 (rembg 또는 chroma key 스크립트)
3. Nearest Neighbor 다운스케일 → 게임 해상도
4. PNG (알파) → Assets/Art/ 해당 폴더
```

---

## 파일 구조

```
sd-prompts-flux/
  01-bosses.md           — 보스 스프라이트 14종
  02-boss-expressions.md — 보스 표정 70종
  03-companions.md       — 동료 도깨비 7종
  04-talismans.md        — 부적 아이콘 20종
  05-backgrounds.md      — 배경 14종
  06-card-illustrations.md — 화투패 48장
  07-card-extras.md      — 카드 뒷면/프레임 10종
  08-icons.md            — 업적/화폐/강화 아이콘 67종
  09-vfx.md              — 이펙트/파티클 16종
  10-ui-frames.md        — UI 프레임 25종
  11-hud-icons.md        — HUD 아이콘 21종
```

**총 에셋: ~312종**

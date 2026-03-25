# [아카이브] ComfyUI 아트 파이프라인 계획서

> **이 문서는 아카이브되었습니다.**
> 초기에는 로컬 ComfyUI 워크플로우 + Python API 자동화를 계획했으나,
> 현재는 **Replicate API (FLUX Dev)** 기반 클라우드 파이프라인으로 전환하였습니다.
>
> **현재 아트 파이프라인 가이드:** [`pixel-art-generator/GUIDE.md`](../pixel-art-generator/GUIDE.md)

---

## 현재 파이프라인 아키텍처

```
┌──────────────────────────────────────────────────────────┐
│                  batch_generate.py                         │
│  (메인 CLI — 카테고리별/개별/배치 생성)                     │
├──────────────────────────────────────────────────────────┤
│                                                            │
│  1. sd-prompts-flux/*.md  ← 카테고리별 프롬프트 정의         │
│         ↓                                                  │
│  2. parse_prompts.py      ← md 파싱 + Pony 태그 정리        │
│         ↓                                                  │
│  3. Replicate API         ← FLUX Dev 모델 호출              │
│     (black-forest-labs/flux-dev)                            │
│         ↓                                                  │
│  4. post_process.py       ← 배경 제거, 리사이즈, 시트 생성   │
│         ↓                                                  │
│  5. output/               ← 카테고리별 정리된 PNG            │
│         ↓                                                  │
│  6. Assets/Art/           ← Unity 프로젝트에 배치            │
│                                                            │
└──────────────────────────────────────────────────────────┘
```

## 프롬프트 구조 (sd-prompts-flux/)

| 파일 | 카테고리 | 에셋 수 |
|------|---------|---------|
| `01-bosses.md` | 보스 스프라이트 | 10+ |
| `02-boss-expressions.md` | 보스 표정 변형 | 다수 |
| `03-companions.md` | 동료 도깨비 | 7+ |
| `04-talismans.md` | 부적 아이콘 | 20+ |
| `05-backgrounds.md` | 게임 배경 | 7+ |
| `06-card-illustrations.md` | 화투 카드 48장 | 48 |
| `07-card-extras.md` | 카드 뒷면/강화 | 10+ |
| `08-icons.md` | UI 아이콘 | 87+ |
| `09-vfx.md` | VFX 이펙트 | 16+ |
| `10-ui-frames.md` | UI 프레임/패널 | 25+ |
| `11-hud-icons.md` | HUD 아이콘 | 21+ |

## 카테고리별 설정 (config.py)

| 카테고리 | 종횡비 | 출력 폴더 |
|---------|--------|----------|
| bosses | 1:1 | `output/bosses/` |
| boss-expressions | 1:1 | `output/boss-expressions/` |
| companions | 2:3 | `output/companions/` |
| talismans | 1:1 | `output/talismans/` |
| backgrounds | 16:9 | `output/backgrounds/` |
| card-illustrations | 2:3 | `output/card-illustrations/` |
| card-extras | 2:3 | `output/card-extras/` |
| icons | 1:1 | `output/icons/` |
| vfx | 1:1 | `output/vfx/` |
| ui-frames | 16:9 | `output/ui-frames/` |
| hud-icons | 1:1 | `output/hud-icons/` |

## 생성 설정

```python
MODEL_ID = "black-forest-labs/flux-dev"
DEFAULT_STEPS = 50
DEFAULT_GUIDANCE = 7.0
```

## 비용 예상

전체 ~414종 기준:
- 1장씩: ~$1.65
- 4장씩 (베스트 선택): ~$6.60

자세한 사용법 및 커맨드는 [`pixel-art-generator/GUIDE.md`](../pixel-art-generator/GUIDE.md) 참조.

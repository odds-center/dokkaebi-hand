# [아카이브] ComfyUI 모델 다운로드 목록

> **이 문서는 아카이브되었습니다.**
> 초기에는 로컬 ComfyUI + Pony Diffusion V6 XL + TBOI LoRA 조합을 사용했으나,
> 현재는 **Replicate API (FLUX Dev)** 기반 클라우드 파이프라인으로 전환하였습니다.
>
> **현재 아트 파이프라인 가이드:** [`pixel-art-generator/GUIDE.md`](../pixel-art-generator/GUIDE.md)

---

## 파이프라인 변천사

| 시기 | 파이프라인 | 비고 |
|------|-----------|------|
| v1 | 로컬 ComfyUI + Pony V6 XL + TBOI LoRA | Mac M3 Pro 로컬 실행, 속도 느림 |
| v2 | 로컬 ComfyUI → Pony 프롬프트 전면 전환 | Pony 태그 형식 적용 (~340종) |
| **v3 (현재)** | **Replicate API + FLUX Dev** | **클라우드 API, 빠르고 저렴** |

## 현재 파이프라인 요약

- **모델:** `black-forest-labs/flux-dev` (Replicate API)
- **프롬프트 소스:** `sd-prompts-flux/` (12개 카테고리, 300+ 에셋)
- **생성 도구:** `pixel-art-generator/batch_generate.py`
- **설정 파일:** `pixel-art-generator/config.py`
- **후처리:** `pixel-art-generator/post_process.py` (배경 제거, 리사이즈, 스프라이트시트)
- **비용:** 전체 ~414종 기준 약 $1.65 (1장씩) ~ $6.60 (4장씩)

자세한 사용법은 [`pixel-art-generator/GUIDE.md`](../pixel-art-generator/GUIDE.md) 참조.

# [아카이브] Stable Diffusion 설치 & 실행 가이드

> **이 문서는 아카이브되었습니다.**
> 초기에는 로컬 ComfyUI/A1111/Diffusers로 이미지를 생성했으나,
> 현재는 **Replicate API (FLUX Dev)** 기반으로 전환하여 로컬 설치가 불필요합니다.
>
> **현재 아트 파이프라인 가이드:** [`pixel-art-generator/GUIDE.md`](../pixel-art-generator/GUIDE.md)

---

## 현재 환경 요구사항

| 항목 | 값 |
|------|-----|
| Python | 3.10+ |
| 패키지 | `replicate`, `requests`, `python-dotenv`, `Pillow` |
| API 토큰 | Replicate API Token (`pixel-art-generator/.env`) |
| GPU | **불필요** (클라우드 API 사용) |

### 빠른 시작

```bash
cd pixel-art-generator
python -m venv venv
source venv/bin/activate  # Mac/Linux
pip install -r requirements.txt
cp .env.example .env
# .env에 REPLICATE_API_TOKEN 입력

# 에셋 목록 확인
python batch_generate.py list

# 테스트 생성
python batch_generate.py bosses --only boss_glutton
```

자세한 사용법은 [`pixel-art-generator/GUIDE.md`](../pixel-art-generator/GUIDE.md) 참조.

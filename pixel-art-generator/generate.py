"""
Google Nano Banana 2 API를 사용한 픽셀아트 이미지 생성기
- sd-prompts-flux/ 프롬프트로 생성
- 1장씩 생성 + seed 고정으로 일관성 유지
"""
import replicate
from pathlib import Path
from config import (
    MODEL_ID,
    DEFAULT_RESOLUTION,
    DEFAULT_OUTPUT_FORMAT,
    OUTPUT_DIR,
    CATEGORY_CONFIG,
)


def ensure_output_dirs():
    """출력 디렉토리 생성"""
    for cat_config in CATEGORY_CONFIG.values():
        out_dir = OUTPUT_DIR / cat_config["output_dir"]
        out_dir.mkdir(parents=True, exist_ok=True)


def generate(
    prompt: str,
    name: str,
    category: str = "bosses",
    seed: int = None,
    aspect_ratio: str = None,
    resolution: str = None,
    reference_image: str | Path = None,
) -> Path | None:
    """
    Nano Banana 2로 픽셀아트 이미지 1장 생성

    Args:
        prompt: 생성 프롬프트
        name: 파일명 (확장자 제외)
        category: CATEGORY_CONFIG 키
        seed: 시드 (재현성)
        aspect_ratio: 비율 오버라이드 (없으면 카테고리 기본값)
        resolution: 해상도 오버라이드 (기본 "1K")

    Returns:
        저장된 파일 경로 (실패시 None)
    """
    ensure_output_dirs()

    cat_config = CATEGORY_CONFIG.get(category, {"output_dir": "misc", "aspect_ratio": "1:1"})
    save_dir = OUTPUT_DIR / cat_config["output_dir"]
    save_dir.mkdir(parents=True, exist_ok=True)

    filename = f"{name}.png"
    save_path = save_dir / filename

    ratio = aspect_ratio or cat_config["aspect_ratio"]
    res = resolution or DEFAULT_RESOLUTION
    print(f"[생성중] {name} (ratio={ratio}, res={res}, seed={seed})...")

    # 레퍼런스 이미지 준비
    image_input = []
    if reference_image:
        ref_path = Path(reference_image)
        if ref_path.exists():
            image_input = [open(ref_path, "rb")]
            print(f"  [레퍼런스] {ref_path.name}")

    input_params = {
        "prompt": prompt,
        "resolution": res,
        "aspect_ratio": ratio,
        "output_format": DEFAULT_OUTPUT_FORMAT,
        "image_input": image_input,
        "image_search": False,
        "google_search": False,
    }

    if seed is not None:
        input_params["seed"] = seed

    try:
        output = replicate.run(MODEL_ID, input=input_params)

        # Nano Banana 2: 단일 FileOutput 객체 반환
        if hasattr(output, 'read'):
            with open(save_path, "wb") as f:
                f.write(output.read())
        elif hasattr(output, 'url'):
            import requests
            response = requests.get(output.url)
            response.raise_for_status()
            with open(save_path, "wb") as f:
                f.write(response.content)
        elif isinstance(output, list):
            item = output[0]
            if hasattr(item, 'read'):
                with open(save_path, "wb") as f:
                    f.write(item.read())
            elif hasattr(item, 'url'):
                import requests
                response = requests.get(item.url)
                response.raise_for_status()
                with open(save_path, "wb") as f:
                    f.write(response.content)
            else:
                import requests
                response = requests.get(str(item))
                response.raise_for_status()
                with open(save_path, "wb") as f:
                    f.write(response.content)
        else:
            import requests
            response = requests.get(str(output))
            response.raise_for_status()
            with open(save_path, "wb") as f:
                f.write(response.content)

        print(f"  [완료] → {save_path}")
        return save_path

    except Exception as e:
        print(f"  [에러] {name}: {e}")
        return None


def generate_boss(boss_id: str, prompt: str, seed: int) -> Path | None:
    """보스 스프라이트 생성"""
    return generate(prompt, boss_id, category="bosses", seed=seed)



def generate_talisman(talisman_id: str, prompt: str, seed: int) -> Path | None:
    """부적 아이콘 생성"""
    return generate(prompt, talisman_id, category="talismans", seed=seed)


def generate_card(card_id: str, prompt: str, seed: int) -> Path | None:
    """화투 카드 생성"""
    return generate(prompt, card_id, category="card-illustrations", seed=seed)


def generate_background(bg_id: str, prompt: str, seed: int) -> Path | None:
    """배경 생성"""
    return generate(prompt, bg_id, category="backgrounds", seed=seed)


def generate_icon(icon_id: str, prompt: str, seed: int) -> Path | None:
    """아이콘 생성"""
    return generate(prompt, icon_id, category="icons", seed=seed)


if __name__ == "__main__":
    # 테스트 — 먹보 도깨비
    generate_boss(
        boss_id="boss_glutton",
        prompt=(
            "Pixel art game boss sprite, front-facing centered, flat cel shading, "
            "thick black outlines, large round gluttonous Korean dokkaebi demon, "
            "massive protruding belly, stubby thick limbs, reddish-orange skin, "
            "short broken horns, enormous wide mouth with gold-capped teeth, "
            "small greedy deep-set eyes, tattered dark loincloth, food stains on body, "
            "arms akimbo confident laughing, menacing yet comedic, "
            "solid pure green background, single character with margins, "
            "sharp pixels, no anti-aliasing, no gradients, no text, no ground, no floor, "
            "16-bit retro game style"
        ),
        seed=70001,
    )

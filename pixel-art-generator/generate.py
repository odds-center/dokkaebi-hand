"""
FLUX Dev API를 사용한 픽셀아트 이미지 생성기
- sd-prompts-flux/ 프롬프트로 생성
- 1장씩 생성 + seed 고정으로 일관성 유지
"""
import replicate
from pathlib import Path
from config import (
    MODEL_ID,
    DEFAULT_STEPS,
    DEFAULT_GUIDANCE,
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
) -> Path | None:
    """
    FLUX Dev로 픽셀아트 이미지 1장 생성

    Args:
        prompt: 생성 프롬프트
        name: 파일명 (확장자 제외)
        category: CATEGORY_CONFIG 키
        seed: 시드 (재현성)
        aspect_ratio: 비율 오버라이드 (없으면 카테고리 기본값)

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
    print(f"[생성중] {name} (ratio={ratio}, seed={seed})...")

    input_params = {
        "prompt": prompt,
        "aspect_ratio": ratio,
        "output_format": "png",
        "output_quality": 100,
        "num_outputs": 1,
        "num_inference_steps": DEFAULT_STEPS,
        "guidance": DEFAULT_GUIDANCE,
        "go_fast": False,
        "megapixels": "1",
        "disable_safety_checker": True,
    }

    if seed is not None:
        input_params["seed"] = seed

    try:
        output = replicate.run(MODEL_ID, input=input_params)

        # output에서 파일 저장
        if isinstance(output, list):
            item = output[0]
        elif hasattr(output, '__iter__'):
            item = next(iter(output))
        else:
            item = output

        # FileOutput 객체 처리
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

        print(f"  [완료] → {save_path}")
        return save_path

    except Exception as e:
        print(f"  [에러] {name}: {e}")
        return None


def generate_boss(boss_id: str, prompt: str, seed: int) -> Path | None:
    """보스 스프라이트 생성"""
    return generate(prompt, boss_id, category="bosses", seed=seed)


def generate_boss_expression(boss_id: str, state: str, prompt: str, seed: int) -> Path | None:
    """보스 표정 변형 생성"""
    return generate(prompt, f"{boss_id}_{state}", category="boss-expressions", seed=seed)


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
    # 테스트 — 장난꾸러기 도깨비
    generate_boss(
        boss_id="boss_trickster",
        prompt=(
            "Simple 16-bit pixel art game boss sprite, low resolution retro style, "
            "limited color palette max 16 colors, Korean dokkaebi folklore demon, "
            "lean mischievous prankster, wiry thin body, exaggerated long arms, "
            "blue-gray skin, sly wide grin, two curved horns backward, large pointed ears, "
            "ragged dark vest, asymmetric eyes one larger, holding wooden club behind back, "
            "crouching ready-to-pounce, playful but unsettling, "
            "solid pure green chroma key background, clean pixel grid, "
            "no anti-aliasing, no gradients, no text, no letters, no words, "
            "no watermark, no signature, "
            "inspired by Binding of Isaac and Shovel Knight pixel art style"
        ),
        seed=70002,
    )

"""
Replicate API를 사용한 픽셀아트 이미지 생성기
- sd-prompts/ md 파일의 프롬프트를 파싱하여 생성
"""
import replicate
import requests
import time
from pathlib import Path
from config import (
    MODEL_ID,
    DEFAULT_STEPS,
    DEFAULT_GUIDANCE,
    NEGATIVE_PROMPT,
    OUTPUT_DIR,
    CATEGORY_CONFIG,
)
from parse_prompts import PromptEntry


def ensure_output_dirs():
    """출력 디렉토리 생성"""
    for cat_config in CATEGORY_CONFIG.values():
        out_dir = OUTPUT_DIR / cat_config["output_dir"]
        out_dir.mkdir(parents=True, exist_ok=True)


def generate_from_entry(entry: PromptEntry, batch_index: int = 0) -> Path | None:
    """
    PromptEntry로부터 이미지 생성

    Args:
        entry: 파싱된 프롬프트 엔트리
        batch_index: 배치 내 인덱스 (같은 프롬프트로 여러 장 생성시)

    Returns:
        저장된 파일 경로 (실패시 None)
    """
    ensure_output_dirs()

    cat_config = CATEGORY_CONFIG.get(entry.category, {})
    out_dir_name = cat_config.get("output_dir", "misc")
    save_dir = OUTPUT_DIR / out_dir_name
    save_dir.mkdir(parents=True, exist_ok=True)

    # 파일명
    suffix = f"_{batch_index}" if batch_index > 0 else ""
    filename = f"{entry.name}{suffix}.png"
    save_path = save_dir / filename

    print(f"[생성중] {entry.name} ({entry.width}x{entry.height}) seed={entry.seed}...")

    prompt = entry.full_prompt
    negative = entry._clean_pony_tags(entry.negative) if entry.negative else NEGATIVE_PROMPT

    input_params = {
        "prompt": prompt,
        "width": entry.width,
        "height": entry.height,
        "guidance": DEFAULT_GUIDANCE,
        "num_inference_steps": DEFAULT_STEPS,
    }

    if entry.seed is not None:
        input_params["seed"] = entry.seed + batch_index

    try:
        output = replicate.run(MODEL_ID, input=input_params)

        # output 타입 처리
        if isinstance(output, list):
            image_url = str(output[0])
        elif hasattr(output, '__iter__'):
            image_url = str(next(iter(output)))
        else:
            image_url = str(output)

        # 이미지 다운로드
        response = requests.get(image_url)
        response.raise_for_status()

        with open(save_path, "wb") as f:
            f.write(response.content)

        print(f"  [완료] → {save_path}")
        return save_path

    except Exception as e:
        print(f"  [에러] {entry.name}: {e}")
        return None


def generate_single(
    prompt: str,
    name: str = "custom",
    category: str = "06-game-sprites",
    width: int = 512,
    height: int = 512,
    seed: int = None,
) -> Path | None:
    """
    커스텀 프롬프트로 단일 이미지 생성 (md 파일 없이)
    """
    entry = PromptEntry(
        name=name,
        prompt=prompt,
        common_prefix="pixel art, 16-bit retro game style, flat colors, thick black outlines",
        negative=NEGATIVE_PROMPT,
        seed=seed,
        category=category,
        width=width,
        height=height,
    )
    return generate_from_entry(entry)


if __name__ == "__main__":
    # 간단 테스트
    generate_single(
        prompt="Korean dokkaebi demon warrior, red skin, horns, holding magic club, solid green background",
        name="test_dokkaebi",
        seed=42,
    )

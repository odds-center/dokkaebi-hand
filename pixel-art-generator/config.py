"""
픽셀아트 생성기 설정
- sd-prompts/ 의 기존 md 파일을 파싱하여 Replicate API로 생성
"""
import os
from pathlib import Path
from dotenv import load_dotenv

load_dotenv()

# API 설정
REPLICATE_API_TOKEN = os.getenv("REPLICATE_API_TOKEN")

# 모델 설정 — 무료 모델 (FLUX Dev)
MODEL_ID = "black-forest-labs/flux-dev"

# 기본 생성 설정
DEFAULT_STEPS = 25
DEFAULT_GUIDANCE = 7.0

# 경로
BASE_DIR = Path(__file__).parent
PROJECT_DIR = BASE_DIR.parent  # dokkaebi-hand/
SD_PROMPTS_DIR = PROJECT_DIR / "sd-prompts"
OUTPUT_DIR = BASE_DIR / "output"

# 공통 네거티브 프롬프트 (Pony 태그 제거, 순수 영어)
NEGATIVE_PROMPT = (
    "blurry, photo, realistic, 3d render, smooth shading, anti-aliasing, "
    "gradient, soft edges, watercolor, text, watermark, signature"
)

# sd-prompts 폴더 → 출력 폴더 + 생성 설정 매핑
CATEGORY_CONFIG = {
    "01-backgrounds": {
        "output_dir": "backgrounds",
        "width": 640,
        "height": 360,
    },
    "02-card-illustrations": {
        "output_dir": "card-illustrations",
        "width": 240,
        "height": 336,
    },
    "03-textures": {
        "output_dir": "textures",
        "width": 256,
        "height": 256,
    },
    "04-concept-art": {
        "output_dir": "concept-art",
        "width": 512,
        "height": 512,
    },
    "05-calligraphy": {
        "output_dir": "calligraphy",
        "width": 512,
        "height": 256,
    },
    "06-game-sprites": {
        "output_dir": "game-sprites",
        "width": 800,
        "height": 800,
    },
    "07-icons": {
        "output_dir": "icons",
        "width": 128,
        "height": 128,
    },
    "08-illustrations": {
        "output_dir": "illustrations",
        "width": 1024,
        "height": 768,
    },
    "09-card-extras": {
        "output_dir": "card-extras",
        "width": 240,
        "height": 336,
    },
    "10-vfx": {
        "output_dir": "vfx",
        "width": 256,
        "height": 256,
    },
    "11-ui-frames": {
        "output_dir": "ui-frames",
        "width": 512,
        "height": 512,
    },
    "12-hud-icons": {
        "output_dir": "hud-icons",
        "width": 128,
        "height": 128,
    },
}

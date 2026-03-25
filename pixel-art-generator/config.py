"""
픽셀아트 생성기 설정
- sd-prompts-flux/ 프롬프트를 Google Nano Banana 2 API로 생성
- 기존 FLUX Dev에서 전환 (2026-03)
"""
import os
from pathlib import Path
from dotenv import load_dotenv

load_dotenv()

# API 설정
REPLICATE_API_TOKEN = os.getenv("REPLICATE_API_TOKEN")

# 모델 설정 — Google Nano Banana 2
MODEL_ID = "google/nano-banana-2"

# 기본 생성 설정
DEFAULT_RESOLUTION = "1K"
DEFAULT_OUTPUT_FORMAT = "png"

# 경로
BASE_DIR = Path(__file__).parent
PROJECT_DIR = BASE_DIR.parent  # dokkaebi-hand/
SD_PROMPTS_DIR = PROJECT_DIR / "sd-prompts-flux"
OUTPUT_DIR = BASE_DIR / "output"

# 카테고리별 설정 (aspect_ratio 기반)
CATEGORY_CONFIG = {
    "bosses": {
        "output_dir": "bosses",
        "aspect_ratio": "1:1",
    },
    "companions": {
        "output_dir": "companions",
        "aspect_ratio": "2:3",
    },
    "talismans": {
        "output_dir": "talismans",
        "aspect_ratio": "1:1",
    },
    "backgrounds": {
        "output_dir": "backgrounds",
        "aspect_ratio": "16:9",
    },
    "card-illustrations": {
        "output_dir": "card-illustrations",
        "aspect_ratio": "2:3",
    },
    "card-extras": {
        "output_dir": "card-extras",
        "aspect_ratio": "2:3",
    },
    "icons": {
        "output_dir": "icons",
        "aspect_ratio": "1:1",
    },
    "vfx": {
        "output_dir": "vfx",
        "aspect_ratio": "1:1",
    },
    "ui-frames": {
        "output_dir": "ui-frames",
        "aspect_ratio": "16:9",
    },
    "hud-icons": {
        "output_dir": "hud-icons",
        "aspect_ratio": "1:1",
    },
}

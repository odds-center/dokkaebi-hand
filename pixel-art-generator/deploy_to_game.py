"""
생성된 에셋을 게임(Love2D)에 배포하는 스크립트
1. 크로마키(녹색 배경) 제거 → 투명 PNG
2. 카드 프레임: 녹색 외부 + 검정 내부 모두 투명화 (장식 테두리만 남김)
3. 게임용 크기로 리사이즈 (Nearest Neighbor)
4. Love2D assets/sprites/ 폴더로 복사
"""
from pathlib import Path
from PIL import Image
import tempfile, os
from post_process import remove_green_background, remove_card_frame_background, resize_for_game

BASE_DIR = Path(__file__).parent
OUTPUT_DIR = BASE_DIR / "output"
GAME_SPRITES = BASE_DIR.parent / "dokkaebi-love2d" / "assets" / "sprites"

# 게임용 크기 설정
SIZES = {
    "bosses":             (128, 128),   # 보스 스프라이트
    "companions":         (80, 120),    # 동료 (2:3)
    "talismans":          (48, 48),     # 부적 아이콘
    "card-illustrations": (60, 90),     # 카드 일러스트 (2:3)
    "backgrounds":        (480, 270),   # 배경 (16:9)
    "hud-icons":          (32, 32),     # HUD 아이콘
    "vfx":                (64, 64),     # VFX 이펙트
    "icons":              (80, 80),     # 범용 아이콘 (축복 등)
    "ui-frames":          None,         # 카드 프레임: 크기별로 개별 처리
}

# 카드 프레임 파일별 크기 (카드 비율 유지)
CARD_FRAME_SIZES = {
    "ui_card_frame_gwang":    (80, 112),   # 광 카드 프레임
    "ui_card_frame_tti":      (80, 112),   # 띠 카드 프레임
    "ui_card_frame_yeolkkeut":(80, 112),   # 그림 카드 프레임
    "ui_card_frame_pi":       (80, 112),   # 피 카드 프레임
}
# 카드 프레임 외 ui-frames 기본 크기
UI_FRAME_DEFAULT_SIZE = (480, 270)

# 크로마키 제거 안 하는 카테고리
NO_CHROMAKEY = {"backgrounds"}

# 카드 프레임 파일 접두사 (외부+내부 투명화 처리)
CARD_FRAME_PREFIX = "ui_card_frame_"


def _process_file(png: Path, dest_path: Path, target_size: tuple, is_card_frame: bool):
    """파일 하나 처리: 크로마키 제거 → 리사이즈 → 저장"""
    with tempfile.NamedTemporaryFile(suffix=".png", delete=False) as tmp:
        tmp_path = tmp.name
    try:
        if is_card_frame:
            # 카드 프레임: 녹색 외부 + 검정 내부 모두 투명화
            remove_card_frame_background(str(png), tmp_path)
        else:
            # 일반 크로마키: 녹색 배경만 제거
            remove_green_background(str(png), tmp_path)

        img = Image.open(tmp_path).convert("RGBA")
        resized = img.resize(target_size, Image.NEAREST)
        resized.save(dest_path)
    finally:
        os.unlink(tmp_path)


def process_category(category: str):
    """카테고리 하나 처리"""
    src_dir = OUTPUT_DIR / category
    if not src_dir.exists():
        print(f"  [스킵] {category} — 폴더 없음")
        return

    png_files = sorted(src_dir.glob("*.png"))
    if not png_files:
        print(f"  [스킵] {category} — 이미지 없음")
        return

    dest_dir = GAME_SPRITES / category
    dest_dir.mkdir(parents=True, exist_ok=True)

    print(f"\n  [{category}] {len(png_files)}개")

    for png in png_files:
        if "_transparent" in png.stem or "_resized" in png.stem or "_frame" in png.stem:
            continue

        dest_path = dest_dir / png.name

        if category in NO_CHROMAKEY:
            # 배경: 크로마키 없이 리사이즈만
            target_size = SIZES[category]
            resize_for_game(str(png), target_size, str(dest_path))

        elif category == "ui-frames":
            # 카드 프레임 vs 일반 UI 프레임 분기
            is_card_frame = png.stem.startswith(CARD_FRAME_PREFIX)
            if is_card_frame:
                target_size = CARD_FRAME_SIZES.get(png.stem, (80, 112))
                _process_file(png, dest_path, target_size, is_card_frame=True)
            else:
                _process_file(png, dest_path, UI_FRAME_DEFAULT_SIZE, is_card_frame=False)

        else:
            target_size = SIZES.get(category, (64, 64))
            _process_file(png, dest_path, target_size, is_card_frame=False)

        print(f"    ✓ {png.name}")

    print(f"  → {dest_dir}")


def deploy_all():
    print("=" * 60)
    print("  에셋 배포: output/ → Love2D assets/sprites/")
    print("=" * 60)
    for category in SIZES:
        process_category(category)
    print("\n" + "=" * 60)
    print("  배포 완료!")
    print(f"  게임 폴더: {GAME_SPRITES}")
    print("=" * 60)


if __name__ == "__main__":
    deploy_all()

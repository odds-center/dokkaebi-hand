"""
이미 게임 폴더에 있는 스프라이트들을 재처리
output/ 원본 → 크로마키 재제거 → assets/sprites/ 덮어쓰기

사용법:
  python reprocess_sprites.py                        # 전체
  python reprocess_sprites.py card-illustrations     # 특정 카테고리
  python reprocess_sprites.py ui-frames              # 카드 프레임 재처리
"""
from pathlib import Path
from PIL import Image
import tempfile, os, sys
from post_process import remove_green_background, remove_card_frame_background

BASE_DIR    = Path(__file__).parent
OUTPUT_DIR  = BASE_DIR / "output"
GAME_SPRITES = BASE_DIR.parent / "dokkaebi-love2d" / "assets" / "sprites"

SIZES = {
    "bosses":             (128, 128),
    "companions":         (80, 120),
    "talismans":          (48, 48),
    "card-illustrations": (60, 90),
    "hud-icons":          (32, 32),
    "vfx":                (64, 64),
}

CARD_FRAME_SIZES = {
    "ui_card_frame_gwang":     (130, 182),   # 카드 최대 크기에 맞춤 (1:1.4 비율)
    "ui_card_frame_tti":       (130, 182),
    "ui_card_frame_yeolkkeut": (130, 182),
    "ui_card_frame_pi":        (130, 182),
}
UI_FRAME_DEFAULT_SIZE = (480, 270)
CARD_FRAME_PREFIX = "ui_card_frame_"
NO_CHROMAKEY = {"backgrounds"}


def _process_file(src: Path, dest: Path, size: tuple, is_card_frame=False):
    with tempfile.NamedTemporaryFile(suffix=".png", delete=False) as tmp:
        tmp_path = tmp.name
    try:
        if is_card_frame:
            remove_card_frame_background(str(src), tmp_path)
        else:
            remove_green_background(str(src), tmp_path)
        img = Image.open(tmp_path).convert("RGBA")
        img.resize(size, Image.NEAREST).save(dest)
    finally:
        os.unlink(tmp_path)


def reprocess_category(category: str):
    src_dir = OUTPUT_DIR / category
    if not src_dir.exists():
        print(f"  [스킵] {category} — output 폴더 없음")
        return

    # _transparent, _resized, _processed 등 이미 후처리된 파일만 제외
    png_files = [p for p in sorted(src_dir.glob("*.png"))
                 if not p.stem.endswith("_transparent")
                 and not p.stem.endswith("_resized")
                 and not p.stem.endswith("_processed")]
    if not png_files:
        print(f"  [스킵] {category} — 이미지 없음")
        return

    dest_dir = GAME_SPRITES / category
    dest_dir.mkdir(parents=True, exist_ok=True)

    print(f"\n[{category}] {len(png_files)}개 재처리")

    for png in png_files:
        dest = dest_dir / png.name

        if category in NO_CHROMAKEY:
            img = Image.open(png)
            img.resize(UI_FRAME_DEFAULT_SIZE, Image.NEAREST).save(dest)

        elif category == "ui-frames":
            is_card_frame = png.stem.startswith(CARD_FRAME_PREFIX)
            size = CARD_FRAME_SIZES.get(png.stem, UI_FRAME_DEFAULT_SIZE) if is_card_frame else UI_FRAME_DEFAULT_SIZE
            _process_file(png, dest, size, is_card_frame=is_card_frame)

        else:
            size = SIZES.get(category, (64, 64))
            _process_file(png, dest, size)

        print(f"  ✓ {png.name}")

    print(f"  → {dest_dir}")


def reprocess_all():
    print("=" * 60)
    print("  스프라이트 전체 재처리 (BFS 크로마키)")
    print("=" * 60)
    for cat in list(SIZES.keys()) + ["ui-frames", "backgrounds"]:
        reprocess_category(cat)
    print("\n완료!")


if __name__ == "__main__":
    if len(sys.argv) > 1:
        for cat in sys.argv[1:]:
            reprocess_category(cat)
    else:
        reprocess_all()

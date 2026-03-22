"""
후처리 도구
- 녹색 배경 제거 (크로마키)
- 리사이즈 (게임용 크기로)
- 스프라이트 시트 생성
"""
from pathlib import Path
from PIL import Image
import argparse


def remove_green_background(
    input_path: str,
    output_path: str = None,
    tolerance: int = 80,
):
    """
    녹색(#00FF00) 배경을 투명으로 변환

    Args:
        input_path: 입력 이미지 경로
        output_path: 출력 경로 (None이면 _transparent 접미사)
        tolerance: 녹색 허용 범위 (0~255, 높을수록 더 많이 제거)
    """
    img = Image.open(input_path).convert("RGBA")
    pixels = img.load()

    for y in range(img.height):
        for x in range(img.width):
            r, g, b, a = pixels[x, y]
            # 녹색 배경 판별
            if g > 200 and r < tolerance and b < tolerance:
                pixels[x, y] = (0, 0, 0, 0)

    if output_path is None:
        p = Path(input_path)
        output_path = str(p.parent / f"{p.stem}_transparent{p.suffix}")

    img.save(output_path)
    print(f"  [배경제거] {output_path}")
    return output_path


def resize_for_game(
    input_path: str,
    target_size: tuple[int, int],
    output_path: str = None,
):
    """
    게임용 크기로 리사이즈 (FilterMode.Point 유지)

    Args:
        input_path: 입력 이미지 경로
        target_size: (width, height) 목표 크기
        output_path: 출력 경로 (None이면 _resized 접미사)
    """
    img = Image.open(input_path)

    # NEAREST = FilterMode.Point (픽셀 보존)
    resized = img.resize(target_size, Image.NEAREST)

    if output_path is None:
        p = Path(input_path)
        output_path = str(p.parent / f"{p.stem}_{target_size[0]}x{target_size[1]}{p.suffix}")

    resized.save(output_path)
    print(f"  [리사이즈] {target_size[0]}x{target_size[1]} → {output_path}")
    return output_path


def create_sprite_sheet(
    image_paths: list[str],
    output_path: str,
    columns: int = 4,
    cell_size: tuple[int, int] = None,
):
    """
    여러 이미지를 스프라이트 시트로 합치기

    Args:
        image_paths: 이미지 경로 리스트
        output_path: 출력 스프라이트 시트 경로
        columns: 열 개수
        cell_size: 각 셀 크기 (None이면 첫 이미지 크기)
    """
    if not image_paths:
        print("  [에러] 이미지 없음")
        return

    images = [Image.open(p).convert("RGBA") for p in image_paths]

    if cell_size is None:
        cell_size = (images[0].width, images[0].height)

    rows = (len(images) + columns - 1) // columns
    sheet_width = cell_size[0] * columns
    sheet_height = cell_size[1] * rows

    sheet = Image.new("RGBA", (sheet_width, sheet_height), (0, 0, 0, 0))

    for i, img in enumerate(images):
        row = i // columns
        col = i % columns
        x = col * cell_size[0]
        y = row * cell_size[1]

        # 셀 크기에 맞게 리사이즈
        resized = img.resize(cell_size, Image.NEAREST)
        sheet.paste(resized, (x, y))

    sheet.save(output_path)
    print(f"  [스프라이트시트] {columns}x{rows} ({len(images)}개) → {output_path}")
    return output_path


def batch_remove_background(folder: str, tolerance: int = 80):
    """폴더 내 모든 PNG의 녹색 배경 제거"""
    folder_path = Path(folder)
    output_dir = folder_path / "transparent"
    output_dir.mkdir(exist_ok=True)

    png_files = sorted(folder_path.glob("*.png"))
    print(f"\n  [{folder_path.name}] {len(png_files)}개 이미지 배경 제거 중...")

    for png in png_files:
        if "_transparent" in png.stem:
            continue
        out = str(output_dir / f"{png.stem}.png")
        remove_green_background(str(png), out, tolerance)

    print(f"  완료! → {output_dir}")


def batch_resize(folder: str, target_size: tuple[int, int]):
    """폴더 내 모든 PNG를 게임용 크기로 리사이즈"""
    folder_path = Path(folder)
    output_dir = folder_path / f"resized_{target_size[0]}x{target_size[1]}"
    output_dir.mkdir(exist_ok=True)

    png_files = sorted(folder_path.glob("*.png"))
    print(f"\n  [{folder_path.name}] {len(png_files)}개 이미지 리사이즈 중...")

    for png in png_files:
        out = str(output_dir / png.name)
        resize_for_game(str(png), target_size, out)

    print(f"  완료! → {output_dir}")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="픽셀아트 후처리 도구")
    sub = parser.add_subparsers(dest="command")

    # 배경 제거
    bg_parser = sub.add_parser("remove-bg", help="녹색 배경 제거")
    bg_parser.add_argument("input", help="이미지 파일 또는 폴더 경로")
    bg_parser.add_argument("--tolerance", type=int, default=80, help="녹색 허용 범위 (0-255)")

    # 리사이즈
    resize_parser = sub.add_parser("resize", help="게임용 크기로 리사이즈")
    resize_parser.add_argument("input", help="이미지 파일 또는 폴더 경로")
    resize_parser.add_argument("--size", required=True, help="목표 크기 (예: 64x64)")

    # 스프라이트 시트
    sheet_parser = sub.add_parser("spritesheet", help="스프라이트 시트 생성")
    sheet_parser.add_argument("folder", help="이미지 폴더 경로")
    sheet_parser.add_argument("--output", required=True, help="출력 파일 경로")
    sheet_parser.add_argument("--columns", type=int, default=4, help="열 개수")
    sheet_parser.add_argument("--cell-size", help="셀 크기 (예: 64x64)")

    args = parser.parse_args()

    if args.command == "remove-bg":
        p = Path(args.input)
        if p.is_dir():
            batch_remove_background(str(p), args.tolerance)
        else:
            remove_green_background(str(p), tolerance=args.tolerance)

    elif args.command == "resize":
        w, h = map(int, args.size.split("x"))
        p = Path(args.input)
        if p.is_dir():
            batch_resize(str(p), (w, h))
        else:
            resize_for_game(str(p), (w, h))

    elif args.command == "spritesheet":
        images = sorted(Path(args.folder).glob("*.png"))
        cell = None
        if args.cell_size:
            cw, ch = map(int, args.cell_size.split("x"))
            cell = (cw, ch)
        create_sprite_sheet([str(i) for i in images], args.output, args.columns, cell)

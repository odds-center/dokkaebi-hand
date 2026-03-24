"""
후처리 도구
- 녹색 배경 제거 (크로마키 — BFS flood fill + 8방향)
- 카드 프레임 처리 (녹색 외부 + 검정 내부 모두 투명화)
- 리사이즈 (게임용 크기로)
- 스프라이트 시트 생성
"""
from pathlib import Path
from collections import deque
from PIL import Image
import argparse


# 8방향 이웃
_DIRS8 = [(-1,-1),(-1,0),(-1,1),(0,-1),(0,1),(1,-1),(1,0),(1,1)]
_DIRS4 = [(-1,0),(1,0),(0,-1),(0,1)]


def _flood_fill_transparent(pixels, w, h, seeds, condition, use8=True):
    """
    BFS flood fill: condition을 만족하는 연결된 픽셀을 투명으로 변환.
    seeds: [(x, y), ...] 시작점 목록
    condition(r,g,b) → bool
    """
    dirs = _DIRS8 if use8 else _DIRS4
    queue = deque()

    for (sx, sy) in seeds:
        r, g, b, a = pixels[sx, sy]
        if a > 0 and condition(r, g, b):
            pixels[sx, sy] = (0, 0, 0, 0)
            queue.append((sx, sy))

    while queue:
        cx, cy = queue.popleft()
        for dx, dy in dirs:
            nx, ny = cx + dx, cy + dy
            if 0 <= nx < w and 0 <= ny < h:
                r, g, b, a = pixels[nx, ny]
                if a > 0 and condition(r, g, b):
                    pixels[nx, ny] = (0, 0, 0, 0)
                    queue.append((nx, ny))


def _fringe_expand(pixels, w, h, rounds=3):
    """
    투명 픽셀 인접 녹색 프린지를 반복적으로 제거 (안티앨리어싱 잔재 제거).
    rounds: 최대 몇 픽셀 깊이까지 제거할지
    """
    def is_fringe(r, g, b):
        return g > 55 and g > r + 12 and g > b + 12

    for _ in range(rounds):
        to_remove = []
        for y in range(h):
            for x in range(w):
                r, g, b, a = pixels[x, y]
                if a == 0 or not is_fringe(r, g, b):
                    continue
                # 인접 투명 픽셀 있으면 제거 대상
                for dx, dy in _DIRS8:
                    nx, ny = x + dx, y + dy
                    if 0 <= nx < w and 0 <= ny < h and pixels[nx, ny][3] == 0:
                        to_remove.append((x, y))
                        break
        if not to_remove:
            break
        for (x, y) in to_remove:
            pixels[x, y] = (0, 0, 0, 0)


def remove_green_background(
    input_path: str,
    output_path: str = None,
    tolerance: int = 80,  # 하위 호환 유지 (미사용)
):
    """
    녹색(#00FF00) 배경을 투명으로 변환.

    1단계: BFS flood fill (8방향) — 테두리에서 시작, 연결된 녹색 픽셀 제거
    2단계: 프린지 확장 — 투명 픽셀 인접 녹색 잔재 3픽셀 깊이까지 제거
    """
    img = Image.open(input_path).convert("RGBA")
    pixels = img.load()
    w, h = img.size

    def is_green(r, g, b):
        return g > 100 and g > r * 1.4 and g > b * 1.4

    # 테두리 시드 수집
    seeds = []
    for x in range(w):
        seeds.append((x, 0))
        seeds.append((x, h - 1))
    for y in range(1, h - 1):
        seeds.append((0, y))
        seeds.append((w - 1, y))

    _flood_fill_transparent(pixels, w, h, seeds, is_green, use8=True)
    _fringe_expand(pixels, w, h, rounds=3)

    if output_path is None:
        p = Path(input_path)
        output_path = str(p.parent / f"{p.stem}_transparent{p.suffix}")

    img.save(output_path)
    print(f"  [배경제거] {output_path}")
    return output_path


def remove_card_frame_background(
    input_path: str,
    output_path: str = None,
):
    """
    카드 프레임 이미지 처리:
    1단계: 녹색 외부 → 투명 (BFS from edges)
    2단계: 프린지 정리
    3단계: 불투명 영역으로 타이트 크롭 (여백 제거 — 프레임이 캔버스를 꽉 채우게)
    4단계: 검정 내부 → 투명 (크롭된 이미지 중앙에서 BFS) — 일러스트가 비치게
    결과: 장식 테두리만 남음, 캔버스에 꽉 참
    """
    img = Image.open(input_path).convert("RGBA")
    pixels = img.load()
    w, h = img.size

    # --- 1단계: 녹색 외부 제거 ---
    def is_green(r, g, b):
        return g > 100 and g > r * 1.4 and g > b * 1.4

    seeds_edge = []
    for x in range(w):
        seeds_edge.append((x, 0))
        seeds_edge.append((x, h - 1))
    for y in range(1, h - 1):
        seeds_edge.append((0, y))
        seeds_edge.append((w - 1, y))

    _flood_fill_transparent(pixels, w, h, seeds_edge, is_green, use8=True)
    _fringe_expand(pixels, w, h, rounds=3)

    # --- 2단계: 타이트 크롭 (투명 여백 제거) ---
    # 원본이 landscape이고 프레임이 중앙에 있을 경우 여백을 제거해 프레임이 캔버스를 꽉 채움
    bbox = img.getbbox()  # (left, top, right, bottom) of non-transparent pixels
    if bbox:
        img = img.crop(bbox)
        w, h = img.size
        pixels = img.load()

    # --- 3단계: 검정 내부 제거 (크롭 후 중앙에서 BFS) ---
    # 어두운 내부(검정~매우 어두운 색)만 제거 — 장식 패턴의 채도 있는 색은 보존
    def is_dark_interior(r, g, b):
        # max 채널이 32 미만이면 제거 (실제 중앙 픽셀 최대값 ~28)
        # 빨강/파랑 계열 장식은 채도가 있어 max > 60 이상이므로 보존됨
        return max(r, g, b) < 32

    cx, cy = w // 2, h // 2
    seeds_center = [(cx + dx, cy + dy) for dx in range(-8, 9) for dy in range(-8, 9)
                    if 0 <= cx+dx < w and 0 <= cy+dy < h]

    _flood_fill_transparent(pixels, w, h, seeds_center, is_dark_interior, use8=False)

    if output_path is None:
        p = Path(input_path)
        output_path = str(p.parent / f"{p.stem}_frame{p.suffix}")

    img.save(output_path)
    print(f"  [프레임처리] {output_path}")
    return output_path


def resize_for_game(
    input_path: str,
    target_size: tuple[int, int],
    output_path: str = None,
):
    """게임용 크기로 리사이즈 (FilterMode.Point 유지)"""
    img = Image.open(input_path)
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
    """여러 이미지를 스프라이트 시트로 합치기"""
    if not image_paths:
        print("  [에러] 이미지 없음")
        return

    images = [Image.open(p).convert("RGBA") for p in image_paths]
    if cell_size is None:
        cell_size = (images[0].width, images[0].height)

    rows = (len(images) + columns - 1) // columns
    sheet = Image.new("RGBA", (cell_size[0]*columns, cell_size[1]*rows), (0,0,0,0))

    for i, img in enumerate(images):
        row, col = i // columns, i % columns
        sheet.paste(img.resize(cell_size, Image.NEAREST), (col*cell_size[0], row*cell_size[1]))

    sheet.save(output_path)
    print(f"  [스프라이트시트] {columns}x{rows} ({len(images)}개) → {output_path}")
    return output_path


def batch_remove_background(folder: str):
    folder_path = Path(folder)
    output_dir = folder_path / "transparent"
    output_dir.mkdir(exist_ok=True)

    png_files = sorted(folder_path.glob("*.png"))
    print(f"\n  [{folder_path.name}] {len(png_files)}개 배경 제거...")
    for png in png_files:
        if "_transparent" in png.stem or "_frame" in png.stem:
            continue
        remove_green_background(str(png), str(output_dir / f"{png.stem}.png"))
    print(f"  완료 → {output_dir}")


def batch_resize(folder: str, target_size: tuple[int, int]):
    folder_path = Path(folder)
    output_dir = folder_path / f"resized_{target_size[0]}x{target_size[1]}"
    output_dir.mkdir(exist_ok=True)
    for png in sorted(folder_path.glob("*.png")):
        resize_for_game(str(png), target_size, str(output_dir / png.name))


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="픽셀아트 후처리 도구")
    sub = parser.add_subparsers(dest="command")

    bg = sub.add_parser("remove-bg", help="녹색 배경 제거")
    bg.add_argument("input")

    fr = sub.add_parser("remove-frame-bg", help="카드 프레임 배경 제거 (외부+내부)")
    fr.add_argument("input")

    rz = sub.add_parser("resize", help="게임용 리사이즈")
    rz.add_argument("input")
    rz.add_argument("--size", required=True)

    ss = sub.add_parser("spritesheet")
    ss.add_argument("folder")
    ss.add_argument("--output", required=True)
    ss.add_argument("--columns", type=int, default=4)
    ss.add_argument("--cell-size")

    args = parser.parse_args()

    if args.command == "remove-bg":
        p = Path(args.input)
        if p.is_dir():
            batch_remove_background(str(p))
        else:
            remove_green_background(str(p))

    elif args.command == "remove-frame-bg":
        p = Path(args.input)
        if p.is_dir():
            for png in sorted(p.glob("*.png")):
                remove_card_frame_background(str(png))
        else:
            remove_card_frame_background(str(p))

    elif args.command == "resize":
        w2, h2 = map(int, args.size.split("x"))
        p = Path(args.input)
        if p.is_dir():
            batch_resize(str(p), (w2, h2))
        else:
            resize_for_game(str(p), (w2, h2))

    elif args.command == "spritesheet":
        images = sorted(Path(args.folder).glob("*.png"))
        cell = None
        if args.cell_size:
            cw, ch = map(int, args.cell_size.split("x"))
            cell = (cw, ch)
        create_sprite_sheet([str(i) for i in images], args.output, args.columns, cell)

"""
배치 생성 스크립트
- sd-prompts/ md 파일을 자동 파싱하여 카테고리별/전체 생성
"""
import argparse
import json
import time
from pathlib import Path
from config import OUTPUT_DIR, CATEGORY_CONFIG
from parse_prompts import parse_all, parse_category, PromptEntry
from generate import generate_from_entry, ensure_output_dirs


# 카테고리 단축 이름 매핑
SHORTCUTS = {
    "backgrounds": "01-backgrounds",
    "bg": "01-backgrounds",
    "cards": "02-card-illustrations",
    "card": "02-card-illustrations",
    "textures": "03-textures",
    "tex": "03-textures",
    "concept": "04-concept-art",
    "calligraphy": "05-calligraphy",
    "calli": "05-calligraphy",
    "sprites": "06-game-sprites",
    "sprite": "06-game-sprites",
    "bosses": "06-game-sprites",
    "icons": "07-icons",
    "icon": "07-icons",
    "illustrations": "08-illustrations",
    "illust": "08-illustrations",
    "card-extras": "09-card-extras",
    "vfx": "10-vfx",
    "ui": "11-ui-frames",
    "hud": "12-hud-icons",
}


def resolve_category(name: str) -> str:
    """단축 이름을 실제 폴더명으로 변환"""
    if name in CATEGORY_CONFIG:
        return name
    return SHORTCUTS.get(name, name)


def batch_generate(
    category: str,
    dry_run: bool = False,
    specific_names: list[str] = None,
    batch_size: int = 1,
):
    """
    카테고리별 배치 생성

    Args:
        category: 생성할 카테고리
        dry_run: True면 실제 생성 없이 목록만 출력
        specific_names: 특정 에셋만 생성
        batch_size: 같은 프롬프트로 몇 장씩 생성할지
    """
    if category == "all":
        for cat_name in sorted(CATEGORY_CONFIG.keys()):
            batch_generate(cat_name, dry_run, specific_names, batch_size)
        return

    cat_folder = resolve_category(category)
    entries = parse_category(cat_folder)

    if not entries:
        print(f"[경고] '{category}' 에서 프롬프트를 찾지 못했습니다.")
        return

    # 특정 에셋만 필터
    if specific_names:
        entries = [e for e in entries if e.name in specific_names]

    total = len(entries)
    total_images = total * batch_size

    cat_config = CATEGORY_CONFIG.get(cat_folder, {})
    out_name = cat_config.get("output_dir", cat_folder)

    print(f"\n{'='*60}")
    print(f"  [{out_name.upper()}] {total}개 에셋 × {batch_size}장 = {total_images}장")
    print(f"{'='*60}")

    if dry_run:
        for e in entries:
            print(f"  [DRY] {e.name} ({e.width}x{e.height}) seed={e.seed}")
            print(f"    프롬프트: {e.full_prompt[:70]}...")
        cost = total_images * 0.004
        print(f"\n  [DRY] 총 {total_images}장 생성 예정 (예상 비용: ~${cost:.2f})")
        return

    results = {"success": [], "failed": []}
    start_time = time.time()

    for i, entry in enumerate(entries, 1):
        for b in range(batch_size):
            label = f"[{i}/{total}]" if batch_size == 1 else f"[{i}/{total} batch {b+1}]"
            print(f"\n--- {label} {entry.name} ---")

            path = generate_from_entry(entry, batch_index=b)

            if path:
                results["success"].append({"name": entry.name, "path": str(path)})
            else:
                results["failed"].append({"name": entry.name, "batch": b})

            # API 레이트 리밋 방지
            time.sleep(1)

    elapsed = time.time() - start_time

    # 결과 요약
    print(f"\n{'='*60}")
    print(f"  [{out_name.upper()}] 완료!")
    print(f"  성공: {len(results['success'])}개 / 실패: {len(results['failed'])}개")
    print(f"  소요 시간: {elapsed:.1f}초")
    print(f"{'='*60}")

    if results["failed"]:
        print("\n  실패 목록:")
        for f in results["failed"]:
            print(f"    - {f['name']}")

    # 결과 로그 저장
    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)
    log_path = OUTPUT_DIR / f"batch_log_{out_name}_{int(time.time())}.json"
    with open(log_path, "w", encoding="utf-8") as f:
        json.dump(results, f, ensure_ascii=False, indent=2)
    print(f"\n  로그 저장: {log_path}")

    return results


def list_all():
    """전체 에셋 목록 출력 (sd-prompts 파싱 기반)"""
    all_data = parse_all()

    total = 0
    print(f"\n{'='*60}")
    print(f"  sd-prompts/ 프롬프트 현황 (자동 파싱)")
    print(f"{'='*60}")

    for cat, entries in all_data.items():
        config = CATEGORY_CONFIG.get(cat, {})
        out_name = config.get("output_dir", cat)
        count = len(entries)
        total += count
        print(f"  {out_name:25s} — {count:3d}개")

    print(f"  {'─'*40}")
    print(f"  {'총계':25s} — {total:3d}개")
    cost_1 = total * 0.004
    cost_4 = total * 4 * 0.004
    print(f"\n  예상 비용 (×1장): ~${cost_1:.2f}")
    print(f"  예상 비용 (×4장): ~${cost_4:.2f}")


def list_category(category: str):
    """특정 카테고리의 상세 목록 출력"""
    cat_folder = resolve_category(category)
    entries = parse_category(cat_folder)

    if not entries:
        print(f"[경고] '{category}' 에서 프롬프트를 찾지 못했습니다.")
        return

    config = CATEGORY_CONFIG.get(cat_folder, {})
    out_name = config.get("output_dir", cat_folder)

    print(f"\n[{out_name.upper()}] — {len(entries)}개")
    for e in entries:
        print(f"  {e.name:30s} ({e.width}x{e.height}) seed={e.seed} [{e.source_file}]")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        description="도깨비의 패 픽셀아트 에셋 배치 생성기 (sd-prompts 자동 파싱)",
        formatter_class=argparse.RawTextHelpFormatter,
    )
    parser.add_argument(
        "category",
        nargs="?",
        default="list",
        help="""생성할 카테고리:
  list          전체 에셋 목록 출력
  all           전체 생성

  카테고리 단축어:
    bg, backgrounds     배경
    cards, card         화투 카드 일러스트 (48장)
    tex, textures       텍스처
    concept             컨셉아트
    calli, calligraphy  서예
    sprites, bosses     인게임 스프라이트
    icons, icon         아이콘
    illust              삽화
    card-extras         카드 추가 에셋
    vfx                 VFX 이펙트
    ui                  UI 프레임
    hud                 HUD 아이콘""",
    )
    parser.add_argument("--dry-run", action="store_true", help="실제 생성 없이 목록/비용만 출력")
    parser.add_argument("--only", nargs="+", help="특정 에셋만 생성 (이름 나열)")
    parser.add_argument("--batch", type=int, default=1, help="같은 프롬프트로 몇 장 생성 (기본 1)")
    parser.add_argument("--detail", action="store_true", help="카테고리 상세 목록 출력")

    args = parser.parse_args()

    if args.category == "list":
        print("\n=== sd-prompts 전체 에셋 목록 ===")
        list_all()
    elif args.detail:
        list_category(args.category)
    else:
        ensure_output_dirs()
        batch_generate(args.category, dry_run=args.dry_run,
                      specific_names=args.only, batch_size=args.batch)

"""
축복 4종 아이콘 생성
업화 / 빙결 / 공허 / 혼돈 — 1:1 픽셀아트 아이콘 (category: icons)
"""
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent))
from generate import generate_icon

BLESSINGS = [
    {
        "id": "blessing_업화",
        "seed": 81001,
        "prompt": (
            "Pixel art icon, 1:1 square, flat shading, thick black outlines, "
            "Korean underworld hellfire blessing symbol, blazing orange-red flame "
            "with dokkaebi demon face emerging from the fire, gold and red tones, "
            "dark background with embers, single centered symbol, "
            "bold readable silhouette, no text, no anti-aliasing, sharp pixels, "
            "16-bit retro game icon style"
        ),
    },
    {
        "id": "blessing_빙결",
        "seed": 81002,
        "prompt": (
            "Pixel art icon, 1:1 square, flat shading, thick black outlines, "
            "Korean underworld frost blessing symbol, crystalline ice shard "
            "with ghostly pale blue glow, frozen spirit trapped in ice crystal, "
            "cool blue and white tones, dark background with frost particles, "
            "single centered symbol, bold readable silhouette, "
            "no text, no anti-aliasing, sharp pixels, 16-bit retro game icon style"
        ),
    },
    {
        "id": "blessing_공허",
        "seed": 81003,
        "prompt": (
            "Pixel art icon, 1:1 square, flat shading, thick black outlines, "
            "Korean underworld void blessing symbol, swirling dark purple vortex "
            "with empty black center, eldritch eye peering from the void, "
            "deep purple and dark violet tones, ominous cosmic background, "
            "single centered symbol, bold readable silhouette, "
            "no text, no anti-aliasing, sharp pixels, 16-bit retro game icon style"
        ),
    },
    {
        "id": "blessing_혼돈",
        "seed": 81004,
        "prompt": (
            "Pixel art icon, 1:1 square, flat shading, thick black outlines, "
            "Korean underworld chaos blessing symbol, fractured spiral of "
            "clashing elemental energies — fire red, ice blue, purple void — "
            "cracking apart, golden cracks throughout like kintsugi, "
            "dark chaotic background, single centered symbol, bold readable silhouette, "
            "no text, no anti-aliasing, sharp pixels, 16-bit retro game icon style"
        ),
    },
]


def main():
    print("=" * 60)
    print("  축복 아이콘 생성 (4종)")
    print("=" * 60)
    success = 0
    for b in BLESSINGS:
        path = generate_icon(b["id"], b["prompt"], b["seed"])
        if path:
            success += 1
    print(f"\n  완료: {success}/{len(BLESSINGS)}")
    print("=" * 60)
    if success > 0:
        print("\n  다음 단계: python deploy_to_game.py 실행하여 게임에 배포")


if __name__ == "__main__":
    main()

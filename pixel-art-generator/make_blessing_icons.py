"""
축복 4종 아이콘 — 32×32 픽셀아트, 투명 배경
불 / 얼음 / 공허 / 혼돈
"""
from pathlib import Path
from PIL import Image
import math, random

OUT_DIR = Path(__file__).parent / "output" / "icons"
OUT_DIR.mkdir(parents=True, exist_ok=True)

S = 32


def new_grid():
    return [[0]*S for _ in range(S)]


def make_img(g, P):
    img = Image.new("RGBA", (S, S), (0, 0, 0, 0))
    px = img.load()
    for y in range(S):
        for x in range(S):
            c = P.get(g[y][x])
            if c:
                px[x, y] = c
    return img


def set_px(g, x, y, v):
    if 0 <= x < S and 0 <= y < S:
        if v > g[y][x]:
            g[y][x] = v


def add_outline(g, P):
    """컬러 픽셀 주변 1px 아웃라인 (인덱스 99)"""
    filled = [[g[y][x] > 0 for x in range(S)] for y in range(S)]
    for y in range(S):
        for x in range(S):
            if g[y][x] == 0:
                for dy, dx in ((-1,0),(1,0),(0,-1),(0,1)):
                    ny, nx = y+dy, x+dx
                    if 0 <= ny < S and 0 <= nx < S and filled[ny][nx]:
                        g[y][x] = 99
                        break
    P[99] = (12, 8, 6, 255)


# ══════════════════════════════════════════════
# 불 (Fire) — 3갈래 불꽃, 밝은 코어
# ══════════════════════════════════════════════
def make_eophwa():
    P = {
        0: (0,   0,   0,   0  ),
        2: (145, 14,  5,   255),   # 어두운 빨강
        3: (208, 46,  8,   255),   # 빨강
        4: (245, 108, 13,  255),   # 주황
        5: (255, 186, 20,  255),   # 노란-주황
        6: (255, 232, 72,  255),   # 노랑
        7: (255, 250, 172, 255),   # 코어 (거의 흰)
    }
    g = new_grid()

    # 불꽃 lobe 그리기: (중심x, top_y, bottom_y, 최대반폭, lean방향)
    def lobe(fcx, ty, by, maxw, lean=0):
        for y in range(ty, by+1):
            t  = (y - ty) / max(by - ty, 1)   # 0=top,1=bottom
            cx = fcx + lean * (1.0 - t)
            w  = maxw * math.sin(t * math.pi)
            lx = round(cx - w)
            rx = round(cx + w)
            for x in range(max(0,lx), min(S, rx+1)):
                dn = abs(x - cx) / max(w, 0.1)   # 0=중심,1=가장자리
                hn = 1.0 - t                       # 1=위,0=아래
                br = (1.0 - dn*0.75) * 0.55 + hn * 0.45
                if   br > 0.82: v = 7
                elif br > 0.66: v = 6
                elif br > 0.50: v = 5
                elif br > 0.34: v = 4
                elif br > 0.18: v = 3
                else:           v = 2
                set_px(g, x, y, v)

    # 중앙 메인 불꽃 (가장 크고 높음)
    lobe(15, 2, 27, 8.5, 0)
    # 왼쪽 보조 불꽃
    lobe(10, 7, 22, 4.5, -1.5)
    # 오른쪽 보조 불꽃
    lobe(20, 8, 21, 3.5,  1.5)
    # 왼쪽 작은 불꽃
    lobe(6,  13, 22, 2.5, -1)
    # 오른쪽 작은 불꽃
    lobe(24, 14, 21, 2.0,  1)

    add_outline(g, P)
    P[99] = (80, 12, 4, 255)   # 불 아웃라인은 짙은 빨강
    return make_img(g, P)


# ══════════════════════════════════════════════
# 얼음 (Ice) — 6각 눈결정, 선명한 기하학
# ══════════════════════════════════════════════
def make_binggyeol():
    P = {
        0: (0,   0,   0,   0  ),
        2: (18,  55,  130, 255),   # 짙은 파랑
        3: (52,  125, 208, 255),   # 파랑
        4: (128, 192, 252, 255),   # 연파랑
        5: (208, 235, 252, 255),   # 거의 흰 파랑
        6: (238, 248, 255, 255),   # 아이스 화이트
        7: (255, 255, 255, 255),   # 순백
    }
    g = new_grid()
    cx, cy = 15.5, 15.5

    # ── 6각형 몸체 ──
    R_hex = 13.0
    for y in range(S):
        for x in range(S):
            dx, dy = x - cx, y - cy
            r = math.sqrt(dx*dx + dy*dy)
            if r > R_hex:
                continue
            # 6각형 거리 (flat-top)
            ang = math.atan2(dy, dx)
            seg_ang = (ang + math.pi/6) % (math.pi/3) - math.pi/6
            hex_r = r * math.cos(seg_ang)
            if hex_r > R_hex * 0.90:
                continue
            # 색상: 중심 → 흰, 외곽 → 파랑
            t = r / R_hex
            if   t < 0.18: v = 7
            elif t < 0.35: v = 6
            elif t < 0.52: v = 5
            elif t < 0.70: v = 4
            elif t < 0.85: v = 3
            else:          v = 2
            set_px(g, x, y, v)

    # ── 6방향 주 가지 (흰 선) ──
    for deg in range(0, 360, 60):
        rad = math.radians(deg)
        for s10 in range(0, 130):   # step × 0.1
            step = s10 / 10.0
            nx = round(cx + math.cos(rad) * step)
            ny = round(cy + math.sin(rad) * step)
            if 0 <= nx < S and 0 <= ny < S and step <= 12.5:
                t = step / 12.5
                vl = 7 if t < 0.55 else (6 if t < 0.80 else 5)
                g[ny][nx] = max(g[ny][nx], vl)

    # ── 6방향 갈래 (step=5, step=8 위치) ──
    for deg in range(0, 360, 60):
        rad = math.radians(deg)
        perp = rad + math.pi / 2
        for branch_step, branch_len, bv in [(5.0, 2.5, 6), (8.0, 2.0, 5)]:
            bx = cx + math.cos(rad) * branch_step
            by_ = cy + math.sin(rad) * branch_step
            for side in (-1, 1):
                for bl in range(0, round(branch_len * 10)):
                    bl_f = bl / 10.0
                    nx = round(bx + math.cos(perp) * bl_f * side)
                    ny = round(by_ + math.sin(perp) * bl_f * side)
                    if 0 <= nx < S and 0 <= ny < S:
                        g[ny][nx] = max(g[ny][nx], bv)

    add_outline(g, P)
    P[99] = (10, 38, 95, 255)   # 얼음 아웃라인: 짙은 네이비
    return make_img(g, P)


# ══════════════════════════════════════════════
# 공허 (Void) — 보라 링 + 중앙 투명 구멍
# ══════════════════════════════════════════════
def make_gongheo():
    P = {
        0: (0,   0,   0,   0  ),
        2: (22,  8,   50,  255),   # 짙은 보라
        3: (72,  18,  128, 255),   # 보라
        4: (138, 45,  198, 255),   # 밝은 보라
        5: (192, 108, 252, 255),   # 연보라
        6: (228, 198, 255, 255),   # 거의 흰 보라
        7: (255, 255, 255, 255),   # 흰 (링 하이라이트)
    }
    g = new_grid()
    cx, cy = 15.5, 15.5

    # ── 도넛(링) 형태 + 소용돌이 ──
    HOLE_R = 5.5    # 중앙 구멍 반경 (투명)
    OUTER_R = 14.0  # 링 외곽 반경

    for y in range(S):
        for x in range(S):
            dx, dy = x - cx, y - cy
            r = math.sqrt(dx*dx + dy*dy)
            if r <= HOLE_R or r > OUTER_R:
                continue
            ang = math.atan2(dy, dx)
            # 소용돌이: 각도 + 거리에 따른 stripe
            swirl = ((ang + r * 0.45) % (math.pi * 2)) / (math.pi * 2)
            t_ring = (r - HOLE_R) / (OUTER_R - HOLE_R)  # 0=안, 1=밖

            # 색: 안쪽(링 내부)은 밝고 swirl 패턴
            bright = (1.0 - t_ring) * 0.7 + (0.5 - abs(swirl - 0.5)) * 0.3
            if   bright > 0.75: v = 6
            elif bright > 0.58: v = 5
            elif bright > 0.42: v = 4
            elif bright > 0.26: v = 3
            else:               v = 2
            set_px(g, x, y, v)

    # ── 링 안쪽 밝은 테두리 ──
    for y in range(S):
        for x in range(S):
            dx, dy = x - cx, y - cy
            r = math.sqrt(dx*dx + dy*dy)
            if abs(r - HOLE_R) < 1.2:
                g[y][x] = max(g[y][x], 7)

    # ── 중앙 구멍: 완전 투명 유지 ──
    for y in range(S):
        for x in range(S):
            dx, dy = x - cx, y - cy
            if math.sqrt(dx*dx + dy*dy) <= HOLE_R - 0.5:
                g[y][x] = 0

    add_outline(g, P)
    P[99] = (12, 4, 30, 255)   # 공허 아웃라인: 짙은 흑보라
    return make_img(g, P)


# ══════════════════════════════════════════════
# 혼돈 (Chaos) — 검은불 + 보라 글로우 + 유령
# ══════════════════════════════════════════════
def make_hondon():
    rng = random.Random(81006)
    P = {
        0: (0,   0,   0,   0  ),
        2: (8,   4,   18,  255),   # 검은불 몸체 (거의 검정)
        3: (25,  8,   52,  255),   # 짙은 보라
        4: (70,  16,  118, 255),   # 보라
        5: (145, 32,  195, 255),   # 밝은 보라
        6: (198, 72,  252, 255),   # 글로우 보라
        7: (238, 205, 255, 255),   # 유령 흰보라
        8: (252, 245, 255, 255),   # 유령 핵
    }
    g = new_grid()
    cx = 15

    # ── 검은불: 불꽃 구조는 업화와 동일하지만 색 반전 ──
    # 가장자리/끝 → 밝은 보라, 중심 → 거의 검정
    def dark_lobe(fcx_base, ty, by, maxw, lean=0):
        for y in range(ty, by+1):
            t  = (y - ty) / max(by - ty, 1)
            fcx = fcx_base + lean * (1.0 - t)
            w  = maxw * math.sin(t * math.pi)
            lx = round(fcx - w)
            rx = round(fcx + w)
            for x in range(max(0,lx), min(S, rx+1)):
                dn = abs(x - fcx) / max(w, 0.1)
                hn = 1.0 - t
                # 역전: 가장자리/끝 = 밝음
                edge = dn * 0.65 + hn * 0.35
                if   edge > 0.78: v = 6
                elif edge > 0.60: v = 5
                elif edge > 0.42: v = 4
                elif edge > 0.25: v = 3
                else:             v = 2
                set_px(g, x, y, v)

    # 비대칭 혼돈스러운 배치
    dark_lobe(15, 3, 26, 8.0,  0)
    dark_lobe( 9, 8, 22, 4.5, -2)
    dark_lobe(21, 9, 21, 3.5,  2.5)
    dark_lobe( 5, 14, 22, 2.5, -1.5)
    dark_lobe(25, 15, 20, 2.0,  2)

    # ── 유령 wisps (불꽃 위로 떠오르는 영혼 파편) ──
    wisps = [(cx-4, 1, 2), (cx+3, 0, 1), (cx+1, 2, 1)]
    for (wx, wy, wr) in wisps:
        for dy in range(-wr, wr+1):
            for dx in range(-wr+abs(dy), wr-abs(dy)+1):
                nx2, ny2 = wx+dx, wy+dy
                if 0 <= nx2 < S and 0 <= ny2 < S and g[ny2][nx2] == 0:
                    g[ny2][nx2] = 7
        if 0 <= wx < S and 0 <= wy < S:
            g[wy][wx] = 8

    # ── 보라 불씨 ──
    for _ in range(16):
        ex = rng.randint(cx - 10, cx + 10)
        ey = rng.randint(0, 5)
        if 0 <= ex < S and 0 <= ey < S and g[ey][ex] == 0:
            g[ey][ex] = 6
            for ddx, ddy in ((-1,0),(1,0),(0,-1),(0,1)):
                nx2, ny2 = ex+ddx, ey+ddy
                if 0 <= nx2 < S and 0 <= ny2 < S and g[ny2][nx2] == 0:
                    g[ny2][nx2] = 4

    # ── 유령 눈 (검은불 내부) ──
    ey_row = 18
    for ex_off, ev in [(-3, 8), (-2, 7), (2, 7), (3, 8)]:
        nx2 = cx + ex_off
        if 0 <= nx2 < S and 0 <= ey_row < S:
            if g[ey_row][nx2] in (2, 3, 4):
                g[ey_row][nx2] = ev

    add_outline(g, P)
    P[99] = (6, 2, 15, 255)    # 혼돈 아웃라인: 거의 검정 보라
    return make_img(g, P)


def save(img, name):
    path = OUT_DIR / f"{name}.png"
    img.save(path)
    print(f"  ✓ {name}  ({img.size[0]}×{img.size[1]})")


if __name__ == "__main__":
    print("=" * 50)
    print("  축복 아이콘 32×32 (투명 배경)")
    print("=" * 50)
    save(make_eophwa(),    "blessing_업화")
    save(make_binggyeol(), "blessing_빙결")
    save(make_gongheo(),   "blessing_공허")
    save(make_hondon(),    "blessing_혼돈")
    print("\n  완료!")

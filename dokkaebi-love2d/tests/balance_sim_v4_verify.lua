--- 밸런스 패치 검증 시뮬레이션 v4
--- 적용된 패치: mult캡10, Go(2/3/8), 최소뎀15, 1관문HP하향, 섯다 데미지 상향

-- 패치 후 섯다 기본 데미지
local function seotda_base(rank)
    if rank == 100 then return 60
    elseif rank == 99 then return 50
    elseif rank == 98 then return 45
    elseif rank == 95 then return 35
    elseif rank >= 90 then return 30
    elseif rank >= 80 then return 15 + (rank - 80)
    elseif rank == 75 then return 25
    elseif rank == 74 then return 22
    elseif rank == 73 then return 20
    elseif rank == 72 then return 18
    elseif rank == 71 then return 15
    elseif rank == 70 then return 12
    elseif rank >= 7 then return 6 + rank
    elseif rank >= 1 then return 4 + rank
    else return 5 end
end

local COMBOS = {
    ogwang      = {50, 0.6},
    samdantong  = {45, 0.5},
    gwangttaeng = {45, 0.5},
    hwangcheon  = {60, 0.6},
    sagwang     = {35, 0.4},
    samgwang    = {22, 0.3},
    jangttaeng  = {30, 0.4},
    hongdan     = {18, 0.2},
    cheongdan   = {18, 0.2},
    chodan      = {18, 0.2},
    godori      = {18, 0.2},
    ali         = {14, 0.15},
    wolhap      = {10, 0.1},
    pibada      = {12, 0.15},
    pi10        = {10, 0.1},
    dokkaebi_bm = {14, 0.15},
    single      = {3,  0},
    none        = {0,  0},
}

-- 패치 후 설정
local MULT_CAP = 10.0
local GO_MULT = {[1]=2, [2]=3, [3]=8}
local MIN_DAMAGE = 15

local function boss_hp(target, spiral)
    return math.floor(target * (1.4 ^ (spiral - 1)))
end

local function sim_round(cfg)
    local wc = math.min(cfg.wc or 0, 80)
    local wm = math.min(cfg.wm or 0, 1.5)
    local carry = math.min((cfg.carry or 0) * 0.5, 100)

    local chips = wc + carry + 5
    local mult = 1.0 + wm

    for _, cid in ipairs(cfg.combos or {}) do
        local c = COMBOS[cid] or {0, 0}
        chips = chips + c[1]
        mult = mult + c[2]
    end

    local stack = cfg.stack or 0
    chips = chips + stack * 3
    mult = math.min(mult, MULT_CAP)

    local base = seotda_base(cfg.rank or 5)
    local gm = GO_MULT[cfg.go or 0] or 1
    local dmg = math.floor((base + chips) * mult * gm)
    dmg = math.max(dmg, MIN_DAMAGE)
    local new_carry = math.min(carry + chips * 0.5, 100)
    return dmg, chips, mult, new_carry
end

local function sim_battle(name, target, spiral, rounds, cfgs)
    local hp = boss_hp(target, spiral)
    local total = 0
    local carry = 0

    io.write(string.format("\n%-48s HP:%-7d %d판\n", name, hp, rounds))

    for i = 1, rounds do
        local cfg = cfgs[math.min(i, #cfgs)]
        cfg.carry = carry
        cfg.stack = i - 1
        local dmg, chips, mult, nc = sim_round(cfg)
        total = total + dmg
        carry = nc

        local cs = table.concat(cfg.combos or {}, "+")
        if cs == "" then cs = "-" end
        local gs = (cfg.go and cfg.go > 0) and ("Go"..cfg.go) or ""

        io.write(string.format("  %d: %-30s %3s base=%-3d chip=%-5.0f x%-5.2f = %-6d [%d/%d]\n",
            i, cs, gs, seotda_base(cfg.rank or 5), chips, mult, dmg, total, hp))

        if total >= hp then
            io.write(string.format("  >>> %d판 격파! (초과 %d)\n", i, total - hp))
            return true, i
        end
    end
    io.write(string.format("  >>> 실패 (부족 %d, 달성률 %d%%)\n", hp - total, math.floor(total/hp*100)))
    return false, rounds
end

-- ===== 시뮬레이션 =====
print("================================================================")
print("  도깨비의 패 - 밸런스 패치 검증 v4")
print("  mult캡=10 | Go=2/3/8 | 최소뎀=15 | 섯다 상향 | 1관문 HP 하향")
print("================================================================")

-- ============================================================
print("\n======== P1. 김초보 (족보 1개, Go 안 함) ========")
-- ============================================================

sim_battle("P1 | 윤회1 관문1 먹보(HP 하향 150)", 150, 1, 7, {
    {combos={"single"}, rank=5},
    {combos={"hongdan"}, rank=72},
    {combos={"single"}, rank=75},
    {combos={"wolhap"}, rank=7},
    {combos={"single"}, rank=3},
    {combos={"none"}, rank=1},
    {combos={"none"}, rank=0},
})

sim_battle("P1 | 최악(족보 0) 관문1 먹보(HP 150)", 150, 1, 7, {
    {combos={"none"}, rank=0},
    {combos={"none"}, rank=1},
    {combos={"none"}, rank=2},
    {combos={"none"}, rank=0},
    {combos={"none"}, rank=1},
    {combos={"none"}, rank=0},
    {combos={"none"}, rank=0},
})

sim_battle("P1 | 윤회1 관문4 불꽃(HP 230)", 230, 1, 7, {
    {combos={"single"}, rank=3},
    {combos={"hongdan"}, rank=70},
    {combos={"wolhap"}, rank=72},
    {combos={"single"}, rank=8},
    {combos={"pibada"}, rank=5},
    {combos={"single"}, rank=1},
    {combos={"none"}, rank=0},
})

-- ============================================================
print("\n======== P2. 이전략 (족보 2~3개, Go 1~2) ========")
-- ============================================================

sim_battle("P2 | 윤회1 관문1 먹보", 150, 1, 7, {
    {combos={"hongdan"}, rank=75, go=1},
    {combos={"wolhap"}, rank=72},
    {combos={"single"}, rank=70},
})

sim_battle("P2 | 윤회1 관문10 그림자(elite)", 350, 1, 6, {
    {combos={"hongdan","wolhap"}, rank=75, go=1},
    {combos={"cheongdan"}, rank=90, go=1},
    {combos={"godori"}, rank=72},
    {combos={"wolhap"}, rank=70},
    {combos={"pibada"}, rank=8},
    {combos={"single"}, rank=3},
})

sim_battle("P2 | 윤회1 관문20 염라(boss)", 600, 1, 8, {
    {combos={"hongdan","chodan"}, rank=90, go=1},
    {combos={"cheongdan"}, rank=75, go=1},
    {combos={"godori"}, rank=72},
    {combos={"wolhap"}, rank=70, go=1},
    {combos={"pibada"}, rank=8},
    {combos={"single"}, rank=5},
    {combos={"none"}, rank=3},
    {combos={"none"}, rank=1},
})

-- ============================================================
print("\n======== P3. 박탐욕 — 윤회별 (영구 강화 포함) ========")
-- ============================================================

sim_battle("P3 | 윤회3 염라(wc=20 wm=1.0)", 600, 3, 8, {
    {wc=20,wm=1.0, combos={"hongdan","cheongdan","chodan"}, rank=90, go=2},
    {wc=20,wm=1.0, combos={"godori","wolhap"}, rank=75, go=1},
    {wc=20,wm=1.0, combos={"pibada"}, rank=72, go=1},
    {wc=20,wm=1.0, combos={"wolhap"}, rank=70},
    {wc=20,wm=1.0, combos={"single"}, rank=8},
    {wc=20,wm=1.0, combos={"none"}, rank=5},
    {wc=20,wm=1.0, combos={"none"}, rank=3},
    {wc=20,wm=1.0, combos={"none"}, rank=1},
})

sim_battle("P3 | 윤회5 염라(wc=35 wm=1.5)", 600, 5, 8, {
    {wc=35,wm=1.5, combos={"hongdan","cheongdan","chodan"}, rank=100, go=2},
    {wc=35,wm=1.5, combos={"samgwang","godori"}, rank=90, go=2},
    {wc=35,wm=1.5, combos={"pibada","wolhap"}, rank=75, go=1},
    {wc=35,wm=1.5, combos={"dokkaebi_bm"}, rank=72, go=1},
    {wc=35,wm=1.5, combos={"hongdan"}, rank=70},
    {wc=35,wm=1.5, combos={"wolhap"}, rank=8},
    {wc=35,wm=1.5, combos={"single"}, rank=5},
    {wc=35,wm=1.5, combos={"none"}, rank=3},
})

sim_battle("P3 | 윤회7 염라(wc=50 풀강화)", 600, 7, 8, {
    {wc=50,wm=1.5, combos={"samdantong","hongdan","cheongdan","chodan"}, rank=100, go=3},
    {wc=50,wm=1.5, combos={"ogwang","godori"}, rank=90, go=2},
    {wc=50,wm=1.5, combos={"samgwang","wolhap"}, rank=75, go=2},
    {wc=50,wm=1.5, combos={"pibada","pi10"}, rank=72, go=1},
    {wc=50,wm=1.5, combos={"hongdan"}, rank=70, go=1},
    {wc=50,wm=1.5, combos={"wolhap"}, rank=8},
    {wc=50,wm=1.5, combos={"single"}, rank=5},
    {wc=50,wm=1.5, combos={"none"}, rank=3},
})

sim_battle("P3 | 윤회10 염라(wc=80 풀빌드)", 600, 10, 8, {
    {wc=80,wm=1.5, combos={"samdantong","hongdan","cheongdan","chodan"}, rank=100, go=3},
    {wc=80,wm=1.5, combos={"ogwang","godori"}, rank=90, go=3},
    {wc=80,wm=1.5, combos={"samgwang","wolhap"}, rank=75, go=2},
    {wc=80,wm=1.5, combos={"pibada","pi10"}, rank=72, go=2},
    {wc=80,wm=1.5, combos={"hongdan","dokkaebi_bm"}, rank=70, go=1},
    {wc=80,wm=1.5, combos={"wolhap"}, rank=8, go=1},
    {wc=80,wm=1.5, combos={"single"}, rank=5},
    {wc=80,wm=1.5, combos={"none"}, rank=3},
})

-- ============================================================
print("\n======== 재앙 보스 ========")
-- ============================================================

sim_battle("재앙 | 윤회3 백골대장(target=3000)", 3000, 3, 7, {
    {wc=20,wm=1.0, combos={"samdantong","hongdan","cheongdan","chodan"}, rank=100, go=3},
    {wc=20,wm=1.0, combos={"ogwang"}, rank=90, go=2},
    {wc=20,wm=1.0, combos={"samgwang","godori"}, rank=75, go=2},
    {wc=20,wm=1.0, combos={"pibada","pi10"}, rank=72, go=1},
    {wc=20,wm=1.0, combos={"hongdan"}, rank=70, go=1},
    {wc=20,wm=1.0, combos={"wolhap"}, rank=8},
    {wc=20,wm=1.0, combos={"single"}, rank=5},
})

sim_battle("재앙 | 윤회5 구미호왕(target=4000)", 4000, 5, 7, {
    {wc=35,wm=1.5, combos={"samdantong","hongdan","cheongdan","chodan"}, rank=100, go=3},
    {wc=35,wm=1.5, combos={"ogwang","godori"}, rank=90, go=3},
    {wc=35,wm=1.5, combos={"samgwang","wolhap"}, rank=75, go=2},
    {wc=35,wm=1.5, combos={"pibada","pi10"}, rank=72, go=2},
    {wc=35,wm=1.5, combos={"hongdan","dokkaebi_bm"}, rank=70, go=1},
    {wc=35,wm=1.5, combos={"wolhap"}, rank=8, go=1},
    {wc=35,wm=1.5, combos={"single"}, rank=5},
})

-- ============================================================
print("\n======== 숫자 성장 체감 (같은 플레이어의 윤회 진행) ========")
-- ============================================================

-- 같은 패턴(홍단+알리+Go1)으로 윤회별 데미지 비교
print("\n  [동일 패턴: 홍단+알리+Go1]")
for sp = 1, 10 do
    local wc = math.min((sp - 1) * 10, 80)
    local wm = math.min((sp - 1) * 0.2, 1.5)
    local chips = wc + 5 + 18 + 14  -- base+hongdan+ali
    local mult = math.min(1.0 + wm + 0.2 + 0.15, MULT_CAP)
    local base = 25  -- 알리
    local gm = 2  -- Go 1
    local dmg = math.floor((base + chips) * mult * gm)
    io.write(string.format("  윤회%2d: wc=%2d wm=%.1f → 칩=%3d x%.2f xGo2 = %5d 데미지\n",
        sp, wc, wm, chips, mult, dmg))
end

print("\n================================================================")
print("  시뮬레이션 완료")
print("================================================================")

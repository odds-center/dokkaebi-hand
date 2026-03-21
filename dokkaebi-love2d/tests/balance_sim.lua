--- 밸런스 시뮬레이션 v2 (전체 재설계 후)
--- lua로 실행: lua balance_sim.lua

-- 섯다 기본 데미지
local function seotda_base(rank)
    if rank == 100 then return 40
    elseif rank == 99 then return 35
    elseif rank == 98 then return 30
    elseif rank == 95 then return 25
    elseif rank >= 90 then return 22
    elseif rank >= 80 then return 12 + (rank - 80)
    elseif rank == 75 then return 20
    elseif rank == 74 then return 18
    elseif rank == 73 then return 16
    elseif rank == 72 then return 14
    elseif rank == 71 then return 12
    elseif rank == 70 then return 10
    elseif rank >= 7 then return 5 + rank
    elseif rank >= 1 then return 3 + rank
    else return 2 end
end

-- 콤보: {chips, mult-1 보너스} (덧셈 시스템)
local COMBOS = {
    -- S
    ogwang      = {50, 0.6},
    samdantong  = {45, 0.5},
    gwangttaeng = {45, 0.5},
    hwangcheon  = {60, 0.6},
    -- A
    sagwang     = {35, 0.4},
    samgwang    = {22, 0.3},
    jangttaeng  = {30, 0.4},
    -- B
    hongdan     = {18, 0.2},
    cheongdan   = {18, 0.2},
    chodan      = {18, 0.2},
    godori      = {18, 0.2},
    ali         = {14, 0.15},
    -- C
    wolhap      = {10, 0.1},
    pibada      = {12, 0.15},
    pi10        = {10, 0.1},
    dokkaebi_bm = {14, 0.15},
    -- D
    single      = {3,  0},
    none        = {0,  0},
}

-- 보스 HP = target * 1.4^(spiral-1)
local function boss_hp(target, spiral)
    return math.floor(target * (1.4 ^ (spiral - 1)))
end

-- ===== 시뮬레이션 엔진 =====
local function sim_round(cfg)
    local wc = math.min(cfg.wc or 0, 80)
    local wm = math.min(cfg.wm or 0, 1.5)
    local carry = math.min((cfg.carry or 0) * 0.5, 100)

    local chips = wc + carry + 5
    local mult = 1.0 + wm

    -- 족보 등록 (덧셈)
    for _, cid in ipairs(cfg.combos or {}) do
        local c = COMBOS[cid] or {0, 0}
        chips = chips + c[1]
        mult = mult + c[2]
    end
    -- 스택 보너스
    local stack = cfg.stack or 0
    chips = chips + stack * 3

    mult = math.min(mult, 4.0)

    local base = seotda_base(cfg.rank or 5)
    local gm = ({[1]=1.5, [2]=2, [3]=3})[cfg.go or 0] or 1
    local dmg = math.floor((base + chips) * math.min(mult, 4.0) * gm)
    local new_carry = math.min(carry + chips * 0.5, 100)

    return dmg, chips, mult, new_carry
end

local function sim_battle(name, target, spiral, rounds, cfgs)
    local hp = boss_hp(target, spiral)
    local total = 0
    local carry = 0
    local result = "PASS"

    io.write(string.format("\n%-45s HP:%-6d (%d*1.4^%d) %d판\n", name, hp, target, spiral-1, rounds))

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

        io.write(string.format("  %d: %-28s %3s base=%-3d chip=%-4.0f x%-5.2f = %-5d [%d/%d]\n",
            i, cs, gs, seotda_base(cfg.rank or 5), chips, mult, dmg, total, hp))

        if total >= hp then
            io.write(string.format("  >>> %d판 격파 (초과 %d)\n", i, total - hp))
            return true, i
        end
    end
    io.write(string.format("  >>> 실패 (부족 %d, 달성률 %d%%)\n", hp - total, math.floor(total/hp*100)))
    return false, rounds
end

-- ===== 시뮬레이션 =====
print("================================================================")
print("  도깨비의 패 - 밸런스 시뮬레이션 v2 (덧셈 배수, 1.4^n HP)")
print("================================================================")

print("\n======== P1. 김초보 (족보 1회, Go 안 함) ========")

sim_battle("P1 | 윤회1 관문1 먹보(normal)", 210, 1, 7, {
    {combos={"single"}, rank=5},
    {combos={"hongdan"}, rank=72},
    {combos={"single"}, rank=75},
    {combos={"wolhap"}, rank=7},
    {combos={"single"}, rank=3},
    {combos={"none"}, rank=1},
    {combos={"none"}, rank=0},
})

sim_battle("P1 | 윤회1 관문4 불꽃(normal)", 230, 1, 7, {
    {combos={"single"}, rank=3},
    {combos={"hongdan"}, rank=70},
    {combos={"wolhap"}, rank=72},
    {combos={"single"}, rank=8},
    {combos={"pibada"}, rank=5},
    {combos={"single"}, rank=1},
    {combos={"none"}, rank=0},
})

sim_battle("P1 | 윤회1 관문7 여우(normal)", 280, 1, 7, {
    {combos={"single"}, rank=5},
    {combos={"hongdan"}, rank=75},
    {combos={"cheongdan"}, rank=72},
    {combos={"wolhap"}, rank=70},
    {combos={"single"}, rank=8},
    {combos={"pibada"}, rank=3},
    {combos={"none"}, rank=0},
})

print("\n======== P2. 이전략 (족보 2~3회, Go 1~2) ========")

sim_battle("P2 | 윤회1 관문1 먹보", 210, 1, 7, {
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

sim_battle("P2 | 윤회1 관문15 황금(elite)", 450, 1, 7, {
    {combos={"hongdan","chodan"}, rank=90, go=1},
    {combos={"cheongdan"}, rank=75, go=1},
    {combos={"godori"}, rank=72},
    {combos={"wolhap"}, rank=70, go=1},
    {combos={"pibada"}, rank=8},
    {combos={"single"}, rank=5},
    {combos={"none"}, rank=3},
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

print("\n======== P3. 박탐욕 — 윤회별 (영구 강화 포함) ========")

sim_battle("P3 | 윤회2 염라 (강화 wc=10 wm=0.5)", 600, 2, 8, {
    {wc=10,wm=0.5, combos={"hongdan","cheongdan","chodan"}, rank=90, go=2},
    {wc=10,wm=0.5, combos={"godori","wolhap"}, rank=75, go=1},
    {wc=10,wm=0.5, combos={"pibada"}, rank=72, go=1},
    {wc=10,wm=0.5, combos={"wolhap"}, rank=70},
    {wc=10,wm=0.5, combos={"single"}, rank=8},
    {wc=10,wm=0.5, combos={"none"}, rank=5},
    {wc=10,wm=0.5, combos={"none"}, rank=3},
    {wc=10,wm=0.5, combos={"none"}, rank=1},
})

sim_battle("P3 | 윤회3 염라 (강화 wc=20 wm=1.0)", 600, 3, 8, {
    {wc=20,wm=1.0, combos={"hongdan","cheongdan","chodan"}, rank=90, go=2},
    {wc=20,wm=1.0, combos={"godori","wolhap"}, rank=75, go=1},
    {wc=20,wm=1.0, combos={"samgwang"}, rank=72, go=1},
    {wc=20,wm=1.0, combos={"pibada"}, rank=70},
    {wc=20,wm=1.0, combos={"wolhap"}, rank=8},
    {wc=20,wm=1.0, combos={"single"}, rank=5},
    {wc=20,wm=1.0, combos={"none"}, rank=3},
    {wc=20,wm=1.0, combos={"none"}, rank=1},
})

sim_battle("P3 | 윤회5 염라 (강화 wc=35 wm=1.5)", 600, 5, 8, {
    {wc=35,wm=1.5, combos={"hongdan","cheongdan","chodan"}, rank=100, go=2},
    {wc=35,wm=1.5, combos={"samgwang","godori"}, rank=90, go=2},
    {wc=35,wm=1.5, combos={"pibada","wolhap"}, rank=75, go=1},
    {wc=35,wm=1.5, combos={"dokkaebi_bm"}, rank=72, go=1},
    {wc=35,wm=1.5, combos={"hongdan"}, rank=70},
    {wc=35,wm=1.5, combos={"wolhap"}, rank=8},
    {wc=35,wm=1.5, combos={"single"}, rank=5},
    {wc=35,wm=1.5, combos={"none"}, rank=3},
})

sim_battle("P3 | 윤회7 염라 (풀강화 wc=50 wm=1.5)", 600, 7, 8, {
    {wc=50,wm=1.5, combos={"samdantong","hongdan","cheongdan","chodan"}, rank=100, go=3},
    {wc=50,wm=1.5, combos={"ogwang","godori"}, rank=90, go=2},
    {wc=50,wm=1.5, combos={"samgwang","wolhap"}, rank=75, go=2},
    {wc=50,wm=1.5, combos={"pibada","pi10"}, rank=72, go=1},
    {wc=50,wm=1.5, combos={"hongdan"}, rank=70, go=1},
    {wc=50,wm=1.5, combos={"wolhap"}, rank=8},
    {wc=50,wm=1.5, combos={"single"}, rank=5},
    {wc=50,wm=1.5, combos={"none"}, rank=3},
})

sim_battle("P3 | 윤회10 염라 (풀빌드 wc=80 wm=1.5)", 600, 10, 8, {
    {wc=80,wm=1.5, combos={"samdantong","hongdan","cheongdan","chodan"}, rank=100, go=3},
    {wc=80,wm=1.5, combos={"ogwang","godori"}, rank=90, go=3},
    {wc=80,wm=1.5, combos={"samgwang","wolhap"}, rank=75, go=2},
    {wc=80,wm=1.5, combos={"pibada","pi10"}, rank=72, go=2},
    {wc=80,wm=1.5, combos={"hongdan","dokkaebi_bm"}, rank=70, go=1},
    {wc=80,wm=1.5, combos={"wolhap"}, rank=8, go=1},
    {wc=80,wm=1.5, combos={"single"}, rank=5},
    {wc=80,wm=1.5, combos={"none"}, rank=3},
})

print("\n======== 재앙 보스 ========")

sim_battle("P3 | 윤회3 백골대장(재앙 target=3000, 하향)", 3000, 3, 7, {
    {wc=20,wm=1.0, combos={"samdantong","hongdan","cheongdan","chodan"}, rank=100, go=3},
    {wc=20,wm=1.0, combos={"ogwang"}, rank=90, go=2},
    {wc=20,wm=1.0, combos={"samgwang","godori"}, rank=75, go=2},
    {wc=20,wm=1.0, combos={"pibada","pi10"}, rank=72, go=1},
    {wc=20,wm=1.0, combos={"hongdan"}, rank=70, go=1},
    {wc=20,wm=1.0, combos={"wolhap"}, rank=8},
    {wc=20,wm=1.0, combos={"single"}, rank=5},
})

sim_battle("P3 | 윤회5 구미호왕(재앙 target=2500, 하향)", 4000, 5, 7, {
    {wc=35,wm=1.5, combos={"samdantong","hongdan","cheongdan","chodan"}, rank=100, go=3},
    {wc=35,wm=1.5, combos={"ogwang","godori"}, rank=90, go=3},
    {wc=35,wm=1.5, combos={"samgwang","wolhap"}, rank=75, go=2},
    {wc=35,wm=1.5, combos={"pibada","pi10"}, rank=72, go=2},
    {wc=35,wm=1.5, combos={"hongdan","dokkaebi_bm"}, rank=70, go=1},
    {wc=35,wm=1.5, combos={"wolhap"}, rank=8, go=1},
    {wc=35,wm=1.5, combos={"single"}, rank=5},
})

print("\n======== 최악의 경우 (족보 0, 피만) ========")

sim_battle("최악 | 윤회1 관문1 먹보 (족보 없음)", 210, 1, 7, {
    {combos={"none"}, rank=0},
    {combos={"none"}, rank=1},
    {combos={"none"}, rank=2},
    {combos={"none"}, rank=0},
    {combos={"none"}, rank=1},
    {combos={"none"}, rank=0},
    {combos={"none"}, rank=0},
})

print("\n================================================================")
print("  시뮬레이션 완료")
print("================================================================")

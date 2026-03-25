--- 밸런스 시뮬레이션 v3 — 패치 비교
--- lua로 실행: luajit balance_sim_v3.lua

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

local function boss_hp(target, spiral)
    return math.floor(target * (1.4 ^ (spiral - 1)))
end

-- ===== 패치 변수 =====
local PATCH = {
    name = "현재(v2)",
    mult_cap = 3.0,
    go_mult = {[1]=1.5, [2]=2, [3]=3},
    min_damage = 0,         -- 최소 보장 데미지
    talisman_chips = 0,     -- 부적 칩 보너스
    talisman_mult = 0,      -- 부적 배수 보너스 (캡 전)
    talisman_final_mult = 1, -- 최종 배수 (캡 후 적용)
}

local function sim_round(cfg, patch)
    local wc = math.min(cfg.wc or 0, 80)
    local wm = math.min(cfg.wm or 0, 1.5)
    local carry = math.min((cfg.carry or 0) * 0.5, 100)

    local chips = wc + carry + 5 + (patch.talisman_chips or 0)
    local mult = 1.0 + wm + (patch.talisman_mult or 0)

    for _, cid in ipairs(cfg.combos or {}) do
        local c = COMBOS[cid] or {0, 0}
        chips = chips + c[1]
        mult = mult + c[2]
    end

    local stack = cfg.stack or 0
    chips = chips + stack * 3

    mult = math.min(mult, patch.mult_cap)

    local base = seotda_base(cfg.rank or 5)
    local gm = patch.go_mult[cfg.go or 0] or 1
    local dmg = math.floor((base + chips) * mult * gm * (patch.talisman_final_mult or 1))
    dmg = math.max(dmg, patch.min_damage)
    local new_carry = math.min(carry + chips * 0.5, 100)

    return dmg, chips, mult, new_carry
end

local function sim_battle(name, target, spiral, rounds, cfgs, patch)
    local hp = boss_hp(target, spiral)
    local total = 0
    local carry = 0

    io.write(string.format("  %-42s HP:%-6d ", name, hp))

    for i = 1, rounds do
        local cfg = cfgs[math.min(i, #cfgs)]
        cfg.carry = carry
        cfg.stack = i - 1
        local dmg, chips, mult, nc = sim_round(cfg, patch)
        total = total + dmg
        carry = nc
        if total >= hp then
            io.write(string.format("→ %d판 격파 (초과 %d)\n", i, total - hp))
            return true, i
        end
    end
    io.write(string.format("→ 실패 (%d%% 달성)\n", math.floor(total/hp*100)))
    return false, rounds
end

-- ===== 테스트 시나리오 =====

-- P1 김초보 (족보 1개, Go 안 함)
local P1_scenarios = {
    {"P1 윤회1 관문1 먹보", 210, 1, 7, {
        {combos={"single"}, rank=5},
        {combos={"hongdan"}, rank=72},
        {combos={"single"}, rank=75},
        {combos={"wolhap"}, rank=7},
        {combos={"single"}, rank=3},
        {combos={"none"}, rank=1},
        {combos={"none"}, rank=0},
    }},
    {"P1 최악(족보 0) 관문1", 210, 1, 7, {
        {combos={"none"}, rank=0},
        {combos={"none"}, rank=1},
        {combos={"none"}, rank=2},
        {combos={"none"}, rank=0},
        {combos={"none"}, rank=1},
        {combos={"none"}, rank=0},
        {combos={"none"}, rank=0},
    }},
}

-- P2 이전략 (족보 2~3개, Go 1~2)
local P2_scenarios = {
    {"P2 윤회1 염라(boss)", 600, 1, 8, {
        {combos={"hongdan","chodan"}, rank=90, go=1},
        {combos={"cheongdan"}, rank=75, go=1},
        {combos={"godori"}, rank=72},
        {combos={"wolhap"}, rank=70, go=1},
        {combos={"pibada"}, rank=8},
        {combos={"single"}, rank=5},
        {combos={"none"}, rank=3},
        {combos={"none"}, rank=1},
    }},
}

-- P3 박탐욕 — 고윤회
local P3_scenarios = {
    {"P3 윤회5 염라(wc35 wm1.5)", 600, 5, 8, {
        {wc=35,wm=1.5, combos={"hongdan","cheongdan","chodan"}, rank=100, go=2},
        {wc=35,wm=1.5, combos={"samgwang","godori"}, rank=90, go=2},
        {wc=35,wm=1.5, combos={"pibada","wolhap"}, rank=75, go=1},
        {wc=35,wm=1.5, combos={"dokkaebi_bm"}, rank=72, go=1},
        {wc=35,wm=1.5, combos={"hongdan"}, rank=70},
        {wc=35,wm=1.5, combos={"wolhap"}, rank=8},
        {wc=35,wm=1.5, combos={"single"}, rank=5},
        {wc=35,wm=1.5, combos={"none"}, rank=3},
    }},
    {"P3 윤회7 염라(wc50 풀강화)", 600, 7, 8, {
        {wc=50,wm=1.5, combos={"samdantong","hongdan","cheongdan","chodan"}, rank=100, go=3},
        {wc=50,wm=1.5, combos={"ogwang","godori"}, rank=90, go=2},
        {wc=50,wm=1.5, combos={"samgwang","wolhap"}, rank=75, go=2},
        {wc=50,wm=1.5, combos={"pibada","pi10"}, rank=72, go=1},
        {wc=50,wm=1.5, combos={"hongdan"}, rank=70, go=1},
        {wc=50,wm=1.5, combos={"wolhap"}, rank=8},
        {wc=50,wm=1.5, combos={"single"}, rank=5},
        {wc=50,wm=1.5, combos={"none"}, rank=3},
    }},
    {"P3 윤회10 염라(wc80 풀빌드)", 600, 10, 8, {
        {wc=80,wm=1.5, combos={"samdantong","hongdan","cheongdan","chodan"}, rank=100, go=3},
        {wc=80,wm=1.5, combos={"ogwang","godori"}, rank=90, go=3},
        {wc=80,wm=1.5, combos={"samgwang","wolhap"}, rank=75, go=2},
        {wc=80,wm=1.5, combos={"pibada","pi10"}, rank=72, go=2},
        {wc=80,wm=1.5, combos={"hongdan","dokkaebi_bm"}, rank=70, go=1},
        {wc=80,wm=1.5, combos={"wolhap"}, rank=8, go=1},
        {wc=80,wm=1.5, combos={"single"}, rank=5},
        {wc=80,wm=1.5, combos={"none"}, rank=3},
    }},
}

-- 재앙 보스
local CALAMITY_scenarios = {
    {"재앙 윤회3 백골대장", 3000, 3, 7, {
        {wc=20,wm=1.0, combos={"samdantong","hongdan","cheongdan","chodan"}, rank=100, go=3},
        {wc=20,wm=1.0, combos={"ogwang"}, rank=90, go=2},
        {wc=20,wm=1.0, combos={"samgwang","godori"}, rank=75, go=2},
        {wc=20,wm=1.0, combos={"pibada","pi10"}, rank=72, go=1},
        {wc=20,wm=1.0, combos={"hongdan"}, rank=70, go=1},
        {wc=20,wm=1.0, combos={"wolhap"}, rank=8},
        {wc=20,wm=1.0, combos={"single"}, rank=5},
    }},
    {"재앙 윤회5 구미호왕", 4000, 5, 7, {
        {wc=35,wm=1.5, combos={"samdantong","hongdan","cheongdan","chodan"}, rank=100, go=3},
        {wc=35,wm=1.5, combos={"ogwang","godori"}, rank=90, go=3},
        {wc=35,wm=1.5, combos={"samgwang","wolhap"}, rank=75, go=2},
        {wc=35,wm=1.5, combos={"pibada","pi10"}, rank=72, go=2},
        {wc=35,wm=1.5, combos={"hongdan","dokkaebi_bm"}, rank=70, go=1},
        {wc=35,wm=1.5, combos={"wolhap"}, rank=8, go=1},
        {wc=35,wm=1.5, combos={"single"}, rank=5},
    }},
}

-- ===== 패치 비교 =====

local patches = {
    -- 현재
    {
        name = "현재(v2) mult캡3.0 Go3=x3",
        mult_cap = 3.0,
        go_mult = {[1]=1.5, [2]=2, [3]=3},
        min_damage = 0,
        talisman_chips = 0,
        talisman_mult = 0,
        talisman_final_mult = 1,
    },
    -- 패치A: 캡만 올림
    {
        name = "패치A: mult캡5.0",
        mult_cap = 5.0,
        go_mult = {[1]=1.5, [2]=2, [3]=3},
        min_damage = 0,
        talisman_chips = 0,
        talisman_mult = 0,
        talisman_final_mult = 1,
    },
    -- 패치B: 캡 올리고 + Go 강화
    {
        name = "패치B: mult캡5.0 + Go3=x5",
        mult_cap = 5.0,
        go_mult = {[1]=1.5, [2]=2.5, [3]=5},
        min_damage = 0,
        talisman_chips = 0,
        talisman_mult = 0,
        talisman_final_mult = 1,
    },
    -- 패치C: 캡 제거 + Go 강화 + 최소뎀
    {
        name = "패치C: mult캡8.0 + Go3=x5 + 최소뎀15",
        mult_cap = 8.0,
        go_mult = {[1]=1.5, [2]=2.5, [3]=5},
        min_damage = 15,
        talisman_chips = 0,
        talisman_mult = 0,
        talisman_final_mult = 1,
    },
    -- 패치D: 캡 올림 + Go 강화 + 부적 시뮬 (평균적 부적 효과)
    {
        name = "패치D: 캡8.0 + Go3=x5 + 부적(칩+30 최종x1.3)",
        mult_cap = 8.0,
        go_mult = {[1]=1.5, [2]=2.5, [3]=5},
        min_damage = 15,
        talisman_chips = 30,
        talisman_mult = 0.3,
        talisman_final_mult = 1.3,
    },
    -- 패치E: Balatro 스타일 (캡 높게 + Go 보상 큼)
    {
        name = "패치E: 캡10.0 + Go3=x8 + 최소뎀15",
        mult_cap = 10.0,
        go_mult = {[1]=2, [2]=3, [3]=8},
        min_damage = 15,
        talisman_chips = 0,
        talisman_mult = 0,
        talisman_final_mult = 1,
    },
}

print("================================================================")
print("  도깨비의 패 - 밸런스 패치 비교 시뮬레이션 v3")
print("================================================================")

for _, patch in ipairs(patches) do
    print(string.format("\n━━━━━ %s ━━━━━", patch.name))

    print("\n  [P1 김초보]")
    for _, s in ipairs(P1_scenarios) do
        sim_battle(s[1], s[2], s[3], s[4], s[5], patch)
    end

    print("  [P2 이전략]")
    for _, s in ipairs(P2_scenarios) do
        sim_battle(s[1], s[2], s[3], s[4], s[5], patch)
    end

    print("  [P3 박탐욕]")
    for _, s in ipairs(P3_scenarios) do
        sim_battle(s[1], s[2], s[3], s[4], s[5], patch)
    end

    print("  [재앙 보스]")
    for _, s in ipairs(CALAMITY_scenarios) do
        sim_battle(s[1], s[2], s[3], s[4], s[5], patch)
    end
end

print("\n================================================================")
print("  시뮬레이션 완료")
print("================================================================")

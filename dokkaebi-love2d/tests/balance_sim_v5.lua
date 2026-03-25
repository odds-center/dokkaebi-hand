--- 밸런스 시뮬레이션 v5 — 대규모 시나리오
--- 패치: mult캡10, Go(2/3/8), 최소뎀15, 섯다상향, 1관문HP하향
--- 부적/축복 효과 포함, 20관문 풀런 시뮬, 윤회 1~15

local NumFmt = { format = function(n)
    if n >= 1000000 then return string.format("%.1fM", n/1000000)
    elseif n >= 1000 then return string.format("%.1fK", n/1000)
    else return tostring(n) end
end }

local function seotda_base(rank)
    if rank == 100 then return 60
    elseif rank == 99 then return 50
    elseif rank == 98 then return 45
    elseif rank == 95 then return 35
    elseif rank >= 90 then return 30
    elseif rank >= 80 then return 15 + (rank - 80)
    elseif rank == 75 then return 25
    elseif rank == 74 then return 22
    elseif rank == 73 then return 16 -- 구삥 유지 (문서 반영)
    elseif rank == 72 then return 18
    elseif rank == 71 then return 15
    elseif rank == 70 then return 12
    elseif rank >= 7 then return 6 + rank
    elseif rank >= 1 then return 4 + rank
    else return 5 end
end

local COMBOS = {
    ogwang      = {50, 0.6},  samdantong  = {45, 0.5},
    gwangttaeng = {45, 0.5},  hwangcheon  = {60, 0.6},
    sagwang     = {35, 0.4},  samgwang    = {22, 0.3},
    jangttaeng  = {30, 0.4},  hongdan     = {18, 0.2},
    cheongdan   = {18, 0.2},  chodan      = {18, 0.2},
    godori      = {18, 0.2},  ali         = {14, 0.15},
    doksa       = {12, 0.15}, gupping     = {10, 0.1},
    wolhap      = {10, 0.1},  pibada      = {12, 0.15},
    pi10        = {10, 0.1},  dokkaebi_bm = {14, 0.15},
    tti5        = {12, 0.15}, geurim5     = {12, 0.15},
    single      = {3,  0},    none        = {0,  0},
}

local MULT_CAP = 10.0
local GO_MULT = {[1]=2, [2]=3, [3]=8}
local MIN_DAMAGE = 15

local function boss_hp(target, spiral, realm)
    realm = realm or 1
    local spiral_mult = 1.4 ^ (spiral - 1)
    local realm_mult = 1.0 + 0.05 * (realm - 1)
    return math.floor(target * spiral_mult * realm_mult)
end

local function sim_round(cfg)
    local wc = math.min(cfg.wc or 0, 80)
    local wm = math.min(cfg.wm or 0, 1.5)
    local carry = math.min((cfg.carry or 0) * 0.5, 100)
    -- 축복 효과
    local blessing_chip_mult = cfg.blessing_chip_mult or 1.0
    local blessing_mult_bonus = cfg.blessing_mult_bonus or 0
    -- 부적 효과
    local tal_chips = cfg.talisman_chips or 0
    local tal_mult = cfg.talisman_mult or 0
    local tal_final = cfg.talisman_final_mult or 1

    local chips = (wc + carry + 5 + tal_chips) * blessing_chip_mult
    local mult = 1.0 + wm + blessing_mult_bonus + tal_mult

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
    local dmg = math.floor(math.max((base + chips) * mult * gm * tal_final, MIN_DAMAGE))
    local new_carry = math.min(carry + chips * 0.5, 100)
    return dmg, chips, mult, new_carry
end

local pass_count, fail_count = 0, 0

local function sim_battle(name, target, spiral, realm, rounds, cfgs, verbose)
    local hp = boss_hp(target, spiral, realm)
    local total = 0
    local carry = 0

    if verbose then
        io.write(string.format("\n%-52s HP:%-7s %d판\n", name, NumFmt.format(hp), rounds))
    end

    for i = 1, rounds do
        local cfg = cfgs[math.min(i, #cfgs)]
        cfg.carry = carry
        cfg.stack = i - 1
        local dmg, chips, mult, nc = sim_round(cfg)
        total = total + dmg
        carry = nc

        if verbose then
            local cs = table.concat(cfg.combos or {}, "+")
            if cs == "" then cs = "-" end
            local gs = (cfg.go and cfg.go > 0) and ("Go"..cfg.go) or ""
            io.write(string.format("  %d: %-28s %3s chip=%-5.0f x%-5.2f = %-6s [%s/%s]\n",
                i, cs, gs, chips, mult, NumFmt.format(dmg), NumFmt.format(total), NumFmt.format(hp)))
        end

        if total >= hp then
            if verbose then
                io.write(string.format("  >>> %d판 격파! (초과 %s)\n", i, NumFmt.format(total - hp)))
            end
            pass_count = pass_count + 1
            return true, i
        end
    end
    if verbose then
        io.write(string.format("  >>> 실패 (%d%%)\n", math.floor(total/hp*100)))
    end
    fail_count = fail_count + 1
    return false, rounds
end

-- 간략 출력
local function sim_brief(name, target, spiral, realm, rounds, cfgs)
    local hp = boss_hp(target, spiral, realm)
    local total = 0
    local carry = 0
    for i = 1, rounds do
        local cfg = cfgs[math.min(i, #cfgs)]
        cfg.carry = carry
        cfg.stack = i - 1
        local dmg, _, _, nc = sim_round(cfg)
        total = total + dmg
        carry = nc
        if total >= hp then
            pass_count = pass_count + 1
            io.write(string.format("  %-48s HP:%-7s → %d판 ✓\n", name, NumFmt.format(hp), i))
            return true, i
        end
    end
    fail_count = fail_count + 1
    io.write(string.format("  %-48s HP:%-7s → 실패 %d%%\n", name, NumFmt.format(hp), math.floor(total/hp*100)))
    return false, rounds
end

-- ===== 플레이어 프로필 빌드 =====

-- 기본: 아무것도 없음
local function P1(go, rank, combos)
    return {combos=combos or {"none"}, rank=rank or 0, go=go or 0}
end

-- 초급: 약간의 웨이브 강화
local function P2(wc, wm, go, rank, combos)
    return {wc=wc, wm=wm, combos=combos or {"none"}, rank=rank or 0, go=go or 0}
end

-- 중급: 웨이브 + 축복
local function P3(wc, wm, go, rank, combos, blessing)
    local b_cm, b_mm = 1.0, 0
    if blessing == "fire" then b_cm = 1.2
    elseif blessing == "ice" then b_mm = 1.0
    end
    return {wc=wc, wm=wm, combos=combos or {"none"}, rank=rank or 0, go=go or 0,
            blessing_chip_mult=b_cm, blessing_mult_bonus=b_mm}
end

-- 상급: 웨이브 + 축복 + 부적
local function P4(wc, wm, go, rank, combos, blessing, tal_c, tal_m, tal_f)
    local b_cm, b_mm = 1.0, 0
    if blessing == "fire" then b_cm = 1.2
    elseif blessing == "ice" then b_mm = 1.0
    end
    return {wc=wc, wm=wm, combos=combos or {"none"}, rank=rank or 0, go=go or 0,
            blessing_chip_mult=b_cm, blessing_mult_bonus=b_mm,
            talisman_chips=tal_c or 0, talisman_mult=tal_m or 0, talisman_final_mult=tal_f or 1}
end

-- ===== 보스 target_score 테이블 (코드 기준) =====
local BOSS = {
    -- normal tier
    glutton=150, trickster=160, thief=150, flame=230, fog=220, fox=280,
    shadow=220, rain=280,
    -- 추가 normal
    egg_ghost=190, samjokgu=230, dokkaebi_fire=220, mudang=270,
    mask=270, gumiho=260, dream=260, quake=280,
    -- elite tier
    cursed_ghost=350, illusionist=380, mirror=340, fog_walker=320,
    poison=420, greed=450, bone=430, mask_elite=400,
    fortune=460, debt=470, oath=480,
    -- high elite
    volcano=420, gold=450, corridor=430, clock=400,
    bone_shaman=460, blood_rain=470, nightmare=480,
    ancient_tree=500, dragon_king=500, sky_demon=480,
    dark_warrior=490, iron_bull=550,
    -- boss
    yeomra=600,
    -- calamity
    skeleton_gen=3000, ninetail_king=4000, imugi=3500, underworld_flower=2500,
}

print("================================================================")
print("  도깨비의 패 - 밸런스 시뮬레이션 v5 (대규모)")
print("  mult캡=10 | Go=2/3/8 | 최소뎀=15 | 섯다상향 | 부적/축복 포함")
print("================================================================")

-- ============================================================
print("\n━━━━━ 1. P1 김모름 (⭐ 입문) — 윤회1 ━━━━━")
print("  족보 0~1개, Go 안 함, 부적 없음\n")
-- ============================================================

sim_battle("P1 | 윤1 관1 먹보 (족보 0, 최악)", 150, 1, 1, 7, {
    P1(0, 0), P1(0, 1), P1(0, 2), P1(0, 0), P1(0, 1), P1(0, 0), P1(0, 0),
}, true)

sim_battle("P1 | 윤1 관1 먹보 (홍단 1개)", 150, 1, 1, 7, {
    P1(0, 5), {combos={"hongdan"}, rank=72}, P1(0, 75), P1(0, 7), P1(0, 3), P1(0, 1), P1(0, 0),
}, true)

sim_brief("P1 | 윤1 관3 불꽃 (단일+홍단)", 230, 1, 3, 7, {
    P1(0, 3), {combos={"hongdan"}, rank=70}, {combos={"wolhap"}, rank=72},
    P1(0, 8), {combos={"pibada"}, rank=5}, P1(0, 1), P1(0, 0),
})

sim_brief("P1 | 윤1 관5 여우 (약한 플레이)", 280, 1, 5, 7, {
    P1(0, 5), {combos={"hongdan"}, rank=75}, {combos={"cheongdan"}, rank=72},
    {combos={"wolhap"}, rank=70}, P1(0, 8), {combos={"pibada"}, rank=3}, P1(0, 0),
})

sim_brief("P1 | 윤1 관10 엘리트(350) 한계", 350, 1, 10, 7, {
    P1(0, 5), {combos={"hongdan"}, rank=75}, {combos={"cheongdan"}, rank=72},
    {combos={"wolhap"}, rank=70}, {combos={"godori"}, rank=8},
    {combos={"pibada"}, rank=3}, P1(0, 0),
})

-- ============================================================
print("\n━━━━━ 2. P2 이배움 (⭐⭐ 초급) — 윤회1 풀런 ━━━━━")
print("  족보 2~3개, Go 1, 부적 1~2개\n")
-- ============================================================

-- 20관문 풀런 시뮬레이션 (주요 관문만)
local p2_targets = {
    {1,  "관1 먹보",     150, "normal"},
    {3,  "관3 불꽃",     230, "normal"},
    {5,  "관5 여우",     280, "normal"},
    {7,  "관7 무당",     270, "normal"},
    {10, "관10 저승사자", 450, "elite"},
    {13, "관13 운명",    460, "elite"},
    {15, "관15 황금",    450, "elite"},
    {18, "관18 악몽",    480, "elite"},
    {20, "관20 염라",    600, "boss"},
}

for _, t in ipairs(p2_targets) do
    local realm, name, target, tier = t[1], t[2], t[3], t[4]
    local cfgs
    if tier == "normal" then
        cfgs = {
            {combos={"hongdan"}, rank=75, go=1},
            {combos={"wolhap"}, rank=72},
            {combos={"cheongdan"}, rank=70},
            P1(0, 8), P1(0, 5), P1(0, 3), P1(0, 0),
        }
    elseif tier == "elite" then
        cfgs = {
            {combos={"hongdan","chodan"}, rank=90, go=1},
            {combos={"cheongdan"}, rank=75, go=1},
            {combos={"godori"}, rank=72},
            {combos={"wolhap"}, rank=70, go=1},
            {combos={"pibada"}, rank=8},
            P1(0, 5), P1(0, 3), P1(0, 1),
        }
    else -- boss
        cfgs = {
            {combos={"hongdan","chodan"}, rank=90, go=1},
            {combos={"cheongdan"}, rank=75, go=1},
            {combos={"godori"}, rank=72},
            {combos={"wolhap"}, rank=70, go=1},
            {combos={"pibada"}, rank=8},
            P1(0, 5), P1(0, 3), P1(0, 1),
        }
    end
    sim_brief(string.format("P2 | 윤1 %s (%s)", name, tier), target, 1, realm, 8, cfgs)
end

-- ============================================================
print("\n━━━━━ 3. P3 박전략 (⭐⭐⭐ 중급) — 윤회1~4 ━━━━━")
print("  족보 3~4개, Go 1~2, 축복:빙결, 부적 없음\n")
-- ============================================================

for sp = 1, 4 do
    local wc = math.min((sp - 1) * 10, 80)
    local wm = math.min((sp - 1) * 0.3, 1.5)
    -- 관문 1 (normal)
    sim_brief(string.format("P3 | 윤%d 관1 먹보(빙결)", sp), 150, sp, 1, 7, {
        P3(wc, wm, 1, 75, {"hongdan"}, "ice"),
        P3(wc, wm, 0, 72, {"wolhap"}, "ice"),
        P3(wc, wm, 0, 70, {"cheongdan"}, "ice"),
        P3(wc, wm, 0, 8, {"single"}, "ice"),
        P3(wc, wm, 0, 5, {"none"}, "ice"),
        P3(wc, wm, 0, 3, {"none"}, "ice"),
        P3(wc, wm, 0, 0, {"none"}, "ice"),
    })
    -- 관문 10 (elite)
    sim_brief(string.format("P3 | 윤%d 관10 엘리트(빙결)", sp), 450, sp, 10, 7, {
        P3(wc, wm, 2, 90, {"hongdan","cheongdan","chodan"}, "ice"),
        P3(wc, wm, 1, 75, {"godori","wolhap"}, "ice"),
        P3(wc, wm, 1, 72, {"pibada"}, "ice"),
        P3(wc, wm, 0, 70, {"wolhap"}, "ice"),
        P3(wc, wm, 0, 8, {"single"}, "ice"),
        P3(wc, wm, 0, 5, {"none"}, "ice"),
        P3(wc, wm, 0, 3, {"none"}, "ice"),
    })
    -- 관문 20 (boss)
    sim_brief(string.format("P3 | 윤%d 관20 염라(빙결)", sp), 600, sp, 20, 8, {
        P3(wc, wm, 2, 100, {"hongdan","cheongdan","chodan"}, "ice"),
        P3(wc, wm, 1, 90, {"samgwang","godori"}, "ice"),
        P3(wc, wm, 1, 75, {"pibada","wolhap"}, "ice"),
        P3(wc, wm, 0, 72, {"dokkaebi_bm"}, "ice"),
        P3(wc, wm, 0, 70, {"hongdan"}, "ice"),
        P3(wc, wm, 0, 8, {"wolhap"}, "ice"),
        P3(wc, wm, 0, 5, {"single"}, "ice"),
        P3(wc, wm, 0, 3, {"none"}, "ice"),
    })
end

-- ============================================================
print("\n━━━━━ 4. P4 최고수 (⭐⭐⭐⭐ 상급) — 윤회1~10 ━━━━━")
print("  풀콤보, Go 2~3, 축복:공허, 부적: 칩+30 배수+0.3 최종x1.3\n")
-- ============================================================

for sp = 1, 10 do
    local wc = math.min((sp - 1) * 10, 80)
    local wm = math.min((sp - 1) * 0.2, 1.5)
    -- 관문 20 (boss)
    sim_brief(string.format("P4 | 윤%2d 관20 염라(공허+부적)", sp), 600, sp, 20, 8, {
        P4(wc, wm, 3, 100, {"samdantong","hongdan","cheongdan","chodan"}, "ice", 30, 0.3, 1.3),
        P4(wc, wm, 2, 90, {"ogwang","godori"}, "ice", 30, 0.3, 1.3),
        P4(wc, wm, 2, 75, {"samgwang","wolhap"}, "ice", 30, 0.3, 1.3),
        P4(wc, wm, 1, 72, {"pibada","pi10"}, "ice", 30, 0.3, 1.3),
        P4(wc, wm, 1, 70, {"hongdan","dokkaebi_bm"}, "ice", 30, 0.3, 1.3),
        P4(wc, wm, 1, 8, {"wolhap"}, "ice", 30, 0.3, 1.3),
        P4(wc, wm, 0, 5, {"single"}, "ice", 30, 0.3, 1.3),
        P4(wc, wm, 0, 3, {"none"}, "ice", 30, 0.3, 1.3),
    })
end

-- ============================================================
print("\n━━━━━ 5. 고수 (⭐⭐⭐⭐⭐) — 윤회10~15 극한 ━━━━━")
print("  풀빌드, Go 3 매 판, 최강 부적: 칩+50 배수+0.5 최종x1.5\n")
-- ============================================================

for sp = 10, 15 do
    local wc, wm = 80, 1.5
    -- 관문 20 (boss)
    sim_brief(string.format("고수 | 윤%2d 관20 염라(풀빌드)", sp), 600, sp, 20, 8, {
        P4(wc, wm, 3, 100, {"samdantong","hongdan","cheongdan","chodan"}, "ice", 50, 0.5, 1.5),
        P4(wc, wm, 3, 90, {"ogwang","godori"}, "ice", 50, 0.5, 1.5),
        P4(wc, wm, 2, 75, {"samgwang","wolhap"}, "ice", 50, 0.5, 1.5),
        P4(wc, wm, 2, 72, {"pibada","pi10"}, "ice", 50, 0.5, 1.5),
        P4(wc, wm, 1, 70, {"hongdan","dokkaebi_bm"}, "ice", 50, 0.5, 1.5),
        P4(wc, wm, 1, 8, {"wolhap"}, "ice", 50, 0.5, 1.5),
        P4(wc, wm, 0, 5, {"single"}, "ice", 50, 0.5, 1.5),
        P4(wc, wm, 0, 3, {"none"}, "ice", 50, 0.5, 1.5),
    })
end

-- ============================================================
print("\n━━━━━ 6. 재앙 보스 — 윤회3~7 ━━━━━")
print("  상급 빌드, Go 3 적극 사용\n")
-- ============================================================

local calamity_tests = {
    {3, "백골대장",   3000},
    {5, "구미호왕",   4000},
    {5, "이무기",     3500},
    {7, "저승꽃",     2500},
}

for _, ct in ipairs(calamity_tests) do
    local sp, name, target = ct[1], ct[2], ct[3]
    local wc = math.min((sp - 1) * 10, 80)
    local wm = math.min((sp - 1) * 0.3, 1.5)
    sim_brief(string.format("재앙 | 윤%d %s(부적 포함)", sp, name), target, sp, 10, 8, {
        P4(wc, wm, 3, 100, {"samdantong","hongdan","cheongdan","chodan"}, "ice", 30, 0.3, 1.3),
        P4(wc, wm, 3, 90, {"ogwang","godori"}, "ice", 30, 0.3, 1.3),
        P4(wc, wm, 2, 75, {"samgwang","wolhap"}, "ice", 30, 0.3, 1.3),
        P4(wc, wm, 2, 72, {"pibada","pi10"}, "ice", 30, 0.3, 1.3),
        P4(wc, wm, 1, 70, {"hongdan","dokkaebi_bm"}, "ice", 30, 0.3, 1.3),
        P4(wc, wm, 1, 8, {"wolhap"}, "ice", 30, 0.3, 1.3),
        P4(wc, wm, 0, 5, {"single"}, "ice", 30, 0.3, 1.3),
        P4(wc, wm, 0, 3, {"none"}, "ice", 30, 0.3, 1.3),
    })
end

-- ============================================================
print("\n━━━━━ 7. 축복 비교 (같은 상황, 다른 축복) ━━━━━")
print("  윤회3 관20 염라, P3 수준\n")
-- ============================================================

local blessings = {"none", "fire", "ice"}
for _, bl in ipairs(blessings) do
    local wc, wm = 20, 0.6
    local label = bl == "none" and "축복 없음" or (bl == "fire" and "업화(칩+20%)" or "빙결(배수+1)")
    sim_brief(string.format("축복비교 | 윤3 염라 — %s", label), 600, 3, 20, 8, {
        P3(wc, wm, 2, 100, {"hongdan","cheongdan","chodan"}, bl),
        P3(wc, wm, 1, 90, {"samgwang","godori"}, bl),
        P3(wc, wm, 1, 75, {"pibada","wolhap"}, bl),
        P3(wc, wm, 0, 72, {"dokkaebi_bm"}, bl),
        P3(wc, wm, 0, 70, {"hongdan"}, bl),
        P3(wc, wm, 0, 8, {"wolhap"}, bl),
        P3(wc, wm, 0, 5, {"single"}, bl),
        P3(wc, wm, 0, 3, {"none"}, bl),
    })
end

-- ============================================================
print("\n━━━━━ 8. 데미지 성장 곡선 (같은 패턴, 윤회 진행) ━━━━━")
-- ============================================================

print("\n  [홍단+알리+Go1, 부적 없음]")
io.write("  ")
for sp = 1, 15 do
    local wc = math.min((sp-1)*10, 80)
    local wm = math.min((sp-1)*0.2, 1.5)
    local chips = wc + 5 + 18 + 14
    local mult = math.min(1.0 + wm + 0.2 + 0.15, MULT_CAP)
    local base = 25
    local gm = 2
    local dmg = math.floor((base + chips) * mult * gm)
    io.write(string.format("윤%d:%s  ", sp, NumFmt.format(dmg)))
    if sp == 8 then io.write("\n  ") end
end
print()

print("\n  [삼단통+38광땡+Go3, 풀부적]")
io.write("  ")
for sp = 1, 15 do
    local wc = math.min((sp-1)*10, 80)
    local wm = math.min((sp-1)*0.2, 1.5)
    local chips = (wc + 5 + 50 + 45 + 18 + 18 + 18) * 1.0
    local mult = math.min(1.0 + wm + 0.5 + 0.5 + 0.2 + 0.2 + 0.2 + 0.5, MULT_CAP)
    local base = 60
    local gm = 8
    local tal_f = 1.5
    local dmg = math.floor((base + chips) * mult * gm * tal_f)
    io.write(string.format("윤%d:%s  ", sp, NumFmt.format(dmg)))
    if sp == 8 then io.write("\n  ") end
end
print()

-- ============================================================
print("\n================================================================")
print(string.format("  시뮬레이션 완료 — 통과: %d / 실패: %d / 총: %d",
    pass_count, fail_count, pass_count + fail_count))
print(string.format("  통과율: %.0f%%", pass_count / (pass_count + fail_count) * 100))
print("================================================================")

--- 밸런스 시뮬레이션 v6 — 추가 시나리오
--- v5에서 발견된 문제점 심층 검증:
--- 1. P2 윤회1 풀런: 영구강화 2~3런 후 클리어 가능한가?
--- 2. 고수 윤회13+: 영구강화 풀업 시 돌파 가능한가?
--- 3. 데미지 성장이 윤회9에서 멈추는 문제 → 영구강화 효과
--- 4. 엽전 경제: 상점에서 부적 살 여유가 되는가?
--- 5. 축복 밸런스: 공허가 너무 강한가?
--- 6. 극한 시나리오: 저주 부적 3개, 운 나쁜 케이스

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
    elseif rank == 73 then return 20
    elseif rank == 72 then return 18
    elseif rank == 71 then return 15
    elseif rank == 70 then return 12
    elseif rank >= 7 then return 6 + rank
    elseif rank >= 1 then return 4 + rank
    else return 5 end
end

local COMBOS = {
    ogwang={50,0.6}, samdantong={45,0.5}, gwangttaeng={45,0.5},
    hwangcheon={60,0.6}, sagwang={35,0.4}, samgwang={22,0.3},
    jangttaeng={30,0.4}, hongdan={18,0.2}, cheongdan={18,0.2},
    chodan={18,0.2}, godori={18,0.2}, ali={14,0.15},
    doksa={12,0.15}, gupping={10,0.1}, wolhap={10,0.1},
    pibada={12,0.15}, pi10={10,0.1}, dokkaebi_bm={14,0.15},
    tti5={12,0.15}, geurim5={12,0.15},
    single={3,0}, none={0,0},
}

local MULT_CAP = 10.0
local GO_MULT = {[1]=2, [2]=3, [3]=8}
local MIN_DAMAGE = 15

local function boss_hp(target, spiral, realm)
    realm = realm or 1
    return math.floor(target * (1.4 ^ (spiral - 1)) * (1.0 + 0.05 * (realm - 1)))
end

local function sim_round(cfg)
    local wc = math.min(cfg.wc or 0, 200)  -- 영구강화 포함 시 캡 높게
    local wm = math.min(cfg.wm or 0, 5.0)
    local carry = math.min((cfg.carry or 0) * 0.5, 100)
    local b_cm = cfg.blessing_chip_mult or 1.0
    local b_mm = cfg.blessing_mult_bonus or 0
    local tal_c = cfg.talisman_chips or 0
    local tal_m = cfg.talisman_mult or 0
    local tal_f = cfg.talisman_final_mult or 1

    local chips = (wc + carry + 5 + tal_c) * b_cm
    local mult = 1.0 + wm + b_mm + tal_m

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
    local dmg = math.floor(math.max((base + chips) * mult * gm * tal_f, MIN_DAMAGE))
    local new_carry = math.min(carry + chips * 0.5, 100)
    return dmg, chips, mult, new_carry
end

local pass_count, fail_count = 0, 0

local function sim_brief(name, target, spiral, realm, rounds, cfgs)
    local hp = boss_hp(target, spiral, realm)
    local total, carry = 0, 0
    for i = 1, rounds do
        local cfg = cfgs[math.min(i, #cfgs)]
        cfg.carry = carry; cfg.stack = i - 1
        local dmg, _, _, nc = sim_round(cfg)
        total = total + dmg; carry = nc
        if total >= hp then
            pass_count = pass_count + 1
            io.write(string.format("  %-50s HP:%-7s → %d판 ✓\n", name, NumFmt.format(hp), i))
            return true, i
        end
    end
    fail_count = fail_count + 1
    io.write(string.format("  %-50s HP:%-7s → 실패 %d%%\n", name, NumFmt.format(hp), math.floor(total/hp*100)))
    return false, rounds
end

-- 빌드 헬퍼
local function build(wc, wm, go, rank, combos, opts)
    opts = opts or {}
    return {
        wc=wc, wm=wm, combos=combos or {"none"}, rank=rank or 0, go=go or 0,
        blessing_chip_mult=opts.bcm or 1, blessing_mult_bonus=opts.bmm or 0,
        talisman_chips=opts.tc or 0, talisman_mult=opts.tm or 0, talisman_final_mult=opts.tf or 1,
    }
end

print("================================================================")
print("  도깨비의 패 - 밸런스 시뮬레이션 v6 (심층 검증)")
print("================================================================")

-- ============================================================
print("\n━━━━━ 1. P2 초급 멀티런 클리어 경로 ━━━━━")
print("  런 1→사망→영구강화→런 2→사망→영구강화→런 3→클리어?\n")
-- ============================================================

-- 런 1: 영구강화 0, Go 1, 족보 2개
-- 예상: 관문 13~15에서 사망
print("  [런 1: 영구강화 없음]")
local p2_r1 = {
    build(0,0, 1, 75, {"hongdan"}),
    build(0,0, 0, 72, {"wolhap"}),
    build(0,0, 0, 70, {"cheongdan"}),
    build(0,0, 0, 8, {"single"}),
    build(0,0, 0, 5, nil), build(0,0, 0, 3, nil), build(0,0, 0, 0, nil),
}
sim_brief("런1 P2 | 윤1 관10 저승사자", 450, 1, 10, 7, p2_r1)
sim_brief("런1 P2 | 윤1 관15 황금", 450, 1, 15, 7, p2_r1)

-- 런 2: 영구강화 칩+5, 배수+0 (20넋 사용)
print("  [런 2: 칩+5, 시작엽전+30 강화]")
local p2_r2 = {
    build(5,0, 1, 75, {"hongdan"}),
    build(5,0, 1, 72, {"cheongdan"}),
    build(5,0, 0, 70, {"wolhap"}),
    build(5,0, 0, 8, {"single"}),
    build(5,0, 0, 5, nil), build(5,0, 0, 3, nil), build(5,0, 0, 0, nil), build(5,0, 0, 0, nil),
}
sim_brief("런2 P2 | 윤1 관15 황금", 450, 1, 15, 8, p2_r2)
sim_brief("런2 P2 | 윤1 관20 염라", 600, 1, 20, 8, p2_r2)

-- 런 3: 영구강화 칩+10, 배수+1 (누적 120넋)
print("  [런 3: 칩+10, 배수+1 강화]")
local p2_r3 = {
    build(10,0.15, 1, 90, {"hongdan","chodan"}),
    build(10,0.15, 1, 75, {"cheongdan"}),
    build(10,0.15, 0, 72, {"godori"}),
    build(10,0.15, 1, 70, {"wolhap"}),
    build(10,0.15, 0, 8, {"pibada"}),
    build(10,0.15, 0, 5, nil), build(10,0.15, 0, 3, nil), build(10,0.15, 0, 0, nil),
}
sim_brief("런3 P2 | 윤1 관15 황금", 450, 1, 15, 8, p2_r3)
sim_brief("런3 P2 | 윤1 관18 악몽", 480, 1, 18, 8, p2_r3)
sim_brief("런3 P2 | 윤1 관20 염라", 600, 1, 20, 8, p2_r3)

-- ============================================================
print("\n━━━━━ 2. 고수 윤회13+ 영구강화 풀업 시나리오 ━━━━━")
print("  영구강화: 칩+30, 배수+3, 체력+3, 손패+2\n")
-- ============================================================

-- 영구강화 풀업: wc = 80 + perm_chips(30) = 110, wm = 1.5 + perm_mult(0.45) = 1.95 → 캡 적용
for sp = 10, 20 do
    sim_brief(string.format("고수풀업 | 윤%2d 관20 염라", sp), 600, sp, 20, 8, {
        build(110, 1.95, 3, 100, {"samdantong","hongdan","cheongdan","chodan"}, {bcm=1, bmm=1, tc=50, tm=0.5, tf=1.5}),
        build(110, 1.95, 3, 90, {"ogwang","godori"}, {bcm=1, bmm=1, tc=50, tm=0.5, tf=1.5}),
        build(110, 1.95, 2, 75, {"samgwang","wolhap"}, {bcm=1, bmm=1, tc=50, tm=0.5, tf=1.5}),
        build(110, 1.95, 2, 72, {"pibada","pi10"}, {bcm=1, bmm=1, tc=50, tm=0.5, tf=1.5}),
        build(110, 1.95, 1, 70, {"hongdan","dokkaebi_bm"}, {bcm=1, bmm=1, tc=50, tm=0.5, tf=1.5}),
        build(110, 1.95, 1, 8, {"wolhap"}, {bcm=1, bmm=1, tc=50, tm=0.5, tf=1.5}),
        build(110, 1.95, 0, 5, {"single"}, {bcm=1, bmm=1, tc=50, tm=0.5, tf=1.5}),
        build(110, 1.95, 0, 3, nil, {bcm=1, bmm=1, tc=50, tm=0.5, tf=1.5}),
    })
end

-- ============================================================
print("\n━━━━━ 3. 엽전 경제 시뮬레이션 ━━━━━")
print("  시작 50냥 + 관문별 보상으로 상점에서 부적 살 수 있는가?\n")
-- ============================================================

local yeop = 50
local shop_costs = {common=35, rare=80, legendary=200, health=75}
print(string.format("  시작 엽전: %d냥\n", yeop))

local rewards = {
    {realm=1,  name="관1 먹보",    yeop_add=25, tier="normal"},
    {realm=2,  name="관2 (이벤트)", yeop_add=30, tier="event"},
    {realm=3,  name="관3 불꽃",    yeop_add=35, tier="normal"},
    {realm=4,  name="관4 (이벤트)", yeop_add=20, tier="event"},
    {realm=5,  name="관5 여우",    yeop_add=40, tier="normal"},
    {realm=6,  name="관6 (상점)",  yeop_add=0,  tier="shop", buy="common"},
    {realm=7,  name="관7 무당",    yeop_add=40, tier="normal"},
    {realm=8,  name="관8 (상점)",  yeop_add=0,  tier="shop", buy="rare"},
    {realm=9,  name="관9 삼족구",  yeop_add=45, tier="normal"},
    {realm=10, name="관10 엘리트", yeop_add=50, tier="elite"},
    {realm=11, name="관11 (이벤트)",yeop_add=35, tier="event"},
    {realm=12, name="관12 (상점)", yeop_add=0,  tier="shop", buy="common"},
    {realm=15, name="관15 엘리트", yeop_add=55, tier="elite"},
    {realm=18, name="관18 (상점)", yeop_add=0,  tier="shop", buy="legendary"},
    {realm=20, name="관20 염라",   yeop_add=80, tier="boss"},
}

for _, r in ipairs(rewards) do
    yeop = yeop + r.yeop_add
    local note = ""
    if r.tier == "shop" and r.buy then
        local cost = shop_costs[r.buy] or 0
        if yeop >= cost then
            yeop = yeop - cost
            note = string.format(" → 구매 [%s] -%d냥", r.buy, cost)
        else
            note = string.format(" → 구매 불가 [%s] 필요 %d냥", r.buy, cost)
        end
    end
    io.write(string.format("  %s: +%d냥 → 잔액 %d냥%s\n", r.name, r.yeop_add, yeop, note))
end

-- ============================================================
print("\n━━━━━ 4. 축복 밸런스 심층 비교 ━━━━━")
print("  같은 빌드, 윤회 1~5, 모든 축복\n")
-- ============================================================

local bless = {
    {name="없음",  bcm=1, bmm=0},
    {name="업화",  bcm=1.2, bmm=0},
    {name="빙결",  bcm=1, bmm=1},
    {name="공허",  bcm=1, bmm=0, tc=0, tm=0, tf=2.0},  -- 부적 효과 2배
}

for sp = 1, 5 do
    local wc = math.min((sp-1)*10, 80)
    local wm = math.min((sp-1)*0.2, 1.5)
    for _, bl in ipairs(bless) do
        local opts = {bcm=bl.bcm, bmm=bl.bmm, tc=bl.tc or 0, tm=bl.tm or 0, tf=bl.tf or 1}
        sim_brief(string.format("윤%d 염라 [%s]", sp, bl.name), 600, sp, 20, 8, {
            build(wc, wm, 2, 100, {"hongdan","cheongdan","chodan"}, opts),
            build(wc, wm, 1, 90, {"samgwang","godori"}, opts),
            build(wc, wm, 1, 75, {"pibada","wolhap"}, opts),
            build(wc, wm, 0, 72, {"dokkaebi_bm"}, opts),
            build(wc, wm, 0, 70, {"hongdan"}, opts),
            build(wc, wm, 0, 8, {"wolhap"}, opts),
            build(wc, wm, 0, 5, {"single"}, opts),
            build(wc, wm, 0, 3, nil, opts),
        })
    end
    print()
end

-- ============================================================
print("━━━━━ 5. 극한/엣지 케이스 ━━━━━\n")
-- ============================================================

-- 저주 부적 3개: 칩-10/판, 배수-0.3/스톱, 손패-1
sim_brief("저주3개 | 윤1 관1 먹보 (칩-10)", 150, 1, 1, 7, {
    build(-10, -0.3, 0, 5, {"hongdan"}),
    build(-10, -0.3, 0, 72, {"wolhap"}),
    build(-10, -0.3, 0, 75, nil),
    build(-10, -0.3, 0, 7, nil),
    build(-10, -0.3, 0, 3, nil),
    build(-10, -0.3, 0, 1, nil),
    build(-10, -0.3, 0, 0, nil),
})

-- 운 최악: 매 판 갑오(rank 0), 족보 0
sim_brief("운최악 | 윤1 관1 먹보 (갑오만)", 150, 1, 1, 7, {
    build(0,0,0,0,nil), build(0,0,0,0,nil), build(0,0,0,0,nil),
    build(0,0,0,0,nil), build(0,0,0,0,nil), build(0,0,0,0,nil), build(0,0,0,0,nil),
})

-- 운 최고: 매 판 38광땡+삼단통+Go3
sim_brief("운최고 | 윤1 관20 염라 (38광+삼단+Go3)", 600, 1, 20, 3, {
    build(0,0, 3, 100, {"samdantong","hongdan","cheongdan","chodan","ogwang"}),
    build(0,0, 3, 100, {"samdantong","hongdan","cheongdan","chodan"}),
    build(0,0, 3, 90, {"ogwang","godori"}),
})

-- Go 3 매판 시도 (즉사 10% × 8판 = 57% 생존 확률)
print("\n  [Go 3 즉사 확률]")
local survive = 1
for round = 1, 8 do
    survive = survive * 0.9
    io.write(string.format("  %d판 Go3: 생존 %.0f%%", round, survive * 100))
    if round == 4 then io.write(" ← 절반\n") else io.write("\n") end
end

-- ============================================================
print("\n━━━━━ 6. 데미지 성장 곡선 (영구강화 포함) ━━━━━\n")
-- ============================================================

print("  [홍단+알리+Go1, 영구강화 칩+5/윤회]")
io.write("  ")
for sp = 1, 20 do
    local perm_c = math.min(sp * 5, 50)
    local wc = math.min((sp-1)*10 + perm_c, 200)
    local wm = math.min((sp-1)*0.2, 1.5)
    local chips = wc + 5 + 18 + 14
    local mult = math.min(1.0 + wm + 0.2 + 0.15, MULT_CAP)
    local dmg = math.floor((25 + chips) * mult * 2)
    io.write(string.format("윤%d:%s ", sp, NumFmt.format(dmg)))
    if sp % 10 == 0 then io.write("\n  ") end
end
print()

print("  [보스 HP vs 최대 데미지/판 (윤회별)]")
io.write("  ")
for sp = 1, 20 do
    local hp = boss_hp(600, sp, 20)
    io.write(string.format("윤%d:HP=%s ", sp, NumFmt.format(hp)))
    if sp % 5 == 0 then io.write("\n  ") end
end

print("\n================================================================")
print(string.format("  시뮬레이션 완료 — 통과: %d / 실패: %d / 총: %d",
    pass_count, fail_count, pass_count + fail_count))
print(string.format("  통과율: %.0f%%", pass_count / math.max(pass_count + fail_count, 1) * 100))
print("================================================================")

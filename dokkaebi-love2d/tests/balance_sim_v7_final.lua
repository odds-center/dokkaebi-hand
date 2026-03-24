--- 밸런스 시뮬레이션 v7 — 최종 패치 검증
--- 변경: HP 1.35^n, realm_mult 0.03, 빙결+0.5, 공허x1.5, 업화+30%

local NumFmt = { format = function(n)
    if n >= 1000000 then return string.format("%.1fM", n/1000000)
    elseif n >= 1000 then return string.format("%.1fK", n/1000)
    else return tostring(n) end
end }

local function seotda_base(rank)
    if rank == 100 then return 60 elseif rank == 99 then return 50
    elseif rank == 98 then return 45 elseif rank == 95 then return 35
    elseif rank >= 90 then return 30 elseif rank >= 80 then return 15+(rank-80)
    elseif rank == 75 then return 25 elseif rank == 74 then return 22
    elseif rank == 73 then return 20 elseif rank == 72 then return 18
    elseif rank == 71 then return 15 elseif rank == 70 then return 12
    elseif rank >= 7 then return 6+rank elseif rank >= 1 then return 4+rank
    else return 5 end
end

local COMBOS = {
    ogwang={50,0.6}, samdantong={45,0.5}, gwangttaeng={45,0.5},
    hwangcheon={60,0.6}, sagwang={35,0.4}, samgwang={22,0.3},
    jangttaeng={30,0.4}, hongdan={18,0.2}, cheongdan={18,0.2},
    chodan={18,0.2}, godori={18,0.2}, ali={14,0.15},
    wolhap={10,0.1}, pibada={12,0.15}, pi10={10,0.1},
    dokkaebi_bm={14,0.15}, single={3,0}, none={0,0},
}

local MULT_CAP = 10.0
local GO_MULT = {[1]=2, [2]=3, [3]=8}

local function boss_hp(target, spiral, realm)
    return math.floor(target * (1.35 ^ (spiral - 1)) * (1.0 + 0.03 * ((realm or 1) - 1)))
end

local function sim_round(cfg)
    local wc = math.min(cfg.wc or 0, 200)
    local wm = math.min(cfg.wm or 0, 5.0)
    local carry = math.min((cfg.carry or 0) * 0.5, 100)
    local chips = (wc + carry + 5 + (cfg.tc or 0)) * (cfg.bcm or 1)
    local mult = 1.0 + wm + (cfg.bmm or 0) + (cfg.tm or 0)
    for _, cid in ipairs(cfg.combos or {}) do
        local c = COMBOS[cid] or {0,0}; chips = chips + c[1]; mult = mult + c[2]
    end
    chips = chips + (cfg.stack or 0) * 3
    mult = math.min(mult, MULT_CAP)
    local base = seotda_base(cfg.rank or 5)
    local gm = GO_MULT[cfg.go or 0] or 1
    return math.floor(math.max((base+chips)*mult*gm*(cfg.tf or 1), 15)), chips, mult, math.min(carry+chips*0.5, 100)
end

local P, F = 0, 0
local function sim(name, target, spiral, realm, rounds, cfgs)
    local hp = boss_hp(target, spiral, realm)
    local total, carry = 0, 0
    for i = 1, rounds do
        local cfg = cfgs[math.min(i, #cfgs)]; cfg.carry=carry; cfg.stack=i-1
        local dmg,_,_,nc = sim_round(cfg); total=total+dmg; carry=nc
        if total >= hp then P=P+1; io.write(string.format("  %-50s HP:%-7s → %d판 ✓\n", name, NumFmt.format(hp), i)); return true end
    end
    F=F+1; io.write(string.format("  %-50s HP:%-7s → 실패 %d%%\n", name, NumFmt.format(hp), math.floor(total/hp*100))); return false
end

local function b(wc,wm,go,rank,combos,bcm,bmm,tc,tm,tf)
    return {wc=wc,wm=wm,go=go,rank=rank,combos=combos or {"none"},bcm=bcm or 1,bmm=bmm or 0,tc=tc or 0,tm=tm or 0,tf=tf or 1}
end

print("================================================================")
print("  v7 최종 — HP=1.35^n, realm+3%/관문, 빙결+0.5, 공허x1.5, 업화+30%")
print("================================================================")

-- ============================================================
print("\n━━━━━ 1. P1 입문 (⭐) ━━━━━\n")
sim("P1 | 최악(족보 0) 관1 먹보", 150, 1, 1, 7, {b(0,0,0,0,nil),b(0,0,0,1,nil),b(0,0,0,2,nil),b(0,0,0,0,nil),b(0,0,0,1,nil),b(0,0,0,0,nil),b(0,0,0,0,nil)})
sim("P1 | 홍단 1개 관1 먹보", 150, 1, 1, 7, {b(0,0,0,5,nil),b(0,0,0,72,{"hongdan"}),b(0,0,0,75,nil),b(0,0,0,7,nil),b(0,0,0,3,nil),b(0,0,0,0,nil)})
sim("P1 | 관5 여우", 280, 1, 5, 7, {b(0,0,0,5,nil),b(0,0,0,75,{"hongdan"}),b(0,0,0,72,{"cheongdan"}),b(0,0,0,70,{"wolhap"}),b(0,0,0,8,nil),b(0,0,0,3,{"pibada"}),b(0,0,0,0,nil)})

-- ============================================================
print("\n━━━━━ 2. P2 초급 (⭐⭐) 멀티런 ━━━━━\n")
-- ============================================================
print("  [런 1: 영구강화 없음]")
sim("런1 | 윤1 관10 저승사자", 450, 1, 10, 7, {b(0,0,1,75,{"hongdan"}),b(0,0,0,72,{"wolhap"}),b(0,0,0,70,{"cheongdan"}),b(0,0,0,8,nil),b(0,0,0,5,nil),b(0,0,0,3,nil),b(0,0,0,0,nil)})
sim("런1 | 윤1 관15 황금", 450, 1, 15, 7, {b(0,0,1,75,{"hongdan"}),b(0,0,0,72,{"wolhap"}),b(0,0,0,70,{"cheongdan"}),b(0,0,0,8,nil),b(0,0,0,5,nil),b(0,0,0,3,nil),b(0,0,0,0,nil)})

print("  [런 2: 칩+5 강화]")
sim("런2 | 윤1 관15 황금", 450, 1, 15, 8, {b(5,0,1,75,{"hongdan"}),b(5,0,1,72,{"cheongdan"}),b(5,0,0,70,{"wolhap"}),b(5,0,0,8,nil),b(5,0,0,5,nil),b(5,0,0,3,nil),b(5,0,0,0,nil),b(5,0,0,0,nil)})
sim("런2 | 윤1 관20 염라", 600, 1, 20, 8, {b(5,0,1,75,{"hongdan"}),b(5,0,1,72,{"cheongdan"}),b(5,0,0,70,{"wolhap"}),b(5,0,0,8,nil),b(5,0,0,5,nil),b(5,0,0,3,nil),b(5,0,0,0,nil),b(5,0,0,0,nil)})

print("  [런 3: 칩+10, 배수+1 강화]")
sim("런3 | 윤1 관15 황금", 450, 1, 15, 8, {b(10,0.15,1,90,{"hongdan","chodan"}),b(10,0.15,1,75,{"cheongdan"}),b(10,0.15,0,72,{"godori"}),b(10,0.15,1,70,{"wolhap"}),b(10,0.15,0,8,{"pibada"}),b(10,0.15,0,5,nil),b(10,0.15,0,3,nil),b(10,0.15,0,0,nil)})
sim("런3 | 윤1 관20 염라", 600, 1, 20, 8, {b(10,0.15,1,90,{"hongdan","chodan"}),b(10,0.15,1,75,{"cheongdan"}),b(10,0.15,0,72,{"godori"}),b(10,0.15,1,70,{"wolhap"}),b(10,0.15,0,8,{"pibada"}),b(10,0.15,0,5,nil),b(10,0.15,0,3,nil),b(10,0.15,0,0,nil)})

-- ============================================================
print("\n━━━━━ 3. P3 중급 (⭐⭐⭐) 윤회1~5 ━━━━━\n")
-- ============================================================
for sp = 1, 5 do
    local wc = math.min((sp-1)*10, 80)
    local wm = math.min((sp-1)*0.3, 1.5)
    sim(string.format("P3 | 윤%d 관20 염라(빙결)", sp), 600, sp, 20, 8, {
        b(wc,wm,2,100,{"hongdan","cheongdan","chodan"},1,0.5),
        b(wc,wm,1,90,{"samgwang","godori"},1,0.5),
        b(wc,wm,1,75,{"pibada","wolhap"},1,0.5),
        b(wc,wm,0,72,{"dokkaebi_bm"},1,0.5),
        b(wc,wm,0,70,{"hongdan"},1,0.5),
        b(wc,wm,0,8,{"wolhap"},1,0.5),
        b(wc,wm,0,5,nil,1,0.5),
        b(wc,wm,0,3,nil,1,0.5),
    })
end

-- ============================================================
print("\n━━━━━ 4. P4 상급 (⭐⭐⭐⭐) 윤회1~10 ━━━━━\n")
-- ============================================================
for sp = 1, 10 do
    local wc = math.min((sp-1)*10, 80)
    local wm = math.min((sp-1)*0.2, 1.5)
    sim(string.format("P4 | 윤%2d 관20 염라(부적)", sp), 600, sp, 20, 8, {
        b(wc,wm,3,100,{"samdantong","hongdan","cheongdan","chodan"},1,0.5,30,0.3,1.3),
        b(wc,wm,2,90,{"ogwang","godori"},1,0.5,30,0.3,1.3),
        b(wc,wm,2,75,{"samgwang","wolhap"},1,0.5,30,0.3,1.3),
        b(wc,wm,1,72,{"pibada","pi10"},1,0.5,30,0.3,1.3),
        b(wc,wm,1,70,{"hongdan","dokkaebi_bm"},1,0.5,30,0.3,1.3),
        b(wc,wm,1,8,{"wolhap"},1,0.5,30,0.3,1.3),
        b(wc,wm,0,5,nil,1,0.5,30,0.3,1.3),
        b(wc,wm,0,3,nil,1,0.5,30,0.3,1.3),
    })
end

-- ============================================================
print("\n━━━━━ 5. 고수 (⭐⭐⭐⭐⭐) 윤회10~20 ━━━━━\n")
-- ============================================================
for sp = 10, 20 do
    sim(string.format("고수 | 윤%2d 관20 염라(풀빌드)", sp), 600, sp, 20, 8, {
        b(110,1.95,3,100,{"samdantong","hongdan","cheongdan","chodan"},1,0.5,50,0.5,1.5),
        b(110,1.95,3,90,{"ogwang","godori"},1,0.5,50,0.5,1.5),
        b(110,1.95,2,75,{"samgwang","wolhap"},1,0.5,50,0.5,1.5),
        b(110,1.95,2,72,{"pibada","pi10"},1,0.5,50,0.5,1.5),
        b(110,1.95,1,70,{"hongdan","dokkaebi_bm"},1,0.5,50,0.5,1.5),
        b(110,1.95,1,8,{"wolhap"},1,0.5,50,0.5,1.5),
        b(110,1.95,0,5,nil,1,0.5,50,0.5,1.5),
        b(110,1.95,0,3,nil,1,0.5,50,0.5,1.5),
    })
end

-- ============================================================
print("\n━━━━━ 6. 재앙 보스 ━━━━━\n")
-- ============================================================
sim("재앙 | 윤3 백골대장(부적)", 3000, 3, 10, 8, {
    b(20,1,3,100,{"samdantong","hongdan","cheongdan","chodan"},1,0.5,30,0.3,1.3),
    b(20,1,3,90,{"ogwang","godori"},1,0.5,30,0.3,1.3),
    b(20,1,2,75,{"samgwang","wolhap"},1,0.5,30,0.3,1.3),
    b(20,1,2,72,{"pibada","pi10"},1,0.5,30,0.3,1.3),
    b(20,1,1,70,{"hongdan","dokkaebi_bm"},1,0.5,30,0.3,1.3),
    b(20,1,1,8,{"wolhap"},1,0.5,30,0.3,1.3),
    b(20,1,0,5,nil,1,0.5,30,0.3,1.3),
    b(20,1,0,3,nil,1,0.5,30,0.3,1.3),
})
sim("재앙 | 윤5 구미호왕(부적)", 4000, 5, 10, 8, {
    b(35,1.5,3,100,{"samdantong","hongdan","cheongdan","chodan"},1,0.5,30,0.3,1.3),
    b(35,1.5,3,90,{"ogwang","godori"},1,0.5,30,0.3,1.3),
    b(35,1.5,2,75,{"samgwang","wolhap"},1,0.5,30,0.3,1.3),
    b(35,1.5,2,72,{"pibada","pi10"},1,0.5,30,0.3,1.3),
    b(35,1.5,1,70,{"hongdan","dokkaebi_bm"},1,0.5,30,0.3,1.3),
    b(35,1.5,1,8,{"wolhap"},1,0.5,30,0.3,1.3),
    b(35,1.5,0,5,nil,1,0.5,30,0.3,1.3),
    b(35,1.5,0,3,nil,1,0.5,30,0.3,1.3),
})

-- ============================================================
print("\n━━━━━ 7. 축복 비교 (윤회3 염라) ━━━━━\n")
-- ============================================================
local wc3, wm3 = 20, 0.6
sim("축복 없음", 600, 3, 20, 8, {b(wc3,wm3,2,100,{"hongdan","cheongdan","chodan"}),b(wc3,wm3,1,90,{"samgwang","godori"}),b(wc3,wm3,1,75,{"pibada","wolhap"}),b(wc3,wm3,0,72,{"dokkaebi_bm"}),b(wc3,wm3,0,70,{"hongdan"}),b(wc3,wm3,0,8,{"wolhap"}),b(wc3,wm3,0,5,nil),b(wc3,wm3,0,3,nil)})
sim("업화(칩+30%)", 600, 3, 20, 8, {b(wc3,wm3,2,100,{"hongdan","cheongdan","chodan"},1.3),b(wc3,wm3,1,90,{"samgwang","godori"},1.3),b(wc3,wm3,1,75,{"pibada","wolhap"},1.3),b(wc3,wm3,0,72,{"dokkaebi_bm"},1.3),b(wc3,wm3,0,70,{"hongdan"},1.3),b(wc3,wm3,0,8,{"wolhap"},1.3),b(wc3,wm3,0,5,nil,1.3),b(wc3,wm3,0,3,nil,1.3)})
sim("빙결(배수+0.5)", 600, 3, 20, 8, {b(wc3,wm3,2,100,{"hongdan","cheongdan","chodan"},1,0.5),b(wc3,wm3,1,90,{"samgwang","godori"},1,0.5),b(wc3,wm3,1,75,{"pibada","wolhap"},1,0.5),b(wc3,wm3,0,72,{"dokkaebi_bm"},1,0.5),b(wc3,wm3,0,70,{"hongdan"},1,0.5),b(wc3,wm3,0,8,{"wolhap"},1,0.5),b(wc3,wm3,0,5,nil,1,0.5),b(wc3,wm3,0,3,nil,1,0.5)})
sim("공허(부적x1.5)", 600, 3, 20, 8, {b(wc3,wm3,2,100,{"hongdan","cheongdan","chodan"},1,0,0,0,1.5),b(wc3,wm3,1,90,{"samgwang","godori"},1,0,0,0,1.5),b(wc3,wm3,1,75,{"pibada","wolhap"},1,0,0,0,1.5),b(wc3,wm3,0,72,{"dokkaebi_bm"},1,0,0,0,1.5),b(wc3,wm3,0,70,{"hongdan"},1,0,0,0,1.5),b(wc3,wm3,0,8,{"wolhap"},1,0,0,0,1.5),b(wc3,wm3,0,5,nil,1,0,0,0,1.5),b(wc3,wm3,0,3,nil,1,0,0,0,1.5)})

-- ============================================================
print("\n━━━━━ 8. HP vs 데미지 성장 ━━━━━\n")
-- ============================================================
print("  [보스 HP (염라 관20)]")
io.write("  ")
for sp = 1, 20 do
    io.write(string.format("윤%d:%s ", sp, NumFmt.format(boss_hp(600, sp, 20))))
    if sp%5==0 then io.write("\n  ") end
end

print("\n================================================================")
print(string.format("  통과: %d / 실패: %d / 총: %d / 통과율: %.0f%%", P, F, P+F, P/(P+F)*100))
print("================================================================")

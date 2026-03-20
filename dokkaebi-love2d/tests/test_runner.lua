--- 간단한 테스트 러너 (love2d 없이 순수 lua로 실행)
--- 사용: lua tests/test_runner.lua

-- 프로젝트 루트에서 require 가능하도록
package.path = package.path .. ";../?.lua;../?/init.lua"

local passed = 0
local failed = 0
local errors = {}

local function assert_eq(a, b, msg)
    if a ~= b then
        error(string.format("%s: expected %s, got %s", msg or "assert_eq", tostring(b), tostring(a)), 2)
    end
end

local function assert_true(v, msg)
    if not v then error(msg or "assert_true failed", 2) end
end

local function test(name, fn)
    local ok, err = pcall(fn)
    if ok then
        passed = passed + 1
        io.write("  ✓ " .. name .. "\n")
    else
        failed = failed + 1
        table.insert(errors, { name = name, err = err })
        io.write("  ✗ " .. name .. ": " .. err .. "\n")
    end
end

-- =============================================
-- 테스트
-- =============================================

print("=== 카드 데이터베이스 ===")
local CardDB = require("src.cards.card_database")

test("48장 카드", function()
    assert_eq(CardDB.get_count(), 48)
end)

test("1번 카드 = 1월 광", function()
    local def = CardDB.get_by_index(1)
    assert_eq(def.month, 1)
    assert_eq(def.card_type, "gwang")
end)

print("\n=== 숫자 포맷터 ===")
local NF = require("src.core.number_formatter")

test("999 → 999", function() assert_eq(NF.format(999), "999") end)
test("1234 → 1234", function() assert_eq(NF.format(1234), "1234") end)
test("12345 → 12.3K", function() assert_eq(NF.format(12345), "12.3K") end)
test("1234567 → 1.2M", function() assert_eq(NF.format(1234567), "1.2M") end)

print("\n=== 섯다 판정 ===")
local CardInstance = require("src.cards.card_instance")
local Seotda = require("src.combat.seotda_challenge")

test("38광땡 = Rank 100", function()
    local c1 = CardInstance.new(1, { name="3g", name_kr="3월광", month=3, card_type="gwang", base_points=20 })
    local c2 = CardInstance.new(2, { name="8g", name_kr="8월광", month=8, card_type="gwang", base_points=20 })
    local r = Seotda.evaluate(c1, c2)
    assert_eq(r.rank, 100)
    assert_eq(r.name, "38광땡")
end)

test("알리 (1+2 그림패) = Rank 75", function()
    local c1 = CardInstance.new(1, { name="1g", name_kr="1월그림", month=1, card_type="geurim", base_points=10 })
    local c2 = CardInstance.new(2, { name="2g", name_kr="2월그림", month=2, card_type="geurim", base_points=10 })
    local r = Seotda.evaluate(c1, c2)
    assert_eq(r.rank, 75)
    assert_eq(r.name, "알리")
end)

test("피 2장 → 끗만 (족보 불가)", function()
    local c1 = CardInstance.new(1, { name="1p", name_kr="1월피", month=1, card_type="pi", base_points=1 })
    local c2 = CardInstance.new(2, { name="2p", name_kr="2월피", month=2, card_type="pi", base_points=1 })
    local r = Seotda.evaluate(c1, c2)
    assert_eq(r.rank, 3)  -- (1+2)%10 = 3끗
    assert_eq(r.name, "3끗")
end)

test("갑오 (2+8=10 그림패) = Rank 0", function()
    local c1 = CardInstance.new(1, { name="2g", name_kr="2월그림", month=2, card_type="geurim", base_points=10 })
    local c2 = CardInstance.new(2, { name="8g", name_kr="8월그림", month=8, card_type="geurim", base_points=10 })
    local r = Seotda.evaluate(c1, c2)
    assert_eq(r.rank, 0)
    assert_eq(r.name, "갑오")
end)

test("장땡 (10+10 그림패) = Rank 90", function()
    local c1 = CardInstance.new(1, { name="10g", name_kr="10월그림", month=10, card_type="geurim", base_points=10 })
    local c2 = CardInstance.new(2, { name="10t", name_kr="10월띠", month=10, card_type="tti", base_points=10 })
    local r = Seotda.evaluate(c1, c2)
    assert_eq(r.rank, 90)
    assert_eq(r.name, "장땡")
end)

test("섯다 데미지: 38광땡=35, 갑오=3", function()
    assert_eq(Seotda.base_damage(100), 35)
    assert_eq(Seotda.base_damage(0), 3)
end)

print("\n=== 덱 매니저 ===")
local DeckManager = require("src.cards.deck_manager")
local PlayerState = require("src.core.player_state")

test("덱 초기화 → 48장", function()
    local dm = DeckManager.new(42)
    dm:initialize_deck()
    assert_eq(#dm.draw_pile, 48)
end)

test("카드 분배 → 손패 10장", function()
    local dm = DeckManager.new(42)
    dm:initialize_deck()
    local p = PlayerState.new()
    dm:deal_cards(p, 10, 0)
    assert_eq(#p.hand, 10)
    assert_eq(#dm.draw_pile, 38)
end)

test("드로우 → 1장씩 감소", function()
    local dm = DeckManager.new(42)
    dm:initialize_deck()
    local c = dm:draw_from_pile()
    assert_true(c ~= nil)
    assert_eq(#dm.draw_pile, 47)
end)

-- =============================================
-- 결과
-- =============================================

print("\n=== 핸드 평가기 ===")
local HE = require("src.cards.hand_evaluator")

test("38광땡 콤보 발견", function()
    local c1 = CardInstance.new(1, { name="3g", name_kr="3월광", month=3, card_type="gwang", base_points=20 })
    local c2 = CardInstance.new(2, { name="8g", name_kr="8월광", month=8, card_type="gwang", base_points=20 })
    local combos = HE.evaluate({c1, c2})
    local found = false
    for _, c in ipairs(combos) do if c.id == "38gwangttaeng" then found = true end end
    assert_true(found, "38광땡 콤보 있어야 함")
end)

test("홍단 콤보 발견", function()
    local c1 = CardInstance.new(1, { name="1h", name_kr="1월홍", month=1, card_type="tti", ribbon="hongdan", base_points=10 })
    local c2 = CardInstance.new(2, { name="2h", name_kr="2월홍", month=2, card_type="tti", ribbon="hongdan", base_points=10 })
    local c3 = CardInstance.new(3, { name="3h", name_kr="3월홍", month=3, card_type="tti", ribbon="hongdan", base_points=10 })
    local combos = HE.evaluate({c1, c2, c3})
    local found = false
    for _, c in ipairs(combos) do if c.id == "hongdan" then found = true end end
    assert_true(found, "홍단 콤보 있어야 함")
end)

test("알리 콤보 (1+2월)", function()
    local c1 = CardInstance.new(1, { name="1p", name_kr="1월피", month=1, card_type="pi", base_points=1 })
    local c2 = CardInstance.new(2, { name="2p", name_kr="2월피", month=2, card_type="pi", base_points=1 })
    local combos = HE.evaluate({c1, c2})
    local found = false
    for _, c in ipairs(combos) do if c.id == "ali" then found = true end end
    assert_true(found, "알리 콤보 있어야 함")
end)

test("Seotda 최고 1개만", function()
    local c1 = CardInstance.new(1, { name="1p", name_kr="1월피", month=1, card_type="pi", base_points=1 })
    local c2 = CardInstance.new(2, { name="2p", name_kr="2월피", month=2, card_type="pi", base_points=1 })
    local combos = HE.evaluate({c1, c2})
    local seotda_count = 0
    for _, c in ipairs(combos) do if c.category == "seotda" then seotda_count = seotda_count + 1 end end
    assert_eq(seotda_count, 1, "Seotda 1개만")
end)

test("칩/배수 합산", function()
    local combos = {
        { chips = 100, mult = 2.0 },
        { chips = 50, mult = 1.5 },
    }
    local chips, mult = HE.get_total_score(combos)
    assert_eq(chips, 150)
    assert_true(math.abs(mult - 3.0) < 0.01, "mult should be 3.0")
end)

test("단일패 최소 3칩", function()
    local c1 = CardInstance.new(1, { name="1p", name_kr="1월피", month=1, card_type="pi", base_points=1 })
    local combos = HE.evaluate({c1})
    local found = false
    for _, c in ipairs(combos) do
        if c.id == "single" then
            assert_true(c.chips >= 3, "단일패 최소 3칩")
            found = true
        end
    end
    assert_true(found, "단일패 콤보 있어야 함")
end)

-- =============================================
-- 보스 시스템
-- =============================================
print("\n=== 보스 시스템 ===")
local BossData = require("src.combat.boss_data")
local BossBattle = require("src.combat.boss_battle")

test("보스 10종 존재", function()
    local all = BossData.get_all_bosses()
    assert_true(#all >= 10, "10종 이상")
end)

test("먹보 도깨비 = id glutton", function()
    local b = BossData.get_boss(1)
    assert_eq(b.id, "glutton")
    assert_eq(b.target_score, 100)
end)

test("보스 HP = TargetScore * 1.8^(spiral-1)", function()
    local b = BossData.get_boss(1)
    local battle = BossBattle.new(b, 1)
    assert_eq(battle.boss_max_hp, 100)

    local battle2 = BossBattle.new(b, 2)
    assert_eq(battle2.boss_max_hp, math.floor(100 * 1.8))
end)

test("보스 데미지 → HP 감소", function()
    local b = BossData.get_boss(1)
    local battle = BossBattle.new(b, 1)
    battle:deal_damage(50)
    assert_eq(battle.boss_current_hp, 50)
end)

test("보스 HP 0 → 격파", function()
    local b = BossData.get_boss(1)
    local battle = BossBattle.new(b, 1)
    local defeated = false
    battle.on_boss_defeated:connect(function() defeated = true end)
    battle:deal_damage(200)
    assert_true(battle:is_boss_defeated())
    assert_true(defeated)
    assert_eq(battle.boss_current_hp, 0)
end)

test("재앙 보스 (나선 3 = 백골대장)", function()
    local b = BossData.get_calamity_boss(3)
    assert_true(b ~= nil, "나선3 재앙 보스")
    assert_eq(b.id, "skeleton_general")
end)

test("나선 1,2에는 재앙 보스 없음", function()
    assert_true(BossData.get_calamity_boss(1) == nil)
    assert_true(BossData.get_calamity_boss(2) == nil)
end)

-- =============================================
-- 나선 시스템
-- =============================================
print("\n=== 나선 시스템 ===")
local SpiralMod = require("src.core.spiral_manager")
local SpiralManager = SpiralMod.SpiralManager

test("시작 = 나선1 영역1", function()
    local sp = SpiralManager.new()
    assert_eq(sp.current_spiral, 1)
    assert_eq(sp.current_realm, 1)
end)

test("20영역 → Gate 발생", function()
    local sp = SpiralManager.new()
    local gate = false
    for i = 1, 19 do
        gate = sp:advance_realm()
        assert_true(not gate, "19번째까지 gate 아님")
    end
    gate = sp:advance_realm()
    assert_true(gate, "20번째에 gate")
end)

test("ContinueToNextSpiral → 나선 증가", function()
    local sp = SpiralManager.new()
    for i = 1, 20 do sp:advance_realm() end
    sp:continue_to_next_spiral()
    assert_eq(sp.current_spiral, 2)
    assert_eq(sp.current_realm, 1)
end)

-- =============================================
-- 영구강화
-- =============================================
print("\n=== 영구강화 ===")
local PermanentUpgrades = require("src.core.permanent_upgrades")

test("초기 칩 보너스 = 0", function()
    local pu = PermanentUpgrades.new()
    assert_eq(pu:get_bonus_chips(), 0)
end)

test("칩 강화 Lv3 = +15", function()
    local pu = PermanentUpgrades.new()
    pu:set_level("base_chips", 3)
    assert_eq(pu:get_bonus_chips(), 15)
end)

test("배수 강화 Lv2 = +2", function()
    local pu = PermanentUpgrades.new()
    pu:set_level("base_mult", 2)
    assert_eq(pu:get_bonus_mult(), 2)
end)

-- =============================================
-- 넋 계산
-- =============================================
print("\n=== 넋 계산 ===")
local SoulCalc = require("src.core.soul_calculator")

test("1관문 격파 넋 = 12", function()
    local reward = SoulCalc.for_boss_defeat(1, 0, false)
    assert_eq(reward, 12)
end)

test("나선 1 완료 보너스 = 100", function()
    assert_eq(SoulCalc.for_spiral_complete(1), 100)
end)

test("사망 패널티 70%", function()
    assert_eq(SoulCalc.apply_death_penalty(100), 70)
end)

-- =============================================
-- 숫자 포맷 확장
-- =============================================
print("\n=== 숫자 포맷 확장 ===")

test("1B 포맷", function()
    assert_eq(NF.format(1500000000), "1.50B")
end)

test("과학적 표기", function()
    local s = NF.format_scientific(12345)
    assert_true(s:find("e4") ~= nil, "12345 → 1.23e4")
end)

-- =============================================
-- 최종 결과
-- =============================================
print(string.format("\n========================================"))
print(string.format("  결과: %d 통과, %d 실패", passed, failed))
print(string.format("========================================"))

if #errors > 0 then
    print("\n실패 목록:")
    for _, e in ipairs(errors) do
        print("  - " .. e.name .. ": " .. e.err)
    end
end

os.exit(failed > 0 and 1 or 0)

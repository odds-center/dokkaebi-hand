--- 웨이브 강화: 영역 클리어 시 3택 1 강화 선택 (VS 스타일)
--- 카테고리: card / talisman / survival / special
local PlayerState = require("src.core.player_state")

local WaveUpgradeManager = {}
WaveUpgradeManager.__index = WaveUpgradeManager

function WaveUpgradeManager.new()
    return setmetatable({
        current_choices = {},
    }, WaveUpgradeManager)
end

--- Fisher-Yates shuffle
local function shuffle(list)
    for i = #list, 2, -1 do
        local j = math.random(i)
        list[i], list[j] = list[j], list[i]
    end
end

--- 3개 랜덤 강화 선택지 생성
function WaveUpgradeManager:generate_choices(absolute_realm)
    self.current_choices = {}
    local pool = self:_get_upgrade_pool(absolute_realm)

    shuffle(pool)

    local count = math.min(3, #pool)
    for i = 1, count do
        table.insert(self.current_choices, pool[i])
    end
end

--- 선택 적용
--- @param player PlayerState
--- @param game GameManager (or table with .upgrades)
--- @param index number 1-based
--- @return boolean
function WaveUpgradeManager:apply_choice(player, game, index)
    if index < 1 or index > #self.current_choices then return false end
    local choice = self.current_choices[index]
    if choice.apply then
        choice.apply(player, game)
    end
    self.current_choices = {}
    return true
end

--- 강화 풀 생성 (나선 비례 기하급수 스케일링)
function WaveUpgradeManager:_get_upgrade_pool(realm)
    local spiral = math.max(1, math.floor((realm - 1) / 10) + 1)

    -- 칩: 기하급수 (x1.3/나선)
    local chip_amount = math.floor(20 * (1.3 ^ (spiral - 1)))

    -- 배수: 나선 10 이전은 가산, 10+ 부터는 곱셈 성장
    local mult_amount
    if spiral < 10 then
        mult_amount = math.max(1, math.floor(1 * (1.25 ^ (spiral - 1))))
    else
        mult_amount = math.max(5, math.floor(1.25 ^ (spiral - 1)))
    end

    local pool = {
        -- === A: 패 강화 (나선 비례) ===
        {
            id = "wave_chip_20",
            name_kr = "칩 강화 +" .. chip_amount,
            name_en = "Chip Boost",
            desc_kr = "이번 런 모든 족보 칩 +" .. chip_amount,
            desc_en = "+" .. chip_amount .. " Chips to all Yokbo",
            category = "card",
            apply = function(p, _g)
                p.wave_chip_bonus = p.wave_chip_bonus + chip_amount
            end,
        },
        {
            id = "wave_mult_1",
            name_kr = "배수 강화 +" .. mult_amount,
            name_en = "Mult Boost",
            desc_kr = "이번 런 기본 배수 +" .. mult_amount,
            desc_en = "+" .. mult_amount .. " base Mult",
            category = "card",
            apply = function(p, _g)
                p.wave_mult_bonus = p.wave_mult_bonus + mult_amount
            end,
        },
        {
            id = "wave_hand_1",
            name_kr = "손패 추가",
            name_en = "Extra Hand",
            desc_kr = "다음 라운드 손패 +1",
            desc_en = "+1 Hand next round",
            category = "card",
            apply = function(p, _g)
                p.next_round_hand_bonus = p.next_round_hand_bonus + 1
            end,
        },

        -- === B: 부적 강화 ===
        {
            id = "wave_talisman_boost",
            name_kr = "부적 증폭",
            name_en = "Talisman Amp",
            desc_kr = "부적 칩/배수 효과 +50%",
            desc_en = "Talisman chip/mult +50%",
            category = "talisman",
            apply = function(p, _g)
                p.wave_talisman_effect_bonus = p.wave_talisman_effect_bonus + 0.5
            end,
        },
        {
            id = "wave_talisman_slot",
            name_kr = "부적 슬롯 +1",
            name_en = "+1 Talisman Slot",
            desc_kr = "이번 런 부적 슬롯 +1",
            desc_en = "+1 Talisman slot this run",
            category = "talisman",
            apply = function(p, _g)
                p.wave_talisman_slot_bonus = p.wave_talisman_slot_bonus + 1
            end,
        },

        -- === C: 생존 강화 ===
        {
            id = "wave_heal_2",
            name_kr = "치유",
            name_en = "Heal",
            desc_kr = "목숨 +2 회복",
            desc_en = "Restore 2 lives",
            category = "survival",
            apply = function(p, _g)
                p.lives = math.min(p.lives + 2, PlayerState.MAX_LIVES)
            end,
        },
        {
            id = "wave_yeop_100",
            name_kr = "엽전 보너스",
            name_en = "Yeop Bonus",
            desc_kr = "엽전 +100",
            desc_en = "+100 Yeop",
            category = "survival",
            apply = function(p, _g)
                p.yeop = p.yeop + 100
            end,
        },
        {
            id = "wave_target_10",
            name_kr = "목표 감소",
            name_en = "Target Reduce",
            desc_kr = "다음 영역 목표 -10%",
            desc_en = "Next realm target -10%",
            category = "survival",
            apply = function(p, _g)
                p.wave_target_reduction = p.wave_target_reduction + 0.1
            end,
        },

        -- === D: 특수 ===
        {
            id = "wave_random_talisman",
            name_kr = "랜덤 부적",
            name_en = "Random Talisman",
            desc_kr = "랜덤 일반 부적 1개 장착",
            desc_en = "Equip 1 random Common talisman",
            category = "special",
            apply = function(p, _g)
                local ok, TalismanDB = pcall(require, "src.talismans.talisman_database")
                if ok and TalismanDB and TalismanDB.get_by_rarity then
                    local commons = TalismanDB.get_by_rarity("common")
                    if commons and #commons > 0 and p:can_equip_talisman() then
                        local t = commons[math.random(#commons)]
                        p:equip_talisman({ data = t })
                    end
                end
            end,
        },
        {
            id = "wave_soul_30",
            name_kr = "영혼 수확",
            name_en = "Soul Harvest",
            desc_kr = "넋 +30",
            desc_en = "+30 Soul Fragments",
            category = "special",
            apply = function(_p, g)
                if g and g.upgrades and g.upgrades.add_soul_fragments then
                    g.upgrades:add_soul_fragments(30)
                end
            end,
        },
        {
            id = "wave_gamble",
            name_kr = "도박",
            name_en = "Gamble",
            desc_kr = "50% 확률로 칩 +50 or 목숨 -1",
            desc_en = "50% +50 Chips or -1 life",
            category = "special",
            apply = function(p, _g)
                if math.random() < 0.5 then
                    p.yeop = p.yeop + 50
                else
                    p.lives = math.max(1, p.lives - 1)
                end
            end,
        },
    }

    -- 고렙 전용 강화 추가 (나선 비례)
    if realm >= 10 then
        local mega_mult = math.max(3, math.floor(3 * (1.4 ^ (spiral - 1))))
        table.insert(pool, {
            id = "wave_mega_mult",
            name_kr = "극한 배수 +" .. mega_mult,
            name_en = "Mega Mult",
            desc_kr = "기본 배수 +" .. mega_mult .. " (목숨 -1)",
            desc_en = "+" .. mega_mult .. " Mult (-1 life)",
            category = "special",
            apply = function(p, _g)
                p.wave_mult_bonus = p.wave_mult_bonus + mega_mult
                p.lives = math.max(1, p.lives - 1)
            end,
        })
    end

    return pool
end

return WaveUpgradeManager

--- 도깨비 각인 시스템: 보스 영혼을 카드에 각인하여 특수 효과 부여
--- 10종 각인 x 2슬롯 = 풍부한 빌드 조합, 2개 각인 시너지 5종
local Signal = require("lib.signal")

-- ============================================================
-- SealDefinition / SealSynergyDefinition
-- ============================================================
local function make_seal(id, name_kr, name_en, desc_kr, boss_id)
    return {
        id      = id,
        name_kr = name_kr,
        name_en = name_en,
        desc_kr = desc_kr,
        boss_id = boss_id,
    }
end

local function make_synergy(seal1_id, seal2_id, name_kr, desc_kr, bonus_value)
    return {
        seal1_id    = seal1_id,
        seal2_id    = seal2_id,
        name_kr     = name_kr,
        desc_kr     = desc_kr,
        bonus_value = bonus_value,
    }
end

-- ============================================================
-- DokkaebiSealDatabase
-- ============================================================
local DokkaebiSealDatabase = {}

local _all_seals = nil
local _synergies = nil

local function initialize()
    _all_seals = {
        make_seal("greed",       "탐식의 각인",  "Greed Seal",
                  "이 카드로 매칭 시 목표 -10",           "glutton"),
        make_seal("deception",   "기만의 각인",  "Deception Seal",
                  "이 카드는 인접 월에도 매칭 가능",       "trickster"),
        make_seal("delusion",    "환혹의 각인",  "Delusion Seal",
                  "매칭 실패 시 칩 +5",                   "fox"),
        make_seal("truth",       "진실의 각인",  "Truth Seal",
                  "보스 기믹 면역 (이 카드 관련)",         "mirror"),
        make_seal("judgment",    "심판의 각인",  "Judgment Seal",
                  "족보 완성 시 배수 +3",                 "yeomra"),
        make_seal("rage",        "분노의 각인",  "Rage Seal",
                  "연속 매칭 시 누적 칩 +10",             "volcano"),
        make_seal("avarice",     "탐욕의 각인",  "Avarice Seal",
                  "매칭 성공 시 엽전 +5",                 "gold"),
        make_seal("patience",    "인내의 각인",  "Patience Seal",
                  "마지막 턴 칩/배수 2배",                "corridor"),
        make_seal("replication", "복제의 각인",  "Replication Seal",
                  "30% 확률로 효과 2회 적용",             "shadow"),
        make_seal("samsara",     "윤회의 각인",  "Samsara Seal",
                  "런 종료 시 강화 등급 유지",            "flame"),
    }

    _synergies = {
        make_synergy("greed", "avarice",
            "탐식+탐욕: 황금 폭식",
            "매칭 시 엽전 +10 추가", 10),
        make_synergy("deception", "delusion",
            "기만+환혹: 완벽한 환상",
            "매칭 실패 시 50% 와일드카드", 0.5),
        make_synergy("judgment", "rage",
            "심판+분노: 격노의 심판",
            "족보 완성 시 칩 +50", 50),
        make_synergy("truth", "patience",
            "진실+인내: 불변의 진리",
            "마지막 3턴 목표 -20%", 0.2),
        make_synergy("replication", "samsara",
            "복제+윤회: 영겁의 순환",
            "모든 각인 효과 +50%", 0.5),
    }
end

function DokkaebiSealDatabase.get_all_seals()
    if not _all_seals then initialize() end
    return _all_seals
end

function DokkaebiSealDatabase.get_all_synergies()
    if not _synergies then initialize() end
    return _synergies
end

function DokkaebiSealDatabase.get_by_id(id)
    local seals = DokkaebiSealDatabase.get_all_seals()
    for _, s in ipairs(seals) do
        if s.id == id then return s end
    end
    return nil
end

function DokkaebiSealDatabase.get_by_boss(boss_id)
    local seals = DokkaebiSealDatabase.get_all_seals()
    for _, s in ipairs(seals) do
        if s.boss_id == boss_id then return s end
    end
    return nil
end

--- 두 각인의 시너지 체크 (양방향)
function DokkaebiSealDatabase.check_synergy(seal1, seal2)
    local synergies = DokkaebiSealDatabase.get_all_synergies()
    for _, s in ipairs(synergies) do
        if (s.seal1_id == seal1 and s.seal2_id == seal2) or
           (s.seal1_id == seal2 and s.seal2_id == seal1) then
            return s
        end
    end
    return nil
end

-- ============================================================
-- SealMatchResult
-- ============================================================
local function default_seal_match_result()
    return {
        bonus_chips      = 0,
        bonus_yeop       = 0,
        target_reduction = 0,
        chip_multiplier  = 1.0,
        mult_multiplier  = 1.0,
    }
end

-- ============================================================
-- SealEffectManager: 각인 효과를 실제 게임에 적용
-- ============================================================
local SealEffectManager = {}
SealEffectManager.__index = SealEffectManager

function SealEffectManager.new()
    return setmetatable({
        _consecutive_match_count = 0,

        -- signals
        on_seal_triggered = Signal.new(),  -- (message_string)
    }, SealEffectManager)
end

function SealEffectManager:reset_round()
    self._consecutive_match_count = 0
end

--- 카드 매칭 시 각인 효과 적용
function SealEffectManager:apply_on_match(card, enh_mgr, match_success, turn_number, total_turns)
    local result = default_seal_match_result()
    local enh = enh_mgr:get_enhancement(card.id)

    if #enh.seals == 0 then return result end

    -- 시너지 체크
    local synergy = nil
    if #enh.seals == 2 then
        synergy = DokkaebiSealDatabase.check_synergy(enh.seals[1], enh.seals[2])
    end

    local has_replication_synergy = synergy and
        (synergy.seal1_id == "replication" or synergy.seal2_id == "replication")

    for _, seal_id in ipairs(enh.seals) do
        -- 복제 시너지 배율은 복제 각인 자체에만 적용
        local seal_effect_mult = (has_replication_synergy and seal_id == "replication") and 1.5 or 1.0

        -- 복제 각인: 30% 2회 적용
        local times = 1
        if seal_id == "replication" and math.random() < 0.3 then
            times = 2
        end

        for _t = 1, times do
            if seal_id == "greed" then
                result.target_reduction = result.target_reduction + math.floor(10 * seal_effect_mult)
                self.on_seal_triggered:emit("탐식: 목표 -10")

            elseif seal_id == "delusion" then
                if not match_success then
                    result.bonus_chips = result.bonus_chips + math.floor(5 * seal_effect_mult)
                    self.on_seal_triggered:emit("환혹: 칩 +5")
                end

            elseif seal_id == "judgment" then
                -- 족보 완성 시 -- 외부에서 호출 (get_yokbo_seal_mult)

            elseif seal_id == "rage" then
                if match_success then
                    self._consecutive_match_count = self._consecutive_match_count + 1
                    local rage_bonus = math.floor(self._consecutive_match_count * 10 * seal_effect_mult)
                    result.bonus_chips = result.bonus_chips + rage_bonus
                    self.on_seal_triggered:emit(
                        string.format("분노: 연속 %d회, 칩 +%d",
                            self._consecutive_match_count,
                            self._consecutive_match_count * 10))
                else
                    self._consecutive_match_count = 0
                end

            elseif seal_id == "avarice" then
                if match_success then
                    result.bonus_yeop = result.bonus_yeop + math.floor(5 * seal_effect_mult)
                    self.on_seal_triggered:emit("탐욕: 엽전 +5")
                end

            elseif seal_id == "patience" then
                if turn_number >= total_turns - 1 then
                    result.chip_multiplier = result.chip_multiplier * 2.0
                    result.mult_multiplier = result.mult_multiplier * 2.0
                    self.on_seal_triggered:emit("인내: 마지막 턴! 칩/배수 2배!")
                end
            end
        end
    end

    -- 시너지 보너스
    if synergy then
        if synergy.seal1_id == "greed" and synergy.seal2_id == "avarice" and match_success then
            result.bonus_yeop = result.bonus_yeop + 10
            self.on_seal_triggered:emit("황금 폭식: 엽전 +10")
        elseif synergy.seal1_id == "judgment" and synergy.seal2_id == "rage" then
            result.bonus_chips = result.bonus_chips + 50
            self.on_seal_triggered:emit("격노의 심판: 칩 +50")
        end
    end

    return result
end

--- 족보 완성 시 각인 효과
function SealEffectManager:get_yokbo_seal_mult(enh_mgr, captured_cards)
    local bonus = 0
    for _, card in ipairs(captured_cards) do
        local enh = enh_mgr:get_enhancement(card.id)
        for _, seal_id in ipairs(enh.seals) do
            if seal_id == "judgment" then
                bonus = bonus + 3
                self.on_seal_triggered:emit("심판의 각인: 배수 +3")
            end
        end
    end
    return bonus
end

return {
    DokkaebiSealDatabase   = DokkaebiSealDatabase,
    SealEffectManager      = SealEffectManager,
    default_seal_match_result = default_seal_match_result,
}

--- 사주팔자 시스템: 매 런마다 고유한 운명 조합 생성
--- 년(오행) x 월(기질) x 일(운) x 시(축복/저주) = 500가지 조합

-- ============================================================
-- Enums
-- ============================================================
local DestinyElement = {
    WOOD  = "wood",
    FIRE  = "fire",
    EARTH = "earth",
    METAL = "metal",
    WATER = "water",
}
local ELEMENT_LIST = { DestinyElement.WOOD, DestinyElement.FIRE, DestinyElement.EARTH,
                       DestinyElement.METAL, DestinyElement.WATER }

local DestinyTemperament = {
    WARM     = "warm",
    HOT      = "hot",
    QUIET    = "quiet",
    VARIABLE = "variable",
}
local TEMPERAMENT_LIST = { DestinyTemperament.WARM, DestinyTemperament.HOT,
                           DestinyTemperament.QUIET, DestinyTemperament.VARIABLE }

local DestinyFortune = {
    GREAT_LUCK  = "great_luck",
    LUCK        = "luck",
    NORMAL      = "normal",
    CURSE       = "curse",
    GREAT_CURSE = "great_curse",
}
local FORTUNE_LIST = { DestinyFortune.GREAT_LUCK, DestinyFortune.LUCK, DestinyFortune.NORMAL,
                       DestinyFortune.CURSE, DestinyFortune.GREAT_CURSE }

local DestinyHour = {
    BLESSING = "blessing",
    LUCKY    = "lucky",
    CURSED   = "cursed",
    BREAKING = "breaking",
    VOID     = "void",
}
local HOUR_LIST = { DestinyHour.BLESSING, DestinyHour.LUCKY, DestinyHour.CURSED,
                    DestinyHour.BREAKING, DestinyHour.VOID }

-- ============================================================
-- DestinyProfile
-- ============================================================
local DestinyProfile = {}
DestinyProfile.__index = DestinyProfile

function DestinyProfile.new(element, temperament, fortune, hour)
    return setmetatable({
        element     = element,
        temperament = temperament,
        fortune     = fortune,
        hour        = hour,
    }, DestinyProfile)
end

function DestinyProfile:get_name_kr()
    local el_names = {
        [DestinyElement.WOOD]  = "목(木)",
        [DestinyElement.FIRE]  = "화(火)",
        [DestinyElement.EARTH] = "토(土)",
        [DestinyElement.METAL] = "금(金)",
        [DestinyElement.WATER] = "수(水)",
    }
    local temp_names = {
        [DestinyTemperament.WARM]     = "온(溫)",
        [DestinyTemperament.HOT]      = "열(熱)",
        [DestinyTemperament.QUIET]    = "정(靜)",
        [DestinyTemperament.VARIABLE] = "변(變)",
    }
    local fort_names = {
        [DestinyFortune.GREAT_LUCK]  = "대길(大吉)",
        [DestinyFortune.LUCK]        = "길(吉)",
        [DestinyFortune.NORMAL]      = "평(平)",
        [DestinyFortune.CURSE]       = "흉(凶)",
        [DestinyFortune.GREAT_CURSE] = "대흉(大凶)",
    }
    local hr_names = {
        [DestinyHour.BLESSING] = "복(福)",
        [DestinyHour.LUCKY]    = "운(運)",
        [DestinyHour.CURSED]   = "액(厄)",
        [DestinyHour.BREAKING] = "파(破)",
        [DestinyHour.VOID]     = "공(空)",
    }
    local el   = el_names[self.element]     or "?"
    local temp = temp_names[self.temperament] or "?"
    local fort = fort_names[self.fortune]   or "?"
    local hr   = hr_names[self.hour]        or "?"
    return string.format("%s %s %s %s", el, temp, fort, hr)
end

function DestinyProfile:get_desc_kr()
    local lines = {}
    -- 오행
    local el_desc = {
        [DestinyElement.WOOD]  = "목: 띠 칩 +20%",
        [DestinyElement.FIRE]  = "화: 광 배수 +1",
        [DestinyElement.EARTH] = "토: 시작 엽전 +50",
        [DestinyElement.METAL] = "금: 열끗 칩 +20%",
        [DestinyElement.WATER] = "수: 피 활성화 -2장 (피 족보 8장부터)",
    }
    table.insert(lines, el_desc[self.element] or "")
    -- 기질
    local temp_desc = {
        [DestinyTemperament.WARM]     = "온: 매칭 실패 시 칩 +5",
        [DestinyTemperament.HOT]      = "열: Go 배수 보너스 +1",
        [DestinyTemperament.QUIET]    = "정: Stop 선택 시 칩 +30",
        [DestinyTemperament.VARIABLE] = "변: 30% 확률로 바닥패 2장 교체",
    }
    table.insert(lines, temp_desc[self.temperament] or "")
    -- 운
    local fort_desc = {
        [DestinyFortune.GREAT_LUCK]  = "대길: 보상 +50%",
        [DestinyFortune.LUCK]        = "길: 보상 +20%",
        [DestinyFortune.NORMAL]      = "평: 변동 없음",
        [DestinyFortune.CURSE]       = "흉: 보상 -20%",
        [DestinyFortune.GREAT_CURSE] = "대흉: 보상 -50%, 넋 3배!",
    }
    table.insert(lines, fort_desc[self.fortune] or "")
    -- 시
    local hr_desc = {
        [DestinyHour.BLESSING] = "복: 이벤트 보상 증가",
        [DestinyHour.LUCKY]    = "운: 상점 가격 -15%",
        [DestinyHour.CURSED]   = "액: 보스 기믹 강화",
        [DestinyHour.BREAKING] = "파: 시작 손패 -2장",
        [DestinyHour.VOID]     = "공: 부적 슬롯 -1",
    }
    table.insert(lines, hr_desc[self.hour] or "")
    return table.concat(lines, "\n")
end

-- ============================================================
-- DestinySystem
-- ============================================================
local DestinySystem = {}
DestinySystem.__index = DestinySystem

function DestinySystem.new(seed)
    if seed then math.randomseed(seed) end
    return setmetatable({
        current_destiny = nil,
    }, DestinySystem)
end

--- 새 런 시작 시 랜덤 사주 생성
function DestinySystem:generate_destiny()
    self.current_destiny = DestinyProfile.new(
        ELEMENT_LIST[math.random(#ELEMENT_LIST)],
        TEMPERAMENT_LIST[math.random(#TEMPERAMENT_LIST)],
        FORTUNE_LIST[math.random(#FORTUNE_LIST)],
        HOUR_LIST[math.random(#HOUR_LIST)]
    )
    return self.current_destiny
end

--- 사주에 따른 칩 보너스 (족보별)
function DestinySystem:get_chip_bonus(yokbo_type)
    if not self.current_destiny then return 0 end
    local el = self.current_destiny.element
    if el == DestinyElement.WOOD and yokbo_type and string.find(yokbo_type, "단") then
        return 20
    end
    if el == DestinyElement.METAL and yokbo_type and string.find(yokbo_type, "열끗") then
        return 20
    end
    return 0
end

--- 사주에 따른 배수 보너스
function DestinySystem:get_mult_bonus()
    if not self.current_destiny then return 0 end
    return self.current_destiny.element == DestinyElement.FIRE and 1 or 0
end

--- 시작 엽전 보너스
function DestinySystem:get_start_yeop_bonus()
    if not self.current_destiny then return 0 end
    return self.current_destiny.element == DestinyElement.EARTH and 50 or 0
end

--- 피 활성화 감소 (수)
function DestinySystem:get_pi_reduction()
    if not self.current_destiny then return 0 end
    return self.current_destiny.element == DestinyElement.WATER and 2 or 0
end

--- 매칭 실패 칩 보너스 (온)
function DestinySystem:get_match_fail_chip_bonus()
    if not self.current_destiny then return 0 end
    return self.current_destiny.temperament == DestinyTemperament.WARM and 5 or 0
end

--- Go 배수 추가 (열)
function DestinySystem:get_go_mult_bonus()
    if not self.current_destiny then return 0 end
    return self.current_destiny.temperament == DestinyTemperament.HOT and 1 or 0
end

--- Stop 칩 보너스 (정)
function DestinySystem:get_stop_chip_bonus()
    if not self.current_destiny then return 0 end
    return self.current_destiny.temperament == DestinyTemperament.QUIET and 30 or 0
end

--- 보상 배율 (운/흉)
function DestinySystem:get_reward_multiplier()
    if not self.current_destiny then return 1 end
    local f = self.current_destiny.fortune
    if f == DestinyFortune.GREAT_LUCK  then return 1.5 end
    if f == DestinyFortune.LUCK        then return 1.2 end
    if f == DestinyFortune.NORMAL      then return 1.0 end
    if f == DestinyFortune.CURSE       then return 0.8 end
    if f == DestinyFortune.GREAT_CURSE then return 0.5 end
    return 1.0
end

--- 대흉: 넋 보너스 배율
function DestinySystem:get_soul_fragment_multiplier()
    if not self.current_destiny then return 1 end
    return self.current_destiny.fortune == DestinyFortune.GREAT_CURSE and 3.0 or 1.0
end

--- 상점 할인 (운 시)
function DestinySystem:get_shop_discount()
    if not self.current_destiny then return 0 end
    return self.current_destiny.hour == DestinyHour.LUCKY and 0.15 or 0
end

--- 시작 손패 감소 (파 시)
function DestinySystem:get_hand_penalty()
    if not self.current_destiny then return 0 end
    return self.current_destiny.hour == DestinyHour.BREAKING and 2 or 0
end

--- 부적 슬롯 감소 (공 시)
function DestinySystem:get_talisman_slot_penalty()
    if not self.current_destiny then return 0 end
    return self.current_destiny.hour == DestinyHour.VOID and 1 or 0
end

--- 보스 기믹 강화 여부 (액 시)
function DestinySystem:is_boss_enhanced()
    if not self.current_destiny then return false end
    return self.current_destiny.hour == DestinyHour.CURSED
end

return {
    DestinyElement     = DestinyElement,
    DestinyTemperament = DestinyTemperament,
    DestinyFortune     = DestinyFortune,
    DestinyHour        = DestinyHour,
    DestinyProfile     = DestinyProfile,
    DestinySystem      = DestinySystem,
}

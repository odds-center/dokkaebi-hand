--- 동료 도깨비: 격파한 보스를 동료로 소환하여 액티브 스킬 사용
local Signal = require("lib.signal")

-- ============================================================
-- CompanionData: 동료 정의
-- ============================================================
local function make_companion_data(id, name_kr, ability_name_kr, ability_desc, cooldown, unlock_boss_id)
    return {
        id               = id,
        name_kr          = name_kr,
        ability_name_kr  = ability_name_kr,
        ability_desc     = ability_desc,
        cooldown         = cooldown,
        unlock_boss_id   = unlock_boss_id,
    }
end

local ALL_COMPANIONS = {
    make_companion_data("glutton",   "먹보 도깨비",      "탐식",   "바닥패 1장 제거",              3,  "glutton"),
    make_companion_data("trickster", "장난꾸러기 도깨비", "속임수", "손패 1장과 바닥패 1장 교환",    4,  "trickster"),
    make_companion_data("fox",       "여우 도깨비",      "환혹",   "다음 매칭 시 와일드카드 1회",   5,  "fox"),
    make_companion_data("mirror",    "거울 도깨비",      "반사",   "보스 기믹 1회 반사",            6,  "mirror"),
    make_companion_data("flame",     "불꽃 도깨비",      "소각",   "바닥패 전체 리셋 (자발적)",     8,  "flame"),
    make_companion_data("shadow",    "그림자 도깨비",    "잠식",   "보스 목표 점수 -15% (1라운드)", 10, "shadow"),
    make_companion_data("boatman",   "뱃사공",           "항해",   "현재 턴 되감기 (Undo)",        12, "secret_boatman"),
}

-- ============================================================
-- CompanionInstance: 동료 런타임 인스턴스
-- ============================================================
local CompanionInstance = {}
CompanionInstance.__index = CompanionInstance

function CompanionInstance.new(data)
    return setmetatable({
        data             = data,
        current_cooldown = 0,
    }, CompanionInstance)
end

function CompanionInstance:is_ready()
    return self.current_cooldown <= 0
end

function CompanionInstance:activate()
    if not self:is_ready() then return false end
    self.current_cooldown = self.data.cooldown
    return true
end

function CompanionInstance:tick_cooldown()
    if self.current_cooldown > 0 then
        self.current_cooldown = self.current_cooldown - 1
    end
end

-- ============================================================
-- CompanionManager
-- ============================================================
local CompanionManager = {}
CompanionManager.__index = CompanionManager
CompanionManager.MAX_SLOTS = 2

function CompanionManager.new()
    return setmetatable({
        active_companions = {},
        _unlocked_ids     = {},

        -- signals
        on_companion_activated = Signal.new(),  -- (companion_instance, ability_desc)
    }, CompanionManager)
end

function CompanionManager:unlock_companion(id)
    self._unlocked_ids[id] = true
end

function CompanionManager:is_unlocked(id)
    return self._unlocked_ids[id] == true
end

function CompanionManager:equip(id)
    if not self._unlocked_ids[id] then return false end
    if #self.active_companions >= CompanionManager.MAX_SLOTS then return false end

    -- 이미 장착 중인지 확인
    for _, c in ipairs(self.active_companions) do
        if c.data.id == id then return false end
    end

    -- 데이터 찾기
    local data = nil
    for _, d in ipairs(ALL_COMPANIONS) do
        if d.id == id then data = d; break end
    end
    if not data then return false end

    table.insert(self.active_companions, CompanionInstance.new(data))
    return true
end

function CompanionManager:unequip(slot_index)
    if slot_index < 1 or slot_index > #self.active_companions then return false end
    table.remove(self.active_companions, slot_index)
    return true
end

function CompanionManager:activate_companion(slot_index)
    if slot_index < 1 or slot_index > #self.active_companions then return false end

    local companion = self.active_companions[slot_index]
    if not companion:activate() then return false end

    self.on_companion_activated:emit(companion, companion.data.ability_desc)
    return true
end

--- 동료 스킬 실행 (RoundManager 연동)
function CompanionManager:execute_ability(slot_index, round, player, boss)
    if slot_index < 1 or slot_index > #self.active_companions then return false end
    local companion = self.active_companions[slot_index]
    if not companion:is_ready() then return false end

    local success = false
    local id = companion.data.id

    if id == "glutton" then
        -- 탐식: 손패 1장 교체 (뽑기패에서 드로우)
        if #player.hand > 0 and round.companion_swap_card then
            success = round:companion_swap_card(player.hand[1])
        end

    elseif id == "trickster" then
        -- 속임수: 손패 1장 교체
        if #player.hand > 0 and round.companion_swap_card then
            success = round:companion_swap_card(player.hand[#player.hand])
        end

    elseif id == "fox" then
        -- 환혹: 다음 매칭 와일드카드
        if round.set_wild_card_next then
            round:set_wild_card_next()
            success = true
        end

    elseif id == "mirror" then
        -- 반사: 보스 기믹 1회 반사
        if boss and boss.reflect_next_mechanic then
            boss:reflect_next_mechanic()
            success = true
        end

    elseif id == "flame" then
        -- 소각: 시너지 배수 보너스
        if round.apply_flame_bonus then
            round:apply_flame_bonus()
            success = true
        end

    elseif id == "shadow" then
        -- 잠식: 목표 점수 -15%
        if round.apply_shadow_reduction then
            round:apply_shadow_reduction()
            success = true
        end

    elseif id == "boatman" then
        -- 항해: 현재 턴 되감기 (간소화: 배수 보너스)
        if round.apply_boatman_undo then
            round:apply_boatman_undo()
            success = true
        end
    end

    if success then
        companion:activate()
    end

    return success
end

function CompanionManager:tick_all_cooldowns()
    for _, c in ipairs(self.active_companions) do
        c:tick_cooldown()
    end
end

function CompanionManager:get_unlocked_ids()
    local ids = {}
    for id, _ in pairs(self._unlocked_ids) do
        table.insert(ids, id)
    end
    return ids
end

function CompanionManager:load_unlocked(ids)
    self._unlocked_ids = {}
    for _, id in ipairs(ids) do
        self._unlocked_ids[id] = true
    end
end

--- 모든 동료 데이터 목록 반환
function CompanionManager.get_all_companions()
    return ALL_COMPANIONS
end

return {
    CompanionInstance = CompanionInstance,
    CompanionManager  = CompanionManager,
    ALL_COMPANIONS    = ALL_COMPANIONS,
}

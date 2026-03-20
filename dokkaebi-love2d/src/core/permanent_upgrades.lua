--- 영구 강화 트리: 넋(영혼 조각)으로 투자하는 메타 진행.
--- 3갈래: 패의 길(card) / 부적의 길(talisman) / 생존의 길(survival)

local PermanentUpgradeManager = {}
PermanentUpgradeManager.__index = PermanentUpgradeManager

-- ============================================================
-- UpgradePath enum
-- ============================================================
PermanentUpgradeManager.Path = {
    CARD     = "card",
    TALISMAN = "talisman",
    SURVIVAL = "survival",
}

-- ============================================================
-- 업그레이드 정의
-- ============================================================
local function define_upgrades()
    return {
        -- === 패의 길 ===
        {
            id = "base_chips", name_kr = "기본 칩 증가",
            path = "card", max_level = 10,
            costs = { 20, 40, 60, 80, 100, 120, 140, 160, 180, 200 },
            description = "모든 족보 칩 +5/레벨",
        },
        {
            id = "base_mult", name_kr = "기본 배수 증가",
            path = "card", max_level = 5,
            costs = { 50, 100, 200, 400, 800 },
            description = "기본 배수 +1/레벨",
        },
        {
            id = "start_hand", name_kr = "시작 손패",
            path = "card", max_level = 3,
            costs = { 100, 300, 600 },
            description = "시작 손패 +1/레벨",
        },
        {
            id = "deck_compress", name_kr = "덱 압축",
            path = "card", max_level = 4,
            costs = { 80, 160, 320, 640 },
            description = "피 카드 2장 제거/레벨",
        },
        {
            id = "yokbo_bonus", name_kr = "족보 보너스",
            path = "card", max_level = 5,
            costs = { 60, 120, 240, 480, 960 },
            description = "첫 족보 완성 시 칩 +20/레벨",
        },
        {
            id = "sweep_bonus", name_kr = "쓸 보너스",
            path = "card", max_level = 3,
            costs = { 100, 200, 400 },
            description = "쓸 시 배수 +1/레벨",
        },

        -- === 부적의 길 ===
        {
            id = "talisman_slots", name_kr = "부적 슬롯 확장",
            path = "talisman", max_level = 3,
            costs = { 200, 500, 1000 },
            description = "최대 부적 +1/레벨",
        },
        {
            id = "talisman_trigger", name_kr = "부적 발동률",
            path = "talisman", max_level = 5,
            costs = { 40, 80, 160, 320, 640 },
            description = "확률 부적 발동률 +5%/레벨",
        },
        {
            id = "talisman_fusion", name_kr = "부적 합성 해금",
            path = "talisman", max_level = 1,
            costs = { 800 },
            description = "같은 등급 부적 2개 -> 상위 1개",
        },
        {
            id = "legend_rate", name_kr = "전설 등장률",
            path = "talisman", max_level = 3,
            costs = { 300, 600, 1200 },
            description = "상점 전설 부적 등장 +5%/레벨",
        },
        {
            id = "start_talisman", name_kr = "시작 부적 슬롯",
            path = "talisman", max_level = 2,
            costs = { 500, 1000 },
            description = "런 시작 시 선택 부적 +1/레벨",
        },
        {
            id = "curse_resist", name_kr = "저주 저항",
            path = "talisman", max_level = 3,
            costs = { 100, 200, 400 },
            description = "저주 부적 효과 -20%/레벨",
        },

        -- === 생존의 길 ===
        {
            id = "max_lives", name_kr = "최대 목숨",
            path = "survival", max_level = 3,
            costs = { 150, 300, 600 },
            description = "시작 목숨 +1/레벨",
        },
        {
            id = "go_insurance", name_kr = "Go 보험",
            path = "survival", max_level = 2,
            costs = { 300, 800 },
            description = "Go 실패 시 30%/60% 면제",
        },
        {
            id = "start_yeop", name_kr = "시작 엽전",
            path = "survival", max_level = 5,
            costs = { 30, 60, 120, 240, 480 },
            description = "시작 엽전 +30/레벨",
        },
        {
            id = "shop_discount", name_kr = "상점 할인",
            path = "survival", max_level = 3,
            costs = { 100, 250, 500 },
            description = "상점 가격 -10%/레벨",
        },
        {
            id = "event_bonus", name_kr = "이벤트 보너스",
            path = "survival", max_level = 3,
            costs = { 80, 160, 320 },
            description = "이벤트 보상 +20%/레벨",
        },
        {
            id = "revive", name_kr = "부활",
            path = "survival", max_level = 1,
            costs = { 1500 },
            description = "런 당 1회 즉사 면제",
        },
        {
            id = "target_reduce", name_kr = "목표 점수 감소",
            path = "survival", max_level = 5,
            costs = { 100, 200, 400, 800, 1600 },
            description = "모든 보스 목표 -3%/레벨",
        },
    }
end

-- ============================================================
-- Constructor
-- ============================================================
function PermanentUpgradeManager.new()
    local self = setmetatable({
        soul_fragments  = 0,
        _upgrade_levels = {},
        all_upgrades    = define_upgrades(),
    }, PermanentUpgradeManager)
    return self
end

-- ============================================================
-- Soul Fragments
-- ============================================================
function PermanentUpgradeManager:add_soul_fragments(amount)
    self.soul_fragments = self.soul_fragments + amount
end

function PermanentUpgradeManager:set_soul_fragments(amount)
    self.soul_fragments = amount
end

-- ============================================================
-- Level management
-- ============================================================
function PermanentUpgradeManager:get_level(upgrade_id)
    return self._upgrade_levels[upgrade_id] or 0
end

function PermanentUpgradeManager:set_level(upgrade_id, level)
    self._upgrade_levels[upgrade_id] = level
end

--- 특정 업그레이드 정의 찾기
function PermanentUpgradeManager:_find_def(upgrade_id)
    for _, def in ipairs(self.all_upgrades) do
        if def.id == upgrade_id then return def end
    end
    return nil
end

--- 업그레이드 비용 조회 (현재 레벨 기준)
function PermanentUpgradeManager:get_cost(upgrade_id)
    local def = self:_find_def(upgrade_id)
    if not def then return -1 end
    local current = self:get_level(upgrade_id)
    if current >= def.max_level then return -1 end
    return def.costs[current + 1]  -- 1-based
end

function PermanentUpgradeManager:can_upgrade(upgrade_id)
    local def = self:_find_def(upgrade_id)
    if not def then return false end
    local current = self:get_level(upgrade_id)
    if current >= def.max_level then return false end
    local cost = def.costs[current + 1]
    return self.soul_fragments >= cost
end

function PermanentUpgradeManager:purchase(upgrade_id)
    if not self:can_upgrade(upgrade_id) then return false end
    local def = self:_find_def(upgrade_id)
    local current = self:get_level(upgrade_id)
    local cost = def.costs[current + 1]

    self.soul_fragments = self.soul_fragments - cost
    self._upgrade_levels[upgrade_id] = current + 1
    return true
end

-- ============================================================
-- 효과 조회 메서드
-- ============================================================
function PermanentUpgradeManager:get_bonus_chips()
    return self:get_level("base_chips") * 5
end

function PermanentUpgradeManager:get_bonus_mult()
    return self:get_level("base_mult")
end

function PermanentUpgradeManager:get_bonus_hand_size()
    return self:get_level("start_hand")
end

function PermanentUpgradeManager:get_deck_reduction()
    return self:get_level("deck_compress") * 2
end

function PermanentUpgradeManager:get_extra_talisman_slots()
    return self:get_level("talisman_slots")
end

function PermanentUpgradeManager:get_talisman_trigger_bonus()
    return self:get_level("talisman_trigger") * 0.05
end

function PermanentUpgradeManager:get_extra_lives()
    return self:get_level("max_lives")
end

function PermanentUpgradeManager:get_go_insurance_chance()
    return self:get_level("go_insurance") * 0.3
end

function PermanentUpgradeManager:get_bonus_start_yeop()
    return self:get_level("start_yeop") * 30
end

function PermanentUpgradeManager:get_shop_discount()
    return self:get_level("shop_discount") * 0.1
end

function PermanentUpgradeManager:get_target_reduction()
    return self:get_level("target_reduce") * 0.03
end

function PermanentUpgradeManager:has_revive()
    return self:get_level("revive") > 0
end

function PermanentUpgradeManager:has_talisman_fusion()
    return self:get_level("talisman_fusion") > 0
end

function PermanentUpgradeManager:get_total_upgrades_purchased()
    local total = 0
    for _, v in pairs(self._upgrade_levels) do
        total = total + v
    end
    return total
end

return PermanentUpgradeManager

--- 카드 강화 시스템: 등급 강화, 변이, 도깨비 각인
local Enums = require("src.cards.card_enums")

-- ============================================================
-- EnhancementTier enum
-- ============================================================
local EnhancementTier = {
    BASE      = 0,  -- ★
    REFINED   = 1,  -- ★★ 연마
    DIVINE    = 2,  -- ★★★ 신통
    LEGENDARY = 3,  -- ★★★★ 전설
    NIRVANA   = 4,  -- ★★★★★ 해탈
}

-- ============================================================
-- CardEnhancement: 개별 카드 강화 상태
-- ============================================================
local CardEnhancement = {}
CardEnhancement.__index = CardEnhancement
CardEnhancement.MAX_SEALS = 2

function CardEnhancement.new(card_id)
    return setmetatable({
        card_id = card_id,
        tier = EnhancementTier.BASE,
        mutated_month = nil,
        mutated_type = nil,
        seals = {},
    }, CardEnhancement)
end

--- 다음 등급으로 강화
function CardEnhancement:upgrade()
    if self.tier >= EnhancementTier.NIRVANA then return false end
    self.tier = self.tier + 1
    return true
end

--- 등급별 칩 보너스
function CardEnhancement:get_chip_bonus(original_type)
    local is_gwang = (original_type == Enums.CardType.Gwang)
    if self.tier == EnhancementTier.REFINED then
        return is_gwang and 10 or 5
    elseif self.tier == EnhancementTier.DIVINE then
        return is_gwang and 20 or 10
    elseif self.tier == EnhancementTier.LEGENDARY then
        return is_gwang and 40 or 20
    elseif self.tier == EnhancementTier.NIRVANA then
        return is_gwang and 80 or 40
    end
    return 0
end

--- 등급별 배수 보너스 (신통 이상)
function CardEnhancement:get_mult_bonus(original_type)
    if self.tier == EnhancementTier.DIVINE then
        return 1
    elseif self.tier == EnhancementTier.LEGENDARY then
        return 2
    elseif self.tier == EnhancementTier.NIRVANA then
        return 4
    end
    return 0
end

--- 신통(★★★) 특수 능력 활성 여부
function CardEnhancement:has_special_ability()
    return self.tier >= EnhancementTier.DIVINE
end

--- 전설(★★★★) 고유 이펙트 활성 여부
function CardEnhancement:has_unique_effect()
    return self.tier >= EnhancementTier.LEGENDARY
end

--- 월 변이 적용
function CardEnhancement:mutate_month(new_month)
    self.mutated_month = new_month
end

--- 타입 변이 적용 (하향 변이 금지: 광→피 불가)
--- CardTypeValue: gwang=4, geurim=3, tti=2, pi=1
--- 높은 값 = 상위 타입, newType의 value가 원본보다 낮으면 하향이므로 금지
function CardEnhancement:mutate_type(original_type, new_type)
    local orig_val = Enums.CardTypeValue[original_type] or 0
    local new_val  = Enums.CardTypeValue[new_type] or 0
    if new_val < orig_val then return false end  -- 하향 금지
    self.mutated_type = new_type
    return true
end

--- 도깨비 각인 추가
function CardEnhancement:add_seal(seal_id)
    if #self.seals >= CardEnhancement.MAX_SEALS then return false end
    for _, s in ipairs(self.seals) do
        if s == seal_id then return false end
    end
    table.insert(self.seals, seal_id)
    return true
end

--- 도깨비 각인 제거
function CardEnhancement:remove_seal(seal_id)
    for i, s in ipairs(self.seals) do
        if s == seal_id then
            table.remove(self.seals, i)
            return true
        end
    end
    return false
end

--- 변이/강화 초기화
function CardEnhancement:reset()
    self.tier = EnhancementTier.BASE
    self.mutated_month = nil
    self.mutated_type = nil
    self.seals = {}
end

-- ============================================================
-- CardEnhancementManager: 전체 덱의 강화 상태 관리 (영구 저장)
-- ============================================================
local CardEnhancementManager = {}
CardEnhancementManager.__index = CardEnhancementManager

function CardEnhancementManager.new()
    return setmetatable({
        _enhancements = {},
    }, CardEnhancementManager)
end

--- 카드별 강화 상태 조회 (없으면 자동 생성)
function CardEnhancementManager:get_enhancement(card_id)
    if not self._enhancements[card_id] then
        self._enhancements[card_id] = CardEnhancement.new(card_id)
    end
    return self._enhancements[card_id]
end

--- 카드 인스턴스에 강화 효과 적용 (변이/칩/배수는 ScoringEngine에서 조회)
function CardEnhancementManager:apply_to_card(card)
    local _enh = self:get_enhancement(card.id)
    -- 변이 적용은 CardInstance 생성 시 처리
    -- 칩/배수 보너스는 ScoringEngine에서 조회
end

--- 윤회 시 등급 1단계 하락
function CardEnhancementManager:on_reincarnation()
    for _, enh in pairs(self._enhancements) do
        if enh.tier > EnhancementTier.BASE then
            local target_tier = math.max(0, enh.tier - 1)
            enh:reset()
            for _i = 1, target_tier do
                enh:upgrade()
            end
        end
    end
end

--- 강화된 카드 수
function CardEnhancementManager:get_total_enhanced_cards()
    local count = 0
    for _, enh in pairs(self._enhancements) do
        if enh.tier > EnhancementTier.BASE then count = count + 1 end
    end
    return count
end

--- 강화 비용 계산: 연마 50, 신통 100, 전설 200, 해탈 500
function CardEnhancementManager.get_upgrade_cost(current_tier)
    if current_tier == EnhancementTier.BASE then return 50 end
    if current_tier == EnhancementTier.REFINED then return 100 end
    if current_tier == EnhancementTier.DIVINE then return 200 end
    if current_tier == EnhancementTier.LEGENDARY then return 500 end
    return -1  -- 해탈은 더 이상 강화 불가
end

--- 전체 카드 강화 상태 조회 (UI용)
function CardEnhancementManager:get_all_enhancements()
    local copy = {}
    for k, v in pairs(self._enhancements) do
        copy[k] = v
    end
    return copy
end

return {
    EnhancementTier = EnhancementTier,
    CardEnhancement = CardEnhancement,
    CardEnhancementManager = CardEnhancementManager,
}

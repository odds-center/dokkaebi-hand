--- 부적 관리: 슬롯, 트리거 발동, 효과 적용
--- Ported from TalismanManager.cs
---
--- 효과 적용 순서: 가산(+) -> 승산(x) -> 특수효과

local Signal = require("lib.signal")
local TD = require("src.talismans.talisman_data")
local Enums = require("src.cards.card_enums")
local EffectType = TD.TalismanEffectType
local Trigger = TD.TalismanTrigger

local TalismanManager = {}
TalismanManager.__index = TalismanManager

function TalismanManager.new()
    return setmetatable({
        -- 시그널: (talisman_instance, message)
        on_talisman_triggered = Signal.new(),
    }, TalismanManager)
end

--- 점수 정산 시 부적 효과 적용
--- @param player PlayerState
--- @param base_score table { chips, mult, final_score }
--- @param current_trigger string (TalismanTrigger value)
--- @return table { chips, mult, final_score }
function TalismanManager:apply_talisman_effects(player, base_score, current_trigger)
    local result = {
        chips = base_score.chips or 0,
        mult = base_score.mult or 1,
        final_score = base_score.final_score or 0,
    }

    -- 부적 효과 배율
    local effect_mult = 1 + (player.wave_talisman_effect_bonus or 0)

    -- 반복 중 컬렉션 수정 방지를 위해 복사본 사용
    local active_talismans = {}
    for _, t in ipairs(player.talismans) do
        table.insert(active_talismans, t)
    end

    -- Phase 1: 가산 효과 (+)
    for _, talisman in ipairs(active_talismans) do
        if talisman.is_active and talisman.data.trigger == current_trigger then
            if self:_check_trigger_chance(talisman) then
                if talisman.data.effect_type == EffectType.AddChips then
                    local added_chips = math.floor(talisman.data.effect_value * effect_mult)
                    result.chips = result.chips + added_chips
                    self.on_talisman_triggered:emit(talisman,
                        string.format("+%d 칩", added_chips))

                    -- 추가 배수 보너스 (칩+배수 동시 효과)
                    if talisman.data.secondary_mult_bonus > 0 then
                        local sec_mult = math.floor(talisman.data.secondary_mult_bonus * effect_mult)
                        result.mult = result.mult + sec_mult
                        self.on_talisman_triggered:emit(talisman,
                            string.format("+%d 배수", sec_mult))
                    end

                elseif talisman.data.effect_type == EffectType.AddMult then
                    local added_mult = math.floor(talisman.data.effect_value * effect_mult)
                    result.mult = result.mult + added_mult
                    self.on_talisman_triggered:emit(talisman,
                        string.format("+%d 배수", added_mult))
                end
            end
        end
    end

    -- Phase 2: 승산 효과 (x)
    for _, talisman in ipairs(active_talismans) do
        if talisman.is_active and talisman.data.trigger == current_trigger then
            if self:_check_trigger_chance(talisman) then
                if talisman.data.effect_type == EffectType.MultiplyMult then
                    local multiplied = result.mult * talisman.data.effect_value
                    self.on_talisman_triggered:emit(talisman,
                        string.format("배수 x%g", talisman.data.effect_value))
                    result.mult = math.floor(multiplied + 0.5)
                end
            end
        end
    end

    result.final_score = result.chips * result.mult
    return result
end

--- 목표 점수 감소 부적 적용
function TalismanManager:apply_target_reduction(player, base_target)
    local reduction = 0

    for _, talisman in ipairs(player.talismans) do
        if talisman.is_active and talisman.data.effect_type == EffectType.ReduceTarget then
            reduction = reduction + talisman.data.effect_value
        end
    end

    if reduction > 0 then
        local reduced = math.floor(base_target * (1 - reduction / 100))
        return math.max(reduced, 1)
    end

    return base_target
end

--- 비점수 트리거 알림
--- @param player PlayerState
--- @param trigger string (TalismanTrigger value)
--- @param context_card CardInstance|nil
function TalismanManager:notify_trigger(player, trigger, context_card)
    for _, talisman in ipairs(player.talismans) do
        if talisman.is_active and talisman.data.trigger == trigger then
            if self:_check_trigger_chance(talisman) then

                if talisman.data.effect_type == EffectType.DestroyCard then
                    -- 흉살: 매 턴 피 1장 소멸
                    if player.consumed_cards then
                        -- consumed_cards에서 피 카드 찾기
                        for i = #player.consumed_cards, 1, -1 do
                            local card = player.consumed_cards[i]
                            if card.card_type == Enums.CardType.Pi then
                                table.remove(player.consumed_cards, i)
                                self.on_talisman_triggered:emit(talisman,
                                    string.format("흉살: %s 소멸", card.name_kr))
                                break
                            end
                        end
                    end

                elseif talisman.data.effect_type == EffectType.WildCard then
                    -- 달빛 여우: 매칭 실패 시 와일드카드
                    if trigger == Trigger.OnMatchFail then
                        player.wild_card_next_match = true
                        self.on_talisman_triggered:emit(talisman,
                            "달빛 여우: 와일드카드 활성!")
                    end

                elseif talisman.data.effect_type == EffectType.TransmuteCard then
                    -- 광기의 광: 광 패 사용 시 랜덤 변이
                    if trigger == Trigger.OnCardPlayed and
                       context_card and context_card.card_type == Enums.CardType.Gwang then
                        self.on_talisman_triggered:emit(talisman,
                            "광기의 광: 카드 변이!")
                    end

                elseif talisman.data.effect_type == EffectType.AddChips then
                    -- 홍살문 등: 족보 완성 시 칩 보너스
                    if trigger == Trigger.OnYokboComplete then
                        self.on_talisman_triggered:emit(talisman,
                            string.format("+%d 칩", math.floor(talisman.data.effect_value)))
                    end

                else
                    self.on_talisman_triggered:emit(talisman,
                        talisman.data.description_kr)
                end
            end
        end
    end
end

-- ============================================================
-- 내부
-- ============================================================

function TalismanManager:_check_trigger_chance(talisman)
    if talisman.data.trigger_chance >= 1 then return true end
    return math.random() < talisman.data.trigger_chance
end

return TalismanManager

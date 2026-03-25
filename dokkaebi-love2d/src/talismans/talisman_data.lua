--- 부적 열거형 + 데이터 구조
--- Ported from Talisman.cs + TalismanInstance.cs

local TalismanRarity = {
    Common = "common",
    Rare = "rare",
    Legendary = "legendary",
    Cursed = "cursed",
}

local TalismanTrigger = {
    OnCardPlayed = "on_card_played",
    OnYokboComplete = "on_yokbo_complete",
    OnTurnStart = "on_turn_start",
    OnTurnEnd = "on_turn_end",
    OnRoundStart = "on_round_start",
    OnRoundEnd = "on_round_end",
    OnGoDecision = "on_go_decision",
    OnStopDecision = "on_stop_decision",
    OnMatchSuccess = "on_match_success",
    OnMatchFail = "on_match_fail",
    Passive = "passive",
}

local TalismanEffectType = {
    AddChips = "add_chips",
    AddMult = "add_mult",
    MultiplyMult = "multiply_mult",
    ReduceTarget = "reduce_target",
    WildCard = "wild_card",
    TransmuteCard = "transmute_card",
    DestroyCard = "destroy_card",
    Special = "special",
}

--- TalismanData: ScriptableObject 없이 동작하는 부적 데이터
local function TalismanData(t)
    return {
        name = t.name or "",
        name_kr = t.name_kr or "",
        rarity = t.rarity or TalismanRarity.Common,
        description = t.description or "",
        description_kr = t.description_kr or "",
        trigger = t.trigger or TalismanTrigger.Passive,
        trigger_condition = t.trigger_condition or "",
        effect_type = t.effect_type or TalismanEffectType.AddChips,
        effect_value = t.effect_value or 0,
        secondary_mult_bonus = t.secondary_mult_bonus or 0,
        trigger_chance = t.trigger_chance or 1,
        is_curse = t.is_curse or false,
        sprite_id = t.sprite_id or nil,
    }
end

--- TalismanInstance: 런타임 부적 인스턴스
local TalismanInstance = {}
TalismanInstance.__index = TalismanInstance

function TalismanInstance.new(talisman_data)
    return setmetatable({
        data = talisman_data,
        is_active = true,
    }, TalismanInstance)
end

return {
    TalismanRarity = TalismanRarity,
    TalismanTrigger = TalismanTrigger,
    TalismanEffectType = TalismanEffectType,
    TalismanData = TalismanData,
    TalismanInstance = TalismanInstance,
}

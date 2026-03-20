--- 플레이어 상태
local Enums = require("src.cards.card_enums")

local PlayerState = {}
PlayerState.__index = PlayerState

PlayerState.MAX_LIVES = 10
PlayerState.MAX_TALISMAN_SLOTS = 5

function PlayerState.new()
    return setmetatable({
        hand = {},
        consumed_cards = {},

        yeop = 50,
        lives = 5,
        go_count = 0,

        -- 웨이브 강화
        wave_chip_bonus = 0,
        wave_mult_bonus = 0,
        wave_talisman_slot_bonus = 0,
        wave_talisman_effect_bonus = 0,
        wave_target_reduction = 0,
        next_round_hand_bonus = 0,
        wild_card_next_match = false,

        -- 영구 강화
        permanent_talisman_slot_bonus = 0,

        -- 부적
        talismans = {},

        -- 회복 보류
        pending_heal_combo = nil,
        pending_heal_amount = 0,
    }, PlayerState)
end

function PlayerState:reset_for_new_round()
    self.hand = {}
    self.consumed_cards = {}
    self.go_count = 0
end

function PlayerState:can_equip_talisman()
    local max_slots = math.min(
        PlayerState.MAX_TALISMAN_SLOTS + self.permanent_talisman_slot_bonus + self.wave_talisman_slot_bonus,
        10)
    return #self.talismans < max_slots
end

function PlayerState:equip_talisman(talisman)
    if not self:can_equip_talisman() and not talisman.data.is_curse then
        return false
    end
    table.insert(self.talismans, talisman)
    return true
end

return PlayerState

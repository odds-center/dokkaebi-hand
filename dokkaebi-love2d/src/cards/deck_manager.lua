--- 덱 관리: 셔플, 분배, 드로우
local CardDatabase = require("src.cards.card_database")
local CardInstance = require("src.cards.card_instance")

local DeckManager = {}
DeckManager.__index = DeckManager

function DeckManager.new(seed)
    if seed then math.randomseed(seed) end
    return setmetatable({
        draw_pile = {},
        field_cards = {},
    }, DeckManager)
end

function DeckManager:initialize_deck()
    self.draw_pile = {}
    self.field_cards = {}

    local defs = CardDatabase.get_all_definitions()
    for i, def in ipairs(defs) do
        table.insert(self.draw_pile, CardInstance.new(i, def))
    end

    -- Fisher-Yates 셔플
    for i = #self.draw_pile, 2, -1 do
        local j = math.random(1, i)
        self.draw_pile[i], self.draw_pile[j] = self.draw_pile[j], self.draw_pile[i]
    end
end

function DeckManager:deal_cards(player, hand_size, field_size)
    hand_size = hand_size or 10
    field_size = field_size or 0

    player.hand = {}
    for i = 1, hand_size do
        local card = self:draw_from_pile()
        if card then table.insert(player.hand, card) end
    end

    self.field_cards = {}
    for i = 1, field_size do
        local card = self:draw_from_pile()
        if card then table.insert(self.field_cards, card) end
    end
end

function DeckManager:draw_from_pile()
    if #self.draw_pile == 0 then return nil end
    return table.remove(self.draw_pile)
end

function DeckManager:return_to_pile(card)
    if card then
        local idx = math.random(1, #self.draw_pile + 1)
        table.insert(self.draw_pile, idx, card)
    end
end

function DeckManager:add_to_field(card)
    table.insert(self.field_cards, card)
end

function DeckManager:remove_from_field(card)
    for i, c in ipairs(self.field_cards) do
        if c == card then
            table.remove(self.field_cards, i)
            return true
        end
    end
    return false
end

function DeckManager:is_draw_pile_empty()
    return #self.draw_pile == 0
end

return DeckManager

--- 카드 런타임 인스턴스
local Enums = require("src.cards.card_enums")

local CardInstance = {}
CardInstance.__index = CardInstance

function CardInstance.new(id, def)
    return setmetatable({
        id = id,
        name = def.name,
        name_kr = def.name_kr,
        month = def.month,
        card_type = def.card_type,
        ribbon = def.ribbon or Enums.RibbonType.None,
        base_points = def.base_points or 1,
        is_rain_gwang = def.is_rain_gwang or false,
        is_double_pi = def.is_double_pi or false,
        pi_index = def.pi_index or 1,
    }, CardInstance)
end

function CardInstance:get_pi_value()
    if self.card_type == Enums.CardType.Pi then
        return self.is_double_pi and 2 or 1
    end
    return 0
end

function CardInstance:__tostring()
    return string.format("%d월 %s (%s)", self.month, self.name_kr, self.card_type)
end

return CardInstance

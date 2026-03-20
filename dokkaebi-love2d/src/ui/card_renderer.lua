--- 카드 렌더링 (프로시저럴 픽셀아트)
local E = require("src.cards.card_enums")
local CT = E.CardType
local RT = E.RibbonType

local CardRenderer = {}

CardRenderer.CARD_W = 90
CardRenderer.CARD_H = 130

local HEADER_COLORS = {
    [CT.Gwang] = {1, 0.84, 0},
    [CT.Yeolkkeut] = {0.3, 0.7, 0.9},
    [CT.Pi] = {0.55, 0.55, 0.55},
}

local RIBBON_COLORS = {
    [RT.HongDan] = {0.85, 0.15, 0.15},
    [RT.CheongDan] = {0.15, 0.4, 0.85},
    [RT.ChoDan] = {0.2, 0.7, 0.2},
}

function CardRenderer.get_header_color(card)
    if card.card_type == CT.Tti then
        return RIBBON_COLORS[card.ribbon] or {0.85, 0.15, 0.15}
    end
    return HEADER_COLORS[card.card_type] or {0.5, 0.5, 0.5}
end

function CardRenderer.draw(card, x, y, is_selected, is_hovered, font_small)
    local w, h = CardRenderer.CARD_W, CardRenderer.CARD_H

    -- 선택 시 위로 올림
    local offset_y = 0
    if is_selected then offset_y = -20
    elseif is_hovered then offset_y = -8
    end
    y = y + offset_y

    -- 배경
    if is_selected then
        love.graphics.setColor(0.3, 0.25, 0.1)
    elseif is_hovered then
        love.graphics.setColor(0.18, 0.16, 0.25)
    else
        love.graphics.setColor(0.12, 0.10, 0.18)
    end
    love.graphics.rectangle("fill", x, y, w, h, 4)

    -- 테두리
    if is_selected then
        love.graphics.setColor(1, 0.84, 0)
        love.graphics.setLineWidth(2)
    else
        love.graphics.setColor(0.3, 0.3, 0.4)
        love.graphics.setLineWidth(1)
    end
    love.graphics.rectangle("line", x, y, w, h, 4)
    love.graphics.setLineWidth(1)

    -- 헤더 바
    local hc = CardRenderer.get_header_color(card)
    love.graphics.setColor(hc)
    love.graphics.rectangle("fill", x, y, w, 28, 4)
    -- 하단 모서리 채우기
    love.graphics.rectangle("fill", x, y + 20, w, 8)

    -- 월 텍스트
    if font_small then love.graphics.setFont(font_small) end
    love.graphics.setColor(0, 0, 0)
    love.graphics.printf(card.month .. "월", x, y + 5, w, "center")

    -- 타입 아이콘 (간단 문자)
    love.graphics.setColor(1, 1, 1)
    local icon = ({
        [CT.Gwang] = "★",
        [CT.Tti] = "━",
        [CT.Yeolkkeut] = "◆",
        [CT.Pi] = "·",
    })[card.card_type] or "?"

    love.graphics.printf(icon, x, y + 45, w, "center")

    -- 카드 이름
    love.graphics.setColor(0.8, 0.8, 0.8)
    love.graphics.printf(card.name_kr, x + 4, y + 75, w - 8, "center")

    -- 포인트
    love.graphics.setColor(0.5, 0.5, 0.6)
    love.graphics.printf(card.base_points .. "점", x, y + h - 20, w, "center")

    return x, y, w, h  -- 클릭 영역 반환
end

return CardRenderer

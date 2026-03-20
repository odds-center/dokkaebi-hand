--- 카드 렌더링 — 도형으로 화투 느낌
local E = require("src.cards.card_enums")
local CT = E.CardType
local RT = E.RibbonType

local CardRenderer = {}
CardRenderer.CARD_W = 88
CardRenderer.CARD_H = 125

-- 월별 도트 아이콘 (픽셀아트 도형으로 대체)
local MONTH_ICON = nil  -- 한자 제거, 도형으로 직접 그림

-- 저승 화투 — 카드 색상
local HEADER_COLORS = {
    [CT.Gwang]    = {0.92, 0.68, 0.12},   -- 도깨비불 금색
    [CT.Geurim]= {0.45, 0.58, 0.68},      -- 삼도천 물빛
    [CT.Pi]       = {0.38, 0.32, 0.38},    -- 먹물 회
}
local RIBBON_COLORS = {
    [RT.HongDan]  = {0.72, 0.10, 0.08},   -- 핏빛 홍단
    [RT.CheongDan]= {0.15, 0.28, 0.58},   -- 심연 청단
    [RT.ChoDan]   = {0.35, 0.50, 0.20},   -- 마른 풀빛 초단
}

local TYPE_ICONS = {
    [CT.Gwang]    = "*",
    [CT.Tti]      = "=",
    [CT.Geurim]= "<>",
    [CT.Pi]       = ".",
}

-- 월별 픽셀아트 도형 (한자 대신)
function CardRenderer._draw_month_pixel(month, cx, cy, px)
    -- 각 월의 상징을 간단한 도트로 표현
    if month == 1 then
        -- 소나무: 세로 줄기 + 가지
        love.graphics.rectangle("fill", cx - px/2, cy - 2*px, px, 5*px)
        love.graphics.rectangle("fill", cx - 2*px, cy - px, 4*px, px)
        love.graphics.rectangle("fill", cx - 3*px, cy - 2*px, 2*px, px)
        love.graphics.rectangle("fill", cx + px, cy - 2*px, 2*px, px)
    elseif month == 2 then
        -- 매화: 중앙 점 + 4방향 꽃잎
        love.graphics.rectangle("fill", cx - px/2, cy - px/2, px, px)
        love.graphics.rectangle("fill", cx - px/2, cy - 2*px, px, px)
        love.graphics.rectangle("fill", cx - px/2, cy + px, px, px)
        love.graphics.rectangle("fill", cx - 2*px, cy - px/2, px, px)
        love.graphics.rectangle("fill", cx + px, cy - px/2, px, px)
    elseif month == 3 then
        -- 벚꽃: 십자 + 대각 점
        love.graphics.rectangle("fill", cx - px/2, cy - px/2, px, px)
        love.graphics.rectangle("fill", cx - px/2, cy - 2*px, px, px)
        love.graphics.rectangle("fill", cx - px/2, cy + px, px, px)
        love.graphics.rectangle("fill", cx - 2*px, cy - px/2, px, px)
        love.graphics.rectangle("fill", cx + px, cy - px/2, px, px)
        love.graphics.rectangle("fill", cx - 2*px, cy - 2*px, px, px)
        love.graphics.rectangle("fill", cx + px, cy + px, px, px)
    elseif month == 4 then
        -- 등나무: 아래로 늘어진 줄기들
        for i = -2, 2 do
            local h = (math.abs(i) < 2) and 4 or 2
            love.graphics.rectangle("fill", cx + i*px, cy - px, px, h*px)
        end
    elseif month == 5 then
        -- 난초: 가느다란 잎
        love.graphics.rectangle("fill", cx - px/2, cy - 2*px, px, 4*px)
        love.graphics.rectangle("fill", cx - 2*px, cy - px, px, 2*px)
        love.graphics.rectangle("fill", cx + px, cy - px, px, 2*px)
    elseif month == 6 then
        -- 모란: 큰 꽃 블록
        love.graphics.rectangle("fill", cx - 2*px, cy - px, 4*px, 2*px)
        love.graphics.rectangle("fill", cx - px, cy - 2*px, 2*px, 4*px)
    elseif month == 7 then
        -- 싸리: 작은 잎 여러개
        love.graphics.rectangle("fill", cx - px/2, cy - 2*px, px, 4*px)
        love.graphics.rectangle("fill", cx - 2*px, cy - px, px, px)
        love.graphics.rectangle("fill", cx + px, cy, px, px)
        love.graphics.rectangle("fill", cx - 2*px, cy + px, px, px)
    elseif month == 8 then
        -- 달: 둥근 사각형
        love.graphics.rectangle("fill", cx - 2*px, cy - px, 4*px, 2*px)
        love.graphics.rectangle("fill", cx - px, cy - 2*px, 2*px, 4*px)
    elseif month == 9 then
        -- 국화: 방사형 점
        love.graphics.rectangle("fill", cx - px/2, cy - px/2, px, px)
        for angle = 0, 3 do
            local dx = (angle == 0 and 1 or angle == 2 and -1 or 0)
            local dy = (angle == 1 and 1 or angle == 3 and -1 or 0)
            love.graphics.rectangle("fill", cx + dx*2*px - px/2, cy + dy*2*px - px/2, px, px)
        end
        love.graphics.rectangle("fill", cx + px, cy - 2*px, px, px)
        love.graphics.rectangle("fill", cx - 2*px, cy + px, px, px)
    elseif month == 10 then
        -- 단풍: 넓게 퍼진 잎
        love.graphics.rectangle("fill", cx - px/2, cy - 2*px, px, 4*px)
        love.graphics.rectangle("fill", cx - 2*px, cy - 2*px, px, px)
        love.graphics.rectangle("fill", cx + px, cy - 2*px, px, px)
        love.graphics.rectangle("fill", cx - 3*px, cy - px, px, px)
        love.graphics.rectangle("fill", cx + 2*px, cy - px, px, px)
    elseif month == 11 then
        -- 오동: 큰 잎 하나
        love.graphics.rectangle("fill", cx - 2*px, cy - px, 4*px, 3*px)
        love.graphics.rectangle("fill", cx - px/2, cy - 2*px, px, px)
    elseif month == 12 then
        -- 비: 세로 줄
        love.graphics.rectangle("fill", cx - 2*px, cy - 2*px, px, 4*px)
        love.graphics.rectangle("fill", cx - px/2, cy - px, px, 3*px)
        love.graphics.rectangle("fill", cx + px, cy - 2*px, px, 4*px)
    end
end

function CardRenderer.get_header_color(card)
    if card.card_type == CT.Tti then
        return RIBBON_COLORS[card.ribbon] or {0.80, 0.12, 0.12}
    end
    return HEADER_COLORS[card.card_type] or {0.4, 0.4, 0.45}
end

function CardRenderer.draw(card, x, y, is_selected, is_hovered, font_small)
    local w, h = CardRenderer.CARD_W, CardRenderer.CARD_H

    -- 선택/호버 시 위로
    if is_selected then y = y - 10
    elseif is_hovered then y = y - 4 end

    -- 그림자
    love.graphics.setColor(0.03, 0.02, 0.05, is_selected and 0.5 or 0.3)
    love.graphics.rectangle("fill", x+2, y+2, w, h)

    -- 카드 배경
    if is_selected then love.graphics.setColor(0.20, 0.14, 0.06)       -- 선택: 따뜻한 금빛 어둠
    elseif is_hovered then love.graphics.setColor(0.10, 0.08, 0.15)    -- 호버: 살짝 밝은 연기
    else love.graphics.setColor(0.07, 0.05, 0.11) end                  -- 기본: 심연
    love.graphics.rectangle("fill", x, y, w, h)

    -- 테두리
    if is_selected then
        love.graphics.setColor(0.92, 0.68, 0.12, 0.9)  -- 금색 테두리
        love.graphics.setLineWidth(2)
    else
        love.graphics.setColor(0.30, 0.15, 0.22)        -- 핏빛 테두리
        love.graphics.setLineWidth(1)
    end
    love.graphics.rectangle("line", x, y, w, h)
    love.graphics.setLineWidth(1)

    -- 헤더 (컬러바, 직각)
    local hc = CardRenderer.get_header_color(card)
    love.graphics.setColor(hc[1], hc[2], hc[3], 1)
    love.graphics.rectangle("fill", x+1, y+1, w-2, 26)

    -- 헤더 광택
    love.graphics.setColor(1, 1, 1, 0.12)
    love.graphics.rectangle("fill", x+1, y+1, w-2, 12)

    -- 헤더 텍스트: 타입 + 월 숫자
    if font_small then love.graphics.setFont(font_small) end
    love.graphics.setColor(0, 0, 0, 0.8)
    local type_labels = {
        [CT.Gwang] = "광",
        [CT.Tti] = "띠",
    }
    local label = type_labels[card.card_type] or ""
    if label ~= "" then label = label .. " " end
    love.graphics.printf(label .. card.month .. "월", x, y + 5, w, "center")

    -- 중앙: 월별 도트 아이콘 (픽셀아트 도형)
    local px = 3  -- 픽셀 단위
    local cx, cy = x + w/2, y + 52
    love.graphics.setColor(hc[1], hc[2], hc[3], 0.4)
    CardRenderer._draw_month_pixel(card.month, cx, cy, px)

    -- 타입 아이콘 (픽셀아트)
    love.graphics.setColor(1, 1, 1, 0.9)

    -- 광 카드: 별 (도트 십자형)
    if card.card_type == CT.Gwang then
        love.graphics.setColor(1, 0.82, 0, 0.3)
        -- 글로우 (사각 블록)
        love.graphics.rectangle("fill", cx - 3*px, cy + 6*px - 3*px, 6*px, 6*px)
        love.graphics.setColor(1, 0.82, 0)
        -- 십자 별
        love.graphics.rectangle("fill", cx - px/2, cy + 6*px - 3*px, px, 6*px)
        love.graphics.rectangle("fill", cx - 3*px, cy + 6*px - px/2, 6*px, px)
        -- 대각
        love.graphics.rectangle("fill", cx - 2*px, cy + 6*px - 2*px, px, px)
        love.graphics.rectangle("fill", cx + px, cy + 6*px - 2*px, px, px)
        love.graphics.rectangle("fill", cx - 2*px, cy + 6*px + px, px, px)
        love.graphics.rectangle("fill", cx + px, cy + 6*px + px, px, px)
    elseif card.card_type == CT.Tti then
        -- 띠: 픽셀 리본
        local rc = CardRenderer.get_header_color(card)
        love.graphics.setColor(rc[1], rc[2], rc[3], 0.7)
        love.graphics.rectangle("fill", cx - 6*px, cy + 5*px, 12*px, 2*px)
        love.graphics.setColor(1, 1, 1, 0.5)
        love.graphics.rectangle("fill", cx - 6*px, cy + 5*px, 12*px, px)
    elseif card.card_type == CT.Geurim then
        -- 그림: 픽셀 다이아몬드
        love.graphics.setColor(0.25, 0.65, 0.85, 0.5)
        love.graphics.rectangle("fill", cx - px/2, cy + 3*px, px, px)
        love.graphics.rectangle("fill", cx - px*3/2, cy + 4*px, 3*px, px)
        love.graphics.rectangle("fill", cx - px*5/2, cy + 5*px, 5*px, px)
        love.graphics.rectangle("fill", cx - px*3/2, cy + 6*px, 3*px, px)
        love.graphics.rectangle("fill", cx - px/2, cy + 7*px, px, px)
    else
        -- 피: 도트 사각형
        love.graphics.setColor(0.5, 0.5, 0.55)
        love.graphics.rectangle("fill", cx - px, cy + 5*px, 2*px, 2*px)
        if card.is_double_pi then
            love.graphics.rectangle("fill", cx + 3*px, cy + 5*px, 2*px, 2*px)
        end
    end

    -- 카드 이름 (하단)
    love.graphics.setColor(0.75, 0.75, 0.80)
    love.graphics.printf(card.name_kr, x + 3, y + 82, w - 6, "center")

    -- 선택 시 상단 체크마크
    if is_selected then
        love.graphics.setColor(1, 0.82, 0)
        love.graphics.printf("✓", x, y + h - 18, w - 5, "right")
    end

    return x, y, w, h
end

-- 미니 카드 (족보 등록 영역용, 축소판)
CardRenderer.MINI_W = 32
CardRenderer.MINI_H = 44

function CardRenderer.draw_mini(card, x, y)
    local w, h = CardRenderer.MINI_W, CardRenderer.MINI_H

    -- 카드 배경
    love.graphics.setColor(0.10, 0.08, 0.16)
    love.graphics.rectangle("fill", x, y, w, h)

    -- 테두리
    love.graphics.setColor(0.28, 0.25, 0.38)
    love.graphics.rectangle("line", x, y, w, h)

    -- 헤더 (컬러바)
    local hc = CardRenderer.get_header_color(card)
    love.graphics.setColor(hc[1], hc[2], hc[3], 1)
    love.graphics.rectangle("fill", x+1, y+1, w-2, 10)

    -- 월 숫자 (헤더 위)
    love.graphics.setColor(0, 0, 0, 0.8)
    love.graphics.printf(tostring(card.month), x, y + 1, w, "center")

    -- 타입 아이콘 (중앙)
    local cx, cy = x + w/2, y + 22
    local px = 2
    if card.card_type == CT.Gwang then
        love.graphics.setColor(1, 0.82, 0)
        love.graphics.rectangle("fill", cx - px/2, cy - 2*px, px, 4*px)
        love.graphics.rectangle("fill", cx - 2*px, cy - px/2, 4*px, px)
    elseif card.card_type == CT.Tti then
        local rc = CardRenderer.get_header_color(card)
        love.graphics.setColor(rc[1], rc[2], rc[3], 0.8)
        love.graphics.rectangle("fill", cx - 4*px, cy, 8*px, 2*px)
    elseif card.card_type == CT.Geurim then
        love.graphics.setColor(0.25, 0.65, 0.85, 0.7)
        love.graphics.rectangle("fill", cx - px/2, cy - px, px, px)
        love.graphics.rectangle("fill", cx - px*3/2, cy, 3*px, px)
        love.graphics.rectangle("fill", cx - px/2, cy + px, px, px)
    else
        love.graphics.setColor(0.5, 0.5, 0.55)
        love.graphics.rectangle("fill", cx - px, cy, 2*px, 2*px)
    end

    -- 타입 라벨 (하단)
    love.graphics.setColor(0.6, 0.6, 0.65)
    local type_short = {[CT.Gwang]="광", [CT.Tti]="띠", [CT.Geurim]="그림", [CT.Pi]="피"}
    love.graphics.printf(type_short[card.card_type] or "", x, y + h - 14, w, "center")
end

return CardRenderer

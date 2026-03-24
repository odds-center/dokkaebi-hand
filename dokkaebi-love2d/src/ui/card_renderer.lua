--- 카드 렌더링 — 스프라이트 일러스트 + 레이아웃 오버레이
local E = require("src.cards.card_enums")
local CT = E.CardType
local RT = E.RibbonType
local SpriteLoader = require("src.ui.sprite_loader")

local CardRenderer = {}
CardRenderer.CARD_W = 100
CardRenderer.CARD_H = 140

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

-- 월별 픽셀아트 도형 (한자 대신)
function CardRenderer._draw_month_pixel(month, cx, cy, px)
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
            local ht = (math.abs(i) < 2) and 4 or 2
            love.graphics.rectangle("fill", cx + i*px, cy - px, px, ht*px)
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

--- 카드 → 스프라이트 파일명 매핑
function CardRenderer._get_card_id(card)
    local month_str = string.format("m%02d", card.month)
    local type_map = {
        [CT.Gwang]  = "gwang",
        [CT.Tti]    = nil,  -- 띠는 ribbon 타입으로 구분
        [CT.Geurim] = "yeolkkeut",
        [CT.Pi]     = "pi",
    }

    local type_name = type_map[card.card_type]

    if card.card_type == CT.Tti then
        local ribbon_map = {
            [RT.HongDan]   = "hongdan",
            [RT.CheongDan] = "chungdan",
            [RT.ChoDan]    = "chodan",
        }
        type_name = ribbon_map[card.ribbon] or "hongdan"
    end

    if not type_name then return nil end

    if card.card_type == CT.Pi then
        local pi_num = card.pi_index or 1
        return month_str .. "_pi" .. pi_num
    end

    return month_str .. "_" .. type_name
end

function CardRenderer.get_header_color(card)
    if card.card_type == CT.Tti then
        return RIBBON_COLORS[card.ribbon] or {0.80, 0.12, 0.12}
    end
    return HEADER_COLORS[card.card_type] or {0.4, 0.4, 0.45}
end

--- 카드 그리기
--- @param w number|nil  카드 너비 (nil 이면 CARD_W 사용)
--- @param h number|nil  카드 높이 (nil 이면 CARD_H 사용)
function CardRenderer.draw(card, x, y, is_selected, is_hovered, font_small, w, h)
    w = w or CardRenderer.CARD_W
    h = h or CardRenderer.CARD_H

    -- w/h 비례 레이아웃 상수
    local bd        = math.max(2, math.floor(w * 0.04))   -- 테두리/패딩 (base 4px)
    local header_h  = math.floor(h * 0.186)                -- 헤더 높이 (base 26px)
    local px        = math.max(2, math.floor(w * 0.05))    -- 픽셀 아이콘 단위 (base 5px)
    local month_oy  = math.max(3, math.floor(h * 0.036))   -- 월 텍스트 y오프셋 (base 5px)
    local name_oy   = math.floor(h * 0.114)                -- 하단 이름 y오프셋 (base 16px)
    local check_oy  = math.floor(h * 0.129)                -- 체크마크 y오프셋 (base 18px)

    -- 선택/호버 시 위로
    local lift = is_selected and math.floor(h * 0.071) or (is_hovered and math.floor(h * 0.029) or 0)
    y = y - lift

    -- 카드 일러스트 로드
    local card_id = CardRenderer._get_card_id(card)
    local sprite = card_id and SpriteLoader.getCard(card_id)

    -- 그림자
    love.graphics.setColor(0.03, 0.02, 0.05, is_selected and 0.5 or 0.3)
    love.graphics.rectangle("fill", x+2, y+2, w, h)

    -- 카드 프레임 (모든 타입 공통: ui_card_frame_tti)
    local card_frame = SpriteLoader.get("ui-frames", "ui_card_frame_tti")

    if sprite then
        -- === 스프라이트 모드 ===
        -- 레이어 순서:
        --   1) 검정 배경 (전체)
        --   2) 화투 일러스트 — 프레임 구멍(hole) 영역에만 scissor 클리핑
        --   3) 카드 프레임 오버레이 (장식 테두리만 불투명, 외부+내부 투명)
        --   4) 텍스트 배지 (월/이름)

        local hc = CardRenderer.get_header_color(card)

        -- 프레임 구멍 위치 (130×182 기준: hole=25,24~104,161 → ~19.2%,13.2%,60.8%,75.3%)
        local hole_ox = math.floor(w * 0.192)
        local hole_oy = math.floor(h * 0.132)
        local hole_w  = math.floor(w * 0.608)
        local hole_h  = math.floor(h * 0.753)

        -- 1) 검정 배경 (전체)
        love.graphics.setColor(0.02, 0.02, 0.04, 1)
        love.graphics.rectangle("fill", x, y, w, h)

        -- 2) 화투 일러스트 — 구멍 영역에만
        love.graphics.setScissor(x + hole_ox, y + hole_oy, hole_w, hole_h)
        local isx = w / sprite:getWidth()
        local isy = h / sprite:getHeight()
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.draw(sprite, x, y, 0, isx, isy)
        love.graphics.setScissor()

        -- 3) 프레임 오버레이 (장식 테두리만)
        if card_frame then
            local fsx = w / card_frame:getWidth()
            local fsy = h / card_frame:getHeight()
            love.graphics.setColor(1, 1, 1, 1)
            love.graphics.draw(card_frame, x, y, 0, fsx, fsy)
        else
            -- 프레임 에셋 없을 때 폴백: 빨간 테두리
            love.graphics.setColor(0.72, 0.08, 0.05, 1)
            love.graphics.setLineWidth(bd * 2)
            love.graphics.rectangle("line", x + bd, y + bd, w - bd*2, h - bd*2)
            love.graphics.setLineWidth(1)
        end

        -- 4) 상단 텍스트 배지: 월 숫자
        if font_small then love.graphics.setFont(font_small) end
        local badge_top_h = math.max(10, math.floor(h * 0.13))
        love.graphics.setColor(0, 0, 0, 0.72)
        love.graphics.rectangle("fill", x + 1, y + 1, w - 2, badge_top_h)
        love.graphics.setColor(1, 0.95, 0.7, 1)
        love.graphics.printf(tostring(card.month) .. "월", x, y + month_oy, w, "center")

        -- 5) 하단 텍스트 배지: 카드 이름
        local label = card.name_kr or ""
        if label ~= "" or card.card_type == CT.Gwang then
            local badge_bot_h = math.max(10, math.floor(h * 0.15))
            love.graphics.setColor(0, 0, 0, 0.72)
            love.graphics.rectangle("fill", x + 1, y + h - badge_bot_h - 1, w - 2, badge_bot_h)
            if card.card_type == CT.Gwang then
                love.graphics.setColor(1, 0.88, 0.2, 1)
                love.graphics.printf("★ " .. label, x, y + h - name_oy, w, "center")
            else
                love.graphics.setColor(hc[1] + 0.3, hc[2] + 0.3, hc[3] + 0.3, 1)
                love.graphics.printf(label, x, y + h - name_oy, w, "center")
            end
        end
    else
        -- === 폴백 모드: 도형으로 그리기 ===
        local hc = CardRenderer.get_header_color(card)

        if is_selected then love.graphics.setColor(0.20, 0.14, 0.06)
        elseif is_hovered then love.graphics.setColor(0.10, 0.08, 0.15)
        else love.graphics.setColor(0.07, 0.05, 0.11) end
        love.graphics.rectangle("fill", x, y, w, h)

        -- 헤더 컬러바
        love.graphics.setColor(hc[1], hc[2], hc[3], 1)
        love.graphics.rectangle("fill", x+1, y+1, w-2, header_h)

        -- 월 숫자 (헤더 위에 크게)
        if font_small then love.graphics.setFont(font_small) end
        love.graphics.setColor(0, 0, 0, 0.8)
        love.graphics.printf(tostring(card.month) .. "월", x, y + month_oy, w, "center")

        -- 카드 타입 도형 (중앙)
        local cx, cy = x + w/2, y + h/2 - px

        if card.card_type == CT.Gwang then
            -- 광: 큰 별
            love.graphics.setColor(1, 0.82, 0, 0.9)
            love.graphics.rectangle("fill", cx-px, cy-3*px, 2*px, 6*px)
            love.graphics.rectangle("fill", cx-3*px, cy-px, 6*px, 2*px)
            love.graphics.rectangle("fill", cx-2*px, cy-2*px, px, px)
            love.graphics.rectangle("fill", cx+px, cy-2*px, px, px)
            love.graphics.rectangle("fill", cx-2*px, cy+px, px, px)
            love.graphics.rectangle("fill", cx+px, cy+px, px, px)
            love.graphics.setColor(1, 0.82, 0)
            love.graphics.printf("★ 광", x, cy+3*px+2, w, "center")
        elseif card.card_type == CT.Tti then
            -- 띠: 리본 모양
            local rc = hc
            love.graphics.setColor(rc[1], rc[2], rc[3], 0.9)
            love.graphics.rectangle("fill", cx-4*px, cy-px, 8*px, 3*px)
            love.graphics.setColor(1, 1, 1, 0.4)
            love.graphics.rectangle("fill", cx-4*px, cy-px, 8*px, px)
            local ribbon_kr = ({[RT.HongDan]="홍단", [RT.CheongDan]="청단", [RT.ChoDan]="초단"})[card.ribbon] or "띠"
            love.graphics.setColor(rc[1], rc[2], rc[3])
            love.graphics.printf(ribbon_kr, x, cy+2*px+2, w, "center")
        elseif card.card_type == CT.Geurim then
            -- 그림: 다이아몬드
            love.graphics.setColor(0.35, 0.75, 0.92, 0.8)
            love.graphics.rectangle("fill", cx-px, cy-2*px, 2*px, px)
            love.graphics.rectangle("fill", cx-2*px, cy-px, 4*px, px)
            love.graphics.rectangle("fill", cx-3*px, cy, 6*px, px)
            love.graphics.rectangle("fill", cx-2*px, cy+px, 4*px, px)
            love.graphics.rectangle("fill", cx-px, cy+2*px, 2*px, px)
            love.graphics.setColor(0.35, 0.75, 0.92)
            love.graphics.printf("열끗", x, cy+3*px+2, w, "center")
        else
            -- 피: 점 2개
            love.graphics.setColor(0.65, 0.65, 0.70, 0.8)
            love.graphics.rectangle("fill", cx-3*px, cy-px, 2*px, 2*px)
            love.graphics.rectangle("fill", cx+px, cy-px, 2*px, 2*px)
            if card.is_double_pi then
                love.graphics.setColor(1, 0.82, 0, 0.6)
                love.graphics.rectangle("fill", cx-px, cy+2*px, 2*px, 2*px)
                love.graphics.printf("쌍피", x, cy+4*px+2, w, "center")
            else
                love.graphics.setColor(0.65, 0.65, 0.70)
                love.graphics.printf("피", x, cy+2*px+2, w, "center")
            end
        end

        -- 카드 이름 (하단)
        if font_small then love.graphics.setFont(font_small) end
        love.graphics.setColor(0.7, 0.7, 0.75)
        love.graphics.printf(card.name_kr or "", x+2, y + h - name_oy, w-4, "center")
    end

    -- ======= 기믹 상태 오버레이 =======

    -- 뒤집기(FlipAll): 카드 전체를 덮어 앞면 숨김
    if card.is_flipped then
        love.graphics.setColor(0.05, 0.03, 0.10, 0.92)
        love.graphics.rectangle("fill", x, y, w, h)
        love.graphics.setColor(0.50, 0.35, 0.80)
        love.graphics.setLineWidth(2)
        love.graphics.rectangle("line", x, y, w, h)
        love.graphics.setLineWidth(1)
        if font_small then love.graphics.setFont(font_small) end
        love.graphics.setColor(0.55, 0.40, 0.90)
        love.graphics.printf("?", x, y + h/2 - 8, w, "center")
    end

    -- 안개(Fog): 반투명 파란 안개 오버레이 + 아이콘
    if card.is_fogged then
        love.graphics.setColor(0.20, 0.45, 0.70, 0.55)
        love.graphics.rectangle("fill", x, y, w, h)
        if font_small then love.graphics.setFont(font_small) end
        love.graphics.setColor(0.50, 0.80, 1.0, 0.9)
        love.graphics.printf("〜", x, y + 2, w, "center")
    end

    -- 독(PoisonPi): 초록 독 오버레이 (피 카드에만)
    if card.is_poisoned then
        love.graphics.setColor(0.10, 0.55, 0.15, 0.45)
        love.graphics.rectangle("fill", x, y, w, h)
        if font_small then love.graphics.setFont(font_small) end
        love.graphics.setColor(0.20, 0.90, 0.30, 0.9)
        love.graphics.printf("☠", x, y + 2, w, "center")
    end

    -- 가짜(FakeCards): 우측 상단 빨간 "FAKE" 배지
    if card.is_fake then
        local bw, bh = 30, 12
        love.graphics.setColor(0.70, 0.08, 0.08, 0.88)
        love.graphics.rectangle("fill", x + w - bw - 2, y + 2, bw, bh, 2)
        if font_small then love.graphics.setFont(font_small) end
        love.graphics.setColor(1, 1, 1, 0.95)
        love.graphics.printf("FAKE", x + w - bw - 2, y + 2, bw, "center")
    end

    -- 테두리 + 글로우
    if is_selected then
        local pulse = 0.7 + math.sin(love.timer.getTime() * 4) * 0.3
        for i = 3, 1, -1 do
            love.graphics.setColor(1, 0.82, 0, 0.08 * pulse * (4-i))
            love.graphics.rectangle("fill", x-i, y-i, w+i*2, h+i*2)
        end
        love.graphics.setColor(0.92, 0.68, 0.12, 0.9)
        love.graphics.setLineWidth(2)
    elseif is_hovered then
        love.graphics.setColor(0.50, 0.35, 0.55, 0.6)
        love.graphics.setLineWidth(1)
    else
        love.graphics.setColor(0.30, 0.15, 0.22)
        love.graphics.setLineWidth(1)
    end
    love.graphics.rectangle("line", x, y, w, h)
    love.graphics.setLineWidth(1)

    -- 선택 시 체크마크
    if is_selected then
        love.graphics.setColor(1, 0.82, 0)
        love.graphics.printf("✓", x, y + h - check_oy, w - 5, "right")
    end

    return x, y, w, h
end

-- 미니 카드 (바닥패용)
CardRenderer.MINI_W = 60
CardRenderer.MINI_H = 84

--- 미니 카드 그리기
--- @param w number|nil  카드 너비 (nil 이면 MINI_W 사용)
--- @param h number|nil  카드 높이 (nil 이면 MINI_H 사용)
function CardRenderer.draw_mini(card, x, y, w, h)
    w = w or CardRenderer.MINI_W
    h = h or CardRenderer.MINI_H

    local card_id = CardRenderer._get_card_id(card)
    local sprite = card_id and SpriteLoader.getCard(card_id)

    local mini_frame = SpriteLoader.get("ui-frames", "ui_card_frame_tti")

    if sprite then
        local hole_ox = math.floor(w * 0.192)
        local hole_oy = math.floor(h * 0.132)
        local hole_w  = math.floor(w * 0.608)
        local hole_h  = math.floor(h * 0.753)

        love.graphics.setColor(0.02, 0.02, 0.04, 1)
        love.graphics.rectangle("fill", x, y, w, h)

        love.graphics.setScissor(x + hole_ox, y + hole_oy, hole_w, hole_h)
        local sx = w / sprite:getWidth()
        local sy = h / sprite:getHeight()
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.draw(sprite, x, y, 0, sx, sy)
        love.graphics.setScissor()

        if mini_frame then
            local fsx = w / mini_frame:getWidth()
            local fsy = h / mini_frame:getHeight()
            love.graphics.setColor(1, 1, 1, 1)
            love.graphics.draw(mini_frame, x, y, 0, fsx, fsy)
        end
    else
        -- 폴백: 도형 모드
        local header_h  = math.max(6, math.floor(h * 0.119))   -- ~10px at h=84
        local px        = math.max(1, math.floor(w * 0.033))    -- ~2px at w=60
        local mid_y     = y + math.floor(h * 0.333)             -- ~28px at h=84

        love.graphics.setColor(0.10, 0.08, 0.16)
        love.graphics.rectangle("fill", x, y, w, h)
        love.graphics.setColor(0.28, 0.25, 0.38)
        love.graphics.rectangle("line", x, y, w, h)

        local hc = CardRenderer.get_header_color(card)
        love.graphics.setColor(hc[1], hc[2], hc[3], 1)
        love.graphics.rectangle("fill", x+1, y+1, w-2, header_h)

        local cx = x + w/2
        if card.card_type == CT.Gwang then
            love.graphics.setColor(1, 0.82, 0)
            love.graphics.rectangle("fill", cx - px/2, mid_y - 2*px, px, 4*px)
            love.graphics.rectangle("fill", cx - 2*px, mid_y - px/2, 4*px, px)
        elseif card.card_type == CT.Tti then
            local rc = CardRenderer.get_header_color(card)
            love.graphics.setColor(rc[1], rc[2], rc[3], 0.8)
            love.graphics.rectangle("fill", cx - 4*px, mid_y, 8*px, 2*px)
        elseif card.card_type == CT.Geurim then
            love.graphics.setColor(0.35, 0.75, 0.92, 0.8)
            love.graphics.rectangle("fill", cx - px, mid_y, 2*px, 2*px)
        else
            love.graphics.setColor(0.65, 0.65, 0.70)
            love.graphics.rectangle("fill", cx - px, mid_y, 2*px, 2*px)
        end
    end
end

return CardRenderer

--- 족보 가이드 — 모든 족보 조합을 미니 카드로 표시
local CardRenderer = require("src.ui.card_renderer")
local DU = require("src.ui.draw_utils")

local YokboGuide = {}
YokboGuide._scroll = 0

-- 카드 타입 약어
local G = "gwang"
local T = "tti"
local GR = "geurim"
local P = "pi"

-- 리본 타입
local HG = "hongdan"
local CG = "cheongdan"
local CD = "chodan"

-- 가짜 카드 생성 (미니 카드 표시용)
local function mc(month, card_type, opts)
    opts = opts or {}
    return {
        month = month,
        card_type = card_type,
        ribbon = opts.ribbon or "none",
        is_rain_gwang = opts.rain or false,
        is_double_pi = opts.double or false,
        base_points = opts.pts or 0,
        name_kr = opts.name or (month .. "월"),
    }
end

-- 티어 색상
local TIER_COLORS = {
    S = {1, 0.84, 0},
    A = {0.25, 0.9, 0.85},
    B = {0.15, 0.7, 0.2},
    C = {0.5, 0.5, 0.5},
    D = {0.35, 0.3, 0.3},
}

-- 카테고리 라벨
local CAT_LABELS = {
    gostop = "고스톱",
    seotda = "섯다",
    jeoseung = "저승",
    seasonal = "계절",
    collection = "수집",
}

-- 모든 족보 정의 (조건 카드 포함)
local YOKBO_LIST = {
    -- ═══ Tier S ═══
    { tier="S", cat="gostop", name="오광", desc="광 5장",
      cards={mc(1,G), mc(3,G), mc(8,G), mc(11,G,{rain=true}), mc(12,G)} },
    { tier="S", cat="seotda", name="38광땡", desc="3월광 + 8월광",
      cards={mc(3,G), mc(8,G)} },
    { tier="S", cat="jeoseung", name="황천의다리", desc="12개월 모두 보유",
      cards={mc(1,G), mc(2,GR), mc(3,G), mc(4,GR), mc(5,GR), mc(6,GR),
             mc(7,GR), mc(8,G), mc(9,GR), mc(10,GR), mc(11,G,{rain=true}), mc(12,G)} },
    { tier="S", cat="gostop", name="삼단통", desc="홍단+청단+초단 모두",
      cards={mc(1,T,{ribbon=HG}), mc(2,T,{ribbon=HG}), mc(3,T,{ribbon=HG}),
             mc(6,T,{ribbon=CG}), mc(9,T,{ribbon=CG}), mc(10,T,{ribbon=CG}),
             mc(4,T,{ribbon=CD}), mc(5,T,{ribbon=CD}), mc(7,T,{ribbon=CD})} },
    { tier="S", cat="jeoseung", name="윤회", desc="총통(4장 세트) 3개 이상",
      cards={mc(1,G), mc(1,T,{ribbon=HG}), mc(1,GR), mc(1,P),
             mc(2,GR), mc(2,T,{ribbon=HG}), mc(2,GR), mc(2,P),
             mc(3,G), mc(3,T,{ribbon=HG}), mc(3,GR), mc(3,P)} },

    -- ═══ Tier A ═══
    { tier="A", cat="gostop", name="사광", desc="광 4장 (비광 제외)",
      cards={mc(1,G), mc(3,G), mc(8,G), mc(12,G)} },
    { tier="A", cat="gostop", name="비사광", desc="광 4장 (비광 포함)",
      cards={mc(1,G), mc(3,G), mc(8,G), mc(11,G,{rain=true})} },
    { tier="A", cat="seotda", name="13광땡", desc="1월광 + 3월광",
      cards={mc(1,G), mc(3,G)} },
    { tier="A", cat="seotda", name="18광땡", desc="1월광 + 8월광",
      cards={mc(1,G), mc(8,G)} },
    { tier="A", cat="seotda", name="장땡", desc="10월 카드 2장",
      cards={mc(10,GR), mc(10,T,{ribbon=CG})} },
    { tier="A", cat="seotda", name="9땡", desc="9월 카드 2장",
      cards={mc(9,GR), mc(9,T,{ribbon=CG})} },
    { tier="A", cat="seotda", name="8땡", desc="8월 카드 2장",
      cards={mc(8,G), mc(8,GR)} },
    { tier="A", cat="jeoseung", name="도깨비불", desc="광 3장 + 피 5장",
      cards={mc(1,G), mc(3,G), mc(8,G), mc(2,P), mc(4,P), mc(6,P), mc(7,P), mc(9,P)} },
    { tier="A", cat="jeoseung", name="저승꽃", desc="피 가치 합 15 이상",
      cards={mc(1,P), mc(2,P), mc(3,P), mc(4,P), mc(5,P), mc(6,P), mc(7,P), mc(9,P,{double=true})} },
    { tier="A", cat="jeoseung", name="삼도천", desc="3월 + 6월 + 9월",
      cards={mc(3,G), mc(6,GR), mc(9,GR)} },

    -- ═══ Tier B ═══
    { tier="B", cat="gostop", name="삼광", desc="광 3장 (비광 제외)",
      cards={mc(1,G), mc(3,G), mc(8,G)} },
    { tier="B", cat="gostop", name="비광", desc="광 3장 (비광 포함)",
      cards={mc(1,G), mc(3,G), mc(11,G,{rain=true})} },
    { tier="B", cat="gostop", name="홍단", desc="1·2·3월 홍단 띠",
      cards={mc(1,T,{ribbon=HG}), mc(2,T,{ribbon=HG}), mc(3,T,{ribbon=HG})} },
    { tier="B", cat="gostop", name="청단", desc="6·9·10월 청단 띠",
      cards={mc(6,T,{ribbon=CG}), mc(9,T,{ribbon=CG}), mc(10,T,{ribbon=CG})} },
    { tier="B", cat="gostop", name="초단", desc="4·5·7월 초단 띠",
      cards={mc(4,T,{ribbon=CD}), mc(5,T,{ribbon=CD}), mc(7,T,{ribbon=CD})} },
    { tier="B", cat="gostop", name="고도리", desc="2·4·8월 그림",
      cards={mc(2,GR), mc(4,GR), mc(8,GR)} },
    { tier="B", cat="gostop", name="총통", desc="같은 월 카드 4장",
      cards={mc(1,G), mc(1,T,{ribbon=HG}), mc(1,GR), mc(1,P)} },
    { tier="B", cat="seotda", name="알리", desc="1월 + 2월",
      cards={mc(1,G), mc(2,GR)} },
    { tier="B", cat="seotda", name="독사", desc="1월 + 4월",
      cards={mc(1,G), mc(4,GR)} },
    { tier="B", cat="seotda", name="구삥", desc="1월 + 9월",
      cards={mc(1,G), mc(9,GR)} },
    { tier="B", cat="seasonal", name="사계", desc="3·6·9·12월",
      cards={mc(3,G), mc(6,GR), mc(9,GR), mc(12,G)} },
    { tier="B", cat="jeoseung", name="선후착", desc="1월광 + 12월광",
      cards={mc(1,G), mc(12,G)} },
    { tier="B", cat="seasonal", name="봄의연회", desc="1·2·3월 카드 4장+",
      cards={mc(1,G), mc(1,T,{ribbon=HG}), mc(2,GR), mc(3,G)} },
    { tier="B", cat="seasonal", name="가을단풍", desc="8·9·10월 카드 4장+",
      cards={mc(8,G), mc(8,GR), mc(9,GR), mc(10,GR)} },

    -- ═══ Tier C ═══
    { tier="C", cat="seotda", name="장삥", desc="1월 + 10월",
      cards={mc(1,G), mc(10,GR)} },
    { tier="C", cat="seotda", name="장사", desc="4월 + 10월",
      cards={mc(4,GR), mc(10,GR)} },
    { tier="C", cat="seotda", name="세륙", desc="4월 + 6월",
      cards={mc(4,GR), mc(6,GR)} },
    { tier="C", cat="collection", name="띠5장", desc="띠 카드 5장 이상",
      cards={mc(1,T,{ribbon=HG}), mc(2,T,{ribbon=HG}), mc(4,T,{ribbon=CD}), mc(6,T,{ribbon=CG}), mc(9,T,{ribbon=CG})} },
    { tier="C", cat="collection", name="그림5장", desc="그림 카드 5장 이상",
      cards={mc(2,GR), mc(4,GR), mc(6,GR), mc(7,GR), mc(8,GR)} },
    { tier="C", cat="collection", name="피10장", desc="피 가치 합 10 이상",
      cards={mc(1,P), mc(2,P), mc(3,P), mc(4,P), mc(5,P), mc(6,P), mc(7,P), mc(9,P,{double=true})} },
    { tier="C", cat="jeoseung", name="월하독작", desc="8월광 + 9월그림",
      cards={mc(8,G), mc(9,GR)} },
    { tier="C", cat="jeoseung", name="염라의심판", desc="1월광 + 11월광",
      cards={mc(1,G), mc(11,G,{rain=true})} },
    { tier="C", cat="jeoseung", name="저승길", desc="11월 + 12월 + 피",
      cards={mc(11,G,{rain=true}), mc(12,G), mc(5,P)} },
    { tier="C", cat="jeoseung", name="귀화", desc="비광 + 1월광",
      cards={mc(11,G,{rain=true}), mc(1,G)} },
    { tier="C", cat="jeoseung", name="혼백분리", desc="광 1장 + 피 3장",
      cards={mc(1,G), mc(2,P), mc(4,P), mc(6,P)} },
    { tier="C", cat="jeoseung", name="업경대", desc="3종류 이상 카드 3장+",
      cards={mc(1,G), mc(2,T,{ribbon=HG}), mc(3,P)} },
    { tier="C", cat="jeoseung", name="도깨비방망이", desc="그림 3장 이상",
      cards={mc(2,GR), mc(4,GR), mc(6,GR)} },
    { tier="C", cat="jeoseung", name="피바다", desc="피 5장 이상",
      cards={mc(1,P), mc(2,P), mc(3,P), mc(4,P), mc(5,P)} },
    { tier="C", cat="jeoseung", name="무상", desc="모두 다른 월 3장+",
      cards={mc(1,G), mc(5,GR), mc(9,GR)} },
    { tier="C", cat="jeoseung", name="꽃비", desc="띠 2장 + 피 2장",
      cards={mc(1,T,{ribbon=HG}), mc(6,T,{ribbon=CG}), mc(3,P), mc(7,P)} },
    { tier="C", cat="jeoseung", name="귀문관", desc="12월 카드 2장",
      cards={mc(12,G), mc(12,P)} },
    { tier="C", cat="seasonal", name="여름바람", desc="6·7·8월 카드 3장+",
      cards={mc(6,GR), mc(7,GR), mc(8,G)} },
    { tier="C", cat="seasonal", name="겨울한파", desc="11월 + 12월",
      cards={mc(11,G,{rain=true}), mc(12,G)} },

    -- ═══ Tier D ═══
    { tier="D", cat="seotda", name="끗(5~9)", desc="월 합 끝자리 5~9",
      cards={mc(3,G), mc(6,GR)} },
    { tier="D", cat="seotda", name="끗(1~4)", desc="월 합 끝자리 1~4",
      cards={mc(1,G), mc(2,GR)} },
    { tier="D", cat="seotda", name="망통", desc="월 합 끝자리 0",
      cards={mc(5,GR), mc(5,T,{ribbon=CD})} },
    { tier="D", cat="collection", name="피짝", desc="피만으로 구성",
      cards={mc(1,P), mc(3,P)} },
}

function YokboGuide.draw(W, H, fonts, PAL, panel_fn, set_fn)
    -- 반투명 배경
    set_fn({0, 0, 0, 0.85})
    love.graphics.rectangle("fill", 0, 0, W, H)

    -- 제목
    love.graphics.setFont(fonts.l)
    set_fn(PAL.gold)
    love.graphics.printf("족보 가이드", 0, 20, W, "center")
    love.graphics.setFont(fonts.s)
    set_fn(PAL.dim)
    love.graphics.printf("모든 족보 조합과 필요 카드", 0, 46, W, "center")

    -- 스크롤 영역
    local area_x = 30
    local area_y = 68
    local area_w = W - 60
    local area_h = H - 100

    love.graphics.setScissor(area_x, area_y, area_w, area_h)

    local mw, mh = CardRenderer.MINI_W, CardRenderer.MINI_H
    local mgap = 3
    local row_h = mh + 30  -- 카드 + 이름/설명
    local col_w = area_w
    local y = area_y + YokboGuide._scroll
    local current_tier = nil

    for _, yokbo in ipairs(YOKBO_LIST) do
        -- 티어 헤더
        if yokbo.tier ~= current_tier then
            current_tier = yokbo.tier
            if y + 20 > area_y - 30 and y < area_y + area_h then
                love.graphics.setFont(fonts.m)
                set_fn(TIER_COLORS[current_tier] or PAL.white)
                love.graphics.printf("── Tier " .. current_tier .. " ──", area_x, y, col_w, "left")
            end
            y = y + 24
        end

        -- 이 항목이 보이는 영역인지 체크
        local visible = (y + row_h > area_y) and (y < area_y + area_h)

        if visible then
            -- 배경 패널
            set_fn({0.12, 0.10, 0.18, 0.7})
            love.graphics.rectangle("fill", area_x, y, col_w, row_h - 4, 4)
            set_fn({0.2, 0.18, 0.28})
            love.graphics.rectangle("line", area_x, y, col_w, row_h - 4, 4)

            -- 족보 이름 + 카테고리
            love.graphics.setFont(fonts.m)
            set_fn(TIER_COLORS[yokbo.tier] or PAL.white)
            love.graphics.print(yokbo.name, area_x + 8, y + 4)

            love.graphics.setFont(fonts.s)
            local cat_label = CAT_LABELS[yokbo.cat] or yokbo.cat
            set_fn(PAL.dim)
            love.graphics.print(cat_label, area_x + 8 + fonts.m:getWidth(yokbo.name) + 8, y + 6)

            -- 설명
            love.graphics.print(yokbo.desc, area_x + 8, y + 22)

            -- 미니 카드들 (우측 정렬)
            local n_cards = #yokbo.cards
            local cards_w = n_cards * (mw + mgap) - mgap
            local cards_x = area_x + col_w - cards_w - 10
            local cards_y = y + 6

            -- 카드가 너무 많으면 왼쪽 한계
            if cards_x < area_x + 180 then cards_x = area_x + 180 end

            for ci, card in ipairs(yokbo.cards) do
                local cx = cards_x + (ci - 1) * (mw + mgap)
                if cx + mw <= area_x + col_w - 4 then
                    CardRenderer.draw_mini(card, cx, cards_y)
                end
            end

            -- 카드가 잘렸으면 "..." 표시
            local max_visible = math.floor((area_x + col_w - 14 - cards_x) / (mw + mgap))
            if max_visible < n_cards then
                love.graphics.setFont(fonts.s)
                set_fn(PAL.dim)
                love.graphics.print("+" .. (n_cards - max_visible), area_x + col_w - 28, cards_y + mh/2 - 6)
            end
        end

        y = y + row_h
    end

    love.graphics.setScissor()

    -- 스크롤 인디케이터
    local total_h = y - area_y - YokboGuide._scroll
    if total_h > area_h then
        local bar_h = math.max(20, area_h * (area_h / total_h))
        local bar_y = area_y + (-YokboGuide._scroll / total_h) * area_h
        set_fn({0.4, 0.4, 0.5, 0.5})
        love.graphics.rectangle("fill", W - 18, bar_y, 6, bar_h, 3)
    end

    -- 닫기 안내
    love.graphics.setFont(fonts.s)
    set_fn(PAL.dim)
    love.graphics.printf("아무 곳이나 클릭하면 닫힘", 0, H - 24, W, "center")
end

function YokboGuide.scroll(dy)
    YokboGuide._scroll = YokboGuide._scroll + dy * 30
    if YokboGuide._scroll > 0 then YokboGuide._scroll = 0 end

    -- 최대 스크롤 제한
    local total = #YOKBO_LIST * (CardRenderer.MINI_H + 30) + 200
    local min_scroll = -(total - 400)
    if min_scroll > 0 then min_scroll = 0 end
    if YokboGuide._scroll < min_scroll then YokboGuide._scroll = min_scroll end
end

function YokboGuide.reset_scroll()
    YokboGuide._scroll = 0
end

return YokboGuide

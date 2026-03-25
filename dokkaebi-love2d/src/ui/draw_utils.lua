--- UI 유틸: CSS처럼 그림자/글로우/그라데이션
local U = {}

--- 그림자가 있는 패널 (도트 스타일 — 직각)
function U.shadow_panel(x, y, w, h, _r, bg_color, shadow_alpha)
    shadow_alpha = shadow_alpha or 0.3
    -- 그림자 (아래 오른쪽 4px)
    love.graphics.setColor(0, 0, 0, shadow_alpha)
    love.graphics.rectangle("fill", x+3, y+3, w, h)
    -- 배경
    love.graphics.setColor(bg_color[1], bg_color[2], bg_color[3], bg_color[4] or 0.94)
    love.graphics.rectangle("fill", x, y, w, h)
    -- 상단 하이라이트 (inner glow)
    love.graphics.setColor(1, 1, 1, 0.04)
    love.graphics.rectangle("fill", x+1, y+1, w-2, h*0.3)
    -- 테두리
    love.graphics.setColor(1, 1, 1, 0.14)
    love.graphics.rectangle("line", x, y, w, h)
end

--- 글로우 텍스트 (text-shadow 느낌)
function U.glow_text(font, text, x, y, w, align, color, glow_color)
    love.graphics.setFont(font)
    -- 글로우 (blur 대신 여러 번 그리기)
    if glow_color then
        love.graphics.setColor(glow_color[1], glow_color[2], glow_color[3], 0.3)
        love.graphics.printf(text, x-1, y-1, w, align or "center")
        love.graphics.printf(text, x+1, y+1, w, align or "center")
    end
    -- 본문
    love.graphics.setColor(color[1], color[2], color[3], color[4] or 1)
    love.graphics.printf(text, x, y, w, align or "center")
end

--- 그라데이션 바 (HP바, 프로그레스바용 — 도트 직각)
function U.gradient_bar(x, y, w, h, ratio, color_full, color_empty, _r)
    -- 배경
    love.graphics.setColor(color_empty[1], color_empty[2], color_empty[3], 0.8)
    love.graphics.rectangle("fill", x, y, w, h)
    -- 채우기
    if ratio > 0 then
        love.graphics.setColor(color_full[1], color_full[2], color_full[3], 1)
        love.graphics.rectangle("fill", x+1, y+1, (w-2)*math.max(ratio, 0), h-2)
        -- 상단 광택
        love.graphics.setColor(1, 1, 1, 0.15)
        love.graphics.rectangle("fill", x+1, y+1, (w-2)*math.max(ratio, 0), (h-2)*0.4)
    end
end

--- 픽셀아트 스타일 버튼 (도트 베벨)
function U.styled_button(text, x, y, w, h, color, font, hovered, _r)
    local br = hovered and 0.14 or 0
    local r = color[1]+br; local g = color[2]+br; local b = color[3]+br

    -- 드롭 그림자
    love.graphics.setColor(0, 0, 0, hovered and 0.50 or 0.32)
    love.graphics.rectangle("fill", x+2, y+2, w, h)

    -- 베이스
    love.graphics.setColor(r, g, b)
    love.graphics.rectangle("fill", x, y, w, h)

    -- 베벨 상단/좌측
    local hl = hovered and 0.80 or 0.58
    love.graphics.setColor(math.min(1,r+0.30), math.min(1,g+0.28), math.min(1,b+0.26), hl)
    love.graphics.rectangle("fill", x+1, y, w-1, 1)
    love.graphics.rectangle("fill", x, y+1, 1, h-1)

    -- 베벨 하단/우측
    love.graphics.setColor(math.max(0,r-0.28), math.max(0,g-0.28), math.max(0,b-0.28), 0.88)
    love.graphics.rectangle("fill", x+1, y+h-1, w-1, 1)
    love.graphics.rectangle("fill", x+w-1, y+1, 1, h-1)

    -- 모서리 노치
    love.graphics.setColor(0, 0, 0, 0.60)
    love.graphics.rectangle("fill", x, y, 1, 1)
    love.graphics.rectangle("fill", x+w-1, y, 1, 1)
    love.graphics.rectangle("fill", x, y+h-1, 1, 1)
    love.graphics.rectangle("fill", x+w-1, y+h-1, 1, 1)

    -- 텍스트
    love.graphics.setFont(font)
    local ty = y + math.floor(h/2 - 7)
    if hovered then ty = ty + 1 end
    love.graphics.setColor(0, 0, 0, 0.45)
    love.graphics.printf(text, x+1, ty+1, w, "center")
    love.graphics.setColor(1, 1, 1, hovered and 1.0 or 0.92)
    love.graphics.printf(text, x, ty, w, "center")
end

--- 구분선
function U.divider(x, y, w, color)
    love.graphics.setColor(color[1], color[2], color[3], 0.3)
    love.graphics.rectangle("fill", x, y, w, 1)
    love.graphics.setColor(1, 1, 1, 0.05)
    love.graphics.rectangle("fill", x, y+1, w, 1)
end

--- 배경 비네트 (저승 화투 — 핏빛+먹물 가장자리)
function U.vignette(w, h)
    -- 상단: 먹물 어둠
    for i = 0, 50 do
        love.graphics.setColor(0.04, 0.03, 0.06, (50-i)/50 * 0.35)
        love.graphics.rectangle("fill", 0, i, w, 1)
    end
    -- 하단: 저승의 심연
    for i = 0, 60 do
        love.graphics.setColor(0.03, 0.02, 0.05, (60-i)/60 * 0.50)
        love.graphics.rectangle("fill", 0, h-i, w, 1)
    end
    -- 좌우: 핏빛 안개
    for i = 0, 25 do
        love.graphics.setColor(0.08, 0.02, 0.04, (25-i)/25 * 0.15)
        love.graphics.rectangle("fill", i, 0, 1, h)
        love.graphics.rectangle("fill", w-i, 0, 1, h)
    end
end

return U

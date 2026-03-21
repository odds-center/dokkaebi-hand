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

--- CSS 스타일 버튼 (도트 직각)
function U.styled_button(text, x, y, w, h, color, font, hovered, _r)
    -- 그림자
    love.graphics.setColor(0, 0, 0, hovered and 0.4 or 0.25)
    love.graphics.rectangle("fill", x+2, y+2, w, h)
    -- 배경
    local br = hovered and 0.18 or 0
    love.graphics.setColor(color[1]+br, color[2]+br, color[3]+br, 1)
    love.graphics.rectangle("fill", x, y, w, h)
    -- 상단 광택
    love.graphics.setColor(1, 1, 1, hovered and 0.12 or 0.06)
    love.graphics.rectangle("fill", x+1, y+1, w-2, h*0.4)
    -- 하단 어두운 선
    love.graphics.setColor(0, 0, 0, 0.15)
    love.graphics.rectangle("fill", x+1, y+h*0.7, w-2, h*0.3-1)
    -- 텍스트
    love.graphics.setFont(font)
    love.graphics.setColor(1, 1, 1, hovered and 1 or 0.9)
    love.graphics.printf(text, x, y + h/2 - 7, w, "center")
    -- 테두리
    love.graphics.setColor(1, 1, 1, hovered and 0.2 or 0.08)
    love.graphics.rectangle("line", x, y, w, h)
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

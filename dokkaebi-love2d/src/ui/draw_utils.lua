--- UI 유틸: CSS처럼 그림자/글로우/그라데이션
local U = {}

--- 그림자가 있는 패널 (box-shadow 느낌)
function U.shadow_panel(x, y, w, h, r, bg_color, shadow_alpha)
    r = r or 6
    shadow_alpha = shadow_alpha or 0.3
    -- 그림자 (아래 오른쪽 4px)
    love.graphics.setColor(0, 0, 0, shadow_alpha)
    love.graphics.rectangle("fill", x+3, y+3, w, h, r)
    -- 배경
    love.graphics.setColor(bg_color[1], bg_color[2], bg_color[3], bg_color[4] or 0.94)
    love.graphics.rectangle("fill", x, y, w, h, r)
    -- 상단 하이라이트 (inner glow)
    love.graphics.setColor(1, 1, 1, 0.04)
    love.graphics.rectangle("fill", x+1, y+1, w-2, h*0.3, r)
    -- 테두리
    love.graphics.setColor(1, 1, 1, 0.08)
    love.graphics.rectangle("line", x, y, w, h, r)
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

--- 그라데이션 바 (HP바, 프로그레스바용)
function U.gradient_bar(x, y, w, h, ratio, color_full, color_empty, r)
    r = r or 3
    -- 배경
    love.graphics.setColor(color_empty[1], color_empty[2], color_empty[3], 0.8)
    love.graphics.rectangle("fill", x, y, w, h, r)
    -- 채우기
    if ratio > 0 then
        love.graphics.setColor(color_full[1], color_full[2], color_full[3], 1)
        love.graphics.rectangle("fill", x+1, y+1, (w-2)*math.max(ratio, 0), h-2, r-1)
        -- 상단 광택
        love.graphics.setColor(1, 1, 1, 0.15)
        love.graphics.rectangle("fill", x+1, y+1, (w-2)*math.max(ratio, 0), (h-2)*0.4, r-1)
    end
end

--- CSS 스타일 버튼 (호버 시 밝아짐 + 그림자)
function U.styled_button(text, x, y, w, h, color, font, hovered, r)
    r = r or 6
    -- 그림자
    love.graphics.setColor(0, 0, 0, hovered and 0.4 or 0.25)
    love.graphics.rectangle("fill", x+2, y+2, w, h, r)
    -- 배경
    local br = hovered and 0.18 or 0
    love.graphics.setColor(color[1]+br, color[2]+br, color[3]+br, 1)
    love.graphics.rectangle("fill", x, y, w, h, r)
    -- 상단 광택
    love.graphics.setColor(1, 1, 1, hovered and 0.12 or 0.06)
    love.graphics.rectangle("fill", x+1, y+1, w-2, h*0.4, r)
    -- 하단 어두운 선
    love.graphics.setColor(0, 0, 0, 0.15)
    love.graphics.rectangle("fill", x+1, y+h*0.7, w-2, h*0.3-1, r)
    -- 텍스트
    love.graphics.setFont(font)
    love.graphics.setColor(1, 1, 1, hovered and 1 or 0.9)
    love.graphics.printf(text, x, y + h/2 - 7, w, "center")
    -- 테두리
    love.graphics.setColor(1, 1, 1, hovered and 0.2 or 0.08)
    love.graphics.rectangle("line", x, y, w, h, r)
end

--- 구분선
function U.divider(x, y, w, color)
    love.graphics.setColor(color[1], color[2], color[3], 0.3)
    love.graphics.rectangle("fill", x, y, w, 1)
    love.graphics.setColor(1, 1, 1, 0.05)
    love.graphics.rectangle("fill", x, y+1, w, 1)
end

--- 배경 비네트 (화면 가장자리 어두움)
function U.vignette(w, h)
    -- 상단 그라데이션
    for i = 0, 40 do
        love.graphics.setColor(0, 0, 0, (40-i)/40 * 0.3)
        love.graphics.rectangle("fill", 0, i, w, 1)
    end
    -- 하단
    for i = 0, 40 do
        love.graphics.setColor(0, 0, 0, (40-i)/40 * 0.4)
        love.graphics.rectangle("fill", 0, h-i, w, 1)
    end
end

return U

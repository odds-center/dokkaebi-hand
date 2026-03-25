--- 픽셀아트 스타일 버튼
--- 베벨 효과: 상단/좌측 하이라이트 + 하단/우측 그림자 + 모서리 노치
local Button = {}
Button.__index = Button

function Button.new(text, x, y, w, h, color, callback)
    return setmetatable({
        text     = text,
        x = x, y = y, w = w or 140, h = h or 32,
        color    = color or {0.18, 0.18, 0.24},
        callback = callback or function() end,
        hovered  = false,
        visible  = true,
        enabled  = true,
    }, Button)
end

function Button:contains(mx, my)
    return self.visible and mx >= self.x and mx <= self.x + self.w
        and my >= self.y and my <= self.y + self.h
end

function Button:update_hover(mx, my)
    self.hovered = self:contains(mx, my)
end

function Button:click(mx, my)
    if self.visible and self.enabled and self:contains(mx, my) then
        self.callback(); return true
    end
    return false
end

function Button:draw(font)
    if not self.visible then return end
    local bx, by, bw, bh = self.x, self.y, self.w, self.h
    local c   = self.color
    local hov = self.hovered and self.enabled
    local enb = self.enabled
    local br  = hov and 0.14 or 0

    -- 1. 픽셀 드롭 그림자 (하단+우측 2px)
    love.graphics.setColor(0, 0, 0, hov and 0.55 or 0.38)
    love.graphics.rectangle("fill", bx+2, by+2, bw, bh)

    -- 2. 버튼 베이스
    local r = enb and (c[1]+br) or 0.09
    local g = enb and (c[2]+br) or 0.07
    local b = enb and (c[3]+br) or 0.12
    love.graphics.setColor(r, g, b)
    love.graphics.rectangle("fill", bx, by, bw, bh)

    -- 3. 상단 하이라이트 1px (베벨 상단)
    local hl = hov and 0.85 or 0.62
    love.graphics.setColor(math.min(1,r+0.30), math.min(1,g+0.28), math.min(1,b+0.26), hl)
    love.graphics.rectangle("fill", bx+1, by,   bw-1, 1)  -- 상단
    love.graphics.rectangle("fill", bx,   by+1, 1, bh-1)  -- 좌측

    -- 4. 하단/우측 그림자 1px (베벨 하단)
    love.graphics.setColor(math.max(0,r-0.28), math.max(0,g-0.28), math.max(0,b-0.28), 0.92)
    love.graphics.rectangle("fill", bx+1, by+bh-1, bw-1, 1)  -- 하단
    love.graphics.rectangle("fill", bx+bw-1, by+1, 1, bh-1)  -- 우측

    -- 5. 모서리 노치 (4px — 클래식 픽셀아트 버튼 서명)
    love.graphics.setColor(0, 0, 0, 0.65)
    love.graphics.rectangle("fill", bx,      by,      1, 1)
    love.graphics.rectangle("fill", bx+bw-1, by,      1, 1)
    love.graphics.rectangle("fill", bx,      by+bh-1, 1, 1)
    love.graphics.rectangle("fill", bx+bw-1, by+bh-1, 1, 1)

    -- 6. 텍스트 (호버 시 1px 아래 = 눌린 느낌)
    if font then love.graphics.setFont(font) end
    local fh_  = love.graphics.getFont():getHeight()
    local ty   = by + math.floor((bh - fh_) / 2)
    if hov then ty = ty + 1 end

    -- 텍스트 드롭 쉐도우
    love.graphics.setColor(0, 0, 0, enb and 0.50 or 0.20)
    love.graphics.printf(self.text, bx+1, ty+1, bw, "center")

    -- 텍스트 본체
    love.graphics.setColor(0.92, 0.88, 0.80, enb and (hov and 1.0 or 0.90) or 0.32)
    love.graphics.printf(self.text, bx, ty, bw, "center")
end

return Button

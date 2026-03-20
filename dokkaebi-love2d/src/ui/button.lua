--- CSS 스타일 버튼 (그림자 + 호버 + 광택)
local Button = {}
Button.__index = Button

function Button.new(text, x, y, w, h, color, callback)
    return setmetatable({
        text = text,
        x = x, y = y, w = w or 140, h = h or 32,
        color = color or {0.18, 0.18, 0.24},
        callback = callback or function() end,
        hovered = false,
        visible = true,
        enabled = true,
        radius = 6,
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
        self.callback()
        return true
    end
    return false
end

function Button:draw(font)
    if not self.visible then return end
    local r = self.radius
    local c = self.color
    local hov = self.hovered and self.enabled
    local br = hov and 0.15 or 0

    -- 그림자 (도트 직각)
    love.graphics.setColor(0, 0, 0, hov and 0.35 or 0.2)
    love.graphics.rectangle("fill", self.x+2, self.y+2, self.w, self.h)

    -- 배경
    if not self.enabled then
        love.graphics.setColor(0.15, 0.15, 0.18)
    else
        love.graphics.setColor(c[1]+br, c[2]+br, c[3]+br)
    end
    love.graphics.rectangle("fill", self.x, self.y, self.w, self.h)

    -- 상단 광택
    love.graphics.setColor(1, 1, 1, hov and 0.10 or 0.05)
    love.graphics.rectangle("fill", self.x+1, self.y+1, self.w-2, self.h*0.35)

    -- 하단 어두움
    love.graphics.setColor(0, 0, 0, 0.12)
    love.graphics.rectangle("fill", self.x+1, self.y+self.h*0.65, self.w-2, self.h*0.35-1)

    -- 테두리
    love.graphics.setColor(1, 1, 1, hov and 0.18 or 0.06)
    love.graphics.rectangle("line", self.x, self.y, self.w, self.h)

    -- 텍스트
    if font then love.graphics.setFont(font) end
    love.graphics.setColor(1, 1, 1, self.enabled and (hov and 1 or 0.88) or 0.4)
    love.graphics.printf(self.text, self.x, self.y + self.h/2 - 7, self.w, "center")
end

return Button

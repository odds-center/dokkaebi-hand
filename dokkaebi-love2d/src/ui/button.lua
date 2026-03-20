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

    -- 그림자
    love.graphics.setColor(0.03, 0.02, 0.05, hov and 0.45 or 0.25)
    love.graphics.rectangle("fill", self.x+2, self.y+2, self.w, self.h)

    -- 배경
    if not self.enabled then
        love.graphics.setColor(0.09, 0.07, 0.12)
    else
        love.graphics.setColor(c[1]+br, c[2]+br, c[3]+br)
    end
    love.graphics.rectangle("fill", self.x, self.y, self.w, self.h)

    -- 상단 광택 (따뜻한 금빛)
    love.graphics.setColor(0.9, 0.7, 0.3, hov and 0.06 or 0.02)
    love.graphics.rectangle("fill", self.x+1, self.y+1, self.w-2, self.h*0.35)

    -- 하단 어두움
    love.graphics.setColor(0.03, 0.02, 0.05, 0.18)
    love.graphics.rectangle("fill", self.x+1, self.y+self.h*0.65, self.w-2, self.h*0.35-1)

    -- 테두리 (핏빛)
    love.graphics.setColor(0.45, 0.18, 0.15, hov and 0.30 or 0.10)
    love.graphics.rectangle("line", self.x, self.y, self.w, self.h)

    -- 텍스트
    if font then love.graphics.setFont(font) end
    love.graphics.setColor(0.90, 0.86, 0.78, self.enabled and (hov and 1 or 0.88) or 0.35)
    local fh = love.graphics.getFont():getHeight()
    love.graphics.printf(self.text, self.x, self.y + math.floor((self.h - fh) / 2), self.w, "center")
end

return Button

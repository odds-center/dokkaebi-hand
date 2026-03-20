--- 범용 UI 버튼
local Button = {}
Button.__index = Button

function Button.new(text, x, y, w, h, color, callback)
    return setmetatable({
        text = text,
        x = x, y = y, w = w, h = h,
        color = color or {0.5, 0.2, 0.2},
        callback = callback or function() end,
        hovered = false,
        visible = true,
        enabled = true,
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
    local r, g, b = unpack(self.color)
    if not self.enabled then r, g, b = 0.2, 0.2, 0.2
    elseif self.hovered then r, g, b = math.min(r+0.15, 1), math.min(g+0.15, 1), math.min(b+0.15, 1) end

    love.graphics.setColor(r, g, b)
    love.graphics.rectangle("fill", self.x, self.y, self.w, self.h, 6)

    -- 테두리
    love.graphics.setColor(1, 1, 1, 0.2)
    love.graphics.rectangle("line", self.x, self.y, self.w, self.h, 6)

    love.graphics.setColor(1, 1, 1)
    if font then love.graphics.setFont(font) end
    love.graphics.printf(self.text, self.x, self.y + self.h/2 - 8, self.w, "center")
end

return Button

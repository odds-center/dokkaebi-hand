--- icons.lua
--- 폰트 의존 없는 픽셀아트 아이콘 렌더러
--- 모든 UI 아이콘을 Love2D 도형으로 직접 그린다

local Icons = {}

--- 삼각형 화살표: 오른쪽 ►
function Icons.arrow_right(x, y, size, color)
    size = size or 10
    love.graphics.setColor(color or {1,1,1})
    love.graphics.polygon("fill",
        x, y,
        x + size, y + size/2,
        x, y + size
    )
end

--- 삼각형 화살표: 왼쪽 ◄
function Icons.arrow_left(x, y, size, color)
    size = size or 10
    love.graphics.setColor(color or {1,1,1})
    love.graphics.polygon("fill",
        x + size, y,
        x, y + size/2,
        x + size, y + size
    )
end

--- 삼각형 화살표: 아래 ▼
function Icons.arrow_down(x, y, size, color)
    size = size or 10
    love.graphics.setColor(color or {1,1,1})
    love.graphics.polygon("fill",
        x, y,
        x + size, y,
        x + size/2, y + size
    )
end

--- 삼각형 화살표: 위 ▲
function Icons.arrow_up(x, y, size, color)
    size = size or 10
    love.graphics.setColor(color or {1,1,1})
    love.graphics.polygon("fill",
        x + size/2, y,
        x + size, y + size,
        x, y + size
    )
end

--- 톱니바퀴 (설정) — 간단한 도트 버전
function Icons.gear(x, y, size, color)
    size = size or 14
    local cx, cy = x + size/2, y + size/2
    local r_outer = size/2
    local r_inner = size/3.5
    love.graphics.setColor(color or {0.7, 0.7, 0.7})
    -- 외곽 원
    love.graphics.circle("fill", cx, cy, r_outer)
    -- 내부 배경 (구멍)
    love.graphics.setColor(0.06, 0.04, 0.10)
    love.graphics.circle("fill", cx, cy, r_inner)
    -- 톱니 (4방향 사각)
    love.graphics.setColor(color or {0.7, 0.7, 0.7})
    local t = size/7
    love.graphics.rectangle("fill", cx-t/2, y-1, t, size+2)
    love.graphics.rectangle("fill", x-1, cy-t/2, size+2, t)
    -- 대각선 톱니
    love.graphics.push()
    love.graphics.translate(cx, cy)
    love.graphics.rotate(math.pi/4)
    love.graphics.rectangle("fill", -t/2, -r_outer-1, t, size+2)
    love.graphics.rectangle("fill", -r_outer-1, -t/2, size+2, t)
    love.graphics.pop()
    -- 내부 원 다시 (깔끔하게)
    love.graphics.setColor(0.06, 0.04, 0.10)
    love.graphics.circle("fill", cx, cy, r_inner)
end

--- 하트 (체력)
function Icons.heart(x, y, size, color, filled)
    size = size or 12
    love.graphics.setColor(color or {0.9, 0.15, 0.15})
    local cx, cy = x + size/2, y + size/2
    local r = size/4
    if filled ~= false then
        love.graphics.circle("fill", cx - r, cy - r*0.5, r)
        love.graphics.circle("fill", cx + r, cy - r*0.5, r)
        love.graphics.polygon("fill",
            x + 1, cy,
            cx, y + size - 1,
            x + size - 1, cy
        )
    else
        love.graphics.circle("line", cx - r, cy - r*0.5, r)
        love.graphics.circle("line", cx + r, cy - r*0.5, r)
    end
end

--- 네모 (카드 타입 표시)
function Icons.square(x, y, size, color)
    size = size or 8
    love.graphics.setColor(color or {1,1,1})
    love.graphics.rectangle("fill", x, y, size, size)
end

--- 동그라미 (불릿)
function Icons.circle(x, y, size, color)
    size = size or 8
    love.graphics.setColor(color or {1,1,1})
    love.graphics.circle("fill", x + size/2, y + size/2, size/2)
end

--- 별 (광 카드)
function Icons.star(x, y, size, color)
    size = size or 12
    local cx, cy = x + size/2, y + size/2
    local outer = size/2
    local inner = size/5
    love.graphics.setColor(color or {1, 0.82, 0})
    local pts = {}
    for i = 0, 9 do
        local angle = math.pi * 2 * i / 10 - math.pi/2
        local r = (i % 2 == 0) and outer or inner
        pts[#pts+1] = cx + math.cos(angle) * r
        pts[#pts+1] = cy + math.sin(angle) * r
    end
    love.graphics.polygon("fill", pts)
end

--- 다이아몬드 (그림 카드)
function Icons.diamond(x, y, size, color)
    size = size or 10
    local cx, cy = x + size/2, y + size/2
    local r = size/2
    love.graphics.setColor(color or {0.3, 0.75, 0.7})
    love.graphics.polygon("fill",
        cx, cy - r,
        cx + r, cy,
        cx, cy + r,
        cx - r, cy
    )
end

--- 점 (피 카드 / 불릿)
function Icons.dot(x, y, size, color)
    size = size or 6
    love.graphics.setColor(color or {0.5, 0.5, 0.5})
    love.graphics.circle("fill", x + size/2, y + size/2, size/3)
end

--- 가로줄 (띠 카드)
function Icons.bar(x, y, w, color)
    w = w or 10
    love.graphics.setColor(color or {0.8, 0.12, 0.12})
    love.graphics.rectangle("fill", x, y, w, 3)
end

return Icons

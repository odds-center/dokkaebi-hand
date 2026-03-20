--- 전투 이펙트: 데미지 팝업, 화면 흔들림, 플래시
local NumFmt = require("src.core.number_formatter")

local Effects = {}

-- 활성 이펙트 목록
local active = {}

-- 화면 흔들림
local shake_t = 0
local shake_intensity = 0

-- 하트 피격 타이머
local heart_hit_t = 0

--- 데미지 숫자 팝업
function Effects.damage_popup(x, y, amount, color)
    active[#active+1] = {
        type = "popup",
        x = x, y = y,
        text = NumFmt.format_score(amount),
        color = color or {1, 0.82, 0},
        life = 1.2,   -- 초
        max_life = 1.2,
        vy = -60,     -- 위로 올라감
    }
end

--- 텍스트 팝업 (족보 이름 등)
function Effects.text_popup(x, y, text, color)
    active[#active+1] = {
        type = "popup",
        x = x, y = y,
        text = text,
        color = color or {1, 1, 1},
        life = 1.5,
        max_life = 1.5,
        vy = -40,
    }
end

--- 흔들림 즉시 중단
function Effects.stop_shake()
    shake_t = 0
    shake_intensity = 0
end

--- 화면 흔들림
function Effects.shake(intensity, duration)
    shake_intensity = intensity or 5
    shake_t = duration or 0.3
end

--- 화면 플래시
function Effects.flash(color, duration)
    active[#active+1] = {
        type = "flash",
        color = color or {1, 1, 1},
        life = duration or 0.15,
        max_life = duration or 0.15,
    }
end

--- 보스 격파 이펙트
function Effects.boss_defeat(boss_name)
    Effects.shake(12, 0.5)
    Effects.flash({1, 0.82, 0}, 0.2)
    Effects.text_popup(640, 200, boss_name .. " 격파!", {1, 0.82, 0})
end

--- 피격 이펙트
function Effects.boss_hit(dmg)
    Effects.shake(math.min(dmg / 30, 10), 0.2)
    Effects.damage_popup(640 + math.random(-30, 30), 100 + math.random(-10, 10), dmg)
end

--- 플레이어 피격 이펙트 (체력 감소)
function Effects.player_hit(amount)
    amount = amount or 1
    Effects.shake(6 + amount * 3, 0.3)
    Effects.flash({0.7, 0.05, 0.05}, 0.25)
    heart_hit_t = 0.6  -- 하트 깜빡임 0.6초
    local label = amount > 1 and ("체력 -" .. amount .. "!") or "체력 -1!"
    Effects.text_popup(640, 30, label, {1, 0.15, 0.1})
end

--- 하트 피격 깜빡임 상태 (외부에서 조회)
function Effects.get_heart_hit_alpha()
    if heart_hit_t <= 0 then return 1 end
    -- 빠르게 깜빡이는 효과 (0~1 사이 진동)
    local blink = math.sin(heart_hit_t * 20) * 0.5 + 0.5
    return 0.3 + blink * 0.7
end

--- 즉사 이펙트
function Effects.instant_death()
    Effects.shake(15, 0.6)
    Effects.flash({0.8, 0.1, 0.05}, 0.3)
    Effects.text_popup(640, 300, "즉사!", {1, 0.2, 0.1})
end

--- 업데이트
function Effects.update(dt)
    -- 흔들림 감소
    if shake_t > 0 then shake_t = shake_t - dt end
    if heart_hit_t > 0 then heart_hit_t = heart_hit_t - dt end

    -- 이펙트 업데이트
    local i = 1
    while i <= #active do
        local e = active[i]
        e.life = e.life - dt
        if e.life <= 0 then
            table.remove(active, i)
        else
            if e.vy then e.y = e.y + e.vy * dt end
            i = i + 1
        end
    end
end

--- 흔들림 오프셋 반환
function Effects.get_shake_offset()
    if shake_t <= 0 then return 0, 0 end
    local s = shake_intensity * (shake_t / 0.3)
    return math.random(-s, s), math.random(-s, s)
end

--- 그리기 (love.draw에서 호출)
function Effects.draw(fonts)
    -- 플래시
    for _, e in ipairs(active) do
        if e.type == "flash" then
            local alpha = (e.life / e.max_life) * 0.4
            love.graphics.setColor(e.color[1], e.color[2], e.color[3], alpha)
            love.graphics.rectangle("fill", 0, 0, love.graphics.getDimensions())
        end
    end

    -- 팝업
    for _, e in ipairs(active) do
        if e.type == "popup" then
            local alpha = math.min(1, e.life / (e.max_life * 0.3))
            local scale = 1 + (1 - e.life / e.max_life) * 0.3
            love.graphics.setFont(fonts.l or love.graphics.getFont())
            -- 글로우
            love.graphics.setColor(e.color[1], e.color[2], e.color[3], alpha * 0.3)
            love.graphics.printf(e.text, e.x - 152, e.y - 1, 300, "center")
            love.graphics.printf(e.text, e.x - 148, e.y + 1, 300, "center")
            -- 본문
            love.graphics.setColor(e.color[1], e.color[2], e.color[3], alpha)
            love.graphics.printf(e.text, e.x - 150, e.y, 300, "center")
        end
    end
end

return Effects

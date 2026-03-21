--- 전투 이펙트 시스템 v2
--- 족보 컷인, 데미지 팝업, 카드 글로우, 고 위험, 보스 폭발, 콤보 체인
local NumFmt = require("src.core.number_formatter")

local Effects = {}

-- 활성 이펙트
local active = {}

-- 상태
local shake_t = 0
local shake_intensity = 0
local heart_hit_t = 0

-- 족보 컷인
local cutin = nil  -- {text, tier, life, max_life, color}

-- 고 위험 레벨 (0~3)
local go_danger = 0

-- 콤보 체인
local chain_count = 0
local chain_timer = 0

-- 파티클
local particles = {}

-- ===========================
-- 파티클 시스템
-- ===========================

local function spawn_particles(x, y, count, color, spread, speed, life)
    for i = 1, count do
        local angle = math.random() * math.pi * 2
        local spd = speed * (0.5 + math.random() * 0.5)
        particles[#particles+1] = {
            x = x + math.random(-spread, spread),
            y = y + math.random(-spread, spread),
            vx = math.cos(angle) * spd,
            vy = math.sin(angle) * spd - 30,
            life = life * (0.7 + math.random() * 0.3),
            max_life = life,
            size = 2 + math.random() * 3,
            color = {color[1], color[2], color[3]},
        }
    end
end

-- ===========================
-- 기본 이펙트
-- ===========================

function Effects.shake(intensity, duration)
    shake_intensity = math.max(shake_intensity, intensity or 5)
    shake_t = math.max(shake_t, duration or 0.3)
end

function Effects.stop_shake()
    shake_t = 0; shake_intensity = 0
end

function Effects.flash(color, duration)
    active[#active+1] = {
        type = "flash",
        color = color or {1, 1, 1},
        life = duration or 0.15,
        max_life = duration or 0.15,
    }
end

-- ===========================
-- 데미지 팝업 (크고 화려하게)
-- ===========================

function Effects.damage_popup(x, y, amount, color)
    local is_big = amount >= 80
    active[#active+1] = {
        type = "damage",
        x = x + math.random(-20, 20),
        y = y,
        text = NumFmt.format_score(amount),
        color = color or (is_big and {1, 0.3, 0.1} or {1, 0.82, 0}),
        life = is_big and 1.5 or 1.0,
        max_life = is_big and 1.5 or 1.0,
        vy = is_big and -80 or -50,
        scale = is_big and 1.8 or 1.2,
        is_big = is_big,
    }
    -- 큰 데미지 시 파티클
    if is_big then
        spawn_particles(x, y, 12, {1, 0.6, 0.1}, 30, 120, 0.6)
    end
end

function Effects.text_popup(x, y, text, color)
    active[#active+1] = {
        type = "damage",
        x = x, y = y,
        text = text,
        color = color or {1, 1, 1},
        life = 1.5, max_life = 1.5,
        vy = -40, scale = 1.0,
    }
end

-- ===========================
-- 족보 컷인 (화면 중앙 대형 텍스트)
-- ===========================

local TIER_COLORS = {
    [1] = {1, 0.82, 0},        -- S: 금색
    [2] = {0.4, 0.85, 1.0},    -- A: 하늘
    [3] = {0.3, 0.85, 0.4},    -- B: 초록
    [4] = {0.7, 0.7, 0.75},    -- C: 회색
    [5] = {0.5, 0.45, 0.4},    -- D: 갈색
}

local TIER_NAMES = {[1]="S", [2]="A", [3]="B", [4]="C", [5]="D"}

function Effects.combo_cutin(name, tier)
    tier = tier or 3
    local dur = tier <= 2 and 1.8 or (tier <= 3 and 1.2 or 0.8)
    cutin = {
        text = name,
        tier_text = TIER_NAMES[tier] or "?",
        tier = tier,
        color = TIER_COLORS[tier] or {1,1,1},
        life = dur,
        max_life = dur,
    }
    -- S/A급은 화면 흔들림 + 파티클
    if tier <= 2 then
        Effects.shake(tier == 1 and 8 or 5, 0.3)
        Effects.flash(TIER_COLORS[tier], 0.15)
        local W = love.graphics.getWidth()
        spawn_particles(W/2, love.graphics.getHeight()/2 - 40, tier == 1 and 25 or 15, TIER_COLORS[tier], 80, 150, 0.8)
    end
end

-- ===========================
-- 콤보 체인
-- ===========================

function Effects.add_chain()
    chain_count = chain_count + 1
    chain_timer = 2.0
    if chain_count >= 3 then
        Effects.flash({1, 0.82, 0, 0.15}, 0.1)
    end
end

function Effects.reset_chain()
    chain_count = 0
    chain_timer = 0
end

-- ===========================
-- 고(Go) 위험 연출
-- ===========================

function Effects.set_go_danger(level)
    go_danger = math.min(level, 3)
end

-- ===========================
-- 보스 이펙트
-- ===========================

function Effects.boss_hit(dmg)
    local intensity = math.min(dmg / 20, 12)
    Effects.shake(intensity, 0.25)
    local W = love.graphics.getWidth()
    Effects.damage_popup(W/2, 80, dmg)
end

function Effects.boss_defeat(boss_name)
    Effects.shake(15, 0.8)
    Effects.flash({1, 0.82, 0}, 0.3)
    local W, H = love.graphics.getDimensions()
    -- 대형 텍스트
    active[#active+1] = {
        type = "boss_defeat",
        text = boss_name .. " 격파!",
        life = 2.5, max_life = 2.5,
    }
    -- 폭발 파티클
    spawn_particles(W/2, 100, 40, {1, 0.82, 0}, 60, 200, 1.0)
    spawn_particles(W/2, 100, 20, {1, 0.4, 0.1}, 40, 150, 0.8)
    spawn_particles(W/2, 100, 15, {1, 1, 1}, 30, 100, 0.6)
end

function Effects.player_hit(amount)
    amount = amount or 1
    Effects.shake(6 + amount * 3, 0.3)
    Effects.flash({0.7, 0.05, 0.05}, 0.25)
    heart_hit_t = 0.6
    local W = love.graphics.getWidth()
    Effects.text_popup(W/2, 30, amount > 1 and ("체력 -"..amount.."!") or "체력 -1!", {1, 0.15, 0.1})
end

function Effects.instant_death()
    Effects.shake(18, 0.8)
    Effects.flash({0.8, 0.1, 0.05}, 0.4)
    local W, H = love.graphics.getDimensions()
    active[#active+1] = {
        type = "fullscreen_text",
        text = "즉사!",
        color = {1, 0.1, 0.05},
        life = 1.5, max_life = 1.5,
    }
    spawn_particles(W/2, H/2, 30, {0.8, 0.1, 0.05}, 100, 180, 0.7)
end

function Effects.get_heart_hit_alpha()
    if heart_hit_t <= 0 then return 1 end
    return 0.3 + (math.sin(heart_hit_t * 20) * 0.5 + 0.5) * 0.7
end

-- ===========================
-- 카드 글로우 (card_renderer에서 호출)
-- ===========================

function Effects.draw_card_glow(x, y, w, h, color, intensity)
    intensity = intensity or 0.3
    local c = color or {1, 0.82, 0}
    -- 외곽 글로우 (여러 겹)
    for i = 1, 3 do
        local expand = i * 2
        love.graphics.setColor(c[1], c[2], c[3], intensity / i)
        love.graphics.rectangle("line", x - expand, y - expand, w + expand*2, h + expand*2)
    end
end

-- ===========================
-- 업데이트
-- ===========================

function Effects.update(dt)
    if shake_t > 0 then shake_t = shake_t - dt end
    if heart_hit_t > 0 then heart_hit_t = heart_hit_t - dt end

    -- 컷인
    if cutin then
        cutin.life = cutin.life - dt
        if cutin.life <= 0 then cutin = nil end
    end

    -- 체인 타이머
    if chain_timer > 0 then
        chain_timer = chain_timer - dt
        if chain_timer <= 0 then chain_count = 0 end
    end

    -- 이펙트 업데이트
    local i = 1
    while i <= #active do
        local e = active[i]
        e.life = e.life - dt
        if e.life <= 0 then
            table.remove(active, i)
        else
            if e.vy then
                e.y = e.y + e.vy * dt
                e.vy = e.vy * 0.98  -- 감속
            end
            if e.scale and e.is_big then
                -- 큰 데미지: 처음에 커졌다가 줄어듦
                local p = 1 - e.life / e.max_life
                if p < 0.1 then
                    e._draw_scale = e.scale * (p / 0.1)
                else
                    e._draw_scale = e.scale
                end
            end
            i = i + 1
        end
    end

    -- 파티클 업데이트
    local pi = 1
    while pi <= #particles do
        local p = particles[pi]
        p.life = p.life - dt
        if p.life <= 0 then
            table.remove(particles, pi)
        else
            p.x = p.x + p.vx * dt
            p.y = p.y + p.vy * dt
            p.vy = p.vy + 200 * dt  -- 중력
            p.size = p.size * 0.995
            pi = pi + 1
        end
    end
end

-- ===========================
-- 흔들림
-- ===========================

function Effects.get_shake_offset()
    if shake_t <= 0 then return 0, 0 end
    local s = shake_intensity * math.min(shake_t / 0.3, 1)
    return (math.random() * 2 - 1) * s, (math.random() * 2 - 1) * s
end

-- ===========================
-- 그리기
-- ===========================

function Effects.draw(fonts)
    local W, H = love.graphics.getDimensions()

    -- 고 위험 오버레이 (화면 테두리 빨갛게)
    if go_danger > 0 then
        local alpha = go_danger * 0.08
        local pulse = math.sin(love.timer.getTime() * 3) * 0.02
        love.graphics.setColor(0.8, 0.05, 0.02, alpha + pulse)
        -- 상단
        love.graphics.rectangle("fill", 0, 0, W, 8 * go_danger)
        -- 하단
        love.graphics.rectangle("fill", 0, H - 8 * go_danger, W, 8 * go_danger)
        -- 좌
        love.graphics.rectangle("fill", 0, 0, 6 * go_danger, H)
        -- 우
        love.graphics.rectangle("fill", W - 6 * go_danger, 0, 6 * go_danger, H)
    end

    -- 플래시
    for _, e in ipairs(active) do
        if e.type == "flash" then
            local alpha = (e.life / e.max_life) * 0.4
            love.graphics.setColor(e.color[1], e.color[2], e.color[3], alpha)
            love.graphics.rectangle("fill", 0, 0, W, H)
        end
    end

    -- 데미지 팝업
    for _, e in ipairs(active) do
        if e.type == "damage" then
            local alpha = math.min(1, e.life / (e.max_life * 0.3))
            local sc = e._draw_scale or e.scale or 1

            local f = fonts.l or love.graphics.getFont()
            if sc > 1.3 and fonts.xl then f = fonts.xl end
            love.graphics.setFont(f)

            -- 그림자
            love.graphics.setColor(0, 0, 0, alpha * 0.5)
            love.graphics.printf(e.text, e.x - 148, e.y + 2, 300, "center")

            -- 외곽 글로우
            love.graphics.setColor(e.color[1], e.color[2], e.color[3], alpha * 0.3)
            love.graphics.printf(e.text, e.x - 152, e.y - 1, 300, "center")
            love.graphics.printf(e.text, e.x - 148, e.y + 1, 300, "center")

            -- 본체
            love.graphics.setColor(e.color[1], e.color[2], e.color[3], alpha)
            love.graphics.printf(e.text, e.x - 150, e.y, 300, "center")
        end
    end

    -- 족보 컷인
    if cutin then
        local p = 1 - cutin.life / cutin.max_life  -- 0→1 진행도
        local c = cutin.color

        -- 슬라이드 인 (왼쪽에서 중앙으로)
        local slide_in = math.min(p / 0.1, 1)  -- 처음 10%에서 슬라이드
        local slide_out = cutin.life < 0.3 and (cutin.life / 0.3) or 1
        local offset_x = (1 - slide_in) * (-200) + (1 - slide_out) * 200

        -- 배경 바 (화면 가로 전체)
        local bar_h = 50
        local bar_y = H * 0.38 - bar_h / 2
        local bar_alpha = math.min(slide_in, slide_out) * 0.7
        love.graphics.setColor(0, 0, 0, bar_alpha)
        love.graphics.rectangle("fill", 0, bar_y - 5, W, bar_h + 10)
        love.graphics.setColor(c[1]*0.3, c[2]*0.3, c[3]*0.3, bar_alpha)
        love.graphics.rectangle("fill", 0, bar_y, W, bar_h)

        -- 상하 경계선
        love.graphics.setColor(c[1], c[2], c[3], bar_alpha)
        love.graphics.rectangle("fill", 0, bar_y, W, 2)
        love.graphics.rectangle("fill", 0, bar_y + bar_h - 2, W, 2)

        -- 족보 이름 (큰 글씨)
        local text_alpha = math.min(slide_in, slide_out)
        if fonts.xl then love.graphics.setFont(fonts.xl)
        elseif fonts.l then love.graphics.setFont(fonts.l) end

        -- 그림자
        love.graphics.setColor(0, 0, 0, text_alpha * 0.6)
        love.graphics.printf(cutin.text, offset_x + 2, bar_y + 8 + 2, W, "center")
        -- 글로우
        love.graphics.setColor(c[1], c[2], c[3], text_alpha * 0.4)
        love.graphics.printf(cutin.text, offset_x - 1, bar_y + 8 - 1, W, "center")
        love.graphics.printf(cutin.text, offset_x + 1, bar_y + 8 + 1, W, "center")
        -- 본체
        love.graphics.setColor(c[1], c[2], c[3], text_alpha)
        love.graphics.printf(cutin.text, offset_x, bar_y + 8, W, "center")

        -- 티어 표시 (우측)
        if fonts.m then love.graphics.setFont(fonts.m) end
        love.graphics.setColor(c[1], c[2], c[3], text_alpha * 0.8)
        love.graphics.printf("Tier " .. cutin.tier_text, offset_x, bar_y + bar_h - 20, W - 20, "right")
    end

    -- 보스 격파 연출
    for _, e in ipairs(active) do
        if e.type == "boss_defeat" then
            local p = 1 - e.life / e.max_life
            local alpha = p < 0.1 and (p/0.1) or (e.life < 0.5 and e.life/0.5 or 1)
            local scale = 1 + p * 0.3

            if fonts.xl then love.graphics.setFont(fonts.xl) end

            -- 배경 바
            local bar_y = H * 0.35
            love.graphics.setColor(0, 0, 0, alpha * 0.6)
            love.graphics.rectangle("fill", 0, bar_y - 10, W, 60)
            love.graphics.setColor(1, 0.82, 0, alpha * 0.15)
            love.graphics.rectangle("fill", 0, bar_y - 10, W, 60)

            -- 텍스트
            love.graphics.setColor(0, 0, 0, alpha * 0.5)
            love.graphics.printf(e.text, 2, bar_y + 8 + 2, W, "center")
            love.graphics.setColor(1, 0.82, 0, alpha)
            love.graphics.printf(e.text, 0, bar_y + 8, W, "center")
        end
    end

    -- 즉사 연출
    for _, e in ipairs(active) do
        if e.type == "fullscreen_text" then
            local p = 1 - e.life / e.max_life
            local alpha = p < 0.15 and (p/0.15) or (e.life < 0.3 and e.life/0.3 or 1)

            if fonts.xl then love.graphics.setFont(fonts.xl) end
            love.graphics.setColor(0, 0, 0, alpha * 0.7)
            love.graphics.rectangle("fill", 0, H*0.35, W, 60)
            love.graphics.setColor(e.color[1], e.color[2], e.color[3], alpha)
            love.graphics.printf(e.text, 0, H*0.37, W, "center")
        end
    end

    -- 콤보 체인 표시
    if chain_count >= 2 and chain_timer > 0 then
        local alpha = math.min(chain_timer / 0.3, 1)
        local pulse = 1 + math.sin(love.timer.getTime() * 8) * 0.05
        if fonts.m then love.graphics.setFont(fonts.m) end

        local chain_text = chain_count .. " CHAIN!"
        local col = chain_count >= 4 and {1, 0.3, 0.1} or (chain_count >= 3 and {1, 0.82, 0} or {0.4, 0.85, 1})

        love.graphics.setColor(0, 0, 0, alpha * 0.5)
        love.graphics.printf(chain_text, W - 152, H * 0.42 + 2, 150, "right")
        love.graphics.setColor(col[1], col[2], col[3], alpha)
        love.graphics.printf(chain_text, W - 150, H * 0.42, 150, "right")
    end

    -- 파티클
    for _, p in ipairs(particles) do
        local alpha = math.min(1, p.life / (p.max_life * 0.3))
        love.graphics.setColor(p.color[1], p.color[2], p.color[3], alpha)
        love.graphics.rectangle("fill", p.x - p.size/2, p.y - p.size/2, p.size, p.size)
    end
end

return Effects

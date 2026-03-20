--- HUD: 보스 HP바, 시너지 표시, 플레이어 정보
local NumFmt = require("src.core.number_formatter")

local HUD = {}

function HUD.draw_boss_info(boss_name, boss_hp, boss_max_hp, spiral, realm, round, max_rounds, go_count, plays_used, max_plays, fonts)
    -- 나선/관문/라운드
    love.graphics.setColor(1, 1, 1)
    love.graphics.setFont(fonts.medium or love.graphics.getFont())
    love.graphics.print(string.format("나선 %d | %d관문 | 판 %d/%d",
        spiral, realm, round, max_rounds), 20, 10)

    -- 보스 이름
    love.graphics.setColor(1, 0.84, 0)
    love.graphics.print(boss_name or "???", 20, 40)

    -- HP 바
    local bx, by, bw, bh = 20, 70, 250, 22
    love.graphics.setColor(0.15, 0.05, 0.05)
    love.graphics.rectangle("fill", bx, by, bw, bh)

    local ratio = boss_max_hp > 0 and (boss_hp / boss_max_hp) or 0
    if ratio > 0.5 then love.graphics.setColor(0.8, 0.15, 0.1)
    elseif ratio > 0.2 then love.graphics.setColor(0.9, 0.5, 0.1)
    else love.graphics.setColor(1, 0.2, 0.2) end
    love.graphics.rectangle("fill", bx + 1, by + 1, (bw - 2) * ratio, bh - 2)

    love.graphics.setColor(1, 1, 1)
    love.graphics.setFont(fonts.small or love.graphics.getFont())
    love.graphics.print(string.format("HP %s / %s", NumFmt.format(boss_hp), NumFmt.format(boss_max_hp)), bx + 5, by + 3)

    -- 내기/고 정보
    love.graphics.setColor(0.5, 0.5, 0.5)
    love.graphics.print(string.format("내기: %d/%d  고: %d회", plays_used, max_plays, go_count), 20, 100)
end

function HUD.draw_synergy(chips, mult, fonts)
    love.graphics.setColor(1, 1, 1)
    love.graphics.setFont(fonts.medium or love.graphics.getFont())
    love.graphics.print(string.format("칩: %s", NumFmt.format_score(chips)), 20, 130)

    love.graphics.setColor(0.3, 1, 0.9)
    love.graphics.print(string.format("x 배수: %.1f", mult), 150, 130)

    love.graphics.setColor(1, 0.84, 0)
    local total = math.floor(chips * mult)
    love.graphics.print(string.format("= %s", NumFmt.format_score(total)), 20, 158)
end

function HUD.draw_player_info(lives, max_lives, yeop, fonts)
    local hearts = ""
    for i = 1, max_lives do
        hearts = hearts .. (i <= lives and "♥" or "♡")
    end
    love.graphics.setColor(lives <= 2 and {1, 0.2, 0.2} or {1, 0.4, 0.4})
    love.graphics.setFont(fonts.small or love.graphics.getFont())
    love.graphics.print(hearts .. "  엽전: " .. yeop .. "냥", 20, 190)
end

function HUD.draw_message_log(messages, y_start, fonts)
    love.graphics.setFont(fonts.small or love.graphics.getFont())
    for i, msg in ipairs(messages) do
        local alpha = math.max(0, 1 - (i - 1) * 0.15)
        love.graphics.setColor(1, 0.84, 0, alpha)
        love.graphics.print(msg, 20, y_start - (i - 1) * 18)
    end
end

return HUD

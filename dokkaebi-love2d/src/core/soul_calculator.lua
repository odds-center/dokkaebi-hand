--- 런 종료 시 넋(영혼 조각) 보상 계산

local SoulCalculator = {}

--- 보스 격파 시 넋
--- @param absolute_realm number 절대 영역 번호
--- @param parts_count number 보스 기물 수
--- @param has_set_bonus boolean 세트 보너스 유무
--- @return number
function SoulCalculator.for_boss_defeat(absolute_realm, parts_count, has_set_bonus)
    local base_reward
    if absolute_realm <= 10 then
        base_reward = 10 + absolute_realm * 2
    else
        base_reward = 20 + absolute_realm
    end

    local parts_multiplier = 1.0 + parts_count * 0.25
    if has_set_bonus then
        parts_multiplier = parts_multiplier + 0.5
    end

    return math.floor(base_reward * parts_multiplier)
end

--- 윤회 완료 보너스
--- @param spiral_number number 윤회 번호
--- @return number
function SoulCalculator.for_spiral_complete(spiral_number)
    if spiral_number == 1 then return 100 end
    return 50 + spiral_number * 20
end

--- Go 3회 성공 보너스
--- @return number
function SoulCalculator.for_triple_go()
    return 50
end

--- 런 실패 시 감소 (70% 유지)
--- @param total_earned number 총 획득량
--- @return number
function SoulCalculator.apply_death_penalty(total_earned)
    return math.floor(total_earned * 0.7)
end

return SoulCalculator

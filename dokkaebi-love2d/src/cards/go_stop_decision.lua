--- Go/Stop 선택 로직 및 리스크 적용

-- ============================================================
-- GoRisk: Go 선택 시 리스크 정보
-- ============================================================
local function make_go_risk(multiplier_bonus, next_target_mult, hand_penalty,
                            instant_death_on_fail, legendary_reward)
    return {
        multiplier_bonus      = multiplier_bonus,
        next_target_mult      = next_target_mult,
        hand_penalty          = hand_penalty,
        instant_death_on_fail = instant_death_on_fail,
        legendary_reward      = legendary_reward,
    }
end

-- ============================================================
-- GoStopDecision
-- ============================================================
local GoStopDecision = {}
GoStopDecision.__index = GoStopDecision

function GoStopDecision.new(scoring_engine)
    return setmetatable({
        _scoring_engine = scoring_engine,
    }, GoStopDecision)
end

--- 현재 Go 횟수에 따른 리스크 정보
function GoStopDecision:get_go_risk(current_go_count)
    local next_go = current_go_count + 1

    if next_go == 1 then
        return make_go_risk(2, 1.5, 0, false, false)
    elseif next_go == 2 then
        return make_go_risk(4, 1.0, 1, false, false)
    else -- 3+
        return make_go_risk(10, 1.0, 0, true, true)
    end
end

--- Go 선택 실행
function GoStopDecision:execute_go(player)
    player.go_count = player.go_count + 1
end

--- Stop 선택 -> 최종 점수 확정
function GoStopDecision:execute_stop(player)
    return self._scoring_engine:calculate_score(player)
end

--- 현재 점수가 기본 Go 가능 점수(7점 이상)를 넘었는지
function GoStopDecision:can_go_or_stop(player)
    local score = self._scoring_engine:calculate_score(player)
    return score.final_score > 0
end

return {
    GoStopDecision = GoStopDecision,
    make_go_risk = make_go_risk,
}

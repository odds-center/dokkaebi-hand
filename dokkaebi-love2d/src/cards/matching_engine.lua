--- 패 매칭 엔진: 같은 월 매칭 판정
local Signal = require("lib.signal")

-- ============================================================
-- MatchResult enum
-- ============================================================
local MatchResult = {
    NO_MATCH     = "no_match",      -- 바닥에 같은 월 없음 -> 카드를 바닥에 놓음
    SINGLE_MATCH = "single_match",  -- 바닥에 같은 월 1장 -> 가져감
    DOUBLE_MATCH = "double_match",  -- 바닥에 같은 월 2장 -> 하나 선택
    TRIPLE_MATCH = "triple_match",  -- 바닥에 같은 월 3장 -> 전부 가져감 (뻑 = 쓸)
}

-- ============================================================
-- MatchingEngine
-- ============================================================
local MatchingEngine = {}
MatchingEngine.__index = MatchingEngine

function MatchingEngine.new(deck_manager)
    return setmetatable({
        _deck_manager = deck_manager,

        -- signals
        on_match_success = Signal.new(),  -- (played_card, captured_list)
        on_match_fail    = Signal.new(),  -- (played_card)
    }, MatchingEngine)
end

--- 바닥에서 같은 월 카드 목록 가져오기
local function get_field_cards_by_month(deck_manager, month)
    local matches = {}
    for _, card in ipairs(deck_manager.field_cards) do
        if card.month == month then
            table.insert(matches, card)
        end
    end
    return matches
end

--- 손패에서 낸 카드의 매칭 결과 판정
function MatchingEngine:evaluate_match(played_card)
    local field_matches = get_field_cards_by_month(self._deck_manager, played_card.month)
    local count = #field_matches

    if count == 0 then return MatchResult.NO_MATCH
    elseif count == 1 then return MatchResult.SINGLE_MATCH
    elseif count == 2 then return MatchResult.DOUBLE_MATCH
    elseif count >= 3 then return MatchResult.TRIPLE_MATCH
    end
    return MatchResult.NO_MATCH
end

--- 매칭 실행: 카드 내기 -> 바닥 매칭 -> 획득
--- NoMatch: 바닥에 놓기
--- SingleMatch: 해당 카드와 함께 획득
--- TripleMatch: 3장 모두 획득
--- DoubleMatch: selected_match로 지정된 카드와 획득 (플레이어 선택 필요)
function MatchingEngine:execute_match(played_card, selected_match)
    local captured = {}
    local field_matches = get_field_cards_by_month(self._deck_manager, played_card.month)
    local count = #field_matches

    if count == 0 then
        -- 바닥에 놓기
        self._deck_manager:add_to_field(played_card)

    elseif count == 1 then
        -- 1장 매칭 -> 둘 다 획득
        table.insert(captured, played_card)
        table.insert(captured, field_matches[1])
        self._deck_manager:remove_from_field(field_matches[1])

    elseif count == 2 then
        -- 2장 매칭 -> 플레이어가 선택한 1장과 획득
        local match_card = nil
        if selected_match then
            for _, fm in ipairs(field_matches) do
                if fm == selected_match then
                    match_card = fm
                    break
                end
            end
        end
        -- 선택이 없거나 유효하지 않으면 첫 번째 매칭 카드
        if not match_card then
            match_card = field_matches[1]
        end
        table.insert(captured, played_card)
        table.insert(captured, match_card)
        self._deck_manager:remove_from_field(match_card)

    elseif count >= 3 then
        -- 3장 매칭 (쓸) -> 전부 획득
        table.insert(captured, played_card)
        for _, fc in ipairs(field_matches) do
            table.insert(captured, fc)
            self._deck_manager:remove_from_field(fc)
        end
    end

    -- 시그널 발생
    if #captured > 0 then
        self.on_match_success:emit(played_card, captured)
    else
        self.on_match_fail:emit(played_card)
    end

    return captured
end

--- 뽑기패 매칭 (뒤집기 매칭)
--- 뽑기패에서 1장 뒤집어 바닥과 매칭
function MatchingEngine:execute_draw_match(drawn_card, selected_match)
    return self:execute_match(drawn_card, selected_match)
end

return {
    MatchResult = MatchResult,
    MatchingEngine = MatchingEngine,
}

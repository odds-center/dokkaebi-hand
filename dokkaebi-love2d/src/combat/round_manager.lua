--- 라운드 진행 관리 (Balatro 스타일)
--- Ported from RoundManager.cs
---
--- [패 분배 10장] → [시너지 페이즈: 1~5장 선택 → "내기!" → 콤보 판정 → 스택]
---   → [고/스톱 선택]
---     → 고: 추가 드로우 + 보스 반격
---     → 스톱: 공격 페이즈로
---   → [공격 페이즈: 남은 손패에서 2장 → 섯다 판정 → 최종 데미지]

local Signal = require("lib.signal")
local Enums = require("src.cards.card_enums")
local SeotdaChallenge = require("src.combat.seotda_challenge")

local Phase = {
    SelectCards = "select_cards",   -- 시너지 페이즈: 1~5장 선택
    GoStopChoice = "go_stop_choice",-- 고/스톱 선택
    AttackSelect = "attack_select", -- 공격 페이즈: 2장 선택
    RoundEnd = "round_end",         -- 라운드 종료
}

local RoundManager = {}
RoundManager.__index = RoundManager
RoundManager.Phase = Phase

--- 생성자
--- @param player PlayerState
--- @param deck_manager DeckManager
--- @param talisman_manager TalismanManager (optional)
--- @param boss_manager BossManager (optional)
--- @param upgrades table (optional) — { get_bonus_chips(), get_bonus_mult(), get_bonus_hand_size() }
function RoundManager.new(player, deck_manager, talisman_manager, boss_manager, upgrades)
    return setmetatable({
        -- 의존성
        _player = player,
        _deck_manager = deck_manager,
        _talisman_manager = talisman_manager,
        _boss_manager = boss_manager,
        _upgrades = upgrades,

        -- 현재 상태
        current_phase = Phase.RoundEnd,
        hand_cards = {},
        accumulated_combos = {},
        accumulated_mult = 1,
        accumulated_chips = 0,
        go_count = 0,
        max_plays = 5,
        plays_used = 0,

        -- 축복 효과
        blessing_hand_penalty = 0,
        blessing_chip_bonus = 0,
        blessing_mult_bonus = 0,

        -- 시그널
        on_phase_changed = Signal.new(),       -- (phase)
        on_combos_evaluated = Signal.new(),    -- (combos)
        on_round_ended = Signal.new(),         -- (won)
        on_message = Signal.new(),             -- (message)
    }, RoundManager)
end

--- 라운드 시작: 덱 초기화 → 손패 분배
function RoundManager:start_round(target_score)
    self.go_count = 0
    self.plays_used = 0
    self.accumulated_combos = {}

    -- 기본값에 영구강화 + 웨이브 강화 반영
    local perm_chips = self._upgrades and self._upgrades.get_bonus_chips and self._upgrades:get_bonus_chips() or 0
    local perm_mult = self._upgrades and self._upgrades.get_bonus_mult and self._upgrades:get_bonus_mult() or 0
    self.accumulated_chips = perm_chips + self._player.wave_chip_bonus
    self.accumulated_mult = 1 + perm_mult + self._player.wave_mult_bonus

    self._player:reset_for_new_round()
    self._deck_manager:initialize_deck()

    -- 손패 크기 결정
    local hand_size = 10
    if self._upgrades and self._upgrades.get_bonus_hand_size then
        hand_size = hand_size + self._upgrades:get_bonus_hand_size()
    end
    if self._player.next_round_hand_bonus > 0 then
        hand_size = hand_size + self._player.next_round_hand_bonus
        self._player.next_round_hand_bonus = 0
    end
    if self.blessing_hand_penalty > 0 then
        hand_size = math.max(5, hand_size - self.blessing_hand_penalty)
    end

    -- 바닥패 없이 손패만 분배
    self._deck_manager:deal_cards(self._player, hand_size, 0)

    -- 손패를 로컬 참조에 동기화
    self.hand_cards = self._player.hand

    -- 부적 트리거: 라운드 시작
    if self._talisman_manager then
        self._talisman_manager:notify_trigger(self._player, "on_round_start", nil)
    end

    -- 보스 기믹: 라운드 시작 시
    if self._boss_manager then
        self._boss_manager:on_turn_start(self._player, self._deck_manager)
    end

    self.on_message:emit(string.format("손패 %d장 배분! 카드를 선택하여 '내기!'", #self.hand_cards))
    self:_set_phase(Phase.SelectCards)
end

--- 시너지 페이즈: 카드 선택 → "내기!" → 콤보 판정 → 스택
--- @param selected table<CardInstance> 선택된 카드 목록
--- @param hand_evaluator table — { evaluate(cards), get_total_score(combos) }
--- @return table<ComboResult>
function RoundManager:submit_cards(selected, hand_evaluator)
    if self.current_phase ~= Phase.SelectCards then
        return {}
    end

    if not selected or #selected == 0 then
        return {}
    end

    -- 공격용 2장은 남겨야 함
    if #self.hand_cards - #selected < 2 then
        self.on_message:emit("공격용 카드 2장은 남겨야 한다!")
        return {}
    end

    -- 선택된 카드가 모두 손패에 있는지 확인
    for _, card in ipairs(selected) do
        local found = false
        for _, hc in ipairs(self.hand_cards) do
            if hc == card then found = true; break end
        end
        if not found then return {} end
    end

    -- 콤보 판정 (hand_evaluator 주입)
    local combos = {}
    if hand_evaluator and hand_evaluator.evaluate then
        combos = hand_evaluator.evaluate(selected)
    end

    -- 광 무효화 기믹: 광 관련 콤보 제거 (염라대왕)
    if self._boss_manager and self._boss_manager:is_gwang_disabled() then
        local filtered = {}
        for _, c in ipairs(combos) do
            local dominated = false
            if c.id then
                if string.find(c.id, "gwang") or c.id == "ogwang" or c.id == "samgwang" or
                   c.id == "bigwang" or c.id == "38gwangttaeng" or c.id == "18gwangttaeng" or
                   c.id == "13gwangttaeng" then
                    dominated = true
                end
            end
            if not dominated then
                table.insert(filtered, c)
            end
        end
        combos = filtered
        if #combos == 0 then
            self.on_message:emit("염라대왕의 기세에 광 족보가 봉인되었다!")
        end
    end

    -- 축복 보너스 적용
    if self.blessing_chip_bonus > 0 or self.blessing_mult_bonus > 0 then
        for _, combo in ipairs(combos) do
            combo.chips = combo.chips + math.floor(combo.chips * self.blessing_chip_bonus)
            combo.mult = combo.mult * (1 + self.blessing_mult_bonus)
        end
    end

    -- 이전 턴의 보류 회복 적용
    if self._player.pending_heal_combo and self._player.pending_heal_amount > 0 then
        local heal = self._player.pending_heal_amount
        self._player.lives = math.min(self._player.lives + heal, self._player.MAX_LIVES)
        self.on_message:emit(string.format("[%s] 유지 성공! 체력 +%d 회복! (%d/%d)",
            self._player.pending_heal_combo, heal, self._player.lives, self._player.MAX_LIVES))
        self._player.pending_heal_combo = nil
        self._player.pending_heal_amount = 0
    end

    -- 누적
    for _, c in ipairs(combos) do
        table.insert(self.accumulated_combos, c)
    end

    -- 점수 합산
    if hand_evaluator and hand_evaluator.get_total_score then
        local chips, mult = hand_evaluator.get_total_score(combos)
        self.accumulated_chips = self.accumulated_chips + chips
        self.accumulated_mult = self.accumulated_mult * mult
    end

    -- 회복 족보 대기 등록
    for _, combo in ipairs(combos) do
        if combo.heal_amount and combo.heal_amount > 0 and combo.heal_requires_hold then
            self._player.pending_heal_combo = combo.name_kr
            self._player.pending_heal_amount = combo.heal_amount
            self.on_message:emit(string.format("[%s] 다음 내기까지 유지하면 체력 +%d 회복!",
                combo.name_kr, combo.heal_amount))
            break
        end
    end

    -- 선택한 카드 소모
    for _, card in ipairs(selected) do
        for i, hc in ipairs(self.hand_cards) do
            if hc == card then
                table.remove(self.hand_cards, i)
                break
            end
        end
    end

    self.plays_used = self.plays_used + 1

    -- 부적 트리거
    if self._talisman_manager then
        self._talisman_manager:notify_trigger(self._player, "on_card_played", selected[1])
        if #combos > 0 then
            self._talisman_manager:notify_trigger(self._player, "on_yokbo_complete", selected[1])
        end
    end

    -- 메시지
    if #combos > 0 then
        local names = {}
        for _, c in ipairs(combos) do table.insert(names, c.name_kr or "?") end
        self.on_message:emit(string.format("내기! -> %s", table.concat(names, " + ")))
        self.on_message:emit(string.format("  누적: 칩 %d x 배수 %.1f",
            self.accumulated_chips, self.accumulated_mult))
    else
        self.on_message:emit("내기! -> 콤보 없음...")
    end

    self.on_combos_evaluated:emit(combos)

    -- 다음 상태 결정
    if #self.hand_cards < 2 then
        self.on_message:emit("손패 부족! 공격 없이 판이 끝난다!")
        self:_set_phase(Phase.AttackSelect)
    elseif self.plays_used >= self.max_plays then
        self.on_message:emit("내기 완료! 공격할 2장을 골라라!")
        self:_set_phase(Phase.AttackSelect)
    elseif #self.accumulated_combos > 0 then
        self:_set_phase(Phase.GoStopChoice)
    else
        self.on_message:emit("콤보 없음... 카드를 더 선택하여 내기!")
        self:_set_phase(Phase.SelectCards)
    end

    return combos
end

--- "고!" 선택: 추가 드로우 + 보스 반격 데미지 반환
function RoundManager:select_go()
    if self.current_phase ~= Phase.GoStopChoice then
        return 0
    end

    self.go_count = self.go_count + 1
    self._player.go_count = self.go_count

    local draw_count, boss_damage, go_message

    if self.go_count == 1 then
        draw_count = 3
        boss_damage = 0
        go_message = "고 1회! +3장, 배수 x1.5!"
    elseif self.go_count == 2 then
        draw_count = 2
        boss_damage = 5
        go_message = "고 2회! +2장, 배수 x2! 보스 반격!"
    else -- 3+
        draw_count = 1
        boss_damage = 10
        go_message = "고 3회! +1장, 배수 x3! 즉사 위험!"
    end

    -- 드로우
    for _ = 1, draw_count do
        local drawn = self._deck_manager:draw_from_pile()
        if drawn then
            table.insert(self.hand_cards, drawn)
        end
    end

    -- 부적 트리거
    if self._talisman_manager then
        self._talisman_manager:notify_trigger(self._player, "on_go_decision", nil)
    end

    self.on_message:emit(go_message)
    self.on_message:emit(string.format("  손패: %d장", #self.hand_cards))

    -- 시너지 페이즈로 복귀
    self:_set_phase(Phase.SelectCards)

    return boss_damage
end

--- "스톱!" 선택: 공격 페이즈로 전환
function RoundManager:select_stop()
    if self.current_phase ~= Phase.GoStopChoice then
        return
    end

    -- 부적 트리거
    if self._talisman_manager then
        self._talisman_manager:notify_trigger(self._player, "on_stop_decision", nil)
    end

    self.on_message:emit("스톱! 공격할 2장을 골라라!")
    self.on_message:emit(string.format("  누적 시너지: 칩 %d x 배수 %.1f",
        self.accumulated_chips, self.accumulated_mult))

    self:_set_phase(Phase.AttackSelect)
end

--- 공격 페이즈: 남은 손패에서 2장 선택 → 섯다 판정 → 최종 데미지
--- @return table { seotda_name, seotda_rank, base_damage, accumulated_chips, accumulated_mult, go_mult, final_damage, combos }
function RoundManager:execute_attack(card1, card2)
    local empty_result = {
        seotda_name = "",
        seotda_rank = 0,
        base_damage = 0,
        accumulated_chips = 0,
        accumulated_mult = 0,
        go_mult = 0,
        final_damage = 0,
        combos = {},
    }

    if self.current_phase ~= Phase.AttackSelect then
        return empty_result
    end

    if not card1 or not card2 then
        return empty_result
    end

    -- 손패에 있는지 확인
    local idx1, idx2 = nil, nil
    for i, c in ipairs(self.hand_cards) do
        if c == card1 then idx1 = i end
        if c == card2 then idx2 = i end
    end
    if not idx1 or not idx2 then return empty_result end
    if card1 == card2 then return empty_result end

    -- 광 무효화 기믹 체크 (염라대왕)
    if self._boss_manager and self._boss_manager:is_gwang_disabled() then
        if card1.card_type == Enums.CardType.Gwang or card2.card_type == Enums.CardType.Gwang then
            self.on_message:emit("염라대왕의 기세에 광이 봉인되었다! 광 카드로 공격 불가!")
            return empty_result
        end
    end

    -- 섯다 족보 판정
    local seotda = SeotdaChallenge.evaluate(card1, card2)

    -- 섯다 기본 데미지
    local base_damage = SeotdaChallenge.base_damage(seotda.rank)

    -- 고 배수
    local go_mult = 1
    if self.go_count == 1 then go_mult = 1.5
    elseif self.go_count == 2 then go_mult = 2
    elseif self.go_count >= 3 then go_mult = 3
    end

    -- 부적 효과: 공격 시 칩/배수 보너스
    local talisman_chips = 0
    local talisman_mult = 1
    if self._talisman_manager and self._talisman_manager.apply_talisman_effects then
        local talisman_result = self._talisman_manager:apply_talisman_effects(
            self._player,
            { chips = 0, mult = 1, final_score = 0 },
            "on_stop_decision")
        talisman_chips = talisman_result.chips
        if talisman_result.mult > 1 then
            talisman_mult = talisman_result.mult
        end
    end

    -- 최종 데미지 = (섯다 기본 + 누적 칩 + 부적 칩) x 누적 배수 x 부적 배수 x 고 배수
    local raw_damage = (base_damage + self.accumulated_chips + talisman_chips)
        * self.accumulated_mult * talisman_mult * go_mult
    local final_damage = math.floor(math.min(raw_damage, 2147483647))

    -- 카드 소모 (큰 인덱스부터 제거)
    if idx1 > idx2 then
        table.remove(self.hand_cards, idx1)
        table.remove(self.hand_cards, idx2)
    else
        table.remove(self.hand_cards, idx2)
        table.remove(self.hand_cards, idx1)
    end

    local combo_names = {}
    for _, c in ipairs(self.accumulated_combos) do
        table.insert(combo_names, c.name_kr or "?")
    end

    local result = {
        seotda_name = seotda.name,
        seotda_rank = seotda.rank,
        base_damage = base_damage,
        accumulated_chips = self.accumulated_chips,
        accumulated_mult = self.accumulated_mult,
        go_mult = go_mult,
        final_damage = final_damage,
        combos = combo_names,
    }

    self.on_message:emit(string.format("[%s] 기본 %d + 칩 %d",
        seotda.name, base_damage, self.accumulated_chips))
    self.on_message:emit(string.format("  x 시너지 %.1f x 고 %.0f = %d 타격!",
        self.accumulated_mult, go_mult, final_damage))

    return result
end

--- 라운드 종료 처리
function RoundManager:finish_round(won)
    -- 부적 트리거: 라운드 종료
    if self._talisman_manager then
        self._talisman_manager:notify_trigger(self._player, "on_round_end", nil)
    end

    self:_set_phase(Phase.RoundEnd)
    self.on_round_ended:emit(won)
end

--- 현재 Go 리스크 정보 (UI 표시용)
function RoundManager:get_current_go_risk()
    local next_go = self.go_count + 1
    if next_go == 1 then
        return {
            draw_cards = 3, boss_damage = 0,
            description = "고 1: +3장 드로우, 배수 x1.5",
            instant_death_risk = false,
        }
    elseif next_go == 2 then
        return {
            draw_cards = 2, boss_damage = 5,
            description = "고 2: +2장 드로우, 배수 x2, 보스 반격!",
            instant_death_risk = false,
        }
    else
        return {
            draw_cards = 1, boss_damage = 10,
            description = "고 3: +1장 드로우, 배수 x3, 즉사 위험!",
            instant_death_risk = true,
        }
    end
end

--- 불꽃 도깨비: 시너지 배수 보너스
function RoundManager:apply_flame_bonus()
    self.on_message:emit("불꽃 도깨비: 시너지 배수 +0.5!")
    self.accumulated_mult = self.accumulated_mult + 0.5
end

--- 그림자 도깨비: 칩 보너스 (목표 약화)
function RoundManager:apply_shadow_reduction()
    local bonus = math.floor(self.accumulated_chips * 0.15)
    if bonus < 10 then bonus = 10 end
    self.accumulated_chips = self.accumulated_chips + bonus
    self.on_message:emit(string.format("그림자 도깨비: 잠식! 칩 +%d (목표 약화)", bonus))
end

--- 뱃사공: 항해 배수 보너스
function RoundManager:apply_boatman_undo()
    self.accumulated_mult = self.accumulated_mult + 0.3
    self.on_message:emit("뱃사공: 항해! 시너지 배수 +0.3!")
end

--- 동료 도깨비 스킬: 손패 1장 교체
function RoundManager:companion_swap_card(hand_card)
    local found = false
    for i, c in ipairs(self.hand_cards) do
        if c == hand_card then
            table.remove(self.hand_cards, i)
            found = true
            break
        end
    end
    if not found then return false end

    local drawn = self._deck_manager:draw_from_pile()
    if not drawn then
        table.insert(self.hand_cards, hand_card)
        return false
    end

    self._deck_manager:return_to_pile(hand_card)
    table.insert(self.hand_cards, drawn)
    self.on_message:emit(string.format("교환: %s -> %s", hand_card.name_kr, drawn.name_kr))
    return true
end

--- 여우 도깨비 스킬: 다음 내기 와일드카드
function RoundManager:set_wild_card_next()
    self._player.wild_card_next_match = true
    self.on_message:emit("다음 내기는 와일드카드!")
end

-- ============================================================
-- 내부
-- ============================================================
function RoundManager:_set_phase(phase)
    self.current_phase = phase
    self.on_phase_changed:emit(phase)
end

return RoundManager

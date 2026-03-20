--- 보스 기믹 처리 매니저
--- Ported from BossManager.cs

local Signal = require("lib.signal")
local BossData = require("src.combat.boss_data")
local BossGimmick = BossData.BossGimmick

local BossManager = {}
BossManager.__index = BossManager

function BossManager.new()
    return setmetatable({
        current_boss = nil,
        turn_counter = 0,
        reflect_next = false,

        -- 재앙 보스용
        skull_count = 0,
        competitive_score = 0,

        -- 시그널
        on_boss_gimmick_triggered = Signal.new(), -- (message)
        on_player_killed = Signal.new(),           -- ()
    }, BossManager)
end

function BossManager:set_boss(boss_def)
    self.current_boss = boss_def
    self.turn_counter = 0
    self.skull_count = 0
    self.competitive_score = 0
end

function BossManager:clear_boss()
    self.current_boss = nil
    self.turn_counter = 0
end

function BossManager:is_boss_active()
    return self.current_boss ~= nil
end

function BossManager:is_calamity_boss()
    if not self.current_boss then return false end
    local g = self.current_boss.gimmick
    return g == BossGimmick.Skullify or g == BossGimmick.FakeCards or
           g == BossGimmick.Competitive or g == BossGimmick.Suppress
end

--- 턴 시작 시 기믹 체크 및 적용
function BossManager:on_turn_start(player, deck_manager)
    if not self.current_boss then return end

    self.turn_counter = self.turn_counter + 1

    if self.turn_counter % self.current_boss.gimmick_interval ~= 0 then
        return
    end

    -- 거울 도깨비 반사
    if self.reflect_next then
        self.reflect_next = false
        self.on_boss_gimmick_triggered:emit("거울 도깨비가 기믹을 반사했다!")
        return
    end

    local gimmick = self.current_boss.gimmick

    if gimmick == BossGimmick.ConsumeHighest then
        self:_apply_consume_highest(player)

    elseif gimmick == BossGimmick.ResetField then
        self:_apply_reset_field(deck_manager)

    elseif gimmick == BossGimmick.DisableTalisman then
        self:_apply_disable_talisman(player)

    elseif gimmick == BossGimmick.NoBright then
        -- Passive — handled in scoring

    elseif gimmick == BossGimmick.FlipAll then
        self.on_boss_gimmick_triggered:emit("장난꾸러기 도깨비가 패를 뒤집었다!")

    -- 재앙 보스 기믹
    elseif gimmick == BossGimmick.Skullify then
        self:_apply_skullify(player)

    elseif gimmick == BossGimmick.FakeCards then
        self:_apply_fake_cards(player)

    elseif gimmick == BossGimmick.Competitive then
        self.competitive_score = self.competitive_score + 50
        self.on_boss_gimmick_triggered:emit(
            string.format("이무기 점수: %d (+50)", self.competitive_score))

    elseif gimmick == BossGimmick.Suppress then
        self:_apply_suppression(player)
    end
end

--- 거울 도깨비 스킬: 다음 기믹 반사
function BossManager:reflect_next_mechanic()
    self.reflect_next = true
end

--- 광 무효화 체크 (염라대왕 기믹)
function BossManager:is_gwang_disabled()
    return self.current_boss ~= nil and self.current_boss.gimmick == BossGimmick.NoBright
end

-- ============================================================
-- 내부: 기믹 적용
-- ============================================================

--- 먹보 도깨비: 손패 중 최고가치 패 1장 소멸
function BossManager:_apply_consume_highest(player)
    if #player.hand == 0 then return end

    local highest = player.hand[1]
    for _, card in ipairs(player.hand) do
        if card.base_points > highest.base_points then
            highest = card
        end
    end

    -- 손패에서 제거
    for i, card in ipairs(player.hand) do
        if card == highest then
            table.remove(player.hand, i)
            break
        end
    end

    self.on_boss_gimmick_triggered:emit(
        string.format("먹보 도깨비가 %s을(를) 먹어치웠다!", highest.name_kr))
end

--- 불꽃 도깨비: 바닥패 전체 리셋
function BossManager:_apply_reset_field(deck_manager)
    -- 바닥패를 모두 제거
    local field_cards = {}
    for _, card in ipairs(deck_manager.field_cards) do
        table.insert(field_cards, card)
    end
    for _, card in ipairs(field_cards) do
        deck_manager:remove_from_field(card)
    end

    -- 뽑기패에서 새 바닥패 배치
    local new_field_count = math.min(8, #deck_manager.draw_pile)
    for _ = 1, new_field_count do
        local drawn = deck_manager:draw_from_pile()
        if drawn then
            deck_manager:add_to_field(drawn)
        end
    end

    self.on_boss_gimmick_triggered:emit(
        "불꽃 도깨비가 바닥패를 불태웠다! 새 패가 깔렸다!")
end

--- 그림자 도깨비: 부적 1개 랜덤 비활성화
function BossManager:_apply_disable_talisman(player)
    local active = {}
    for _, t in ipairs(player.talismans) do
        if t.is_active then
            table.insert(active, t)
        end
    end
    if #active == 0 then return end

    local target = active[math.random(#active)]
    target.is_active = false

    self.on_boss_gimmick_triggered:emit(
        string.format("그림자 도깨비가 %s을(를) 봉인했다!", target.data.name_kr))
end

--- 백골대장: 손패 1장을 해골패로 변환 (제거). 3개 = 즉사.
function BossManager:_apply_skullify(player)
    if #player.hand == 0 then return end

    local idx = math.random(#player.hand)
    local skull = player.hand[idx]
    table.remove(player.hand, idx)
    self.skull_count = self.skull_count + 1

    self.on_boss_gimmick_triggered:emit(
        string.format("백골대장이 %s을(를) 해골로 만들었다! (%d/3)",
            skull.name_kr, self.skull_count))

    if self.skull_count >= 3 then
        player.lives = 0
        self.on_boss_gimmick_triggered:emit("해골이 3개 모였다... 즉사!")
        self.on_player_killed:emit()
    end
end

--- 구미호 왕: 가짜 카드 효과 — 손패 셔플 (랜덤 재배열)
function BossManager:_apply_fake_cards(player)
    if #player.hand == 0 then return end

    -- Fisher-Yates 셔플
    for i = #player.hand, 2, -1 do
        local j = math.random(1, i)
        player.hand[i], player.hand[j] = player.hand[j], player.hand[i]
    end

    self.on_boss_gimmick_triggered:emit("구미호 왕이 손패를 뒤섞었다!")
end

--- 저승꽃: 부적 셔플 (랜덤 비활성/활성 전환)
function BossManager:_apply_suppression(player)
    -- 부적 1개 랜덤 비활성
    local active = {}
    for _, t in ipairs(player.talismans) do
        if t.is_active then table.insert(active, t) end
    end
    if #active > 0 then
        active[math.random(#active)].is_active = false
        self.on_boss_gimmick_triggered:emit("저승꽃이 부적을 억누른다...")
    end

    -- 비활성 1개 랜덤 활성 (셔플 효과)
    local inactive = {}
    for _, t in ipairs(player.talismans) do
        if not t.is_active then table.insert(inactive, t) end
    end
    if #inactive > 0 then
        inactive[math.random(#inactive)].is_active = true
    end
end

return BossManager

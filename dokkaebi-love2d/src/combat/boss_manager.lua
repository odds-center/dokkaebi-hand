--- 보스 기믹 처리 매니저
--- Ported from BossManager.cs

local Signal = require("lib.signal")
local BossData = require("src.combat.boss_data")
local BossGimmick = BossData.BossGimmick
local CardType = require("src.cards.card_enums").CardType

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

        -- 저주 기믹
        curse_count = 0,

        -- 저승시계 기믹: 판당 내기 횟수 감소
        time_pressure_penalty = 0,   -- start_round 시 적용 후 초기화

        -- 거울 기믹: 다음 내기 칩 30% 흡수
        mirror_debuff_active = false,

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
    self.curse_count = 0
    self.time_pressure_penalty = 0
    self.mirror_debuff_active = false
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

    elseif gimmick == BossGimmick.FlipAll then
        self:_apply_flip_all(player)

    elseif gimmick == BossGimmick.ResetField then
        self:_apply_reset_field(deck_manager)

    elseif gimmick == BossGimmick.DisableTalisman then
        self:_apply_disable_talisman(player)

    elseif gimmick == BossGimmick.NoBright then
        -- Passive — handled in scoring

    elseif gimmick == BossGimmick.StealCard then
        self:_apply_steal_card(player)

    elseif gimmick == BossGimmick.CurseMark then
        self:_apply_curse_mark(player)

    elseif gimmick == BossGimmick.TimePressure then
        self:_apply_time_pressure()

    elseif gimmick == BossGimmick.MirrorCopy then
        self:_apply_mirror_copy()

    elseif gimmick == BossGimmick.Fog then
        self:_apply_fog(player)

    elseif gimmick == BossGimmick.PoisonPi then
        self:_apply_poison_pi(player)

    -- 재앙 보스 기믹
    elseif gimmick == BossGimmick.Skullify then
        self:_apply_skullify(player)

    elseif gimmick == BossGimmick.FakeCards then
        self:_apply_fake_cards(player)

    elseif gimmick == BossGimmick.Competitive then
        self.competitive_score = self.competitive_score + 50
        self.on_boss_gimmick_triggered:emit(
            string.format("이무기 점수: %d (+50) — 이무기가 앞서면 패배!", self.competitive_score))

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

--- 저승시계 패널티 반환 후 초기화 (start_round에서 1회 소비)
function BossManager:consume_time_pressure_penalty()
    local penalty = self.time_pressure_penalty
    self.time_pressure_penalty = 0
    return penalty
end

--- 거울 기믹 디버프 소비 (submit_cards에서 1회 적용)
function BossManager:consume_mirror_debuff()
    if self.mirror_debuff_active then
        self.mirror_debuff_active = false
        return true
    end
    return false
end

--- 이무기 경쟁 점수 vs 플레이어 데미지 비교 (판 종료 시 체크)
--- player_damage: 이번 판 플레이어가 가한 총 데미지
function BossManager:check_competitive(player, player_damage)
    if self.competitive_score > player_damage then
        player.lives = player.lives - 1
        self.on_boss_gimmick_triggered:emit(
            string.format("이무기가 이겼다! (이무기:%d vs 플레이어:%d) 목숨 -1!",
                self.competitive_score, player_damage))
    else
        self.on_boss_gimmick_triggered:emit(
            string.format("이무기를 앞질렀다! (플레이어:%d vs 이무기:%d)",
                player_damage, self.competitive_score))
    end
    self.competitive_score = 0
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

    for i, card in ipairs(player.hand) do
        if card == highest then
            table.remove(player.hand, i)
            break
        end
    end

    self.on_boss_gimmick_triggered:emit(
        string.format("먹보 도깨비가 %s을(를) 먹어치웠다!", highest.name_kr))
end

--- 장난꾸러기 도깨비: 손패 셔플 + 뒤집기 표시
function BossManager:_apply_flip_all(player)
    if #player.hand == 0 then return end

    -- Fisher-Yates 셔플
    for i = #player.hand, 2, -1 do
        local j = math.random(1, i)
        player.hand[i], player.hand[j] = player.hand[j], player.hand[i]
    end
    -- 한 턴 동안 카드 앞면 숨김 표시
    for _, card in ipairs(player.hand) do
        card.is_flipped = true
    end

    self.on_boss_gimmick_triggered:emit(
        "장난꾸러기 도깨비가 패를 뒤집었다! 다음 내기까지 패를 볼 수 없다!")
end

--- 불꽃 도깨비: 바닥패 전체 리셋
function BossManager:_apply_reset_field(deck_manager)
    local field_cards = {}
    for _, card in ipairs(deck_manager.field_cards) do
        table.insert(field_cards, card)
    end
    for _, card in ipairs(field_cards) do
        deck_manager:remove_from_field(card)
    end

    local new_field_count = math.min(8, #deck_manager.draw_pile)
    for _ = 1, new_field_count do
        local drawn = deck_manager:draw_from_pile()
        if drawn then deck_manager:add_to_field(drawn) end
    end

    self.on_boss_gimmick_triggered:emit(
        "불꽃 도깨비가 바닥패를 불태웠다! 새 패가 깔렸다!")
end

--- 그림자 도깨비: 부적 1개 랜덤 비활성화
function BossManager:_apply_disable_talisman(player)
    local active = {}
    for _, t in ipairs(player.talismans) do
        if t.is_active then table.insert(active, t) end
    end
    if #active == 0 then return end

    local target = active[math.random(#active)]
    target.is_active = false

    self.on_boss_gimmick_triggered:emit(
        string.format("그림자 도깨비가 [%s]을(를) 봉인했다!", target.data.name_kr))
end

--- 도둑 도깨비: 손패 중 랜덤 1장 빼앗기
function BossManager:_apply_steal_card(player)
    if #player.hand == 0 then return end

    local idx = math.random(#player.hand)
    local stolen = player.hand[idx]
    table.remove(player.hand, idx)

    self.on_boss_gimmick_triggered:emit(
        string.format("도둑 도깨비가 [%s]을(를) 훔쳐갔다!", stolen.name_kr))
end

--- 원귀: 저주 표식 누적 — 3개 = 즉사
function BossManager:_apply_curse_mark(player)
    self.curse_count = self.curse_count + 1

    self.on_boss_gimmick_triggered:emit(
        string.format("원귀가 저주 표식을 새겼다! (%d/3)", self.curse_count))

    if self.curse_count >= 3 then
        player.lives = 0
        self.on_boss_gimmick_triggered:emit("저주가 셋 쌓였다... 즉사!")
        self.on_player_killed:emit()
    end
end

--- 저승시계: 이번 판 내기 횟수 -2
function BossManager:_apply_time_pressure()
    self.time_pressure_penalty = 2
    self.on_boss_gimmick_triggered:emit(
        "저승시계가 울렸다! 이번 판 내기 횟수가 2 줄었다!")
end

--- 거울 도깨비: 다음 내기에서 칩 30% 흡수
function BossManager:_apply_mirror_copy()
    self.mirror_debuff_active = true
    self.on_boss_gimmick_triggered:emit(
        "거울 도깨비가 족보를 복사할 준비를 한다! 다음 내기 칩 30% 흡수!")
end

--- 안개 도깨비: 손패 중 3장을 안개로 가림 (내기 시 칩 -50%)
function BossManager:_apply_fog(player)
    if #player.hand == 0 then return end

    -- 기존 안개 표시 초기화
    for _, card in ipairs(player.hand) do
        card.is_fogged = false
    end

    -- 최대 3장 랜덤 선택
    local indices = {}
    for i = 1, #player.hand do indices[i] = i end
    for i = #indices, 2, -1 do
        local j = math.random(1, i)
        indices[i], indices[j] = indices[j], indices[i]
    end

    local fog_count = math.min(3, #player.hand)
    for i = 1, fog_count do
        player.hand[indices[i]].is_fogged = true
    end

    self.on_boss_gimmick_triggered:emit(
        string.format("안개 도깨비가 패 %d장을 안개로 덮었다! 그 패는 칩이 반감된다!", fog_count))
end

--- 독사 도깨비: 손패의 피 카드에 독 부여 (내기 시 칩 -10/장)
function BossManager:_apply_poison_pi(player)
    local count = 0
    for _, card in ipairs(player.hand) do
        if card.card_type == CardType.Pi then
            card.is_poisoned = true
            count = count + 1
        end
    end

    if count > 0 then
        self.on_boss_gimmick_triggered:emit(
            string.format("독사 도깨비가 피 패 %d장에 독을 발랐다! 독 피 패 사용 시 칩 -10/장!", count))
    else
        self.on_boss_gimmick_triggered:emit("독사 도깨비가 독을 뿌렸지만 피 패가 없다!")
    end
end

--- 백골대장: 손패 1장을 해골패로 변환 — 3개 = 즉사
function BossManager:_apply_skullify(player)
    if #player.hand == 0 then return end

    local idx = math.random(#player.hand)
    local skull = player.hand[idx]
    table.remove(player.hand, idx)
    self.skull_count = self.skull_count + 1

    self.on_boss_gimmick_triggered:emit(
        string.format("백골대장이 [%s]을(를) 해골로 만들었다! (%d/3)",
            skull.name_kr, self.skull_count))

    if self.skull_count >= 3 then
        player.lives = 0
        self.on_boss_gimmick_triggered:emit("해골이 3개 모였다... 즉사!")
        self.on_player_killed:emit()
    end
end

--- 구미호 왕: 손패 중 3장을 가짜 카드로 만들기 (섯다 판정 시 점수 0)
function BossManager:_apply_fake_cards(player)
    if #player.hand == 0 then return end

    -- 기존 가짜 표시 초기화
    for _, card in ipairs(player.hand) do
        card.is_fake = false
    end

    -- 최대 3장 랜덤 선택
    local indices = {}
    for i = 1, #player.hand do indices[i] = i end
    for i = #indices, 2, -1 do
        local j = math.random(1, i)
        indices[i], indices[j] = indices[j], indices[i]
    end

    local fake_count = math.min(3, #player.hand)
    for i = 1, fake_count do
        player.hand[indices[i]].is_fake = true
    end

    self.on_boss_gimmick_triggered:emit(
        string.format("구미호 왕이 패 %d장을 가짜로 만들었다! 가짜 패로 공격하면 데미지 0!", fake_count))
end

--- 저승꽃: 부적 셔플 (랜덤 비활성/활성 전환)
function BossManager:_apply_suppression(player)
    local active = {}
    for _, t in ipairs(player.talismans) do
        if t.is_active then table.insert(active, t) end
    end
    if #active > 0 then
        active[math.random(#active)].is_active = false
        self.on_boss_gimmick_triggered:emit("저승꽃이 부적을 억누른다...")
    end

    local inactive = {}
    for _, t in ipairs(player.talismans) do
        if not t.is_active then table.insert(inactive, t) end
    end
    if #inactive > 0 then
        inactive[math.random(#inactive)].is_active = true
    end
end

return BossManager

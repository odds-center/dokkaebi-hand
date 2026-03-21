--- 보스 전투 시스템: HP 기반 전투
--- Ported from BossBattle.cs
---
--- 전투 흐름:
--- 1. 보스 HP 표시
--- 2. 고스톱 매칭으로 패를 모은다
--- 3. 족보 완성 → 스톱하면 보스에게 타격 (점x배 = 데미지)
--- 4. 보스 반격 (기믹 발동 + 데미지)
--- 5. 보스 HP 0 이하 → 관문 돌파
--- 6. 내 목숨 0 → 저승에 가라앉다

local Signal = require("lib.signal")
local NumberFormatter = require("src.core.number_formatter")
local BossData = require("src.combat.boss_data")
local BossGimmick = BossData.BossGimmick

local BossBattle = {}
BossBattle.__index = BossBattle

function BossBattle.new(boss_def, spiral_number)
    -- HP = TargetScore * 1.4^(spiral-1)  (완화: 1.5→1.4)
    local spiral_mult = math.pow(1.4, spiral_number - 1)
    local max_hp = math.floor(boss_def.target_score * spiral_mult)

    -- 반격 데미지 (기믹 유형별)
    local attack_damage = 0
    if boss_def.gimmick == BossGimmick.ConsumeHighest or
       boss_def.gimmick == BossGimmick.Skullify then
        attack_damage = 1
    end

    local self = setmetatable({
        boss_def = boss_def,
        spiral_number = spiral_number,

        boss_max_hp = max_hp,
        boss_current_hp = max_hp,
        boss_attack_damage = attack_damage,

        -- 보스 반격 페널티
        counter_chip_penalty = 0,
        counter_hand_penalty = 0,

        -- 시그널
        on_boss_damaged = Signal.new(),       -- (damage)
        on_player_damaged = Signal.new(),     -- (damage)
        on_boss_defeated = Signal.new(),      -- ()
        on_boss_counter_attack = Signal.new(),-- (message)
        on_player_killed = Signal.new(),      -- ()
    }, BossBattle)

    return self
end

function BossBattle:is_boss_defeated()
    return self.boss_current_hp <= 0
end

--- 플레이어가 스톱 → 족보 데미지로 보스 HP 깎기
function BossBattle:deal_damage(final_score)
    local damage = final_score
    self.boss_current_hp = self.boss_current_hp - damage

    self.on_boss_damaged:emit(damage)

    if self.boss_current_hp <= 0 then
        self.boss_current_hp = 0
        self.on_boss_defeated:emit()
    end

    return damage
end

--- 보스 반격 (매 판 종료 후)
function BossBattle:boss_counter_attack(player)
    self.counter_chip_penalty = 0
    self.counter_hand_penalty = 0

    local message = ""
    local hp_ratio = self:get_hp_ratio()

    if hp_ratio < 0.3 then
        message = self:_boss_rage_attack(player)
    elseif hp_ratio < 0.6 then
        message = self:_boss_anger_attack(player)
    else
        message = self:_boss_light_attack(player)
    end

    self.on_boss_counter_attack:emit(message)
    return message
end

--- HP 바 표시용 (0.0~1.0)
function BossBattle:get_hp_ratio()
    if self.boss_max_hp <= 0 then return 0 end
    return self.boss_current_hp / self.boss_max_hp
end

--- HP 바 텍스트
function BossBattle:get_hp_display()
    return string.format("HP %s/%s",
        NumberFormatter.format(self.boss_current_hp),
        NumberFormatter.format(self.boss_max_hp))
end

-- ============================================================
-- 내부: 반격 단계별
-- ============================================================

--- 여유 상태 → 가벼운 방해
function BossBattle:_boss_light_attack(player)
    local roll = math.random(0, 2)

    if roll == 0 then
        -- 조롱 (효과 없음)
        local gimmick = self.boss_def.gimmick
        if gimmick == BossGimmick.ConsumeHighest then
            return "크하하! 배고프다~"
        elseif gimmick == BossGimmick.FlipAll then
            return "히히, 어디 한번 맞춰봐~"
        elseif gimmick == BossGimmick.NoBright then
            return "광이 뭐가 대수냐?"
        else
            return "흥, 이 정도로는..."
        end
    elseif roll == 1 then
        -- 다음 판 점 -10%
        self.counter_chip_penalty = 10
        return "도깨비가 바닥을 내리쳤다! (다음 판 점 -10%)"
    else
        return "도깨비가 코를 킁킁댄다..."
    end
end

--- 피 60% 미만 → 짜증 상태
function BossBattle:_boss_anger_attack(player)
    local roll = math.random(0, 2)

    if roll == 0 then
        -- 손패 1장 제거
        self.counter_hand_penalty = 1
        return "도깨비가 화가 났다! 손패 1장 빼앗김!"
    elseif roll == 1 then
        -- 다음 판 점 -20%
        self.counter_chip_penalty = 20
        return "도깨비가 발을 구른다! (다음 판 점 -20%)"
    else
        -- 엽전 도둑질
        local stolen = math.min(player.yeop, 15)
        player.yeop = player.yeop - stolen
        return string.format("도깨비가 엽전을 훔쳤다! (-%d냥)", stolen)
    end
end

--- 나선에 따른 보스 반격 강도 (1~5)
function BossBattle:_get_rage_damage(spiral_number)
    if spiral_number <= 3 then return 1 end
    if spiral_number <= 7 then return 2 end
    if spiral_number <= 15 then return 3 end
    if spiral_number <= 25 then return 4 end
    return 5
end

--- 피 30% 미만 → 광분 상태
function BossBattle:_boss_rage_attack(player)
    local roll = math.random(0, 2)

    if roll == 0 then
        -- 목숨 위협 (15% 확률, 나선 비례 피해)
        if math.random() < 0.15 then
            local dmg = self:_get_rage_damage(self.spiral_number)
            player.lives = math.max(0, player.lives - dmg)
            if player.lives <= 0 then
                self.on_player_killed:emit()
            end
            return string.format("도깨비가 미쳐 날뛴다!! 목숨 -%d!", dmg)
        end
        return "도깨비가 미친 듯이 날뛰지만... 피했다!"
    elseif roll == 1 then
        -- 손패 2장 제거
        self.counter_hand_penalty = 2
        return "도깨비가 광분한다!! 손패 2장 빼앗김!"
    else
        -- 다음 판 점 -30%
        self.counter_chip_penalty = 30
        return "도깨비의 기세가 바닥을 짓누른다! (다음 판 점 -30%)"
    end
end

return BossBattle

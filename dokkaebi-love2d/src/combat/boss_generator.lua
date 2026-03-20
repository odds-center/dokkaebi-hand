--- 보스 랜덤 생성기
--- Ported from BossGenerator.cs (simplified — no BossParts system yet)

local BossData = require("src.combat.boss_data")

local PartsSlot = {
    Head = "head",
    Arm = "arm",
    Body = "body",
}

local PartsRarity = {
    Common = 1,
    Rare = 2,
    Legendary = 3,
}

--- 간소화된 파츠 데이터
local BossPartData = {}
BossPartData.__index = BossPartData

function BossPartData.new(t)
    return setmetatable({
        id = t.id or "",
        name = t.name or "",
        name_kr = t.name_kr or "",
        slot = t.slot or PartsSlot.Head,
        rarity = t.rarity or PartsRarity.Common,
        description = t.description or "",
        set_id = t.set_id or nil,
        target_bonus_percent = t.target_bonus_percent or 0,
        talisman_effect_reduction = t.talisman_effect_reduction or 0,
    }, BossPartData)
end

--- 생성된 보스 인스턴스
local GeneratedBoss = {}
GeneratedBoss.__index = GeneratedBoss

function GeneratedBoss.new(t)
    return setmetatable({
        base_boss = t.base_boss,
        parts = t.parts or {},
        final_target_score = t.final_target_score or 0,
        display_name = t.display_name or "",
        spiral = t.spiral or 1,
        absolute_realm = t.absolute_realm or 1,
    }, GeneratedBoss)
end

function GeneratedBoss:has_set_bonus()
    local sets = {}
    for _, p in ipairs(self.parts) do
        if p.set_id then
            sets[p.set_id] = (sets[p.set_id] or 0) + 1
            if sets[p.set_id] >= 2 then return true end
        end
    end
    return false
end

function GeneratedBoss:get_total_talisman_reduction()
    local total = 0
    for _, p in ipairs(self.parts) do
        total = total + p.talisman_effect_reduction
    end
    return math.min(total, 0.9)
end

-- ============================================================
-- BossGenerator
-- ============================================================
local BossGenerator = {}
BossGenerator.__index = BossGenerator

function BossGenerator.new(seed)
    if seed then math.randomseed(seed) end
    return setmetatable({}, BossGenerator)
end

--- 랜덤 보스 생성 (simplified)
--- spiral_manager: { current_spiral, absolute_realm, get_target_score(base), get_parts_count(), get_min_parts_rarity() }
function BossGenerator:generate_random_boss(spiral_manager, base_target)
    base_target = base_target or 150

    local all_bosses = BossData.get_all_bosses()
    local base_boss = all_bosses[math.random(#all_bosses)]

    -- 기본 목표 점수 (나선 배수 적용)
    local target = base_target
    if spiral_manager and spiral_manager.get_target_score then
        target = spiral_manager:get_target_score(base_target)
    end

    -- 기믹 간격 변동 (+-1, 최소 1)
    local interval = math.max(1, base_boss.gimmick_interval + math.random(-1, 1))
    local rounds = math.max(2, base_boss.rounds + math.random(-1, 1))
    local yeop = base_boss.yeop_reward + math.random(-20, 29)

    -- 변이된 보스 정의
    local mutated = BossData.BossDefinition({
        id = base_boss.id,
        name = base_boss.name,
        name_kr = base_boss.name_kr,
        description = base_boss.description,
        target_score = target,
        rounds = rounds,
        gimmick = base_boss.gimmick,
        gimmick_interval = interval,
        intro_dialogue = base_boss.intro_dialogue,
        defeat_dialogue = base_boss.defeat_dialogue,
        victory_dialogue = base_boss.victory_dialogue,
        yeop_reward = yeop,
        drops_legendary_talisman = base_boss.drops_legendary_talisman,
    })

    local spiral_num = 1
    local realm_num = 1
    if spiral_manager then
        spiral_num = spiral_manager.current_spiral or 1
        realm_num = spiral_manager.absolute_realm or 1
    end

    return GeneratedBoss.new({
        base_boss = mutated,
        parts = {},
        final_target_score = target,
        display_name = mutated.name_kr,
        spiral = spiral_num,
        absolute_realm = realm_num,
    })
end

--- 스토리 보스 생성 (고정 도깨비)
function BossGenerator:generate_story_boss(realm_in_spiral, spiral_manager)
    local index = math.min(realm_in_spiral, #BossData.get_all_bosses())
    local base_boss = BossData.get_boss(index)

    local target = base_boss.target_score
    if spiral_manager and spiral_manager.get_target_score then
        target = spiral_manager:get_target_score(base_boss.target_score)
    end

    local spiral_num = 1
    local realm_num = 1
    if spiral_manager then
        spiral_num = spiral_manager.current_spiral or 1
        realm_num = spiral_manager.absolute_realm or 1
    end

    return GeneratedBoss.new({
        base_boss = base_boss,
        parts = {},
        final_target_score = target,
        display_name = base_boss.name_kr,
        spiral = spiral_num,
        absolute_realm = realm_num,
    })
end

-- Export
BossGenerator.PartsSlot = PartsSlot
BossGenerator.PartsRarity = PartsRarity
BossGenerator.BossPartData = BossPartData
BossGenerator.GeneratedBoss = GeneratedBoss

return BossGenerator

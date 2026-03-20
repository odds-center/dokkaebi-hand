--- 업적 관리 시스템
local Signal = require("lib.signal")

-- ============================================================
-- AchievementCategory enum
-- ============================================================
local AchievementCategory = {
    PROGRESS = "progress",
    YOKBO    = "yokbo",
    GO_STOP  = "go_stop",
    SPECIAL  = "special",
    HIDDEN   = "hidden",
}

-- ============================================================
-- 헬퍼: 업적 정의 생성
-- ============================================================
local function make_achievement(id, name_kr, name_en, description_kr, category, soul_reward, is_hidden)
    return {
        id             = id,
        name_kr        = name_kr,
        name_en        = name_en,
        description_kr = description_kr,
        category       = category,
        soul_reward    = soul_reward,
        is_hidden      = is_hidden or false,
    }
end

-- ============================================================
-- 전체 업적 목록
-- ============================================================
local function initialize_achievements()
    return {
        -- === 진행 ===
        make_achievement("first_step",      "첫 발걸음",     "First Step",          "1영역 클리어",         AchievementCategory.PROGRESS, 20),
        make_achievement("explorer",        "저승 탐험가",   "Explorer",            "5영역 클리어",         AchievementCategory.PROGRESS, 50),
        make_achievement("yeomra_judgment", "염라의 심판",   "Yeomra's Judgment",   "나선 1 완료 (10영역)", AchievementCategory.PROGRESS, 100),
        make_achievement("spiral_2",        "두 번째 윤회",  "Second Cycle",        "나선 2 돌입 (20영역)", AchievementCategory.PROGRESS, 200),
        make_achievement("spiral_5",        "저승의 전설",   "Underworld Legend",   "나선 5 돌입 (50영역)", AchievementCategory.PROGRESS, 500),
        make_achievement("spiral_10",       "무한의 끝",     "Edge of Infinity",    "나선 10 돌입 (100영역)", AchievementCategory.PROGRESS, 1000),
        make_achievement("tenth_death",     "열 번째 죽음",  "Tenth Death",         "10회 사망",            AchievementCategory.PROGRESS, 20),

        -- === 족보 ===
        make_achievement("three_gwang", "삼광 달성",   "Three Brights", "삼광 완성",             AchievementCategory.YOKBO, 30),
        make_achievement("four_gwang",  "사광 달성",   "Four Brights",  "사광 완성",             AchievementCategory.YOKBO, 50),
        make_achievement("five_gwang",  "오광 달성",   "Five Brights",  "오광 완성",             AchievementCategory.YOKBO, 100),
        make_achievement("score_10k",   "만점왕",      "10K Master",    "단일 라운드 10,000점",  AchievementCategory.YOKBO, 200),
        make_achievement("score_1m",    "백만장자",    "Millionaire",   "단일 라운드 1,000,000점", AchievementCategory.YOKBO, 500),

        -- === Go/Stop ===
        make_achievement("first_go",     "첫 Go",        "First Go",     "Go 1회 선택",      AchievementCategory.GO_STOP, 10),
        make_achievement("bold_choice",  "대담한 선택",   "Bold Choice",  "Go 2회 연속",      AchievementCategory.GO_STOP, 30),
        make_achievement("mad_gambler",  "미친 도박사",   "Mad Gambler",  "Go 3회 성공",      AchievementCategory.GO_STOP, 200),
        make_achievement("greed_price",  "욕심의 대가",   "Price of Greed", "Go 3회 실패 즉사", AchievementCategory.GO_STOP, 20),

        -- === 특수 ===
        make_achievement("no_talisman",  "무부적",       "No Talisman",   "부적 없이 나선 1 완료", AchievementCategory.SPECIAL, 200),
        make_achievement("curse_lover",  "저주 수용자",  "Curse Lover",   "저주 부적 3개 장착 클리어", AchievementCategory.SPECIAL, 150),
        make_achievement("nirvana_card", "해탈",         "Nirvana",       "카드 1장 해탈 등급 달성",  AchievementCategory.SPECIAL, 300),

        -- === 히든 ===
        make_achievement("boatman_talk", "???", "???", "뱃사공에게 5번 대화",      AchievementCategory.HIDDEN, 50,  true),
        make_achievement("zero_score",   "???", "???", "점수 0으로 라운드 종료",   AchievementCategory.HIDDEN, 10,  true),
        make_achievement("time_100h",    "???", "???", "총 플레이 시간 100시간",   AchievementCategory.HIDDEN, 0,   true),
    }
end

-- ============================================================
-- AchievementManager
-- ============================================================
local AchievementManager = {}
AchievementManager.__index = AchievementManager

function AchievementManager.new()
    local all = initialize_achievements()
    return setmetatable({
        _unlocked       = {},  -- set: id -> true
        _all_achievements = all,

        -- signals
        on_achievement_unlocked = Signal.new(),  -- (achievement_def)
    }, AchievementManager)
end

function AchievementManager:is_unlocked(id)
    return self._unlocked[id] == true
end

function AchievementManager:try_unlock(id)
    if self._unlocked[id] then return false end

    local def = nil
    for _, a in ipairs(self._all_achievements) do
        if a.id == id then def = a; break end
    end
    if not def then return false end

    self._unlocked[id] = true
    self.on_achievement_unlocked:emit(def)
    return true
end

function AchievementManager:get_unlocked_count()
    local count = 0
    for _ in pairs(self._unlocked) do count = count + 1 end
    return count
end

function AchievementManager:get_total_count()
    return #self._all_achievements
end

function AchievementManager:get_unlocked_ids()
    local ids = {}
    for id, _ in pairs(self._unlocked) do
        table.insert(ids, id)
    end
    return ids
end

function AchievementManager:load_unlocked(ids)
    self._unlocked = {}
    for _, id in ipairs(ids) do
        self._unlocked[id] = true
    end
end

function AchievementManager:get_all_achievements()
    return self._all_achievements
end

-- === 조건 체크 헬퍼 ===

function AchievementManager:check_progress(spiral_cleared, total_realms, deaths)
    if total_realms >= 1   then self:try_unlock("first_step") end
    if total_realms >= 5   then self:try_unlock("explorer") end
    if total_realms >= 10  then self:try_unlock("yeomra_judgment") end
    if total_realms >= 20  then self:try_unlock("spiral_2") end
    if total_realms >= 50  then self:try_unlock("spiral_5") end
    if total_realms >= 100 then self:try_unlock("spiral_10") end
    if deaths >= 10        then self:try_unlock("tenth_death") end
end

function AchievementManager:check_yokbo(yokbo_name, single_round_score)
    if yokbo_name and string.find(yokbo_name, "삼광") then self:try_unlock("three_gwang") end
    if yokbo_name and string.find(yokbo_name, "사광") then self:try_unlock("four_gwang") end
    if yokbo_name and string.find(yokbo_name, "오광") then self:try_unlock("five_gwang") end
    if single_round_score >= 10000   then self:try_unlock("score_10k") end
    if single_round_score >= 1000000 then self:try_unlock("score_1m") end
end

function AchievementManager:check_go(go_count, succeeded)
    if go_count >= 1 then self:try_unlock("first_go") end
    if go_count >= 2 then self:try_unlock("bold_choice") end
    if go_count >= 3 and succeeded     then self:try_unlock("mad_gambler") end
    if go_count >= 3 and not succeeded then self:try_unlock("greed_price") end
end

return {
    AchievementCategory = AchievementCategory,
    AchievementManager  = AchievementManager,
}

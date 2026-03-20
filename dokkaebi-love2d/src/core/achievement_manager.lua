--- 업적 관리 시스템
local Signal = require("lib.signal")

-- ============================================================
-- AchievementCategory enum
-- ============================================================
local AchievementCategory = {
    PROGRESS = "progress",
    YOKBO    = "yokbo",
    GO_STOP  = "go_stop",
    COMBAT   = "combat",
    COLLECT  = "collect",
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
-- 전체 업적 목록 (60개)
-- ============================================================
local function initialize_achievements()
    return {
        -- ═══════════════════════════════════════
        -- 진행 (12개)
        -- ═══════════════════════════════════════
        make_achievement("first_step",      "첫 발걸음",       "First Step",          "관문 1 돌파",                AchievementCategory.PROGRESS, 20),
        make_achievement("explorer",        "저승 탐험가",     "Explorer",            "관문 5 돌파",                AchievementCategory.PROGRESS, 50),
        make_achievement("yeomra_judgment", "염라의 심판",     "Yeomra's Judgment",   "윤회 1 완료 (관문 10)",      AchievementCategory.PROGRESS, 100),
        make_achievement("spiral_2",        "두 번째 윤회",    "Second Cycle",        "윤회 2 돌입",                AchievementCategory.PROGRESS, 200),
        make_achievement("spiral_3",        "삼세의 업보",     "Third Karma",         "윤회 3 돌입",                AchievementCategory.PROGRESS, 300),
        make_achievement("spiral_5",        "저승의 전설",     "Underworld Legend",   "윤회 5 돌입",                AchievementCategory.PROGRESS, 500),
        make_achievement("spiral_10",       "무한의 끝",       "Edge of Infinity",    "윤회 10 돌입",               AchievementCategory.PROGRESS, 1000),
        make_achievement("first_death",     "첫 번째 죽음",    "First Death",         "처음으로 사망",              AchievementCategory.PROGRESS, 5),
        make_achievement("tenth_death",     "열 번째 죽음",    "Tenth Death",         "10회 사망",                  AchievementCategory.PROGRESS, 20),
        make_achievement("fifty_death",     "오십 번의 윤회",  "Fifty Rebirths",      "50회 사망",                  AchievementCategory.PROGRESS, 100),
        make_achievement("hundred_death",   "백사백생",        "Hundred Lives",       "100회 사망",                 AchievementCategory.PROGRESS, 200),
        make_achievement("speed_clear",     "질풍같은 승리",   "Swift Victory",       "3판 이내로 보스 격파",       AchievementCategory.PROGRESS, 80),

        -- ═══════════════════════════════════════
        -- 족보 (15개)
        -- ═══════════════════════════════════════
        make_achievement("three_gwang",     "삼광 달성",       "Three Brights",       "삼광 완성",                  AchievementCategory.YOKBO, 30),
        make_achievement("four_gwang",      "사광 달성",       "Four Brights",        "사광 완성",                  AchievementCategory.YOKBO, 50),
        make_achievement("five_gwang",      "오광 달성",       "Five Brights",        "오광 완성",                  AchievementCategory.YOKBO, 100),
        make_achievement("hongdan",         "홍단 달성",       "Red Ribbon",          "홍단 완성",                  AchievementCategory.YOKBO, 20),
        make_achievement("cheongdan",       "청단 달성",       "Blue Ribbon",         "청단 완성",                  AchievementCategory.YOKBO, 20),
        make_achievement("chodan",          "초단 달성",       "Grass Ribbon",        "초단 완성",                  AchievementCategory.YOKBO, 20),
        make_achievement("all_dan",         "삼색단",          "Three Ribbons",       "홍단+청단+초단 한 판에 완성",AchievementCategory.YOKBO, 150),
        make_achievement("godori",          "고도리 달성",     "Godori",              "고도리 완성",                AchievementCategory.YOKBO, 30),
        make_achievement("38gwangttaeng",   "38광땡",          "38 Bright Pair",      "38광땡 완성",                AchievementCategory.YOKBO, 80),
        make_achievement("jangttaeng",      "장땡 달성",       "Jang Pair",           "장땡 완성",                  AchievementCategory.YOKBO, 40),
        make_achievement("score_10k",       "만점왕",          "10K Master",          "단일 라운드 10,000점",       AchievementCategory.YOKBO, 200),
        make_achievement("score_100k",      "십만대군",        "100K Army",           "단일 라운드 100,000점",      AchievementCategory.YOKBO, 350),
        make_achievement("score_1m",        "백만장자",        "Millionaire",         "단일 라운드 1,000,000점",    AchievementCategory.YOKBO, 500),
        make_achievement("combo_5",         "연환계",          "Chain Combo",         "한 판에 족보 5개 이상 등록", AchievementCategory.YOKBO, 60),
        make_achievement("combo_10",        "만화경",          "Kaleidoscope",        "한 판에 족보 10개 이상 등록",AchievementCategory.YOKBO, 200),

        -- ═══════════════════════════════════════
        -- 고/스톱 (8개)
        -- ═══════════════════════════════════════
        make_achievement("first_go",        "첫 고",           "First Go",            "고 1회 선택",                AchievementCategory.GO_STOP, 10),
        make_achievement("bold_choice",     "대담한 선택",     "Bold Choice",         "고 2회 연속",                AchievementCategory.GO_STOP, 30),
        make_achievement("mad_gambler",     "미친 도박사",     "Mad Gambler",         "고 3회 성공",                AchievementCategory.GO_STOP, 200),
        make_achievement("greed_price",     "욕심의 대가",     "Price of Greed",      "고 3회 실패 즉사",           AchievementCategory.GO_STOP, 20),
        make_achievement("stop_master",     "신중한 자",       "Careful One",         "10판 연속 스톱 선택",        AchievementCategory.GO_STOP, 40),
        make_achievement("go_10_total",     "도박꾼의 피",     "Gambler's Blood",     "누적 고 10회",               AchievementCategory.GO_STOP, 50),
        make_achievement("go_50_total",     "저승의 타짜",     "Underworld Hustler",  "누적 고 50회",               AchievementCategory.GO_STOP, 150),
        make_achievement("perfect_round",   "완벽한 한 판",    "Perfect Round",       "고 없이 한 판에 300점 이상", AchievementCategory.GO_STOP, 100),

        -- ═══════════════════════════════════════
        -- 전투 (10개)
        -- ═══════════════════════════════════════
        make_achievement("first_boss",      "첫 격파",         "First Kill",          "보스를 처음으로 격파",       AchievementCategory.COMBAT, 15),
        make_achievement("boss_10",         "도깨비 사냥꾼",   "Dokkaebi Hunter",     "보스 10마리 격파",           AchievementCategory.COMBAT, 80),
        make_achievement("boss_50",         "저승의 공포",     "Terror of the Dead",  "보스 50마리 격파",           AchievementCategory.COMBAT, 200),
        make_achievement("boss_100",        "만귀의 왕",       "King of Spirits",     "보스 100마리 격파",          AchievementCategory.COMBAT, 500),
        make_achievement("overkill",        "과잉 타격",       "Overkill",            "보스 HP의 2배 이상 데미지",  AchievementCategory.COMBAT, 60),
        make_achievement("last_stand",      "기사회생",        "Last Stand",          "목숨 1에서 보스 격파",       AchievementCategory.COMBAT, 80),
        make_achievement("no_damage",       "무피해 격파",     "Flawless",            "피해 없이 보스 격파",        AchievementCategory.COMBAT, 120),
        make_achievement("calamity_clear",  "재앙을 넘어서",   "Beyond Calamity",     "재앙 보스 격파",             AchievementCategory.COMBAT, 300),
        make_achievement("yeomra_clear",    "염라 격파",       "Yeomra Defeated",     "염라대왕 격파",              AchievementCategory.COMBAT, 150),
        make_achievement("one_shot",        "일격필살",        "One Shot",            "한 번의 공격으로 보스 격파", AchievementCategory.COMBAT, 250),

        -- ═══════════════════════════════════════
        -- 수집 (8개)
        -- ═══════════════════════════════════════
        make_achievement("talisman_first",  "첫 부적",         "First Talisman",      "부적을 처음 획득",           AchievementCategory.COLLECT, 10),
        make_achievement("talisman_10",     "부적 수집가",     "Talisman Collector",  "부적 10종 수집",             AchievementCategory.COLLECT, 60),
        make_achievement("talisman_all",    "만물상",          "Full Collection",     "모든 부적 수집",             AchievementCategory.COLLECT, 300),
        make_achievement("legendary_first", "전설의 시작",     "Legendary Start",     "전설 부적 처음 획득",        AchievementCategory.COLLECT, 50),
        make_achievement("seal_first",      "첫 각인",         "First Seal",          "도깨비 각인 처음 획득",      AchievementCategory.COLLECT, 30),
        make_achievement("seal_5",          "다섯 각인",       "Five Seals",          "도깨비 각인 5개 수집",       AchievementCategory.COLLECT, 150),
        make_achievement("seal_all",        "만인의 각인",     "All Seals",           "모든 도깨비 각인 수집",      AchievementCategory.COLLECT, 500),
        make_achievement("yeop_10000",      "만냥꾼",          "Ten Thousand Nyang",  "엽전 누적 10,000냥 획득",    AchievementCategory.COLLECT, 80),

        -- ═══════════════════════════════════════
        -- 특수 (7개)
        -- ═══════════════════════════════════════
        make_achievement("no_talisman",     "무부적",          "No Talisman",         "부적 없이 윤회 1 완료",      AchievementCategory.SPECIAL, 200),
        make_achievement("curse_lover",     "저주 수용자",     "Curse Lover",         "저주 부적 3개 장착 클리어",  AchievementCategory.SPECIAL, 150),
        make_achievement("nirvana_card",    "해탈",            "Nirvana",             "카드 1장 해탈 등급 달성",    AchievementCategory.SPECIAL, 300),
        make_achievement("all_yokbo",       "족보 박사",       "Yokbo Master",        "모든 족보를 한 번 이상 완성",AchievementCategory.SPECIAL, 500),
        make_achievement("destiny_great",   "대길의 운명",     "Great Fortune",       "운명 대길로 윤회 완료",      AchievementCategory.SPECIAL, 100),
        make_achievement("destiny_curse",   "대흉을 극복하다", "Overcome Great Curse","운명 대흉으로 윤회 완료",    AchievementCategory.SPECIAL, 300),
        make_achievement("full_upgrade",    "저승의 달인",     "Underworld Master",   "영구 강화 모두 최대",        AchievementCategory.SPECIAL, 1000),

        -- ═══════════════════════════════════════
        -- 히든 (10개)
        -- ═══════════════════════════════════════
        make_achievement("boatman_talk",    "???", "???", "뱃사공에게 5번 대화",              AchievementCategory.HIDDEN, 50,  true),
        make_achievement("zero_score",      "???", "???", "점수 0으로 라운드 종료",           AchievementCategory.HIDDEN, 10,  true),
        make_achievement("time_100h",       "???", "???", "총 플레이 시간 100시간",           AchievementCategory.HIDDEN, 0,   true),
        make_achievement("mangtong_3",      "???", "???", "한 판에 망통 3번",                 AchievementCategory.HIDDEN, 30,  true),
        make_achievement("all_bright",      "???", "???", "손패에 광 4장이 잡힘",             AchievementCategory.HIDDEN, 40,  true),
        make_achievement("pi_only_win",     "???", "???", "피 카드만으로 보스 격파",          AchievementCategory.HIDDEN, 100, true),
        make_achievement("same_boss_5",     "???", "???", "같은 보스에게 5번 패배",           AchievementCategory.HIDDEN, 20,  true),
        make_achievement("lucky_7",         "???", "???", "7월 카드 4장을 한 판에 모두 수집", AchievementCategory.HIDDEN, 50,  true),
        make_achievement("ghost_card",      "???", "???", "해골패를 5장 이상 보유",           AchievementCategory.HIDDEN, 60,  true),
        make_achievement("rebirth",         "???", "???", "이승의 문을 거부하고 계속 진행",   AchievementCategory.HIDDEN, 80,  true),
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
    if total_realms >= 30  then self:try_unlock("spiral_3") end
    if total_realms >= 50  then self:try_unlock("spiral_5") end
    if total_realms >= 100 then self:try_unlock("spiral_10") end
    if deaths >= 1         then self:try_unlock("first_death") end
    if deaths >= 10        then self:try_unlock("tenth_death") end
    if deaths >= 50        then self:try_unlock("fifty_death") end
    if deaths >= 100       then self:try_unlock("hundred_death") end
end

function AchievementManager:check_yokbo(yokbo_name, single_round_score)
    if yokbo_name then
        if string.find(yokbo_name, "삼광") then self:try_unlock("three_gwang") end
        if string.find(yokbo_name, "사광") then self:try_unlock("four_gwang") end
        if string.find(yokbo_name, "오광") then self:try_unlock("five_gwang") end
        if string.find(yokbo_name, "홍단") then self:try_unlock("hongdan") end
        if string.find(yokbo_name, "청단") then self:try_unlock("cheongdan") end
        if string.find(yokbo_name, "초단") then self:try_unlock("chodan") end
        if string.find(yokbo_name, "고도리") then self:try_unlock("godori") end
        if string.find(yokbo_name, "38광땡") then self:try_unlock("38gwangttaeng") end
        if string.find(yokbo_name, "장땡") then self:try_unlock("jangttaeng") end
    end
    if single_round_score >= 10000    then self:try_unlock("score_10k") end
    if single_round_score >= 100000   then self:try_unlock("score_100k") end
    if single_round_score >= 1000000  then self:try_unlock("score_1m") end
end

function AchievementManager:check_go(go_count, succeeded)
    if go_count >= 1 then self:try_unlock("first_go") end
    if go_count >= 2 then self:try_unlock("bold_choice") end
    if go_count >= 3 and succeeded     then self:try_unlock("mad_gambler") end
    if go_count >= 3 and not succeeded then self:try_unlock("greed_price") end
end

function AchievementManager:check_combat(boss_id, boss_killed, total_kills, overkill_ratio, lives_left, damage_taken)
    if boss_killed then self:try_unlock("first_boss") end
    if total_kills >= 10  then self:try_unlock("boss_10") end
    if total_kills >= 50  then self:try_unlock("boss_50") end
    if total_kills >= 100 then self:try_unlock("boss_100") end
    if overkill_ratio and overkill_ratio >= 2.0 then self:try_unlock("overkill") end
    if lives_left and lives_left <= 1 and boss_killed then self:try_unlock("last_stand") end
    if damage_taken and damage_taken <= 0 and boss_killed then self:try_unlock("no_damage") end
    if boss_id == "yeomra" and boss_killed then self:try_unlock("yeomra_clear") end
end

return {
    AchievementCategory = AchievementCategory,
    AchievementManager  = AchievementManager,
}

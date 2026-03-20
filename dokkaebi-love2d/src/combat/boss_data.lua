--- 보스 데이터 + 데이터베이스
--- Ported from BossData.cs + BossDatabase.cs

local BossGimmick = {
    None = "none",
    ConsumeHighest = "consume_highest",   -- 먹보 도깨비: 매 턴 최고가치 패 1장 소멸
    FlipAll = "flip_all",                 -- 장난꾸러기 도깨비: 모든 패 뒤집기
    ResetField = "reset_field",           -- 불꽃 도깨비: 3턴마다 바닥패 리셋
    DisableTalisman = "disable_talisman", -- 그림자 도깨비: 부적 1개 비활성화
    NoBright = "no_bright",               -- 염라대왕: 광 무효화
    -- 재앙 보스 기믹
    Skullify = "skullify",               -- 백골대장: 카드→해골패 변환, 3개 모이면 즉사
    FakeCards = "fake_cards",             -- 구미호 왕: 30% 가짜 카드, 매칭실패 시 -50칩
    Competitive = "competitive",          -- 이무기: 보스도 점수 누적, 경쟁
    Suppress = "suppress",                -- 저승꽃: 매 라운드 강화 1개 비활성 + 족보명 숨김
}

--- BossDefinition 생성
local function BossDefinition(t)
    return {
        id = t.id,
        name = t.name,
        name_kr = t.name_kr,
        description = t.description,
        target_score = t.target_score or 300,
        rounds = t.rounds or 3,
        gimmick = t.gimmick or BossGimmick.None,
        gimmick_interval = t.gimmick_interval or 1,
        intro_dialogue = t.intro_dialogue or "",
        defeat_dialogue = t.defeat_dialogue or "",
        victory_dialogue = t.victory_dialogue or "",
        yeop_reward = t.yeop_reward or 50,
        drops_legendary_talisman = t.drops_legendary_talisman or false,
        -- 비주얼: 보스별 고유 색상 {몸통, 머리, 뿔, 눈}
        body_color = t.body_color or {0.55, 0.10, 0.08},
        head_color = t.head_color or {0.65, 0.15, 0.10},
        horn_color = t.horn_color or {0.80, 0.70, 0.20},
        eye_color  = t.eye_color  or {1.00, 0.20, 0.10},
    }
end

-- ============================================================
-- 일반 보스 10종
-- ============================================================
local all_bosses = {
    -- 1. 먹보 도깨비 — 입문 (녹색 톤, 뚱뚱한 느낌)
    BossDefinition({
        id = "glutton",
        name = "Glutton Dokkaebi",
        name_kr = "먹보 도깨비",
        description = "2턴마다 손패 중 최고가치 패 1장을 먹어치운다",
        target_score = 100,
        rounds = 6,
        gimmick = BossGimmick.ConsumeHighest,
        gimmick_interval = 2,
        intro_dialogue = "크하하! 네 패에서 맛있는 냄새가 나는구나!",
        defeat_dialogue = "으억... 배가 너무 불러...",
        victory_dialogue = "꺼억! 맛있었다! 넌 이제 내 밥이야!",
        yeop_reward = 30,
        drops_legendary_talisman = false,
        body_color = {0.15, 0.45, 0.12}, head_color = {0.20, 0.55, 0.15},
        horn_color = {0.60, 0.50, 0.10}, eye_color = {1.0, 0.8, 0.1},
    }),

    -- 2. 장난꾸러기 도깨비 — 입문 (보라 톤)
    BossDefinition({
        id = "trickster",
        name = "Trickster Dokkaebi",
        name_kr = "장난꾸러기 도깨비",
        description = "2턴마다 패를 뒤집는다",
        target_score = 150,
        rounds = 6,
        gimmick = BossGimmick.FlipAll,
        gimmick_interval = 2,
        intro_dialogue = "히히히! 눈 감고 쳐봐라~!",
        defeat_dialogue = "에잇, 네 눈이 너무 좋구나!",
        victory_dialogue = "히히! 찍기의 달인이 될 뻔했는데~",
        yeop_reward = 35,
        drops_legendary_talisman = false,
        body_color = {0.40, 0.15, 0.55}, head_color = {0.50, 0.20, 0.65},
        horn_color = {0.90, 0.50, 0.90}, eye_color = {0.3, 1.0, 0.3},
    }),

    -- 3. 불꽃 도깨비 — 초급 (붉은/주황 톤)
    BossDefinition({
        id = "flame",
        name = "Flame Dokkaebi",
        name_kr = "불꽃 도깨비",
        description = "3턴마다 바닥패를 전부 불태워 리셋한다",
        target_score = 200,
        rounds = 6,
        gimmick = BossGimmick.ResetField,
        gimmick_interval = 3,
        intro_dialogue = "타오르는 화투판... 재밌지 않나?",
        defeat_dialogue = "꺼져가는 불꽃... 인정한다...",
        victory_dialogue = "모두 태워버리겠다!",
        yeop_reward = 40,
        drops_legendary_talisman = false,
        body_color = {0.70, 0.20, 0.05}, head_color = {0.85, 0.25, 0.08},
        horn_color = {1.0, 0.6, 0.1}, eye_color = {1.0, 0.9, 0.2},
    }),

    -- 4. 그림자 도깨비 — 중급 (짙은 남색)
    BossDefinition({
        id = "shadow",
        name = "Shadow Dokkaebi",
        name_kr = "그림자 도깨비",
        description = "부적 1개를 랜덤으로 비활성화한다",
        target_score = 230,
        rounds = 5,
        gimmick = BossGimmick.DisableTalisman,
        gimmick_interval = 2,
        intro_dialogue = "그림자가 너의 힘을 삼켜가고 있다...",
        defeat_dialogue = "빛이... 너무 밝다...",
        victory_dialogue = "어둠 속에서 영원히 헤매거라!",
        yeop_reward = 50,
        drops_legendary_talisman = true,
        body_color = {0.08, 0.08, 0.20}, head_color = {0.12, 0.10, 0.28},
        horn_color = {0.30, 0.25, 0.50}, eye_color = {0.6, 0.2, 1.0},
    }),

    -- 5. 여우 도깨비 — 중급 (주황/흰 톤)
    BossDefinition({
        id = "fox",
        name = "Fox Dokkaebi",
        name_kr = "여우 도깨비",
        description = "매 2턴마다 바닥패 2장의 월을 변경한다",
        target_score = 200,
        rounds = 5,
        gimmick = BossGimmick.FlipAll,
        gimmick_interval = 2,
        intro_dialogue = "후후... 눈을 잘 떠야 할 거야.",
        defeat_dialogue = "아이고... 꼬리가 잡혔네...",
        victory_dialogue = "후후후, 속았지?",
        yeop_reward = 45,
        drops_legendary_talisman = false,
        body_color = {0.75, 0.45, 0.10}, head_color = {0.85, 0.55, 0.15},
        horn_color = {0.95, 0.85, 0.60}, eye_color = {0.2, 0.8, 0.9},
    }),

    -- 6. 거울 도깨비 — 중급 (은색/하늘)
    BossDefinition({
        id = "mirror",
        name = "Mirror Dokkaebi",
        name_kr = "거울 도깨비",
        description = "부적 효과를 반전시킨다",
        target_score = 260,
        rounds = 5,
        gimmick = BossGimmick.DisableTalisman,
        gimmick_interval = 3,
        intro_dialogue = "네 힘이 곧 나의 힘...",
        defeat_dialogue = "거울이... 깨진다...",
        victory_dialogue = "네 그림자에 갇혀라!",
        yeop_reward = 50,
        drops_legendary_talisman = false,
        body_color = {0.50, 0.55, 0.65}, head_color = {0.60, 0.65, 0.75},
        horn_color = {0.80, 0.85, 0.95}, eye_color = {0.3, 0.7, 1.0},
    }),

    -- 7. 화산 도깨비 — 상급 (짙은 빨강/검정)
    BossDefinition({
        id = "volcano",
        name = "Volcano Dokkaebi",
        name_kr = "화산 도깨비",
        description = "매 2턴 바닥패 1장 소각",
        target_score = 300,
        rounds = 5,
        gimmick = BossGimmick.ResetField,
        gimmick_interval = 2,
        intro_dialogue = "뜨거운 용암 위에서 패를 쳐볼 테냐!",
        defeat_dialogue = "크윽... 식어간다...",
        victory_dialogue = "모든 것을 녹여버리겠다!",
        yeop_reward = 55,
        drops_legendary_talisman = false,
        body_color = {0.35, 0.05, 0.02}, head_color = {0.45, 0.08, 0.03},
        horn_color = {1.0, 0.3, 0.0}, eye_color = {1.0, 0.5, 0.0},
    }),

    -- 8. 황금 도깨비 — 상급 (금색)
    BossDefinition({
        id = "gold",
        name = "Golden Dokkaebi",
        name_kr = "황금 도깨비",
        description = "강하지만 보상도 크다",
        target_score = 350,
        rounds = 6,
        gimmick = BossGimmick.ConsumeHighest,
        gimmick_interval = 3,
        intro_dialogue = "금으로 된 패를 원하느냐? 그럼 이겨봐라!",
        defeat_dialogue = "내 금은보화를... 가져가거라...",
        victory_dialogue = "탐욕은 모든 것을 삼킨다!",
        yeop_reward = 80,
        drops_legendary_talisman = true,
        body_color = {0.70, 0.55, 0.10}, head_color = {0.85, 0.68, 0.15},
        horn_color = {1.0, 0.84, 0.0}, eye_color = {1.0, 0.2, 0.1},
    }),

    -- 9. 회랑 도깨비 — 상급 (청록)
    BossDefinition({
        id = "corridor",
        name = "Corridor Dokkaebi",
        name_kr = "회랑 도깨비",
        description = "매 턴 패를 뒤집는다",
        target_score = 320,
        rounds = 5,
        gimmick = BossGimmick.FlipAll,
        gimmick_interval = 1,
        intro_dialogue = "이 끝없는 회랑에서 빠져나갈 수 있겠느냐...",
        defeat_dialogue = "길을 찾다니... 대단하구나...",
        victory_dialogue = "영원히 이 회랑을 떠돌게 될 것이다!",
        yeop_reward = 60,
        drops_legendary_talisman = false,
        body_color = {0.08, 0.35, 0.40}, head_color = {0.10, 0.45, 0.50},
        horn_color = {0.20, 0.70, 0.75}, eye_color = {0.0, 1.0, 0.8},
    }),

    -- 10. 염라대왕 — 보스 (최종, 검정/금)
    BossDefinition({
        id = "yeomra",
        name = "King Yeomra",
        name_kr = "염라대왕",
        description = "광을 무효화시킨다. 피와 띠만으로 승부하라",
        target_score = 400,
        rounds = 6,
        gimmick = BossGimmick.NoBright,
        gimmick_interval = 1,
        intro_dialogue = "감히 이승으로 돌아가겠다고? 한 판 뜨자!",
        defeat_dialogue = "허... 대단하구나. 이승의 길을 열어주마.",
        victory_dialogue = "저승에서 영원히 내 패거리가 되거라!",
        yeop_reward = 100,
        drops_legendary_talisman = true,
        body_color = {0.10, 0.08, 0.08}, head_color = {0.15, 0.10, 0.10},
        horn_color = {1.0, 0.84, 0.0}, eye_color = {1.0, 0.0, 0.0},
    }),
}

-- ============================================================
-- 재앙 보스 4종
-- ============================================================
local calamity_bosses = {
    -- 백골대장 (나선 3)
    BossDefinition({
        id = "skeleton_general",
        name = "Skeleton General",
        name_kr = "백골대장",
        description = "매 턴 카드 1장을 해골패로 변환. 해골 3개 = 즉사.",
        target_score = 5000,
        rounds = 5,
        gimmick = BossGimmick.Skullify,
        gimmick_interval = 1,
        intro_dialogue = "뼈뼈뼈... 살이 아까운가? 뼈만 남겨주마...",
        defeat_dialogue = "깔깔깔... 뼈는 거짓말을 하지 않아...",
        victory_dialogue = "뼈밖에 남지 않았구나! 껄껄껄!",
        yeop_reward = 500,
        drops_legendary_talisman = true,
    }),

    -- 구미호 왕 (나선 5)
    BossDefinition({
        id = "ninetail_king",
        name = "Nine-Tail Fox King",
        name_kr = "구미호 왕",
        description = "30% 카드가 가짜. 매칭 실패 시 -50칩. 3턴마다 손패 셔플.",
        target_score = 6000,
        rounds = 5,
        gimmick = BossGimmick.FakeCards,
        gimmick_interval = 3,
        intro_dialogue = "후후... 진짜와 가짜를 구분할 수 있겠느냐?",
        defeat_dialogue = "이 눈으로... 간파하다니...",
        victory_dialogue = "환상 속에서 영원히 헤매거라! 후후후!",
        yeop_reward = 600,
        drops_legendary_talisman = true,
    }),

    -- 이무기 (나선 8)
    BossDefinition({
        id = "imugi",
        name = "Imugi (Greater Demon)",
        name_kr = "이무기",
        description = "경쟁전: 이무기도 매 턴 +50점 누적. 먼저 목표 달성해야 승리.",
        target_score = 8000,
        rounds = 7,
        gimmick = BossGimmick.Competitive,
        gimmick_interval = 1,
        intro_dialogue = "나도 용이 되려면 이겨야 한다! 승부다!",
        defeat_dialogue = "크으... 결국 승천은 네 몫이었구나...",
        victory_dialogue = "하하하! 이무기는 결국 용이 되었다!",
        yeop_reward = 800,
        drops_legendary_talisman = true,
    }),

    -- 저승꽃 (나선 10+)
    BossDefinition({
        id = "underworld_flower",
        name = "Underworld Flower King",
        name_kr = "저승꽃",
        description = "매 라운드 강화 1개 비활성 + 5턴마다 부적 셔플 + 족보명 숨김.",
        target_score = 10000,
        rounds = 7,
        gimmick = BossGimmick.Suppress,
        gimmick_interval = 5,
        intro_dialogue = "아름답지 않니? 이 꽃들은 전부 망자의 혼으로 피어났단다.",
        defeat_dialogue = "꽃잎이... 흩날린다... 아름답구나...",
        victory_dialogue = "너도 꽃이 되어라. 영원히... 아름답게...",
        yeop_reward = 1000,
        drops_legendary_talisman = true,
    }),
}

-- ============================================================
-- Public API
-- ============================================================
local BossData = {}

BossData.BossGimmick = BossGimmick
BossData.BossDefinition = BossDefinition

function BossData.get_all_bosses()
    return all_bosses
end

function BossData.get_calamity_bosses()
    return calamity_bosses
end

--- 인덱스로 보스 가져오기 (1-based)
function BossData.get_boss(index)
    if index < 1 or index > #all_bosses then
        return all_bosses[1]
    end
    return all_bosses[index]
end

--- ID로 보스 찾기
function BossData.get_by_id(id)
    for _, boss in ipairs(all_bosses) do
        if boss.id == id then return boss end
    end
    for _, boss in ipairs(calamity_bosses) do
        if boss.id == id then return boss end
    end
    return nil
end

--- 재앙 보스 가져오기 (나선 번호 기반)
function BossData.get_calamity_boss(spiral_number)
    if spiral_number == 3 then return calamity_bosses[1]      -- 백골대장
    elseif spiral_number == 5 then return calamity_bosses[2]  -- 구미호 왕
    elseif spiral_number == 8 then return calamity_bosses[3]  -- 이무기
    elseif spiral_number >= 10 then return calamity_bosses[4] -- 저승꽃
    else return nil
    end
end

return BossData

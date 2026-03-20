--- 보스 데이터 + 데이터베이스
--- 10관문 = 1윤회. 1~9관문은 일반 보스 풀에서 랜덤, 10관문은 염라대왕 고정.

local BossGimmick = {
    None = "none",
    ConsumeHighest = "consume_highest",   -- 먹보: 최고가치 패 소멸
    FlipAll = "flip_all",                 -- 장난꾸러기: 패 뒤집기
    ResetField = "reset_field",           -- 불꽃: 바닥패 리셋
    DisableTalisman = "disable_talisman", -- 그림자: 부적 비활성화
    NoBright = "no_bright",               -- 염라대왕: 광 무효화
    StealCard = "steal_card",             -- 도둑: 먹은 패 1장 빼앗기
    CurseMark = "curse_mark",             -- 원귀: 저주 표식 누적
    TimePressure = "time_pressure",       -- 저승시계: 턴 수 제한
    MirrorCopy = "mirror_copy",           -- 거울: 플레이어 족보 복사
    Fog = "fog",                          -- 안개: 바닥패 일부 숨기기
    PoisonPi = "poison_pi",              -- 독사: 피 카드 독 부여
    -- 재앙 보스 기믹
    Skullify = "skullify",               -- 백골대장: 해골패 변환
    FakeCards = "fake_cards",             -- 구미호 왕: 가짜 카드
    Competitive = "competitive",          -- 이무기: 경쟁
    Suppress = "suppress",                -- 저승꽃: 강화 비활성+족보 숨김
}

--- BossDefinition 생성
local function BossDefinition(t)
    return {
        id = t.id,
        name = t.name,
        name_kr = t.name_kr,
        description = t.description,
        target_score = t.target_score or 500,
        rounds = t.rounds or 3,
        gimmick = t.gimmick or BossGimmick.None,
        gimmick_interval = t.gimmick_interval or 1,
        intro_dialogue = t.intro_dialogue or "",
        defeat_dialogue = t.defeat_dialogue or "",
        victory_dialogue = t.victory_dialogue or "",
        yeop_reward = t.yeop_reward or 50,
        drops_legendary_talisman = t.drops_legendary_talisman or false,
        tier = t.tier or "normal",  -- "normal", "elite", "boss", "calamity"
        body_color = t.body_color or {0.55, 0.10, 0.08},
        head_color = t.head_color or {0.65, 0.15, 0.10},
        horn_color = t.horn_color or {0.80, 0.70, 0.20},
        eye_color  = t.eye_color  or {1.00, 0.20, 0.10},
    }
end

-- ============================================================
-- 일반 보스 풀 (1~9관문에서 랜덤 등장, 18종)
-- ============================================================
local all_bosses = {
    -- ── 입문급 (관문 1~3) ──
    BossDefinition({
        id = "glutton", name = "Glutton Dokkaebi", name_kr = "먹보 도깨비",
        description = "2턴마다 손패 중 최고가치 패 1장을 먹어치운다",
        target_score = 260, rounds = 5, tier = "normal",
        gimmick = BossGimmick.ConsumeHighest, gimmick_interval = 2,
        intro_dialogue = "크하하! 네 패에서 맛있는 냄새가 나는구나!",
        defeat_dialogue = "으억... 배가 너무 불러...",
        victory_dialogue = "꺼억! 맛있었다! 넌 이제 내 밥이야!",
        yeop_reward = 25,
        body_color = {0.15, 0.45, 0.12}, head_color = {0.20, 0.55, 0.15},
        horn_color = {0.60, 0.50, 0.10}, eye_color = {1.0, 0.8, 0.1},
    }),
    BossDefinition({
        id = "trickster", name = "Trickster Dokkaebi", name_kr = "장난꾸러기 도깨비",
        description = "2턴마다 패를 뒤집는다",
        target_score = 310, rounds = 5, tier = "normal",
        gimmick = BossGimmick.FlipAll, gimmick_interval = 2,
        intro_dialogue = "히히히! 눈 감고 쳐봐라~!",
        defeat_dialogue = "에잇, 네 눈이 너무 좋구나!",
        victory_dialogue = "히히! 찍기의 달인이 될 뻔했는데~",
        yeop_reward = 30,
        body_color = {0.40, 0.15, 0.55}, head_color = {0.50, 0.20, 0.65},
        horn_color = {0.90, 0.50, 0.90}, eye_color = {0.3, 1.0, 0.3},
    }),
    BossDefinition({
        id = "thief", name = "Thief Dokkaebi", name_kr = "도둑 도깨비",
        description = "2턴마다 먹은 패 중 1장을 훔쳐간다",
        target_score = 290, rounds = 5, tier = "normal",
        gimmick = BossGimmick.StealCard, gimmick_interval = 2,
        intro_dialogue = "쉿! 가만히 있어봐... 슬쩍~",
        defeat_dialogue = "이런... 손이 느려졌나...",
        victory_dialogue = "고마워! 네 패는 이제 다 내 거야!",
        yeop_reward = 28,
        body_color = {0.25, 0.25, 0.30}, head_color = {0.35, 0.30, 0.38},
        horn_color = {0.50, 0.50, 0.55}, eye_color = {0.9, 0.9, 0.2},
    }),

    -- ── 초급 (관문 3~5) ──
    BossDefinition({
        id = "flame", name = "Flame Dokkaebi", name_kr = "불꽃 도깨비",
        description = "3턴마다 바닥패를 전부 불태워 리셋한다",
        target_score = 370, rounds = 5, tier = "normal",
        gimmick = BossGimmick.ResetField, gimmick_interval = 3,
        intro_dialogue = "타오르는 화투판... 재밌지 않나?",
        defeat_dialogue = "꺼져가는 불꽃... 인정한다...",
        victory_dialogue = "모두 태워버리겠다!",
        yeop_reward = 35,
        body_color = {0.70, 0.20, 0.05}, head_color = {0.85, 0.25, 0.08},
        horn_color = {1.0, 0.6, 0.1}, eye_color = {1.0, 0.9, 0.2},
    }),
    BossDefinition({
        id = "fog", name = "Fog Dokkaebi", name_kr = "안개 도깨비",
        description = "바닥패 절반이 안개에 가려 보이지 않는다",
        target_score = 360, rounds = 5, tier = "normal",
        gimmick = BossGimmick.Fog, gimmick_interval = 1,
        intro_dialogue = "앞이 보이지 않는다... 안개가 너를 삼킨다...",
        defeat_dialogue = "안개가... 걷히는구나...",
        victory_dialogue = "안개 속에서 영원히 길을 잃어라!",
        yeop_reward = 33,
        body_color = {0.35, 0.40, 0.45}, head_color = {0.45, 0.50, 0.55},
        horn_color = {0.60, 0.65, 0.70}, eye_color = {0.8, 0.8, 0.9},
    }),
    BossDefinition({
        id = "fox", name = "Fox Dokkaebi", name_kr = "여우 도깨비",
        description = "매 2턴마다 바닥패 2장의 월을 변경한다",
        target_score = 440, rounds = 5, tier = "normal",
        gimmick = BossGimmick.FlipAll, gimmick_interval = 2,
        intro_dialogue = "후후... 눈을 잘 떠야 할 거야.",
        defeat_dialogue = "아이고... 꼬리가 잡혔네...",
        victory_dialogue = "후후후, 속았지?",
        yeop_reward = 40,
        body_color = {0.75, 0.45, 0.10}, head_color = {0.85, 0.55, 0.15},
        horn_color = {0.95, 0.85, 0.60}, eye_color = {0.2, 0.8, 0.9},
    }),

    -- ── 중급 (관문 4~7) ──
    BossDefinition({
        id = "shadow", name = "Shadow Dokkaebi", name_kr = "그림자 도깨비",
        description = "부적 1개를 랜덤으로 비활성화한다",
        target_score = 480, rounds = 5, tier = "elite",
        gimmick = BossGimmick.DisableTalisman, gimmick_interval = 2,
        intro_dialogue = "그림자가 너의 힘을 삼켜가고 있다...",
        defeat_dialogue = "빛이... 너무 밝다...",
        victory_dialogue = "어둠 속에서 영원히 헤매거라!",
        yeop_reward = 45, drops_legendary_talisman = true,
        body_color = {0.08, 0.08, 0.20}, head_color = {0.12, 0.10, 0.28},
        horn_color = {0.30, 0.25, 0.50}, eye_color = {0.6, 0.2, 1.0},
    }),
    BossDefinition({
        id = "mirror", name = "Mirror Dokkaebi", name_kr = "거울 도깨비",
        description = "플레이어의 족보를 복사해 반격한다",
        target_score = 490, rounds = 6, tier = "elite",
        gimmick = BossGimmick.MirrorCopy, gimmick_interval = 1,
        intro_dialogue = "네 힘이 곧 나의 힘...",
        defeat_dialogue = "거울이... 깨진다...",
        victory_dialogue = "네 그림자에 갇혀라!",
        yeop_reward = 48,
        body_color = {0.50, 0.55, 0.65}, head_color = {0.60, 0.65, 0.75},
        horn_color = {0.80, 0.85, 0.95}, eye_color = {0.3, 0.7, 1.0},
    }),
    BossDefinition({
        id = "curse_ghost", name = "Curse Ghost", name_kr = "원귀 도깨비",
        description = "매 턴 저주 표식 1개 누적. 5개 모이면 즉사.",
        target_score = 460, rounds = 5, tier = "elite",
        gimmick = BossGimmick.CurseMark, gimmick_interval = 1,
        intro_dialogue = "한...을... 풀어야...한다...",
        defeat_dialogue = "드디어... 한이... 풀린다...",
        victory_dialogue = "너도 원귀가 되어라...영원히...",
        yeop_reward = 45,
        body_color = {0.15, 0.20, 0.35}, head_color = {0.20, 0.25, 0.45},
        horn_color = {0.40, 0.30, 0.60}, eye_color = {0.8, 0.1, 0.1},
    }),
    BossDefinition({
        id = "viper", name = "Viper Dokkaebi", name_kr = "독사 도깨비",
        description = "피 카드에 독을 부여. 독 피를 먹으면 칩 -20",
        target_score = 440, rounds = 5, tier = "elite",
        gimmick = BossGimmick.PoisonPi, gimmick_interval = 1,
        intro_dialogue = "스스스... 피 카드를 조심해라...",
        defeat_dialogue = "크윽... 독이 역류한다...",
        victory_dialogue = "독에 물든 패로는 아무것도 할 수 없지!",
        yeop_reward = 42,
        body_color = {0.20, 0.50, 0.15}, head_color = {0.25, 0.60, 0.18},
        horn_color = {0.45, 0.75, 0.20}, eye_color = {0.9, 1.0, 0.1},
    }),

    -- ── 상급 (관문 6~9) ──
    BossDefinition({
        id = "volcano", name = "Volcano Dokkaebi", name_kr = "화산 도깨비",
        description = "매 2턴 바닥패 전체 소각 + 랜덤 리필",
        target_score = 540, rounds = 6, tier = "elite",
        gimmick = BossGimmick.ResetField, gimmick_interval = 2,
        intro_dialogue = "뜨거운 용암 위에서 패를 쳐볼 테냐!",
        defeat_dialogue = "크윽... 식어간다...",
        victory_dialogue = "모든 것을 녹여버리겠다!",
        yeop_reward = 55,
        body_color = {0.35, 0.05, 0.02}, head_color = {0.45, 0.08, 0.03},
        horn_color = {1.0, 0.3, 0.0}, eye_color = {1.0, 0.5, 0.0},
    }),
    BossDefinition({
        id = "gold", name = "Golden Dokkaebi", name_kr = "황금 도깨비",
        description = "3턴마다 최고 패 소멸. 강하지만 보상도 크다",
        target_score = 600, rounds = 6, tier = "elite",
        gimmick = BossGimmick.ConsumeHighest, gimmick_interval = 3,
        intro_dialogue = "금으로 된 패를 원하느냐? 그럼 이겨봐라!",
        defeat_dialogue = "내 금은보화를... 가져가거라...",
        victory_dialogue = "탐욕은 모든 것을 삼킨다!",
        yeop_reward = 65, drops_legendary_talisman = true,
        body_color = {0.70, 0.55, 0.10}, head_color = {0.85, 0.68, 0.15},
        horn_color = {1.0, 0.84, 0.0}, eye_color = {1.0, 0.2, 0.1},
    }),
    BossDefinition({
        id = "corridor", name = "Corridor Dokkaebi", name_kr = "회랑 도깨비",
        description = "매 턴 패를 뒤집는다",
        target_score = 580, rounds = 6, tier = "elite",
        gimmick = BossGimmick.FlipAll, gimmick_interval = 1,
        intro_dialogue = "이 끝없는 회랑에서 빠져나갈 수 있겠느냐...",
        defeat_dialogue = "길을 찾다니... 대단하구나...",
        victory_dialogue = "영원히 이 회랑을 떠돌게 될 것이다!",
        yeop_reward = 55,
        body_color = {0.08, 0.35, 0.40}, head_color = {0.10, 0.45, 0.50},
        horn_color = {0.20, 0.70, 0.75}, eye_color = {0.0, 1.0, 0.8},
    }),
    BossDefinition({
        id = "clock", name = "Clock Dokkaebi", name_kr = "저승시계 도깨비",
        description = "각 판 턴 수가 제한된다. 시간이 다하면 즉사!",
        target_score = 560, rounds = 5, tier = "elite",
        gimmick = BossGimmick.TimePressure, gimmick_interval = 1,
        intro_dialogue = "째깍째깍... 네 시간은 얼마 남지 않았다...",
        defeat_dialogue = "시간의 모래가... 다 떨어졌구나...",
        victory_dialogue = "시간이 다 됐다! 이승의 꿈은 여기까지!",
        yeop_reward = 52,
        body_color = {0.30, 0.20, 0.10}, head_color = {0.40, 0.28, 0.14},
        horn_color = {0.80, 0.65, 0.30}, eye_color = {1.0, 0.6, 0.0},
    }),
    BossDefinition({
        id = "bone_shaman", name = "Bone Shaman", name_kr = "뼈무당 도깨비",
        description = "부적 2개 비활성 + 3턴마다 패 1장 소멸",
        target_score = 610, rounds = 6, tier = "elite",
        gimmick = BossGimmick.DisableTalisman, gimmick_interval = 1,
        intro_dialogue = "뼈 점을 쳐보마... 네 운명은 이미 정해졌다!",
        defeat_dialogue = "뼈가 거짓말을 했구나...",
        victory_dialogue = "뼈가 말한다... 넌 여기서 끝이다!",
        yeop_reward = 58, drops_legendary_talisman = true,
        body_color = {0.55, 0.50, 0.40}, head_color = {0.65, 0.58, 0.48},
        horn_color = {0.90, 0.80, 0.60}, eye_color = {0.2, 0.8, 0.2},
    }),
    BossDefinition({
        id = "blood_rain", name = "Blood Rain Dokkaebi", name_kr = "혈우 도깨비",
        description = "매 턴 피 카드에 저주. 피 3장 이상 보유 시 칩 -50",
        target_score = 630, rounds = 6, tier = "elite",
        gimmick = BossGimmick.PoisonPi, gimmick_interval = 1,
        intro_dialogue = "핏빛 비가 내린다... 아름답지 않느냐?",
        defeat_dialogue = "피의 비가... 그치는구나...",
        victory_dialogue = "핏빛 세상에서 영원히 살아라!",
        yeop_reward = 60,
        body_color = {0.50, 0.05, 0.05}, head_color = {0.60, 0.08, 0.08},
        horn_color = {0.80, 0.15, 0.10}, eye_color = {1.0, 0.0, 0.0},
    }),
    BossDefinition({
        id = "nightmare", name = "Nightmare Dokkaebi", name_kr = "악몽 도깨비",
        description = "손패 3장이 항상 뒤집혀 있다. 3턴마다 바닥패 셔플",
        target_score = 650, rounds = 6, tier = "elite",
        gimmick = BossGimmick.FlipAll, gimmick_interval = 3,
        intro_dialogue = "잠들어라... 악몽에서는 아무것도 보이지 않는다...",
        defeat_dialogue = "악몽에서... 깨어났구나...",
        victory_dialogue = "영원한 악몽 속에 가둬주마!",
        yeop_reward = 62, drops_legendary_talisman = true,
        body_color = {0.15, 0.05, 0.25}, head_color = {0.22, 0.08, 0.35},
        horn_color = {0.50, 0.20, 0.70}, eye_color = {1.0, 0.3, 0.8},
    }),

    -- ── 저승 망자 계열 ──
    BossDefinition({
        id = "wonhon", name = "Wandering Spirit", name_kr = "떠도는 원혼",
        description = "매 턴 저주 표식 누적. 4개 모이면 손패 절반 소멸",
        target_score = 340, rounds = 5, tier = "normal",
        gimmick = BossGimmick.CurseMark, gimmick_interval = 1,
        intro_dialogue = "이승이 그립다... 너의 패를 빌려다오...",
        defeat_dialogue = "고맙다... 이제 쉴 수 있겠구나...",
        victory_dialogue = "너도 나처럼 떠돌게 될 거야...",
        yeop_reward = 30,
        body_color = {0.20, 0.25, 0.35}, head_color = {0.28, 0.32, 0.45},
        horn_color = {0.40, 0.45, 0.55}, eye_color = {0.5, 0.7, 1.0},
    }),
    BossDefinition({
        id = "jeoseung_saja", name = "Reaper", name_kr = "저승사자",
        description = "매 3턴 최고가치 패 1장 차압. 부적도 1개 봉인",
        target_score = 600, rounds = 6, tier = "elite",
        gimmick = BossGimmick.ConsumeHighest, gimmick_interval = 3,
        intro_dialogue = "때가 됐다. 명부에 네 이름이 적혀 있다.",
        defeat_dialogue = "...명부를 다시 확인해야겠군.",
        victory_dialogue = "순순히 따라오거라. 저승에 자리가 마련되어 있다.",
        yeop_reward = 58, drops_legendary_talisman = true,
        body_color = {0.05, 0.05, 0.08}, head_color = {0.08, 0.08, 0.12},
        horn_color = {0.15, 0.15, 0.20}, eye_color = {0.8, 0.0, 0.0},
    }),

    -- ── 요괴 계열 ──
    BossDefinition({
        id = "gumiho", name = "Gumiho", name_kr = "구미호",
        description = "패 2장을 가짜로 바꾼다. 가짜 패 사용 시 칩 -30",
        target_score = 410, rounds = 5, tier = "normal",
        gimmick = BossGimmick.FakeCards, gimmick_interval = 2,
        intro_dialogue = "예쁜 아가씨인 줄 알았지? 후후...",
        defeat_dialogue = "꼬리가 밟혔구나...",
        victory_dialogue = "네 간을 내놓거라!",
        yeop_reward = 38,
        body_color = {0.80, 0.50, 0.15}, head_color = {0.90, 0.60, 0.20},
        horn_color = {1.0, 0.80, 0.40}, eye_color = {0.3, 0.9, 0.3},
    }),
    BossDefinition({
        id = "haetae", name = "Haetae", name_kr = "해태",
        description = "불 속성 족보(홍단,화산 등) 피해를 흡수한다",
        target_score = 510, rounds = 5, tier = "elite",
        gimmick = BossGimmick.None, gimmick_interval = 1,
        intro_dialogue = "불을 다스리는 자, 해태가 왔다.",
        defeat_dialogue = "네 화기가... 대단하구나...",
        victory_dialogue = "모든 불을 삼켜주마!",
        yeop_reward = 50,
        body_color = {0.60, 0.40, 0.10}, head_color = {0.70, 0.50, 0.15},
        horn_color = {0.90, 0.70, 0.20}, eye_color = {1.0, 0.6, 0.1},
    }),
    BossDefinition({
        id = "bulgasari", name = "Bulgasari", name_kr = "불가사리",
        description = "철을 먹는 괴수. 매 턴 엽전 5냥 소모",
        target_score = 480, rounds = 5, tier = "elite",
        gimmick = BossGimmick.StealCard, gimmick_interval = 1,
        intro_dialogue = "쇠든 뭐든... 다 먹어치운다!",
        defeat_dialogue = "더는... 먹을 수가 없다...",
        victory_dialogue = "네 엽전도 전부 내 뱃속으로!",
        yeop_reward = 45,
        body_color = {0.30, 0.30, 0.35}, head_color = {0.38, 0.38, 0.42},
        horn_color = {0.55, 0.55, 0.60}, eye_color = {1.0, 0.4, 0.1},
    }),

    -- ── 자연/신령 계열 ──
    BossDefinition({
        id = "san_shin", name = "Mountain God", name_kr = "산신령",
        description = "산의 축복: 자연 족보(봄/여름/가을/겨울) 위력 반감",
        target_score = 580, rounds = 6, tier = "elite",
        gimmick = BossGimmick.DisableTalisman, gimmick_interval = 2,
        intro_dialogue = "이 산에 들어온 이상... 내 규칙을 따라야 한다.",
        defeat_dialogue = "허허... 산을 넘었구나. 대단한 놈이야.",
        victory_dialogue = "산을 넘을 수 없다면 영원히 이 숲을 헤매거라!",
        yeop_reward = 55, drops_legendary_talisman = true,
        body_color = {0.15, 0.40, 0.15}, head_color = {0.20, 0.50, 0.20},
        horn_color = {0.50, 0.75, 0.30}, eye_color = {1.0, 1.0, 0.5},
    }),
    BossDefinition({
        id = "yongwang", name = "Dragon King", name_kr = "용왕",
        description = "비 광 효과 무효화. 매 2턴 패 2장 물에 잠김(사용불가)",
        target_score = 680, rounds = 6, tier = "elite",
        gimmick = BossGimmick.Fog, gimmick_interval = 2,
        intro_dialogue = "바다의 지배자 앞에서 감히!",
        defeat_dialogue = "파도가... 잠잠해지는구나...",
        victory_dialogue = "깊은 바닷속으로 끌어들여주마!",
        yeop_reward = 65, drops_legendary_talisman = true,
        body_color = {0.05, 0.20, 0.50}, head_color = {0.08, 0.28, 0.60},
        horn_color = {0.15, 0.50, 0.85}, eye_color = {0.0, 0.9, 1.0},
    }),
    BossDefinition({
        id = "cheonji_ma", name = "Heaven-Earth Demon", name_kr = "천지마",
        description = "홀수턴 광 봉인, 짝수턴 띠 봉인. 번갈아 제한",
        target_score = 650, rounds = 6, tier = "elite",
        gimmick = BossGimmick.NoBright, gimmick_interval = 1,
        intro_dialogue = "하늘과 땅 사이... 네가 설 곳은 없다!",
        defeat_dialogue = "천지가... 흔들린다...",
        victory_dialogue = "하늘도 땅도 너를 거부한다!",
        yeop_reward = 60,
        body_color = {0.40, 0.10, 0.40}, head_color = {0.50, 0.15, 0.50},
        horn_color = {0.70, 0.30, 0.70}, eye_color = {1.0, 1.0, 0.0},
    }),

    -- ── 이승 침입자 계열 ──
    BossDefinition({
        id = "tal_gwangdae", name = "Masked Jester", name_kr = "탈 광대",
        description = "매 턴 랜덤 카드 2장의 월을 바꾼다",
        target_score = 420, rounds = 5, tier = "normal",
        gimmick = BossGimmick.FlipAll, gimmick_interval = 1,
        intro_dialogue = "하하하! 어디 구경 좀 하자!",
        defeat_dialogue = "탈이... 벗겨졌구나... 아아...",
        victory_dialogue = "영원히 춤추게 해주마! 하하하!",
        yeop_reward = 35,
        body_color = {0.70, 0.15, 0.15}, head_color = {0.85, 0.85, 0.80},
        horn_color = {0.90, 0.30, 0.10}, eye_color = {0.0, 0.0, 0.0},
    }),
    BossDefinition({
        id = "dalgyal", name = "Egg Ghost", name_kr = "달걀귀신",
        description = "눈코입 없는 귀신. 패 정보가 일부 가려진다",
        target_score = 320, rounds = 5, tier = "normal",
        gimmick = BossGimmick.Fog, gimmick_interval = 1,
        intro_dialogue = ".........",
        defeat_dialogue = "......!!",
        victory_dialogue = "............",
        yeop_reward = 28,
        body_color = {0.85, 0.82, 0.75}, head_color = {0.90, 0.88, 0.82},
        horn_color = {0.70, 0.68, 0.60}, eye_color = {0.0, 0.0, 0.0},
    }),
    BossDefinition({
        id = "mul_gwishin", name = "Water Ghost", name_kr = "물귀신",
        description = "매 턴 손패 1장을 물 속으로 끌어간다(소멸)",
        target_score = 390, rounds = 5, tier = "normal",
        gimmick = BossGimmick.ConsumeHighest, gimmick_interval = 1,
        intro_dialogue = "같이... 물 속으로... 들어가자...",
        defeat_dialogue = "혼자... 가야 하는구나...",
        victory_dialogue = "같이 빠지면... 외롭지 않을 텐데...",
        yeop_reward = 32,
        body_color = {0.10, 0.25, 0.40}, head_color = {0.15, 0.35, 0.55},
        horn_color = {0.20, 0.45, 0.65}, eye_color = {0.4, 0.8, 1.0},
    }),

    -- ── 저승 관리 계열 ──
    BossDefinition({
        id = "mansin", name = "Shaman", name_kr = "무당",
        description = "매 2턴 부적 효과 반전. 버프가 디버프로 바뀐다",
        target_score = 420, rounds = 5, tier = "normal",
        gimmick = BossGimmick.DisableTalisman, gimmick_interval = 2,
        intro_dialogue = "신이 내린다... 네 부적은 무용지물이야!",
        defeat_dialogue = "신이... 떠나간다...",
        victory_dialogue = "신의 뜻이다! 순순히 받아들여라!",
        yeop_reward = 36,
        body_color = {0.60, 0.20, 0.30}, head_color = {0.70, 0.28, 0.38},
        horn_color = {0.85, 0.40, 0.50}, eye_color = {1.0, 1.0, 1.0},
    }),
    BossDefinition({
        id = "myeongbu_gwanri", name = "Underworld Clerk", name_kr = "명부 관리",
        description = "매 턴 족보 1개를 무작위로 금지시킨다",
        target_score = 530, rounds = 5, tier = "elite",
        gimmick = BossGimmick.Suppress, gimmick_interval = 1,
        intro_dialogue = "명부에 따르면... 이 족보는 사용 불가다.",
        defeat_dialogue = "명부가... 찢어졌구나...",
        victory_dialogue = "규정 위반이다! 저승 감옥에 처한다!",
        yeop_reward = 50,
        body_color = {0.25, 0.20, 0.15}, head_color = {0.35, 0.28, 0.20},
        horn_color = {0.60, 0.50, 0.35}, eye_color = {0.9, 0.7, 0.3},
    }),
    BossDefinition({
        id = "heuk_muin", name = "Black Warrior", name_kr = "흑무인",
        description = "매 턴 반격 데미지 +1. 빨리 처치하지 않으면 위험",
        target_score = 490, rounds = 5, tier = "elite",
        gimmick = BossGimmick.ConsumeHighest, gimmick_interval = 3,
        intro_dialogue = "칼이 점점 날카로워진다... 서둘러라!",
        defeat_dialogue = "좋은 한 판이었다...",
        victory_dialogue = "너무 느렸다!",
        yeop_reward = 48,
        body_color = {0.08, 0.08, 0.12}, head_color = {0.12, 0.12, 0.18},
        horn_color = {0.25, 0.25, 0.35}, eye_color = {0.9, 0.2, 0.2},
    }),

    -- ── 동물 요괴 계열 ──
    BossDefinition({
        id = "samjokgu", name = "Three-Legged Dog", name_kr = "삼족구",
        description = "3의 배수 턴마다 바닥패 전체 리셋",
        target_score = 370, rounds = 5, tier = "normal",
        gimmick = BossGimmick.ResetField, gimmick_interval = 3,
        intro_dialogue = "왈왈! 이 저승의 문지기를 넘어볼 테냐!",
        defeat_dialogue = "낑낑... 강한 놈이구나...",
        victory_dialogue = "컹컹! 여기서 꼼짝 마라!",
        yeop_reward = 32,
        body_color = {0.45, 0.25, 0.10}, head_color = {0.55, 0.32, 0.14},
        horn_color = {0.70, 0.50, 0.25}, eye_color = {1.0, 0.7, 0.2},
    }),
    BossDefinition({
        id = "baeksa", name = "White Serpent", name_kr = "백사",
        description = "독안개: 바닥패 절반 숨김 + 피 카드 독 부여",
        target_score = 560, rounds = 6, tier = "elite",
        gimmick = BossGimmick.PoisonPi, gimmick_interval = 1,
        intro_dialogue = "스스스... 천년을 살았다... 네가 무섭지 않아...",
        defeat_dialogue = "스스... 이번은 인정하마...",
        victory_dialogue = "독에 물든 채 저승에서 썩어라!",
        yeop_reward = 54,
        body_color = {0.80, 0.80, 0.75}, head_color = {0.90, 0.88, 0.82},
        horn_color = {0.95, 0.92, 0.85}, eye_color = {0.3, 0.8, 0.2},
    }),
    BossDefinition({
        id = "cheolma", name = "Iron Horse Demon", name_kr = "철마",
        description = "매 턴 엽전 8냥 소모. 6턴 안에 못 잡으면 파산",
        target_score = 510, rounds = 6, tier = "elite",
        gimmick = BossGimmick.StealCard, gimmick_interval = 1,
        intro_dialogue = "히히힝! 네 재물을 전부 밟아버리겠다!",
        defeat_dialogue = "크윽... 멈출 수가...",
        victory_dialogue = "네 냥전은 먼지가 되었다!",
        yeop_reward = 55,
        body_color = {0.35, 0.35, 0.40}, head_color = {0.45, 0.45, 0.50},
        horn_color = {0.65, 0.65, 0.70}, eye_color = {1.0, 0.3, 0.0},
    }),
    BossDefinition({
        id = "duggaebi", name = "Toad Spirit", name_kr = "두꺼비 정령",
        description = "매 2턴 피 카드 1장을 금 카드로 변환 (도박)",
        target_score = 340, rounds = 5, tier = "normal",
        gimmick = BossGimmick.FlipAll, gimmick_interval = 2,
        intro_dialogue = "개골개골... 금두꺼비가 복을 가져다준다구?",
        defeat_dialogue = "개골... 금이 다 떨어졌다...",
        victory_dialogue = "개골개골! 네 복도 내가 가져간다!",
        yeop_reward = 30,
        body_color = {0.30, 0.45, 0.15}, head_color = {0.38, 0.55, 0.20},
        horn_color = {0.55, 0.70, 0.30}, eye_color = {1.0, 0.9, 0.2},
    }),

    -- ── 자연재해 계열 ──
    BossDefinition({
        id = "taepoong", name = "Typhoon Spirit", name_kr = "태풍귀",
        description = "매 턴 손패 전체 셔플 + 선택 카드 해제",
        target_score = 460, rounds = 5, tier = "elite",
        gimmick = BossGimmick.FlipAll, gimmick_interval = 1,
        intro_dialogue = "회오리바람이 모든 것을 쓸어간다!",
        defeat_dialogue = "바람이... 잠잠해진다...",
        victory_dialogue = "폭풍 속에서 길을 잃어라!",
        yeop_reward = 44,
        body_color = {0.20, 0.35, 0.45}, head_color = {0.28, 0.45, 0.55},
        horn_color = {0.40, 0.60, 0.70}, eye_color = {0.8, 0.9, 1.0},
    }),
    BossDefinition({
        id = "jisin", name = "Earthquake Spirit", name_kr = "지진귀",
        description = "3턴마다 바닥패+손패 전체 흔들림(순서 변경)",
        target_score = 440, rounds = 5, tier = "normal",
        gimmick = BossGimmick.ResetField, gimmick_interval = 3,
        intro_dialogue = "우르르르릉! 땅이 갈라진다!",
        defeat_dialogue = "균열이... 메워지는구나...",
        victory_dialogue = "저승의 땅 위에 영원히 묻혀라!",
        yeop_reward = 38,
        body_color = {0.45, 0.30, 0.15}, head_color = {0.55, 0.38, 0.20},
        horn_color = {0.70, 0.55, 0.30}, eye_color = {1.0, 0.5, 0.1},
    }),

    -- ── 저승 환상 계열 ──
    BossDefinition({
        id = "kkum_gwishin", name = "Dream Ghost", name_kr = "꿈귀신",
        description = "매 턴 손패 2장이 랜덤으로 바뀐다 (환각)",
        target_score = 410, rounds = 5, tier = "normal",
        gimmick = BossGimmick.FlipAll, gimmick_interval = 1,
        intro_dialogue = "이것은 꿈일까... 현실일까...",
        defeat_dialogue = "꿈에서... 깨어났구나...",
        victory_dialogue = "영원히 꿈속을 헤매거라...",
        yeop_reward = 35,
        body_color = {0.30, 0.15, 0.45}, head_color = {0.40, 0.22, 0.55},
        horn_color = {0.60, 0.35, 0.75}, eye_color = {0.8, 0.5, 1.0},
    }),
    BossDefinition({
        id = "geoulgwi", name = "Mirror Demon", name_kr = "거울귀",
        description = "플레이어의 마지막 족보를 복사해 칩 -30 반격",
        target_score = 540, rounds = 6, tier = "elite",
        gimmick = BossGimmick.MirrorCopy, gimmick_interval = 1,
        intro_dialogue = "네 모습이 보인다... 똑같이 해주마!",
        defeat_dialogue = "거울이... 산산조각...",
        victory_dialogue = "네 자신을 이길 수 있겠느냐!",
        yeop_reward = 52,
        body_color = {0.50, 0.50, 0.55}, head_color = {0.60, 0.60, 0.65},
        horn_color = {0.75, 0.75, 0.80}, eye_color = {0.5, 0.5, 1.0},
    }),
    BossDefinition({
        id = "mangja_wang", name = "King of the Dead", name_kr = "망자왕",
        description = "저주 표식 + 부적 봉인 + 피 카드 독. 복합 기믹",
        target_score = 710, rounds = 6, tier = "elite",
        gimmick = BossGimmick.CurseMark, gimmick_interval = 1,
        intro_dialogue = "모든 망자의 왕이 왔다... 무릎 꿇어라!",
        defeat_dialogue = "왕좌가... 흔들린다...",
        victory_dialogue = "네 혼도 내 군대에 합류할 것이다!",
        yeop_reward = 70, drops_legendary_talisman = true,
        body_color = {0.20, 0.05, 0.20}, head_color = {0.28, 0.08, 0.28},
        horn_color = {0.50, 0.15, 0.50}, eye_color = {1.0, 0.0, 0.5},
    }),
    BossDefinition({
        id = "cheonnyeon_namu", name = "Millennium Tree", name_kr = "천년 고목",
        description = "매 턴 뿌리가 패 1장을 감싼다(사용불가). 느리지만 강함",
        target_score = 680, rounds = 7, tier = "elite",
        gimmick = BossGimmick.Fog, gimmick_interval = 1,
        intro_dialogue = "천 년을 이 자리에 있었다... 서두를 것 없다...",
        defeat_dialogue = "뿌리가... 마침내... 풀린다...",
        victory_dialogue = "뿌리 속에서 영원히 잠들거라...",
        yeop_reward = 65, drops_legendary_talisman = true,
        body_color = {0.25, 0.18, 0.08}, head_color = {0.32, 0.25, 0.12},
        horn_color = {0.15, 0.40, 0.10}, eye_color = {0.5, 0.9, 0.3},
    }),
    BossDefinition({
        id = "bul_dokkebi", name = "Fire Will-o-Wisp", name_kr = "도깨비불",
        description = "매 턴 랜덤 카드 1장 소각. 소각된 카드는 엽전 +3",
        target_score = 360, rounds = 5, tier = "normal",
        gimmick = BossGimmick.ConsumeHighest, gimmick_interval = 1,
        intro_dialogue = "일렁일렁... 따라오면 안 돼...",
        defeat_dialogue = "꺼져간다... 일렁...",
        victory_dialogue = "따라왔구나... 이제 돌아갈 수 없어...",
        yeop_reward = 28,
        body_color = {0.10, 0.30, 0.60}, head_color = {0.15, 0.40, 0.75},
        horn_color = {0.25, 0.55, 0.90}, eye_color = {0.3, 0.8, 1.0},
    }),
}

-- ============================================================
-- 윤회 보스 (관문 10 고정) — 염라대왕
-- 모든 일반 보스를 격파해야 비로소 만날 수 있다
-- ============================================================
local yeomra = BossDefinition({
    id = "yeomra", name = "King Yeomra", name_kr = "염라대왕",
    description = "광을 무효화시킨다. 피와 띠만으로 승부하라. 저승의 최종 심판자.",
    target_score = 850, rounds = 7, tier = "boss",
    gimmick = BossGimmick.NoBright, gimmick_interval = 1,
    intro_dialogue = "감히 이승으로 돌아가겠다고? 한 판 뜨자!",
    defeat_dialogue = "허... 대단하구나. 이승의 길을 열어주마.",
    victory_dialogue = "저승에서 영원히 내 패거리가 되거라!",
    yeop_reward = 100, drops_legendary_talisman = true,
    body_color = {0.10, 0.08, 0.08}, head_color = {0.15, 0.10, 0.10},
    horn_color = {1.0, 0.84, 0.0}, eye_color = {1.0, 0.0, 0.0},
})

-- ============================================================
-- 재앙 보스 4종 (윤회 3, 5, 8, 10+ 에서 염라 대신 등장)
-- ============================================================
local calamity_bosses = {
    BossDefinition({
        id = "skeleton_general", name = "Skeleton General", name_kr = "백골대장",
        description = "매 턴 카드 1장을 해골패로 변환. 해골 3개 = 즉사.",
        target_score = 8000, rounds = 5, tier = "calamity",
        gimmick = BossGimmick.Skullify, gimmick_interval = 1,
        intro_dialogue = "뼈뼈뼈... 살이 아까운가? 뼈만 남겨주마...",
        defeat_dialogue = "깔깔깔... 뼈는 거짓말을 하지 않아...",
        victory_dialogue = "뼈밖에 남지 않았구나! 껄껄껄!",
        yeop_reward = 500, drops_legendary_talisman = true,
        body_color = {0.55, 0.50, 0.45}, head_color = {0.65, 0.60, 0.55},
        horn_color = {0.80, 0.75, 0.65}, eye_color = {1.0, 0.3, 0.1},
    }),
    BossDefinition({
        id = "ninetail_king", name = "Nine-Tail Fox King", name_kr = "구미호 왕",
        description = "30% 카드가 가짜. 매칭 실패 시 -50칩. 3턴마다 손패 셔플.",
        target_score = 10000, rounds = 5, tier = "calamity",
        gimmick = BossGimmick.FakeCards, gimmick_interval = 3,
        intro_dialogue = "후후... 진짜와 가짜를 구분할 수 있겠느냐?",
        defeat_dialogue = "이 눈으로... 간파하다니...",
        victory_dialogue = "환상 속에서 영원히 헤매거라! 후후후!",
        yeop_reward = 600, drops_legendary_talisman = true,
        body_color = {0.75, 0.45, 0.10}, head_color = {0.90, 0.60, 0.15},
        horn_color = {1.0, 0.85, 0.50}, eye_color = {0.2, 0.9, 0.9},
    }),
    BossDefinition({
        id = "imugi", name = "Imugi", name_kr = "이무기",
        description = "경쟁전: 이무기도 매 턴 +50점 누적. 먼저 목표 달성해야 승리.",
        target_score = 15000, rounds = 6, tier = "calamity",
        gimmick = BossGimmick.Competitive, gimmick_interval = 1,
        intro_dialogue = "나도 용이 되려면 이겨야 한다! 승부다!",
        defeat_dialogue = "크으... 결국 승천은 네 몫이었구나...",
        victory_dialogue = "하하하! 이무기는 결국 용이 되었다!",
        yeop_reward = 800, drops_legendary_talisman = true,
        body_color = {0.10, 0.25, 0.50}, head_color = {0.12, 0.30, 0.60},
        horn_color = {0.30, 0.60, 0.90}, eye_color = {1.0, 0.8, 0.1},
    }),
    BossDefinition({
        id = "underworld_flower", name = "Underworld Flower King", name_kr = "저승꽃",
        description = "매 라운드 강화 1개 비활성 + 5턴마다 부적 셔플 + 족보명 숨김.",
        target_score = 20000, rounds = 6, tier = "calamity",
        gimmick = BossGimmick.Suppress, gimmick_interval = 5,
        intro_dialogue = "아름답지 않니? 이 꽃들은 전부 망자의 혼으로 피어났단다.",
        defeat_dialogue = "꽃잎이... 흩날린다... 아름답구나...",
        victory_dialogue = "너도 꽃이 되어라. 영원히... 아름답게...",
        yeop_reward = 1000, drops_legendary_talisman = true,
        body_color = {0.60, 0.20, 0.40}, head_color = {0.70, 0.25, 0.50},
        horn_color = {0.90, 0.50, 0.70}, eye_color = {1.0, 0.4, 0.6},
    }),
}

-- ============================================================
-- Public API
-- ============================================================
local BossData = {}

BossData.BossGimmick = BossGimmick
BossData.BossDefinition = BossDefinition

--- 일반 보스 풀 (도감용)
function BossData.get_all_bosses()
    return all_bosses
end

--- 염라대왕 (윤회 보스)
function BossData.get_yeomra()
    return yeomra
end

--- 도감용: 모든 보스 (일반 + 염라 + 재앙)
function BossData.get_all_bosses_for_collection()
    local result = {}
    for _, b in ipairs(all_bosses) do result[#result+1] = b end
    result[#result+1] = yeomra
    for _, b in ipairs(calamity_bosses) do result[#result+1] = b end
    return result
end

function BossData.get_calamity_bosses()
    return calamity_bosses
end

--- 관문 번호에 따른 보스 선택
--- 관문 1~9: 일반 보스 풀에서 랜덤, 관문 10: 염라대왕
function BossData.get_boss_for_realm(realm_number, spiral_number)
    -- 관문 10 = 윤회 보스
    if realm_number == 10 then
        -- 재앙 윤회에서는 재앙 보스
        local calamity = BossData.get_calamity_boss(spiral_number)
        if calamity then return calamity end
        return yeomra
    end
    -- 관문 1~9: 풀에서 랜덤
    return all_bosses[math.random(#all_bosses)]
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
    if id == "yeomra" then return yeomra end
    for _, boss in ipairs(all_bosses) do
        if boss.id == id then return boss end
    end
    for _, boss in ipairs(calamity_bosses) do
        if boss.id == id then return boss end
    end
    return nil
end

--- 재앙 보스 가져오기 (윤회 번호 기반)
function BossData.get_calamity_boss(spiral_number)
    if spiral_number == 3 then return calamity_bosses[1]      -- 백골대장
    elseif spiral_number == 5 then return calamity_bosses[2]  -- 구미호 왕
    elseif spiral_number == 8 then return calamity_bosses[3]  -- 이무기
    elseif spiral_number >= 10 then return calamity_bosses[4] -- 저승꽃
    else return nil
    end
end

return BossData

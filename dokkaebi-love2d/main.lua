--- 도깨비의 패 — Love2D
--- 통일 UI 시스템: 모든 화면이 동일한 디자인 언어 사용

love.graphics.setDefaultFilter("nearest", "nearest")
love.graphics.setLineStyle("rough")  -- 안티앨리어싱 제거

-- ===========================
-- 픽셀아트 렌더링 시스템
-- ===========================
love.graphics.setDefaultFilter("nearest", "nearest")
math.randomseed(os.time())

local DeckManager    = require("src.cards.deck_manager")
local HandEvaluator  = require("src.cards.hand_evaluator")
local BossData       = require("src.combat.boss_data")
local BossBattle     = require("src.combat.boss_battle")
local NumFmt         = require("src.core.number_formatter")
local CardRenderer   = require("src.ui.card_renderer")
local Button         = require("src.ui.button")
local PlayerState    = require("src.core.player_state")
local SM             = require("src.core.spiral_manager")
local SpiralManager  = SM.SpiralManager
local SpiralBlessing = SM.SpiralBlessing
local DU             = require("src.ui.draw_utils")
local FX             = require("src.ui.effects")
local SFX            = require("src.core.sfx")
local CardEnums      = require("src.cards.card_enums")
local TalismanDB     = require("src.talismans.talisman_database")
local TalismanInst   = require("src.talismans.talisman_data").TalismanInstance
local BGM            = require("src.core.bgm")
local IconGen        = require("src.ui.icon_generator")
local Icons          = require("src.ui.icons")
local PIX            = require("src.ui.pixel_icons")
local BossIcons      = require("src.ui.boss_icons")
local SpriteLoader   = require("src.ui.sprite_loader")
local YokboGuide     = require("src.ui.yokbo_guide")
local AchMod         = require("src.core.achievement_manager")
local AchievementManager = AchMod.AchievementManager

-- ===========================
-- 디자인 토큰 (전역 통일)
-- ===========================
local W, H = 1280, 720  -- 실행 시 love.update에서 실제 창 크기로 갱신
local fonts = {}

-- 색상 팔레트 — 저승 화투 (어둠 + 핏빛 + 금빛)
local PAL = {
    -- ── 배경/패널 ──
    bg        = {0.04,  0.03,  0.07},          -- 심연 흑자
    panel     = {0.07,  0.05,  0.11, 0.95},    -- 짙은 연기
    panel_alt = {0.09,  0.06,  0.14, 0.92},    -- 귀화 연기
    border    = {0.30,  0.15,  0.22},          -- 핏빛 테두리
    -- ── 강조/텍스트 ──
    gold      = {0.95,  0.72,  0.15},          -- 도깨비불 금색 (엽전, 제목)
    white     = {0.95,  0.92,  0.85},          -- 한지빛 (일반 텍스트)
    dim       = {0.62,  0.56,  0.58},          -- 먹물 회색 (부가 텍스트)
    -- ── 포인트 색상 ──
    red       = {0.72,  0.10,  0.08},          -- 선혈 (위험/공격)
    cyan      = {0.55,  0.82,  0.78},          -- 삼도천 (정보/설명)
    blue      = {0.12,  0.20,  0.50},          -- 저승 심연
    purple    = {0.52,  0.18,  0.55},          -- 봉인/저주
    green     = {0.25,  0.55,  0.35},          -- 귀화 (미사용, 호환용)
    -- ── HP 바 ──
    hp_bg     = {0.12,  0.04,  0.04},
    hp_high   = {0.65,  0.12,  0.08},          -- 여유
    hp_mid    = {0.78,  0.38,  0.08},          -- 주의
    hp_low    = {0.88,  0.18,  0.12},          -- 위험
    -- ── 버튼 ──
    btn_red   = {0.52,  0.10,  0.08},          -- 핏빛 (공격/위험)
    btn_blue  = {0.10,  0.08,  0.38},          -- 심연 (고/스톱)
    btn_green = {0.55,  0.40,  0.08},          -- 도깨비불 황금 (구매/선택/긍정)
    btn_dim   = {0.13,  0.10,  0.17},          -- 짙은 어둠 (비활성)
    -- ── 저승 전용 ──
    blood     = {0.58,  0.04,  0.04},          -- 짙은 핏빛
    ghost     = {0.62,  0.70,  0.80},          -- 귀신불 청백
    flame     = {0.88,  0.48,  0.08},          -- 도깨비불 주황
    seal      = {0.65,  0.28,  0.72},          -- 각인 자주
}

-- 공통 UI 크기
local UI = {
    bar_h    = 30,   -- 상단 바 높이
    btn_h    = 32,   -- 버튼 높이
    btn_w    = 140,  -- 버튼 폭
    pad      = 12,   -- 패딩
    radius   = 0,    -- 도트 스타일: 직각
    card_gap = 6,    -- 카드 간격
}

-- ===========================
-- 게임 상태 (모든 함수보다 먼저 선언)
-- ===========================

local S = {
    state = "main_menu",
    player = nil, spiral = nil, deck = nil,
    boss = nil, battle = nil,
    round = 0, max_rounds = 5,
    chips = 0, mult = 1, go_count = 0, plays = 0,
    hand = {}, selected = {}, messages = {},
    shop_items = {}, event = nil, upgrades = {},
    -- 영구 데이터 (런 간 유지)
    soul = 0,           -- 넋 (영구 강화 화폐)
    perm_chips = 0,     -- 영구 칩 보너스
    perm_mult = 0,      -- 영구 배수 보너스
    perm_lives = 0,     -- 영구 추가 체력
    perm_yeop = 0,      -- 영구 시작 엽전
    -- 패의 길 (확장)
    perm_hand = 0,      -- 시작 손패 추가
    perm_yokbo = 0,     -- 족보 등록 횟수 추가
    -- 부적의 길
    perm_talisman = 0,  -- 부적 슬롯 추가
    perm_tali_rate = 0, -- 상점 희귀 부적 확률 증가
    -- 생존의 길
    perm_go_ins = 0,    -- Go 실패 면제 확률
    perm_heal = 0,      -- 보스 격파 시 체력 회복
    perm_shop_disc = 0, -- 상점 할인
    total_runs = 0,     -- 총 런 횟수
    best_realm = 0,     -- 최고 관문
    total_kills = 0,    -- 총 보스 격파 수
    total_go = 0,       -- 총 Go 횟수
    total_deaths = 0,   -- 총 사망 횟수
    total_yeop_earned = 0, -- 총 엽전 획득
    consecutive_stops = 0, -- 연속 스톱 횟수
    -- 업적 매니저
    ach = nil,
    -- 발견 추적 (도감용)
    discovered = {
        bosses = {},     -- {boss_id = true, ...}
        talismans = {},  -- {talisman_id = true, ...}
        yokbos = {},     -- {yokbo_id = true, ...}
        companions = {}, -- {comp_id = true, ...}
    },
    _damage_taken_this_battle = 0, -- 이번 배틀 피격량
}

local function msg(s)
    table.insert(S.messages, 1, s)
    if #S.messages > 5 then table.remove(S.messages) end
end

-- 게임오버 헬퍼 (사망 시 업적 체크 + 통계 업데이트)
local function trigger_game_over()
    S.total_deaths = (S.total_deaths or 0) + 1
    S.total_runs = (S.total_runs or 0) + 1
    if S.ach then S.ach:check_progress(nil, S.best_realm, S.total_deaths) end
    S.state = "game_over"
    SFX.play("game_over")
    save_meta()
end

-- 중앙 연출 메시지 (큰 글씨로 화면 중앙에 페이드인/아웃)
local center_msg = nil      -- {text, sub, timer, duration, color}

local function show_center_msg(text, sub, duration, color)
    center_msg = {
        text = text,
        sub = sub or "",
        timer = 0,
        duration = duration or 2.0,
        color = color or PAL.gold,
    }
end

local function update_center_msg(dt)
    if not center_msg then return end
    center_msg.timer = center_msg.timer + dt
    if center_msg.timer >= center_msg.duration then
        center_msg = nil
    end
end

local function draw_center_msg()
    if not center_msg then return end
    local sc = love.graphics.setColor
    local t = center_msg.timer
    local d = center_msg.duration
    -- 페이드: 0~0.3초 페이드인, 마지막 0.5초 페이드아웃
    local alpha = 1
    if t < 0.3 then alpha = t / 0.3
    elseif t > d - 0.5 then alpha = (d - t) / 0.5 end
    alpha = math.max(0, math.min(1, alpha))

    -- 반투명 배경 띠
    sc(0, 0, 0, 0.6 * alpha)
    love.graphics.rectangle("fill", 0, H/2 - 50, W, 100)
    -- 상하 테두리
    local c = center_msg.color
    sc(c[1], c[2], c[3], 0.5 * alpha)
    love.graphics.rectangle("fill", 0, H/2 - 50, W, 2)
    love.graphics.rectangle("fill", 0, H/2 + 48, W, 2)

    -- 메인 텍스트
    love.graphics.setFont(fonts.xl)
    sc(c[1], c[2], c[3], alpha)
    love.graphics.printf(center_msg.text, 0, H/2 - 30, W, "center")
    -- 서브 텍스트
    if center_msg.sub ~= "" then
        love.graphics.setFont(fonts.m)
        sc(0.7, 0.7, 0.75, alpha * 0.8)
        love.graphics.printf(center_msg.sub, 0, H/2 + 16, W, "center")
    end
end

local bosses = BossData.get_all_bosses()

-- ===========================
-- 공통 UI 함수
-- ===========================

local btns = {}
local card_rects = {}
local hover_idx = nil
local talisman_rects = {}
local hover_talisman = nil
local show_yokbo_guide = false
local combo_rects = {}
local hover_combo = nil

-- 손패 정렬 모드: "none", "month", "type", "value"
local sort_mode = "none"
local sort_labels = {none="정렬 없음", month="월별", type="종류별", value="가치순"}
local sort_order = {"none", "month", "type", "value"}

local function sort_hand()
    if sort_mode == "none" then return end
    local CTV = CardEnums.CardTypeValue
    if sort_mode == "month" then
        table.sort(S.hand, function(a, b)
            if a.month ~= b.month then return a.month < b.month end
            return (CTV[a.card_type] or 0) > (CTV[b.card_type] or 0)
        end)
    elseif sort_mode == "type" then
        table.sort(S.hand, function(a, b)
            local va, vb = CTV[a.card_type] or 0, CTV[b.card_type] or 0
            if va ~= vb then return va > vb end
            return a.month < b.month
        end)
    elseif sort_mode == "value" then
        table.sort(S.hand, function(a, b)
            local va, vb = CTV[a.card_type] or 0, CTV[b.card_type] or 0
            local sa = va * 100 + a.month
            local sb = vb * 100 + b.month
            return sa > sb
        end)
    end
    SFX.play("card_deal")
end

local function set(c, a) love.graphics.setColor(c[1], c[2], c[3], a or c[4] or 1) end

-- 패널: CSS box-shadow 스타일
local function panel(x, y, w, h, alt)
    DU.shadow_panel(x, y, w, h, UI.radius, alt and PAL.panel_alt or PAL.panel, 0.25)
end

-- 버튼 생성 (통일된 크기)
local function ui_btn(text, x, y, w, h, color, fn)
    local b = Button.new(text, x, y, w or UI.btn_w, h or UI.btn_h, color or PAL.btn_dim, fn)
    btns[#btns+1] = b; b:draw(fonts.m); return b
end

-- 상단 바: 모든 화면에서 동일
local function topbar(title_extra)
    set(PAL.panel)
    love.graphics.rectangle("fill", 0, 0, W, UI.bar_h)
    set(PAL.border)
    love.graphics.line(0, UI.bar_h, W, UI.bar_h)

    if not S or not S.player then return end
    love.graphics.setFont(fonts.s)
    set(PAL.dim)
    local sp = S.spiral and S.spiral.current_spiral or 1
    local rm = S.spiral and S.spiral.current_realm or 1
    love.graphics.print(string.format("윤회 %d |관문 %d", sp, rm), UI.pad, 8)

    -- 체력 (도트 하트 아이콘)
    local hx_start = W*0.25 - (S.player.MAX_LIVES * 9)
    for i = 1, S.player.MAX_LIVES do
        if i <= S.player.lives then
            PIX.draw(PIX.heart, hx_start + (i-1)*18, 6, 16)
        else
            PIX.draw(PIX.heart_empty, hx_start + (i-1)*18, 6, 16)
        end
    end

    -- 엽전 + 넋 (도트 아이콘 포함)
    local yeop_str = S.player.yeop .. "냥"
    local soul_str = S.soul .. "넋"
    local info_w = fonts.s:getWidth(yeop_str .. "   " .. soul_str) + 44
    local info_x = W - UI.pad - info_w
    PIX.draw(PIX.coin, info_x, 5, 14)
    set(PAL.gold)
    love.graphics.print(yeop_str, info_x + 18, 8)
    local soul_x = info_x + 18 + fonts.s:getWidth(yeop_str) + 10
    PIX.draw(PIX.soul, soul_x, 5, 14)
    set(PAL.cyan)
    love.graphics.print(soul_str, soul_x + 18, 8)

    if title_extra then
        set(PAL.white)
        love.graphics.printf(title_extra, W * 0.35, 8, W * 0.3, "center")
    end
end

-- 메시지 로그
local function draw_msgs(y, center)
    if #S.messages == 0 then return end
    love.graphics.setFont(fonts.s)
    local fh = fonts.s:getHeight()
    local count = math.min(#S.messages, 4)
    if center then
        -- 중앙 정렬 메시지 패널
        local pw, ph = 500, count * fh + 8
        local px = W/2 - pw/2
        set({0.04, 0.03, 0.08, 0.7})
        love.graphics.rectangle("fill", px, y, pw, ph)
        set({0.15, 0.12, 0.22, 0.5})
        love.graphics.rectangle("line", px, y, pw, ph)
        for i = 1, count do
            local alpha = math.max(0.3, 1 - (i-1) * 0.25)
            set(i == 1 and PAL.gold or PAL.dim, alpha)
            love.graphics.printf(S.messages[i], px + 8, y + 4 + (i-1) * fh, pw - 16, "center")
        end
    else
        for i = 1, count do
            set(PAL.gold, math.max(0, 1 - (i-1) * 0.20))
            love.graphics.print("  " .. S.messages[i], UI.pad, y + (i-1) * fh)
        end
    end
end

-- 제목 (화면 상단 센터)
local function title(text, y)
    love.graphics.setFont(fonts.l)
    set(PAL.gold)
    love.graphics.printf(text, 0, y or 50, W, "center")
end

-- 부제목
local function subtitle(text, y)
    love.graphics.setFont(fonts.s)
    set(PAL.dim)
    love.graphics.printf(text, W * 0.15, y or 80, W * 0.7, "center")
end

-- (S, msg, bosses는 위에서 선언됨)

-- ===========================
-- 게임 로직
-- ===========================

local function new_game()
    S.total_runs = S.total_runs + 1
    S.player = PlayerState.new()
    -- 영구 강화 반영 (3갈래)
    -- perm_chips/perm_mult 는 S.chips/S.mult 계산식에서 별도 반영됨.
    -- wave_*_bonus 는 런 내 이벤트/상점 누적분만 담아야 함 → 0으로 초기화.
    S.player.lives = 4 + S.perm_lives
    S.player.yeop = 40 + S.perm_yeop
    S.player.wave_chip_bonus = 0   -- 버그수정: perm_chips 이중 적용 방지
    S.player.wave_mult_bonus = 0   -- 버그수정: perm_mult 이중 적용 방지
    S.player.MAX_TALISMAN_SLOTS = 5 + (S.perm_talisman or 0)
    S.spiral = SpiralManager.new()
    S.deck = DeckManager.new()
    S.messages = {}; S.selected = {}; S._eaten_combos = {}
    msg("넌 죽었다. 저승의 도깨비들과 고스톱을 치자.")
end

local function gen_shop()
    S.shop_items = {}

    -- 부적 DB에서 가져오기 (이미 보유한 부적 제외)
    local all_tal = TalismanDB.get_all()
    local owned = {}
    for _, t in ipairs(S.player.talismans) do
        if t.data then owned[t.data.name_kr or ""] = true end
    end

    -- 레어리티별 가격
    local rarity_cost = {common=30, rare=55, legendary=90, cursed=15}

    -- 저주 부적 제외 + 미보유만 필터
    local pool = {}
    for _, t in ipairs(all_tal) do
        if not t.is_curse and not owned[t.name_kr] then
            pool[#pool+1] = t
        end
    end

    -- 셔플 후 최대 3개
    for i = #pool, 2, -1 do local j = math.random(1,i); pool[i], pool[j] = pool[j], pool[i] end
    local count = math.min(3, #pool)
    for i = 1, count do
        local t = pool[i]
        local cost = rarity_cost[t.rarity] or 50
        -- 효과 요약 텍스트
        local desc = t.description_kr
        -- 칩/배수 효과 추출
        local effect = {}
        if t.effect_type == "add_chips" then effect.chip = t.effect_value
        elseif t.effect_type == "add_mult" then effect.mult = t.effect_value
        elseif t.effect_type == "multiply_mult" then effect.mult_x = t.effect_value
        elseif t.effect_type == "reduce_target" then effect.target_reduce = t.effect_value
        end
        if t.secondary_mult_bonus > 0 then effect.mult = t.secondary_mult_bonus end

        S.shop_items[#S.shop_items+1] = {
            name=t.name_kr, cost=cost, type="talisman", sold=false,
            desc=desc, effect=effect, talisman_data=t, rarity=t.rarity
        }
    end

    -- 고정 아이템 후보
    local extras = {
        {name="체력 회복", cost=75, type="health", sold=false, desc="체력 +1"},
        {name="패 팩(소)", cost=40, type="card_pack", sold=false, desc="손패 +2"},
    }
    if math.random() < 0.4 then
        extras[#extras+1] = {name="혼백 거울", cost=120, type="copy_mirror", sold=false, desc="다음 판: 족보 카드 1장 복사"}
    end
    if math.random() < 0.2 then
        extras[#extras+1] = {name="윤회의 실", cost=200, type="copy_all", sold=false, desc="다음 판: 족보 카드 전부 복사"}
    end
    -- 최대 5개까지만
    for _, e in ipairs(extras) do
        if #S.shop_items >= 5 then break end
        S.shop_items[#S.shop_items+1] = e
    end
end

local function gen_event()
    local evts = {
        {title="저승 방랑자", desc="길을 잃은 다른 망자.\n\"도와줘... 길을 잃었어...\"",
         choices={
            {text="도와준다 (칩 +15)", result="감사! 다음 보스전 칩 +15",
             fn=function() S.player.wave_chip_bonus=S.player.wave_chip_bonus+15 end},
            {text="무시한다", result="...", fn=function() end},
            {text="소지품 뒤진다 (+50냥, 다음 보스 HP +20%)", result="+50냥, 하지만 다음 보스가 강해진다...",
             fn=function() S.player.yeop=S.player.yeop+50; S._next_boss_hp_mult=(S._next_boss_hp_mult or 1)*1.2 end},
         }},
        {title="도깨비불의 거래", desc="도깨비불이 너울너울 춤추며 다가온다.\n\"내 불꽃을 나눠줄까?\n대신 네 온기를 좀 가져갈게.\"",
         choices={
            {text="불꽃을 받는다 (배수+0.8, 체력-1)", result="푸른 불꽃이 카드에 깃든다.",
             fn=function() S.player.wave_mult_bonus=S.player.wave_mult_bonus+0.8; S.player.lives=math.max(1,S.player.lives-1) end},
            {text="온기를 지킨다 (체력+1)", result="따뜻함을 잃지 않았다.",
             fn=function() S.player.lives=math.min(S.player.lives+1,10) end},
            {text="불꽃을 잡는다 (칩+30, 50% 체력-2)", result="",
             fn=function()
                S.player.wave_chip_bonus=S.player.wave_chip_bonus+30
                if math.random() < 0.5 then S.player.lives=math.max(1,S.player.lives-2); msg("화상! 체력 -2") end
             end},
         }},
        {title="운명의 갈림길", desc="두 개의 문이 있다.\n붉은 문에서는 뜨거운 기운이,\n푸른 문에서는 차가운 기운이 느껴진다.",
         choices={
            {text="붉은 문 (칩 +25, 보스 기믹 봉인)", result="불꽃이 타오른다! 다음 보스의 기믹이 봉인된다!",
             fn=function()
                S.player.wave_chip_bonus=S.player.wave_chip_bonus+25
                S._next_boss_gimmick_seal = true
             end},
            {text="푸른 문 (배수 +1, 보스 HP -15%)", result="차가운 기운이 스며든다. 다음 보스가 약해진다.",
             fn=function()
                S.player.wave_mult_bonus=S.player.wave_mult_bonus+1
                S._next_boss_hp_mult=(S._next_boss_hp_mult or 1)*0.85
             end},
            {text="되돌아간다 (+1 체력)", result="안전한 선택. 체력 +1",
             fn=function() S.player.lives=math.min(S.player.lives+1,10) end},
         }},
        {title="삼도천 강가", desc="삼도천 강물이 반짝인다.\n\"기도를 올리면 무언가 응답할 것 같다...\"",
         choices={
            {text="기도한다 (-40냥, 다음 판 손패 +3)", result="빛이 응답한다. 다음 판 손패가 늘어난다!",
             fn=function()
                S.player.yeop=math.max(0,S.player.yeop-40)
                S.player.next_round_hand_bonus=(S.player.next_round_hand_bonus or 0)+3
             end},
            {text="동전을 던진다 (50% 확률 +100냥 / 전액 소멸)", result="",
             fn=function()
                if math.random() < 0.5 then
                    S.player.yeop=S.player.yeop+100
                    msg("행운! +100냥!")
                    show_center_msg("+100냥!", "운이 좋았다.", 1.5, PAL.gold)
                else
                    S.player.yeop=0
                    msg("엽전이 모두 사라졌다...")
                    show_center_msg("전액 소멸!", "강물이 모든 것을 삼켰다.", 1.5, PAL.red)
                end
             end},
            {text="그냥 지나간다", result="강물이 잔잔해진다.", fn=function() end},
         }},
        {title="과거의 도전자", desc="벽에 기대앉은 해골.\n손에 화투패 한 장을 쥐고 있다.\n\"이 사람도 이승으로 돌아가려 했던 걸까...\"",
         choices={
            {text="패를 가져간다 (칩 +20, 배수 +0.3)", result="해골의 패에서 힘이 흘러든다.",
             fn=function()
                S.player.wave_chip_bonus=S.player.wave_chip_bonus+20
                S.player.wave_mult_bonus=S.player.wave_mult_bonus+0.3
             end},
            {text="쉬어간다 (+2 체력)", result="잠시 쉬어간다. 체력이 회복된다.",
             fn=function() S.player.lives=math.min(S.player.lives+2,10) end},
         }},

        -- ═══ 추가 이벤트 ═══

        {title="저승사자의 제안", desc="저승사자가 길을 막는다.\n\"네 영혼의 일부를 주면 지름길을 열어주지.\"",
         choices={
            {text="영혼을 준다 (-1 체력, 다음 보스 HP -30%)", result="아프지만... 보스가 약해졌다.",
             fn=function()
                S.player.lives=math.max(1,S.player.lives-1)
                S._next_boss_hp_mult=(S._next_boss_hp_mult or 1)*0.7
             end},
            {text="거절한다 (배수 +0.5)", result="\"용감하군.\" 저승사자가 힘을 나눠준다.",
             fn=function() S.player.wave_mult_bonus=S.player.wave_mult_bonus+0.5 end},
         }},

        {title="귀신 도박장", desc="어둠 속에서 주사위 소리가 들린다.\n\"한 판 하지 않겠나? 건 것의 두 배를 주지.\"",
         choices={
            {text="체력을 건다 (50%: 체력 +3 / 체력 -2)", result="",
             fn=function()
                if math.random() < 0.5 then
                    S.player.lives=math.min(S.player.lives+3,10)
                    msg("승리! 체력 +3!")
                    show_center_msg("도박 승리!", "+3 체력", 1.5, PAL.gold)
                else
                    S.player.lives=math.max(1,S.player.lives-2)
                    msg("패배... 체력 -2")
                    show_center_msg("도박 패배...", "-2 체력", 1.5, PAL.red)
                end
             end},
            {text="엽전을 건다 (50%: +80냥 / -50냥)", result="",
             fn=function()
                if math.random() < 0.5 then
                    S.player.yeop=S.player.yeop+80; msg("승리! +80냥!")
                else
                    S.player.yeop=math.max(0,S.player.yeop-50); msg("패배... -50냥")
                end
             end},
            {text="안 한다", result="현명한 선택이다.", fn=function() end},
         }},

        {title="잊혀진 제단", desc="이끼 낀 제단 위에 부적이 놓여 있다.\n가져가면 힘을 얻겠지만,\n저주가 따라올 수도 있다.",
         choices={
            {text="부적을 가져간다 (칩+30, 배수+0.5, 체력-1)", result="강한 힘이 몸에 스며든다. 하지만 어딘가 아프다.",
             fn=function()
                S.player.wave_chip_bonus=S.player.wave_chip_bonus+30
                S.player.wave_mult_bonus=S.player.wave_mult_bonus+0.5
                S.player.lives=math.max(1,S.player.lives-1)
             end},
            {text="기도만 올린다 (체력 +1)", result="마음이 편안해진다.",
             fn=function() S.player.lives=math.min(S.player.lives+1,10) end},
            {text="제단을 부순다 (칩+50, 다음 보스 HP+30%)", result="파편에서 에너지가 폭발한다!",
             fn=function()
                S.player.wave_chip_bonus=S.player.wave_chip_bonus+50
                S._next_boss_hp_mult=(S._next_boss_hp_mult or 1)*1.3
             end},
         }},

        {title="도깨비 장터 뒷골목", desc="수상한 도깨비가 손짓한다.\n\"싸게 줄 테니 하나 사가.\"",
         choices={
            {text="수상한 물약 (-30냥, 배수+1)", result="으... 쓰지만 효과는 확실하다!",
             fn=function()
                S.player.yeop=math.max(0,S.player.yeop-30)
                S.player.wave_mult_bonus=S.player.wave_mult_bonus+1
             end},
            {text="금빛 가루 (-50냥, 칩+40)", result="카드가 금빛으로 빛난다!",
             fn=function()
                S.player.yeop=math.max(0,S.player.yeop-50)
                S.player.wave_chip_bonus=S.player.wave_chip_bonus+40
             end},
            {text="그냥 지나간다", result="\"체, 손님 아니었나.\"", fn=function() end},
         }},

        {title="지옥꽃 군락", desc="저승에서만 피는 붉은 꽃이 만발해 있다.\n꽃잎에서 이상한 향기가 난다.",
         choices={
            {text="꽃을 꺾는다 (칩+15, 내기 횟수+1)", result="꽃의 힘이 카드에 깃든다.",
             fn=function()
                S.player.wave_chip_bonus=S.player.wave_chip_bonus+15
                S.perm_yokbo=(S.perm_yokbo or 0)+1
             end},
            {text="향을 맡는다 (체력 전부 회복)", result="온 몸이 따뜻해진다...",
             fn=function() S.player.lives=10 end},
            {text="불태운다 (배수+1.5, 체력-2)", result="불꽃 속에서 힘이 솟구친다!",
             fn=function()
                S.player.wave_mult_bonus=S.player.wave_mult_bonus+1.5
                S.player.lives=math.max(1,S.player.lives-2)
             end},
         }},

        {title="망자의 편지", desc="바닥에 누군가의 편지가 떨어져 있다.\n\"이걸 읽으면 안 될 것 같기도 한데...\"",
         choices={
            {text="편지를 읽는다 (랜덤: 칩+40 또는 배수-0.5)", result="",
             fn=function()
                if math.random() < 0.6 then
                    S.player.wave_chip_bonus=S.player.wave_chip_bonus+40
                    msg("편지에서 힘이 느껴진다. 칩 +40!")
                else
                    S.player.wave_mult_bonus=math.max(0,S.player.wave_mult_bonus-0.5)
                    msg("저주받은 편지였다... 배수 -0.5")
                end
             end},
            {text="무덤에 묻어준다 (+30냥, +1 체력)", result="좋은 일을 했다. 마음이 편안하다.",
             fn=function()
                S.player.yeop=S.player.yeop+30
                S.player.lives=math.min(S.player.lives+1,10)
             end},
         }},

        {title="시간의 틈", desc="공간이 일그러진다.\n과거의 자신이 보인다.\n\"지금의 너에게 하나를 줄 수 있어.\"",
         choices={
            {text="과거의 힘 (칩+25, 배수+0.5)", result="과거의 기억이 힘이 된다.",
             fn=function()
                S.player.wave_chip_bonus=S.player.wave_chip_bonus+25
                S.player.wave_mult_bonus=S.player.wave_mult_bonus+0.5
             end},
            {text="과거의 지혜 (손패+3, 내기+1)", result="더 많은 선택지가 보인다.",
             fn=function()
                S.perm_hand=(S.perm_hand or 0)+3
                S.perm_yokbo=(S.perm_yokbo or 0)+1
             end},
            {text="과거의 재물 (+100냥)", result="주머니가 무거워진다.",
             fn=function() S.player.yeop=S.player.yeop+100 end},
         }},

        {title="떠도는 악사", desc="피리를 부는 해골이 앉아 있다.\n\"한 곡 들어볼래? 공짜는 아니지만.\"",
         choices={
            {text="듣는다 (-20냥, 배수+0.8)", result="음악이 영혼을 깨운다.",
             fn=function() S.player.yeop=math.max(0,S.player.yeop-20); S.player.wave_mult_bonus=S.player.wave_mult_bonus+0.8 end},
            {text="같이 연주한다 (칩+10, 배수+0.3, 체력+1)", result="즐거운 합주!",
             fn=function() S.player.wave_chip_bonus=S.player.wave_chip_bonus+10; S.player.wave_mult_bonus=S.player.wave_mult_bonus+0.3; S.player.lives=math.min(S.player.lives+1,10) end},
            {text="악기를 뺏는다 (칩+35, 다음 보스 기믹 2회)", result="해골이 저주를 내린다...",
             fn=function() S.player.wave_chip_bonus=S.player.wave_chip_bonus+35 end},
         }},

        {title="저승 온천", desc="뜨거운 물이 솟아오르는 온천.\n\"들어가면 상처가 나을 것 같다.\n하지만 오래 있으면 위험해 보인다.\"",
         choices={
            {text="잠깐 담근다 (체력+2)", result="따뜻하다... 상처가 낫는다.",
             fn=function() S.player.lives=math.min(S.player.lives+2,10) end},
            {text="오래 담근다 (체력 전회복, 칩-10)", result="완전히 회복! 하지만 힘이 좀 빠졌다.",
             fn=function() S.player.lives=10; S.player.wave_chip_bonus=math.max(0,S.player.wave_chip_bonus-10) end},
            {text="물을 떠간다 (+40냥)", result="이 물을 팔면 돈이 되겠다.",
             fn=function() S.player.yeop=S.player.yeop+40 end},
         }},

        {title="저승 점술사", desc="눈이 없는 할머니가 점을 쳐준다.\n\"네 운명을 보여줄까?\"",
         choices={
            {text="본다 (랜덤: 대길=칩+50 / 대흉=체력-2)", result="",
             fn=function()
                if math.random() < 0.4 then
                    S.player.wave_chip_bonus=S.player.wave_chip_bonus+50
                    msg("대길! 엄청난 힘이!"); show_center_msg("대길!", "칩 +50", 1.5, PAL.gold)
                else
                    S.player.lives=math.max(1,S.player.lives-2)
                    msg("대흉... 체력 -2"); show_center_msg("대흉...", "체력 -2", 1.5, PAL.red)
                end
             end},
            {text="안 본다 (배수+0.3)", result="모르는 게 약이다.",
             fn=function() S.player.wave_mult_bonus=S.player.wave_mult_bonus+0.3 end},
         }},

        {title="업경대", desc="거대한 거울이 길을 막고 있다.\n거울에 비친 자신의 과거가 보인다.",
         choices={
            {text="과거를 받아들인다 (칩+20, 배수+0.5)", result="과거의 힘이 현재에 깃든다.",
             fn=function() S.player.wave_chip_bonus=S.player.wave_chip_bonus+20; S.player.wave_mult_bonus=S.player.wave_mult_bonus+0.5 end},
            {text="거울을 깨뜨린다 (칩+40, 체력-1)", result="파편이 손을 베었지만 힘을 얻었다.",
             fn=function() S.player.wave_chip_bonus=S.player.wave_chip_bonus+40; S.player.lives=math.max(1,S.player.lives-1) end},
            {text="뒤를 돌아본다 (+60냥)", result="거울 뒤에 보물이 숨겨져 있었다.",
             fn=function() S.player.yeop=S.player.yeop+60 end},
         }},

        {title="구미호의 유혹", desc="아름다운 여인이 웃으며 다가온다.\n\"나와 놀지 않겠니?\"\n꼬리가 살짝 보인다.",
         choices={
            {text="놀아준다 (배수+1.5, 다음 보스 HP+25%)", result="즐거웠다... 하지만 대가가 있다.",
             fn=function() S.player.wave_mult_bonus=S.player.wave_mult_bonus+1.5; S._next_boss_hp_mult=(S._next_boss_hp_mult or 1)*1.25 end},
            {text="정체를 밝힌다 (칩+25)", result="\"쳇, 들켰네.\" 구미호가 선물을 남기고 사라진다.",
             fn=function() S.player.wave_chip_bonus=S.player.wave_chip_bonus+25 end},
            {text="도망친다 (체력+1)", result="위험을 피했다.",
             fn=function() S.player.lives=math.min(S.player.lives+1,10) end},
         }},

        {title="도깨비 씨름판", desc="도깨비들이 씨름을 하고 있다.\n\"넌 이승 놈이지? 한 판 붙자!\"",
         choices={
            {text="도전한다 (50%: 칩+45/체력-2)", result="",
             fn=function()
                if math.random() < 0.5 then
                    S.player.wave_chip_bonus=S.player.wave_chip_bonus+45; msg("이겼다! 칩 +45!"); show_center_msg("승리!", "칩 +45", 1.5, PAL.gold)
                else
                    S.player.lives=math.max(1,S.player.lives-2); msg("졌다... 체력 -2"); show_center_msg("패배...", "체력 -2", 1.5, PAL.red)
                end
             end},
            {text="구경한다 (칩+10)", result="구경하는 것도 나쁘지 않다.",
             fn=function() S.player.wave_chip_bonus=S.player.wave_chip_bonus+10 end},
         }},

        {title="황천강 뱃사공", desc="뱃사공이 배를 저어 온다.\n\"건너편에 보물이 있다.\n뱃삯은 비싸지만.\"",
         choices={
            {text="탄다 (-60냥, 칩+35, 배수+0.8)", result="건너편에 힘이 기다리고 있었다.",
             fn=function() S.player.yeop=math.max(0,S.player.yeop-60); S.player.wave_chip_bonus=S.player.wave_chip_bonus+35; S.player.wave_mult_bonus=S.player.wave_mult_bonus+0.8 end},
            {text="헤엄친다 (체력-1, 칩+20)", result="차갑다... 하지만 건넜다.",
             fn=function() S.player.lives=math.max(1,S.player.lives-1); S.player.wave_chip_bonus=S.player.wave_chip_bonus+20 end},
            {text="안 건넌다", result="때론 안전이 최선이다.", fn=function() end},
         }},

        {title="도깨비 감투", desc="바닥에 낡은 감투가 놓여 있다.\n쓰면 투명해진다고 한다.",
         choices={
            {text="쓴다 (다음 보스 반격 전부 무효)", result="몸이 투명해진다! 보스가 널 볼 수 없다!",
             fn=function() S._next_counter_immune = true end},
            {text="팔아버린다 (+80냥)", result="골동품상이 비싸게 산다.",
             fn=function() S.player.yeop=S.player.yeop+80 end},
         }},

        {title="해골탑", desc="해골이 탑처럼 쌓여 있다.\n맨 위에 빛나는 무언가가 보인다.",
         choices={
            {text="올라간다 (60%: 칩+50, 배수+1 / 40%: 체력-3)", result="",
             fn=function()
                if math.random() < 0.6 then
                    S.player.wave_chip_bonus=S.player.wave_chip_bonus+50; S.player.wave_mult_bonus=S.player.wave_mult_bonus+1
                    msg("정상 도착! 엄청난 보물!"); show_center_msg("대박!", "칩+50, 배수+1", 1.5, PAL.gold)
                else
                    S.player.lives=math.max(1,S.player.lives-3)
                    msg("무너졌다! 체력 -3!"); show_center_msg("붕괴!", "체력 -3", 1.5, PAL.red)
                end
             end},
            {text="밑에서 줍는다 (칩+15)", result="떨어진 조각을 줍는다.",
             fn=function() S.player.wave_chip_bonus=S.player.wave_chip_bonus+15 end},
         }},

        {title="원귀의 부탁", desc="울고 있는 귀신.\n\"내 한을 풀어줘... 제발...\"",
         choices={
            {text="한을 풀어준다 (-30냥, 배수+1, 체력+1)", result="고맙다... 이 힘을 가져가라...",
             fn=function() S.player.yeop=math.max(0,S.player.yeop-30); S.player.wave_mult_bonus=S.player.wave_mult_bonus+1; S.player.lives=math.min(S.player.lives+1,10) end},
            {text="무시한다", result="울음소리가 점점 작아진다.", fn=function() end},
            {text="흡수한다 (배수+1.5, 다음 보스 기믹 강화)", result="힘은 얻었지만... 저주가 느껴진다.",
             fn=function() S.player.wave_mult_bonus=S.player.wave_mult_bonus+1.5 end},
         }},

        {title="무당의 굿판", desc="무당이 미친 듯이 춤을 추고 있다.\n\"신내림을 받을 자, 나서라!\"",
         choices={
            {text="신내림 받는다 (랜덤 강화 2종)", result="",
             fn=function()
                local r = math.random(3)
                if r == 1 then S.player.wave_chip_bonus=S.player.wave_chip_bonus+30; S.player.wave_mult_bonus=S.player.wave_mult_bonus+0.5; msg("칩+30, 배수+0.5!")
                elseif r == 2 then S.player.lives=math.min(S.player.lives+3,10); S.player.yeop=S.player.yeop+50; msg("체력+3, 엽전+50!")
                else S.player.wave_mult_bonus=S.player.wave_mult_bonus+1.5; S.player.lives=math.max(1,S.player.lives-1); msg("배수+1.5, 체력-1!") end
             end},
            {text="춤만 춘다 (+20냥, 체력+1)", result="즐거운 시간이었다!",
             fn=function() S.player.yeop=S.player.yeop+20; S.player.lives=math.min(S.player.lives+1,10) end},
         }},

        {title="저승 도서관", desc="끝없이 이어지는 책장.\n\"여기 모든 죽음의 기록이 있다.\"",
         choices={
            {text="자기 기록을 읽는다 (칩+20, 배수+0.5)", result="죽음을 이해하면 더 강해진다.",
             fn=function() S.player.wave_chip_bonus=S.player.wave_chip_bonus+20; S.player.wave_mult_bonus=S.player.wave_mult_bonus+0.5 end},
            {text="다음 보스 기록을 읽는다 (보스 HP-20%)", result="약점을 파악했다!",
             fn=function() S._next_boss_hp_mult=(S._next_boss_hp_mult or 1)*0.8 end},
            {text="금서를 훔친다 (배수+2, 체력-2)", result="금지된 지식의 대가는 크다.",
             fn=function() S.player.wave_mult_bonus=S.player.wave_mult_bonus+2; S.player.lives=math.max(1,S.player.lives-2) end},
         }},

        {title="이무기의 여의주", desc="동굴에서 빛나는 구슬이 보인다.\n가까이 가니 거대한 뱀이 감고 있다.",
         choices={
            {text="빼앗는다 (칩+60, 체력-3)", result="여의주의 힘을 손에 넣었다!",
             fn=function() S.player.wave_chip_bonus=S.player.wave_chip_bonus+60; S.player.lives=math.max(1,S.player.lives-3) end},
            {text="거래한다 (-80냥, 배수+2)", result="\"공정한 거래다.\" 이무기가 고개를 끄덕인다.",
             fn=function() S.player.yeop=math.max(0,S.player.yeop-80); S.player.wave_mult_bonus=S.player.wave_mult_bonus+2 end},
            {text="도망친다", result="현명한 판단이다.", fn=function() end},
         }},

        {title="저승 대장간", desc="불도깨비가 쇠를 두드리고 있다.\n\"무기를 벼려줄까? 재료가 필요하지만.\"",
         choices={
            {text="칩 강화 (-40냥, 칩+35)", result="카드에 쇠의 힘이 깃든다!",
             fn=function() S.player.yeop=math.max(0,S.player.yeop-40); S.player.wave_chip_bonus=S.player.wave_chip_bonus+35 end},
            {text="배수 강화 (-40냥, 배수+1)", result="카드가 날카로워진다!",
             fn=function() S.player.yeop=math.max(0,S.player.yeop-40); S.player.wave_mult_bonus=S.player.wave_mult_bonus+1 end},
            {text="구경만 한다 (칩+5)", result="구경하는 것도 공부다.",
             fn=function() S.player.wave_chip_bonus=S.player.wave_chip_bonus+5 end},
         }},

        {title="천도재", desc="스님이 천도재를 올리고 있다.\n\"시주를 하면 복을 받으리라.\"",
         choices={
            {text="시주한다 (-50냥, 체력 전회복, 배수+0.5)", result="마음이 맑아진다.",
             fn=function() S.player.yeop=math.max(0,S.player.yeop-50); S.player.lives=10; S.player.wave_mult_bonus=S.player.wave_mult_bonus+0.5 end},
            {text="같이 기도한다 (체력+2)", result="평안해진다.",
             fn=function() S.player.lives=math.min(S.player.lives+2,10) end},
            {text="그냥 지나간다", result="바쁜 길이다.", fn=function() end},
         }},

        {title="삼신할미", desc="노파가 실을 잣고 있다.\n\"네 운명의 실이 곧 끊어지려 한다.\n내가 이어줄까?\"",
         choices={
            {text="실을 잇는다 (체력+3, 내기+1)", result="운명이 연장된다.",
             fn=function() S.player.lives=math.min(S.player.lives+3,10); S.perm_yokbo=(S.perm_yokbo or 0)+1 end},
            {text="새 실을 달라 (손패+3)", result="새로운 가능성이 열린다.",
             fn=function() S.perm_hand=(S.perm_hand or 0)+3 end},
            {text="운명을 거부한다 (배수+1)", result="\"대담하구나.\" 할미가 웃는다.",
             fn=function() S.player.wave_mult_bonus=S.player.wave_mult_bonus+1 end},
         }},

        {title="저승꽃밭", desc="하얀 꽃이 끝없이 펼쳐져 있다.\n꽃잎 하나하나가 누군가의 기억이라 한다.",
         choices={
            {text="기억을 흡수한다 (칩+30, 배수+0.5)", result="수많은 기억이 밀려든다.",
             fn=function() S.player.wave_chip_bonus=S.player.wave_chip_bonus+30; S.player.wave_mult_bonus=S.player.wave_mult_bonus+0.5 end},
            {text="꽃다발을 만든다 (+70냥)", result="저승에서도 꽃은 비싸다.",
             fn=function() S.player.yeop=S.player.yeop+70 end},
            {text="누워서 쉰다 (체력 전회복)", result="평화롭다...",
             fn=function() S.player.lives=10 end},
         }},
    }
    -- 셔플 후 첫 번째 (이전과 다른 이벤트)
    for i = #evts, 2, -1 do local j = math.random(1,i); evts[i], evts[j] = evts[j], evts[i] end
    S.event = evts[1]
end

local function gen_upgrades()
    local pool = {
        -- ═══ 공격 계열 (빨강) ═══
        {name="업화", desc="칩 +20. 불꽃이 카드를 감싼다.",
            icon=PIX.upgrade_chip, color={0.85,0.2,0.1},
            fn=function() S.player.wave_chip_bonus=S.player.wave_chip_bonus+20 end},
        {name="피의 결속", desc="배수 ×1.5. 피를 바쳐 힘을 얻는다.",
            icon=PIX.upgrade_mult, color={0.7,0.05,0.05},
            fn=function() S.player.wave_mult_bonus=S.player.wave_mult_bonus+0.5 end},
        {name="도깨비 방망이", desc="칩 +10, 배수 +0.3. 균형 잡힌 힘.",
            icon=PIX.horn, color={0.9,0.7,0.1},
            fn=function() S.player.wave_chip_bonus=S.player.wave_chip_bonus+10; S.player.wave_mult_bonus=S.player.wave_mult_bonus+0.3 end},
        {name="광기", desc="배수 +1. 대신 체력 -1. 미친 자의 선택.",
            icon=PIX.skull, color={0.8,0.1,0.5},
            fn=function() S.player.wave_mult_bonus=S.player.wave_mult_bonus+1; S.player.lives=S.player.lives-1 end},

        -- ═══ 생존 계열 (초록) ═══
        {name="삼도천의 물", desc="체력 +2. 저승의 물이 상처를 치유한다.",
            icon=PIX.potion, color={0.2,0.8,0.3},
            fn=function() S.player.lives=math.min(S.player.lives+2,10) end},
        {name="뱃사공의 은혜", desc="체력 +1, 엽전 +20. 뱃사공이 도와준다.",
            icon=PIX.heart, color={0.3,0.7,0.5},
            fn=function() S.player.lives=math.min(S.player.lives+1,10); S.player.yeop=S.player.yeop+20 end},
        {name="철갑", desc="다음 보스 첫 반격 무효. 한 번은 버틴다.",
            icon=PIX.shield, color={0.3,0.5,0.8},
            fn=function() S._next_counter_immune = true end},

        -- ═══ 경제 계열 (금색) ═══
        {name="도깨비 주머니", desc="엽전 +50. 무거운 주머니.",
            icon=PIX.coin, color={0.9,0.75,0.1},
            fn=function() S.player.yeop=S.player.yeop+50 end},
        {name="엽전비", desc="엽전 +30, 칩 +5. 돈이 하늘에서 내린다.",
            icon=PIX.coin, color={0.85,0.7,0.2},
            fn=function() S.player.yeop=S.player.yeop+30; S.player.wave_chip_bonus=S.player.wave_chip_bonus+5 end},

        -- ═══ 특수 계열 (보라) ═══
        {name="족보의 눈", desc="내기 횟수 +1. 더 많은 기회.",
            icon=PIX.star, color={0.6,0.3,0.9},
            fn=function() S.perm_yokbo=(S.perm_yokbo or 0)+1 end},
        {name="탐욕", desc="칩 +30. 대신 다음 보스 HP +20%.",
            icon=PIX.horn, color={0.8,0.5,0.1},
            fn=function() S.player.wave_chip_bonus=S.player.wave_chip_bonus+30; S._next_boss_hp_mult=(S._next_boss_hp_mult or 1)*1.2 end},
        {name="환생", desc="손패 +2. 다음 판부터 카드가 더 많다.",
            icon=PIX.card_pack, color={0.5,0.8,1},
            fn=function() S.perm_hand=(S.perm_hand or 0)+2 end},
    }

    -- 셔플 후 3개 선택 (같은 계열 2개까지만)
    for i = #pool, 2, -1 do local j = math.random(1,i); pool[i], pool[j] = pool[j], pool[i] end
    S.upgrades = {}
    for i = 1, math.min(3, #pool) do S.upgrades[i] = pool[i] end
end

local save_meta  -- forward declaration (정의는 433행)

local function start_realm()
    if not S.spiral then return end
    local realm = S.spiral.current_realm
    local REALMS = SpiralManager.REALMS_PER_SPIRAL  -- 20
    if realm > REALMS then
        -- 나선 완료 보너스
        local sp = S.spiral and S.spiral.current_spiral or 1
        local bonus = sp == 1 and 100 or (50 + sp * 20)
        S.soul = S.soul + bonus
        msg(string.format("윤회 %d 완료! +%d넋", sp, bonus))
        S.state = "gate"; save_meta(); return
    end
    -- 관문별 보스 매칭: 초반=약한 보스, 후반=강한 보스, 마지막=염라
    if realm == REALMS then
        S.boss = BossData.get_yeomra()
    else
        local prev_id = S._prev_boss_id
        -- 관문 위치에 따라 normal/elite 필터링
        local pool = {}
        local realm_ratio = realm / REALMS  -- 0.05 ~ 0.95
        for _, b in ipairs(bosses) do
            if realm_ratio < 0.35 then
                -- 초반(관문 1~7): normal만
                if b.tier == "normal" then pool[#pool+1] = b end
            elseif realm_ratio < 0.7 then
                -- 중반(관문 8~14): normal + elite
                pool[#pool+1] = b
            else
                -- 후반(관문 15~19): elite 우선
                if b.tier == "elite" then pool[#pool+1] = b end
            end
        end
        if #pool == 0 then pool = bosses end  -- 풀백
        local pick
        for attempt = 1, 20 do
            pick = pool[math.random(1, #pool)]
            if pick.id ~= prev_id then break end
        end
        S.boss = pick
    end
    S._prev_boss_id = S.boss.id
    S.battle = BossBattle.new(S.boss, S.spiral.current_spiral)

    -- 이벤트 효과 적용: 보스 HP 변조
    if S._next_boss_hp_mult and S._next_boss_hp_mult ~= 1 then
        local new_hp = math.floor(S.battle.boss_max_hp * S._next_boss_hp_mult)
        S.battle.boss_max_hp = new_hp
        S.battle.boss_current_hp = new_hp
        S._next_boss_hp_mult = nil
    end
    -- 이벤트 효과 적용: 기믹 봉인
    if S._next_boss_gimmick_seal then
        S.boss._original_gimmick = S.boss.gimmick
        S.boss.gimmick = "none"
        S._next_boss_gimmick_seal = nil
        msg("이벤트 효과: 보스 기믹 봉인!")
    end

    S.max_rounds = S.boss.rounds; S.round = 0
    S._eaten_combos = {}
    S._boss_chips = 0; S._boss_mult = 0  -- 보스전 시너지 누적 초기화
    S._copy_cards = {}                    -- 카드 복사 대기열 초기화
    -- 보스 대사만 표시 (이름+HP는 보스 패널 UI에서 이미 표시)
    show_center_msg(S.boss.name_kr, S.boss.intro_dialogue or "", 2.5, PAL.red)
    SFX.play("boss_appear")
    -- 발견 추적: 보스
    S.discovered.bosses[S.boss.id] = true
    -- 업적: 진행도 체크
    local realm = S.spiral and S.spiral.current_realm or 1
    if S.ach then S.ach:check_progress(nil, realm, S.total_deaths) end
    start_round()
end

function start_round()
    FX.set_go_danger(0)
    FX.reset_chain()
    S.round = S.round + 1
    -- Check round limit
    if S.round > S.max_rounds then
        -- Boss survived all rounds → player takes damage
        S.player.lives = S.player.lives - 1
        FX.player_hit(1); SFX.play("damage_taken")
        msg("라운드 초과! 체력 -1")
        if S.player.lives <= 0 then trigger_game_over(); return end
        S.round = S.round - 1  -- stay on same round count
    end
    -- Deal new hand
    S.deck:initialize_deck()
    S.deck:deal_cards(S.player, 10 + (S.perm_hand or 0), 0)
    S.hand = S.player.hand
    S.selected = {}
    S.chips = 5 + (S.perm_chips or 0) + (S.player.wave_chip_bonus or 0)
    S.mult = 1.0 + (S.perm_mult or 0) * 0.15 + (S.player.wave_mult_bonus or 0)
    S.go_count = 0
    S.plays = 0
    S._eaten_combos = {}
    S.state = "in_round"
    sort_hand()

    -- 카드 복사 처리: 이전 판 등록 카드 중 복사 대상이 있으면 손패에 추가
    if S._copy_cards and #S._copy_cards > 0 then
        local copies = {}
        for _, card in ipairs(S._copy_cards) do
            local copy = {}
            for k, v in pairs(card) do copy[k] = v end
            copy._is_copy = true
            copies[#copies+1] = copy
        end
        for _, c in ipairs(copies) do S.hand[#S.hand+1] = c end
        msg(string.format("복사된 카드 %d장이 손패에 추가!", #copies))
        S._copy_cards = {}
        S._copy_mode = nil
        sort_hand()
    end

    -- 보스 기믹 적용 (매 판 시작)
    if S.boss and S.boss.gimmick and S.round % (S.boss.gimmick_interval or 2) == 0 then
        SFX.play("gimmick")
        local g = S.boss.gimmick
        if g == "consume_highest" and #S.hand > 2 then
            local best_idx = 1
            for i = 2, #S.hand do
                if S.hand[i].base_points > S.hand[best_idx].base_points then best_idx = i end
            end
            local eaten = table.remove(S.hand, best_idx)
            msg("기믹: " .. S.boss.name_kr .. "이(가) " .. eaten.name_kr .. "을 먹었다!")
        elseif g == "flip_all" then
            msg("기믹: 패를 뒤섞는다!")
            for i = #S.hand, 2, -1 do
                local j = math.random(1, i)
                S.hand[i], S.hand[j] = S.hand[j], S.hand[i]
            end
        elseif g == "disable_talisman" and S.player and #S.player.talismans > 0 then
            msg("기믹: 부적 1개 봉인!")
        elseif g == "no_bright" then
            msg("기믹: 광 카드 사용 불가!")
        end
    end

    -- Show round number
    if S.round > 1 then
        show_center_msg(string.format("판 %d/%d", S.round, S.max_rounds), "", 1.0, PAL.white)
    end
    SFX.play("round_start")
end

local _defeat_timer = nil

local function after_defeat()
    S.player.yeop = S.player.yeop + S.boss.yeop_reward
    -- 넋 획득 (관문 번호에 비례, 1윤회 총합 ~65넋)
    local realm = S.spiral and S.spiral.current_realm or 1
    local soul_gain = 5 + realm  -- 이전: 10 + realm*2 (1윤회 합계 210→65로 감소)
    S.soul = S.soul + soul_gain
    S.best_realm = math.max(S.best_realm, realm)
    S.total_kills = (S.total_kills or 0) + 1
    -- 동료 해금: 보스 격파 시 해당 보스의 동료 해금
    local comp_map = {glutton=true, trickster=true, fox=true, mirror=true, flame=true, shadow=true}
    if comp_map[S.boss.id] and not S.discovered.companions[S.boss.id] then
        S.discovered.companions[S.boss.id] = true
        msg(string.format("동료 해금! [%s]", S.boss.name_kr))
        FX.text_popup(W and W/2 or 320, 100, "동료: " .. S.boss.name_kr, {0, 0.85, 1})
    end
    -- 격파 회복 (생존의 길)
    local heal = S.perm_heal or 0
    if heal > 0 then
        S.player.lives = math.min(S.player.lives + heal, S.player.MAX_LIVES)
        msg(string.format("격파 회복! 체력 +%d", heal))
    end
    -- 업적: 전투 체크
    if S.ach then
        local overkill = S.battle and S.battle.boss_max_hp > 0
            and (1 - S.battle.boss_current_hp / S.battle.boss_max_hp) or 1
        S.ach:check_combat(S.boss.id, true, S.total_kills, overkill,
            S.player.lives, S._damage_taken_this_battle or 0)
        -- 재앙 보스 체크
        if S.boss.tier == "calamity" then S.ach:try_unlock("calamity_clear") end
        -- 속도 클리어 (3판 이내)
        if S.round <= 3 then S.ach:try_unlock("speed_clear") end
        -- 1판 킬
        if S.round <= 1 then S.ach:try_unlock("one_shot") end
        -- 무피해
        if (S._damage_taken_this_battle or 0) <= 0 then S.ach:try_unlock("no_damage") end
        -- 목숨 1 격파
        if S.player.lives <= 1 then S.ach:try_unlock("last_stand") end
    end
    -- 보상만 표시 (FX.boss_defeat()에서 이름+격파 텍스트 이미 표시됨)
    msg(string.format("+%d냥  +%d넋", S.boss.yeop_reward, soul_gain))
    SFX.play("reward")
    save_meta()
    -- 1초 뒤 강화 화면 전환 (격파 연출 후)
    _defeat_timer = 1.0
end

-- ============================
-- 전투 액션
-- 흐름: 카드 선택 → 내기(데미지) → 고/스톱
-- ============================

local function do_end_round()
    -- Boss counter-attack
    local hp_ratio = S.battle.boss_current_hp / math.max(S.battle.boss_max_hp, 1)
    if hp_ratio < 0.3 then
        if math.random() < 0.15 then
            S.player.lives = S.player.lives - 1
            FX.player_hit(1)
            SFX.play("boss_rage")
            msg("보스 광분! 체력 -1!")
            if S.player.lives <= 0 then trigger_game_over(); return end
        end
    elseif hp_ratio < 0.6 then
        local stolen = math.min(S.player.yeop, 10)
        S.player.yeop = S.player.yeop - stolen
        if stolen > 0 then msg("보스 반격! 엽전 -" .. stolen .. "냥") end
    end
    -- Next round
    start_round()
end

local function do_bet()
    if #S.selected == 0 then msg("카드를 선택하세요"); return end
    if S.battle and S.battle:is_boss_defeated() then return end
    -- 내기 횟수 제한 (최대 5회 + 영구강화)
    local max_plays = 5 + (S.perm_yokbo or 0)
    if S.plays >= max_plays then msg("내기 횟수 초과!"); return end

    -- Evaluate combos from selected cards
    local all_combos = HandEvaluator.evaluate(S.selected)
    local combos = {}
    for _, c in ipairs(all_combos) do
        combos[#combos+1] = c
    end

    -- Calculate chips and mult from combos
    local cc = 0
    local cm_add = 0
    for _, c in ipairs(combos) do
        cc = cc + c.chips
        cm_add = cm_add + (c.mult - 1)
    end

    -- Stack bonus from previous bets this round
    local stack_count = S._eaten_combos and #S._eaten_combos or 0
    cc = cc + stack_count * 3

    S.chips = S.chips + cc
    S.mult = math.min(S.mult + cm_add, 10.0)
    S.plays = S.plays + 1

    -- Remove selected cards from hand
    S._copy_cards = S._copy_cards or {}
    for _, sel in ipairs(S.selected) do
        for i, h in ipairs(S.hand) do if h == sel then table.remove(S.hand, i); break end end
        -- 카드 복사 아이템 효과
        if S._copy_mode == "all" then
            S._copy_cards[#S._copy_cards+1] = sel
        elseif S._copy_mode == "single" and #S._copy_cards == 0 then
            S._copy_cards[#S._copy_cards+1] = sel
        end
    end
    if S._copy_mode == "single" and #S._copy_cards > 1 then
        table.sort(S._copy_cards, function(a, b) return (a.base_points or 0) > (b.base_points or 0) end)
        S._copy_cards = {S._copy_cards[1]}
    end

    -- Record combos
    S._eaten_combos = S._eaten_combos or {}
    if #combos > 0 then
        local names = {}
        for _, c in ipairs(combos) do
            names[#names+1] = c.name_kr
            S._eaten_combos[#S._eaten_combos+1] = {name=c.name_kr, tier=c.tier, chips=c.chips, mult=c.mult, id=c.id, cat=c.category, is_penalty=c.is_penalty, desc=c.desc, heal=c.heal}
            -- Discovery tracking
            if S.discovered then S.discovered.yokbos[c.id] = true end
        end

        -- Calculate damage NOW
        -- 고 배수: 1고=×1.8, 2고=×2.8, 3고=×5.0 (이전: ×2/×3/×8)
        local go_mult = ({[1]=1.8, [2]=2.8, [3]=5.0})[S.go_count] or 1
        local final_mult = math.min(S.mult, 10.0)
        local damage = math.floor(math.max(S.chips * final_mult * go_mult, 8))

        -- Deal damage to boss
        S.battle:deal_damage(damage)

        -- Countup animation
        FX.start_countup(math.floor(S.chips), final_mult, go_mult, damage)
        FX.boss_hit(damage)

        -- HP ghost effect (ratio는 반드시 [0, 1] 범위로 클램프)
        local max_hp = math.max(S.battle.boss_max_hp, 1)
        local prev_ratio = math.min(1.0, (S.battle.boss_current_hp + damage) / max_hp)
        local new_ratio  = math.max(0.0, S.battle.boss_current_hp / max_hp)
        FX.set_hp_ghost(prev_ratio, new_ratio)

        -- Combo cutin
        local best_tier, best_name = 5, names[1]
        for _, c in ipairs(combos) do
            if c.tier < best_tier then best_tier = c.tier; best_name = c.name_kr end
        end
        FX.combo_cutin(best_name, best_tier)
        FX.add_chain()
        if best_tier <= 1 then SFX.play("combo_epic")
        elseif best_tier <= 2 then SFX.play("combo_great")
        elseif best_tier <= 3 then SFX.play("combo_good")
        else SFX.play("combo_normal") end

        -- Achievement checks
        if S.ach then
            for _, c in ipairs(combos) do
                S.ach:check_yokbo(c.name_kr, damage)
            end
        end

        msg(string.format("%s → %s칩 ×%.1f ×고%d = %s 데미지!",
            table.concat(names, "+"), NumFmt.format_score(S.chips), final_mult, go_mult, NumFmt.format_score(damage)))

        -- Check boss defeated
        if S.battle:is_boss_defeated() then
            FX.boss_defeat(S.boss.name_kr)
            SFX.play("boss_defeat")
            after_defeat()
            return
        end

        -- Offer Go/Stop (if hand has cards left and plays remain)
        local max_plays2 = 5 + (S.perm_yokbo or 0)
        if #S.hand >= 1 and S.plays < max_plays2 then
            S.state = "go_stop"
        else
            -- No cards left or max plays reached → end round
            do_end_round()
        end
    else
        -- No combo found - still deal minimum damage
        local damage = 15
        S.battle:deal_damage(damage)
        FX.boss_hit(damage)
        msg("족보 없음... 최소 데미지 15")
        SFX.play("combo_none")

        if S.battle:is_boss_defeated() then
            FX.boss_defeat(S.boss.name_kr)
            SFX.play("boss_defeat")
            after_defeat()
            return
        end

        if #S.hand >= 1 then
            S.state = "go_stop"
        else
            do_end_round()
        end
    end

    S.selected = {}
end

local function do_go()
    S.go_count = S.go_count + 1
    FX.set_go_danger(S.go_count)
    FX.go_pulse(S.go_count)
    SFX.play("go_pressed")
    -- Draw bonus cards
    local bonus = ({3, 2, 1})[math.min(S.go_count, 3)] or 1
    for i = 1, bonus do
        local c = S.deck:draw_from_pile()
        if c then S.hand[#S.hand+1] = c end
    end
    SFX.play("card_deal")
    -- Go 3 instant death check
    if S.go_count >= 3 and math.random() < 0.10 then
        S.player.lives = S.player.lives - 1
        FX.instant_death()
        SFX.play("instant_death")
        msg("즉사! 도깨비의 일격!")
        if S.player.lives <= 0 then trigger_game_over(); return end
    end
    -- Achievement
    S.total_go = (S.total_go or 0) + 1
    S.consecutive_stops = 0
    if S.ach then
        S.ach:check_go(S.go_count, true)
        if S.total_go >= 10 then S.ach:try_unlock("go_10_total") end
        if S.total_go >= 50 then S.ach:try_unlock("go_50_total") end
    end
    msg(({"고 1! +3장 ×1.8", "고 2! +2장 ×2.8", "고 3! +1장 ×5.0 위험!"})[math.min(S.go_count, 3)])
    S.state = "in_round"
    S.selected = {}
    sort_hand()
end

local function do_stop()
    FX.set_go_danger(0)
    SFX.play("stop_pressed")
    S.consecutive_stops = (S.consecutive_stops or 0) + 1
    if S.ach and S.consecutive_stops >= 10 then S.ach:try_unlock("stop_master") end
    do_end_round()
end


-- ===========================
-- Love2D 콜백
-- ===========================

-- 세이브/로드 (영구 데이터만)
local json = require("lib.json")

save_meta = function()
    local data = {
        soul = S.soul,
        perm_chips = S.perm_chips, perm_mult = S.perm_mult,
        perm_lives = S.perm_lives, perm_yeop = S.perm_yeop,
        perm_hand = S.perm_hand, perm_yokbo = S.perm_yokbo,
        perm_talisman = S.perm_talisman, perm_tali_rate = S.perm_tali_rate,
        perm_go_ins = S.perm_go_ins, perm_heal = S.perm_heal,
        perm_shop_disc = S.perm_shop_disc,
        total_runs = S.total_runs, best_realm = S.best_realm,
        total_kills = S.total_kills, total_go = S.total_go,
        total_deaths = S.total_deaths, total_yeop_earned = S.total_yeop_earned,
        unlocked_achievements = S.ach and S.ach:get_unlocked_ids() or {},
        discovered = S.discovered,
    }
    local ok, str = pcall(json.encode, data, true)
    if ok and love.filesystem then
        love.filesystem.write("dokkaebi_meta.json", str)
    end
end

local function load_meta()
    if not love.filesystem then return end
    local info = love.filesystem.getInfo("dokkaebi_meta.json")
    if not info then return end
    local str = love.filesystem.read("dokkaebi_meta.json")
    if not str then return end
    local ok, data = pcall(json.decode, str)
    if ok and data then
        S.soul = data.soul or 0
        S.perm_chips = data.perm_chips or 0
        S.perm_mult = data.perm_mult or 0
        S.perm_lives = data.perm_lives or 0
        S.perm_yeop = data.perm_yeop or 0
        S.perm_hand = data.perm_hand or 0
        S.perm_yokbo = data.perm_yokbo or 0
        S.perm_talisman = data.perm_talisman or 0
        S.perm_tali_rate = data.perm_tali_rate or 0
        S.perm_go_ins = data.perm_go_ins or 0
        S.perm_heal = data.perm_heal or 0
        S.perm_shop_disc = data.perm_shop_disc or 0
        S.total_runs = data.total_runs or 0
        S.best_realm = data.best_realm or 0
        S.total_kills = data.total_kills or 0
        S.total_go = data.total_go or 0
        S.total_deaths = data.total_deaths or 0
        S.total_yeop_earned = data.total_yeop_earned or 0
        -- 업적 복원
        if S.ach and data.unlocked_achievements then
            S.ach:load_unlocked(data.unlocked_achievements)
        end
        -- 발견 추적 복원
        if data.discovered then
            S.discovered = data.discovered
        end
    end
end

function love.load()
    -- W, H는 내부 렌더 해상도 (640x360)로 고정
    W, H = love.graphics.getDimensions()
    SFX.init()
    BGM.init()
    -- 업적 매니저 초기화
    S.ach = AchievementManager.new()
    S.ach.on_achievement_unlocked:connect(function(def)
        msg(string.format("업적 해금! [%s] +%d넋", def.name_kr, def.soul_reward))
        S.soul = S.soul + (def.soul_reward or 0)
        FX.text_popup(W and W/2 or 320, 60, "업적: " .. def.name_kr, {1, 0.82, 0})
        SFX.play("combo_epic")
    end)
    load_meta()
    local fp = "assets/fonts/Pretendard-Regular.ttf"
    local fb = "assets/fonts/Pretendard-Bold.ttf"
    fonts.s  = love.graphics.newFont(fp, 11)
    fonts.m  = love.graphics.newFont(fp, 14)
    fonts.l  = love.graphics.newFont(fb, 20)
    fonts.xl = love.graphics.newFont(fb, 28)
    -- 줄 간격 여유 (1.0 기본 → 1.3으로 넓힘)
    fonts.s:setLineHeight(1.3)
    fonts.m:setLineHeight(1.3)
    fonts.l:setLineHeight(1.25)
    fonts.xl:setLineHeight(1.2)

    -- 윈도우 아이콘 설정 (도깨비 픽셀아트)
    IconGen.set_window_icon()

    -- 모든 도트 아이콘 프리로드
    PIX.preload()
    BossIcons.preload()
end

function love.quit()
    save_meta()
end

-- [DEV] F5 = 게임 재시작 (릴리즈 시 제거)
function love.keypressed(key)
    if key == "f5" then
        love.event.quit("restart")
    end
end

function love.update(dt)
    W, H = love.graphics.getDimensions()
    FX.update(dt)
    BGM.update(dt)
    BGM.update_state(S.state)
    update_center_msg(dt)
    -- 보스 격파 딜레이 타이머
    if _defeat_timer then
        _defeat_timer = _defeat_timer - dt
        if _defeat_timer <= 0 then
            _defeat_timer = nil
            FX.stop_shake()
            gen_upgrades(); S.state = "upgrade_select"
        end
    end
    -- 볼륨 슬라이더 드래그 처리
    if S._vol_dragging and S._vol_sliders then
        local sl = S._vol_sliders[S._vol_dragging]
        if sl and love.mouse.isDown(1) then
            local mx = love.mouse.getX()
            local ratio = math.max(0, math.min(1, (mx - sl.x) / sl.w))
            local v = math.floor(ratio * 100 + 0.5)
            S._settings[S._vol_dragging] = v; sl.apply(v)
        else
            S._vol_dragging = nil
        end
    end
    local mx, my = love.mouse.getPosition()
    for _, b in ipairs(btns) do b:update_hover(mx, my) end
    hover_idx = nil
    for i, cr in ipairs(card_rects) do
        if mx >= cr.x and mx <= cr.x+cr.w and my >= cr.y and my <= cr.y+cr.h then hover_idx = i; break end
    end
    hover_talisman = nil
    for i, tr in ipairs(talisman_rects) do
        if mx >= tr.x and mx <= tr.x+tr.w and my >= tr.y and my <= tr.y+tr.h then hover_talisman = i; break end
    end
    hover_combo = nil
    for i, cr in ipairs(combo_rects) do
        if mx >= cr.x and mx <= cr.x+cr.w and my >= cr.y and my <= cr.y+cr.h then hover_combo = i; break end
    end
end

function love.wheelmoved(x, y)
    if show_yokbo_guide then
        YokboGuide.scroll(y)
        return
    end
    if S.state == "collection" then
        S._col_scroll = (S._col_scroll or 0) + y * 30
        if S._col_scroll > 0 then S._col_scroll = 0 end
    end
end

function love.mousereleased(x, y, b)
    if b == 1 then S._vol_dragging = nil end
end

function love.mousepressed(x, y, b)
    if b ~= 1 then return end
    if show_yokbo_guide then show_yokbo_guide = false; return end
    -- 볼륨 슬라이더 드래그 시작
    if S.state == "settings" and S._vol_sliders then
        for lbl, sl in pairs(S._vol_sliders) do
            if x >= sl.x and x <= sl.x+sl.w and y >= sl.y-4 and y <= sl.y+sl.h+4 then
                S._vol_dragging = lbl
                local ratio = math.max(0, math.min(1, (x - sl.x) / sl.w))
                local v = math.floor(ratio * 100 + 0.5)
                S._settings[lbl] = v; sl.apply(v)
                return
            end
        end
    end
    for _, btn in ipairs(btns) do if btn:click(x, y) then SFX.play("button_click"); return end end
    -- 인라운드: 카드 클릭 → 선택 토글 (최대 5장)
    if S.state == "in_round" then
        for _, cr in ipairs(card_rects) do
            if x >= cr.x and x <= cr.x+cr.w and y >= cr.y and y <= cr.y+cr.h then
                local found = false
                for j, sel in ipairs(S.selected) do if sel == cr.card then table.remove(S.selected, j); found = true; SFX.play("card_deselect"); break end end
                if not found then
                    if #S.selected < 5 then S.selected[#S.selected+1] = cr.card; SFX.play("card_select") end
                end; return
            end
        end
    end
end

-- ===========================
-- 화면: 메인 메뉴
-- ===========================
local function scr_main_menu()
    -- 타이틀
    love.graphics.setFont(fonts.xl)
    set(PAL.gold)
    love.graphics.printf("도깨비의 패", 0, H*0.25, W, "center")
    love.graphics.setFont(fonts.m)
    set(PAL.dim)
    love.graphics.printf("도깨비의 패", 0, H*0.25 + 38, W, "center")
    love.graphics.setFont(fonts.s)
    set({0.55, 0.55, 0.65})
    love.graphics.printf("넌 죽었다. 저승의 도깨비들과 고스톱을 쳐서 이승으로 돌아가야 한다.", W*0.25, H*0.25 + 60, W*0.5, "center")

    -- 메뉴 버튼 (세로 정렬, 작은 크기)
    local cx, bw, bh, gap = W/2 - 70, 140, UI.btn_h, 8
    local sy = H*0.5
    ui_btn("새 게임",   cx, sy,            bw, bh, PAL.btn_red,  function() new_game(); S.state = "blessing_select" end)
    ui_btn("이어하기",  cx, sy + (bh+gap),   bw, bh, S.total_runs > 0 and PAL.btn_dim or {0.12,0.12,0.16},  function()
        if S.total_runs > 0 then
            msg(string.format("강화 데이터 로드 완료 (넋:%d 칩+%d 배+%d)", S.soul, S.perm_chips, S.perm_mult))
            new_game(); S.state = "blessing_select"
        else msg("플레이 기록이 없습니다.") end
    end)
    ui_btn("저승 수련",  cx, sy + (bh+gap)*2, bw, bh, PAL.purple,   function() S._prev_state = "main_menu"; S.state = "upgrade_tree" end)
    ui_btn("도감",      cx, sy + (bh+gap)*3, bw, bh, PAL.btn_dim,  function() S.state = "collection" end)
    ui_btn("설정",      cx, sy + (bh+gap)*4, bw, bh, PAL.btn_dim,  function() S.state = "settings" end)
    ui_btn("종료",      cx, sy + (bh+gap)*5, bw, bh, {0.3,0.15,0.15},  function() love.event.quit() end)

    -- 하단
    love.graphics.setFont(fonts.s)
    set({0.22, 0.22, 0.30})
    love.graphics.print("v0.1.0", UI.pad, H - 18)
    love.graphics.printf("[한/EN/日]", 0, H - 18, W - UI.pad, "right")
end

-- ===========================
-- 화면: 축복 선택
-- ===========================
local function scr_blessing()
    topbar()
    local CY = H/2

    title("축복을 선택하라", CY - 190)
    subtitle("양날의 검 — 강력한 보너스와 저주가 함께 따른다.", CY - 165)

    local blessings = SpiralBlessing.get_all()
    local cols = {{0.65,0.18,0.08}, {0.08,0.35,0.65}, {0.35,0.10,0.55}, {0.50,0.45,0.12}}
    local names = {"업화", "빙결", "공허", "혼돈"}
    local cw, ch, gap = 180, 280, 12
    local img_h = 80  -- 이미지 영역 높이
    local sx = (W - (#blessings * (cw+gap) - gap)) / 2
    local card_y = CY - 130

    for i, b in ipairs(blessings) do
        local bx = sx + (i-1)*(cw+gap)

        panel(bx, card_y, cw, ch, true)

        -- 헤더 바
        set(cols[i])
        love.graphics.rectangle("fill", bx+1, card_y+1, cw-2, 30)
        love.graphics.setFont(fonts.m); set(PAL.white)
        love.graphics.printf(names[i], bx, card_y+7, cw, "center")

        -- 이미지 영역
        local img_y = card_y + 34
        local blessing_ids = {"blessing_업화", "blessing_빙결", "blessing_공허", "blessing_혼돈"}
        local bsprite = SpriteLoader.get("icon", blessing_ids[i])
        if bsprite then
            -- 실제 스프라이트: 비율 유지하며 img_h 높이에 맞춤
            local sw, sh = bsprite:getDimensions()
            local scale = img_h / sh
            local dw = sw * scale
            local draw_x = bx + 8 + (cw - 16 - dw) / 2
            love.graphics.setColor(1, 1, 1, 1)
            love.graphics.draw(bsprite, draw_x, img_y, 0, scale, scale)
        else
            -- 폴백: 컬러 배경 + 한자
            set({cols[i][1]*0.3, cols[i][2]*0.3, cols[i][3]*0.3, 0.6})
            love.graphics.rectangle("fill", bx+8, img_y, cw-16, img_h)
            set({cols[i][1]*0.6, cols[i][2]*0.6, cols[i][3]*0.6})
            love.graphics.rectangle("line", bx+8, img_y, cw-16, img_h)
            love.graphics.setFont(fonts.l)
            set({cols[i][1]+0.2, cols[i][2]+0.2, cols[i][3]+0.2, 0.5})
            local icons = {"火", "氷", "空", "混"}
            love.graphics.printf(icons[i], bx+8, img_y + img_h/2 - 16, cw-16, "center")
        end

        -- 구분선
        local desc_y = img_y + img_h + 6
        set(PAL.border)
        love.graphics.line(bx+12, desc_y, bx+cw-12, desc_y)

        -- 보너스
        love.graphics.setFont(fonts.s)
        set({0.25, 0.90, 0.45})
        love.graphics.printf("+ " .. b.bonus_desc, bx+8, desc_y+6, cw-16, "left")

        -- 패널티
        set({0.95, 0.35, 0.35})
        love.graphics.printf("- " .. b.penalty_desc, bx+8, desc_y+38, cw-16, "left")

        -- 선택 버튼
        local idx = i
        ui_btn("선택", bx+(cw-90)/2, card_y+ch-40, 90, 28, cols[i], function()
            S.spiral:select_blessing(blessings[idx])
            msg("축복: " .. names[idx])
            local bl = blessings[idx]
            if bl.chip_bonus > 0 then S.player.wave_chip_bonus = S.player.wave_chip_bonus + math.floor(bl.chip_bonus * 20) end
            if bl.mult_bonus > 0 then S.player.wave_mult_bonus = S.player.wave_mult_bonus + bl.mult_bonus end
            start_realm()
        end)
    end

    ui_btn("축복 없이 시작", W/2-65, card_y + ch + 20, 130, 30, PAL.btn_dim, function()
        msg("축복 없이 출발!"); start_realm()
    end)
end

-- ===========================
-- 화면: 전투 (중앙 정렬)
-- ===========================

local function scr_battle()
    topbar()
    local CX = W/2  -- 화면 중앙 기준

    -- ======= 레이아웃 사전 계산 =======
    local btn_y = H - 44

    -- 카드 크기: 손패 수에 따라 동적으로 계산 (최소 50, 최대 80)
    local hand_count_ref = math.max(#S.hand, 10)  -- 최소 10장 기준
    local avail_w = W - 80  -- 좌우 여백
    local cw_card = math.max(50, math.min(
        math.floor((avail_w - (hand_count_ref - 1) * UI.card_gap) / hand_count_ref),
        80))
    local ch_card = math.floor(cw_card * 1.4)  -- 화투 비율 5:7 유지

    local card_y = btn_y - 12 - ch_card
    local boss_by = 34
    local boss_bottom = boss_by

    -- ======= 보스 (컴팩트, 화면 상단 중앙) =======
    if S.battle then
        local bw = math.min(W * 0.82, 960)
        local bh = 155
        local bx = CX - bw/2
        local by = boss_by

        -- 보스 패널 배경
        set({0.04, 0.03, 0.08, 0.96})
        love.graphics.rectangle("fill", bx, by, bw, bh)
        -- 상단 강조 바
        local boss_ratio = S.battle.boss_current_hp / math.max(S.battle.boss_max_hp, 1)
        local bar_col = boss_ratio > 0.5 and {0.65,0.12,0.08} or (boss_ratio > 0.2 and {0.75,0.40,0.08} or {0.85,0.15,0.15})
        set(bar_col)
        love.graphics.rectangle("fill", bx, by, bw, 3)
        -- 외곽 테두리
        set(PAL.border)
        love.graphics.rectangle("line", bx, by, bw, bh)

        -- 보스 아이콘 영역 (패널 높이에 꽉 차게)
        local icon_pad = 4
        local icon_size = bh - icon_pad * 2
        set({0.03, 0.02, 0.06, 0.9})
        love.graphics.rectangle("fill", bx+icon_pad, by+icon_pad, icon_size, icon_size)

        -- 보스 스프라이트 (꽉 차게) + 피격 흔들림
        local ix0 = bx + icon_pad
        local iy0 = by + icon_pad
        local bsx, bsy = FX.get_boss_shake_offset()
        BossIcons.draw(S.boss.id, ix0 + bsx, iy0 + bsy, icon_size, S.boss)

        -- 이름 + 기믹
        local ix = bx + icon_size + icon_pad*2 + 8
        local iw = bw - icon_size - icon_pad*3 - 12
        love.graphics.setFont(fonts.l); set(PAL.gold)
        love.graphics.print(S.boss.name_kr, ix, by+6)

        -- 기믹 태그
        local gimmick_kr = ({
            consume_highest = "최고 패 먹기",
            flip_all = "패 뒤섞기",
            reset_field = "바닥패 리셋",
            disable_talisman = "부적 봉인",
            no_bright = "광 봉인",
            skullify = "해골화",
            fake_cards = "가짜 카드",
            competitive = "점수 경쟁",
            suppress = "억압",
            none = "",
        })[S.boss.gimmick or "none"] or ""
        if gimmick_kr ~= "" then
            love.graphics.setFont(fonts.s)
            local tw = fonts.s:getWidth(gimmick_kr) + 12
            set({0.35, 0.10, 0.10, 0.9})
            love.graphics.rectangle("fill", ix, by+30, tw, 18)
            set({0.6, 0.2, 0.2})
            love.graphics.rectangle("line", ix, by+30, tw, 18)
            set({1, 0.5, 0.4})
            love.graphics.print(gimmick_kr, ix+6, by+32)
        end

        -- 보스 설명
        if S.boss.description then
            love.graphics.setFont(fonts.s); set(PAL.dim)
            love.graphics.printf(S.boss.description, ix, by+50, iw, "left")
        end

        -- HP 바 (넓게 + 광택 + 잔상)
        local hx, hy, hw, hh = ix, by+66, iw, 24
        set({0.08, 0.03, 0.03})
        love.graphics.rectangle("fill", hx, hy, hw, hh)
        local ratio = S.battle.boss_current_hp / math.max(S.battle.boss_max_hp, 1)
        -- 잔상 바 (흰색 → 서서히 줄어듦)
        local ghost = FX.get_hp_ghost()
        if ghost then
            if ghost.flash_t > 0 then
                set({1, 1, 1, 0.7})
            else
                set({1, 0.3, 0.2, 0.5})
            end
            love.graphics.rectangle("fill", hx+1, hy+1, (hw-2)*math.max(0, math.min(1, ghost.ratio)), hh-2)
        end
        -- 실제 HP 바
        local hp_col = ratio > 0.5 and PAL.hp_high or (ratio > 0.2 and PAL.hp_mid or PAL.hp_low)
        set(hp_col)
        love.graphics.rectangle("fill", hx+1, hy+1, (hw-2)*math.max(ratio, 0), hh-2)
        set({1, 1, 1, 0.08})
        love.graphics.rectangle("fill", hx+1, hy+1, (hw-2)*math.max(ratio, 0), (hh-2)/2)
        set(PAL.border)
        love.graphics.rectangle("line", hx, hy, hw, hh)
        love.graphics.setFont(fonts.m); set(PAL.white)
        love.graphics.printf(string.format("HP  %s / %s",
            NumFmt.format(S.battle.boss_current_hp), NumFmt.format(S.battle.boss_max_hp)), hx, hy+1, hw, "center")

        -- 라운드 정보 (HP 바 아래 한 줄)
        love.graphics.setFont(fonts.s)
        local ry = by + 96
        -- 판
        set(PAL.dim)
        love.graphics.print("판", ix, ry)
        set(PAL.white)
        love.graphics.print(string.format("%d/%d", S.round, S.max_rounds), ix+22, ry)
        -- 내기
        set(PAL.dim)
        love.graphics.print("내기", ix+65, ry)
        set(PAL.gold)
        love.graphics.print(tostring(S.plays), ix+95, ry)
        -- Go
        set(PAL.dim)
        love.graphics.print("Go", ix+130, ry)
        if S.go_count > 0 then
            set(PAL.red)
            love.graphics.print("x" .. S.go_count, ix+150, ry)
        else
            set(PAL.dim)
            love.graphics.print("x0", ix+150, ry)
        end

        -- 등록된 콤보 (카테고리별 태그)
        if S._eaten_combos and #S._eaten_combos > 0 then
            love.graphics.setFont(fonts.s)
            local tag_x = ix
            local tag_y = ry + 18
            local cat_colors = {gostop=PAL.gold, seotda=PAL.cyan, jeoseung=PAL.purple,
                seasonal={0.3,0.85,0.4}, collection=PAL.white, monthpair=PAL.dim}
            for _, ec in ipairs(S._eaten_combos) do
                local col = ec.is_penalty and {0.90,0.20,0.15} or (cat_colors[ec.cat] or PAL.gold)
                local txt = ec.is_penalty and ("⚠ "..ec.name) or ec.name
                local tw = fonts.s:getWidth(txt) + 8
                if tag_x + tw > bx + bw - 8 then
                    tag_x = ix; tag_y = tag_y + 16
                end
                set({col[1]*0.3, col[2]*0.3, col[3]*0.3, 0.8})
                love.graphics.rectangle("fill", tag_x, tag_y, tw, 14)
                set(col)
                love.graphics.rectangle("line", tag_x, tag_y, tw, 14)
                love.graphics.print(txt, tag_x+4, tag_y+1)
                tag_x = tag_x + tw + 3
            end
        end
        boss_bottom = by + bh
    end

    -- ======= 데미지 패널 (보스 바로 아래, 중앙) =======
    local score_y = boss_bottom + 6
    local score_w = math.min(math.floor(W * 0.42), 520)
    local score_h = 42
    local sx = CX - score_w/2
    local sy = score_y

    -- 패널 배경
    set({0.05, 0.04, 0.10, 0.95})
    love.graphics.rectangle("fill", sx, sy, score_w, score_h)
    set(PAL.border)
    love.graphics.rectangle("line", sx, sy, score_w, score_h)

    -- 3칸: 칩 | × 배수 | = 데미지
    local cw1 = score_w * 0.30  -- 칩
    local cw2 = score_w * 0.30  -- 배수
    local cw3 = score_w * 0.40  -- 데미지

    -- 구분선
    set({0.22, 0.16, 0.32})
    love.graphics.line(sx + cw1, sy+5, sx + cw1, sy+score_h-5)
    love.graphics.line(sx + cw1 + cw2, sy+5, sx + cw1 + cw2, sy+score_h-5)

    -- 칩
    love.graphics.setFont(fonts.m); set({0.55, 0.80, 1.0})
    love.graphics.printf(NumFmt.format_score(S.chips) .. " 칩", sx, sy+5, cw1, "center")
    love.graphics.setFont(fonts.s); set(PAL.dim)
    love.graphics.printf("공격력", sx, sy+24, cw1, "center")

    -- 배수
    love.graphics.setFont(fonts.m); set(PAL.cyan)
    love.graphics.printf("× " .. string.format("%.1f", S.mult), sx + cw1, sy+5, cw2, "center")
    love.graphics.setFont(fonts.s); set(PAL.dim)
    love.graphics.printf("배수", sx + cw1, sy+24, cw2, "center")

    -- 데미지 (강조)
    local final_dmg = math.floor(S.chips * S.mult)
    set({0.15, 0.12, 0.03, 0.7})
    love.graphics.rectangle("fill", sx + cw1 + cw2 + 1, sy+1, cw3-2, score_h-2)
    love.graphics.setFont(fonts.l); set(PAL.gold)
    love.graphics.printf(NumFmt.format_score(final_dmg), sx + cw1 + cw2, sy+3, cw3, "center")
    love.graphics.setFont(fonts.s); set(PAL.gold)
    love.graphics.printf("예상 데미지", sx + cw1 + cw2, sy+26, cw3, "center")

    -- ======= 등록된 족보 (데미지 패널 아래) =======
    local combo_y = score_y + score_h + 6
    local combo_area_h = 0

    if S._eaten_combos and #S._eaten_combos > 0 then
        -- 콤보 태그 (개별 클릭/호버 가능)
        combo_rects = {}
        do
            love.graphics.setFont(fonts.s)
            local tier_colors = {
                [1]=PAL.gold, [2]=PAL.cyan, [3]={0.3,0.85,0.4},
                [4]={0.65,0.65,0.70}, [5]={0.55,0.48,0.45},
            }
            local tag_gap = 4
            local tag_h = fonts.s:getHeight() + 6
            local dy = combo_y + 4
            local PAL_PENALTY = {0.90, 0.20, 0.15}  -- 패널티 빨강

            -- 전체 너비 계산 (중앙 정렬)
            local total_w = 0
            for _, ec in ipairs(S._eaten_combos) do
                local label = ec.is_penalty and ("⚠ " .. ec.name) or ("[" .. ec.name .. "]")
                total_w = total_w + fonts.s:getWidth(label) + tag_gap + 8
            end
            total_w = total_w - tag_gap
            local tx = CX - total_w / 2

            for ci, ec in ipairs(S._eaten_combos) do
                local is_penalty = ec.is_penalty
                local tag_text = is_penalty and ("⚠ " .. ec.name) or ("[" .. ec.name .. "]")
                local tw = fonts.s:getWidth(tag_text) + 8
                local is_hover = (hover_combo == ci)
                local col = is_penalty and PAL_PENALTY or (tier_colors[ec.tier] or PAL.white)

                -- 태그 배경
                if is_penalty then
                    set({0.30, 0.05, 0.05, is_hover and 0.75 or 0.5})
                elseif is_hover then
                    set({col[1]*0.3, col[2]*0.3, col[3]*0.3, 0.6})
                else
                    set({0.12, 0.10, 0.18, 0.5})
                end
                love.graphics.rectangle("fill", tx, dy, tw, tag_h, 3)

                -- 태그 테두리 (패널티는 점선 느낌으로 얇게)
                set(col, is_hover and 1 or (is_penalty and 0.85 or 0.6))
                love.graphics.setLineWidth(is_penalty and 1.5 or 1)
                love.graphics.rectangle("line", tx, dy, tw, tag_h, 3)
                love.graphics.setLineWidth(1)

                -- 태그 텍스트
                set(col, is_hover and 1 or 0.85)
                love.graphics.printf(tag_text, tx, dy + 3, tw, "center")

                combo_rects[ci] = {x=tx, y=dy, w=tw, h=tag_h, combo=ec}
                tx = tx + tw + tag_gap
            end
            combo_area_h = combo_area_h + tag_h + 2

            -- 족보 호버 툴팁
            if hover_combo and combo_rects[hover_combo] then
                local cr = combo_rects[hover_combo]
                local ec = cr.combo
                love.graphics.setFont(fonts.s)

                local cat_labels = {gostop="고스톱", seotda="섯다", jeoseung="저승",
                    seasonal="계절", collection="수집", monthpair="월합", fallback="기본",
                    penalty="⚠ 패널티"}
                local cat_name = cat_labels[ec.cat] or ec.cat or ""
                local tier_names = {[1]="S", [2]="A", [3]="B", [4]="C", [5]="D", [6]="P"}
                local tier_name = tier_names[ec.tier] or "?"

                local line1 = ec.name .. "  [Tier " .. tier_name .. " |" .. cat_name .. "]"
                local chips_val = ec.chips or 0
                local chips_str = chips_val >= 0 and ("칩 +" .. chips_val) or ("칩 " .. chips_val)
                local line2 = string.format("%s  | 배수 ×%.2f", chips_str, ec.mult or 1)
                local line3 = ec.is_penalty and (ec.desc or "패널티 족보") or (ec.heal and ("회복 +" .. ec.heal) or nil)

                local tip_w = math.max(fonts.s:getWidth(line1), fonts.s:getWidth(line2)) + 20
                local tip_lines = line3 and 3 or 2
                local tip_h = tip_lines * fonts.s:getHeight() + 12
                local tip_x = cr.x + cr.w / 2 - tip_w / 2
                local tip_y = cr.y - tip_h - 4

                if tip_x < 4 then tip_x = 4 end
                if tip_x + tip_w > W - 4 then tip_x = W - tip_w - 4 end
                if tip_y < 0 then tip_y = cr.y + cr.h + 4 end

                -- 툴팁 배경
                local bg_col = ec.is_penalty and {0.20, 0.03, 0.03, 0.95} or {0.06, 0.04, 0.12, 0.95}
                set(bg_col)
                love.graphics.rectangle("fill", tip_x, tip_y, tip_w, tip_h, 4)
                local col = ec.is_penalty and {0.90, 0.25, 0.20} or (tier_colors[ec.tier] or PAL.white)
                set(col)
                love.graphics.rectangle("line", tip_x, tip_y, tip_w, tip_h, 4)

                -- 툴팁 텍스트
                set(ec.is_penalty and {1, 0.7, 0.7} or PAL.white)
                love.graphics.print(line1, tip_x + 8, tip_y + 4)
                set(ec.is_penalty and {0.90, 0.35, 0.25} or PAL.gold)
                love.graphics.print(line2, tip_x + 8, tip_y + 4 + fonts.s:getHeight())
                if line3 then
                    set(ec.is_penalty and {1.0, 0.45, 0.35} or {0.3, 0.85, 0.4})
                    love.graphics.print(line3, tip_x + 8, tip_y + 4 + fonts.s:getHeight() * 2)
                end
            end
        end
    else
        love.graphics.setFont(fonts.s)
        set({0.55, 0.55, 0.65})
        love.graphics.printf("카드를 골라서 [내기!]를 누르세요.", 0, combo_y + 4, W, "center")
        combo_area_h = fonts.s:getHeight() + 8
    end

    -- ======= 메시지 로그 (중앙) =======
    draw_msgs(combo_y + combo_area_h + 6, true)

    -- ======= 안내 텍스트 (카드 바로 위) =======
    love.graphics.setFont(fonts.s)
    local guide_y = card_y - 16
    if S.state == "in_round" then
        set({0.6, 0.85, 1.0})
        love.graphics.printf(string.format("카드를 골라서 [내기!] — 족보 = 데미지! (%d장 선택)", #S.selected), 0, guide_y, W, "center")
    elseif S.state == "go_stop" then
        set({1, 0.85, 0.4})
        love.graphics.printf("고 or 스톱?", 0, guide_y, W, "center")
    end

    -- ======= 손패 (중앙 하단) =======
    local hand_count = #S.hand
    local total_card_w = hand_count * (cw_card + UI.card_gap) - UI.card_gap
    local card_sx = CX - total_card_w / 2

    card_rects = {}
    for i, card in ipairs(S.hand) do
        local cx = card_sx + (i-1)*(cw_card + UI.card_gap)
        local sel = false
        for _, s in ipairs(S.selected) do if s == card then sel = true; break end end
        CardRenderer.draw(card, cx, card_y, sel, i == hover_idx, fonts.s, cw_card, ch_card)
        local oy = sel and math.floor(ch_card * 0.071) or (i == hover_idx and math.floor(ch_card * 0.029) or 0)
        card_rects[i] = {x=cx, y=card_y+oy, w=cw_card, h=ch_card, card=card}
    end

    -- ======= 부적 슬롯 (아이콘만, 호버 시 툴팁) =======
    local tal_sz = 36   -- 정사각 아이콘 크기
    local tal_gap = 4
    local talisman_y = card_y - tal_sz - 30
    love.graphics.setFont(fonts.s)
    set(PAL.dim)
    love.graphics.print("부적:", 15, talisman_y + (tal_sz - fonts.s:getHeight()) / 2)
    talisman_rects = {}
    local tal_x = 55
    if S.player and #S.player.talismans > 0 then
        for ti, t in ipairs(S.player.talismans) do
            local sprite_id = t.data and t.data.sprite_id
            local icon = sprite_id and SpriteLoader.getTalisman(sprite_id)
            local is_hover = (hover_talisman == ti)
            local rarity = t.data and t.data.rarity
            local border_col = is_hover and PAL.cyan
                or (rarity == "legendary" and {0.85, 0.65, 0.10}
                or (rarity == "rare"      and {0.50, 0.35, 0.80}
                or (rarity == "cursed"    and {0.70, 0.15, 0.15}
                or {0.45, 0.40, 0.55})))

            -- 배경
            set(is_hover and {0.22, 0.18, 0.32} or {0.10, 0.08, 0.16})
            love.graphics.rectangle("fill", tal_x, talisman_y, tal_sz, tal_sz, 4)
            -- 테두리
            set(border_col)
            love.graphics.setLineWidth(is_hover and 2 or 1)
            love.graphics.rectangle("line", tal_x, talisman_y, tal_sz, tal_sz, 4)
            love.graphics.setLineWidth(1)

            -- 아이콘
            if icon then
                local pad = 3
                local isz = tal_sz - pad * 2
                local scale = isz / math.max(icon:getWidth(), icon:getHeight())
                love.graphics.setColor(1, 1, 1, t.is_active ~= false and 1 or 0.35)
                love.graphics.draw(icon, tal_x + pad, talisman_y + pad, 0, scale, scale)
            else
                -- 스프라이트 없으면 첫 글자
                love.graphics.setFont(fonts.s)
                set(is_hover and PAL.white or PAL.cyan)
                local name = t.data and t.data.name_kr or "?"
                love.graphics.printf(name:sub(1,1), tal_x, talisman_y + (tal_sz - fonts.s:getHeight()) / 2, tal_sz, "center")
            end

            -- 봉인 표시 (비활성 부적)
            if t.is_active == false then
                love.graphics.setColor(0, 0, 0, 0.6)
                love.graphics.rectangle("fill", tal_x, talisman_y, tal_sz, tal_sz, 4)
                set({0.55, 0.20, 0.20})
                love.graphics.printf("✕", tal_x, talisman_y + (tal_sz - fonts.s:getHeight()) / 2, tal_sz, "center")
            end

            talisman_rects[ti] = {x=tal_x, y=talisman_y, w=tal_sz, h=tal_sz, talisman=t}
            tal_x = tal_x + tal_sz + tal_gap
        end
    else
        set({0.10, 0.08, 0.16})
        love.graphics.rectangle("fill", tal_x, talisman_y, tal_sz, tal_sz, 4)
        set({0.30, 0.28, 0.38})
        love.graphics.rectangle("line", tal_x, talisman_y, tal_sz, tal_sz, 4)
        set(PAL.dim)
        love.graphics.printf("없음", tal_x, talisman_y + (tal_sz - fonts.s:getHeight()) / 2, tal_sz, "center")
    end

    -- 부적 호버 툴팁
    if hover_talisman and talisman_rects[hover_talisman] then
        local tr = talisman_rects[hover_talisman]
        local t = tr.talisman
        if t and t.data then
            love.graphics.setFont(fonts.s)
            local fh = fonts.s:getHeight()
            local name = t.data.name_kr or t.data.name or "?"
            local desc = t.data.description_kr or t.data.description or ""

            -- 발동 조건
            local trigger_str = ""
            if t.data.trigger then
                local tl = {
                    on_card_played="카드 사용 시", on_yokbo_complete="족보 완성 시",
                    on_turn_start="턴 시작 시", on_turn_end="턴 종료 시",
                    on_round_start="판 시작 시", on_round_end="판 종료 시",
                    on_go_decision="고 선택 시", on_stop_decision="스톱 선택 시",
                    on_match_success="매칭 성공 시", on_match_fail="매칭 실패 시",
                    passive="항상 적용",
                }
                trigger_str = tl[t.data.trigger] or tostring(t.data.trigger)
            end

            -- 효과 수치
            local effect_str = ""
            if t.data.effect_value then
                local el = {
                    add_chips="칩 +", add_mult="배수 +",
                    multiply_mult="최종 배수 ×", reduce_target="목표 점수 -",
                    wild_card="만능패", transmute_card="패 변환",
                    destroy_card="패 소멸", special="특수 효과",
                }
                local et = t.data.effect_type or ""
                local prefix = el[et] or ""
                if prefix == "" then
                    effect_str = desc  -- fallback: 설명문 자체가 효과
                else
                    effect_str = prefix .. tostring(t.data.effect_value)
                end
            end

            -- 아이콘 크기 (툴팁 내 좌측 배치)
            local tip_icon_sz = 48
            local tip_icon = (t.data.sprite_id) and SpriteLoader.getTalisman(t.data.sprite_id)
            local tip_w = 240
            local icon_area = tip_icon and (tip_icon_sz + 8) or 0
            local content_w = tip_w - 16 - icon_area

            local _, name_lines = fonts.s:getWrap(name, content_w)
            local _, desc_lines = fonts.s:getWrap(desc, content_w)
            local lines = #name_lines + #desc_lines
            if trigger_str ~= "" then lines = lines + 1 end
            if effect_str ~= "" then lines = lines + 1 end
            local tip_h = math.max(lines * fh + 16, tip_icon and (tip_icon_sz + 16) or 0)

            local tip_x = math.max(4, math.min(tr.x, W - tip_w - 4))
            local tip_y = tr.y - tip_h - 4
            if tip_y < 0 then tip_y = tr.y + tr.h + 4 end

            -- 툴팁 배경
            local rarity_tip = t.data.rarity
            local tip_border = rarity_tip == "legendary" and {0.85, 0.65, 0.10}
                or (rarity_tip == "rare"    and {0.50, 0.35, 0.80}
                or (rarity_tip == "cursed"  and {0.70, 0.15, 0.15}
                or PAL.cyan))
            set({0.06, 0.04, 0.10, 0.96})
            love.graphics.rectangle("fill", tip_x, tip_y, tip_w, tip_h, 4)
            set(tip_border)
            love.graphics.rectangle("line", tip_x, tip_y, tip_w, tip_h, 4)

            -- 좌측 아이콘
            if tip_icon then
                local pad = (tip_h - tip_icon_sz) / 2
                local scale = tip_icon_sz / math.max(tip_icon:getWidth(), tip_icon:getHeight())
                love.graphics.setColor(1, 1, 1, 1)
                love.graphics.draw(tip_icon, tip_x + 8, tip_y + pad, 0, scale, scale)
            end

            -- 우측 텍스트
            local text_x = tip_x + 8 + icon_area
            local cy = tip_y + 8
            set(PAL.white)
            love.graphics.printf(name, text_x, cy, content_w, "left")
            cy = cy + #name_lines * fh + 2
            if trigger_str ~= "" then
                set({0.5, 0.75, 1.0})
                love.graphics.printf("발동: " .. trigger_str, text_x, cy, content_w, "left")
                cy = cy + fh
            end
            set({0.7, 0.7, 0.75})
            love.graphics.printf(desc, text_x, cy, content_w, "left")
            cy = cy + #desc_lines * fh + 2
            if effect_str ~= "" then
                set(PAL.gold)
                love.graphics.printf(effect_str, text_x, cy, content_w, "left")
            end
        end
    end

    -- ======= 고정 버튼바 (최하단 중앙) =======
    -- btn_y는 카드 배치 시 이미 계산됨
    set(PAL.panel); love.graphics.rectangle("fill", 0, btn_y-6, W, 50)
    set(PAL.border); love.graphics.line(0, btn_y-6, W, btn_y-6)

    if S.state == "in_round" then
        local col = #S.selected > 0 and PAL.btn_red or PAL.btn_dim
        ui_btn("내기!", CX-55, btn_y, 110, UI.btn_h, col, do_bet)
    elseif S.state == "go_stop" then
        ui_btn("고", CX-120, btn_y, 100, UI.btn_h, PAL.red, do_go)
        ui_btn("스톱", CX+20, btn_y, 100, UI.btn_h, PAL.btn_blue, do_stop)
        -- 리스크 텍스트 (버튼 우측에 표시)
        love.graphics.setFont(fonts.s); set({1,0.5,0.5})
        local ri = math.min((S.go_count or 0)+1, 3)
        love.graphics.printf(({"고 1: +3장 ×1.8","고 2: +2장 ×2.8","고 3: +1장 ×5.0 즉사위험!"})[ri], CX+130, btn_y+4, 250, "left")
    end

    -- ======= 설정(톱니바퀴) 버튼 (우상단) =======
    ui_btn("SET", W-46, 36, 38, 24, PAL.btn_dim, function()
        S._return_from_settings = S.state
        S.state = "settings"
    end)
    -- 톱니바퀴 아이콘 (버튼 위에 도트 아이콘)
    PIX.draw(PIX.gear, W-41, 38, 18)

    -- ======= 족보 가이드 버튼 (설정 왼쪽) =======
    ui_btn("?", W-78, 36, 30, 24, PAL.btn_dim, function()
        show_yokbo_guide = true
        YokboGuide.reset_scroll()
    end)

    -- ======= 손패 정렬 버튼 (하단 좌측) =======
    local sort_col = sort_mode ~= "none" and PAL.btn_blue or PAL.btn_dim
    ui_btn(sort_labels[sort_mode], 10, btn_y, 70, UI.btn_h, sort_col, function()
        local idx = 1
        for j, m in ipairs(sort_order) do if m == sort_mode then idx = j; break end end
        idx = idx % #sort_order + 1
        sort_mode = sort_order[idx]
        sort_hand()
    end)

    -- ======= 카드 색상 가이드 (우측 상단) =======
    love.graphics.setFont(fonts.s)
    local guide_x = W - 110
    local gy = 70
    set(PAL.dim)
    love.graphics.print("카드 종류:", guide_x, gy)
    gy = gy + 16
    local card_types = {
        {{1, 0.82, 0},       "광 (최강)"},
        {{0.80, 0.12, 0.12}, "홍단"},
        {{0.12, 0.35, 0.78}, "청단"},
        {{0.15, 0.60, 0.18}, "초단"},
        {{0.25, 0.65, 0.85}, "그림"},
        {{0.60, 0.60, 0.65}, "피 (약)"},
    }
    for _, ct in ipairs(card_types) do
        Icons.square(guide_x, gy+2, 8, ct[1])
        set(ct[1])
        love.graphics.print(" "..ct[2], guide_x+12, gy)
        gy = gy + 14
    end

    -- ======= 실시간 콤보 미리보기 (우측 패널, 카드 가이드 아래) =======
    if S.state == "in_round" and #S.selected > 0 then
        local preview_combos = HandEvaluator.evaluate(S.selected)
        local cpw = 180
        local cpx = W - cpw - 10
        local cpy = gy + 24  -- 카드 가이드 바로 아래

        local cph = 30  -- 기본 높이 (콤보 없음 패널)
        if #preview_combos > 0 then
            -- 카테고리별 그룹핑
            local cat_order = {"gostop", "seotda", "jeoseung", "seasonal", "collection", "monthpair", "fallback"}
            local cat_labels = {gostop="고스톱", seotda="섯다", jeoseung="저승",
                seasonal="계절", collection="수집", monthpair="월합", fallback="기본"}
            local cat_colors = {gostop=PAL.gold, seotda=PAL.cyan, jeoseung=PAL.purple,
                seasonal={0.3,0.85,0.4}, collection=PAL.white, monthpair=PAL.dim, fallback={0.58,0.55,0.55}}
            local groups = {}
            for _, combo in ipairs(preview_combos) do
                local cat = combo.category or "fallback"
                if not groups[cat] then groups[cat] = {} end
                groups[cat][#groups[cat]+1] = combo
            end
            -- 높이 계산
            local line_count = 0
            local group_count = 0
            for _, cat in ipairs(cat_order) do
                if groups[cat] then
                    group_count = group_count + 1
                    line_count = line_count + #groups[cat]
                end
            end
            cph = 4 + group_count * 16 + line_count * 15
            panel(cpx, cpy, cpw, cph, true)
            love.graphics.setFont(fonts.s)
            local dy = cpy + 2
            for _, cat in ipairs(cat_order) do
                if groups[cat] then
                    -- 카테고리 헤더
                    local col = cat_colors[cat] or PAL.white
                    set(col)
                    love.graphics.print(cat_labels[cat] or cat, cpx+5, dy)
                    dy = dy + 14
                    -- 족보 목록
                    for _, combo in ipairs(groups[cat]) do
                        local tier_colors = {
                            [1]={1,0.84,0}, [2]={0.25,0.9,0.85}, [3]={0.15,0.7,0.2},
                            [4]={0.65,0.65,0.65}, [5]={0.55,0.48,0.45}
                        }
                        set(tier_colors[combo.tier] or PAL.white)
                        love.graphics.printf(
                            string.format("  [%s] %s +%d ×%.1f",
                                ({"S","A","B","C","D"})[combo.tier] or "?",
                                combo.name_kr, combo.chips, combo.mult),
                            cpx + 5, dy, cpw - 10, "left")
                        dy = dy + 15
                    end
                end
            end
        else
            panel(cpx, cpy, cpw, 30, true)
            love.graphics.setFont(fonts.s)
            set({0.65, 0.45, 0.45})
            love.graphics.printf("콤보 없음", cpx, cpy+8, cpw, "center")
        end

    end

    -- ======= TIP 안내 (정렬 버튼 우측) =======
    love.graphics.setFont(fonts.s)
    set({0.48, 0.48, 0.58})
    if S.state == "in_round" then
        love.graphics.print("TIP: 같은 월 카드 = 땡! 같은 종류 = 단!", 90, btn_y+4)
    end
end

-- ===========================
-- 화면: 라운드 결과
-- ===========================
local function scr_post_round()
    topbar()
    if S.battle and S.battle:is_boss_defeated() then return end
    local CY = H/2
    title("보스 생존! 다음 판...", CY - 60)
    if S.battle then
        subtitle(string.format("HP: %s / %s", NumFmt.format(S.battle.boss_current_hp), NumFmt.format(S.battle.boss_max_hp)), CY - 30)
    end
    ui_btn("다음 판", W/2-55, CY + 10, 110, UI.btn_h, {0.50,0.22,0.06}, function() S.selected={}; start_round() end)
    draw_msgs(CY + 60)
end

-- ===========================
-- 화면: 강화 선택 (정중앙)
-- ===========================
local function scr_upgrade()
    topbar()
    local CY = H/2

    title("강화 선택", CY - 150)
    subtitle((S.boss and S.boss.name_kr or "보스") .. " 격파! 하나를 선택하세요.", CY - 120)

    local cw, ch, gap = 180, 200, 16
    local sx = (W - (#S.upgrades * (cw+gap) - gap)) / 2
    local card_y = CY - 100

    for i, u in ipairs(S.upgrades) do
        local ux = sx + (i-1)*(cw+gap)

        -- 카드 배경
        panel(ux, card_y, cw, ch, true)

        -- 강화별 테마 색상
        local uc = u.color or {0.5, 0.5, 0.6}

        -- 아이콘 영역 (색상 배경)
        local img_size = 80
        local img_x = ux + (cw - img_size) / 2
        local img_y = card_y + 10
        -- 색상 배경 글로우
        set({uc[1]*0.3, uc[2]*0.3, uc[3]*0.3})
        love.graphics.rectangle("fill", img_x, img_y, img_size, img_size, 6)
        -- 테두리 (테마 색상)
        set({uc[1]*0.8, uc[2]*0.8, uc[3]*0.8, 0.6})
        love.graphics.rectangle("line", img_x, img_y, img_size, img_size, 6)
        -- 아이콘
        local icon = u.icon or PIX.star
        PIX.draw(icon, img_x + (img_size-48)/2, img_y + (img_size-48)/2, 48)

        -- 강화 이름 (테마 색상)
        love.graphics.setFont(fonts.m); set(uc)
        love.graphics.printf(u.name, ux, img_y + img_size + 8, cw, "center")

        -- 설명 (밝은 회색)
        love.graphics.setFont(fonts.s); set({0.75, 0.72, 0.68})
        love.graphics.printf(u.desc, ux+10, img_y + img_size + 28, cw-20, "center")

        local idx = i
        ui_btn("선택", ux+(cw-100)/2, card_y+ch-36, 100, 28, PAL.btn_green, function()
            S.upgrades[idx].fn(); msg("강화: "..S.upgrades[idx].name)
            gen_shop(); S.state = "shop"
        end)
    end
end

-- ===========================
-- 화면: 저승 장터
-- ===========================
local function scr_shop()
    topbar()
    local CY = H/2

    title("저승 장터", CY - 170)
    subtitle("\"어서 와, 살아있는 손님은 오랜만이야.\"", CY - 145)

    love.graphics.setFont(fonts.s); set(PAL.gold)
    love.graphics.printf("보유: " .. S.player.yeop .. " 냥", 0, CY - 125, W, "center")

    local cw, gap = 155, 8
    local total = #S.shop_items
    local cols = math.min(total, 5)
    local sx = (W - (cols * (cw+gap) - gap)) / 2
    local base_y = CY - 100

    -- 이미지 48 + 이름(가변) + 설명(가변) + 가격 + 버튼 + 여백
    local ch = 190

    for i, item in ipairs(S.shop_items) do
        local ix = sx + ((i-1) % cols) * (cw+gap)
        local iy = base_y + math.floor((i-1)/cols) * (ch+gap)

        panel(ix, iy, cw, ch, item.sold)

        -- 이미지 영역 (1:1, 상단)
        local img_size = 48
        local img_x = ix + (cw - img_size) / 2
        local img_y = iy + 6
        set(item.sold and {0.08,0.08,0.12} or {0.12, 0.12, 0.18})
        love.graphics.rectangle("fill", img_x, img_y, img_size, img_size, 4)
        set(item.sold and {0.18,0.18,0.25} or {0.25, 0.25, 0.35})
        love.graphics.rectangle("line", img_x, img_y, img_size, img_size, 4)
        -- 타입별 도트 아이콘
        local icon_fn = PIX.talisman
        if item.type == "health" then icon_fn = PIX.potion
        elseif item.type == "card_pack" then icon_fn = PIX.card_pack
        elseif item.type == "copy_mirror" then icon_fn = PIX.mirror
        elseif item.type == "copy_all" then icon_fn = PIX.thread end
        PIX.draw(icon_fn, img_x + (img_size-32)/2, img_y + (img_size-32)/2, 32)

        -- 텍스트 시작 y (이미지 아래)
        local ty = img_y + img_size + 4

        -- 아이템 이름
        love.graphics.setFont(fonts.m)
        set(item.sold and PAL.dim or PAL.white)
        love.graphics.printf(item.name, ix+4, ty, cw-8, "center")
        local _, name_lines = fonts.m:getWrap(item.name, cw-8)
        ty = ty + #name_lines * fonts.m:getHeight() + 2

        -- 효과 설명
        love.graphics.setFont(fonts.s)
        set(PAL.cyan)
        love.graphics.printf(item.desc or "", ix+4, ty, cw-8, "center")
        local _, desc_lines = fonts.s:getWrap(item.desc or "", cw-8)
        ty = ty + #desc_lines * fonts.s:getHeight() + 2

        -- 가격
        set(PAL.gold)
        love.graphics.printf(item.sold and "구매완료" or (item.cost.."냥"), ix+4, ty, cw-8, "center")

        -- 구매 버튼 (카드 하단 고정)
        if not item.sold then
            local idx = i
            local affordable = S.player.yeop >= item.cost
            ui_btn("구매", ix+(cw-70)/2, iy+ch-28, 70, 22, affordable and PAL.btn_green or PAL.btn_dim, function()
                local it = S.shop_items[idx]
                if it.sold or S.player.yeop < it.cost then msg("구매 불가!"); return end
                S.player.yeop = S.player.yeop - it.cost; it.sold = true; SFX.play("purchase")
                if it.type == "health" then
                    S.player.lives = math.min(S.player.lives+1, 10); msg("체력 +1!")
                elseif it.type == "card_pack" then
                    S.player.next_round_hand_bonus = (S.player.next_round_hand_bonus or 0) + 2; msg("패 팩! 손패 +2")
                elseif it.type == "copy_mirror" then
                    -- 혼백 거울: 다음 보스전에서 족보 등록 카드 1장 복사
                    S._copy_mode = "single"
                    msg("혼백 거울! 다음 판에서 족보 카드 1장이 복사됩니다!")
                elseif it.type == "copy_all" then
                    -- 윤회의 실: 다음 보스전에서 족보 등록 카드 전부 복사
                    S._copy_mode = "all"
                    msg("윤회의 실! 다음 판에서 족보 카드 전부가 복사됩니다!")
                elseif it.type == "talisman" then
                    -- 부적 장착 (DB 데이터 연동)
                    local tdata = it.talisman_data or {name_kr=it.name, description_kr=it.desc}
                    local inst = {data=tdata, effect=it.effect or {}, is_active=true}
                    S.player.talismans[#S.player.talismans+1] = inst
                    -- 즉시 반영 가능한 효과
                    if it.effect then
                        if it.effect.chip then S.player.wave_chip_bonus = S.player.wave_chip_bonus + it.effect.chip end
                        if it.effect.mult then S.player.wave_mult_bonus = S.player.wave_mult_bonus + it.effect.mult end
                    end
                    local rarity_kr = ({common="일반", rare="희귀", legendary="전설"})[it.rarity or "common"] or ""
                    msg(string.format("[%s] %s 장착!", rarity_kr, it.name))
                    show_center_msg(it.name .. " 장착!", it.desc, 1.5, PAL.cyan)
                    -- 발견 추적: 부적
                    if it.talisman_data and it.talisman_data.id then
                        S.discovered.talismans[it.talisman_data.id] = true
                    end
                    -- 업적: 부적 수집
                    if S.ach then
                        S.ach:try_unlock("talisman_first")
                        if it.rarity == "legendary" then S.ach:try_unlock("legendary_first") end
                    end
                else msg(it.name .. " 구매!") end
            end)
        end
    end

    local rows = math.ceil(total / cols)
    local next_btn_y = base_y + rows * (ch + gap) + 10
    ui_btn("다음으로 >", W/2-55, next_btn_y, 110, UI.btn_h, PAL.btn_green, function()
        if S.spiral.current_realm % 2 == 0 then gen_event(); S.state = "event"
        else S.spiral:advance_realm(); S.selected={}; start_realm() end
    end)
end

-- ===========================
-- 화면: 이벤트
-- ===========================
local function scr_event()
    topbar()
    if not S.event then S.spiral:advance_realm(); S.selected={}; start_realm(); return end
    local CY = H/2

    title(S.event.title, CY - 130)
    love.graphics.setFont(fonts.m); set(PAL.white)
    love.graphics.printf(S.event.desc, W*0.2, CY - 95, W*0.6, "center")

    local cy = CY - 30
    for i, ch in ipairs(S.event.choices) do
        local bw = math.min(340, W*0.5)
        panel(W/2-bw/2, cy, bw, 34)
        ui_btn(">> "..ch.text, W/2-bw/2+4, cy+3, bw-8, 28, PAL.btn_dim, function()
            ch.fn(); msg(S.event.title.." → "..ch.result)
            S.event = nil; S.spiral:advance_realm(); S.selected={}; start_realm()
        end)
        cy = cy + 42
    end
end

-- ===========================
-- 화면: 이승의 문
-- ===========================
local function scr_gate()
    local CY = H/2
    title("이승의 문", CY - 80)
    love.graphics.setFont(fonts.m); set(PAL.white)
    love.graphics.printf("관문을 모두 통과했다!\n이승으로 돌아갈 수 있다...", 0, CY - 40, W, "center")

    local sp = S.spiral and S.spiral.current_spiral or 1
    ui_btn("이승으로 돌아간다 (엔딩)", W/2-220, CY + 20, 200, UI.btn_h, PAL.gold, function()
        msg("이승의 문 통과..."); S.state = "main_menu"
    end)
    ui_btn("계속 싸운다 (윤회 "..(sp+1)..")", W/2+40, CY + 20, 200, UI.btn_h, PAL.btn_red, function()
        if S.spiral then S.spiral:continue_to_next_spiral() end
        msg("윤회 "..(S.spiral and S.spiral.current_spiral or 2).." 진입!")
        S.selected={}; start_realm()
    end)
end

-- ===========================
-- 화면: 게임 오버
-- ===========================
local function scr_game_over()
    local CY = H/2
    title("게임 오버", CY - 200)
    love.graphics.setFont(fonts.m); set(PAL.dim)
    local sp = S.spiral and S.spiral.current_spiral or 1
    local rm = S.spiral and S.spiral.current_realm or 1
    love.graphics.printf(string.format("윤회 %d, %d관문에서 쓰러짐", sp, rm), 0, CY - 165, W, "center")

    -- 넋 획득 결과
    love.graphics.setFont(fonts.m); set(PAL.gold)
    love.graphics.printf(string.format("보유 넋: %d", S.soul), 0, CY - 135, W, "center")
    love.graphics.setFont(fonts.s); set(PAL.dim)
    love.graphics.printf(string.format("최고 기록: %d관문 | 총 %d런", S.best_realm, S.total_runs), 0, CY - 115, W, "center")

    -- 영구 강화 구매 패널
    local px, pw = W/2-280, 560
    local panel_y = CY - 85
    panel(px, panel_y, pw, 170)
    love.graphics.setFont(fonts.m); set(PAL.gold)
    love.graphics.printf("저승 수련 (넋으로 영구 강화)", px, panel_y + 7, pw, "center")
    DU.divider(px+20, panel_y + 30, pw-40, PAL.border)

    local upgrades = {
        {id="chips", name="기본 칩 +5",  cost=20*(1 + math.floor(S.perm_chips/5)), current=S.perm_chips, apply=function() S.perm_chips = S.perm_chips + 5 end},
        {id="mult",  name="기본 배수 +1", cost=50*(1 + S.perm_mult), current=S.perm_mult, apply=function() S.perm_mult = S.perm_mult + 1 end},
        {id="lives", name="시작 체력 +1", cost=150*(1 + S.perm_lives), current=S.perm_lives, max=3, apply=function() S.perm_lives = S.perm_lives + 1 end},
        {id="yeop",  name="시작 엽전 +30",cost=30*(1 + math.floor(S.perm_yeop/30)), current=S.perm_yeop, apply=function() S.perm_yeop = S.perm_yeop + 30 end},
    }

    for i, u in ipairs(upgrades) do
        local ux = px + 15 + (i-1)*135
        local uy = panel_y + 40

        panel(ux, uy, 125, 90, true)
        love.graphics.setFont(fonts.s); set(PAL.white)
        love.graphics.printf(u.name, ux, uy+8, 125, "center")
        set(PAL.dim)
        love.graphics.printf(string.format("현재: +%d", u.current), ux, uy+26, 125, "center")
        set(PAL.gold)
        love.graphics.printf(string.format("%d넋", u.cost), ux, uy+44, 125, "center")

        local maxed = u.max and (u.current >= u.max * (u.id == "lives" and 1 or 5))
        local affordable = S.soul >= u.cost and not maxed
        local idx = i
        ui_btn(maxed and "최대" or "강화", ux+22, uy+62, 80, 22, affordable and PAL.btn_green or PAL.btn_dim, function()
            if not affordable then
                if maxed then msg("이미 최대 레벨") else msg("넋이 부족합니다") end
                return
            end
            S.soul = S.soul - upgrades[idx].cost
            upgrades[idx].apply()
            msg(upgrades[idx].name .. " 강화 완료")
        end)
    end

    -- 하단 버튼
    ui_btn("다시 도전", W/2-120, CY + 110, 100, UI.btn_h, PAL.btn_red, function() S.state = "blessing_select"; new_game() end)
    ui_btn("메인 메뉴", W/2+20, CY + 110, 100, UI.btn_h, PAL.btn_dim, function() S.state = "main_menu" end)

    draw_msgs(CY + 155)
end

-- ===========================
-- 화면: 도감
-- ===========================

-- 기믹 한글 매핑
local GIMMICK_KR = {
    consume_highest = "탐식 — 최고 패 소멸",
    flip_all        = "변환 — 패 뒤집기",
    reset_field     = "소각 — 바닥패 리셋",
    disable_talisman= "봉인 — 부적 비활성",
    no_bright       = "암흑 — 광 무효화",
    steal_card      = "도적 — 먹은 패 빼앗기",
    curse_mark      = "저주 — 표식 누적 즉사",
    time_pressure   = "시한 — 턴 수 제한",
    mirror_copy     = "반사 — 족보 복사 반격",
    fog             = "농무 — 바닥패 숨기기",
    poison_pi       = "독사 — 피 카드 독",
    skullify        = "백골 — 해골패 변환",
    fake_cards      = "환혹 — 가짜 카드 혼합",
    competitive     = "경쟁 — 보스도 점수 누적",
    suppress        = "억압 — 강화 비활성+숨김",
    none            = "없음",
}

local function scr_collection()
    title("도감", H*0.08)
    subtitle("지금까지 만난 도깨비와 부적, 족보를 확인할 수 있다.", H*0.08+30)

    -- 탭 버튼 (5개: 보스, 부적, 족보, 동료, 업적)
    local tabs = {"보스", "부적", "족보", "동료", "업적"}
    local tab_w, tab_gap = 85, 5
    local tab_sx = (W - (#tabs*(tab_w+tab_gap)-tab_gap))/2
    S._col_tab = S._col_tab or 1
    S._col_scroll = S._col_scroll or 0

    for i, t in ipairs(tabs) do
        local tx = tab_sx + (i-1)*(tab_w+tab_gap)
        local col = S._col_tab == i and PAL.gold or PAL.btn_dim
        local idx = i
        ui_btn(t, tx, H*0.17, tab_w, 26, col, function() S._col_tab = idx; S._col_scroll = 0 end)
    end

    -- 내용 패널 (좌우 여백 최소화)
    local px, py, pw, ph = W*0.03, H*0.25, W*0.94, H*0.60
    panel(px, py, pw, ph)

    -- 스크롤 가능 영역 클리핑
    love.graphics.setScissor(px, py, pw, ph)

    if S._col_tab == 1 then
        -- ═══ 보스 도깨비 도감 ═══
        love.graphics.setFont(fonts.s)
        local all_bosses = BossData.get_all_bosses_for_collection()
        local cols_per_row = 4
        local b_margin = 8
        local b_gap = 6
        local item_w = math.floor((pw - b_margin*2 - b_gap*(cols_per_row-1)) / cols_per_row)
        local item_h = 75
        local oy = S._col_scroll or 0
        local discovered_count, total_count = 0, #all_bosses
        for _, b in ipairs(all_bosses) do
            if S.discovered.bosses[b.id] then discovered_count = discovered_count + 1 end
        end
        love.graphics.setFont(fonts.s); set(PAL.dim)
        love.graphics.printf(string.format("발견: %d/%d", discovered_count, total_count), px, py+1, pw-10, "right")

        for i, b in ipairs(all_bosses) do
            local c = (i-1) % cols_per_row
            local r = math.floor((i-1) / cols_per_row)
            local ix = px + b_margin + c*(item_w+b_gap)
            local iy = py + 12 + r*(item_h+b_gap) + oy
            local found = S.discovered.bosses[b.id]

            panel(ix, iy, item_w, item_h, true)

            if found then
                -- 발견된 보스: 정보 표시
                BossIcons.draw(b.id, ix+4, iy+4, item_h-8, b)
                local tier_col = PAL.white
                if b.tier == "boss" then tier_col = {1, 0.2, 0.1}
                elseif b.tier == "calamity" then tier_col = PAL.seal
                elseif b.tier == "elite" then tier_col = PAL.gold
                end
                local tx = ix + item_h - 2
                local tw = item_w - item_h + 2
                love.graphics.setFont(fonts.m); set(tier_col)
                love.graphics.printf(b.name_kr, tx, iy+5, tw, "left")
                love.graphics.setFont(fonts.s); set(PAL.dim)
                love.graphics.printf(string.format("HP:%d  %d냥", b.target_score, b.yeop_reward), tx, iy+28, tw, "left")
                local gimmick_text = GIMMICK_KR[b.gimmick] or b.gimmick or ""
                set({0.55, 0.35, 0.35})
                love.graphics.printf(gimmick_text, tx, iy+44, tw, "left")
            else
                -- 미발견: 실루엣 + ???
                set({0.15, 0.12, 0.2})
                love.graphics.rectangle("fill", ix+4, iy+4, item_h-8, item_h-8)
                set({0.3, 0.25, 0.35})
                love.graphics.setFont(fonts.l)
                love.graphics.printf("?", ix+4, iy+20, item_h-8, "center")
                local tx = ix + item_h - 2
                local tw = item_w - item_h + 2
                love.graphics.setFont(fonts.m); set({0.35, 0.3, 0.4})
                love.graphics.printf("???", tx, iy+5, tw, "left")
                love.graphics.setFont(fonts.s); set({0.25, 0.22, 0.3})
                love.graphics.printf("미발견", tx, iy+28, tw, "left")
            end
        end

    elseif S._col_tab == 2 then
        -- ═══ 부적 도감 ═══
        love.graphics.setFont(fonts.s)
        -- 실제 부적 DB에서 가져오기
        local TalismanDB = require("src.talismans.talisman_database")
        local all_tal = TalismanDB.get_all()
        local rarity_kr = {common="일반", rare="희귀", legendary="전설", cursed="저주"}
        local rarity_col_map = {common=PAL.white, rare=PAL.cyan, legendary=PAL.gold, cursed={0.7, 0.2, 0.5}}
        local rarity_icon = {common=PIX.talisman, rare=PIX.star, legendary=PIX.horn, cursed=PIX.skull}

        local cols = 3
        local margin = 8
        local gap_t = 6
        local item_w = math.floor((pw - margin*2 - gap_t*(cols-1)) / cols)
        local item_h = 70
        local oy = S._col_scroll or 0
        local disc_t, total_t = 0, #all_tal
        for _, t in ipairs(all_tal) do
            if S.discovered.talismans[t.id] then disc_t = disc_t + 1 end
        end
        love.graphics.setFont(fonts.s); set(PAL.dim)
        love.graphics.printf(string.format("발견: %d/%d", disc_t, total_t), px, py+1, pw-10, "right")

        for i, t in ipairs(all_tal) do
            local c = (i-1) % cols
            local r = math.floor((i-1) / cols)
            local ix = px + margin + c*(item_w+gap_t)
            local iy = py + 12 + r*(item_h+gap_t) + oy
            local found = S.discovered.talismans[t.id]

            panel(ix, iy, item_w, item_h, true)

            if found then
                local icon_fn = rarity_icon[t.rarity] or PIX.talisman
                PIX.draw(icon_fn, ix+6, iy+6, 28)
                local rc = rarity_col_map[t.rarity] or PAL.white
                local rk = rarity_kr[t.rarity] or "?"
                love.graphics.setFont(fonts.s); set(rc)
                love.graphics.print("["..rk.."]", ix+38, iy+4)
                love.graphics.setFont(fonts.m); set(rc)
                love.graphics.printf(t.name_kr, ix+38, iy+18, item_w-44, "left")
                love.graphics.setFont(fonts.s); set(PAL.dim)
                love.graphics.printf(t.description_kr or "", ix+6, iy+38, item_w-12, "left")
            else
                set({0.15, 0.12, 0.2})
                love.graphics.rectangle("fill", ix+6, iy+6, 28, 28)
                love.graphics.setFont(fonts.m); set({0.35, 0.3, 0.4})
                love.graphics.printf("???", ix+38, iy+18, item_w-44, "left")
                love.graphics.setFont(fonts.s); set({0.25, 0.22, 0.3})
                love.graphics.printf("미발견", ix+6, iy+38, item_w-12, "left")
            end
        end

    elseif S._col_tab == 3 then
        -- ═══ 족보 도감 (대폭 확장) ═══
        love.graphics.setFont(fonts.s)
        local yokbos = {
            -- S등급
            {tier="S", name="오광",       desc="광 5장",              chips=60,  mult=3.0},
            {tier="S", name="38광땡",     desc="3월광+8월광",         chips=50,  mult=2.5},
            {tier="S", name="황천의 다리", desc="12개월 모두 수집",   chips=70,  mult=3.5},
            {tier="S", name="삼단통",     desc="홍단+청단+초단 완성", chips=55,  mult=2.8},
            {tier="S", name="윤회",       desc="월통 3세트 이상",     chips=60,  mult=3.0},
            -- A등급
            {tier="A", name="사광",       desc="광 4장(비광 제외)",   chips=40,  mult=2.2},
            {tier="A", name="비사광",     desc="광 4장(비광 포함)",   chips=35,  mult=2.0},
            {tier="A", name="13광땡",     desc="1월광+3월광",         chips=40,  mult=2.2},
            {tier="A", name="18광땡",     desc="1월광+8월광",         chips=42,  mult=2.3},
            {tier="A", name="장땡",       desc="10월 패 2장",         chips=35,  mult=2.0},
            {tier="A", name="9땡",        desc="9월 패 2장",          chips=30,  mult=1.9},
            {tier="A", name="8땡",        desc="8월 패 2장",          chips=28,  mult=1.8},
            {tier="A", name="도깨비불",   desc="광3+피5 이상",        chips=30,  mult=1.8},
            {tier="A", name="저승꽃",     desc="피 15점 이상",        chips=30,  mult=1.8},
            {tier="A", name="삼도천",     desc="3, 6, 9월",           chips=25,  mult=1.7},
            -- B등급
            {tier="B", name="삼광",       desc="광 3장(비광 제외)",   chips=25,  mult=1.6},
            {tier="B", name="비광",       desc="비광 포함 삼광",      chips=20,  mult=1.4},
            {tier="B", name="홍단",       desc="1, 2, 3월 홍단",      chips=20,  mult=1.5},
            {tier="B", name="청단",       desc="6, 9, 10월 청단",     chips=20,  mult=1.5},
            {tier="B", name="초단",       desc="4, 5, 7월 초단",      chips=20,  mult=1.5},
            {tier="B", name="고도리",     desc="2, 4, 8월 그림",      chips=20,  mult=1.5},
            {tier="B", name="7땡",        desc="7월 패 2장",          chips=24,  mult=1.65},
            {tier="B", name="6땡",        desc="6월 패 2장",          chips=22,  mult=1.6},
            {tier="B", name="5땡",        desc="5월 패 2장",          chips=20,  mult=1.55},
            {tier="B", name="알리",       desc="1월+2월",             chips=18,  mult=1.5},
            {tier="B", name="독사",       desc="1월+4월",             chips=16,  mult=1.4},
            {tier="B", name="구삥",       desc="1월+9월",             chips=15,  mult=1.4},
            {tier="B", name="사계",       desc="3, 6, 9, 12월",       chips=22,  mult=1.5},
            {tier="B", name="선후착",     desc="1월+12월 광",         chips=22,  mult=1.5},
            -- C등급
            {tier="C", name="4땡",        desc="4월 패 2장",          chips=18,  mult=1.5},
            {tier="C", name="3땡",        desc="3월 패 2장",          chips=16,  mult=1.45},
            {tier="C", name="2땡",        desc="2월 패 2장",          chips=14,  mult=1.4},
            {tier="C", name="1땡",        desc="1월 패 2장",          chips=12,  mult=1.3},
            {tier="C", name="장삥",       desc="1월+10월",            chips=10,  mult=1.3},
            {tier="C", name="장사",       desc="4월+10월",            chips=9,   mult=1.25},
            {tier="C", name="세륙",       desc="4월+6월",             chips=8,   mult=1.2},
            {tier="C", name="월하독작",   desc="8월광+9월그림",       chips=12,  mult=1.3},
            {tier="C", name="띠 5장",     desc="띠 카드 5장",         chips=10,  mult=1.3},
            {tier="C", name="그림 5장",   desc="그림 카드 5장",       chips=10,  mult=1.3},
            {tier="C", name="피 10장",    desc="피 10점 이상",        chips=8,   mult=1.2},
            {tier="C", name="봄의 연회",  desc="봄 카드 4+1,2,3월",   chips=18,  mult=1.4},
            {tier="C", name="가을단풍",   desc="가을 카드 4+8,9,10월",chips=18,  mult=1.4},
            {tier="C", name="여름바람",   desc="여름 카드 3+6,7,8월", chips=8,   mult=1.2},
            {tier="C", name="겨울한파",   desc="11월+12월",           chips=7,   mult=1.2},
            {tier="C", name="염라의 심판",desc="1월+11월 광",         chips=14,  mult=1.4},
            {tier="C", name="도깨비방망이",desc="그림 3장 이상",      chips=10,  mult=1.3},
            -- D등급
            {tier="D", name="끗 9",       desc="월합 끝자리 9",       chips=13,  mult=1.27},
            {tier="D", name="끗 8",       desc="월합 끝자리 8",       chips=11,  mult=1.24},
            {tier="D", name="끗 7",       desc="월합 끝자리 7",       chips=9,   mult=1.21},
            {tier="D", name="끗 6",       desc="월합 끝자리 6",       chips=7,   mult=1.18},
            {tier="D", name="끗 5",       desc="월합 끝자리 5",       chips=5,   mult=1.15},
            {tier="D", name="망통",       desc="월합 끝자리 0",       chips=2,   mult=0.5},
            {tier="D", name="단일패",     desc="카드 1장",            chips=3,   mult=1.0},
            {tier="D", name="피짝",       desc="피 카드만",           chips=3,   mult=1.0},
            -- P등급 (패널티)
            {tier="P", name="⚠ 삼봉",    desc="같은 달 정확히 3장",  chips=-10, mult=0.6,  is_penalty=true},
            {tier="P", name="⚠ 나가리",  desc="피만 4장 이상 선택",  chips=-8,  mult=0.65, is_penalty=true},
            {tier="P", name="⚠ 업보",    desc="월 합 50 이상+3장",   chips=-6,  mult=0.7,  is_penalty=true},
            {tier="P", name="⚠ 빈손",    desc="망통+3장 이상 선택",  chips=-5,  mult=0.55, is_penalty=true},
        }
        local tier_colors = {S=PAL.gold, A=PAL.cyan, B=PAL.green, C=PAL.dim, D={0.58,0.48,0.45}, P={0.90,0.20,0.15}}
        local tier_icons = {S=PIX.horn, A=PIX.star, B=PIX.sword, C=PIX.shield, D=PIX.talisman}
        local cols = 3
        local y_margin = 8
        local y_gap = 5
        local item_w = math.floor((pw - y_margin*2 - y_gap*(cols-1)) / cols)
        local item_h = 55
        local oy = S._col_scroll or 0
        -- 족보별 id 생성 (이름 기반)
        local disc_y, total_y = 0, #yokbos
        for _, y in ipairs(yokbos) do
            y._id = y._id or y.name:gsub(" ", "_")
            if S.discovered.yokbos[y._id] then disc_y = disc_y + 1 end
        end
        love.graphics.setFont(fonts.s); set(PAL.dim)
        love.graphics.printf(string.format("발견: %d/%d", disc_y, total_y), px, py+1, pw-10, "right")

        for i, y in ipairs(yokbos) do
            local c = (i-1) % cols
            local r = math.floor((i-1) / cols)
            local ix = px + y_margin + c*(item_w+y_gap)
            local iy = py + 12 + r*(item_h+y_gap) + oy
            local found = S.discovered.yokbos[y._id]

            panel(ix, iy, item_w, item_h, true)

            if found then
                local icon_fn = tier_icons[y.tier] or PIX.talisman
                PIX.draw(icon_fn, ix+4, iy+4, 22)
                local tc = tier_colors[y.tier] or PAL.white
                love.graphics.setFont(fonts.m); set(tc)
                love.graphics.print("[" .. y.tier .. "] " .. y.name, ix+30, iy+5)
                love.graphics.setFont(fonts.s); set(PAL.dim)
                love.graphics.print(y.desc, ix+30, iy+22)
                -- 패널티는 빨간 칩 표시, 일반은 청록
                local chips_label = (y.chips >= 0) and string.format("칩+%d  ×%.1f", y.chips, y.mult)
                    or string.format("칩%d  ×%.1f", y.chips, y.mult)
                set(y.is_penalty and {0.90, 0.30, 0.25} or PAL.cyan)
                love.graphics.printf(chips_label, ix+4, iy+38, item_w-8, "left")
            else
                -- 미발견: 티어 아이콘만 표시 + ???
                local tc = tier_colors[y.tier] or PAL.dim
                love.graphics.setFont(fonts.m); set({tc[1]*0.4, tc[2]*0.4, tc[3]*0.4})
                love.graphics.print("[" .. y.tier .. "] ???", ix+30, iy+5)
                love.graphics.setFont(fonts.s); set({0.25, 0.22, 0.3})
                love.graphics.print("미발견", ix+30, iy+22)
            end
        end

    elseif S._col_tab == 4 then
        -- ═══ 동료 도감 ═══
        love.graphics.setFont(fonts.s)
        local CompMgr = require("src.core.companion_manager")
        local all_comps = CompMgr.get_all_companions and CompMgr.get_all_companions() or {
            {id="glutton",   name_kr="먹보 도깨비",      boss_id="glutton",   desc="피 카드 1장당 칩 +3"},
            {id="trickster", name_kr="장난꾸러기 도깨비", boss_id="trickster", desc="매칭 시 50% 와일드카드"},
            {id="fox",       name_kr="여우 도깨비",      boss_id="fox",       desc="매 턴 바닥패 1장 공개"},
            {id="mirror",    name_kr="거울 도깨비",      boss_id="mirror",    desc="보스 기믹 1회 반사"},
            {id="flame",     name_kr="불꽃 도깨비",      boss_id="flame",     desc="매 판 시작 시 칩 +15"},
            {id="shadow",    name_kr="그림자 도깨비",    boss_id="shadow",    desc="보스 반격 50% 회피"},
            {id="boatman",   name_kr="뱃사공",           boss_id=nil,         desc="매 관문 시작 시 손패 +1"},
        }

        local disc_c, total_c = 0, #all_comps
        for _, c in ipairs(all_comps) do
            if S.discovered.companions[c.id] then disc_c = disc_c + 1 end
        end
        set(PAL.dim)
        love.graphics.printf(string.format("해금: %d/%d", disc_c, total_c), px, py+1, pw-10, "right")

        local cols_c = 3
        local margin_c = 8
        local gap_c = 6
        local cw = math.floor((pw - margin_c*2 - gap_c*(cols_c-1)) / cols_c)
        local ch = 75
        local oy = S._col_scroll or 0

        for i, comp in ipairs(all_comps) do
            local c = (i-1) % cols_c
            local r = math.floor((i-1) / cols_c)
            local ix = px + margin_c + c*(cw+gap_c)
            local iy = py + 12 + r*(ch+gap_c) + oy
            local found = S.discovered.companions[comp.id]

            panel(ix, iy, cw, ch, true)

            if found then
                -- 해금: 보스 아이콘 + 이름 + 효과
                if comp.boss_id then
                    BossIcons.draw(comp.boss_id, ix+4, iy+4, ch-8, {})
                else
                    -- 뱃사공 등 특수 동료
                    set(PAL.cyan)
                    love.graphics.setFont(fonts.l)
                    love.graphics.printf("☆", ix+4, iy+18, ch-8, "center")
                end
                local tx = ix + ch - 2
                local tw = cw - ch + 2
                love.graphics.setFont(fonts.m); set(PAL.cyan)
                love.graphics.printf(comp.name_kr, tx, iy+5, tw, "left")
                love.graphics.setFont(fonts.s); set(PAL.dim)
                love.graphics.printf(comp.desc or "", tx, iy+25, tw, "left")
                set(PAL.green)
                love.graphics.printf("해금됨", tx, iy+48, tw, "left")
            else
                -- 미해금: 실루엣
                set({0.15, 0.12, 0.2})
                love.graphics.rectangle("fill", ix+4, iy+4, ch-8, ch-8)
                set({0.3, 0.25, 0.35})
                love.graphics.setFont(fonts.l)
                love.graphics.printf("?", ix+4, iy+20, ch-8, "center")
                local tx = ix + ch - 2
                local tw = cw - ch + 2
                love.graphics.setFont(fonts.m); set({0.35, 0.3, 0.4})
                love.graphics.printf("???", tx, iy+5, tw, "left")
                love.graphics.setFont(fonts.s); set({0.25, 0.22, 0.3})
                love.graphics.printf("보스를 격파하면 해금", tx, iy+25, tw, "left")
            end
        end

    else
        -- ═══ 업적 탭 ═══
        love.graphics.setFont(fonts.s)
        local all_ach = S.ach and S.ach:get_all_achievements() or {}
        local ach_unlocked = S.ach and S.ach:get_unlocked_count() or 0
        local ach_total = #all_ach
        set(PAL.dim)
        love.graphics.printf(string.format("해금: %d/%d", ach_unlocked, ach_total), px, py+1, pw-10, "right")
        local cat_names = {
            progress="진행", yokbo="족보", go_stop="고/스톱",
            combat="전투", collect="수집", special="특수", hidden="히든"
        }
        local cat_colors = {
            progress=PAL.green, yokbo=PAL.cyan, go_stop=PAL.gold,
            combat={0.9,0.3,0.3}, collect={0.6,0.8,1.0}, special={0.8,0.5,1.0}, hidden=PAL.dim
        }
        local cols = 3
        local margin = 8
        local gap = 6
        local item_w = math.floor((pw - margin*2 - gap*(cols-1)) / cols)
        local item_h = 50
        local oy = S._col_scroll or 0
        for i, a in ipairs(all_ach) do
            local c = (i-1) % cols
            local r = math.floor((i-1) / cols)
            local ix = px + margin + c*(item_w+gap)
            local iy = py + 12 + r*(item_h+gap) + oy

            local unlocked = S.ach and S.ach:is_unlocked(a.id)
            panel(ix, iy, item_w, item_h, true)

            -- 해금된 업적: 체크마크 배경
            if unlocked then
                set({0.1, 0.25, 0.1, 0.3})
                love.graphics.rectangle("fill", ix+1, iy+1, item_w-2, item_h-2)
            end

            -- 카테고리 아이콘
            local cat_icon = {
                progress=PIX.arrow_right, yokbo=PIX.star, go_stop=PIX.coin,
                combat=PIX.sword, collect=PIX.card_pack, special=PIX.horn, hidden=PIX.skull
            }
            local icon_fn = cat_icon[a.category] or PIX.talisman
            PIX.draw(icon_fn, ix+4, iy+4, 20)
            -- 카테고리 태그
            local cat_kr = cat_names[a.category] or "기타"
            local cat_col = cat_colors[a.category] or PAL.white
            love.graphics.setFont(fonts.s); set(unlocked and cat_col or {cat_col[1]*0.4, cat_col[2]*0.4, cat_col[3]*0.4})
            love.graphics.print("["..cat_kr.."]", ix+28, iy+4)
            -- 업적 이름
            love.graphics.setFont(fonts.m)
            if unlocked then
                set(PAL.white)
                love.graphics.printf(a.is_hidden and a.name_kr or a.name_kr, ix+28, iy+18, item_w-34, "left")
            else
                set({0.35, 0.3, 0.4})
                local display_name = a.is_hidden and "???" or a.name_kr
                love.graphics.printf(display_name, ix+28, iy+18, item_w-34, "left")
            end
            -- 설명
            love.graphics.setFont(fonts.s)
            if unlocked then
                set(PAL.dim)
                love.graphics.printf(a.description_kr, ix+6, iy+34, item_w-12, "left")
            else
                set({0.25, 0.22, 0.3})
                local display_desc = a.is_hidden and "숨겨진 업적" or a.description_kr
                love.graphics.printf(display_desc, ix+6, iy+34, item_w-12, "left")
            end
            -- 보상 (해금 여부 표시)
            if a.soul_reward > 0 then
                PIX.draw(PIX.soul, ix+item_w-40, iy+4, 14)
                set(unlocked and PAL.green or PAL.gold)
                love.graphics.print((unlocked and "✓ " or "") .. a.soul_reward.."넋", ix+item_w-24, iy+4)
            end
        end
    end

    love.graphics.setScissor()

    -- 스크롤 안내 + 뒤로가기 (패널 바로 아래 한 줄)
    love.graphics.setFont(fonts.s); set(PAL.dim)
    love.graphics.printf("마우스 휠로 스크롤", px, py+ph+6, pw, "center")

    ui_btn("< 돌아가기", W/2-55, py+ph+22, 110, UI.btn_h, PAL.btn_dim, function() S.state = "main_menu" end)
end

-- ===========================
-- 화면: 설정
-- ===========================
local function scr_settings()
    title("설정", H*0.12)

    local cx, cw = W/2-150, 300
    local sy = H*0.25

    -- 16x16 도트 아이콘 그리기 (픽셀아트)
    local function draw_dots(ix, iy, dots, color)
        set(color)
        for _, d in ipairs(dots) do
            love.graphics.rectangle("fill", ix + d[1], iy + d[2], 1, 1)
        end
    end

    local function icon_globe(ix, iy)
        -- 지구본 16x16 도트
        local c1 = PAL.cyan
        local c2 = {0.15, 0.55, 0.70}
        -- 외곽 원
        draw_dots(ix, iy, {
            {5,0},{6,0},{7,0},{8,0},{9,0},{10,0},
            {3,1},{4,1},{11,1},{12,1},
            {2,2},{13,2},
            {1,3},{14,3},
            {1,4},{14,4},
            {0,5},{15,5},
            {0,6},{15,6},
            {0,7},{15,7},
            {0,8},{15,8},
            {0,9},{15,9},
            {0,10},{15,10},
            {1,11},{14,11},
            {1,12},{14,12},
            {2,13},{13,13},
            {3,14},{4,14},{11,14},{12,14},
            {5,15},{6,15},{7,15},{8,15},{9,15},{10,15},
        }, c1)
        -- 가로선 (적도)
        draw_dots(ix, iy, {
            {1,7},{2,7},{3,7},{4,7},{5,7},{6,7},{7,7},{8,7},{9,7},{10,7},{11,7},{12,7},{13,7},{14,7},
        }, c2)
        -- 세로선 (경선)
        draw_dots(ix, iy, {
            {7,1},{7,2},{7,3},{7,4},{7,5},{7,6},{7,8},{7,9},{7,10},{7,11},{7,12},{7,13},{7,14},
        }, c2)
        -- 대륙 느낌 점들
        draw_dots(ix, iy, {
            {4,3},{5,3},{9,3},{10,3},
            {3,4},{4,4},{5,4},{10,4},{11,4},
            {3,5},{4,5},{5,5},{10,5},{11,5},
            {4,6},{5,6},{11,6},
            {3,9},{4,9},{9,9},{10,9},{11,9},
            {4,10},{5,10},{9,10},{10,10},
            {5,11},{6,11},{9,11},
        }, c1)
    end

    local function icon_speed(ix, iy)
        -- 번개 16x16 도트
        draw_dots(ix, iy, {
            {7,0},{8,0},{9,0},{10,0},
            {6,1},{7,1},{8,1},{9,1},
            {5,2},{6,2},{7,2},{8,2},
            {4,3},{5,3},{6,3},{7,3},
            {3,4},{4,4},{5,4},{6,4},{7,4},{8,4},{9,4},{10,4},{11,4},
            {4,5},{5,5},{6,5},{7,5},{8,5},{9,5},{10,5},
            {6,6},{7,6},{8,6},{9,6},
            {7,7},{8,7},{9,7},
            {8,8},{9,8},{10,8},
            {9,9},{10,9},{11,9},
            {10,10},{11,10},
            {9,11},{10,11},
            {8,12},{9,12},
            {7,13},{8,13},
            {6,14},{7,14},
            {5,15},{6,15},
        }, PAL.gold)
    end

    local function icon_shake(ix, iy)
        -- 흔들림/진동 16x16 도트
        local c = PAL.white
        -- 중앙 사각형 (폰/화면)
        draw_dots(ix, iy, {
            {5,2},{6,2},{7,2},{8,2},{9,2},{10,2},
            {5,3},{10,3},
            {5,4},{10,4},
            {5,5},{10,5},
            {5,6},{10,6},
            {5,7},{10,7},
            {5,8},{10,8},
            {5,9},{10,9},
            {5,10},{10,10},
            {5,11},{10,11},
            {5,12},{6,12},{7,12},{8,12},{9,12},{10,12},
        }, c)
        -- 왼쪽 진동선
        draw_dots(ix, iy, {
            {3,4},{2,5},{2,6},{2,7},{2,8},{2,9},{3,10},
            {1,6},{0,7},{1,8},
        }, PAL.dim)
        -- 오른쪽 진동선
        draw_dots(ix, iy, {
            {12,4},{13,5},{13,6},{13,7},{13,8},{13,9},{12,10},
            {14,6},{15,7},{14,8},
        }, PAL.dim)
    end

    local function icon_music(ix, iy)
        -- 음표 16x16 도트
        draw_dots(ix, iy, {
            -- 기둥 1
            {5,3},{5,4},{5,5},{5,6},{5,7},{5,8},{5,9},{5,10},{5,11},
            -- 기둥 2
            {11,2},{11,3},{11,4},{11,5},{11,6},{11,7},{11,8},{11,9},
            -- 연결 가로선 (깃발)
            {5,2},{6,2},{7,2},{8,2},{9,2},{10,2},{11,2},
            {6,3},{7,3},{8,3},{9,3},{10,3},{11,3},
            -- 음표 머리 1
            {3,12},{4,12},{5,12},{6,12},
            {2,13},{3,13},{4,13},{5,13},
            {3,14},{4,14},
            -- 음표 머리 2
            {9,10},{10,10},{11,10},{12,10},
            {8,11},{9,11},{10,11},{11,11},
            {9,12},{10,12},
        }, PAL.gold)
    end

    local function icon_speaker(ix, iy)
        -- 스피커 16x16 도트
        -- 스피커 본체
        draw_dots(ix, iy, {
            {1,5},{1,6},{1,7},{1,8},{1,9},{1,10},
            {2,5},{2,6},{2,7},{2,8},{2,9},{2,10},
            {3,5},{3,6},{3,7},{3,8},{3,9},{3,10},
            {4,4},{4,5},{4,6},{4,7},{4,8},{4,9},{4,10},{4,11},
            {5,3},{5,4},{5,11},{5,12},
            {6,2},{6,3},{6,12},{6,13},
            {7,1},{7,2},{7,13},{7,14},
        }, PAL.white)
        -- 음파 1
        draw_dots(ix, iy, {
            {9,5},{9,6},{9,7},{9,8},{9,9},{9,10},
        }, PAL.cyan)
        -- 음파 2
        draw_dots(ix, iy, {
            {11,3},{11,4},{11,5},{11,6},{11,7},{11,8},{11,9},{11,10},{11,11},{11,12},
        }, {0.15, 0.60, 0.55})
        -- 음파 3
        draw_dots(ix, iy, {
            {13,2},{13,3},{13,4},{13,5},{13,6},{13,7},{13,8},{13,9},{13,10},{13,11},{13,12},{13,13},
        }, {0.10, 0.40, 0.38})
    end

    local ico_sz = 16
    local lbl_x = cx + 8 + ico_sz + 6

    -- 일반 설정 항목들
    local settings_items = {
        {label="언어",      current="한국어", options={"한국어","English","日本語","中文"}, icon=icon_globe},
        {label="연출 속도",  current="보통",   options={"느리게","보통","빠르게"},         icon=icon_speed},
        {label="화면 흔들림", current="켜짐",   options={"켜짐","꺼짐"},                 icon=icon_shake},
    }

    S._settings = S._settings or {}
    for _, item in ipairs(settings_items) do
        S._settings[item.label] = S._settings[item.label] or item.current
    end

    -- 볼륨 초기값 (숫자)
    if type(S._settings["BGM 볼륨"]) == "string" then S._settings["BGM 볼륨"] = nil end
    if type(S._settings["SFX 볼륨"]) == "string" then S._settings["SFX 볼륨"] = nil end
    S._settings["BGM 볼륨"] = S._settings["BGM 볼륨"] or 10
    S._settings["SFX 볼륨"] = S._settings["SFX 볼륨"] or 10

    -- 일반 설정 (드롭다운 + 아이콘)
    for i, item in ipairs(settings_items) do
        local iy = sy + (i-1)*50

        panel(cx, iy, cw, 40)

        -- 아이콘
        item.icon(cx+8, iy+12)

        -- 라벨
        love.graphics.setFont(fonts.m); set(PAL.white)
        love.graphics.print(item.label, lbl_x, iy+10)

        -- 현재 값
        love.graphics.setFont(fonts.m); set(PAL.gold)
        love.graphics.printf(S._settings[item.label], cx, iy+10, cw-50, "right")

        -- 변경 버튼
        local lbl = item.label
        local opts = item.options
        ui_btn(">", cx+cw-40, iy+6, 32, 28, PAL.btn_dim, function()
            local cur = S._settings[lbl]
            local idx = 1
            for j, o in ipairs(opts) do if o == cur then idx = j; break end end
            idx = idx % #opts + 1
            S._settings[lbl] = opts[idx]
            msg("설정: " .. lbl .. " → " .. opts[idx])
        end)
    end

    -- 볼륨 슬라이더 (1% 단위, 드래그 가능, 아이콘 포함)
    local vol_items = {
        {label="BGM", key="BGM 볼륨", apply=function(v) BGM.set_volume(v/100) end, icon=icon_music},
        {label="SFX", key="SFX 볼륨", apply=function(v) SFX.set_volume(v/100) end, icon=icon_speaker},
    }
    local vol_sy = sy + #settings_items * 50

    S._vol_sliders = S._vol_sliders or {}

    for i, vi in ipairs(vol_items) do
        local iy = vol_sy + (i-1)*50
        local lbl = vi.key
        local vol = S._settings[lbl]

        panel(cx, iy, cw, 40)

        -- 아이콘
        vi.icon(cx+8, iy+12)

        -- 라벨
        love.graphics.setFont(fonts.m); set(PAL.white)
        love.graphics.print(vi.label, lbl_x, iy+10)

        -- 퍼센트 숫자
        love.graphics.setFont(fonts.s); set(PAL.gold)
        love.graphics.printf(vol.."%", lbl_x+28, iy+12, 38, "right")

        -- - 버튼
        ui_btn("-", cx+105, iy+6, 24, 28, PAL.btn_dim, function()
            local v = math.max(0, S._settings[lbl] - 1)
            S._settings[lbl] = v; vi.apply(v)
        end)

        -- 볼륨 바 (드래그 가능)
        local bar_x = cx + 133
        local bar_w = cw - 133 - 30
        local bar_h = 14
        local bar_y = iy + 13
        set({0.1, 0.08, 0.18})
        love.graphics.rectangle("fill", bar_x, bar_y, bar_w, bar_h)
        if vol > 0 then
            set(PAL.gold)
            love.graphics.rectangle("fill", bar_x, bar_y, bar_w*(vol/100), bar_h)
        end
        if vol > 0 and vol < 100 then
            set(PAL.white)
            love.graphics.rectangle("fill", bar_x + bar_w*(vol/100) - 1, bar_y-1, 3, bar_h+2)
        end
        set(PAL.border)
        love.graphics.rectangle("line", bar_x, bar_y, bar_w, bar_h)

        S._vol_sliders[lbl] = {x=bar_x, y=bar_y, w=bar_w, h=bar_h, apply=vi.apply}

        -- + 버튼
        ui_btn("+", cx+cw-26, iy+6, 24, 28, PAL.btn_dim, function()
            local v = math.min(100, S._settings[lbl] + 1)
            S._settings[lbl] = v; vi.apply(v)
        end)
    end

    -- 크레딧
    love.graphics.setFont(fonts.s); set(PAL.dim)
    love.graphics.printf("도깨비의 패 v0.1.0\n© 2026 Dokkaebi Studio", 0, H*0.82, W, "center")

    -- 하단 버튼들
    local btn_y = H * 0.88
    ui_btn("< 돌아가기", W/2-160, btn_y, 120, UI.btn_h, PAL.btn_dim, function()
        S.state = S._return_from_settings or "main_menu"
        S._return_from_settings = nil
    end)

    -- 게임 중이면 "포기하기" 버튼
    local in_game = S._return_from_settings and S._return_from_settings ~= "main_menu"
    if in_game then
        ui_btn("포기하고 나가기", W/2+20, btn_y, 140, UI.btn_h, PAL.red, function()
            -- 현재 런 포기 → 넋 70% 유지 → 메인메뉴
            save_meta()
            S._return_from_settings = nil
            S.state = "main_menu"
            msg("런을 포기했습니다...")
        end)
    end
end

-- ===========================
-- 화면: 영구 강화 트리 (저승 수련)
-- ===========================
local function scr_upgrade_tree()
    title("저승 수련", H*0.06)
    subtitle("넋을 소모하여 영구적으로 강해진다. 세 갈래의 길을 걸어라.", H*0.06+24)

    -- 넋 표시
    love.graphics.setFont(fonts.m); set(PAL.gold)
    PIX.draw(PIX.soul, W/2 - 60, H*0.12 - 2, 18)
    love.graphics.printf("넋: " .. S.soul, 0, H*0.12, W, "center")

    -- 3갈래 강화 트리
    local paths = {
        {name="패의 길",   color={0.72, 0.20, 0.10}, desc="화투패와 족보의 힘을 키운다",
         upgrades={
            {name="기본 칩", desc="기본 칩 +5/Lv (최대 10단계)", icon_fn=PIX.upgrade_chip,
             lv=math.floor(S.perm_chips/5), max=10, cost_fn=function(lv) return 20+lv*20 end,
             apply=function() S.perm_chips=S.perm_chips+5 end},
            {name="기본 배수", desc="기본 배수 +0.15/Lv (최대 5단계)", icon_fn=PIX.upgrade_mult,
             lv=S.perm_mult, max=5, cost_fn=function(lv) return 60+lv*60 end,
             apply=function() S.perm_mult=S.perm_mult+1 end},
            {name="시작 손패", desc="시작 손패 +1/Lv", icon_fn=PIX.card_pack,
             lv=S.perm_hand, max=3, cost_fn=function(lv) return 80+lv*80 end,
             apply=function() S.perm_hand=S.perm_hand+1 end},
            {name="족보 횟수", desc="족보 등록 +1회/Lv", icon_fn=PIX.star,
             lv=S.perm_yokbo, max=3, cost_fn=function(lv) return 100+lv*100 end,
             apply=function() S.perm_yokbo=S.perm_yokbo+1 end},
        }},
        {name="부적의 길", color={0.10, 0.35, 0.65}, desc="부적과 도깨비의 힘을 빌린다",
         upgrades={
            {name="부적 슬롯", desc="부적 칸 +1/Lv", icon_fn=PIX.talisman,
             lv=S.perm_talisman, max=3, cost_fn=function(lv) return 60+lv*80 end,
             apply=function() S.perm_talisman=S.perm_talisman+1 end},
            {name="희귀 부적", desc="상점 희귀 +10%/Lv", icon_fn=PIX.mirror,
             lv=S.perm_tali_rate, max=5, cost_fn=function(lv) return 30+lv*30 end,
             apply=function() S.perm_tali_rate=S.perm_tali_rate+1 end},
            {name="시작 엽전", desc="시작 +30냥/Lv", icon_fn=PIX.coin,
             lv=math.floor(S.perm_yeop/30), max=5, cost_fn=function(lv) return 20+lv*20 end,
             apply=function() S.perm_yeop=S.perm_yeop+30 end},
            {name="상점 할인", desc="상점 가격 -10%/Lv", icon_fn=PIX.coin,
             lv=S.perm_shop_disc, max=3, cost_fn=function(lv) return 50+lv*50 end,
             apply=function() S.perm_shop_disc=S.perm_shop_disc+1 end},
        }},
        {name="생존의 길", color={0.10, 0.55, 0.20}, desc="죽음을 거부하고 살아남는다",
         upgrades={
            {name="시작 체력", desc="시작 목숨 +1/Lv", icon_fn=PIX.heart,
             lv=S.perm_lives, max=3, cost_fn=function(lv) return 60+lv*100 end,
             apply=function() S.perm_lives=S.perm_lives+1 end},
            {name="Go 보험", desc="Go 실패 면제 +15%/Lv", icon_fn=PIX.shield,
             lv=S.perm_go_ins, max=3, cost_fn=function(lv) return 80+lv*80 end,
             apply=function() S.perm_go_ins=S.perm_go_ins+1 end},
            {name="격파 회복", desc="보스 격파 시 체력 +1/Lv", icon_fn=PIX.potion,
             lv=S.perm_heal, max=2, cost_fn=function(lv) return 120+lv*120 end,
             apply=function() S.perm_heal=S.perm_heal+1 end},
        }},
    }

    local pw = math.floor((W - 40) / 3)  -- 패널 폭
    local ph = H * 0.68
    local py = H * 0.18
    local pgap = 10

    for pi, path in ipairs(paths) do
        local px = 15 + (pi-1) * (pw + pgap)

        -- 패널 배경
        panel(px, py, pw, ph)

        -- 헤더
        set(path.color)
        love.graphics.rectangle("fill", px+1, py+1, pw-2, 30)
        love.graphics.setFont(fonts.m); set(PAL.white)
        love.graphics.printf(path.name, px, py+6, pw, "center")
        love.graphics.setFont(fonts.s); set(PAL.dim)
        love.graphics.printf(path.desc, px+8, py+34, pw-16, "center")

        -- 강화 항목
        local uy = py + 55
        local uh = 62
        local ugap_inner = 6

        for ui_idx, u in ipairs(path.upgrades) do
            local iy = uy + (ui_idx-1) * (uh + ugap_inner)
            local lv = u.lv
            local cost = u.cost_fn(lv)
            local maxed = lv >= u.max
            local affordable = S.soul >= cost and not maxed

            panel(px+6, iy, pw-12, uh, true)

            -- 아이콘
            if u.icon_fn then
                PIX.draw(u.icon_fn, px+12, iy + (uh-24)/2, 24)
            end

            -- 이름 + 설명
            love.graphics.setFont(fonts.s); set(PAL.white)
            love.graphics.print(u.name, px+42, iy+4)
            set(PAL.cyan)
            love.graphics.print(u.desc, px+42, iy+18)

            -- 레벨 바
            local bar_x = px + 42
            local bar_w = pw - 130
            for j = 0, u.max - 1 do
                local bx = bar_x + j * (bar_w / u.max)
                local bw = bar_w / u.max - 2
                set(j < lv and PAL.gold or {0.12, 0.10, 0.18})
                love.graphics.rectangle("fill", bx, iy+36, bw, 5)
            end
            set(PAL.dim)
            love.graphics.print("Lv"..lv.."/"..u.max, bar_x+bar_w+4, iy+33)

            -- 구매 버튼
            local pth_idx, up_idx = pi, ui_idx
            if maxed then
                ui_btn("MAX", px+pw-68, iy+6, 52, 22, {0.25,0.20,0.08}, function() end)
            else
                ui_btn(cost.."넋", px+pw-68, iy+6, 52, 22,
                    affordable and PAL.btn_green or PAL.btn_dim, function()
                    local pp = paths[pth_idx]
                    local uu = pp.upgrades[up_idx]
                    local c = uu.cost_fn(uu.lv)
                    if uu.lv >= uu.max then msg("최대!"); return end
                    if S.soul < c then msg("넋 부족!"); return end
                    S.soul = S.soul - c
                    uu.apply()
                    save_meta()
                    SFX.play("purchase")
                    msg(pp.name..": "..uu.name.." Lv"..(uu.lv+1))
                end)
            end
        end
    end

    -- 하단 현재 보너스 요약
    local stat_y = py + ph + 6
    panel(15, stat_y, W-30, 32)
    love.graphics.setFont(fonts.s); set(PAL.dim)
    love.graphics.printf(string.format(
        "칩+%d  배수+%d  손패+%d  족보+%d  체력+%d  엽전+%d  부적+%d  Go보험+%d%%",
        S.perm_chips, S.perm_mult, S.perm_hand, S.perm_yokbo,
        S.perm_lives, S.perm_yeop, S.perm_talisman, S.perm_go_ins*15
    ), 15, stat_y+10, W-30, "center")

    ui_btn("< 돌아가기", W/2-55, stat_y+38, 110, UI.btn_h, PAL.btn_dim, function()
        S.state = S._prev_state or "main_menu"
    end)
end

-- ===========================
-- love.draw
-- ===========================
function love.draw()
    -- 배경 (스프라이트 우선, 없으면 단색)
    local bg_map = {
        main_menu = "bg_main_menu", blessing_select = "bg_main_menu",
        in_round = "bg_ghost_market", go_stop = "bg_ghost_market",
        post_round = "bg_ghost_market",
        shop = "bg_shop", event = "bg_yellow_spring",
        gate = "bg_chaos_gate", game_over = "bg_shadow_city",
        upgrade_select = "bg_ghost_market",
        collection = "bg_archive_hall", settings = "bg_archive_hall",
        upgrade_tree = "bg_archive_hall",
    }
    local bg_id = bg_map[S.state]
    local bg_sprite = bg_id and SpriteLoader.getBackground(bg_id)
    if bg_sprite then
        love.graphics.setColor(1, 1, 1, 1)
        local sx = W / bg_sprite:getWidth()
        local sy = H / bg_sprite:getHeight()
        love.graphics.draw(bg_sprite, 0, 0, 0, sx, sy)
        -- 어두운 오버레이 (UI 가독성)
        love.graphics.setColor(0, 0, 0, 0.45)
        love.graphics.rectangle("fill", 0, 0, W, H)
    else
        set(PAL.bg)
        love.graphics.rectangle("fill", 0, 0, W, H)
    end

    -- 화면 흔들림
    local sx, sy = FX.get_shake_offset()
    love.graphics.push()
    love.graphics.translate(sx, sy)

    DU.vignette(W, H)
    btns = {}; card_rects = {}; combo_rects = {}
    local screens = {
        main_menu = scr_main_menu,
        blessing_select = scr_blessing,
        in_round = scr_battle, go_stop = scr_battle,
        post_round = scr_post_round,
        upgrade_select = scr_upgrade,
        shop = scr_shop,
        event = scr_event,
        gate = scr_gate,
        game_over = scr_game_over,
        collection = scr_collection,
        settings = scr_settings,
        upgrade_tree = scr_upgrade_tree,
    }
    local fn = screens[S.state]; if fn then fn() end

    love.graphics.pop()

    -- 족보 가이드 오버레이
    if show_yokbo_guide then
        YokboGuide.draw(W, H, fonts, PAL, panel, set)
    end

    -- 중앙 연출 메시지
    draw_center_msg()

    -- 이펙트 (흔들림 위에)
    FX.draw(fonts)
end

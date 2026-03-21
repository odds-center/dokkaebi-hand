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
local Seotda         = require("src.combat.seotda_challenge")
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
local YokboGuide     = require("src.ui.yokbo_guide")

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
}

local function msg(s)
    table.insert(S.messages, 1, s)
    if #S.messages > 5 then table.remove(S.messages) end
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
    S.player.lives = 4 + S.perm_lives
    S.player.yeop = 40 + S.perm_yeop
    S.player.wave_chip_bonus = S.perm_chips
    S.player.wave_mult_bonus = S.perm_mult
    S.player.MAX_TALISMAN_SLOTS = 5 + (S.perm_talisman or 0)
    S.spiral = SpiralManager.new()
    S.deck = DeckManager.new()
    S.messages = {}; S.selected = {}; S._eaten_combos = {}; S._registered_cards = {}
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
        {title="도깨비불 시험", desc="도깨비불이 수수께끼를 낸다.\n\"나는 밤에 태어나 낮에 죽는다.\n나는 누구인가?\"",
         choices={
            {text="도깨비불 (배수 +0.5)", result="정답! 다음 보스전 배수 +0.5",
             fn=function() S.player.wave_mult_bonus=S.player.wave_mult_bonus+0.5 end},
            {text="그림자 (체력 -1)", result="오답. 체력 -1",
             fn=function() S.player.lives=math.max(1,S.player.lives-1) end},
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
    }
    -- 셔플 후 첫 번째 (이전과 다른 이벤트)
    for i = #evts, 2, -1 do local j = math.random(1,i); evts[i], evts[j] = evts[j], evts[i] end
    S.event = evts[1]
end

local function gen_upgrades()
    local pool = {
        {name="칩 +20", desc="모든 족보 칩 +20", fn=function() S.player.wave_chip_bonus=S.player.wave_chip_bonus+20 end},
        {name="배수 +1", desc="기본 배수 +1", fn=function() S.player.wave_mult_bonus=S.player.wave_mult_bonus+1 end},
        {name="체력 +1", desc="체력 회복", fn=function() S.player.lives=math.min(S.player.lives+1,10) end},
        {name="엽전 +30", desc="+30냥", fn=function() S.player.yeop=S.player.yeop+30 end},
    }
    -- 셔플 후 앞에서 3개 (중복 방지)
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
    S._eaten_combos = {}; S._registered_cards = {}
    S._boss_chips = 0; S._boss_mult = 0  -- 보스전 시너지 누적 초기화
    S._copy_cards = {}                    -- 카드 복사 대기열 초기화
    msg(string.format("%s 등장! HP: %s", S.boss.name_kr, NumFmt.format(S.battle.boss_max_hp)))
    show_center_msg(S.boss.name_kr, "넌 죽었다. 저승의 도깨비들과 고스톱을 쳐서 이승으로 돌아가야 한다.", 2.5, PAL.red)
    SFX.play("boss_appear")
    start_round()
end

function start_round()
    FX.set_go_danger(0)
    FX.reset_chain()
    S.round = S.round + 1
    if S.round > S.max_rounds then
        S.player.lives = S.player.lives - 1; msg("판 종료! 체력 -1")
        FX.player_hit(1); SFX.play("damage_taken")
        if S.player.lives <= 0 then S.state = "game_over"; SFX.play("game_over"); save_meta(); return end
        -- 라운드 리셋 후 다시 도전
        S.round = 0; start_round(); return
    end
    S.deck:initialize_deck(); S.player:reset_for_new_round()
    S.deck:deal_cards(S.player, 10 + (S.perm_hand or 0), 0)
    S.hand = S.player.hand; S.selected = {}
    sort_hand()  -- 정렬 모드 유지

    -- 칩: 강화 보너스 + 이전 판 이월 + 기본 5
    S._boss_chips = math.min((S._boss_chips or 0) * 0.5, 100)  -- 50% 감쇠, 상한 100
    S.chips = math.min(S.player.wave_chip_bonus, 80) + S._boss_chips + 5
    -- 배수: 1.0 + 강화 보너스 (이월 없음, 매 판 족보로 새로 쌓기)
    S.mult  = 1.0 + math.min(S.player.wave_mult_bonus, 1.5)
    S.go_count = 0; S.plays = 0; S.state = "in_round"

    -- 카드 복사 처리: 이전 판 등록 카드 중 복사 대상이 있으면 손패에 추가
    if S._copy_cards and #S._copy_cards > 0 then
        local copies = {}
        for _, card in ipairs(S._copy_cards) do
            -- 복사된 카드를 새 인스턴스로 손패에 추가
            local copy = {}
            for k, v in pairs(card) do copy[k] = v end
            copy._is_copy = true  -- 복사본 표시
            copies[#copies+1] = copy
        end
        for _, c in ipairs(copies) do S.hand[#S.hand+1] = c end
        msg(string.format("복사된 카드 %d장이 손패에 추가!", #copies))
        S._copy_cards = {}  -- 1회만 적용
        S._copy_mode = nil  -- 복사 모드 소비 완료
        sort_hand()
    end

    -- 보스 기믹 적용 (매 판 시작)
    if S.boss and S.boss.gimmick and S.round % (S.boss.gimmick_interval or 2) == 0 then
        SFX.play("gimmick")
        local g = S.boss.gimmick
        if g == "consume_highest" and #S.hand > 2 then
            -- 가장 높은 카드 1장 제거
            local best_idx = 1
            for i = 2, #S.hand do
                if S.hand[i].base_points > S.hand[best_idx].base_points then best_idx = i end
            end
            local eaten = table.remove(S.hand, best_idx)
            msg("기믹: " .. S.boss.name_kr .. "이(가) " .. eaten.name_kr .. "을 먹었다!")
        elseif g == "flip_all" then
            msg("기믹: 패를 뒤섞는다!")
            -- 손패 셔플
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

    msg(string.format("판 %d/%d — 손패 %d장", S.round, S.max_rounds, #S.hand))
    if S.round == 1 then
        -- 첫 판에는 보스 등장 연출이 있으므로 스킵
    else
        show_center_msg(string.format("판 %d", S.round), "", 1.0, PAL.white)
    end
    SFX.play("round_start")
end

local _defeat_timer = nil

local function after_defeat()
    S.player.yeop = S.player.yeop + S.boss.yeop_reward
    -- 넋 획득 (관문 번호에 비례)
    local realm = S.spiral and S.spiral.current_realm or 1
    local soul_gain = 10 + realm * 2
    S.soul = S.soul + soul_gain
    S.best_realm = math.max(S.best_realm, realm)
    -- 격파 회복 (생존의 길)
    local heal = S.perm_heal or 0
    if heal > 0 then
        S.player.lives = math.min(S.player.lives + heal, S.player.MAX_LIVES)
        msg(string.format("격파 회복! 체력 +%d", heal))
    end
    msg(string.format("%s 격파 +%d냥 +%d넋", S.boss.name_kr, S.boss.yeop_reward, soul_gain))
    show_center_msg(S.boss.name_kr .. " 격파!", string.format("+%d냥  +%d넋", S.boss.yeop_reward, soul_gain), 2.0, PAL.gold)
    SFX.play("reward")
    -- 1초 뒤 강화 화면 전환 (격파 연출 후)
    _defeat_timer = 1.0
end

-- ============================
-- 전투 액션
-- 흐름: 족보 등록(버프) → 고/스톱 → 섯다 공격(데미지)
-- ============================
local function do_register_synergy()
    if #S.selected == 0 then msg("족보로 쓸 카드를 선택하세요"); return end
    if #S.hand - #S.selected < 2 then msg("공격용 2장은 남겨야!"); return end

    local all_combos = HandEvaluator.evaluate(S.selected)
    -- 족보 등록 단계: 섯다 족보 제외 (섯다는 공격 페이즈 전용)
    local combos = {}
    for _, c in ipairs(all_combos) do
        if c.category ~= "seotda" then combos[#combos+1] = c end
    end
    -- 칩: 합산, 배수: 각 콤보의 (mult-1)을 합산 (곱셈 아님!)
    local cc = 0
    local cm_add = 0
    for _, c in ipairs(combos) do
        cc = cc + c.chips
        cm_add = cm_add + (c.mult - 1)
    end
    -- 누적 보너스: 기존 족보 1개당 칩 +3
    local stack_count = S._eaten_combos and #S._eaten_combos or 0
    cc = cc + stack_count * 3

    S.chips = S.chips + cc
    S.mult  = math.min(S.mult + cm_add, 4.0)  -- 배수 상한 4.0
    S.plays = S.plays + 1

    -- 다음 판 이월: 칩 50% 이월, 배수 이월 없음
    S._boss_chips = math.min((S._boss_chips or 0) + cc * 0.5, 150)

    -- 손패에서 제거 (족보에 사용한 카드는 소모) + 등록 카드 기록
    S._registered_cards = S._registered_cards or {}
    S._copy_cards = S._copy_cards or {}
    for _, sel in ipairs(S.selected) do
        for i, h in ipairs(S.hand) do if h == sel then table.remove(S.hand, i); break end end
        S._registered_cards[#S._registered_cards+1] = sel

        -- 카드 복사 아이템 효과: 소모된 카드를 다음 판에 복사
        if S._copy_mode == "all" then
            S._copy_cards[#S._copy_cards+1] = sel
        elseif S._copy_mode == "single" and #S._copy_cards == 0 then
            -- 가장 높은 가치의 카드 1장만 복사 (등록 완료 후 처리)
            S._copy_cards[#S._copy_cards+1] = sel
        end
    end
    -- single 모드에서 최고 가치 1장만 남기기
    if S._copy_mode == "single" and #S._copy_cards > 1 then
        table.sort(S._copy_cards, function(a, b) return (a.base_points or 0) > (b.base_points or 0) end)
        S._copy_cards = {S._copy_cards[1]}
    end

    -- 콤보 기록 + 엽전 보상
    S._eaten_combos = S._eaten_combos or {}
    if #combos > 0 then
        local n = {}
        local yeop_earn = 0
        for _, c in ipairs(combos) do
            n[#n+1] = c.name_kr
            local exists = false
            for _, ec in ipairs(S._eaten_combos) do if ec.name == c.name_kr then exists = true; break end end
            if not exists then S._eaten_combos[#S._eaten_combos+1] = {
                name=c.name_kr, cat=c.category, tier=c.tier,
                chips=c.chips, mult=c.mult,
                heal=c.heal, id=c.id,
            } end
            -- 족보 등급별 엽전 보상 (티어 기준)
            if c.tier <= 1 then yeop_earn = yeop_earn + 5
            elseif c.tier <= 2 then yeop_earn = yeop_earn + 3
            elseif c.tier <= 3 then yeop_earn = yeop_earn + 2
            else yeop_earn = yeop_earn + 1 end
        end
        if yeop_earn > 0 then
            S.player.yeop = S.player.yeop + yeop_earn
        end
        msg("족보 등록 → " .. table.concat(n, " + ") .. string.format(" (+%d냥)", yeop_earn))
        msg(string.format("  공격력 강화: %s칩 × %.1f배", NumFmt.format_score(S.chips), S.mult))
        -- 족보 컷인 연출 (가장 높은 등급 기준)
        local best_tier = 5
        local best_name = n[1]
        for _, c in ipairs(combos) do
            if c.tier < best_tier then best_tier = c.tier; best_name = c.name_kr end
        end
        FX.combo_cutin(best_name, best_tier)
        FX.add_chain()
        -- 효과음
        if best_tier <= 1 then SFX.play("combo_epic")
        elseif best_tier <= 2 then SFX.play("combo_great")
        elseif best_tier <= 3 then SFX.play("combo_good")
        else SFX.play("combo_normal") end
    else
        msg("족보 — 콤보 없음 (base chips only)")
        SFX.play("combo_none")
    end

    S.selected = {}
    local max_plays = 5 + (S.perm_yokbo or 0)
    if S.plays >= max_plays then
        S.state = "attack"
        msg("족보 등록 완료! 이제 남은 패 중 2장으로 섯다 공격")
    elseif #combos > 0 then
        S.state = "go_stop"
    end
end

local function do_go()
    S.go_count = S.go_count + 1
    FX.set_go_danger(S.go_count)
    SFX.play("go_pressed")
    local d = ({3,2,1})[math.min(S.go_count,3)] or 1
    for i=1,d do local c=S.deck:draw_from_pile(); if c then S.hand[#S.hand+1]=c end end
    SFX.play("card_deal")
    local go_ins_chance = (S.perm_go_ins or 0) * 0.15  -- Go 보험: 15%/Lv 면제
    if S.go_count >= 3 and math.random() < 0.10 and math.random() > go_ins_chance then
        S.player.lives = S.player.lives - 1
        FX.instant_death()
        SFX.play("instant_death")
        msg("즉사! 도깨비의 일격!")
        if S.player.lives <= 0 then S.state = "game_over"; SFX.play("game_over"); save_meta(); return end
    end
    msg(({"고 1! +3장 ×1.5","고 2! +2장 ×2","고 3! +1장 ×3 위험!"})[math.min(S.go_count,3)])
    S.state = "in_round"; S.selected = {}
    sort_hand()
end

local function do_stop()
    S.state = "attack"; S.selected = {}
    FX.set_go_danger(0)
    sort_hand()
    SFX.play("stop_pressed")
    msg("스톱! 족보 확정 → 남은 패 중 2장으로 섯다 공격")
end

local function do_attack()
    if #S.selected ~= 2 then msg("2장을 선택하세요"); return end
    -- 광 봉인 기믹 체크
    if S.boss and S.boss.gimmick == "no_bright" then
        for _, c in ipairs(S.selected) do
            if c.card_type == "gwang" then
                msg("염라대왕의 기세에 광이 봉인되었다!")
                return
            end
        end
    end
    local seotda = Seotda.evaluate(S.selected[1], S.selected[2])
    local base = Seotda.base_damage(seotda.rank)
    local gm = ({[1]=1.5,[2]=2,[3]=3})[S.go_count] or 1
    local final_mult = math.min(S.mult, 4.0)  -- 배수 상한 4.0
    local dmg = math.floor((base + S.chips) * final_mult * gm)
    S.battle:deal_damage(dmg)
    -- 이펙트
    FX.boss_hit(dmg)
    if seotda.rank <= 3 then SFX.play("attack_critical") else SFX.play("attack_hit") end
    -- 섯다 랭크별 엽전 보상
    local atk_yeop = 0
    if seotda.rank <= 2 then atk_yeop = 8        -- 광땡급
    elseif seotda.rank <= 5 then atk_yeop = 4     -- 땡급
    elseif seotda.rank <= 10 then atk_yeop = 2    -- 중간
    else atk_yeop = 1 end                         -- 일반
    S.player.yeop = S.player.yeop + atk_yeop
    msg(string.format("[%s] %d + %s칩 ×%.1f ×고%.1f = %s (+%d냥)", seotda.name, base, NumFmt.format_score(S.chips), S.mult, gm, NumFmt.format_score(dmg), atk_yeop))
    for _, sel in ipairs(S.selected) do for i, h in ipairs(S.hand) do if h == sel then table.remove(S.hand, i); break end end end
    S.selected = {}

    -- 사구파토 재경기: 4+9 조합이면 남은 손패로 한번 더 공격!
    if seotda.rematch and #S.hand >= 2 and not S.battle:is_boss_defeated() then
        FX.flash({1, 0.8, 0.2}, 0.3)
        SFX.play("rematch")
        msg("사구파토! 재경기 — 한번 더 공격!")
        S.state = "attack"
        return
    end

    if S.battle:is_boss_defeated() then
        FX.boss_defeat(S.boss.name_kr)
        SFX.play("boss_defeat")
        after_defeat()
    else
        -- 보스 반격
        local hp_ratio = S.battle.boss_current_hp / math.max(S.battle.boss_max_hp, 1)
        if hp_ratio < 0.3 then
            -- 광분: 15% 확률 체력 -1
            if math.random() < 0.15 then
                S.player.lives = S.player.lives - 1
                FX.player_hit(1)
                SFX.play("boss_rage")
                SFX.play("damage_taken")
                msg("보스 광분! 체력 -1!")
                if S.player.lives <= 0 then S.state = "game_over"; SFX.play("game_over"); save_meta(); return end
            else
                msg("보스가 날뛰지만... 피했다!")
            end
        elseif hp_ratio < 0.6 then
            -- 짜증: 엽전 도둑
            local stolen = math.min(S.player.yeop, 10)
            S.player.yeop = S.player.yeop - stolen
            if stolen > 0 then SFX.play("yeop_stolen"); msg("보스 반격! 엽전 -" .. stolen .. "냥") end
        end
        -- 보스 생존 → 바로 다음 판 시작
        S.selected = {}; start_round()
    end
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
    end
end

function love.load()
    -- W, H는 내부 렌더 해상도 (640x360)로 고정
    W, H = love.graphics.getDimensions()
    SFX.init()
    BGM.init()
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
    if S.state == "in_round" or S.state == "attack" then
        for _, cr in ipairs(card_rects) do
            if x >= cr.x and x <= cr.x+cr.w and y >= cr.y and y <= cr.y+cr.h then
                local found = false
                for j, sel in ipairs(S.selected) do if sel == cr.card then table.remove(S.selected, j); found = true; SFX.play("card_deselect"); break end end
                if not found then
                    local mx = S.state == "attack" and 2 or 5
                    if #S.selected < mx then S.selected[#S.selected+1] = cr.card; SFX.play("card_select") end
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

        -- 이미지 영역 (나중에 실제 이미지로 교체)
        local img_y = card_y + 34
        set({cols[i][1]*0.3, cols[i][2]*0.3, cols[i][3]*0.3, 0.6})
        love.graphics.rectangle("fill", bx+8, img_y, cw-16, img_h)
        set({cols[i][1]*0.6, cols[i][2]*0.6, cols[i][3]*0.6})
        love.graphics.rectangle("line", bx+8, img_y, cw-16, img_h)
        -- 플레이스홀더 아이콘 (도트)
        love.graphics.setFont(fonts.l)
        set({cols[i][1]+0.2, cols[i][2]+0.2, cols[i][3]+0.2, 0.5})
        local icons = {"火", "氷", "空", "混"}
        love.graphics.printf(icons[i], bx+8, img_y + img_h/2 - 16, cw-16, "center")

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

-- 먹은 카드 추적
S._eaten = S._eaten or { gwang=0, tti=0, geurim=0, pi=0, combos={} }

local function scr_battle()
    topbar()
    local CX = W/2  -- 화면 중앙 기준

    -- ======= 레이아웃 사전 계산 =======
    local btn_y = H - 44
    local cw_card, ch_card = CardRenderer.CARD_W, CardRenderer.CARD_H
    local card_y = btn_y - 12 - ch_card
    local boss_by = 34
    local boss_bottom = boss_by

    -- ======= 보스 (컴팩트, 화면 상단 중앙) =======
    if S.battle then
        local bw = math.min(W * 0.72, 680)
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

        -- 아이콘 영역
        local icon_size = 105
        local icon_pad = 8
        set({0.06, 0.04, 0.12, 0.8})
        love.graphics.rectangle("fill", bx+icon_pad, by+icon_pad, icon_size+8, bh-icon_pad*2)
        set({0.18, 0.12, 0.28})
        love.graphics.rectangle("line", bx+icon_pad, by+icon_pad, icon_size+8, bh-icon_pad*2)

        -- 보스 도트 아이콘 (크게)
        local ix0 = bx + icon_pad + 4
        local iy0 = by + (bh - icon_size) / 2
        BossIcons.draw(S.boss.id, ix0, iy0, icon_size, S.boss)
        -- Lv 표시
        love.graphics.setFont(fonts.s); set(PAL.dim)
        love.graphics.printf("Lv." .. (S.spiral and S.spiral.current_realm or 1), ix0, iy0+icon_size+2, icon_size, "center")

        -- 이름 + 기믹
        local ix = bx + icon_size + icon_pad*2 + 16
        local iw = bw - icon_size - icon_pad*3 - 20
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

        -- HP 바 (넓게 + 광택)
        local hx, hy, hw, hh = ix, by+66, iw, 24
        set({0.08, 0.03, 0.03})
        love.graphics.rectangle("fill", hx, hy, hw, hh)
        local ratio = S.battle.boss_current_hp / math.max(S.battle.boss_max_hp, 1)
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
        -- 족보
        set(PAL.dim)
        love.graphics.print("족보", ix+65, ry)
        set(PAL.gold)
        love.graphics.print(string.format("%d/5", S.plays), ix+95, ry)
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
                local col = cat_colors[ec.cat] or PAL.gold
                local txt = ec.name
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
    local score_w = 380
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
    local reg_cards = S._registered_cards or {}

    if #reg_cards > 0 then
        -- 미니 카드 배치
        local mw, mh = CardRenderer.MINI_W, CardRenderer.MINI_H
        local mgap = 3
        local total_mini_w = #reg_cards * (mw + mgap) - mgap
        local mini_sx = CX - total_mini_w / 2
        local mini_y = combo_y

        for i, card in ipairs(reg_cards) do
            CardRenderer.draw_mini(card, mini_sx + (i-1) * (mw + mgap), mini_y)
        end
        combo_area_h = mh + 4

        -- 콤보 태그 (미니 카드 아래, 개별 클릭/호버 가능)
        combo_rects = {}
        if S._eaten_combos and #S._eaten_combos > 0 then
            love.graphics.setFont(fonts.s)
            local tier_colors = {
                [1]=PAL.gold, [2]=PAL.cyan, [3]={0.3,0.85,0.4},
                [4]={0.65,0.65,0.70}, [5]={0.55,0.48,0.45},
            }
            local tag_gap = 4
            local tag_h = fonts.s:getHeight() + 6
            local dy = combo_y + mh + 4

            -- 전체 너비 계산 (중앙 정렬)
            local total_w = 0
            for _, ec in ipairs(S._eaten_combos) do
                total_w = total_w + fonts.s:getWidth("[" .. ec.name .. "]") + tag_gap + 8
            end
            total_w = total_w - tag_gap
            local tx = CX - total_w / 2

            for ci, ec in ipairs(S._eaten_combos) do
                local tag_text = "[" .. ec.name .. "]"
                local tw = fonts.s:getWidth(tag_text) + 8
                local is_hover = (hover_combo == ci)
                local col = tier_colors[ec.tier] or PAL.white

                -- 태그 배경
                if is_hover then
                    set({col[1]*0.3, col[2]*0.3, col[3]*0.3, 0.6})
                else
                    set({0.12, 0.10, 0.18, 0.5})
                end
                love.graphics.rectangle("fill", tx, dy, tw, tag_h, 3)

                -- 태그 테두리
                set(col, is_hover and 1 or 0.6)
                love.graphics.rectangle("line", tx, dy, tw, tag_h, 3)

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
                    seasonal="계절", collection="수집", monthpair="월합", fallback="기본"}
                local cat_name = cat_labels[ec.cat] or ec.cat or ""
                local tier_names = {[1]="S", [2]="A", [3]="B", [4]="C", [5]="D"}
                local tier_name = tier_names[ec.tier] or "?"

                local line1 = ec.name .. "  [Tier " .. tier_name .. " |" .. cat_name .. "]"
                local line2 = string.format("칩 +%d  | 배수 ×%.2f", ec.chips or 0, ec.mult or 1)
                local line3 = ec.heal and ("회복 +" .. ec.heal) or nil

                local tip_w = math.max(fonts.s:getWidth(line1), fonts.s:getWidth(line2)) + 20
                local tip_lines = line3 and 3 or 2
                local tip_h = tip_lines * fonts.s:getHeight() + 12
                local tip_x = cr.x + cr.w / 2 - tip_w / 2
                local tip_y = cr.y - tip_h - 4

                if tip_x < 4 then tip_x = 4 end
                if tip_x + tip_w > W - 4 then tip_x = W - tip_w - 4 end
                if tip_y < 0 then tip_y = cr.y + cr.h + 4 end

                -- 툴팁 배경
                set({0.06, 0.04, 0.12, 0.95})
                love.graphics.rectangle("fill", tip_x, tip_y, tip_w, tip_h, 4)
                local col = tier_colors[ec.tier] or PAL.white
                set(col)
                love.graphics.rectangle("line", tip_x, tip_y, tip_w, tip_h, 4)

                -- 툴팁 텍스트
                set(PAL.white)
                love.graphics.print(line1, tip_x + 8, tip_y + 4)
                set(PAL.gold)
                love.graphics.print(line2, tip_x + 8, tip_y + 4 + fonts.s:getHeight())
                if line3 then
                    set({0.3, 0.85, 0.4})
                    love.graphics.print(line3, tip_x + 8, tip_y + 4 + fonts.s:getHeight() * 2)
                end
            end
        end
    else
        love.graphics.setFont(fonts.s)
        set({0.55, 0.55, 0.65})
        love.graphics.printf("카드를 선택하고 족보를 등록하세요.", 0, combo_y + 4, W, "center")
        combo_area_h = fonts.s:getHeight() + 8
    end

    -- ======= 메시지 로그 (중앙) =======
    draw_msgs(combo_y + combo_area_h + 6, true)

    -- ======= 안내 텍스트 (카드 바로 위) =======
    love.graphics.setFont(fonts.s)
    local guide_y = card_y - 16
    if S.state == "in_round" then
        if #S.selected == 0 then
            set({0.6, 0.85, 1.0})
            love.graphics.printf("카드를 클릭해서 선택한 뒤 [족보 등록]을 눌러라", 0, guide_y, W, "center")
        else
            set({0.4, 1, 0.6})
            love.graphics.printf(string.format("%d장 선택 — [족보 등록]을 눌러 콤보 발동! (%d/5)", #S.selected, #S.selected), 0, guide_y, W, "center")
        end
    elseif S.state == "go_stop" then
        set({1, 0.85, 0.4})
        love.graphics.printf("고 = 추가 드로우 + 배수 상승 / 스톱 = 즉시 공격!", 0, guide_y, W, "center")
    elseif S.state == "attack" then
        set({1, 0.6, 0.4})
        love.graphics.printf(string.format("섯다 공격 2장 선택 — 그림패만 족보! 피는 끗만 (%d/2)", #S.selected), 0, guide_y, W, "center")
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
        CardRenderer.draw(card, cx, card_y, sel, i == hover_idx, fonts.s)
        local oy = sel and -10 or (i == hover_idx and -4 or 0)
        card_rects[i] = {x=cx, y=card_y+oy, w=cw_card, h=ch_card, card=card}
    end

    -- ======= 부적 슬롯 (안내 텍스트 위, 가로 태그) =======
    local tal_h = 22
    local tal_gap = 4
    local talisman_y = card_y - tal_h - 30
    love.graphics.setFont(fonts.s)
    set(PAL.dim)
    love.graphics.print("부적:", 15, talisman_y + (tal_h - fonts.s:getHeight()) / 2)
    talisman_rects = {}
    local tal_x = 55
    if S.player and #S.player.talismans > 0 then
        for ti, t in ipairs(S.player.talismans) do
            local name = t.data and t.data.name_kr or "?"
            local tw = math.max(fonts.s:getWidth(name) + 12, 44)
            local ty = talisman_y
            local is_hover = (hover_talisman == ti)
            -- 배경
            set(is_hover and {0.20, 0.18, 0.30} or {0.12, 0.10, 0.18})
            love.graphics.rectangle("fill", tal_x, ty, tw, tal_h, 3)
            -- 테두리
            set(is_hover and PAL.cyan or {0.45, 0.40, 0.55})
            love.graphics.rectangle("line", tal_x, ty, tw, tal_h, 3)
            -- 이름
            set(is_hover and PAL.white or PAL.cyan)
            love.graphics.printf(name, tal_x, ty + (tal_h - fonts.s:getHeight()) / 2, tw, "center")
            talisman_rects[ti] = {x=tal_x, y=ty, w=tw, h=tal_h, talisman=t}
            tal_x = tal_x + tw + tal_gap
        end
    else
        set({0.12, 0.10, 0.18})
        love.graphics.rectangle("fill", tal_x, talisman_y, 44, tal_h, 3)
        set({0.30, 0.30, 0.38})
        love.graphics.rectangle("line", tal_x, talisman_y, 44, tal_h, 3)
        set(PAL.dim)
        love.graphics.printf("없음", tal_x, talisman_y + (tal_h - fonts.s:getHeight()) / 2, 44, "center")
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

            -- 너비/높이 계산
            local tip_w = 230
            local content_w = tip_w - 16
            local _, name_lines = fonts.s:getWrap(name, content_w)
            local _, desc_lines = fonts.s:getWrap(desc, content_w)
            local lines = #name_lines + #desc_lines
            if trigger_str ~= "" then lines = lines + 1 end
            if effect_str ~= "" then lines = lines + 1 end
            local tip_h = lines * fh + 16

            local tip_x = math.max(4, math.min(tr.x, W - tip_w - 4))
            local tip_y = tr.y - tip_h - 4
            if tip_y < 0 then tip_y = tr.y + tr.h + 4 end

            -- 배경
            set({0.06, 0.04, 0.10, 0.95})
            love.graphics.rectangle("fill", tip_x, tip_y, tip_w, tip_h, 4)
            set(PAL.cyan)
            love.graphics.rectangle("line", tip_x, tip_y, tip_w, tip_h, 4)

            -- 내용
            local cy = tip_y + 6
            set(PAL.white)
            love.graphics.printf(name, tip_x + 8, cy, content_w, "left")
            cy = cy + #name_lines * fh + 2
            if trigger_str ~= "" then
                set({0.5, 0.75, 1.0})
                love.graphics.printf("발동: " .. trigger_str, tip_x + 8, cy, content_w, "left")
                cy = cy + fh
            end
            set({0.7, 0.7, 0.75})
            love.graphics.printf(desc, tip_x + 8, cy, content_w, "left")
            cy = cy + #desc_lines * fh + 2
            if effect_str ~= "" then
                set(PAL.gold)
                love.graphics.printf(effect_str, tip_x + 8, cy, content_w, "left")
            end
        end
    end

    -- ======= 고정 버튼바 (최하단 중앙) =======
    -- btn_y는 카드 배치 시 이미 계산됨
    set(PAL.panel); love.graphics.rectangle("fill", 0, btn_y-6, W, 50)
    set(PAL.border); love.graphics.line(0, btn_y-6, W, btn_y-6)

    if S.state == "in_round" then
        ui_btn("족보 등록", CX-55, btn_y, 110, UI.btn_h, PAL.btn_red, do_register_synergy)
    elseif S.state == "go_stop" then
        ui_btn("고", CX-120, btn_y, 100, UI.btn_h, PAL.red, do_go)
        ui_btn("스톱", CX+20, btn_y, 100, UI.btn_h, PAL.btn_blue, do_stop)
        -- 리스크 텍스트 (버튼 우측에 표시)
        love.graphics.setFont(fonts.s); set({1,0.5,0.5})
        local ri = math.min((S.go_count or 0)+1, 3)
        love.graphics.printf(({"고 1: +3장 ×1.5","고 2: +2장 ×2 반격!","고 3: +1장 ×3 즉사위험!"})[ri], CX+130, btn_y+4, 250, "left")
    elseif S.state == "attack" then
        local col = #S.selected == 2 and PAL.btn_red or PAL.btn_dim
        ui_btn("공격", CX-55, btn_y, 110, UI.btn_h, col, do_attack)
        if #S.selected == 2 then
            local p = Seotda.evaluate(S.selected[1], S.selected[2])
            local bd = Seotda.base_damage(p.rank)
            local gm = ({[1]=1.5,[2]=2,[3]=3})[S.go_count] or 1
            local est = math.floor((bd+S.chips)*S.mult*gm)
            -- 예상 데미지 (버튼 우측에 표시)
            love.graphics.setFont(fonts.s); set({0.4,1,0.6})
            love.graphics.printf(string.format("[%s] 예상: %s", p.name, NumFmt.format_score(est)), CX+65, btn_y+4, 280, "left")
        end
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
    if (S.state == "in_round" or S.state == "attack") and #S.selected > 0 then
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

        -- 공격 모드 2장 → 섯다 미리보기 (콤보 미리보기 아래)
        if S.state == "attack" and #S.selected == 2 then
            local p = Seotda.evaluate(S.selected[1], S.selected[2])
            local bd = Seotda.base_damage(p.rank)
            local gm = ({[1]=1.5,[2]=2,[3]=3})[S.go_count] or 1
            local est = math.floor((bd+S.chips)*S.mult*gm)
            local seotda_y = cpy + cph + 6
            love.graphics.setFont(fonts.s)
            set({0.4, 1, 0.6})
            love.graphics.printf(string.format(">> [%s] 예상: %s", p.name, NumFmt.format_score(est)), cpx+5, seotda_y, cpw-10, "left")
        end
    end

    -- ======= TIP 안내 (정렬 버튼 우측) =======
    love.graphics.setFont(fonts.s)
    set({0.48, 0.48, 0.58})
    if S.state == "in_round" then
        love.graphics.print("TIP: 같은 월 카드를 골라보세요!", 90, btn_y+4)
    elseif S.state == "attack" then
        love.graphics.print("TIP: 같은 월 2장 = 땡!", 90, btn_y+4)
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

        -- 이미지 영역 (1:1, 상단)
        local img_size = 80
        local img_x = ux + (cw - img_size) / 2
        local img_y = card_y + 10
        set({0.12, 0.12, 0.18})
        love.graphics.rectangle("fill", img_x, img_y, img_size, img_size, 4)
        set({0.25, 0.25, 0.35})
        love.graphics.rectangle("line", img_x, img_y, img_size, img_size, 4)
        -- 강화 아이콘 (도트)
        PIX.draw(PIX.star, img_x + (img_size-48)/2, img_y + (img_size-48)/2, 48)

        -- 강화 이름
        love.graphics.setFont(fonts.m); set(PAL.white)
        love.graphics.printf(u.name, ux, img_y + img_size + 8, cw, "center")

        -- 설명
        love.graphics.setFont(fonts.s); set(PAL.cyan)
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

    -- 탭 버튼 (4개: 보스, 부적, 족보, 업적)
    local tabs = {"보스", "부적", "족보", "업적"}
    local tab_w, tab_gap = 100, 6
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
        for i, b in ipairs(all_bosses) do
            local c = (i-1) % cols_per_row
            local r = math.floor((i-1) / cols_per_row)
            local ix = px + b_margin + c*(item_w+b_gap)
            local iy = py + 12 + r*(item_h+b_gap) + oy

            panel(ix, iy, item_w, item_h, true)
            -- 보스 도트 아이콘 (좌측)
            BossIcons.draw(b.id, ix+4, iy+4, item_h-8, b)
            -- 등급별 이름 색상
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
        for i, t in ipairs(all_tal) do
            local c = (i-1) % cols
            local r = math.floor((i-1) / cols)
            local ix = px + margin + c*(item_w+gap_t)
            local iy = py + 12 + r*(item_h+gap_t) + oy

            panel(ix, iy, item_w, item_h, true)

            -- 아이콘 (좌측)
            local icon_fn = rarity_icon[t.rarity] or PIX.talisman
            PIX.draw(icon_fn, ix+6, iy+6, 28)

            -- 레어리티 배지
            local rc = rarity_col_map[t.rarity] or PAL.white
            local rk = rarity_kr[t.rarity] or "?"
            love.graphics.setFont(fonts.s)
            set(rc)
            love.graphics.print("["..rk.."]", ix+38, iy+4)

            -- 이름
            love.graphics.setFont(fonts.m)
            set(rc)
            love.graphics.printf(t.name_kr, ix+38, iy+18, item_w-44, "left")

            -- 설명
            love.graphics.setFont(fonts.s); set(PAL.dim)
            love.graphics.printf(t.description_kr or "", ix+6, iy+38, item_w-12, "left")
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
        }
        local tier_colors = {S=PAL.gold, A=PAL.cyan, B=PAL.green, C=PAL.dim, D={0.58,0.48,0.45}}
        local tier_icons = {S=PIX.horn, A=PIX.star, B=PIX.sword, C=PIX.shield, D=PIX.talisman}
        local cols = 3
        local y_margin = 8
        local y_gap = 5
        local item_w = math.floor((pw - y_margin*2 - y_gap*(cols-1)) / cols)
        local item_h = 55
        local oy = S._col_scroll or 0
        for i, y in ipairs(yokbos) do
            local c = (i-1) % cols
            local r = math.floor((i-1) / cols)
            local ix = px + y_margin + c*(item_w+y_gap)
            local iy = py + 12 + r*(item_h+y_gap) + oy

            panel(ix, iy, item_w, item_h, true)

            -- 티어 아이콘
            local icon_fn = tier_icons[y.tier] or PIX.talisman
            PIX.draw(icon_fn, ix+4, iy+4, 22)

            -- 티어 뱃지 + 이름
            local tc = tier_colors[y.tier] or PAL.white
            love.graphics.setFont(fonts.m); set(tc)
            love.graphics.print("[" .. y.tier .. "] " .. y.name, ix+30, iy+5)

            -- 설명
            love.graphics.setFont(fonts.s); set(PAL.dim)
            love.graphics.print(y.desc, ix+30, iy+22)

            -- 수치
            set(PAL.cyan)
            love.graphics.printf(string.format("칩+%d  ×%.1f", y.chips, y.mult), ix+4, iy+38, item_w-8, "left")
        end

    else
        -- ═══ 업적 탭 ═══
        love.graphics.setFont(fonts.s)
        local AM = require("src.core.achievement_manager")
        local all_ach = AM.AchievementManager.new():get_all_achievements()
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

            panel(ix, iy, item_w, item_h, true)
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
            love.graphics.setFont(fonts.s); set(cat_col)
            love.graphics.print("["..cat_kr.."]", ix+28, iy+4)
            -- 업적 이름
            love.graphics.setFont(fonts.m); set(PAL.white)
            local display_name = a.is_hidden and "???" or a.name_kr
            love.graphics.printf(display_name, ix+28, iy+18, item_w-34, "left")
            -- 설명
            love.graphics.setFont(fonts.s); set(PAL.dim)
            local display_desc = a.is_hidden and "숨겨진 업적" or a.description_kr
            love.graphics.printf(display_desc, ix+6, iy+34, item_w-12, "left")
            -- 보상
            if a.soul_reward > 0 then
                PIX.draw(PIX.soul, ix+item_w-40, iy+4, 14)
                set(PAL.gold)
                love.graphics.print(a.soul_reward.."넋", ix+item_w-24, iy+4)
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
            {name="기본 칩", desc="족보 칩 +5/Lv", icon_fn=PIX.upgrade_chip,
             lv=math.floor(S.perm_chips/5), max=10, cost_fn=function(lv) return 15+lv*15 end,
             apply=function() S.perm_chips=S.perm_chips+5 end},
            {name="기본 배수", desc="시작 배수 +0.3/Lv", icon_fn=PIX.upgrade_mult,
             lv=S.perm_mult, max=5, cost_fn=function(lv) return 40+lv*40 end,
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
    -- 배경
    set(PAL.bg)
    love.graphics.rectangle("fill", 0, 0, W, H)

    -- 화면 흔들림
    local sx, sy = FX.get_shake_offset()
    love.graphics.push()
    love.graphics.translate(sx, sy)

    DU.vignette(W, H)
    btns = {}; card_rects = {}; combo_rects = {}
    local screens = {
        main_menu = scr_main_menu,
        blessing_select = scr_blessing,
        in_round = scr_battle, go_stop = scr_battle, attack = scr_battle,
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

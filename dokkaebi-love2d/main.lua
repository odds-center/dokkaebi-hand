--- 도깨비의 패 — Love2D
--- 통일 UI 시스템: 모든 화면이 동일한 디자인 언어 사용

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

-- ===========================
-- 디자인 토큰 (전역 통일)
-- ===========================
local W, H = 1280, 720
local fonts = {}

-- 색상 팔레트
local PAL = {
    bg        = {0.035, 0.035, 0.09},
    panel     = {0.065, 0.055, 0.13, 0.94},
    panel_alt = {0.08,  0.06,  0.15, 0.90},
    border    = {0.22,  0.16,  0.38},
    gold      = {1, 0.82, 0},
    white     = {1, 1, 1},
    dim       = {0.42, 0.42, 0.50},
    red       = {0.82, 0.15, 0.12},
    green     = {0.15, 0.55, 0.20},
    blue      = {0.12, 0.35, 0.75},
    cyan      = {0.25, 0.90, 0.85},
    purple    = {0.50, 0.20, 0.65},
    hp_bg     = {0.14, 0.05, 0.05},
    hp_high   = {0.78, 0.14, 0.10},
    hp_mid    = {0.88, 0.48, 0.10},
    hp_low    = {1.00, 0.20, 0.20},
    btn_red   = {0.65, 0.12, 0.05},
    btn_blue  = {0.08, 0.08, 0.55},
    btn_green = {0.10, 0.42, 0.12},
    btn_dim   = {0.18, 0.18, 0.24},
}

-- 공통 UI 크기
local UI = {
    bar_h    = 30,   -- 상단 바 높이
    btn_h    = 32,   -- 버튼 높이
    btn_w    = 140,  -- 버튼 폭
    pad      = 12,   -- 패딩
    radius   = 5,    -- 모서리 둥글기
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
    total_runs = 0,     -- 총 런 횟수
    best_realm = 0,     -- 최고 관문
}

local function msg(s)
    table.insert(S.messages, 1, s)
    if #S.messages > 5 then table.remove(S.messages) end
end

local bosses = BossData.get_all_bosses()

-- ===========================
-- 공통 UI 함수
-- ===========================

local btns = {}
local card_rects = {}
local hover_idx = nil

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
    love.graphics.print(string.format("윤회 %d · 관문 %d", sp, rm), UI.pad, 8)

    -- 체력
    local hearts = ""
    for i = 1, S.player.MAX_LIVES do hearts = hearts .. (i <= S.player.lives and "♥" or "♡") end
    set(S.player.lives <= 2 and PAL.red or {0.85, 0.30, 0.30})
    love.graphics.printf(hearts, 0, 8, W * 0.5, "center")

    -- 엽전 + 넋
    set(PAL.gold)
    love.graphics.printf(S.player.yeop .. "냥  |  넋:" .. S.soul, 0, 8, W - UI.pad, "right")

    if title_extra then
        set(PAL.white)
        love.graphics.printf(title_extra, W * 0.35, 8, W * 0.3, "center")
    end
end

-- 메시지 로그
local function draw_msgs(y)
    love.graphics.setFont(fonts.s)
    for i, m in ipairs(S.messages) do
        set(PAL.gold, math.max(0, 1 - (i-1) * 0.20))
        love.graphics.print("  " .. m, UI.pad, y + (i-1) * 14)
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
    -- 영구 강화 반영
    S.player.lives = 5 + S.perm_lives
    S.player.yeop = 50 + S.perm_yeop
    S.player.wave_chip_bonus = S.perm_chips
    S.player.wave_mult_bonus = S.perm_mult
    S.spiral = SpiralManager.new()
    S.deck = DeckManager.new()
    S.messages = {}; S.selected = {}; S._eaten_combos = {}
    msg("넌 죽었다. 저승의 도깨비들과 고스톱을 치자.")
end

local function gen_shop()
    S.shop_items = {}
    local pool = {
        {name="피의 맹세", cost=35, type="talisman"},
        {name="삼도천의 나룻배", cost=40, type="talisman"},
        {name="도깨비 방망이", cost=45, type="talisman"},
        {name="달빛 여우", cost=90, type="talisman"},
        {name="황천의 거울", cost=85, type="talisman"},
    }
    for i = 1, 3 do S.shop_items[#S.shop_items+1] = {name=pool[math.random(#pool)].name, cost=pool[math.random(#pool)].cost, type="talisman", sold=false} end
    S.shop_items[#S.shop_items+1] = {name="체력 회복", cost=75, type="health", sold=false}
    S.shop_items[#S.shop_items+1] = {name="패 팩(소)", cost=40, type="card_pack", sold=false}
end

local function gen_event()
    local evts = {
        {title="저승 방랑자", desc="길을 잃은 다른 망자.\n\"도와줘... 길을 잃었어...\"",
         choices={{text="도와준다 (+50냥)", result="감사! +50냥", fn=function() S.player.yeop=S.player.yeop+50 end},
                  {text="무시한다", result="...", fn=function() end},
                  {text="소지품 뒤진다 (+30냥)", result="+30냥", fn=function() S.player.yeop=S.player.yeop+30 end}}},
        {title="도깨비불 시험", desc="\"나는 밤에 태어나 낮에 죽는다.\n나는 누구인가?\"",
         choices={{text="도깨비불 (+80냥)", result="정답! +80냥", fn=function() S.player.yeop=S.player.yeop+80 end},
                  {text="그림자 (-30냥)", result="오답. -30냥", fn=function() S.player.yeop=math.max(0,S.player.yeop-30) end}}},
        {title="운명의 갈림길", desc="두 개의 문.\n붉은 문과 푸른 문.",
         choices={{text="붉은 문 (+100냥)", result="+100냥!", fn=function() S.player.yeop=S.player.yeop+100 end},
                  {text="푸른 문 (+2 체력)", result="+2 체력!", fn=function() S.player.lives=math.min(S.player.lives+2,10) end}}},
    }
    S.event = evts[math.random(#evts)]
end

local function gen_upgrades()
    local pool = {
        {name="칩 +20", desc="모든 족보 칩 +20", fn=function() S.player.wave_chip_bonus=S.player.wave_chip_bonus+20 end},
        {name="배수 +1", desc="기본 배수 +1", fn=function() S.player.wave_mult_bonus=S.player.wave_mult_bonus+1 end},
        {name="체력 +1", desc="체력 회복", fn=function() S.player.lives=math.min(S.player.lives+1,10) end},
        {name="엽전 +30", desc="+30냥", fn=function() S.player.yeop=S.player.yeop+30 end},
    }
    S.upgrades = {}
    for i = 1, 3 do S.upgrades[i] = pool[math.random(#pool)] end
end

local function start_realm()
    if not S.spiral then return end
    local realm = S.spiral.current_realm
    if realm > 10 then
        -- 나선 완료 보너스
        local sp = S.spiral and S.spiral.current_spiral or 1
        local bonus = sp == 1 and 100 or (50 + sp * 20)
        S.soul = S.soul + bonus
        msg(string.format("윤회 %d 완료! +%d넋", sp, bonus))
        S.state = "gate"; save_meta(); return
    end
    S.boss = bosses[realm] or bosses[1]
    S.battle = BossBattle.new(S.boss, S.spiral.current_spiral)
    S.max_rounds = S.boss.rounds; S.round = 0
    msg(string.format("%s 등장! HP: %s", S.boss.name_kr, NumFmt.format(S.battle.boss_max_hp)))
    start_round()
end

function start_round()
    S.round = S.round + 1
    if S.round > S.max_rounds then
        S.player.lives = S.player.lives - 1; msg("판 종료! 체력 -1")
        if S.player.lives <= 0 then S.state = "game_over"; save_meta(); return end
        S.state = "post_round"; return
    end
    S.deck:initialize_deck(); S.player:reset_for_new_round()
    S.deck:deal_cards(S.player, 10, 0)
    S.hand = S.player.hand; S.selected = {}
    S.chips = S.player.wave_chip_bonus; S.mult = 1.0 + S.player.wave_mult_bonus
    S.go_count = 0; S.plays = 0; S.state = "in_round"
    S._eaten_combos = {}

    -- 보스 기믹 적용 (매 판 시작)
    if S.boss and S.boss.gimmick and S.round % (S.boss.gimmick_interval or 2) == 0 then
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
end

local function after_defeat()
    S.player.yeop = S.player.yeop + S.boss.yeop_reward
    -- 넋 획득 (관문 번호에 비례)
    local realm = S.spiral and S.spiral.current_realm or 1
    local soul_gain = 10 + realm * 2
    S.soul = S.soul + soul_gain
    S.best_realm = math.max(S.best_realm, realm)
    msg(string.format("%s 격파 +%d냥 +%d넋", S.boss.name_kr, S.boss.yeop_reward, soul_gain))
    gen_upgrades(); S.state = "upgrade_select"
end

-- ============================
-- 전투 액션
-- 흐름: 족보 등록(버프) → 고/스톱 → 섯다 공격(데미지)
-- ============================
local function do_register_synergy()
    if #S.selected == 0 then msg("족보로 쓸 카드를 선택하세요"); return end
    if #S.hand - #S.selected < 2 then msg("공격용 2장은 남겨야!"); return end

    local combos = HandEvaluator.evaluate(S.selected)
    local cc, cm = HandEvaluator.get_total_score(combos)
    S.chips = S.chips + cc; S.mult = S.mult * cm; S.plays = S.plays + 1

    -- 손패에서 제거 (족보에 사용한 카드는 소모)
    for _, sel in ipairs(S.selected) do
        for i, h in ipairs(S.hand) do if h == sel then table.remove(S.hand, i); break end end
    end

    -- 콤보 기록
    S._eaten_combos = S._eaten_combos or {}
    if #combos > 0 then
        local n = {}
        for _, c in ipairs(combos) do
            n[#n+1] = c.name_kr
            local exists = false
            for _, ec in ipairs(S._eaten_combos) do if ec == c.name_kr then exists = true; break end end
            if not exists then S._eaten_combos[#S._eaten_combos+1] = c.name_kr end
        end
        msg("족보 등록 → " .. table.concat(n, " + "))
        msg(string.format("  공격력 강화: %s칩 × %.1f배", NumFmt.format_score(S.chips), S.mult))
    else
        msg("족보 — 콤보 없음 (base chips only)")
    end

    S.selected = {}
    if S.plays >= 5 then
        S.state = "attack"
        msg("족보 등록 완료! 이제 남은 패 중 2장으로 섯다 공격")
    elseif #combos > 0 then
        S.state = "go_stop"
    end
end

local function do_go()
    S.go_count = S.go_count + 1
    local d = ({3,2,1})[math.min(S.go_count,3)] or 1
    for i=1,d do local c=S.deck:draw_from_pile(); if c then S.hand[#S.hand+1]=c end end
    if S.go_count >= 3 and math.random() < 0.10 then
        S.player.lives = S.player.lives - 1
        FX.instant_death()
        msg("즉사! 도깨비의 일격!")
        if S.player.lives <= 0 then S.state = "game_over"; save_meta(); return end
    end
    msg(({"고 1! +3장 ×1.5","고 2! +2장 ×2","고 3! +1장 ×3 위험!"})[math.min(S.go_count,3)])
    S.state = "in_round"; S.selected = {}
end

local function do_stop()
    S.state = "attack"; S.selected = {}
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
    local dmg = math.floor((base + S.chips) * S.mult * gm)
    S.battle:deal_damage(dmg)
    -- 이펙트
    FX.boss_hit(dmg)
    msg(string.format("[%s] %d + %s칩 ×%.1f ×고%.1f = %s", seotda.name, base, NumFmt.format_score(S.chips), S.mult, gm, NumFmt.format_score(dmg)))
    for _, sel in ipairs(S.selected) do for i, h in ipairs(S.hand) do if h == sel then table.remove(S.hand, i); break end end end
    S.selected = {}
    if S.battle:is_boss_defeated() then
        FX.boss_defeat(S.boss.name_kr)
        after_defeat()
    else
        -- 보스 반격
        local hp_ratio = S.battle.boss_current_hp / math.max(S.battle.boss_max_hp, 1)
        if hp_ratio < 0.3 then
            -- 광분: 15% 확률 체력 -1
            if math.random() < 0.15 then
                S.player.lives = S.player.lives - 1
                FX.shake(8, 0.4)
                FX.flash({0.8, 0.1, 0.05}, 0.2)
                msg("보스 광분! 체력 -1!")
                if S.player.lives <= 0 then S.state = "game_over"; save_meta(); return end
            else
                msg("보스가 날뛰지만... 피했다!")
            end
        elseif hp_ratio < 0.6 then
            -- 짜증: 엽전 도둑
            local stolen = math.min(S.player.yeop, 10)
            S.player.yeop = S.player.yeop - stolen
            if stolen > 0 then msg("보스 반격! 엽전 -" .. stolen .. "냥") end
        end
        S.state = "post_round"
    end
end

-- ===========================
-- Love2D 콜백
-- ===========================

-- 세이브/로드 (영구 데이터만)
local json = require("lib.json")

local function save_meta()
    local data = {
        soul = S.soul,
        perm_chips = S.perm_chips, perm_mult = S.perm_mult,
        perm_lives = S.perm_lives, perm_yeop = S.perm_yeop,
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
        S.total_runs = data.total_runs or 0
        S.best_realm = data.best_realm or 0
    end
end

function love.load()
    W, H = love.graphics.getDimensions()
    load_meta()  -- 영구 데이터 복원
    local fp = "assets/fonts/Pretendard-Regular.ttf"
    local fb = "assets/fonts/Pretendard-Bold.ttf"
    fonts.s  = love.graphics.newFont(fp, 11)
    fonts.m  = love.graphics.newFont(fp, 14)
    fonts.l  = love.graphics.newFont(fb, 20)
    fonts.xl = love.graphics.newFont(fb, 32)
end

function love.quit()
    save_meta()
end

function love.update(dt)
    W, H = love.graphics.getDimensions()
    FX.update(dt)
    local mx, my = love.mouse.getPosition()
    for _, b in ipairs(btns) do b:update_hover(mx, my) end
    hover_idx = nil
    for i, cr in ipairs(card_rects) do
        if mx >= cr.x and mx <= cr.x+cr.w and my >= cr.y and my <= cr.y+cr.h then hover_idx = i; break end
    end
end

function love.mousepressed(x, y, b)
    if b ~= 1 then return end
    for _, btn in ipairs(btns) do if btn:click(x, y) then return end end
    if S.state == "in_round" or S.state == "attack" then
        for _, cr in ipairs(card_rects) do
            if x >= cr.x and x <= cr.x+cr.w and y >= cr.y and y <= cr.y+cr.h then
                local found = false
                for j, sel in ipairs(S.selected) do if sel == cr.card then table.remove(S.selected, j); found = true; break end end
                if not found then
                    local mx = S.state == "attack" and 2 or 5
                    if #S.selected < mx then S.selected[#S.selected+1] = cr.card end
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
    set({0.35, 0.35, 0.45})
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
    ui_btn("도감",      cx, sy + (bh+gap)*2, bw, bh, PAL.btn_dim,  function() S.state = "collection" end)
    ui_btn("설정",      cx, sy + (bh+gap)*3, bw, bh, PAL.btn_dim,  function() S.state = "settings" end)

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
    title("축복을 선택하라", 42)
    subtitle("양날의 검 — 강력한 보너스와 저주가 함께 따른다.", 68)

    local blessings = SpiralBlessing.get_all()
    local cols = {{0.65,0.18,0.08}, {0.08,0.35,0.65}, {0.35,0.10,0.55}, {0.50,0.45,0.12}}
    local cw, ch, gap = 130, 180, 12
    local sx = (W - (#blessings * (cw+gap) - gap)) / 2

    for i, b in ipairs(blessings) do
        local bx = sx + (i-1)*(cw+gap)
        local by = 100

        panel(bx, by, cw, ch, true)

        -- 컬러 헤더
        set(cols[i])
        love.graphics.rectangle("fill", bx+1, by+1, cw-2, 28, UI.radius)
        love.graphics.setFont(fonts.m)
        set(PAL.white)
        love.graphics.printf(b.name_kr, bx, by+6, cw, "center")

        -- 보너스
        love.graphics.setFont(fonts.s)
        set({0.25, 0.90, 0.45})
        love.graphics.printf("◆ "..b.bonus_desc, bx+6, by+38, cw-12, "left")

        -- 페널티
        set({0.95, 0.35, 0.35})
        love.graphics.printf("▼ "..b.penalty_desc, bx+6, by+80, cw-12, "left")

        -- 선택 버튼
        local idx = i
        ui_btn("선택", bx + (cw-80)/2, by+ch-38, 80, 26, cols[i], function()
            S.spiral:select_blessing(blessings[idx])
            msg("Blessing: " .. blessings[idx].name_kr)
            local bl = blessings[idx]
            if bl.chip_bonus > 0 then S.player.wave_chip_bonus = S.player.wave_chip_bonus + math.floor(bl.chip_bonus * 20) end
            if bl.mult_bonus > 0 then S.player.wave_mult_bonus = S.player.wave_mult_bonus + bl.mult_bonus end
            start_realm()
        end)
    end

    ui_btn("축복 없이 시작", W/2-60, 300, 120, 28, PAL.btn_dim, function() msg("축복 없이!"); start_realm() end)
end

-- ===========================
-- 화면: 전투 (중앙 정렬)
-- ===========================

-- 먹은 카드 추적
S._eaten = S._eaten or { gwang=0, tti=0, yeolkkeut=0, pi=0, combos={} }

local function scr_battle()
    topbar()
    local CX = W/2  -- 화면 중앙 기준

    -- ======= 보스 (크게, 화면 상단 중앙) =======
    if S.battle then
        local bw, bh = 480, 145
        local bx = CX - bw/2
        local by = 34

        panel(bx, by, bw, bh)

        -- 보스 아이콘 (픽셀아트 도깨비 — 투명 배경)
        local is = 105
        local ix0, iy0 = bx+10, by+10
        local cx0, cy0 = ix0 + is/2, iy0 + is/2 + 8
        local px = 4  -- 픽셀 크기 단위

        -- 도깨비 몸통 (사각 블록으로 도트)
        set({0.55, 0.10, 0.08})
        for dy = -6, 6 do
            local hw = (dy >= -2 and dy <= 4) and 8 or (dy >= -5 and dy <= 5) and 6 or 4
            for dx = -hw, hw do
                love.graphics.rectangle("fill", cx0 + dx*px - px/2, cy0 + dy*px - px/2, px, px)
            end
        end

        -- 머리 (사각 블록)
        set({0.65, 0.15, 0.10})
        for dy = -12, -7 do
            local hw = (dy >= -11 and dy <= -8) and 5 or 3
            for dx = -hw, hw do
                love.graphics.rectangle("fill", cx0 + dx*px - px/2, cy0 + dy*px - px/2, px, px)
            end
        end

        -- 뿔 (왼쪽, 픽셀 블록)
        love.graphics.setColor(0.8, 0.7, 0.2)
        love.graphics.rectangle("fill", cx0 - 4*px, cy0 - 13*px, px, px*3)
        love.graphics.rectangle("fill", cx0 - 5*px, cy0 - 16*px, px, px*3)
        -- 뿔 (오른쪽)
        love.graphics.rectangle("fill", cx0 + 3*px, cy0 - 13*px, px, px*3)
        love.graphics.rectangle("fill", cx0 + 4*px, cy0 - 16*px, px, px*3)

        -- 눈 (빛나는 빨간, 도트)
        set({1, 0.2, 0.1})
        love.graphics.rectangle("fill", cx0 - 3*px, cy0 - 10*px, px*2, px*2)
        love.graphics.rectangle("fill", cx0 + 1*px, cy0 - 10*px, px*2, px*2)
        -- 눈 하이라이트
        set({1, 0.8, 0.3})
        love.graphics.rectangle("fill", cx0 - 3*px, cy0 - 10*px, px, px)
        love.graphics.rectangle("fill", cx0 + 1*px, cy0 - 10*px, px, px)

        -- 입 (이빨, 도트)
        set({0.3, 0.05, 0.05})
        love.graphics.rectangle("fill", cx0 - 3*px, cy0 - 7*px, px*6, px*2)
        set({1, 1, 1})
        -- 송곳니
        love.graphics.rectangle("fill", cx0 - 2*px, cy0 - 7*px, px, px*3)
        love.graphics.rectangle("fill", cx0 + 1*px, cy0 - 7*px, px, px*3)

        -- 방망이 (오른손, 도트)
        set({0.5, 0.35, 0.15})
        love.graphics.rectangle("fill", cx0 + 7*px, cy0 - 3*px, px*2, px*8)
        set({0.6, 0.45, 0.2})
        love.graphics.rectangle("fill", cx0 + 6*px, cy0 - 5*px, px*4, px*3)

        -- Lv 표시
        love.graphics.setFont(fonts.s); set(PAL.dim)
        love.graphics.printf("Lv." .. (S.spiral and S.spiral.current_realm or 1), ix0, iy0+is-12, is, "center")

        -- 이름 + 기믹
        local ix, iw = bx + is + 22, bw - is - 36
        love.graphics.setFont(fonts.l); set(PAL.gold)
        love.graphics.print(S.boss.name_kr, ix, by+10)
        love.graphics.setFont(fonts.s); set(PAL.dim)
        love.graphics.print(S.boss.gimmick or "", ix, by+34)

        -- HP 바 (넓게)
        local hx, hy, hw, hh = ix, by+54, iw, 16
        set(PAL.hp_bg); love.graphics.rectangle("fill", hx, hy, hw, hh, 3)
        local ratio = S.battle.boss_current_hp / math.max(S.battle.boss_max_hp, 1)
        set(ratio > 0.5 and PAL.hp_high or (ratio > 0.2 and PAL.hp_mid or PAL.hp_low))
        love.graphics.rectangle("fill", hx+1, hy+1, (hw-2)*math.max(ratio, 0), hh-2, 2)
        love.graphics.setFont(fonts.m); set(PAL.white)
        love.graphics.printf(string.format("HP  %s / %s",
            NumFmt.format(S.battle.boss_current_hp), NumFmt.format(S.battle.boss_max_hp)), hx, hy, hw, "center")

        -- 라운드 + 
        love.graphics.setFont(fonts.s); set(PAL.dim)
        love.graphics.printf(string.format("판 %d/%d  ·  족보 %d/5  ·  Go x%d",
            S.round, S.max_rounds, S.plays, S.go_count), ix, by+76, iw, "left")

        -- 등록된 콤보
        if S._eaten_combos and #S._eaten_combos > 0 then
            local cs = ""
            for _, cn in ipairs(S._eaten_combos) do cs = cs .. "[" .. cn .. "] " end
            set(PAL.gold); love.graphics.printf(cs, ix, by+92, iw, "left")
        end
    end

    -- ======= 족보 점수 (보스 아래 중앙) =======
    local score_y = 185
    local score_w = 320
    panel(CX - score_w/2, score_y, score_w, 38)
    love.graphics.setFont(fonts.m)
    set(PAL.white)
    love.graphics.printf(string.format("칩 %s", NumFmt.format_score(S.chips)), CX-score_w/2, score_y+3, score_w*0.35, "center")
    set(PAL.cyan)
    love.graphics.printf(string.format("× %.1f", S.mult), CX-score_w*0.15, score_y+3, score_w*0.3, "center")
    set(PAL.gold)
    love.graphics.setFont(fonts.l)
    love.graphics.printf(string.format("= %s", NumFmt.format_score(math.floor(S.chips*S.mult))), CX+score_w*0.1, score_y+1, score_w*0.38, "center")

    -- ======= 획득 족보 표시 (점수 아래) =======
    local combo_y = 182
    if S._eaten_combos and #S._eaten_combos > 0 then
        love.graphics.setFont(fonts.s)
        local combo_str = ""
        for _, cn in ipairs(S._eaten_combos) do combo_str = combo_str .. "[" .. cn .. "] " end
        set(PAL.gold)
        love.graphics.printf(combo_str, 0, combo_y, W, "center")
    end

    -- ======= 메시지 로그 (좌측) =======
    draw_msgs(200)

    -- ======= 손패 (중앙 하단) =======
    local cw, ch = CardRenderer.CARD_W, CardRenderer.CARD_H
    local hand_count = #S.hand
    local total_card_w = hand_count * (cw + UI.card_gap) - UI.card_gap
    local card_sx = CX - total_card_w / 2
    local card_y = H - ch - 58

    -- 선택 카운트
    love.graphics.setFont(fonts.s); set(PAL.gold)
    local mode_text = S.state == "attack" and "공격 카드" or "족보 카드"
    local max_sel = S.state == "attack" and 2 or 5
    love.graphics.printf(string.format("%s: %d/%d장", mode_text, #S.selected, max_sel), 0, card_y-16, W, "center")

    card_rects = {}
    for i, card in ipairs(S.hand) do
        local cx = card_sx + (i-1)*(cw + UI.card_gap)
        local sel = false
        for _, s in ipairs(S.selected) do if s == card then sel = true; break end end
        CardRenderer.draw(card, cx, card_y, sel, i == hover_idx, fonts.s)
        local oy = sel and -20 or (i == hover_idx and -6 or 0)
        card_rects[i] = {x=cx, y=card_y+oy, w=cw, h=ch, card=card}
    end

    -- ======= 부적 슬롯 (카드 위 좌측) =======
    love.graphics.setFont(fonts.s)
    set(PAL.dim)
    local talisman_y = card_y - 34
    love.graphics.print("부적:", 15, talisman_y)
    if S.player and #S.player.talismans > 0 then
        for ti, t in ipairs(S.player.talismans) do
            set(PAL.cyan)
            love.graphics.print("[" .. (t.data and t.data.name_kr or "?") .. "]", 55 + (ti-1)*75, talisman_y)
        end
    else
        set({0.25,0.25,0.3})
        love.graphics.print("(없음)", 55, talisman_y)
    end

    -- ======= 고정 버튼바 (최하단 중앙) =======
    local btn_y = H - 44
    set(PAL.panel); love.graphics.rectangle("fill", 0, btn_y-6, W, 50)
    set(PAL.border); love.graphics.line(0, btn_y-6, W, btn_y-6)

    if S.state == "in_round" then
        ui_btn("족보 등록", CX-55, btn_y, 110, UI.btn_h, PAL.btn_red, do_register_synergy)
    elseif S.state == "go_stop" then
        ui_btn("고", CX-120, btn_y, 100, UI.btn_h, PAL.red, do_go)
        ui_btn("스톱", CX+20, btn_y, 100, UI.btn_h, PAL.btn_blue, do_stop)
        -- 리스크 텍스트
        love.graphics.setFont(fonts.s); set({1,0.4,0.4})
        local ri = math.min((S.go_count or 0)+1, 3)
        love.graphics.printf(({"고 1: +3장 ×1.5","고 2: +2장 ×2 반격!","고 3: +1장 ×3 즉사위험!"})[ri], 0, btn_y-18, W, "center")
    elseif S.state == "attack" then
        local col = #S.selected == 2 and PAL.btn_red or PAL.btn_dim
        ui_btn("공격", CX-55, btn_y, 110, UI.btn_h, col, do_attack)
        if #S.selected == 2 then
            local p = Seotda.evaluate(S.selected[1], S.selected[2])
            local bd = Seotda.base_damage(p.rank)
            local gm = ({[1]=1.5,[2]=2,[3]=3})[S.go_count] or 1
            local est = math.floor((bd+S.chips)*S.mult*gm)
            love.graphics.setFont(fonts.s); set({0.3,1,0.5})
            love.graphics.printf(string.format("[%s] 예상: %s", p.name, NumFmt.format_score(est)), 0, btn_y-18, W, "center")
        end
    end

    -- ======= 1. 큰 안내 텍스트 (화면 중앙 상단) =======
    love.graphics.setFont(fonts.m)
    if S.state == "in_round" then
        if #S.selected == 0 then
            set({0.5, 0.8, 1.0})
            love.graphics.printf("↓ 카드를 클릭해서 선택한 뒤 [선택 cards, then press [족보 등록]", 0, card_y - 36, W, "center")
        else
            set({0.3, 1, 0.5})
            love.graphics.printf(#S.selected .. "cards selected — Press [족보 등록] to activate combo!", 0, card_y - 36, W, "center")
        end
    elseif S.state == "go_stop" then
        set({1, 0.8, 0.3})
        love.graphics.printf("GO = Draw more cards + higher multiplier / 스톱 = Attack now!", 0, card_y - 36, W, "center")
    elseif S.state == "attack" then
        set({1, 0.5, 0.3})
        love.graphics.printf("선택 2 cards for Seotda Attack — Same month = Ttaeng!", 0, card_y - 36, W, "center")
    end

    -- ======= 2. 실시간 콤보 미리보기 (선택 중) =======
    if (S.state == "in_round" or S.state == "attack") and #S.selected > 0 then
        local preview_combos = HandEvaluator.evaluate(S.selected)
        if #preview_combos > 0 then
            local pw = 300
            local px = CX - pw/2
            local py = 200

            set({0.04, 0.06, 0.15, 0.88})
            love.graphics.rectangle("fill", px, py, pw, 14 + #preview_combos * 16, UI.radius)
            set(PAL.border)
            love.graphics.rectangle("line", px, py, pw, 14 + #preview_combos * 16, UI.radius)

            love.graphics.setFont(fonts.s)
            for ci, combo in ipairs(preview_combos) do
                local tier_colors = {
                    [1]={1,0.84,0}, [2]={0.25,0.9,0.85}, [3]={0.15,0.7,0.2},
                    [4]={0.5,0.5,0.5}, [5]={0.35,0.3,0.3}
                }
                set(tier_colors[combo.tier] or PAL.white)
                love.graphics.printf(
                    string.format("[%s] %s  칩%d ×%.1f",
                        ({"S","A","B","C","D"})[combo.tier] or "?",
                        combo.name_kr, combo.chips, combo.mult),
                    px + 8, py + 2 + (ci-1)*16, pw - 16, "left")
            end
        else
            -- 콤보 없음 표시
            love.graphics.setFont(fonts.s)
            set({0.6, 0.3, 0.3})
            love.graphics.printf("(이 조합에는 콤보가 없음)", 0, 210, W, "center")
        end

        -- 공격 모드 2장 → 섯다 미리보기
        if S.state == "attack" and #S.selected == 2 then
            local p = Seotda.evaluate(S.selected[1], S.selected[2])
            local bd = Seotda.base_damage(p.rank)
            local gm = ({[1]=1.5,[2]=2,[3]=3})[S.go_count] or 1
            local est = math.floor((bd+S.chips)*S.mult*gm)
            love.graphics.setFont(fonts.m)
            set({0.3, 1, 0.5})
            love.graphics.printf(string.format("▶ [%s] 예상 데미지: %s", p.name, NumFmt.format_score(est)), 0, 240, W, "center")
        end
    end

    -- ======= 3. 추천 카드 하이라이트 안내 (우하단) =======
    love.graphics.setFont(fonts.s)
    set({0.28, 0.28, 0.38})
    local tip_x, tip_y = W - 210, card_y + ch + 4
    if S.state == "in_round" then
        love.graphics.print("TIP: 같은 월 카드를 골라보세요!", tip_x, tip_y)
    elseif S.state == "attack" then
        love.graphics.print("TIP: 같은 월 2장 = 땡!", tip_x, tip_y)
    end
end

-- ===========================
-- 화면: 라운드 결과
-- ===========================
local function scr_post_round()
    topbar()
    if S.battle and S.battle:is_boss_defeated() then return end -- upgrade_select로 이동
    title("보스 생존! 다음 판...", 100)
    if S.battle then
        subtitle(string.format("HP: %s / %s", NumFmt.format(S.battle.boss_current_hp), NumFmt.format(S.battle.boss_max_hp)), 135)
    end
    ui_btn("다음 판", W/2-55, 180, 110, UI.btn_h, {0.50,0.22,0.06}, function() S.selected={}; start_round() end)
    draw_msgs(230)
end

-- ===========================
-- 화면: 강화 선택
-- ===========================
local function scr_upgrade()
    topbar()
    title("강화 선택", 42)
    subtitle(S.boss.name_kr .. " 격파 하나를 선택하세요.", 68)

    local cw, ch, gap = 150, 100, 14
    local sx = (W - (#S.upgrades * (cw+gap) - gap)) / 2

    for i, u in ipairs(S.upgrades) do
        local ux = sx + (i-1)*(cw+gap)
        panel(ux, 100, cw, ch, true)
        love.graphics.setFont(fonts.m); set(PAL.gold)
        love.graphics.printf(u.name, ux, 110, cw, "center")
        love.graphics.setFont(fonts.s); set(PAL.dim)
        love.graphics.printf(u.desc, ux+4, 132, cw-8, "center")

        local idx = i
        ui_btn("선택", ux+(cw-80)/2, 168, 80, 24, PAL.btn_green, function()
            S.upgrades[idx].fn(); msg("강화: "..S.upgrades[idx].name)
            gen_shop(); S.state = "shop"
        end)
    end
    ui_btn("스킵", W/2-40, 220, 80, 24, PAL.btn_dim, function() gen_shop(); S.state = "shop" end)
end

-- ===========================
-- 화면: 저승 장터
-- ===========================
local function scr_shop()
    topbar()
    title("저승 장터", 42)
    subtitle("\"어서 와, 살아있는 손님은 오랜만이야.\"", 68)

    love.graphics.setFont(fonts.s); set(PAL.gold)
    love.graphics.printf("보유: " .. S.player.yeop .. " 냥", 0, 88, W, "center")

    local cw, ch, gap = 160, 80, 10
    local total = #S.shop_items
    local sx = (W - (math.min(total, 5) * (cw+gap) - gap)) / 2

    for i, item in ipairs(S.shop_items) do
        local ix = sx + ((i-1) % 5) * (cw+gap)
        local iy = 108 + math.floor((i-1)/5) * (ch+gap+10)

        panel(ix, iy, cw, ch, item.sold)
        love.graphics.setFont(fonts.m)
        set(item.sold and PAL.dim or PAL.white)
        love.graphics.printf(item.name, ix, iy+8, cw, "center")
        love.graphics.setFont(fonts.s)
        set(PAL.gold)
        love.graphics.printf(item.sold and "구매완료" or (item.cost.."냥"), ix, iy+30, cw, "center")

        if not item.sold then
            local idx = i
            local affordable = S.player.yeop >= item.cost
            ui_btn("구매", ix+(cw-70)/2, iy+50, 70, 22, affordable and PAL.btn_green or PAL.btn_dim, function()
                local it = S.shop_items[idx]
                if it.sold or S.player.yeop < it.cost then msg("구매 불가!"); return end
                S.player.yeop = S.player.yeop - it.cost; it.sold = true
                if it.type == "health" then S.player.lives = math.min(S.player.lives+1, 10); msg("체력 +1!")
                elseif it.type == "card_pack" then S.player.next_round_hand_bonus = (S.player.next_round_hand_bonus or 0) + 2; msg("패 팩! 손패 +2")
                else msg(it.name .. " 구매!") end
            end)
        end
    end

    ui_btn("다음으로 ▶", W/2-55, 300, 110, UI.btn_h, PAL.btn_green, function()
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
    title(S.event.title, 50)
    love.graphics.setFont(fonts.m); set(PAL.white)
    love.graphics.printf(S.event.desc, W*0.2, 85, W*0.6, "center")

    local cy = 155
    for i, ch in ipairs(S.event.choices) do
        local bw = math.min(320, W*0.5)
        panel(W/2-bw/2, cy, bw, 32)
        ui_btn("▸ "..ch.text, W/2-bw/2+4, cy+2, bw-8, 28, PAL.btn_dim, function()
            ch.fn(); msg(S.event.title.." → "..ch.result)
            S.event = nil; S.spiral:advance_realm(); S.selected={}; start_realm()
        end)
        cy = cy + 40
    end
end

-- ===========================
-- 화면: 이승의 문
-- ===========================
local function scr_gate()
    title("이승의 문", H*0.25)
    love.graphics.setFont(fonts.m); set(PAL.white)
    love.graphics.printf("10관문을 모두 통과했다!\n이승으로 돌아갈 수 있다...", 0, H*0.25+40, W, "center")

    local sp = S.spiral and S.spiral.current_spiral or 1
    ui_btn("이승으로 돌아간다 (엔딩)", W/2-220, H*0.5, 200, UI.btn_h, PAL.gold, function()
        msg("이승의 문 통과..."); S.state = "main_menu"
    end)
    ui_btn("계속 싸운다 (윤회 "..(sp+1)..")", W/2+40, H*0.5, 200, UI.btn_h, PAL.btn_red, function()
        if S.spiral then S.spiral:continue_to_next_spiral() end
        msg("윤회 "..(S.spiral and S.spiral.current_spiral or 2).." 진입!")
        S.selected={}; start_realm()
    end)
end

-- ===========================
-- 화면: 게임 오버
-- ===========================
local function scr_game_over()
    title("게임 오버", 60)
    love.graphics.setFont(fonts.m); set(PAL.dim)
    local sp = S.spiral and S.spiral.current_spiral or 1
    local rm = S.spiral and S.spiral.current_realm or 1
    love.graphics.printf(string.format("윤회 %d, %d관문에서 쓰러짐", sp, rm), 0, 95, W, "center")

    -- 넋 획득 결과
    love.graphics.setFont(fonts.m); set(PAL.gold)
    love.graphics.printf(string.format("보유 넋: %d", S.soul), 0, 130, W, "center")
    love.graphics.setFont(fonts.s); set(PAL.dim)
    love.graphics.printf(string.format("최고 기록: %d관문 | 총 %d런", S.best_realm, S.total_runs), 0, 155, W, "center")

    -- 영구 강화 구매 패널
    local px, pw = W/2-280, 560
    panel(px, 185, pw, 170)
    love.graphics.setFont(fonts.m); set(PAL.gold)
    love.graphics.printf("저승 수련 (넋으로 영구 강화)", px, 192, pw, "center")
    DU.divider(px+20, 215, pw-40, PAL.border)

    local upgrades = {
        {id="chips", name="기본 칩 +5",  cost=20*(1 + math.floor(S.perm_chips/5)), current=S.perm_chips, apply=function() S.perm_chips = S.perm_chips + 5 end},
        {id="mult",  name="기본 배수 +1", cost=50*(1 + S.perm_mult), current=S.perm_mult, apply=function() S.perm_mult = S.perm_mult + 1 end},
        {id="lives", name="시작 체력 +1", cost=150*(1 + S.perm_lives), current=S.perm_lives, max=3, apply=function() S.perm_lives = S.perm_lives + 1 end},
        {id="yeop",  name="시작 엽전 +30",cost=30*(1 + math.floor(S.perm_yeop/30)), current=S.perm_yeop, apply=function() S.perm_yeop = S.perm_yeop + 30 end},
    }

    for i, u in ipairs(upgrades) do
        local ux = px + 15 + (i-1)*135
        local uy = 225

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
    ui_btn("다시 도전", W/2-120, 380, 100, UI.btn_h, PAL.btn_red, function() S.state = "blessing_select"; new_game() end)
    ui_btn("메인 메뉴", W/2+20, 380, 100, UI.btn_h, PAL.btn_dim, function() S.state = "main_menu" end)

    draw_msgs(420)
end

-- ===========================
-- 화면: 도감
-- ===========================
local function scr_collection()
    title("도감", H*0.08)
    subtitle("지금까지 만난 도깨비와 부적, 족보를 확인할 수 있다.", H*0.08+30)

    -- 탭 버튼
    local tabs = {"보스 도깨비", "부적", "족보"}
    local tab_w, tab_gap = 110, 8
    local tab_sx = (W - (#tabs*(tab_w+tab_gap)-tab_gap))/2
    S._col_tab = S._col_tab or 1

    for i, t in ipairs(tabs) do
        local tx = tab_sx + (i-1)*(tab_w+tab_gap)
        local col = S._col_tab == i and PAL.gold or PAL.btn_dim
        local idx = i
        ui_btn(t, tx, H*0.17, tab_w, 26, col, function() S._col_tab = idx end)
    end

    -- 내용 패널
    local px, py, pw, ph = W*0.08, H*0.25, W*0.84, H*0.58
    panel(px, py, pw, ph)

    if S._col_tab == 1 then
        -- 보스 목록
        love.graphics.setFont(fonts.s)
        local all_bosses = BossData.get_all_bosses()
        local cols_per_row = 5
        local item_w, item_h, gap = 145, 60, 8
        for i, b in ipairs(all_bosses) do
            local col = (i-1) % cols_per_row
            local row = math.floor((i-1) / cols_per_row)
            local ix = px + 15 + col*(item_w+gap)
            local iy = py + 15 + row*(item_h+gap)

            panel(ix, iy, item_w, item_h, true)
            love.graphics.setFont(fonts.m); set(PAL.gold)
            love.graphics.printf(b.name_kr, ix, iy+6, item_w, "center")
            love.graphics.setFont(fonts.s); set(PAL.dim)
            love.graphics.printf(string.format("HP:%d  보상:%d냥", b.target_score, b.yeop_reward), ix, iy+28, item_w, "center")
            love.graphics.printf(b.gimmick or "", ix, iy+42, item_w, "center")
        end
    elseif S._col_tab == 2 then
        -- 부적 목록
        love.graphics.setFont(fonts.s)
        local talismans = {
            {name="피의 맹세", rarity="일반", desc="피 카드: 배수 +1"},
            {name="삼도천의 나룻배", rarity="일반", desc="라운드 시작: 칩 +15"},
            {name="도깨비 방망이", rarity="일반", desc="쓸 시: 칩 +40"},
            {name="달빛 여우", rarity="희귀", desc="매칭 실패: 50% 와일드"},
            {name="황천의 거울", rarity="희귀", desc="스톱 시: 칩 +50"},
            {name="저승사자의 명부", rarity="전설", desc="4로 끝나면: 배수 ×4"},
            {name="염라왕의 도장", rarity="전설", desc="5광 달성: 배수 ×3"},
            {name="천상의 비파", rarity="전설", desc="청단 완성: 칩+100 배+2"},
        }
        local item_w, item_h, gap = 185, 55, 8
        local cols = 4
        for i, t in ipairs(talismans) do
            local col = (i-1) % cols
            local row = math.floor((i-1) / cols)
            local ix = px + 15 + col*(item_w+gap)
            local iy = py + 15 + row*(item_h+gap)

            panel(ix, iy, item_w, item_h, true)
            love.graphics.setFont(fonts.m)
            local rarity_col = t.rarity == "전설" and PAL.gold or (t.rarity == "희귀" and PAL.cyan or PAL.white)
            set(rarity_col)
            love.graphics.printf(t.name, ix, iy+4, item_w, "center")
            love.graphics.setFont(fonts.s); set(PAL.dim)
            love.graphics.printf("["..t.rarity.."] "..t.desc, ix+4, iy+24, item_w-8, "center")
        end
    else
        -- 족보
        love.graphics.setFont(fonts.s)
        local yokbos = {
            {tier="S", name="오광", desc="광 5장", chips=500, mult=8},
            {tier="S", name="38광땡", desc="3월광+8월광", chips=400, mult=6},
            {tier="A", name="사광", desc="광 4장(비광 없이)", chips=300, mult=5},
            {tier="A", name="장땡", desc="10월 패 2장", chips=250, mult=4.5},
            {tier="B", name="삼광", desc="광 3장(비광 없이)", chips=200, mult=3},
            {tier="B", name="홍단", desc="1,2,3월 홍단", chips=150, mult=3},
            {tier="B", name="청단", desc="6,9,10월 청단", chips=150, mult=3},
            {tier="B", name="고도리", desc="2,4,8월 열끗", chips=150, mult=3},
            {tier="B", name="알리", desc="1월+2월", chips=130, mult=2.8},
            {tier="C", name="세륙", desc="4월+6월", chips=70, mult=1.8},
            {tier="C", name="월하독작", desc="8월광+9월열끗", chips=90, mult=2},
            {tier="D", name="단일패", desc="카드 1장", chips=10, mult=1},
        }
        local tier_colors = {S=PAL.gold, A=PAL.cyan, B=PAL.green, C=PAL.dim, D={0.4,0.3,0.3}}
        local item_w, item_h, gap = 185, 45, 6
        local cols = 4
        for i, y in ipairs(yokbos) do
            local col = (i-1) % cols
            local row = math.floor((i-1) / cols)
            local ix = px + 15 + col*(item_w+gap)
            local iy = py + 15 + row*(item_h+gap)

            panel(ix, iy, item_w, item_h, true)
            love.graphics.setFont(fonts.m); set(tier_colors[y.tier] or PAL.white)
            love.graphics.printf(string.format("[%s] %s", y.tier, y.name), ix, iy+3, item_w, "center")
            love.graphics.setFont(fonts.s); set(PAL.dim)
            love.graphics.printf(string.format("%s  칩%d ×%.1f", y.desc, y.chips, y.mult), ix+4, iy+24, item_w-8, "center")
        end
    end

    -- 뒤로가기
    ui_btn("← 돌아가기", W/2-55, H*0.88, 110, UI.btn_h, PAL.btn_dim, function() S.state = "main_menu" end)
end

-- ===========================
-- 화면: 설정
-- ===========================
local function scr_settings()
    title("설정", H*0.12)

    local cx, cw = W/2-150, 300
    local sy = H*0.25

    -- 설정 항목들
    local settings_items = {
        {label="언어", current="한국어", options={"한국어","English","日本語","中文"}},
        {label="연출 속도", current="보통", options={"느리게","보통","빠르게"}},
        {label="화면 흔들림", current="켜짐", options={"켜짐","꺼짐"}},
        {label="BGM 볼륨", current="80%", options={"0%","20%","40%","60%","80%","100%"}},
        {label="SFX 볼륨", current="100%", options={"0%","20%","40%","60%","80%","100%"}},
    }

    S._settings = S._settings or {}
    for i, item in ipairs(settings_items) do
        S._settings[item.label] = S._settings[item.label] or item.current
    end

    for i, item in ipairs(settings_items) do
        local iy = sy + (i-1)*50

        panel(cx, iy, cw, 40)

        love.graphics.setFont(fonts.m); set(PAL.white)
        love.graphics.print(item.label, cx+12, iy+10)

        -- 현재 값
        love.graphics.setFont(fonts.m); set(PAL.gold)
        love.graphics.printf(S._settings[item.label], cx, iy+10, cw-80, "right")

        -- 변경 버튼
        local lbl = item.label
        local opts = item.options
        ui_btn("▸", cx+cw-55, iy+5, 40, 28, PAL.btn_dim, function()
            local cur = S._settings[lbl]
            local idx = 1
            for j, o in ipairs(opts) do if o == cur then idx = j; break end end
            idx = idx % #opts + 1
            S._settings[lbl] = opts[idx]
            msg("설정: " .. lbl .. " → " .. opts[idx])
        end)
    end

    -- 영구 강화 (저승 수련)
    local uy = sy + #settings_items * 50 + 20
    panel(cx, uy, cw, 40)
    love.graphics.setFont(fonts.m); set(PAL.purple)
    love.graphics.print("저승 수련 (영구 강화)", cx+12, uy+10)
    ui_btn("열기", cx+cw-75, uy+5, 60, 28, PAL.purple, function() S.state = "upgrade_tree" end)

    -- 크레딧
    love.graphics.setFont(fonts.s); set(PAL.dim)
    love.graphics.printf("도깨비의 패 v0.1.0\n© 2026 Dokkaebi Studio", 0, H*0.82, W, "center")

    -- 뒤로가기
    ui_btn("← 돌아가기", W/2-55, H*0.90, 110, UI.btn_h, PAL.btn_dim, function() S.state = "main_menu" end)
end

-- ===========================
-- 화면: 영구 강화 트리 (저승 수련)
-- ===========================
local function scr_upgrade_tree()
    title("저승 수련", H*0.06)
    subtitle("넋(영혼)을 소모하여 영구적으로 강해진다.", H*0.06+28)

    love.graphics.setFont(fonts.s); set(PAL.gold)
    love.graphics.printf("보유 넋: 0", 0, H*0.14, W, "center")

    -- 3갈래 길
    local paths = {
        {name="패의 길", color={0.7,0.2,0.1}, upgrades={
            {name="기본 칩", desc="모든 족보 칩 +5/Lv", cost="20/40/60", max=10},
            {name="기본 배수", desc="기본 배수 +1/Lv", cost="50/100/200", max=5},
            {name="시작 손패", desc="시작 손패 +1/Lv", cost="100/300", max=3},
        }},
        {name="부적의 길", color={0.1,0.4,0.7}, upgrades={
            {name="부적 슬롯", desc="최대 부적 +1/Lv", cost="200/500", max=3},
            {name="부적 발동률", desc="확률 +5%/Lv", cost="40/80/160", max=5},
            {name="전설 등장률", desc="상점 전설 +5%/Lv", cost="300/600", max=3},
        }},
        {name="생존의 길", color={0.1,0.6,0.2}, upgrades={
            {name="최대 목숨", desc="시작 목숨 +1/Lv", cost="150/300", max=3},
            {name="Go 보험", desc="Go 실패 면제 30%/Lv", cost="300/800", max=2},
            {name="시작 엽전", desc="시작 엽전 +30/Lv", cost="30/60/120", max=5},
        }},
    }

    local pw, ph, pgap = 250, 280, 15
    local psx = (W - (#paths*(pw+pgap)-pgap))/2

    for pi, path in ipairs(paths) do
        local px = psx + (pi-1)*(pw+pgap)
        local py = H*0.20

        panel(px, py, pw, ph)

        -- 헤더
        set(path.color)
        love.graphics.rectangle("fill", px+1, py+1, pw-2, 28, UI.radius)
        love.graphics.setFont(fonts.m); set(PAL.white)
        love.graphics.printf(path.name, px, py+5, pw, "center")

        -- 강화 항목
        for ui, u in ipairs(path.upgrades) do
            local uy = py + 38 + (ui-1)*75
            local uw = pw-20

            panel(px+10, uy, uw, 65, true)
            love.graphics.setFont(fonts.m); set(PAL.white)
            love.graphics.printf(u.name, px+10, uy+5, uw, "center")
            love.graphics.setFont(fonts.s); set(PAL.dim)
            love.graphics.printf(u.desc, px+14, uy+24, uw-8, "center")
            love.graphics.printf("비용: "..u.cost.."넋  (최대 Lv"..u.max..")", px+14, uy+40, uw-8, "center")

            ui_btn("Lv 0", px+pw-80, uy+4, 55, 20, PAL.btn_dim, function()
                msg("넋이 부족합니다!")
            end)
        end
    end

    ui_btn("← 돌아가기", W/2-55, H*0.92, 110, UI.btn_h, PAL.btn_dim, function()
        S.state = S._prev_state or "settings"
    end)
end

-- ===========================
-- love.draw
-- ===========================
function love.draw()
    -- 화면 흔들림 적용
    local sx, sy = FX.get_shake_offset()
    love.graphics.push()
    love.graphics.translate(sx, sy)

    set(PAL.bg); love.graphics.rectangle("fill", -10, -10, W+20, H+20)
    DU.vignette(W, H)
    btns = {}; card_rects = {}
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

    -- 이펙트 (화면 흔들림 위에)
    FX.draw(fonts)
end

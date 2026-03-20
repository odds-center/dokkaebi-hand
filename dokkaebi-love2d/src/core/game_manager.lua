--- 게임 루프 총괄: 라운드 연결, 층 진행, 승패 처리
--- Balatro 스타일 전투: 시너지 페이즈 -> 고/스톱 -> 섯다 공격
local Signal = require("lib.signal")
local PlayerState = require("src.core.player_state")
local SpiralMod = require("src.core.spiral_manager")
local SpiralManager = SpiralMod.SpiralManager
local SpiralBlessing = SpiralMod.SpiralBlessing
local PermanentUpgradeManager = require("src.core.permanent_upgrades")
local ShopManager = require("src.core.shop_manager")
local EventManager = require("src.core.event_manager")
local WaveUpgradeManager = require("src.core.wave_upgrades")
local GreedMod = require("src.core.greed_scale")
local GreedScale = GreedMod.GreedScale
local SoulCalculator = require("src.core.soul_calculator")

-- ============================================================
-- GameState enum
-- ============================================================
local GameState = {
    MAIN_MENU    = "main_menu",
    SPIRAL_START = "spiral_start",   -- 윤회 시작 (축복 선택)
    PRE_ROUND    = "pre_round",      -- 라운드 시작 전 (보스 소개)
    IN_ROUND     = "in_round",       -- 라운드 진행 중
    POST_ROUND   = "post_round",     -- 라운드 종료 (결과 + 강화 선택)
    SHOP         = "shop",           -- 상점
    EVENT        = "event",          -- 이벤트
    GATE         = "gate",           -- 이승의 문 (선택적 엔딩)
    GAME_OVER    = "game_over",      -- 게임 오버 (죽음)
}

-- ============================================================
-- GameManager
-- ============================================================
local GameManager = {}
GameManager.__index = GameManager

function GameManager.new()
    local self = setmetatable({
        -- subsystems
        player        = PlayerState.new(),
        spiral        = SpiralManager.new(),
        upgrades      = PermanentUpgradeManager.new(),
        shop          = ShopManager.new(),
        events        = EventManager.new(),
        wave_upgrades = WaveUpgradeManager.new(),
        greed_scale   = GreedScale.new(),

        -- state
        current_state          = GameState.MAIN_MENU,
        current_round_in_realm = 0,
        total_rounds_in_realm  = 0,
        current_boss           = nil,
        current_battle         = nil,

        -- 런 내 통계
        _run_soul_fragments = 0,

        -- 튜토리얼 플래그
        is_tutorial_mode = false,

        -- signals
        on_state_changed     = Signal.new(), -- (state)
        on_message           = Signal.new(), -- (message_string)
        on_boss_generated    = Signal.new(), -- (boss)
        on_gate_appeared     = Signal.new(), -- ()
        on_wave_upgrade_ready = Signal.new(), -- ()
    }, GameManager)

    -- 이벤트 연결
    self.spiral.on_gate_appeared:connect(function()
        self:_set_state(GameState.GATE)
    end)

    return self
end

-- ============================================================
-- State
-- ============================================================
function GameManager:_set_state(state)
    self.current_state = state
    self.on_state_changed:emit(state)
end

-- ============================================================
-- New Game
-- ============================================================
function GameManager:start_new_game()
    local p = self.player
    local u = self.upgrades

    p.lives = 5 + u:get_extra_lives()
    p.yeop = 50 + u:get_bonus_start_yeop()
    self._run_soul_fragments = 0

    -- 영구 강화 반영
    p.permanent_talisman_slot_bonus = u:get_extra_talisman_slots()

    -- 런 내 버프 초기화
    p.wave_chip_bonus = 0
    p.wave_mult_bonus = 0
    p.wave_talisman_slot_bonus = 0
    p.wave_talisman_effect_bonus = 0
    p.wave_target_reduction = 0
    p.next_round_hand_bonus = 0
    p.wild_card_next_match = false
    p.talismans = {}

    self:_set_state(GameState.SPIRAL_START)
end

-- ============================================================
-- Spiral / Blessing
-- ============================================================
function GameManager:begin_spiral_with_blessing(blessing)
    if blessing then
        self.spiral:select_blessing(blessing)
        self.on_message:emit(
            string.format("축복 선택: %s — %s / %s",
                blessing.name_kr, blessing.bonus_desc, blessing.penalty_desc))

        local p = self.player

        if blessing.talisman_slot_penalty > 0 then
            p.permanent_talisman_slot_bonus = math.max(0,
                p.permanent_talisman_slot_bonus - blessing.talisman_slot_penalty)
        end

        if blessing.talisman_effect_mult > 0 then
            p.wave_talisman_effect_bonus = p.wave_talisman_effect_bonus + (blessing.talisman_effect_mult - 1.0)
        end
    end

    self:start_next_realm()
end

-- ============================================================
-- Realm / Round
-- ============================================================
function GameManager:start_next_realm()
    -- 보스 생성은 전투 모듈에 위임 (간소화: stub)
    self.current_round_in_realm = 0
    self.total_rounds_in_realm = 3  -- 기본 3판

    self.on_message:emit("보스가 판을 깔았다!")
    self:start_next_round()
end

function GameManager:start_next_round()
    self.current_round_in_realm = self.current_round_in_realm + 1

    -- 라운드 수 초과 시 보스 미격파 -> 패배 처리
    if self.current_round_in_realm > self.total_rounds_in_realm then
        self.player.lives = self.player.lives - 1
        self.on_message:emit("판이 다 끝났다! 도깨비에게 밀렸다...")
        if self.player.lives <= 0 then
            self:_set_state(GameState.GAME_OVER)
            self.on_message:emit("저승의 어둠이 너를 집어삼킨다...")
        else
            self.current_round_in_realm = self.current_round_in_realm - 1
            self:_set_state(GameState.POST_ROUND)
        end
        return
    end

    self.greed_scale:reset()
    self:_set_state(GameState.IN_ROUND)
end

-- ============================================================
-- Seotda Attack
-- ============================================================
function GameManager:seotda_attack(card1, card2)
    -- 섯다 공격: 실제 구현은 RoundManager + ScoringEngine에 위임
    -- 여기서는 orchestrator 역할만 수행
    local result = { final_damage = 0 }

    -- 전투 모듈이 있으면 사용, 아니면 간소화
    if self.current_battle and self.current_battle.deal_damage then
        self.current_battle:deal_damage(result.final_damage)
    end

    return result
end

-- ============================================================
-- Go / Stop
-- ============================================================
function GameManager:apply_go_damage(boss_damage)
    if boss_damage <= 0 then return end

    local p = self.player
    local yeop_loss = boss_damage
    p.yeop = math.max(0, p.yeop - yeop_loss)
    self.on_message:emit(string.format("보스 반격! 엽전 -%d냥", yeop_loss))

    -- Go 3 즉사 판정
    if self.greed_scale.go_count >= 3 then
        local death_chance = 0.1  -- 10%
        local insurance_chance = self.upgrades:get_go_insurance_chance()

        if math.random() < death_chance then
            if insurance_chance > 0 and math.random() < insurance_chance then
                self.on_message:emit("Go 보험 발동! 즉사를 면했다!")
            else
                p.lives = p.lives - 1
                self.on_message:emit("즉사! 도깨비의 일격!")
                if p.lives <= 0 then
                    self:_set_state(GameState.GAME_OVER)
                    self.on_message:emit("저승의 어둠이 너를 집어삼킨다...")
                end
            end
        elseif insurance_chance > 0 then
            self.on_message:emit("위험했지만... 무사히 넘겼다!")
        end
    end
end

-- ============================================================
-- Round Ended
-- ============================================================
function GameManager:handle_round_ended(won)
    if won then
        self.greed_scale:reset()

        -- 보스 격파 체크 (전투 모듈 의존)
        local boss_defeated = self.current_battle and self.current_battle.is_boss_defeated

        if boss_defeated then
            local soul_reward = SoulCalculator.for_boss_defeat(
                self.spiral:absolute_realm(),
                0,  -- parts count
                false)  -- set bonus
            self._run_soul_fragments = self._run_soul_fragments + soul_reward
            self.upgrades:add_soul_fragments(soul_reward)
            self.on_message:emit(string.format("+%d 넋", soul_reward))

            -- 윤회 끝? -> 이승의 문
            local gate_appeared = self.spiral:advance_realm()
            if gate_appeared then
                self.on_gate_appeared:emit()
                self:_set_state(GameState.GATE)
                return
            else
                -- 웨이브 강화 선택지 생성
                self.wave_upgrades:generate_choices(self.spiral:absolute_realm())
                self.on_wave_upgrade_ready:emit()
            end
        end

        self:_set_state(GameState.POST_ROUND)
    else
        -- 패배
        self.player.lives = self.player.lives - 1
        if self.player.lives <= 0 then
            self:_set_state(GameState.GAME_OVER)
            self.on_message:emit("저승의 어둠이 너를 집어삼킨다...")
        else
            self.current_round_in_realm = self.current_round_in_realm - 1
            self:_set_state(GameState.POST_ROUND)
        end
    end
end

-- ============================================================
-- Shop
-- ============================================================
function GameManager:open_shop()
    self.shop:generate_stock(self.spiral.current_spiral, self.upgrades:get_shop_discount())
    self:_set_state(GameState.SHOP)
end

function GameManager:shop_purchase(item_index)
    return self.shop:purchase(self.player, item_index)
end

function GameManager:leave_shop()
    if self.spiral.current_realm % 2 == 0 then
        self.events:generate_event(self.spiral.current_spiral)
        self:_set_state(GameState.EVENT)
    else
        self:start_next_realm()
    end
end

-- ============================================================
-- Event
-- ============================================================
function GameManager:execute_event_choice(choice_index)
    local result = self.events:execute_choice(self.player, choice_index)
    self.on_message:emit(result)

    if self.player.lives <= 0 then
        self:_set_state(GameState.GAME_OVER)
        self.on_message:emit("저승의 어둠이 너를 집어삼킨다...")
    end

    return result
end

function GameManager:leave_event()
    self:start_next_realm()
end

-- ============================================================
-- Gate (이승의 문)
-- ============================================================
function GameManager:enter_gate()
    self.on_message:emit("이승의 문을 통과합니다...")
end

function GameManager:continue_after_gate()
    local spiral_bonus = SoulCalculator.for_spiral_complete(self.spiral.current_spiral)
    self._run_soul_fragments = self._run_soul_fragments + spiral_bonus
    self.upgrades:add_soul_fragments(spiral_bonus)

    self.spiral:continue_to_next_spiral()
    self.on_message:emit(string.format("나선 %d 진입! 더 깊은 저승으로...", self.spiral.current_spiral))

    self:_set_state(GameState.SPIRAL_START)
end

-- ============================================================
-- Wave Upgrades
-- ============================================================
function GameManager:apply_wave_upgrade(choice_index)
    self.wave_upgrades:apply_choice(self.player, self, choice_index)
    self:open_shop()
end

function GameManager:skip_wave_upgrade()
    self.wave_upgrades.current_choices = {}
    self:open_shop()
end

-- ============================================================
-- Save / Load
-- ============================================================
function GameManager:load_from_save(data)
    if not data then return end

    if data.spiral then
        self.spiral:load_from_save(data.spiral)
    end

    local p = self.player
    p.lives = data.lives or 5
    p.yeop = data.yeop or 50
    p.go_count = data.go_count or 0

    p.wave_chip_bonus = data.wave_chip_bonus or 0
    p.wave_mult_bonus = data.wave_mult_bonus or 0
    p.wave_talisman_slot_bonus = data.wave_talisman_slot_bonus or 0
    p.wave_talisman_effect_bonus = data.wave_talisman_effect_bonus or 0
    p.wave_target_reduction = data.wave_target_reduction or 0
    p.next_round_hand_bonus = data.next_round_hand_bonus or 0

    p.talismans = {}
    -- 부적 복원 (TalismanDatabase 의존; 간소화)
    if data.equipped_talismans then
        for _, name in ipairs(data.equipped_talismans) do
            local ok, TalismanDB = pcall(require, "src.talismans.talisman_database")
            if ok and TalismanDB and TalismanDB.get_by_name then
                local tData = TalismanDB.get_by_name(name)
                if tData then
                    p:equip_talisman({ data = tData })
                end
            end
        end
    end

    -- 영구 강화 복원
    if data.soul_fragments then
        self.upgrades:set_soul_fragments(data.soul_fragments)
    end
    if data.upgrade_levels then
        for _, entry in ipairs(data.upgrade_levels) do
            self.upgrades:set_level(entry.id, entry.level)
        end
    end

    -- 보스 전투 상태 복원은 전투 모듈에 위임
    self.current_round_in_realm = data.current_round_in_realm or 0

    self._run_soul_fragments = 0

    self.on_message:emit(string.format(
        "세이브 로드 완료: 나선 %d 영역 %d",
        self.spiral.current_spiral, self.spiral.current_realm))
end

return {
    GameManager = GameManager,
    GameState   = GameState,
}

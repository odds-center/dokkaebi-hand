--- 4단계 인터랙티브 튜토리얼 (첫 플레이 시 자동 실행, 스킵 가능)
--- 1단계: 패 내기와 매칭
--- 2단계: 족보와 점수
--- 3단계: Go/Stop 선택
--- 4단계: 보스와 전략
local Signal = require("lib.signal")

-- ============================================================
-- TutorialStep enum
-- ============================================================
local TutorialStep = {
    NOT_STARTED    = "not_started",
    STEP1_MATCHING = "step1_matching",  -- 패 내기와 매칭
    STEP2_YOKBO    = "step2_yokbo",     -- 족보와 점수
    STEP3_GO_STOP  = "step3_go_stop",   -- Go/Stop 선택
    STEP4_STRATEGY = "step4_strategy",  -- 보스와 전략
    COMPLETE       = "complete",
}

-- 진행 순서 테이블
local STEP_ORDER = {
    [TutorialStep.NOT_STARTED]    = TutorialStep.STEP1_MATCHING,
    [TutorialStep.STEP1_MATCHING] = TutorialStep.STEP2_YOKBO,
    [TutorialStep.STEP2_YOKBO]    = TutorialStep.STEP3_GO_STOP,
    [TutorialStep.STEP3_GO_STOP]  = TutorialStep.STEP4_STRATEGY,
    [TutorialStep.STEP4_STRATEGY] = TutorialStep.COMPLETE,
}

-- 단계별 대사/힌트 키
local STEP_DIALOGUES = {
    [TutorialStep.STEP1_MATCHING] = { dialogue = "tutorial_step1_dialogue", hint = "tutorial_step1_hint" },
    [TutorialStep.STEP2_YOKBO]    = { dialogue = "tutorial_step2_dialogue", hint = "tutorial_step2_hint" },
    [TutorialStep.STEP3_GO_STOP]  = { dialogue = "tutorial_step3_dialogue", hint = "tutorial_step3_hint" },
    [TutorialStep.STEP4_STRATEGY] = { dialogue = "tutorial_step4_dialogue", hint = "tutorial_step4_hint" },
    [TutorialStep.COMPLETE]       = { dialogue = "tutorial_complete",       hint = "" },
}

-- ============================================================
-- TutorialPreset: 튜토리얼용 고정 라운드 프리셋
-- ============================================================
local function make_preset(description, target_score)
    return {
        description  = description,
        target_score = target_score,
    }
end

local STEP_PRESETS = {
    [TutorialStep.STEP1_MATCHING] = make_preset("1월 송학 광과 1월 카드 매칭 연습", 50),
    [TutorialStep.STEP2_YOKBO]    = make_preset("홍단 족보 완성 유도", 100),
    [TutorialStep.STEP3_GO_STOP]  = make_preset("Go 선택 시 리스크 체험", 150),
    [TutorialStep.STEP4_STRATEGY] = make_preset("보스 기믹 대응 연습", 200),
}

-- ============================================================
-- TutorialManager
-- ============================================================
local TutorialManager = {}
TutorialManager.__index = TutorialManager

function TutorialManager.new()
    return setmetatable({
        current_step     = TutorialStep.NOT_STARTED,
        current_dialogue = nil,
        current_hint     = nil,

        -- signals
        on_step_changed = Signal.new(),  -- (step)
        on_dialogue     = Signal.new(),  -- (dialogue_key)
    }, TutorialManager)
end

--- 활성 여부
function TutorialManager:is_active()
    return self.current_step ~= TutorialStep.NOT_STARTED
       and self.current_step ~= TutorialStep.COMPLETE
end

--- 튜토리얼 시작
function TutorialManager:start()
    self.current_step = TutorialStep.STEP1_MATCHING
    self:_show_step_dialogue()
end

--- 스킵
function TutorialManager:skip()
    self.current_step = TutorialStep.COMPLETE
    self.on_step_changed:emit(self.current_step)
end

--- 다음 단계로 진행
function TutorialManager:advance_step()
    if self.current_step == TutorialStep.COMPLETE then return end

    local next = STEP_ORDER[self.current_step]
    self.current_step = next or TutorialStep.COMPLETE

    self:_show_step_dialogue()
    self.on_step_changed:emit(self.current_step)
end

--- 내부: 현재 단계 대사/힌트 설정
function TutorialManager:_show_step_dialogue()
    local info = STEP_DIALOGUES[self.current_step]
    if info then
        self.current_dialogue = info.dialogue
        self.current_hint     = info.hint
    else
        self.current_dialogue = nil
        self.current_hint     = nil
    end

    if self.current_dialogue then
        self.on_dialogue:emit(self.current_dialogue)
    end
end

--- 튜토리얼용 고정 라운드 프리셋 가져오기
function TutorialManager.get_preset(step)
    return STEP_PRESETS[step] or make_preset("", 100)
end

return {
    TutorialStep    = TutorialStep,
    TutorialManager = TutorialManager,
}

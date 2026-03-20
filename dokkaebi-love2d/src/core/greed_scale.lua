--- 욕망의 저울: Go/Stop 리스크의 시각적 피드백 시스템
--- 안전(왼쪽) <-> 탐욕(오른쪽) 기울기로 현재 리스크 상태 표시
local Signal = require("lib.signal")

-- ============================================================
-- GreedLevel enum
-- ============================================================
local GreedLevel = {
    SAFE     = "safe",      -- Go 0회 -- 저울 수평, 평화
    TEMPTED  = "tempted",   -- Go 1회 -- 약간 기울어짐, 도깨비불 깜빡
    GREEDY   = "greedy",    -- Go 2회 -- 크게 기울어짐, 붉은 기운
    CONSUMED = "consumed",  -- Go 3회 -- 극한, 화면 진동, 사이렌
}

-- ============================================================
-- GreedScale
-- ============================================================
local GreedScale = {}
GreedScale.__index = GreedScale

function GreedScale.new()
    return setmetatable({
        go_count       = 0,
        level          = GreedLevel.SAFE,

        -- 시각 값
        tilt_amount    = 0,
        fire_intensity = 0.1,
        red_tint       = 0,
        bpm            = 80,
        screen_shake   = 0,

        -- signals
        on_greed_level_changed = Signal.new(), -- (level)
        on_go_moment           = Signal.new(), -- () -- 3 Go 특수 연출
    }, GreedScale)
end

--- 라운드 시작 시 리셋
function GreedScale:reset()
    self.go_count = 0
    self:_update_level()
end

--- Go 선택 시 호출
function GreedScale:on_go()
    self.go_count = self.go_count + 1
    self:_update_level()

    if self.go_count >= 3 then
        self.on_go_moment:emit()
    end
end

--- Stop 선택 시 호출
function GreedScale:on_stop()
    -- 레벨은 유지 (점수 표시용), 다음 라운드에서 리셋
end

--- 내부: 레벨 갱신 + 시각 값 설정
function GreedScale:_update_level()
    local prev_level = self.level
    local gc = self.go_count

    -- Level
    if gc == 0 then
        self.level = GreedLevel.SAFE
    elseif gc == 1 then
        self.level = GreedLevel.TEMPTED
    elseif gc == 2 then
        self.level = GreedLevel.GREEDY
    else
        self.level = GreedLevel.CONSUMED
    end

    -- Tilt
    if gc == 0 then self.tilt_amount = 0
    elseif gc == 1 then self.tilt_amount = 0.3
    elseif gc == 2 then self.tilt_amount = 0.65
    else self.tilt_amount = 1.0 end

    -- Fire intensity
    if gc == 0 then self.fire_intensity = 0.1
    elseif gc == 1 then self.fire_intensity = 0.4
    elseif gc == 2 then self.fire_intensity = 0.7
    else self.fire_intensity = 1.0 end

    -- Red tint
    if gc == 0 then self.red_tint = 0
    elseif gc == 1 then self.red_tint = 0.1
    elseif gc == 2 then self.red_tint = 0.35
    else self.red_tint = 0.7 end

    -- BPM
    if gc == 0 then self.bpm = 80
    elseif gc == 1 then self.bpm = 100
    elseif gc == 2 then self.bpm = 120
    else self.bpm = 140 end

    -- Screen shake
    if gc == 0 then self.screen_shake = 0
    elseif gc == 1 then self.screen_shake = 0
    elseif gc == 2 then self.screen_shake = 2
    else self.screen_shake = 8 end

    if self.level ~= prev_level then
        self.on_greed_level_changed:emit(self.level)
    end
end

--- UI 표시용: 현재 상태 텍스트
function GreedScale:get_status_text()
    if self.level == GreedLevel.SAFE then return "" end
    if self.level == GreedLevel.TEMPTED then return "... 욕심이 고개를 든다" end
    if self.level == GreedLevel.GREEDY then return "...! 저울이 기울어진다!" end
    if self.level == GreedLevel.CONSUMED then return "!! 욕심이 너를 삼키려 한다 !!" end
    return ""
end

--- UI 표시용: 저울 시각적 문자열
function GreedScale:get_scale_visual()
    if self.go_count == 0 then return "    o=====o    " end
    if self.go_count == 1 then return "   o======o   " end
    if self.go_count == 2 then return "  o=======o  " end
    return " o========o "
end

return {
    GreedScale = GreedScale,
    GreedLevel = GreedLevel,
}

--- 무한 나선(Infinite Spiral) 관리.
--- 10관문 1세트 = 1윤회. 윤회는 무한 반복.
--- 매 윤회 완료 시 "이승의 문" 출현 -> 선택적 엔딩 or 계속.
local Signal = require("lib.signal")

-- ============================================================
-- SpiralBlessing: 윤회 시작 시 선택하는 축복/저주 (양날의 검)
-- ============================================================
local SpiralBlessing = {}
SpiralBlessing.__index = SpiralBlessing

function SpiralBlessing.new(t)
    return setmetatable({
        id               = t.id,
        name             = t.name,
        name_kr          = t.name_kr,
        bonus_desc       = t.bonus_desc,
        penalty_desc     = t.penalty_desc,
        chip_bonus       = t.chip_bonus or 0,
        mult_bonus       = t.mult_bonus or 0,
        target_penalty   = t.target_penalty or 0,
        hand_penalty     = t.hand_penalty or 0,
        talisman_effect_mult  = t.talisman_effect_mult or 0,
        talisman_slot_penalty = t.talisman_slot_penalty or 0,
    }, SpiralBlessing)
end

function SpiralBlessing.get_all()
    return {
        SpiralBlessing.new({
            id = "fire", name = "Hellfire", name_kr = "업화(業火)",
            bonus_desc = "모든 칩 +20%", penalty_desc = "매 5턴 바닥패 1장 소각",
            chip_bonus = 0.2,
        }),
        SpiralBlessing.new({
            id = "ice", name = "Frostbind", name_kr = "빙결(氷結)",
            bonus_desc = "모든 배수 +1", penalty_desc = "매 라운드 시작 손패 -1",
            mult_bonus = 1, hand_penalty = 1,
        }),
        SpiralBlessing.new({
            id = "void", name = "Void", name_kr = "공허(空虛)",
            bonus_desc = "부적 효과 2배", penalty_desc = "부적 슬롯 -2",
            talisman_effect_mult = 2.0, talisman_slot_penalty = 2,
        }),
        SpiralBlessing.new({
            id = "chaos", name = "Chaos", name_kr = "혼돈(混沌)",
            bonus_desc = "랜덤 족보 매턴 1개 강제 완성", penalty_desc = "좋을 수도, 나쁠 수도",
            chip_bonus = 0,
        }),
    }
end

-- ============================================================
-- SpiralManager
-- ============================================================
local SpiralManager = {}
SpiralManager.__index = SpiralManager

SpiralManager.REALMS_PER_SPIRAL = 20

function SpiralManager.new()
    local self = setmetatable({
        current_spiral       = 1,
        current_realm        = 1,
        total_realms_cleared = 0,
        active_blessing      = nil,

        -- signals
        on_spiral_advanced = Signal.new(), -- (spiral_number)
        on_gate_appeared   = Signal.new(), -- ()
    }, SpiralManager)
    return self
end

--- 현재 영역의 절대 번호 (1, 2, 3, ... inf)
function SpiralManager:absolute_realm()
    return (self.current_spiral - 1) * SpiralManager.REALMS_PER_SPIRAL + self.current_realm
end

--- 영역 내 목표 점수 (같은 윤회 안에서는 완만하게 증가)
function SpiralManager:get_target_score(base_target)
    local realm_mult = 1.0 + 0.05 * (self.current_realm - 1)
    return math.floor(base_target * realm_mult)
end

--- 현재 윤회에서 보스에 붙는 파츠 수
function SpiralManager:get_parts_count()
    if self.current_spiral <= 1 then return 0 end
    if self.current_spiral <= 2 then return 1 end
    if self.current_spiral <= 3 then return 2 end
    return 3
end

--- 현재 윤회의 파츠 최소 등급
function SpiralManager:get_min_parts_rarity()
    if self.current_spiral <= 3 then return "common" end
    if self.current_spiral <= 5 then return "rare" end
    return "legendary"
end

--- 영역 클리어 -> 다음 영역 또는 윤회 완료
--- @return boolean true if gate appeared
function SpiralManager:advance_realm()
    self.total_realms_cleared = self.total_realms_cleared + 1
    self.current_realm = self.current_realm + 1

    if self.current_realm > SpiralManager.REALMS_PER_SPIRAL then
        -- 윤회 완료 -> 이승의 문 출현
        self.on_gate_appeared:emit()
        return true
    end

    return false
end

--- 이승의 문 거부 -> 다음 윤회로
function SpiralManager:continue_to_next_spiral()
    self.current_spiral = self.current_spiral + 1
    self.current_realm = 1
    self.active_blessing = nil
    self.on_spiral_advanced:emit(self.current_spiral)
end

--- 윤회 시작 시 축복 선택
function SpiralManager:select_blessing(blessing)
    self.active_blessing = blessing
end

--- 세이브용 상태 직렬화
function SpiralManager:to_save_data()
    return {
        spiral        = self.current_spiral,
        realm         = self.current_realm,
        total_cleared = self.total_realms_cleared,
        blessing_id   = self.active_blessing and self.active_blessing.id or nil,
    }
end

--- 세이브 로드
function SpiralManager:load_from_save(data)
    self.current_spiral       = data.spiral
    self.current_realm        = data.realm
    self.total_realms_cleared = data.total_cleared

    self.active_blessing = nil
    if data.blessing_id and data.blessing_id ~= "" then
        local all = SpiralBlessing.get_all()
        for _, b in ipairs(all) do
            if b.id == data.blessing_id then
                self.active_blessing = b
                break
            end
        end
    end
end

return {
    SpiralManager  = SpiralManager,
    SpiralBlessing = SpiralBlessing,
}

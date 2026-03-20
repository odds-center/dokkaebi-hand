--- 부적 데이터베이스 (20종)
--- Ported from TalismanDatabase.cs

local TD = require("src.talismans.talisman_data")
local Rarity = TD.TalismanRarity
local Trigger = TD.TalismanTrigger
local Effect = TD.TalismanEffectType
local TalismanData = TD.TalismanData

local all_talismans = nil

local function initialize()
    all_talismans = {
        -- === MVP 부적 3종 ===

        -- 1. 피의 맹세 (일반) - 피 패가 +1 배수 제공
        TalismanData({
            name = "Blood Oath",
            name_kr = "피의 맹세",
            rarity = Rarity.Common,
            description = "Each Pi card provides +1 Mult",
            description_kr = "피 패 1장당 +1 배수",
            trigger = Trigger.OnRoundEnd,
            trigger_condition = "pi_count",
            effect_type = Effect.AddMult,
            effect_value = 1,
            trigger_chance = 1,
        }),

        -- 2. 도깨비 감투 (희귀) - 띠 1장당 목표 점수 -5%
        TalismanData({
            name = "Dokkaebi Hat",
            name_kr = "도깨비 감투",
            rarity = Rarity.Rare,
            description = "-5% target score per Ribbon card",
            description_kr = "띠 1장당 목표 점수 -5%",
            trigger = Trigger.Passive,
            trigger_condition = "tti_count",
            effect_type = Effect.ReduceTarget,
            effect_value = 5,
            trigger_chance = 1,
        }),

        -- 3. 저승사자의 명부 (전설) - 점수 끝자리 4일 때 최종 배수 x4
        TalismanData({
            name = "Reaper's Ledger",
            name_kr = "저승사자의 명부",
            rarity = Rarity.Legendary,
            description = "When score ends in 4, final Mult x4",
            description_kr = "점수 끝자리 4일 때 최종 배수 x4",
            trigger = Trigger.OnRoundEnd,
            trigger_condition = "score_ends_4",
            effect_type = Effect.MultiplyMult,
            effect_value = 4,
            trigger_chance = 1,
        }),

        -- 4. 홍살문 (일반) - 홍단 완성 시 추가 +30 칩
        TalismanData({
            name = "Red Gate",
            name_kr = "홍살문",
            rarity = Rarity.Common,
            description = "+30 Chips when Hong Dan is completed",
            description_kr = "홍단 완성 시 추가 +30 칩",
            trigger = Trigger.OnYokboComplete,
            trigger_condition = "hongdan",
            effect_type = Effect.AddChips,
            effect_value = 30,
            trigger_chance = 1,
        }),

        -- 5. 달빛 여우 (희귀) - 월 매칭 실패 시 50% 확률로 와일드카드 변환
        TalismanData({
            name = "Moonlight Fox",
            name_kr = "달빛 여우",
            rarity = Rarity.Rare,
            description = "50% chance to wildcard on match fail",
            description_kr = "월 매칭 실패 시 50% 확률로 와일드카드 변환",
            trigger = Trigger.OnMatchFail,
            trigger_condition = "",
            effect_type = Effect.WildCard,
            effect_value = 1,
            trigger_chance = 0.5,
        }),

        -- 6. 광기의 광 (전설) - 광 패 사용 시 랜덤 패 1장을 광으로 변이
        TalismanData({
            name = "Madness Bright",
            name_kr = "광기의 광",
            rarity = Rarity.Legendary,
            description = "When playing Gwang, transmute 1 random card to Gwang",
            description_kr = "광 패 사용 시 랜덤 패 1장을 광으로 변이",
            trigger = Trigger.OnCardPlayed,
            trigger_condition = "gwang_played",
            effect_type = Effect.TransmuteCard,
            effect_value = 1,
            trigger_chance = 1,
        }),

        -- 7. 흉살 (저주) - 매 턴 피 1장 자동 소멸
        TalismanData({
            name = "Doom",
            name_kr = "흉살",
            rarity = Rarity.Cursed,
            description = "Destroy 1 Pi card each turn (forced equip)",
            description_kr = "매 턴 피 1장 자동 소멸 (강제 장착)",
            trigger = Trigger.OnTurnEnd,
            trigger_condition = "",
            effect_type = Effect.DestroyCard,
            effect_value = 1,
            trigger_chance = 1,
            is_curse = true,
        }),

        -- === 확장 13종 ===

        -- 8. 삼도천의 나룻배 (일반) - 매 라운드 시작 시 칩 +15
        TalismanData({
            name = "Samdo Ferry",
            name_kr = "삼도천의 나룻배",
            rarity = Rarity.Common,
            description = "+15 Chips at round start",
            description_kr = "라운드 시작 시 칩 +15",
            trigger = Trigger.OnRoundStart,
            trigger_condition = "",
            effect_type = Effect.AddChips,
            effect_value = 15,
            trigger_chance = 1,
        }),

        -- 9. 도깨비 방망이 (일반) - 쓸(Sweep) 시 칩 +40
        TalismanData({
            name = "Dokkaebi Club",
            name_kr = "도깨비 방망이",
            rarity = Rarity.Common,
            description = "+40 Chips on Sweep",
            description_kr = "쓸 시 칩 +40",
            trigger = Trigger.OnMatchSuccess,
            trigger_condition = "sweep",
            effect_type = Effect.AddChips,
            effect_value = 40,
            trigger_chance = 1,
        }),

        -- 10. 열녀문 (일반) - 초단 완성 시 배수 +2
        TalismanData({
            name = "Virtue Gate",
            name_kr = "열녀문",
            rarity = Rarity.Common,
            description = "+2 Mult when Cho Dan completed",
            description_kr = "초단 완성 시 배수 +2",
            trigger = Trigger.OnYokboComplete,
            trigger_condition = "chodan",
            effect_type = Effect.AddMult,
            effect_value = 2,
            trigger_chance = 1,
        }),

        -- 11. 황천의 거울 (희귀) - Stop 선택 시 칩 +50
        TalismanData({
            name = "Underworld Mirror",
            name_kr = "황천의 거울",
            rarity = Rarity.Rare,
            description = "+50 Chips when choosing Stop",
            description_kr = "Stop 선택 시 칩 +50",
            trigger = Trigger.OnRoundEnd,
            trigger_condition = "stop",
            effect_type = Effect.AddChips,
            effect_value = 50,
            trigger_chance = 1,
        }),

        -- 12. 기린 각 (희귀) - 그림 5장 이상일 때 배수 +3
        TalismanData({
            name = "Girin Horn",
            name_kr = "기린 각",
            rarity = Rarity.Rare,
            description = "+3 Mult when 5+ Picture cards captured",
            description_kr = "그림 5장 이상 시 배수 +3",
            trigger = Trigger.OnRoundEnd,
            trigger_condition = "geurim_5",
            effect_type = Effect.AddMult,
            effect_value = 3,
            trigger_chance = 1,
        }),

        -- 13. 사주팔자의 주사위 (희귀) - Go 선택 시 50% 칩 +80
        TalismanData({
            name = "Fate Dice",
            name_kr = "사주팔자의 주사위",
            rarity = Rarity.Rare,
            description = "50% chance +80 Chips on Go decision",
            description_kr = "Go 선택 시 50% 확률로 칩 +80",
            trigger = Trigger.OnGoDecision,
            trigger_condition = "",
            effect_type = Effect.AddChips,
            effect_value = 80,
            trigger_chance = 0.5,
        }),

        -- 14. 염라왕의 도장 (전설) - 오광 달성 시 배수 x3
        TalismanData({
            name = "Yeomra's Seal",
            name_kr = "염라왕의 도장",
            rarity = Rarity.Legendary,
            description = "x3 Mult when Five Brights achieved",
            description_kr = "오광 달성 시 배수 x3",
            trigger = Trigger.OnRoundEnd,
            trigger_condition = "ogwang",
            effect_type = Effect.MultiplyMult,
            effect_value = 3,
            trigger_chance = 1,
        }),

        -- 15. 천상의 비파 (전설) - 청단 완성 시 칩 +100, 배수 +2
        TalismanData({
            name = "Heavenly Lute",
            name_kr = "천상의 비파",
            rarity = Rarity.Legendary,
            description = "+100 Chips +2 Mult on Cheong Dan",
            description_kr = "청단 완성 시 칩 +100, 배수 +2",
            trigger = Trigger.OnYokboComplete,
            trigger_condition = "cheongdan",
            effect_type = Effect.AddChips,
            effect_value = 100,
            secondary_mult_bonus = 2,
            trigger_chance = 1,
        }),

        -- 16. 지옥불꽃 (전설) - 피 15장 이상 시 배수 x2
        TalismanData({
            name = "Hellflame",
            name_kr = "지옥불꽃",
            rarity = Rarity.Legendary,
            description = "x2 Mult when 15+ Pi cards captured",
            description_kr = "피 15장 이상 시 배수 x2",
            trigger = Trigger.OnRoundEnd,
            trigger_condition = "pi_15",
            effect_type = Effect.MultiplyMult,
            effect_value = 2,
            trigger_chance = 1,
        }),

        -- 17. 허깨비 (저주) - 매칭 실패 시 엽전 -5
        TalismanData({
            name = "Phantom",
            name_kr = "허깨비",
            rarity = Rarity.Cursed,
            description = "-5 Yeop on match fail (forced equip)",
            description_kr = "매칭 실패 시 엽전 -5 (강제 장착)",
            trigger = Trigger.OnMatchFail,
            trigger_condition = "",
            effect_type = Effect.Special,
            effect_value = -5,
            trigger_chance = 1,
            is_curse = true,
        }),

        -- 18. 망각의 띠 (저주) - Go 2회 이상 시 손패 추가 -1
        TalismanData({
            name = "Oblivion Ribbon",
            name_kr = "망각의 띠",
            rarity = Rarity.Cursed,
            description = "Hand -1 when Go count >= 2 (forced equip)",
            description_kr = "Go 2회 이상 시 손패 -1 (강제 장착)",
            trigger = Trigger.OnGoDecision,
            trigger_condition = "go_2",
            effect_type = Effect.Special,
            effect_value = -1,
            trigger_chance = 1,
            is_curse = true,
        }),

        -- 19. 윤회의 구슬 (일반) - 획득 광 1장당 칩 +10
        TalismanData({
            name = "Samsara Bead",
            name_kr = "윤회의 구슬",
            rarity = Rarity.Common,
            description = "+10 Chips per Gwang card captured",
            description_kr = "획득 광 1장당 칩 +10",
            trigger = Trigger.OnRoundEnd,
            trigger_condition = "gwang_count",
            effect_type = Effect.AddChips,
            effect_value = 10,
            trigger_chance = 1,
        }),

        -- 20. 욕망의 저울 (희귀) - 목표 점수 -10%, 하지만 목숨 -1
        TalismanData({
            name = "Scale of Desire",
            name_kr = "욕망의 저울",
            rarity = Rarity.Rare,
            description = "Target -10%, but -1 life per realm",
            description_kr = "목표 점수 -10%, 하지만 영역 시작 시 목숨 -1",
            trigger = Trigger.Passive,
            trigger_condition = "target_reduce_with_penalty",
            effect_type = Effect.ReduceTarget,
            effect_value = 10,
            trigger_chance = 1,
        }),
    }
end

-- ============================================================
-- Public API
-- ============================================================
local TalismanDatabase = {}

function TalismanDatabase.get_all()
    if not all_talismans then initialize() end
    return all_talismans
end

function TalismanDatabase.get_by_name(name)
    if not all_talismans then initialize() end
    for _, t in ipairs(all_talismans) do
        if t.name == name then return t end
    end
    return nil
end

function TalismanDatabase.get_by_name_kr(name_kr)
    if not all_talismans then initialize() end
    for _, t in ipairs(all_talismans) do
        if t.name_kr == name_kr then return t end
    end
    return nil
end

function TalismanDatabase.get_by_rarity(rarity)
    if not all_talismans then initialize() end
    local result = {}
    for _, t in ipairs(all_talismans) do
        if t.rarity == rarity then
            table.insert(result, t)
        end
    end
    return result
end

return TalismanDatabase

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

        -- 3. 저승사자의 명부 (전설) - 점수 끝자리 4일 때 최종 배수 x1.5
        TalismanData({
            name = "Reaper's Ledger",
            name_kr = "저승사자의 명부",
            rarity = Rarity.Legendary,
            description = "When score ends in 4, final Mult x1.5",
            description_kr = "점수 끝자리 4일 때 최종 배수 x1.5",
            trigger = Trigger.OnRoundEnd,
            trigger_condition = "score_ends_4",
            effect_type = Effect.MultiplyMult,
            effect_value = 1.5,
            trigger_chance = 1,
        }),

        -- 4. 홍살문 (일반) - 홍단 완성 시 추가 +30 칩
        TalismanData({
            name = "Red Gate",
            name_kr = "홍살문",
            rarity = Rarity.Common,
            description = "+30 Chips when Hong Dan is completed",
            description_kr = "홍단 완성 시 추가 +15 칩",
            trigger = Trigger.OnYokboComplete,
            trigger_condition = "hongdan",
            effect_type = Effect.AddChips,
            effect_value = 15,
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
            description_kr = "쓸 시 칩 +15",
            trigger = Trigger.OnMatchSuccess,
            trigger_condition = "sweep",
            effect_type = Effect.AddChips,
            effect_value = 15,
            trigger_chance = 1,
        }),

        -- 10. 열녀문 (일반) - 초단 완성 시 배수 +2
        TalismanData({
            name = "Virtue Gate",
            name_kr = "열녀문",
            rarity = Rarity.Common,
            description = "+2 Mult when Cho Dan completed",
            description_kr = "초단 완성 시 배수 +0.5",
            trigger = Trigger.OnYokboComplete,
            trigger_condition = "chodan",
            effect_type = Effect.AddMult,
            effect_value = 0.5,
            trigger_chance = 1,
        }),

        -- 11. 황천의 거울 (희귀) - Stop 선택 시 칩 +50
        TalismanData({
            name = "Underworld Mirror",
            name_kr = "황천의 거울",
            rarity = Rarity.Rare,
            description = "+50 Chips when choosing Stop",
            description_kr = "Stop 선택 시 칩 +20",
            trigger = Trigger.OnRoundEnd,
            trigger_condition = "stop",
            effect_type = Effect.AddChips,
            effect_value = 20,
            trigger_chance = 1,
        }),

        -- 12. 기린 각 (희귀) - 그림 5장 이상일 때 배수 +3
        TalismanData({
            name = "Girin Horn",
            name_kr = "기린 각",
            rarity = Rarity.Rare,
            description = "+3 Mult when 5+ Picture cards captured",
            description_kr = "그림 5장 이상 시 배수 +0.5",
            trigger = Trigger.OnRoundEnd,
            trigger_condition = "geurim_5",
            effect_type = Effect.AddMult,
            effect_value = 0.5,
            trigger_chance = 1,
        }),

        -- 13. 사주팔자의 주사위 (희귀) - Go 선택 시 50% 칩 +80
        TalismanData({
            name = "Fate Dice",
            name_kr = "사주팔자의 주사위",
            rarity = Rarity.Rare,
            description = "50% chance +80 Chips on Go decision",
            description_kr = "Go 선택 시 50% 확률로 칩 +25",
            trigger = Trigger.OnGoDecision,
            trigger_condition = "",
            effect_type = Effect.AddChips,
            effect_value = 25,
            trigger_chance = 0.5,
        }),

        -- 14. 염라왕의 도장 (전설) - 오광 달성 시 배수 x3
        TalismanData({
            name = "Yeomra's Seal",
            name_kr = "염라왕의 도장",
            rarity = Rarity.Legendary,
            description = "x3 Mult when Five Brights achieved",
            description_kr = "오광 달성 시 배수 x1.5",
            trigger = Trigger.OnRoundEnd,
            trigger_condition = "ogwang",
            effect_type = Effect.MultiplyMult,
            effect_value = 1.5,
            trigger_chance = 1,
        }),

        -- 15. 천상의 비파 (전설) - 청단 완성 시 칩 +100, 배수 +2
        TalismanData({
            name = "Heavenly Lute",
            name_kr = "천상의 비파",
            rarity = Rarity.Legendary,
            description = "+100 Chips +2 Mult on Cheong Dan",
            description_kr = "청단 완성 시 칩 +30, 배수 +0.3",
            trigger = Trigger.OnYokboComplete,
            trigger_condition = "cheongdan",
            effect_type = Effect.AddChips,
            effect_value = 30,
            secondary_mult_bonus = 0.3,
            trigger_chance = 1,
        }),

        -- 16. 지옥불꽃 (전설) - 피 15장 이상 시 배수 x2
        TalismanData({
            name = "Hellflame",
            name_kr = "지옥불꽃",
            rarity = Rarity.Legendary,
            description = "x2 Mult when 15+ Pi cards captured",
            description_kr = "피 15장 이상 시 배수 x1.3",
            trigger = Trigger.OnRoundEnd,
            trigger_condition = "pi_15",
            effect_type = Effect.MultiplyMult,
            effect_value = 1.3,
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

        -- 20. 욕망의 저울 (희귀)
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

        -- ═══════════════════════════════
        -- 확장 부적 30종 (21~50)
        -- ═══════════════════════════════

        -- === 일반 (10종) ===

        TalismanData({
            name = "Grave Lantern", name_kr = "저승의 초롱",
            rarity = Rarity.Common,
            description_kr = "광 패 매칭 시 칩 +10",
            trigger = Trigger.OnMatchSuccess, trigger_condition = "gwang_match",
            effect_type = Effect.AddChips, effect_value = 10,
        }),
        TalismanData({
            name = "Samshin Thread", name_kr = "삼신할미의 실",
            rarity = Rarity.Common,
            description_kr = "띠 패 매칭 시 배수 +0.3",
            trigger = Trigger.OnMatchSuccess, trigger_condition = "tti_match",
            effect_type = Effect.AddMult, effect_value = 0.3,
        }),
        TalismanData({
            name = "Dead Man's Coin", name_kr = "망자의 노자돈",
            rarity = Rarity.Common,
            description_kr = "판 종료 시 엽전 +8",
            trigger = Trigger.OnRoundEnd, trigger_condition = "",
            effect_type = Effect.Special, effect_value = 8,
        }),
        TalismanData({
            name = "Gwimun Key", name_kr = "귀문관의 열쇠",
            rarity = Rarity.Common,
            description_kr = "첫 족보 등록 시 칩 +20",
            trigger = Trigger.OnYokboComplete, trigger_condition = "first_register",
            effect_type = Effect.AddChips, effect_value = 20,
        }),
        TalismanData({
            name = "Five Color Thread", name_kr = "오방색 실타래",
            rarity = Rarity.Common,
            description_kr = "5종류 이상 카드 수집 시 배수 +0.5",
            trigger = Trigger.OnRoundEnd, trigger_condition = "variety_5",
            effect_type = Effect.AddMult, effect_value = 0.5,
        }),
        TalismanData({
            name = "Jangseung", name_kr = "장승",
            rarity = Rarity.Common,
            description_kr = "보스 반격 데미지 1 감소",
            trigger = Trigger.Passive, trigger_condition = "reduce_counter",
            effect_type = Effect.Special, effect_value = 1,
        }),
        TalismanData({
            name = "Lotus Lamp", name_kr = "연등",
            rarity = Rarity.Common,
            description_kr = "판 시작 시 칩 +8",
            trigger = Trigger.OnRoundStart, trigger_condition = "",
            effect_type = Effect.AddChips, effect_value = 8,
        }),
        TalismanData({
            name = "Totem Pole", name_kr = "솟대",
            rarity = Rarity.Common,
            description_kr = "그림 패 매칭 시 칩 +8",
            trigger = Trigger.OnMatchSuccess, trigger_condition = "geurim_match",
            effect_type = Effect.AddChips, effect_value = 8,
        }),
        TalismanData({
            name = "Straw Doll", name_kr = "짚인형",
            rarity = Rarity.Common,
            description_kr = "피 3장 이상 보유 시 칩 +12",
            trigger = Trigger.OnRoundEnd, trigger_condition = "pi_3",
            effect_type = Effect.AddChips, effect_value = 12,
        }),
        TalismanData({
            name = "Wooden Fish", name_kr = "목어",
            rarity = Rarity.Common,
            description_kr = "스톱 선택 시 칩 +10",
            trigger = Trigger.OnRoundEnd, trigger_condition = "stop",
            effect_type = Effect.AddChips, effect_value = 10,
        }),

        -- === 희귀 (10종) ===

        TalismanData({
            name = "Underworld Mist", name_kr = "삼도천의 물안개",
            rarity = Rarity.Rare,
            description_kr = "3판 이상 생존 시 칩 +25",
            trigger = Trigger.OnRoundEnd, trigger_condition = "survive_3",
            effect_type = Effect.AddChips, effect_value = 25,
        }),
        TalismanData({
            name = "Mirror Fragment", name_kr = "업경대의 파편",
            rarity = Rarity.Rare,
            description_kr = "족보 등록 시 칩 +15",
            trigger = Trigger.OnYokboComplete, trigger_condition = "",
            effect_type = Effect.AddChips, effect_value = 15,
        }),
        TalismanData({
            name = "Bone Fan", name_kr = "백골부채",
            rarity = Rarity.Rare,
            description_kr = "그림 패 3장 이상 시 배수 +0.5",
            trigger = Trigger.OnRoundEnd, trigger_condition = "geurim_3",
            effect_type = Effect.AddMult, effect_value = 0.5,
        }),
        TalismanData({
            name = "Spirit Pouch", name_kr = "혼백주머니",
            rarity = Rarity.Rare,
            description_kr = "2연속 족보 등록 시 칩 +20",
            trigger = Trigger.OnYokboComplete, trigger_condition = "chain_2",
            effect_type = Effect.AddChips, effect_value = 20,
        }),
        TalismanData({
            name = "Dokkaebi Mask", name_kr = "도깨비 탈",
            rarity = Rarity.Rare,
            description_kr = "고 성공 시 배수 +0.3",
            trigger = Trigger.OnGoDecision, trigger_condition = "",
            effect_type = Effect.AddMult, effect_value = 0.3,
        }),
        TalismanData({
            name = "Dragon Pearl", name_kr = "여의주 파편",
            rarity = Rarity.Rare,
            description_kr = "광 2장 이상 보유 시 배수 +0.5",
            trigger = Trigger.OnRoundEnd, trigger_condition = "gwang_2",
            effect_type = Effect.AddMult, effect_value = 0.5,
        }),
        TalismanData({
            name = "Fox Bead", name_kr = "여우구슬",
            rarity = Rarity.Rare,
            description_kr = "매칭 실패 시 30% 확률 칩 +15",
            trigger = Trigger.OnMatchFail, trigger_condition = "",
            effect_type = Effect.AddChips, effect_value = 15,
            trigger_chance = 0.3,
        }),
        TalismanData({
            name = "Thunder Drum", name_kr = "뇌고",
            rarity = Rarity.Rare,
            description_kr = "총통 완성 시 칩 +30",
            trigger = Trigger.OnYokboComplete, trigger_condition = "chongtong",
            effect_type = Effect.AddChips, effect_value = 30,
        }),
        TalismanData({
            name = "Underworld Flower Bud", name_kr = "저승꽃 봉오리",
            rarity = Rarity.Rare,
            description_kr = "피 5장 이상 보유 시 배수 +0.5",
            trigger = Trigger.OnRoundEnd, trigger_condition = "pi_5",
            effect_type = Effect.AddMult, effect_value = 0.5,
        }),
        TalismanData({
            name = "Iron Shield", name_kr = "철갑옷",
            rarity = Rarity.Rare,
            description_kr = "보스 광분 시 50% 확률 피해 무효",
            trigger = Trigger.Passive, trigger_condition = "rage_block",
            effect_type = Effect.Special, effect_value = 1,
            trigger_chance = 0.5,
        }),

        -- === 전설 (6종) ===

        TalismanData({
            name = "Imugi Pearl", name_kr = "이무기의 여의주",
            rarity = Rarity.Legendary,
            description_kr = "고 3회 성공 시 배수 ×1.5",
            trigger = Trigger.OnRoundEnd, trigger_condition = "go_3",
            effect_type = Effect.MultiplyMult, effect_value = 1.5,
        }),
        TalismanData({
            name = "Gumiho Tail", name_kr = "구미호의 꼬리",
            rarity = Rarity.Legendary,
            description_kr = "매 판 랜덤 카드 1장 복제",
            trigger = Trigger.OnRoundStart, trigger_condition = "",
            effect_type = Effect.TransmuteCard, effect_value = 1,
        }),
        TalismanData({
            name = "Peach of Immortality", name_kr = "천도복숭아",
            rarity = Rarity.Legendary,
            description_kr = "보스 격파 시 목숨 +1 회복",
            trigger = Trigger.OnRoundEnd, trigger_condition = "boss_defeat",
            effect_type = Effect.Special, effect_value = 1,
        }),
        TalismanData({
            name = "Wheel of Fate", name_kr = "운명의 수레바퀴",
            rarity = Rarity.Legendary,
            description_kr = "매 판 시작 시 50% 칩 +30 or 배수 +0.5",
            trigger = Trigger.OnRoundStart, trigger_condition = "",
            effect_type = Effect.AddChips, effect_value = 30,
            trigger_chance = 0.5,
            secondary_mult_bonus = 0.5,
        }),
        TalismanData({
            name = "King's Crown", name_kr = "왕의 면류관",
            rarity = Rarity.Legendary,
            description_kr = "장땡 달성 시 칩 +40, 배수 +0.5",
            trigger = Trigger.OnYokboComplete, trigger_condition = "jangttaeng",
            effect_type = Effect.AddChips, effect_value = 40,
            secondary_mult_bonus = 0.5,
        }),
        TalismanData({
            name = "Soul Lantern", name_kr = "혼등",
            rarity = Rarity.Legendary,
            description_kr = "넋 획득량 2배",
            trigger = Trigger.Passive, trigger_condition = "soul_double",
            effect_type = Effect.Special, effect_value = 2,
        }),

        -- === 저주 (4종) ===

        TalismanData({
            name = "Nightmare", name_kr = "흉몽",
            rarity = Rarity.Cursed,
            description_kr = "매 판 시작 시 칩 -10 (강제 장착)",
            trigger = Trigger.OnRoundStart, trigger_condition = "",
            effect_type = Effect.AddChips, effect_value = -10,
            is_curse = true,
        }),
        TalismanData({
            name = "Ghost Shackle", name_kr = "귀박의 족쇄",
            rarity = Rarity.Cursed,
            description_kr = "스톱 선택 시 배수 -0.3 (강제 장착)",
            trigger = Trigger.OnRoundEnd, trigger_condition = "stop",
            effect_type = Effect.AddMult, effect_value = -0.3,
            is_curse = true,
        }),
        TalismanData({
            name = "Grudge", name_kr = "원귀의 한",
            rarity = Rarity.Cursed,
            description_kr = "고 실패 시 추가 피해 +1 (강제 장착)",
            trigger = Trigger.OnGoDecision, trigger_condition = "go_fail",
            effect_type = Effect.Special, effect_value = 1,
            is_curse = true,
        }),
        TalismanData({
            name = "Fog of Oblivion", name_kr = "망각의 안개",
            rarity = Rarity.Cursed,
            description_kr = "족보 1개 랜덤 비활성 (강제 장착)",
            trigger = Trigger.OnRoundStart, trigger_condition = "",
            effect_type = Effect.Special, effect_value = 1,
            is_curse = true,
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

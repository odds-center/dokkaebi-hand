using System.Collections.Generic;

namespace DokkaebiHand.Talismans
{
    /// <summary>
    /// MVP 부적 데이터베이스 (3종 + 확장용 구조)
    /// </summary>
    public static class TalismanDatabase
    {
        private static List<TalismanData> _allTalismans;

        public static List<TalismanData> AllTalismans
        {
            get
            {
                if (_allTalismans == null)
                    Initialize();
                return _allTalismans;
            }
        }

        private static void Initialize()
        {
            _allTalismans = new List<TalismanData>();

            // === MVP 부적 3종 ===

            // 1. 피의 맹세 (일반) - 피 패가 +1 배수 제공
            _allTalismans.Add(new TalismanData
            {
                Name = "Blood Oath",
                NameKR = "피의 맹세",
                Rarity = TalismanRarity.Common,
                Description = "Each Pi card provides +1 Mult",
                DescriptionKR = "피 패 1장당 +1 배수",
                Trigger = TalismanTrigger.OnRoundEnd,
                TriggerCondition = "pi_count",
                EffectType = TalismanEffectType.AddMult,
                EffectValue = 1f, // per pi card
                TriggerChance = 1f,
                IsCurse = false
            });

            // 2. 도깨비 감투 (희귀) - 띠 1장당 목표 점수 -5%
            _allTalismans.Add(new TalismanData
            {
                Name = "Dokkaebi Hat",
                NameKR = "도깨비 감투",
                Rarity = TalismanRarity.Rare,
                Description = "-5% target score per Ribbon card",
                DescriptionKR = "띠 1장당 목표 점수 -5%",
                Trigger = TalismanTrigger.Passive,
                TriggerCondition = "tti_count",
                EffectType = TalismanEffectType.ReduceTarget,
                EffectValue = 5f, // per ribbon card
                TriggerChance = 1f,
                IsCurse = false
            });

            // 3. 저승사자의 명부 (전설) - 점수 끝자리 4일 때 최종 배수 x4
            _allTalismans.Add(new TalismanData
            {
                Name = "Reaper's Ledger",
                NameKR = "저승사자의 명부",
                Rarity = TalismanRarity.Legendary,
                Description = "When score ends in 4, final Mult x4",
                DescriptionKR = "점수 끝자리 4일 때 최종 배수 x4",
                Trigger = TalismanTrigger.OnRoundEnd,
                TriggerCondition = "score_ends_4",
                EffectType = TalismanEffectType.MultiplyMult,
                EffectValue = 4f,
                TriggerChance = 1f,
                IsCurse = false
            });

            // === 확장용 (Phase 3에서 추가) ===

            // 4. 홍살문 (일반) - 홍단 완성 시 추가 +30 칩
            _allTalismans.Add(new TalismanData
            {
                Name = "Red Gate",
                NameKR = "홍살문",
                Rarity = TalismanRarity.Common,
                Description = "+30 Chips when Hong Dan is completed",
                DescriptionKR = "홍단 완성 시 추가 +30 칩",
                Trigger = TalismanTrigger.OnYokboComplete,
                TriggerCondition = "hongdan",
                EffectType = TalismanEffectType.AddChips,
                EffectValue = 30f,
                TriggerChance = 1f,
                IsCurse = false
            });

            // 5. 달빛 여우 (희귀) - 월 매칭 실패 시 50% 확률로 와일드카드 변환
            _allTalismans.Add(new TalismanData
            {
                Name = "Moonlight Fox",
                NameKR = "달빛 여우",
                Rarity = TalismanRarity.Rare,
                Description = "50% chance to wildcard on match fail",
                DescriptionKR = "월 매칭 실패 시 50% 확률로 와일드카드 변환",
                Trigger = TalismanTrigger.OnMatchFail,
                TriggerCondition = "",
                EffectType = TalismanEffectType.WildCard,
                EffectValue = 1f,
                TriggerChance = 0.5f,
                IsCurse = false
            });

            // 6. 광기의 광 (전설) - 광 패 사용 시 랜덤 패 1장을 광으로 변이
            _allTalismans.Add(new TalismanData
            {
                Name = "Madness Bright",
                NameKR = "광기의 광",
                Rarity = TalismanRarity.Legendary,
                Description = "When playing Gwang, transmute 1 random card to Gwang",
                DescriptionKR = "광 패 사용 시 랜덤 패 1장을 광으로 변이",
                Trigger = TalismanTrigger.OnCardPlayed,
                TriggerCondition = "gwang_played",
                EffectType = TalismanEffectType.TransmuteCard,
                EffectValue = 1f,
                TriggerChance = 1f,
                IsCurse = false
            });

            // 7. 흉살 (저주) - 매 턴 피 1장 자동 소멸
            _allTalismans.Add(new TalismanData
            {
                Name = "Doom",
                NameKR = "흉살",
                Rarity = TalismanRarity.Cursed,
                Description = "Destroy 1 Pi card each turn (forced equip)",
                DescriptionKR = "매 턴 피 1장 자동 소멸 (강제 장착)",
                Trigger = TalismanTrigger.OnTurnEnd,
                TriggerCondition = "",
                EffectType = TalismanEffectType.DestroyCard,
                EffectValue = 1f,
                TriggerChance = 1f,
                IsCurse = true
            });

            // === 확장 13종 ===

            // 8. 삼도천의 나룻배 (일반) - 매 라운드 시작 시 칩 +15
            _allTalismans.Add(new TalismanData
            {
                Name = "Samdo Ferry",
                NameKR = "삼도천의 나룻배",
                Rarity = TalismanRarity.Common,
                Description = "+15 Chips at round start",
                DescriptionKR = "라운드 시작 시 칩 +15",
                Trigger = TalismanTrigger.OnRoundStart,
                TriggerCondition = "",
                EffectType = TalismanEffectType.AddChips,
                EffectValue = 15f,
                TriggerChance = 1f,
                IsCurse = false
            });

            // 9. 도깨비 방망이 (일반) - 쓸(Sweep) 시 칩 +40
            _allTalismans.Add(new TalismanData
            {
                Name = "Dokkaebi Club",
                NameKR = "도깨비 방망이",
                Rarity = TalismanRarity.Common,
                Description = "+40 Chips on Sweep",
                DescriptionKR = "쓸 시 칩 +40",
                Trigger = TalismanTrigger.OnMatchSuccess,
                TriggerCondition = "sweep",
                EffectType = TalismanEffectType.AddChips,
                EffectValue = 40f,
                TriggerChance = 1f,
                IsCurse = false
            });

            // 10. 열녀문 (일반) - 초단 완성 시 배수 +2
            _allTalismans.Add(new TalismanData
            {
                Name = "Virtue Gate",
                NameKR = "열녀문",
                Rarity = TalismanRarity.Common,
                Description = "+2 Mult when Cho Dan completed",
                DescriptionKR = "초단 완성 시 배수 +2",
                Trigger = TalismanTrigger.OnYokboComplete,
                TriggerCondition = "chodan",
                EffectType = TalismanEffectType.AddMult,
                EffectValue = 2f,
                TriggerChance = 1f,
                IsCurse = false
            });

            // 11. 황천의 거울 (희귀) - Stop 선택 시 칩 +50
            _allTalismans.Add(new TalismanData
            {
                Name = "Underworld Mirror",
                NameKR = "황천의 거울",
                Rarity = TalismanRarity.Rare,
                Description = "+50 Chips when choosing Stop",
                DescriptionKR = "Stop 선택 시 칩 +50",
                Trigger = TalismanTrigger.OnRoundEnd,
                TriggerCondition = "stop",
                EffectType = TalismanEffectType.AddChips,
                EffectValue = 50f,
                TriggerChance = 1f,
                IsCurse = false
            });

            // 12. 기린 각 (희귀) - 열끗 5장 이상일 때 배수 +3
            _allTalismans.Add(new TalismanData
            {
                Name = "Girin Horn",
                NameKR = "기린 각",
                Rarity = TalismanRarity.Rare,
                Description = "+3 Mult when 5+ Animal cards captured",
                DescriptionKR = "열끗 5장 이상 시 배수 +3",
                Trigger = TalismanTrigger.OnRoundEnd,
                TriggerCondition = "yeolkkeut_5",
                EffectType = TalismanEffectType.AddMult,
                EffectValue = 3f,
                TriggerChance = 1f,
                IsCurse = false
            });

            // 13. 사주팔자의 주사위 (희귀) - Go 선택 시 50% 칩 +80
            _allTalismans.Add(new TalismanData
            {
                Name = "Fate Dice",
                NameKR = "사주팔자의 주사위",
                Rarity = TalismanRarity.Rare,
                Description = "50% chance +80 Chips on Go decision",
                DescriptionKR = "Go 선택 시 50% 확률로 칩 +80",
                Trigger = TalismanTrigger.OnGoDecision,
                TriggerCondition = "",
                EffectType = TalismanEffectType.AddChips,
                EffectValue = 80f,
                TriggerChance = 0.5f,
                IsCurse = false
            });

            // 14. 염라왕의 도장 (전설) - 오광 달성 시 배수 x3
            _allTalismans.Add(new TalismanData
            {
                Name = "Yeomra's Seal",
                NameKR = "염라왕의 도장",
                Rarity = TalismanRarity.Legendary,
                Description = "x3 Mult when Five Brights achieved",
                DescriptionKR = "오광 달성 시 배수 x3",
                Trigger = TalismanTrigger.OnRoundEnd,
                TriggerCondition = "ogwang",
                EffectType = TalismanEffectType.MultiplyMult,
                EffectValue = 3f,
                TriggerChance = 1f,
                IsCurse = false
            });

            // 15. 천상의 비파 (전설) - 청단 완성 시 칩 +100, 배수 +2
            _allTalismans.Add(new TalismanData
            {
                Name = "Heavenly Lute",
                NameKR = "천상의 비파",
                Rarity = TalismanRarity.Legendary,
                Description = "+100 Chips +2 Mult on Cheong Dan",
                DescriptionKR = "청단 완성 시 칩 +100, 배수 +2",
                Trigger = TalismanTrigger.OnYokboComplete,
                TriggerCondition = "cheongdan",
                EffectType = TalismanEffectType.AddChips,
                EffectValue = 100f,
                SecondaryMultBonus = 2f,
                TriggerChance = 1f,
                IsCurse = false
            });

            // 16. 지옥불꽃 (전설) - 피 15장 이상 시 배수 x2
            _allTalismans.Add(new TalismanData
            {
                Name = "Hellflame",
                NameKR = "지옥불꽃",
                Rarity = TalismanRarity.Legendary,
                Description = "x2 Mult when 15+ Pi cards captured",
                DescriptionKR = "피 15장 이상 시 배수 x2",
                Trigger = TalismanTrigger.OnRoundEnd,
                TriggerCondition = "pi_15",
                EffectType = TalismanEffectType.MultiplyMult,
                EffectValue = 2f,
                TriggerChance = 1f,
                IsCurse = false
            });

            // 17. 허깨비 (저주) - 매칭 실패 시 엽전 -5
            _allTalismans.Add(new TalismanData
            {
                Name = "Phantom",
                NameKR = "허깨비",
                Rarity = TalismanRarity.Cursed,
                Description = "-5 Yeop on match fail (forced equip)",
                DescriptionKR = "매칭 실패 시 엽전 -5 (강제 장착)",
                Trigger = TalismanTrigger.OnMatchFail,
                TriggerCondition = "",
                EffectType = TalismanEffectType.Special,
                EffectValue = -5f,
                TriggerChance = 1f,
                IsCurse = true
            });

            // 18. 망각의 띠 (저주) - Go 2회 이상 시 손패 추가 -1
            _allTalismans.Add(new TalismanData
            {
                Name = "Oblivion Ribbon",
                NameKR = "망각의 띠",
                Rarity = TalismanRarity.Cursed,
                Description = "Hand -1 when Go count >= 2 (forced equip)",
                DescriptionKR = "Go 2회 이상 시 손패 -1 (강제 장착)",
                Trigger = TalismanTrigger.OnGoDecision,
                TriggerCondition = "go_2",
                EffectType = TalismanEffectType.Special,
                EffectValue = -1f,
                TriggerChance = 1f,
                IsCurse = true
            });

            // 19. 윤회의 구슬 (일반) - 획득 광 1장당 칩 +10
            _allTalismans.Add(new TalismanData
            {
                Name = "Samsara Bead",
                NameKR = "윤회의 구슬",
                Rarity = TalismanRarity.Common,
                Description = "+10 Chips per Gwang card captured",
                DescriptionKR = "획득 광 1장당 칩 +10",
                Trigger = TalismanTrigger.OnRoundEnd,
                TriggerCondition = "gwang_count",
                EffectType = TalismanEffectType.AddChips,
                EffectValue = 10f,
                TriggerChance = 1f,
                IsCurse = false
            });

            // 20. 욕망의 저울 (희귀) - 목표 점수 -10%, 하지만 목숨 -1 (영역 시작 시)
            _allTalismans.Add(new TalismanData
            {
                Name = "Scale of Desire",
                NameKR = "욕망의 저울",
                Rarity = TalismanRarity.Rare,
                Description = "Target -10%, but -1 life per realm",
                DescriptionKR = "목표 점수 -10%, 하지만 영역 시작 시 목숨 -1",
                Trigger = TalismanTrigger.Passive,
                TriggerCondition = "target_reduce_with_penalty",
                EffectType = TalismanEffectType.ReduceTarget,
                EffectValue = 10f,
                TriggerChance = 1f,
                IsCurse = false
            });
        }

        public static TalismanData GetByName(string name)
        {
            return AllTalismans.Find(t => t.Name == name);
        }

        public static TalismanData GetByNameKR(string nameKR)
        {
            return AllTalismans.Find(t => t.NameKR == nameKR);
        }

        public static List<TalismanData> GetByRarity(TalismanRarity rarity)
        {
            return AllTalismans.FindAll(t => t.Rarity == rarity);
        }
    }
}

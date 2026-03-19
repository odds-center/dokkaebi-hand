using System;
using System.Collections.Generic;
using DokkaebiHand.Cards;
using DokkaebiHand.Core;

namespace DokkaebiHand.Combat
{
    public enum PartsSlot
    {
        Head,
        Arm,
        Body
    }

    public enum PartsRarity
    {
        Common,
        Rare,
        Legendary
    }

    /// <summary>
    /// 보스에 장착되는 파츠 데이터
    /// </summary>
    public class BossPartData
    {
        public string Id;
        public string Name;
        public string NameKR;
        public PartsSlot Slot;
        public PartsRarity Rarity;
        public string Description;
        public string SetId; // 세트 효과용

        // 기믹 효과
        public float TargetBonusPercent;     // 목표 점수 증가 %
        public int FieldBurnCount;           // N턴마다 바닥패 소각 수
        public int FieldBurnInterval;        // 소각 간격 (턴)
        public int HandFreezeCount;          // 매 라운드 동결 손패 수
        public float PlayerMultReduction;    // Go 배수 감소
        public float TalismanEffectReduction;// 부적 효과 감소 %
        public int SkullifyInterval;         // N턴마다 획득패 해골화
    }

    /// <summary>
    /// 보스 파츠 데이터베이스
    /// </summary>
    public static class BossPartsDatabase
    {
        private static List<BossPartData> _allParts;

        public static List<BossPartData> AllParts
        {
            get
            {
                if (_allParts == null) Initialize();
                return _allParts;
            }
        }

        private static void Initialize()
        {
            _allParts = new List<BossPartData>
            {
                // === 머리 파츠 ===
                new BossPartData
                {
                    Id = "iron_horn", Name = "Iron Horn", NameKR = "쇠뿔",
                    Slot = PartsSlot.Head, Rarity = PartsRarity.Common,
                    Description = "목표 점수 +15%",
                    TargetBonusPercent = 15f
                },
                new BossPartData
                {
                    Id = "fire_horn", Name = "Flame Horn", NameKR = "화염 뿔",
                    Slot = PartsSlot.Head, Rarity = PartsRarity.Rare, SetId = "fire",
                    Description = "매 4턴 바닥패 2장 소각",
                    FieldBurnCount = 2, FieldBurnInterval = 4
                },
                new BossPartData
                {
                    Id = "ice_crown", Name = "Ice Crown", NameKR = "얼음 왕관",
                    Slot = PartsSlot.Head, Rarity = PartsRarity.Rare, SetId = "ice",
                    Description = "매 라운드 시작 시 손패 1장 동결",
                    HandFreezeCount = 1
                },
                new BossPartData
                {
                    Id = "third_eye", Name = "Third Eye", NameKR = "제3의 눈",
                    Slot = PartsSlot.Head, Rarity = PartsRarity.Common,
                    Description = "손패 1장 보스에게 공개"
                },
                new BossPartData
                {
                    Id = "ghost_helm", Name = "Ghost Fire Helm", NameKR = "도깨비불 투구",
                    Slot = PartsSlot.Head, Rarity = PartsRarity.Rare,
                    Description = "부적 발동 확률 -20%",
                    TalismanEffectReduction = 0.2f
                },
                new BossPartData
                {
                    Id = "skull_crown", Name = "Skull Crown", NameKR = "해골 면류관",
                    Slot = PartsSlot.Head, Rarity = PartsRarity.Legendary, SetId = "skull",
                    Description = "매 3턴 획득패 1장 해골화",
                    SkullifyInterval = 3
                },
                new BossPartData
                {
                    Id = "fog_mask", Name = "Fog Mask", NameKR = "독안개 면",
                    Slot = PartsSlot.Head, Rarity = PartsRarity.Rare,
                    Description = "바닥패 2장 항상 뒤집힘"
                },
                new BossPartData
                {
                    Id = "king_helm", Name = "Heavenly Helm", NameKR = "천왕 투구",
                    Slot = PartsSlot.Head, Rarity = PartsRarity.Legendary,
                    Description = "광 패 칩 -50%"
                },

                // === 팔 파츠 ===
                new BossPartData
                {
                    Id = "chain_arm", Name = "Chain Arm", NameKR = "쇠사슬",
                    Slot = PartsSlot.Arm, Rarity = PartsRarity.Rare,
                    Description = "매 턴 손패 2장 체인 (함께 내야 함)"
                },
                new BossPartData
                {
                    Id = "fire_glove", Name = "Flame Glove", NameKR = "불꽃 장갑",
                    Slot = PartsSlot.Arm, Rarity = PartsRarity.Common, SetId = "fire",
                    Description = "기믹 발동 시 목표 +30",
                    TargetBonusPercent = 0 // flat +30 handled in code
                },
                new BossPartData
                {
                    Id = "shadow_arm", Name = "Shadow Arm", NameKR = "그림자 팔",
                    Slot = PartsSlot.Arm, Rarity = PartsRarity.Rare, SetId = "shadow",
                    Description = "매 2턴 바닥패 1장 보스가 가져감",
                    FieldBurnCount = 1, FieldBurnInterval = 2
                },
                new BossPartData
                {
                    Id = "gold_brace", Name = "Gold Bracelet", NameKR = "황금 팔찌",
                    Slot = PartsSlot.Arm, Rarity = PartsRarity.Common,
                    Description = "매칭 성공 시 엽전 -3"
                },
                new BossPartData
                {
                    Id = "poison_claw", Name = "Poison Claw", NameKR = "독 발톱",
                    Slot = PartsSlot.Arm, Rarity = PartsRarity.Rare,
                    Description = "매칭 실패 시 독 스택 +1 (3스택 = 목표 +50)"
                },
                new BossPartData
                {
                    Id = "seal_arm", Name = "Seal Arm", NameKR = "봉인 부적 팔",
                    Slot = PartsSlot.Arm, Rarity = PartsRarity.Legendary,
                    Description = "랜덤 부적 1개 효과 50% 감소",
                    TalismanEffectReduction = 0.5f
                },
                new BossPartData
                {
                    Id = "web_hand", Name = "Web Hand", NameKR = "거미줄 손",
                    Slot = PartsSlot.Arm, Rarity = PartsRarity.Rare,
                    Description = "획득패가 1턴 지연 (바로 족보 미반영)"
                },
                new BossPartData
                {
                    Id = "bone_pincer", Name = "Bone Pincer", NameKR = "뼈 집게",
                    Slot = PartsSlot.Arm, Rarity = PartsRarity.Legendary, SetId = "skull",
                    Description = "쓸 시 1장 보스가 가로챔"
                },

                // === 몸통 파츠 ===
                new BossPartData
                {
                    Id = "iron_plate", Name = "Iron Plate", NameKR = "철갑",
                    Slot = PartsSlot.Body, Rarity = PartsRarity.Common,
                    Description = "첫 3턴 목표 +100",
                    TargetBonusPercent = 0 // flat, handled in code
                },
                new BossPartData
                {
                    Id = "fire_mark", Name = "Fire Mark", NameKR = "화문(火紋)",
                    Slot = PartsSlot.Body, Rarity = PartsRarity.Rare, SetId = "fire",
                    Description = "기믹 쿨타임 -1턴"
                },
                new BossPartData
                {
                    Id = "ice_armor", Name = "Ice Armor", NameKR = "빙결 갑옷",
                    Slot = PartsSlot.Body, Rarity = PartsRarity.Rare, SetId = "ice",
                    Description = "Go 배수 -1 (최소 1)",
                    PlayerMultReduction = 1
                },
                new BossPartData
                {
                    Id = "shadow_armor", Name = "Shadow Armor", NameKR = "그림자 갑옷",
                    Slot = PartsSlot.Body, Rarity = PartsRarity.Common, SetId = "shadow",
                    Description = "목표 변동 (±10% 랜덤)"
                },
                new BossPartData
                {
                    Id = "talisman_absorb", Name = "Talisman Absorber", NameKR = "부적 흡수체",
                    Slot = PartsSlot.Body, Rarity = PartsRarity.Legendary,
                    Description = "부적 효과 30% 흡수",
                    TalismanEffectReduction = 0.3f
                },
                new BossPartData
                {
                    Id = "mirror_plate", Name = "Mirror Plate", NameKR = "거울 흉갑",
                    Slot = PartsSlot.Body, Rarity = PartsRarity.Legendary,
                    Description = "족보 1개 복사하여 보스 목표 감소"
                },
                new BossPartData
                {
                    Id = "thorn_armor", Name = "Thorn Armor", NameKR = "가시 갑옷",
                    Slot = PartsSlot.Body, Rarity = PartsRarity.Rare,
                    Description = "매칭 성공 시 10% 다음 턴 매칭 불가"
                },
                new BossPartData
                {
                    Id = "smoke_body", Name = "Smoke Body", NameKR = "연기 몸",
                    Slot = PartsSlot.Body, Rarity = PartsRarity.Common,
                    Description = "2턴마다 바닥패 시야 일시 차단"
                }
            };
        }

        public static List<BossPartData> GetBySlot(PartsSlot slot)
        {
            return AllParts.FindAll(p => p.Slot == slot);
        }

        public static List<BossPartData> GetByRarity(PartsRarity minRarity)
        {
            return AllParts.FindAll(p => p.Rarity >= minRarity);
        }

        public static List<BossPartData> GetBySlotAndRarity(PartsSlot slot, PartsRarity minRarity)
        {
            return AllParts.FindAll(p => p.Slot == slot && p.Rarity >= minRarity);
        }
    }
}

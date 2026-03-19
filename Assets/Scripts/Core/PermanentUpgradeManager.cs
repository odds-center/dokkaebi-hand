using System;
using System.Collections.Generic;

namespace DokkaebiHand.Core
{
    /// <summary>
    /// 영구 강화 트리: 영혼 조각으로 투자하는 메타 진행.
    /// 3갈래: 패의 길 / 부적의 길 / 생존의 길
    /// </summary>
    public enum UpgradePath
    {
        Card,     // 패의 길
        Talisman, // 부적의 길
        Survival  // 생존의 길
    }

    public class UpgradeDefinition
    {
        public string Id;
        public string NameKR;
        public UpgradePath Path;
        public int MaxLevel;
        public int[] Costs;       // 레벨별 비용
        public string Description; // 레벨당 효과 설명

        public int GetCost(int currentLevel)
        {
            if (currentLevel >= MaxLevel) return -1;
            return Costs[currentLevel];
        }
    }

    public class PermanentUpgradeManager
    {
        public int SoulFragments { get; private set; }

        private Dictionary<string, int> _upgradeLevels = new Dictionary<string, int>();
        private List<UpgradeDefinition> _allUpgrades;

        public IReadOnlyList<UpgradeDefinition> AllUpgrades => _allUpgrades;

        public PermanentUpgradeManager()
        {
            _allUpgrades = InitializeUpgrades();
        }

        public void AddSoulFragments(int amount)
        {
            SoulFragments += amount;
        }

        public int GetLevel(string upgradeId)
        {
            return _upgradeLevels.TryGetValue(upgradeId, out int level) ? level : 0;
        }

        public bool CanUpgrade(string upgradeId)
        {
            var def = _allUpgrades.Find(u => u.Id == upgradeId);
            if (def == null) return false;

            int current = GetLevel(upgradeId);
            if (current >= def.MaxLevel) return false;

            int cost = def.GetCost(current);
            return SoulFragments >= cost;
        }

        public bool Purchase(string upgradeId)
        {
            if (!CanUpgrade(upgradeId)) return false;

            var def = _allUpgrades.Find(u => u.Id == upgradeId);
            int current = GetLevel(upgradeId);
            int cost = def.GetCost(current);

            SoulFragments -= cost;
            _upgradeLevels[upgradeId] = current + 1;
            return true;
        }

        // === 효과 조회 메서드 ===

        public int GetBonusChips()
        {
            return GetLevel("base_chips") * 5;
        }

        public int GetBonusMult()
        {
            return GetLevel("base_mult");
        }

        public int GetBonusHandSize()
        {
            return GetLevel("start_hand");
        }

        public int GetDeckReduction()
        {
            return GetLevel("deck_compress") * 2;
        }

        public int GetExtraTalismanSlots()
        {
            return GetLevel("talisman_slots");
        }

        public float GetTalismanTriggerBonus()
        {
            return GetLevel("talisman_trigger") * 0.05f;
        }

        public int GetExtraLives()
        {
            return GetLevel("max_lives");
        }

        public float GetGoInsuranceChance()
        {
            return GetLevel("go_insurance") * 0.3f;
        }

        public int GetBonusStartYeop()
        {
            return GetLevel("start_yeop") * 30;
        }

        public float GetShopDiscount()
        {
            return GetLevel("shop_discount") * 0.1f;
        }

        public float GetTargetReduction()
        {
            return GetLevel("target_reduce") * 0.03f;
        }

        public bool HasRevive()
        {
            return GetLevel("revive") > 0;
        }

        public bool HasTalismanFusion()
        {
            return GetLevel("talisman_fusion") > 0;
        }

        /// <summary>
        /// 세이브 로드용: 비용 없이 직접 레벨 설정
        /// </summary>
        public void SetLevel(string upgradeId, int level)
        {
            _upgradeLevels[upgradeId] = level;
        }

        /// <summary>
        /// 세이브 로드용: 영혼 조각 직접 설정
        /// </summary>
        public void SetSoulFragments(int amount)
        {
            SoulFragments = amount;
        }

        public int GetTotalUpgradesPurchased()
        {
            int total = 0;
            foreach (var kv in _upgradeLevels)
                total += kv.Value;
            return total;
        }

        private List<UpgradeDefinition> InitializeUpgrades()
        {
            return new List<UpgradeDefinition>
            {
                // === 패의 길 ===
                new UpgradeDefinition
                {
                    Id = "base_chips", NameKR = "기본 칩 증가",
                    Path = UpgradePath.Card, MaxLevel = 10,
                    Costs = new[] { 20, 40, 60, 80, 100, 120, 140, 160, 180, 200 },
                    Description = "모든 족보 칩 +5/레벨"
                },
                new UpgradeDefinition
                {
                    Id = "base_mult", NameKR = "기본 배수 증가",
                    Path = UpgradePath.Card, MaxLevel = 5,
                    Costs = new[] { 50, 100, 200, 400, 800 },
                    Description = "기본 배수 +1/레벨"
                },
                new UpgradeDefinition
                {
                    Id = "start_hand", NameKR = "시작 손패",
                    Path = UpgradePath.Card, MaxLevel = 3,
                    Costs = new[] { 100, 300, 600 },
                    Description = "시작 손패 +1/레벨"
                },
                new UpgradeDefinition
                {
                    Id = "deck_compress", NameKR = "덱 압축",
                    Path = UpgradePath.Card, MaxLevel = 4,
                    Costs = new[] { 80, 160, 320, 640 },
                    Description = "피 카드 2장 제거/레벨"
                },
                new UpgradeDefinition
                {
                    Id = "yokbo_bonus", NameKR = "족보 보너스",
                    Path = UpgradePath.Card, MaxLevel = 5,
                    Costs = new[] { 60, 120, 240, 480, 960 },
                    Description = "첫 족보 완성 시 칩 +20/레벨"
                },
                new UpgradeDefinition
                {
                    Id = "sweep_bonus", NameKR = "쓸 보너스",
                    Path = UpgradePath.Card, MaxLevel = 3,
                    Costs = new[] { 100, 200, 400 },
                    Description = "쓸 시 배수 +1/레벨"
                },

                // === 부적의 길 ===
                new UpgradeDefinition
                {
                    Id = "talisman_slots", NameKR = "부적 슬롯 확장",
                    Path = UpgradePath.Talisman, MaxLevel = 3,
                    Costs = new[] { 200, 500, 1000 },
                    Description = "최대 부적 +1/레벨"
                },
                new UpgradeDefinition
                {
                    Id = "talisman_trigger", NameKR = "부적 발동률",
                    Path = UpgradePath.Talisman, MaxLevel = 5,
                    Costs = new[] { 40, 80, 160, 320, 640 },
                    Description = "확률 부적 발동률 +5%/레벨"
                },
                new UpgradeDefinition
                {
                    Id = "talisman_fusion", NameKR = "부적 합성 해금",
                    Path = UpgradePath.Talisman, MaxLevel = 1,
                    Costs = new[] { 800 },
                    Description = "같은 등급 부적 2개 → 상위 1개"
                },
                new UpgradeDefinition
                {
                    Id = "legend_rate", NameKR = "전설 등장률",
                    Path = UpgradePath.Talisman, MaxLevel = 3,
                    Costs = new[] { 300, 600, 1200 },
                    Description = "상점 전설 부적 등장 +5%/레벨"
                },
                new UpgradeDefinition
                {
                    Id = "start_talisman", NameKR = "시작 부적 슬롯",
                    Path = UpgradePath.Talisman, MaxLevel = 2,
                    Costs = new[] { 500, 1000 },
                    Description = "런 시작 시 선택 부적 +1/레벨"
                },
                new UpgradeDefinition
                {
                    Id = "curse_resist", NameKR = "저주 저항",
                    Path = UpgradePath.Talisman, MaxLevel = 3,
                    Costs = new[] { 100, 200, 400 },
                    Description = "저주 부적 효과 -20%/레벨"
                },

                // === 생존의 길 ===
                new UpgradeDefinition
                {
                    Id = "max_lives", NameKR = "최대 목숨",
                    Path = UpgradePath.Survival, MaxLevel = 3,
                    Costs = new[] { 150, 300, 600 },
                    Description = "시작 목숨 +1/레벨"
                },
                new UpgradeDefinition
                {
                    Id = "go_insurance", NameKR = "Go 보험",
                    Path = UpgradePath.Survival, MaxLevel = 2,
                    Costs = new[] { 300, 800 },
                    Description = "Go 실패 시 30%/60% 면제"
                },
                new UpgradeDefinition
                {
                    Id = "start_yeop", NameKR = "시작 엽전",
                    Path = UpgradePath.Survival, MaxLevel = 5,
                    Costs = new[] { 30, 60, 120, 240, 480 },
                    Description = "시작 엽전 +30/레벨"
                },
                new UpgradeDefinition
                {
                    Id = "shop_discount", NameKR = "상점 할인",
                    Path = UpgradePath.Survival, MaxLevel = 3,
                    Costs = new[] { 100, 250, 500 },
                    Description = "상점 가격 -10%/레벨"
                },
                new UpgradeDefinition
                {
                    Id = "event_bonus", NameKR = "이벤트 보너스",
                    Path = UpgradePath.Survival, MaxLevel = 3,
                    Costs = new[] { 80, 160, 320 },
                    Description = "이벤트 보상 +20%/레벨"
                },
                new UpgradeDefinition
                {
                    Id = "revive", NameKR = "부활",
                    Path = UpgradePath.Survival, MaxLevel = 1,
                    Costs = new[] { 1500 },
                    Description = "런 당 1회 즉사 면제"
                },
                new UpgradeDefinition
                {
                    Id = "target_reduce", NameKR = "목표 점수 감소",
                    Path = UpgradePath.Survival, MaxLevel = 5,
                    Costs = new[] { 100, 200, 400, 800, 1600 },
                    Description = "모든 보스 목표 -3%/레벨"
                }
            };
        }
    }
}

using System;
using System.Collections.Generic;
using DokkaebiHand.Core;

namespace DokkaebiHand.Combat
{
    /// <summary>
    /// 보스 랜덤 생성기.
    /// 기본 도깨비 + 파츠 조합으로 매번 다른 보스를 생성.
    /// </summary>
    public class BossGenerator
    {
        private readonly Random _rng;

        public BossGenerator(int? seed = null)
        {
            _rng = seed.HasValue ? new Random(seed.Value) : new Random();
        }

        /// <summary>
        /// 스토리 보스 생성 (나선 1: 고정 도깨비 + 파츠 없음)
        /// </summary>
        public GeneratedBoss GenerateStoryBoss(int realmInSpiral, SpiralManager spiral)
        {
            var baseBoss = BossDatabase.GetBoss(Math.Min(realmInSpiral - 1, BossDatabase.AllBosses.Count - 1));
            int partsCount = spiral.GetPartsCount();
            var minRarity = spiral.GetMinPartsRarity();

            var parts = GenerateRandomParts(partsCount, minRarity);
            int target = spiral.GetTargetScore(baseBoss.TargetScore);

            // 파츠 목표 보너스 적용
            foreach (var part in parts)
            {
                target = (int)(target * (1f + part.TargetBonusPercent / 100f));
            }

            return new GeneratedBoss
            {
                BaseBoss = baseBoss,
                Parts = parts,
                FinalTargetScore = target,
                DisplayName = BuildDisplayName(baseBoss.NameKR, parts),
                Spiral = spiral.CurrentSpiral,
                AbsoluteRealm = spiral.AbsoluteRealm
            };
        }

        /// <summary>
        /// 잡졸 보스 생성 (완전 랜덤)
        /// </summary>
        public GeneratedBoss GenerateRandomBoss(SpiralManager spiral, int baseTarget = 150)
        {
            var allBosses = BossDatabase.AllBosses;
            var baseBoss = allBosses[_rng.Next(allBosses.Count)];
            int partsCount = spiral.GetPartsCount();
            var minRarity = spiral.GetMinPartsRarity();

            var parts = GenerateRandomParts(partsCount, minRarity);
            int target = spiral.GetTargetScore(baseTarget);

            foreach (var part in parts)
            {
                target = (int)(target * (1f + part.TargetBonusPercent / 100f));
            }

            // 기믹 간격 랜덤 변동 (±1, 최소 1)
            var mutatedBoss = new BossDefinition
            {
                Id = baseBoss.Id,
                Name = baseBoss.Name,
                NameKR = baseBoss.NameKR,
                Description = baseBoss.Description,
                TargetScore = baseBoss.TargetScore,
                Rounds = baseBoss.Rounds + _rng.Next(-1, 2), // 2~4 라운드 변동
                Gimmick = baseBoss.Gimmick,
                GimmickInterval = System.Math.Max(1, baseBoss.GimmickInterval + _rng.Next(-1, 2)),
                IntroDialogue = baseBoss.IntroDialogue,
                DefeatDialogue = baseBoss.DefeatDialogue,
                VictoryDialogue = baseBoss.VictoryDialogue,
                YeopReward = baseBoss.YeopReward + _rng.Next(-20, 30),
                DropsLegendaryTalisman = baseBoss.DropsLegendaryTalisman
            };
            mutatedBoss.Rounds = System.Math.Max(2, mutatedBoss.Rounds);

            return new GeneratedBoss
            {
                BaseBoss = mutatedBoss,
                Parts = parts,
                FinalTargetScore = target,
                DisplayName = BuildDisplayName(mutatedBoss.NameKR, parts),
                Spiral = spiral.CurrentSpiral,
                AbsoluteRealm = spiral.AbsoluteRealm
            };
        }

        private List<BossPartData> GenerateRandomParts(int count, PartsRarity minRarity)
        {
            var result = new List<BossPartData>();
            if (count <= 0) return result;

            var slots = new[] { PartsSlot.Head, PartsSlot.Arm, PartsSlot.Body };

            for (int i = 0; i < Math.Min(count, slots.Length); i++)
            {
                var pool = BossPartsDatabase.GetBySlotAndRarity(slots[i], minRarity);
                if (pool.Count > 0)
                {
                    result.Add(pool[_rng.Next(pool.Count)]);
                }
            }

            return result;
        }

        private string BuildDisplayName(string baseName, List<BossPartData> parts)
        {
            if (parts.Count == 0) return baseName;

            // 세트 효과 체크
            string setName = CheckSetBonus(parts);
            if (setName != null)
                return $"{setName} {baseName}";

            // 파츠 접두사 조합
            var prefixes = new List<string>();
            foreach (var part in parts)
            {
                prefixes.Add(part.NameKR);
            }

            return $"{string.Join(" ", prefixes)} {baseName}";
        }

        private string CheckSetBonus(List<BossPartData> parts)
        {
            var setCounts = new Dictionary<string, int>();
            foreach (var part in parts)
            {
                if (string.IsNullOrEmpty(part.SetId)) continue;
                if (!setCounts.ContainsKey(part.SetId))
                    setCounts[part.SetId] = 0;
                setCounts[part.SetId]++;
            }

            foreach (var kv in setCounts)
            {
                if (kv.Value >= 2)
                {
                    return kv.Key switch
                    {
                        "fire" => "불의 군주",
                        "ice" => "얼음의 군주",
                        "shadow" => "그림자의 군주",
                        "skull" => "해골의 군주",
                        _ => null
                    };
                }
            }

            return null;
        }
    }

    /// <summary>
    /// 생성된 보스 인스턴스
    /// </summary>
    public class GeneratedBoss
    {
        public BossDefinition BaseBoss;
        public List<BossPartData> Parts;
        public int FinalTargetScore;
        public string DisplayName;
        public int Spiral;
        public int AbsoluteRealm;

        public bool HasSetBonus()
        {
            var sets = new Dictionary<string, int>();
            foreach (var p in Parts)
            {
                if (string.IsNullOrEmpty(p.SetId)) continue;
                if (!sets.ContainsKey(p.SetId)) sets[p.SetId] = 0;
                sets[p.SetId]++;
                if (sets[p.SetId] >= 2) return true;
            }
            return false;
        }

        public float GetTotalTalismanReduction()
        {
            float total = 0;
            foreach (var p in Parts)
                total += p.TalismanEffectReduction;
            return Math.Min(total, 0.9f);
        }
    }
}

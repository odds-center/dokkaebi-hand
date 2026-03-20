using System;
using System.Collections.Generic;
using DokkaebiHand.Cards;

namespace DokkaebiHand.Core
{
    /// <summary>
    /// 도깨비 각인: 보스 영혼을 카드에 각인하여 특수 효과 부여
    /// 10종 각인 × 2슬롯 = 풍부한 빌드 조합
    /// 2개 각인 시너지 5종
    /// </summary>
    public class SealDefinition
    {
        public string Id;
        public string NameKR;
        public string NameEN;
        public string DescKR;
        public string BossId; // 획득 보스
    }

    public class SealSynergyDefinition
    {
        public string Seal1Id;
        public string Seal2Id;
        public string NameKR;
        public string DescKR;
        public float BonusValue;
    }

    public static class DokkaebiSealDatabase
    {
        private static List<SealDefinition> _allSeals;
        private static List<SealSynergyDefinition> _synergies;

        public static List<SealDefinition> AllSeals
        {
            get
            {
                if (_allSeals == null) Initialize();
                return _allSeals;
            }
        }

        public static List<SealSynergyDefinition> AllSynergies
        {
            get
            {
                if (_synergies == null) Initialize();
                return _synergies;
            }
        }

        private static void Initialize()
        {
            _allSeals = new List<SealDefinition>
            {
                new SealDefinition
                {
                    Id = "greed", NameKR = "탐식의 각인", NameEN = "Greed Seal",
                    DescKR = "이 카드로 매칭 시 목표 -10", BossId = "glutton"
                },
                new SealDefinition
                {
                    Id = "deception", NameKR = "기만의 각인", NameEN = "Deception Seal",
                    DescKR = "이 카드는 인접 월에도 매칭 가능", BossId = "trickster"
                },
                new SealDefinition
                {
                    Id = "delusion", NameKR = "환혹의 각인", NameEN = "Delusion Seal",
                    DescKR = "매칭 실패 시 칩 +5", BossId = "fox"
                },
                new SealDefinition
                {
                    Id = "truth", NameKR = "진실의 각인", NameEN = "Truth Seal",
                    DescKR = "보스 기믹 면역 (이 카드 관련)", BossId = "mirror"
                },
                new SealDefinition
                {
                    Id = "judgment", NameKR = "심판의 각인", NameEN = "Judgment Seal",
                    DescKR = "족보 완성 시 배수 +3", BossId = "yeomra"
                },
                new SealDefinition
                {
                    Id = "rage", NameKR = "분노의 각인", NameEN = "Rage Seal",
                    DescKR = "연속 매칭 시 누적 칩 +10", BossId = "volcano"
                },
                new SealDefinition
                {
                    Id = "avarice", NameKR = "탐욕의 각인", NameEN = "Avarice Seal",
                    DescKR = "매칭 성공 시 엽전 +5", BossId = "gold"
                },
                new SealDefinition
                {
                    Id = "patience", NameKR = "인내의 각인", NameEN = "Patience Seal",
                    DescKR = "마지막 턴 칩/배수 2배", BossId = "corridor"
                },
                new SealDefinition
                {
                    Id = "replication", NameKR = "복제의 각인", NameEN = "Replication Seal",
                    DescKR = "30% 확률로 효과 2회 적용", BossId = "shadow"
                },
                new SealDefinition
                {
                    Id = "samsara", NameKR = "윤회의 각인", NameEN = "Samsara Seal",
                    DescKR = "런 종료 시 강화 등급 유지", BossId = "flame"
                }
            };

            _synergies = new List<SealSynergyDefinition>
            {
                new SealSynergyDefinition
                {
                    Seal1Id = "greed", Seal2Id = "avarice",
                    NameKR = "탐식+탐욕: 황금 폭식",
                    DescKR = "매칭 시 엽전 +10 추가",
                    BonusValue = 10
                },
                new SealSynergyDefinition
                {
                    Seal1Id = "deception", Seal2Id = "delusion",
                    NameKR = "기만+환혹: 완벽한 환상",
                    DescKR = "매칭 실패 시 50% 와일드카드",
                    BonusValue = 0.5f
                },
                new SealSynergyDefinition
                {
                    Seal1Id = "judgment", Seal2Id = "rage",
                    NameKR = "심판+분노: 격노의 심판",
                    DescKR = "족보 완성 시 칩 +50",
                    BonusValue = 50
                },
                new SealSynergyDefinition
                {
                    Seal1Id = "truth", Seal2Id = "patience",
                    NameKR = "진실+인내: 불변의 진리",
                    DescKR = "마지막 3턴 목표 -20%",
                    BonusValue = 0.2f
                },
                new SealSynergyDefinition
                {
                    Seal1Id = "replication", Seal2Id = "samsara",
                    NameKR = "복제+윤회: 영겁의 순환",
                    DescKR = "모든 각인 효과 +50%",
                    BonusValue = 0.5f
                }
            };
        }

        public static SealDefinition GetById(string id)
        {
            return AllSeals.Find(s => s.Id == id);
        }

        public static SealDefinition GetByBoss(string bossId)
        {
            return AllSeals.Find(s => s.BossId == bossId);
        }

        /// <summary>
        /// 두 각인의 시너지 체크
        /// </summary>
        public static SealSynergyDefinition CheckSynergy(string seal1, string seal2)
        {
            return AllSynergies.Find(s =>
                (s.Seal1Id == seal1 && s.Seal2Id == seal2) ||
                (s.Seal1Id == seal2 && s.Seal2Id == seal1));
        }
    }

    /// <summary>
    /// 각인 효과를 실제 게임에 적용하는 매니저
    /// </summary>
    public class SealEffectManager
    {
        private int _consecutiveMatchCount;
        private readonly Random _rng = new Random();

        public event Action<string> OnSealTriggered;

        public void ResetRound()
        {
            _consecutiveMatchCount = 0;
        }

        /// <summary>
        /// 카드 매칭 시 각인 효과 적용
        /// </summary>
        public SealMatchResult ApplyOnMatch(CardInstance card, CardEnhancementManager enhMgr,
            bool matchSuccess, int turnNumber, int totalTurns)
        {
            var result = SealMatchResult.Default();
            var enh = enhMgr.GetEnhancement(card.Id);

            if (enh.Seals.Count == 0) return result;

            // 시너지 체크
            SealSynergyDefinition synergy = null;
            if (enh.Seals.Count == 2)
                synergy = DokkaebiSealDatabase.CheckSynergy(enh.Seals[0], enh.Seals[1]);

            float effectMult = synergy != null && synergy.Seal1Id == "replication" ? 1.5f : 1f;

            foreach (var sealId in enh.Seals)
            {
                // 복제 각인: 30% 2회 적용
                int times = 1;
                if (sealId == "replication" && _rng.NextDouble() < 0.3)
                    times = 2;

                for (int t = 0; t < times; t++)
                {
                    switch (sealId)
                    {
                        case "greed":
                            result.TargetReduction += (int)(10 * effectMult);
                            OnSealTriggered?.Invoke("탐식: 목표 -10");
                            break;

                        case "delusion":
                            if (!matchSuccess)
                            {
                                result.BonusChips += (int)(5 * effectMult);
                                OnSealTriggered?.Invoke("환혹: 칩 +5");
                            }
                            break;

                        case "judgment":
                            // 족보 완성 시 — 외부에서 호출
                            break;

                        case "rage":
                            if (matchSuccess)
                            {
                                _consecutiveMatchCount++;
                                result.BonusChips += (int)(_consecutiveMatchCount * 10 * effectMult);
                                OnSealTriggered?.Invoke($"분노: 연속 {_consecutiveMatchCount}회, 칩 +{_consecutiveMatchCount * 10}");
                            }
                            else
                            {
                                _consecutiveMatchCount = 0;
                            }
                            break;

                        case "avarice":
                            if (matchSuccess)
                            {
                                result.BonusYeop += (int)(5 * effectMult);
                                OnSealTriggered?.Invoke("탐욕: 엽전 +5");
                            }
                            break;

                        case "patience":
                            if (turnNumber >= totalTurns - 1)
                            {
                                result.ChipMultiplier *= 2f;
                                result.MultMultiplier *= 2f;
                                OnSealTriggered?.Invoke("인내: 마지막 턴! 칩/배수 2배!");
                            }
                            break;
                    }
                }
            }

            // 시너지 보너스
            if (synergy != null)
            {
                if (synergy.Seal1Id == "greed" && synergy.Seal2Id == "avarice" && matchSuccess)
                {
                    result.BonusYeop += 10;
                    OnSealTriggered?.Invoke("황금 폭식: 엽전 +10");
                }
                else if (synergy.Seal1Id == "judgment" && synergy.Seal2Id == "rage")
                {
                    result.BonusChips += 50;
                    OnSealTriggered?.Invoke("격노의 심판: 칩 +50");
                }
            }

            return result;
        }

        /// <summary>
        /// 족보 완성 시 각인 효과
        /// </summary>
        public int GetYokboSealMult(CardEnhancementManager enhMgr, List<CardInstance> capturedCards)
        {
            int bonus = 0;
            foreach (var card in capturedCards)
            {
                var enh = enhMgr.GetEnhancement(card.Id);
                if (enh.Seals.Contains("judgment"))
                {
                    bonus += 3;
                    OnSealTriggered?.Invoke("심판의 각인: 배수 +3");
                }
            }
            return bonus;
        }
    }

    public struct SealMatchResult
    {
        public int BonusChips;
        public int BonusYeop;
        public int TargetReduction;
        public float ChipMultiplier;
        public float MultMultiplier;

        public static SealMatchResult Default() => new SealMatchResult
        {
            BonusChips = 0,
            BonusYeop = 0,
            TargetReduction = 0,
            ChipMultiplier = 1f,
            MultMultiplier = 1f
        };
    }
}

using System;
using System.Collections.Generic;
using DokkaebiHand.Cards;

namespace DokkaebiHand.Core
{
    /// <summary>
    /// 웨이브 강화: 영역 클리어 시 3택 1 강화 선택 (VS 스타일)
    /// 카테고리: A(패) / B(부적) / C(생존) / D(특수)
    /// </summary>
    public class WaveUpgrade
    {
        public string Id;
        public string NameKR;
        public string NameEN;
        public string DescKR;
        public string DescEN;
        public string Category; // "card", "talisman", "survival", "special"
        public Action<PlayerState, GameManager> Apply;
    }

    public class WaveUpgradeManager
    {
        private readonly Random _rng = new Random();
        public List<WaveUpgrade> CurrentChoices { get; private set; } = new List<WaveUpgrade>();

        /// <summary>
        /// 3개 랜덤 강화 선택지 생성
        /// </summary>
        public void GenerateChoices(int absoluteRealm)
        {
            CurrentChoices.Clear();
            var pool = GetUpgradePool(absoluteRealm);

            // 셔플 후 3개 선택
            for (int i = pool.Count - 1; i > 0; i--)
            {
                int j = _rng.Next(i + 1);
                (pool[i], pool[j]) = (pool[j], pool[i]);
            }

            int count = Math.Min(3, pool.Count);
            for (int i = 0; i < count; i++)
                CurrentChoices.Add(pool[i]);
        }

        /// <summary>
        /// 선택 적용
        /// </summary>
        public bool ApplyChoice(PlayerState player, GameManager game, int index)
        {
            if (index < 0 || index >= CurrentChoices.Count) return false;
            CurrentChoices[index].Apply?.Invoke(player, game);
            CurrentChoices.Clear();
            return true;
        }

        private List<WaveUpgrade> GetUpgradePool(int realm)
        {
            // 나선이 올라갈수록 강화 수치도 기하급수 증가
            // 잘 키우면 나선 50+ 까지 갈 수 있도록 설계
            int spiral = Math.Max(1, (realm - 1) / 10 + 1);

            // 칩: 기하급수 (×1.3/나선)
            int chipAmount = (int)(20 * Math.Pow(1.3, spiral - 1));

            // 배수: 나선 10 이전은 가산, 10+ 부터는 현재 배수의 30% 추가 (곱셈 성장)
            int multAmount;
            if (spiral < 10)
                multAmount = Math.Max(1, (int)(1 * Math.Pow(1.25, spiral - 1)));
            else
                multAmount = Math.Max(5, (int)(Math.Pow(1.25, spiral - 1)));

            var pool = new List<WaveUpgrade>
            {
                // === A: 패 강화 (나선 비례) ===
                new WaveUpgrade
                {
                    Id = "wave_chip_20", NameKR = $"칩 강화 +{chipAmount}", NameEN = "Chip Boost",
                    DescKR = $"이번 런 모든 족보 칩 +{chipAmount}", DescEN = $"+{chipAmount} Chips to all Yokbo",
                    Category = "card",
                    Apply = (p, g) => p.WaveChipBonus += chipAmount
                },
                new WaveUpgrade
                {
                    Id = "wave_mult_1", NameKR = $"배수 강화 +{multAmount}", NameEN = "Mult Boost",
                    DescKR = $"이번 런 기본 배수 +{multAmount}", DescEN = $"+{multAmount} base Mult",
                    Category = "card",
                    Apply = (p, g) => p.WaveMultBonus += multAmount
                },
                new WaveUpgrade
                {
                    Id = "wave_hand_1", NameKR = "손패 추가", NameEN = "Extra Hand",
                    DescKR = "다음 라운드 손패 +1", DescEN = "+1 Hand next round",
                    Category = "card",
                    Apply = (p, g) => p.NextRoundHandBonus += 1
                },

                // === B: 부적 강화 ===
                new WaveUpgrade
                {
                    Id = "wave_talisman_boost", NameKR = "부적 증폭", NameEN = "Talisman Amp",
                    DescKR = "부적 칩/배수 효과 +50%", DescEN = "Talisman chip/mult +50%",
                    Category = "talisman",
                    Apply = (p, g) => p.WaveTalismanEffectBonus += 0.5f
                },
                new WaveUpgrade
                {
                    Id = "wave_talisman_slot", NameKR = "부적 슬롯 +1", NameEN = "+1 Talisman Slot",
                    DescKR = "이번 런 부적 슬롯 +1", DescEN = "+1 Talisman slot this run",
                    Category = "talisman",
                    Apply = (p, g) => p.WaveTalismanSlotBonus += 1
                },

                // === C: 생존 강화 ===
                new WaveUpgrade
                {
                    Id = "wave_heal_2", NameKR = "치유", NameEN = "Heal",
                    DescKR = "목숨 +2 회복", DescEN = "Restore 2 lives",
                    Category = "survival",
                    Apply = (p, g) => p.Lives = Math.Min(p.Lives + 2, PlayerState.MaxLives)
                },
                new WaveUpgrade
                {
                    Id = "wave_yeop_100", NameKR = "엽전 보너스", NameEN = "Yeop Bonus",
                    DescKR = "엽전 +100", DescEN = "+100 Yeop",
                    Category = "survival",
                    Apply = (p, g) => p.Yeop += 100
                },
                new WaveUpgrade
                {
                    Id = "wave_target_10", NameKR = "목표 감소", NameEN = "Target Reduce",
                    DescKR = "다음 영역 목표 -10%", DescEN = "Next realm target -10%",
                    Category = "survival",
                    Apply = (p, g) => p.WaveTargetReduction += 0.1f
                },

                // === D: 특수 ===
                new WaveUpgrade
                {
                    Id = "wave_random_talisman", NameKR = "랜덤 부적", NameEN = "Random Talisman",
                    DescKR = "랜덤 일반 부적 1개 장착", DescEN = "Equip 1 random Common talisman",
                    Category = "special",
                    Apply = (p, g) =>
                    {
                        var commons = Talismans.TalismanDatabase.GetByRarity(Talismans.TalismanRarity.Common);
                        if (commons.Count > 0 && p.CanEquipTalisman())
                        {
                            var t = commons[_rng.Next(commons.Count)];
                            p.EquipTalisman(new Talismans.TalismanInstance(t));
                        }
                    }
                },
                new WaveUpgrade
                {
                    Id = "wave_soul_30", NameKR = "영혼 수확", NameEN = "Soul Harvest",
                    DescKR = "넋 +30", DescEN = "+30 Soul Fragments",
                    Category = "special",
                    Apply = (p, g) => g.Upgrades.AddSoulFragments(30)
                },
                new WaveUpgrade
                {
                    Id = "wave_gamble", NameKR = "도박", NameEN = "Gamble",
                    DescKR = "50% 확률로 칩 +50 or 목숨 -1", DescEN = "50% +50 Chips or -1 life",
                    Category = "special",
                    Apply = (p, g) =>
                    {
                        if (_rng.NextDouble() < 0.5)
                            p.Yeop += 50;
                        else
                            p.Lives = Math.Max(1, p.Lives - 1);
                    }
                }
            };

            // 고렙 전용 강화 추가 (나선 비례)
            if (realm >= 10)
            {
                int megaMult = Math.Max(3, (int)(3 * Math.Pow(1.4, spiral - 1))); // 기하급수
                pool.Add(new WaveUpgrade
                {
                    Id = "wave_mega_mult", NameKR = $"극한 배수 +{megaMult}", NameEN = "Mega Mult",
                    DescKR = $"기본 배수 +{megaMult} (목숨 -1)", DescEN = $"+{megaMult} Mult (-1 life)",
                    Category = "special",
                    Apply = (p, g) => { p.WaveMultBonus += megaMult; p.Lives = Math.Max(1, p.Lives - 1); }
                });
            }

            return pool;
        }
    }
}

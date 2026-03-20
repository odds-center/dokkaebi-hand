using System;
using System.Collections.Generic;
using System.Linq;
using DokkaebiHand.Cards;
using DokkaebiHand.Core;

namespace DokkaebiHand.Combat
{
    /// <summary>
    /// 전투 시스템 핵심:
    ///
    /// [고스톱 페이즈] 패를 매칭해서 모은다
    ///   → 모은 패로 고스톱 족보가 완성되면 "시너지" 활성
    ///   → 시너지는 직접 데미지가 아니라, 섯다 공격을 강화하는 버프
    ///
    /// [공격 페이즈] 모은 패 중 2장을 골라 섯다 족보로 공격!
    ///   → 섯다 기본 데미지 × 시너지 배수 = 최종 타격
    ///   → 공격에 쓴 2장은 소모됨 (족보 깨질 수 있음!)
    ///
    /// 핵심 딜레마: "족보 유지 vs 강한 공격"
    ///   삼광 유지하면 시너지 배수 높지만, 광을 섯다에 쓰면 광땡 한 방!
    /// </summary>
    public class BattleSystem
    {
        /// <summary>
        /// 현재 활성화된 고스톱 시너지 목록
        /// </summary>
        public List<ActiveSynergy> ActiveSynergies { get; private set; } = new List<ActiveSynergy>();

        /// <summary>
        /// 시너지 총 배수 (모든 활성 시너지 합산)
        /// </summary>
        public float TotalSynergyMult { get; private set; } = 1f;

        /// <summary>
        /// 시너지 총 추가 점수
        /// </summary>
        public int TotalSynergyBonus { get; private set; }

        /// <summary>
        /// 고스톱 페이즈 종료 후: 모은 패 기반으로 시너지 판정
        /// </summary>
        public void EvaluateSynergies(PlayerState player)
        {
            ActiveSynergies.Clear();
            TotalSynergyMult = 1f;
            TotalSynergyBonus = 0;

            // === 광 시너지 ===
            int gwangCount = player.CapturedGwang.Count;
            bool hasRain = player.CapturedGwang.Any(c => c.IsRainGwang);

            if (gwangCount >= 5)
            {
                AddSynergy("오광", "섯다 데미지 ×3", 3f, 0);
            }
            else if (gwangCount == 4)
            {
                AddSynergy("사광", "섯다 데미지 ×2.5", 2.5f, 0);
            }
            else if (gwangCount == 3 && !hasRain)
            {
                AddSynergy("삼광", "섯다 데미지 ×2", 2f, 0);
            }
            else if (gwangCount == 3 && hasRain)
            {
                AddSynergy("비광", "섯다 데미지 ×1.5", 1.5f, 0);
            }
            else if (gwangCount == 2)
            {
                AddSynergy("쌍광", "섯다 데미지 ×1.3", 1.3f, 0);
            }

            // === 띠 시너지 ===
            var ribbons = player.CapturedTti;
            bool hong = HasRibbonSet(ribbons, RibbonType.HongDan,
                new[] { CardMonth.January, CardMonth.February, CardMonth.March });
            bool cheong = HasRibbonSet(ribbons, RibbonType.CheongDan,
                new[] { CardMonth.June, CardMonth.September, CardMonth.October });
            bool cho = HasRibbonSet(ribbons, RibbonType.ChoDan,
                new[] { CardMonth.April, CardMonth.May, CardMonth.July });

            if (hong) AddSynergy("홍단", "섯다 공격 +40점", 1f, 40);
            if (cheong) AddSynergy("청단", "섯다 공격 +40점", 1f, 40);
            if (cho) AddSynergy("초단", "섯다 공격 +40점", 1f, 40);

            if (hong && cheong && cho)
                AddSynergy("삼단통!", "추가 ×1.5", 1.5f, 50);

            if (ribbons.Count >= 5)
                AddSynergy($"띠 {ribbons.Count}장", $"+{ribbons.Count * 8}점", 1f, ribbons.Count * 8);

            // === 열끗 시너지 ===
            var yeol = player.CapturedYeolkkeut;
            bool godori = yeol.Any(c => c.Month == CardMonth.February) &&
                          yeol.Any(c => c.Month == CardMonth.April) &&
                          yeol.Any(c => c.Month == CardMonth.August);

            if (godori) AddSynergy("고도리", "섯다 공격 ×1.5", 1.5f, 0);

            if (yeol.Count >= 5)
                AddSynergy($"열끗 {yeol.Count}장", $"+{yeol.Count * 6}점", 1f, yeol.Count * 6);

            // === 피 시너지 ===
            int piCount = player.GetTotalPiCount();
            if (piCount >= 10)
                AddSynergy($"피 {piCount}장", $"섯다 공격 +{piCount * 3}점", 1f, piCount * 3);

            // === 총통 ===
            CheckChongtong(player);

            // 총 배수 계산
            TotalSynergyMult = 1f;
            TotalSynergyBonus = 0;
            foreach (var s in ActiveSynergies)
            {
                TotalSynergyMult *= s.MultBonus;
                TotalSynergyBonus += s.FlatBonus;
            }
        }

        /// <summary>
        /// 섯다 공격! 모은 패 중 2장 선택 → 데미지 계산
        /// 선택한 2장은 소모됨!
        /// </summary>
        public AttackResult ExecuteSeotdaAttack(PlayerState player, CardInstance card1, CardInstance card2)
        {
            var result = new AttackResult();

            // 섯다 족보 판정
            var seotda = SeotdaChallenge.Evaluate(card1, card2);
            result.SeotdaName = seotda.Name;
            result.SeotdaRank = seotda.Rank;

            // 섯다 기본 데미지
            result.BaseDamage = CalculateSeotdaBaseDamage(seotda);

            // 시너지 적용 전 시너지 재평가 (공격 전 시점의 시너지)
            result.SynergyMult = TotalSynergyMult;
            result.SynergyBonus = TotalSynergyBonus;

            // 최종 데미지 = (기본 + 시너지 보너스) × 시너지 배수
            result.FinalDamage = (int)((result.BaseDamage + result.SynergyBonus) * result.SynergyMult);

            // 공격에 쓴 2장 소모!
            RemoveCardFromPlayer(player, card1);
            RemoveCardFromPlayer(player, card2);

            // 시너지 재평가 (카드 소모 후 족보가 깨질 수 있음)
            EvaluateSynergies(player);

            result.SynergiesAfter = new List<string>();
            foreach (var s in ActiveSynergies)
                result.SynergiesAfter.Add(s.Name);

            return result;
        }

        /// <summary>
        /// 섯다 족보별 기본 데미지
        /// </summary>
        private int CalculateSeotdaBaseDamage(SeotdaResult seotda)
        {
            return seotda.Rank switch
            {
                100 => 300, // 38광땡
                99 => 250,  // 18광땡
                98 => 230,  // 13광땡
                95 => 200,  // 기타 광땡
                >= 90 => 150, // 장땡
                >= 80 => 80 + (seotda.Rank - 80) * 7, // N땡 (80~150)
                75 => 100,  // 알리
                74 => 90,   // 독사
                73 => 80,   // 구삥
                72 => 70,   // 장삥
                71 => 60,   // 장사
                70 => 50,   // 세륙
                >= 7 => seotda.Rank * 5, // 7~9끗
                >= 1 => seotda.Rank * 3, // 1~6끗
                _ => 5 // 갑오(0끗) — 최소 데미지
            };
        }

        private bool RemoveCardFromPlayer(PlayerState player, CardInstance card)
        {
            // 4개 리스트에서 해당 카드 제거
            if (player.CapturedGwang.Remove(card)) return true;
            if (player.CapturedTti.Remove(card)) return true;
            if (player.CapturedYeolkkeut.Remove(card)) return true;
            if (player.CapturedPi.Remove(card)) return true;
            return false;
        }

        private void AddSynergy(string name, string desc, float mult, int flat)
        {
            ActiveSynergies.Add(new ActiveSynergy
            {
                Name = name,
                Description = desc,
                MultBonus = mult,
                FlatBonus = flat
            });
        }

        private bool HasRibbonSet(List<CardInstance> ribbons, RibbonType type, CardMonth[] months)
        {
            foreach (var m in months)
                if (!ribbons.Any(r => r.Ribbon == type && r.Month == m))
                    return false;
            return true;
        }

        private void CheckChongtong(PlayerState player)
        {
            var all = new List<CardInstance>();
            all.AddRange(player.CapturedGwang);
            all.AddRange(player.CapturedTti);
            all.AddRange(player.CapturedYeolkkeut);
            all.AddRange(player.CapturedPi);

            var counts = new Dictionary<CardMonth, int>();
            foreach (var c in all)
            {
                if (!counts.ContainsKey(c.Month)) counts[c.Month] = 0;
                counts[c.Month]++;
            }

            foreach (var kv in counts)
                if (kv.Value >= 4)
                    AddSynergy($"총통({(int)kv.Key}월)", "섯다 공격 ×1.5", 1.5f, 30);
        }
    }

    public class ActiveSynergy
    {
        public string Name;
        public string Description;
        public float MultBonus;  // 1.0 = 변동 없음, 2.0 = 2배
        public int FlatBonus;    // 추가 점수
    }

    public class AttackResult
    {
        public string SeotdaName;
        public int SeotdaRank;
        public int BaseDamage;
        public float SynergyMult;
        public int SynergyBonus;
        public int FinalDamage;
        public List<string> SynergiesAfter; // 공격 후 남은 시너지
    }
}

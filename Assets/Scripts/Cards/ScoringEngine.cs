using System.Collections.Generic;
using System.Linq;
using DokkaebiHand.Core;

namespace DokkaebiHand.Cards
{
    /// <summary>
    /// 고스톱 족보 판정 엔진
    ///
    /// 역할: 모은 패에서 어떤 족보가 완성되었는지 판정
    /// 데미지 계산은 BattleSystem이 담당 (섯다 공격 × 시너지)
    ///
    /// 이 엔진은 "어떤 시너지가 활성인가"를 판단하는 데 사용
    /// </summary>
    public class ScoringEngine
    {
        public struct ScoreResult
        {
            public int Chips;
            public int Mult;
            public int FinalScore;
            public List<string> CompletedYokbo;

            public override string ToString()
            {
                string yokbo = CompletedYokbo != null ? string.Join(", ", CompletedYokbo) : "";
                return yokbo.Length > 0 ? yokbo : "(족보 없음)";
            }
        }

        /// <summary>
        /// 현재 모은 패에서 완성된 족보 목록 반환
        /// BattleSystem에서 시너지 판정에 사용
        /// Go/Stop 판정에도 사용 (족보 있으면 고/스톱 선택 가능)
        /// </summary>
        public ScoreResult CalculateScore(PlayerState player)
        {
            var result = new ScoreResult
            {
                Chips = 0,
                Mult = 1,
                CompletedYokbo = new List<string>()
            };

            CalculateGwangScore(player, ref result);
            CalculateTtiScore(player, ref result);
            CalculateYeolkkeutScore(player, ref result);
            CalculatePiScore(player, ref result);
            CalculateGodori(player, ref result);
            CalculateChongtong(player, ref result);
            CalculateSpecialYokbo(player, ref result);
            ApplyGoMultiplier(player, ref result);

            result.FinalScore = result.Chips * result.Mult;
            return result;
        }

        #region 광

        private void CalculateGwangScore(PlayerState player, ref ScoreResult result)
        {
            int cnt = player.CapturedGwang.Count;
            bool rain = player.CapturedGwang.Any(c => c.IsRainGwang);

            if (cnt >= 5) { result.Chips += 300; result.Mult += 5; result.CompletedYokbo.Add("오광(五光)"); }
            else if (cnt == 4 && !rain) { result.Chips += 200; result.Mult += 3; result.CompletedYokbo.Add("사광(四光)"); }
            else if (cnt == 4 && rain) { result.Chips += 180; result.Mult += 3; result.CompletedYokbo.Add("비사광"); }
            else if (cnt == 3 && !rain) { result.Chips += 150; result.Mult += 2; result.CompletedYokbo.Add("삼광(三光)"); }
            else if (cnt == 3 && rain) { result.Chips += 100; result.Mult += 1; result.CompletedYokbo.Add("비광(雨光)"); }
        }

        #endregion

        #region 띠

        private void CalculateTtiScore(PlayerState player, ref ScoreResult result)
        {
            var r = player.CapturedTti;
            bool hong = HasSet(r, RibbonType.HongDan, CardMonth.January, CardMonth.February, CardMonth.March);
            bool cheong = HasSet(r, RibbonType.CheongDan, CardMonth.June, CardMonth.September, CardMonth.October);
            bool cho = HasSet(r, RibbonType.ChoDan, CardMonth.April, CardMonth.May, CardMonth.July);

            if (hong) { result.Chips += 120; result.Mult += 2; result.CompletedYokbo.Add("홍단(紅丹)"); }
            if (cheong) { result.Chips += 120; result.Mult += 2; result.CompletedYokbo.Add("청단(靑丹)"); }
            if (cho) { result.Chips += 120; result.Mult += 2; result.CompletedYokbo.Add("초단(草丹)"); }
            if (hong && cheong && cho) { result.Chips += 200; result.Mult += 4; result.CompletedYokbo.Add("삼단통!"); }
            if (r.Count >= 5) { int b = 50 + (r.Count - 5) * 20; result.Chips += b; result.CompletedYokbo.Add($"띠 {r.Count}장"); }
        }

        private bool HasSet(List<CardInstance> ribbons, RibbonType type, params CardMonth[] months)
        {
            foreach (var m in months)
                if (!ribbons.Any(r => r.Ribbon == type && r.Month == m)) return false;
            return true;
        }

        #endregion

        #region 열끗/피

        private void CalculateYeolkkeutScore(PlayerState player, ref ScoreResult result)
        {
            int c = player.CapturedYeolkkeut.Count;
            if (c >= 5) { result.Chips += 50 + (c - 5) * 20; result.CompletedYokbo.Add($"열끗 {c}장"); }
        }

        private void CalculatePiScore(PlayerState player, ref ScoreResult result)
        {
            int p = player.GetTotalPiCount();
            if (p >= 10) { result.Chips += 30 + (p - 10) * 10; result.CompletedYokbo.Add($"피 {p}장"); }
        }

        #endregion

        #region 고도리/총통

        private void CalculateGodori(PlayerState player, ref ScoreResult result)
        {
            var y = player.CapturedYeolkkeut;
            if (y.Any(c => c.Month == CardMonth.February) &&
                y.Any(c => c.Month == CardMonth.April) &&
                y.Any(c => c.Month == CardMonth.August))
            {
                result.Chips += 100; result.Mult += 2; result.CompletedYokbo.Add("고도리(高鳥)");
            }
        }

        private void CalculateChongtong(PlayerState player, ref ScoreResult result)
        {
            var all = new List<CardInstance>();
            all.AddRange(player.CapturedGwang); all.AddRange(player.CapturedTti);
            all.AddRange(player.CapturedYeolkkeut); all.AddRange(player.CapturedPi);
            var counts = new Dictionary<CardMonth, int>();
            foreach (var c in all) { if (!counts.ContainsKey(c.Month)) counts[c.Month] = 0; counts[c.Month]++; }
            foreach (var kv in counts)
                if (kv.Value >= 4)
                { result.Chips += 80; result.Mult += 2; result.CompletedYokbo.Add($"총통({(int)kv.Key}월)"); }
        }

        #endregion

        #region 저승 족보

        private void CalculateSpecialYokbo(PlayerState player, ref ScoreResult result)
        {
            var all = new List<CardInstance>();
            all.AddRange(player.CapturedGwang); all.AddRange(player.CapturedTti);
            all.AddRange(player.CapturedYeolkkeut); all.AddRange(player.CapturedPi);
            var months = new HashSet<CardMonth>();
            foreach (var c in all) months.Add(c.Month);

            // 사계
            if (months.Contains(CardMonth.March) && months.Contains(CardMonth.June) &&
                months.Contains(CardMonth.September) && months.Contains(CardMonth.December))
            { result.Chips += 100; result.Mult += 2; result.CompletedYokbo.Add("사계(四季)"); }

            // 월하독작
            if (player.CapturedGwang.Any(c => c.Month == CardMonth.August) &&
                player.CapturedYeolkkeut.Any(c => c.Month == CardMonth.September))
            { result.Chips += 50; result.Mult += 1; result.CompletedYokbo.Add("월하독작"); }

            // 선후착
            if (player.CapturedGwang.Any(c => c.Month == CardMonth.January) &&
                player.CapturedGwang.Any(c => c.Month == CardMonth.December))
            { result.Chips += 90; result.Mult += 2; result.CompletedYokbo.Add("선후착"); }

            // 도깨비불
            if (player.CapturedGwang.Count == 1 && player.GetTotalPiCount() >= 7)
            { result.Chips += 40; result.Mult += 1; result.CompletedYokbo.Add("도깨비불"); }
        }

        #endregion

        #region 고 배수

        private void ApplyGoMultiplier(PlayerState player, ref ScoreResult result)
        {
            switch (player.GoCount)
            {
                case 1: result.Mult *= 2; result.CompletedYokbo.Add("고 1회 (×2)"); break;
                case 2: result.Mult *= 4; result.CompletedYokbo.Add("고 2회 (×4)"); break;
                case >= 3: result.Mult *= 10; result.CompletedYokbo.Add($"고 {player.GoCount}회 (×10)"); break;
            }
        }

        #endregion
    }
}

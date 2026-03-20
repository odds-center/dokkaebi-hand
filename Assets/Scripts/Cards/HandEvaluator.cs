using System.Collections.Generic;
using System.Linq;

namespace DokkaebiHand.Cards
{
    public enum ComboTier { S, A, B, C, D }
    public enum ComboCategory { GoStop, Seotda, Seasonal, Jeoseung, MonthPair, Collection, Fallback }

    public class ComboResult
    {
        public string Id;
        public string NameKR;
        public string NameEN;
        public ComboTier Tier;
        public ComboCategory Category;
        public int Chips;
        public float Mult;
        public string Description;
        public int HealAmount;          // 회복량 (0이면 회복 없음)
        public bool HealRequiresHold;   // true면 다음 턴까지 유지해야 회복

        public override string ToString()
        {
            return $"[{Tier}] {NameKR} (Chips:{Chips} Mult:{Mult:F1})";
        }
    }

    /// <summary>
    /// 시너지 힌트: 현재 선택에서 추가 카드 조건을 만족하면 활성화될 수 있는 콤보
    /// </summary>
    public class SynergyHint
    {
        public string ComboNameKR;
        public string ComboNameEN;
        public ComboTier Tier;
        public string Condition;     // "3월 광 추가 시" 등
        public int EstimatedChips;
        public float EstimatedMult;

        public override string ToString()
        {
            return $"[{Tier}] {ComboNameKR} — {Condition} (칩:{EstimatedChips} 배:{EstimatedMult:F1})";
        }
    }

    /// <summary>
    /// 핸드 평가 엔진: 선택한 카드에서 모든 매칭 콤보를 찾아 반환.
    /// Balatro 스타일 - 여러 콤보가 동시에 스택 가능.
    /// 단, Seotda 카테고리는 최고 1개만 적용.
    /// </summary>
    public static class HandEvaluator
    {
        /// <summary>
        /// 선택한 카드들을 평가하여 매칭되는 모든 콤보를 반환 (티어순 정렬).
        /// </summary>
        public static List<ComboResult> Evaluate(List<CardInstance> selectedCards)
        {
            if (selectedCards == null || selectedCards.Count == 0)
                return new List<ComboResult>();

            var allCombos = new List<ComboResult>();

            // 기본 데이터 준비
            int cardCount = selectedCards.Count;
            var months = selectedCards.Select(c => c.Month).ToList();
            var distinctMonths = new HashSet<CardMonth>(months);
            var types = selectedCards.Select(c => c.Type).ToList();
            var ribbonTypes = selectedCards.Where(c => c.Type == CardType.Tti).Select(c => c.Ribbon).ToList();
            var gwangCards = selectedCards.Where(c => c.Type == CardType.Gwang).ToList();
            var ttiCards = selectedCards.Where(c => c.Type == CardType.Tti).ToList();
            var yeolkkeutCards = selectedCards.Where(c => c.Type == CardType.Yeolkkeut).ToList();
            var piCards = selectedCards.Where(c => c.Type == CardType.Pi).ToList();
            bool hasRainGwang = gwangCards.Any(c => c.IsRainGwang);

            // 월별 카운트
            var monthCounts = new Dictionary<CardMonth, int>();
            foreach (var m in months)
            {
                if (!monthCounts.ContainsKey(m)) monthCounts[m] = 0;
                monthCounts[m]++;
            }

            // 월별 합산 (끗 계산용) — 고유 월만 합산하여 중복 월 중복 계산 방지
            int monthSum = distinctMonths.Sum(m => (int)m);

            // =====================
            // Tier S 콤보
            // =====================

            // 오광: 5장 광
            if (gwangCards.Count >= 5)
            {
                allCombos.Add(new ComboResult
                {
                    Id = "ogwang", NameKR = "오광", NameEN = "Five Brights",
                    Tier = ComboTier.S, Category = ComboCategory.GoStop,
                    Chips = 500, Mult = 8f,
                    Description = "광 5장 모두 선택"
                });
            }

            // 38광땡: 3월 광 + 8월 광
            if (gwangCards.Any(c => c.Month == CardMonth.March) &&
                gwangCards.Any(c => c.Month == CardMonth.August))
            {
                allCombos.Add(new ComboResult
                {
                    Id = "38gwangttaeng", NameKR = "38광땡", NameEN = "3-8 Bright Pair",
                    Tier = ComboTier.S, Category = ComboCategory.Seotda,
                    Chips = 400, Mult = 6f,
                    Description = "3월 광 + 8월 광"
                });
            }

            // 황천의 다리: 12개 월 모두 포함 (불가능에 가까우나 설계대로)
            if (distinctMonths.Count >= 12)
            {
                allCombos.Add(new ComboResult
                {
                    Id = "hwangcheon_dari", NameKR = "황천의다리", NameEN = "Bridge of the Underworld",
                    Tier = ComboTier.S, Category = ComboCategory.Jeoseung,
                    Chips = 600, Mult = 10f,
                    Description = "12개월 패 모두 포함"
                });
            }

            // 삼단통: 홍단 + 청단 + 초단 모두 포함
            bool hasHongDan = HasRibbonSet(ttiCards, RibbonType.HongDan,
                CardMonth.January, CardMonth.February, CardMonth.March);
            bool hasCheongDan = HasRibbonSet(ttiCards, RibbonType.CheongDan,
                CardMonth.June, CardMonth.September, CardMonth.October);
            bool hasChoDan = HasRibbonSet(ttiCards, RibbonType.ChoDan,
                CardMonth.April, CardMonth.May, CardMonth.July);

            if (hasHongDan && hasCheongDan && hasChoDan)
            {
                allCombos.Add(new ComboResult
                {
                    Id = "samdantong", NameKR = "삼단통", NameEN = "Triple Ribbon Set",
                    Tier = ComboTier.S, Category = ComboCategory.GoStop,
                    Chips = 450, Mult = 7f,
                    Description = "홍단 + 청단 + 초단 모두 완성"
                });
            }

            // 윤회: 총통 3개 이상 (3개 이상 다른 월에서 4장씩)
            int chongtongCount = monthCounts.Count(kv => kv.Value >= 4);
            if (chongtongCount >= 3)
            {
                allCombos.Add(new ComboResult
                {
                    Id = "yunhoe", NameKR = "윤회", NameEN = "Samsara",
                    Tier = ComboTier.S, Category = ComboCategory.Jeoseung,
                    Chips = 500, Mult = 8f,
                    Description = "총통(같은 월 4장) 3세트 이상"
                });
            }

            // =====================
            // Tier A 콤보
            // =====================

            // 사광 (비광 없이 4광)
            if (gwangCards.Count == 4 && !hasRainGwang)
            {
                allCombos.Add(new ComboResult
                {
                    Id = "sagwang", NameKR = "사광", NameEN = "Four Brights",
                    Tier = ComboTier.A, Category = ComboCategory.GoStop,
                    Chips = 300, Mult = 5f,
                    Description = "비광 없이 광 4장"
                });
            }

            // 비사광 (비광 포함 4광)
            if (gwangCards.Count == 4 && hasRainGwang)
            {
                allCombos.Add(new ComboResult
                {
                    Id = "bisagwang", NameKR = "비사광", NameEN = "Rain Four Brights",
                    Tier = ComboTier.A, Category = ComboCategory.GoStop,
                    Chips = 250, Mult = 4f,
                    Description = "비광 포함 광 4장"
                });
            }

            // 13광땡
            if (gwangCards.Any(c => c.Month == CardMonth.January) &&
                gwangCards.Any(c => c.Month == CardMonth.March))
            {
                // 38광땡보다 하위이므로, 38이 아닌 경우만
                if (!allCombos.Any(c => c.Id == "38gwangttaeng"))
                {
                    allCombos.Add(new ComboResult
                    {
                        Id = "13gwangttaeng", NameKR = "13광땡", NameEN = "1-3 Bright Pair",
                        Tier = ComboTier.A, Category = ComboCategory.Seotda,
                        Chips = 300, Mult = 5f,
                        Description = "1월 광 + 3월 광"
                    });
                }
            }

            // 18광땡
            if (gwangCards.Any(c => c.Month == CardMonth.January) &&
                gwangCards.Any(c => c.Month == CardMonth.August))
            {
                if (!allCombos.Any(c => c.Id == "38gwangttaeng"))
                {
                    allCombos.Add(new ComboResult
                    {
                        Id = "18gwangttaeng", NameKR = "18광땡", NameEN = "1-8 Bright Pair",
                        Tier = ComboTier.A, Category = ComboCategory.Seotda,
                        Chips = 320, Mult = 5.5f,
                        Description = "1월 광 + 8월 광"
                    });
                }
            }

            // 장땡 (10월 페어)
            if (cardCount >= 2 && monthCounts.ContainsKey(CardMonth.October) && monthCounts[CardMonth.October] >= 2)
            {
                allCombos.Add(new ComboResult
                {
                    Id = "jangttaeng", NameKR = "장땡", NameEN = "Jang-ttaeng",
                    Tier = ComboTier.A, Category = ComboCategory.Seotda,
                    Chips = 250, Mult = 4.5f,
                    Description = "10월 패 2장"
                });
            }

            // 9땡
            if (cardCount >= 2 && monthCounts.ContainsKey(CardMonth.September) && monthCounts[CardMonth.September] >= 2)
            {
                allCombos.Add(new ComboResult
                {
                    Id = "9ttaeng", NameKR = "9땡", NameEN = "9-ttaeng",
                    Tier = ComboTier.A, Category = ComboCategory.Seotda,
                    Chips = 230, Mult = 4f,
                    Description = "9월 패 2장"
                });
            }

            // 8땡
            if (cardCount >= 2 && monthCounts.ContainsKey(CardMonth.August) && monthCounts[CardMonth.August] >= 2)
            {
                allCombos.Add(new ComboResult
                {
                    Id = "8ttaeng", NameKR = "8땡", NameEN = "8-ttaeng",
                    Tier = ComboTier.A, Category = ComboCategory.Seotda,
                    Chips = 210, Mult = 3.8f,
                    Description = "8월 패 2장"
                });
            }

            // 도깨비불: 광 3장 + 끗 5 (5장 이상 필요하겠지만 카드수 조건 맞으면)
            if (gwangCards.Count >= 3 && piCards.Count >= 5)
            {
                allCombos.Add(new ComboResult
                {
                    Id = "dokkaebi_bul", NameKR = "도깨비불", NameEN = "Dokkaebi Fire",
                    Tier = ComboTier.A, Category = ComboCategory.Jeoseung,
                    Chips = 200, Mult = 4f,
                    Description = "광 3장 + 피 5장 이상"
                });
            }

            // 저승꽃: 피 15장 이상
            int totalPiValue = piCards.Sum(c => c.GetPiValue());
            if (totalPiValue >= 15)
            {
                allCombos.Add(new ComboResult
                {
                    Id = "jeoseung_kkot", NameKR = "저승꽃", NameEN = "Flower of the Dead",
                    Tier = ComboTier.A, Category = ComboCategory.Jeoseung,
                    Chips = 200, Mult = 4f,
                    Description = "피 가치 합계 15 이상 (회복 +2)",
                    HealAmount = 2, HealRequiresHold = true
                });
            }

            // 삼도천: 3월 + 6월 + 9월 조합
            if (distinctMonths.Contains(CardMonth.March) &&
                distinctMonths.Contains(CardMonth.June) &&
                distinctMonths.Contains(CardMonth.September))
            {
                allCombos.Add(new ComboResult
                {
                    Id = "samdocheon", NameKR = "삼도천", NameEN = "Three-River Crossing",
                    Tier = ComboTier.A, Category = ComboCategory.Jeoseung,
                    Chips = 180, Mult = 3.5f,
                    Description = "3월 + 6월 + 9월 조합"
                });
            }

            // =====================
            // Tier B 콤보
            // =====================

            // 삼광 (비광 없이 3광)
            if (gwangCards.Count == 3 && !hasRainGwang)
            {
                allCombos.Add(new ComboResult
                {
                    Id = "samgwang", NameKR = "삼광", NameEN = "Three Brights",
                    Tier = ComboTier.B, Category = ComboCategory.GoStop,
                    Chips = 200, Mult = 3f,
                    Description = "비광 없이 광 3장"
                });
            }

            // 비광 (비광 포함 3광)
            if (gwangCards.Count == 3 && hasRainGwang)
            {
                allCombos.Add(new ComboResult
                {
                    Id = "bigwang", NameKR = "비광", NameEN = "Rain Three Brights",
                    Tier = ComboTier.B, Category = ComboCategory.GoStop,
                    Chips = 150, Mult = 2.5f,
                    Description = "비광 포함 광 3장"
                });
            }

            // 홍단: 1,2,3월 홍단 띠
            if (hasHongDan)
            {
                allCombos.Add(new ComboResult
                {
                    Id = "hongdan", NameKR = "홍단", NameEN = "Red Ribbons",
                    Tier = ComboTier.B, Category = ComboCategory.GoStop,
                    Chips = 150, Mult = 3f,
                    Description = "1월, 2월, 3월 홍단"
                });
            }

            // 청단: 6,9,10월 청단 띠
            if (hasCheongDan)
            {
                allCombos.Add(new ComboResult
                {
                    Id = "cheongdan", NameKR = "청단", NameEN = "Blue Ribbons",
                    Tier = ComboTier.B, Category = ComboCategory.GoStop,
                    Chips = 150, Mult = 3f,
                    Description = "6월, 9월, 10월 청단"
                });
            }

            // 초단: 4,5,7월 초단 띠
            if (hasChoDan)
            {
                allCombos.Add(new ComboResult
                {
                    Id = "chodan", NameKR = "초단", NameEN = "Plain Ribbons",
                    Tier = ComboTier.B, Category = ComboCategory.GoStop,
                    Chips = 150, Mult = 3f,
                    Description = "4월, 5월, 7월 초단"
                });
            }

            // 고도리: 2,4,8월 열끗
            if (yeolkkeutCards.Any(c => c.Month == CardMonth.February) &&
                yeolkkeutCards.Any(c => c.Month == CardMonth.April) &&
                yeolkkeutCards.Any(c => c.Month == CardMonth.August))
            {
                allCombos.Add(new ComboResult
                {
                    Id = "godori", NameKR = "고도리", NameEN = "Go-Dori",
                    Tier = ComboTier.B, Category = ComboCategory.GoStop,
                    Chips = 150, Mult = 3f,
                    Description = "2월, 4월, 8월 열끗"
                });
            }

            // 총통: 같은 월 4장
            foreach (var kv in monthCounts)
            {
                if (kv.Value >= 4)
                {
                    allCombos.Add(new ComboResult
                    {
                        Id = $"chongtong_{(int)kv.Key}", NameKR = $"총통({(int)kv.Key}월)",
                        NameEN = $"Chongtong ({(int)kv.Key})",
                        Tier = ComboTier.B, Category = ComboCategory.GoStop,
                        Chips = 120, Mult = 3f,
                        Description = $"{(int)kv.Key}월 패 4장 모두"
                    });
                }
            }

            // 7땡~1땡
            for (int m = 7; m >= 1; m--)
            {
                var cm = (CardMonth)m;
                if (monthCounts.ContainsKey(cm) && monthCounts[cm] >= 2)
                {
                    allCombos.Add(new ComboResult
                    {
                        Id = $"{m}ttaeng", NameKR = $"{m}땡", NameEN = $"{m}-ttaeng",
                        Tier = ComboTier.B, Category = ComboCategory.Seotda,
                        Chips = 100 + m * 10, Mult = 2f + m * 0.2f,
                        Description = $"{m}월 패 2장"
                    });
                }
            }

            // 알리: 1월 + 2월
            if (distinctMonths.Contains(CardMonth.January) && distinctMonths.Contains(CardMonth.February))
            {
                allCombos.Add(new ComboResult
                {
                    Id = "ali", NameKR = "알리", NameEN = "Ali",
                    Tier = ComboTier.B, Category = ComboCategory.Seotda,
                    Chips = 130, Mult = 2.8f,
                    Description = "1월 + 2월"
                });
            }

            // 독사: 1월 + 4월
            if (distinctMonths.Contains(CardMonth.January) && distinctMonths.Contains(CardMonth.April))
            {
                allCombos.Add(new ComboResult
                {
                    Id = "doksa", NameKR = "독사", NameEN = "Doksa",
                    Tier = ComboTier.B, Category = ComboCategory.Seotda,
                    Chips = 120, Mult = 2.6f,
                    Description = "1월 + 4월"
                });
            }

            // 구삥: 1월 + 9월
            if (distinctMonths.Contains(CardMonth.January) && distinctMonths.Contains(CardMonth.September))
            {
                allCombos.Add(new ComboResult
                {
                    Id = "gupping", NameKR = "구삥", NameEN = "Gupping",
                    Tier = ComboTier.B, Category = ComboCategory.Seotda,
                    Chips = 110, Mult = 2.5f,
                    Description = "1월 + 9월"
                });
            }

            // 사계: 3,6,9,12월
            if (distinctMonths.Contains(CardMonth.March) && distinctMonths.Contains(CardMonth.June) &&
                distinctMonths.Contains(CardMonth.September) && distinctMonths.Contains(CardMonth.December))
            {
                allCombos.Add(new ComboResult
                {
                    Id = "sagye", NameKR = "사계", NameEN = "Four Seasons",
                    Tier = ComboTier.B, Category = ComboCategory.Seasonal,
                    Chips = 150, Mult = 3f,
                    Description = "3월, 6월, 9월, 12월"
                });
            }

            // 선후착: 1월 광 + 12월 광
            if (gwangCards.Any(c => c.Month == CardMonth.January) &&
                gwangCards.Any(c => c.Month == CardMonth.December))
            {
                allCombos.Add(new ComboResult
                {
                    Id = "seonhuchak", NameKR = "선후착", NameEN = "First and Last",
                    Tier = ComboTier.B, Category = ComboCategory.Jeoseung,
                    Chips = 160, Mult = 3f,
                    Description = "1월 광 + 12월 광"
                });
            }

            // 봄의연회: 1,2,3월 카드 합 6장 이상 (5장 핸드로는 어려움)
            int springCount = months.Count(m => m == CardMonth.January || m == CardMonth.February || m == CardMonth.March);
            if (springCount >= 4 && distinctMonths.Contains(CardMonth.January) &&
                distinctMonths.Contains(CardMonth.February) && distinctMonths.Contains(CardMonth.March))
            {
                allCombos.Add(new ComboResult
                {
                    Id = "bom_yeonhoe", NameKR = "봄의연회", NameEN = "Spring Banquet",
                    Tier = ComboTier.B, Category = ComboCategory.Seasonal,
                    Chips = 140, Mult = 2.5f,
                    Description = "1월, 2월, 3월 카드 4장 이상 (회복 +1)",
                    HealAmount = 1, HealRequiresHold = true
                });
            }

            // 가을단풍: 8,9,10월 카드 합 6장 이상 (5장 핸드로 조정: 4장+)
            int autumnCount = months.Count(m => m == CardMonth.August || m == CardMonth.September || m == CardMonth.October);
            if (autumnCount >= 4 && distinctMonths.Contains(CardMonth.August) &&
                distinctMonths.Contains(CardMonth.September) && distinctMonths.Contains(CardMonth.October))
            {
                allCombos.Add(new ComboResult
                {
                    Id = "gaeul_danpung", NameKR = "가을단풍", NameEN = "Autumn Foliage",
                    Tier = ComboTier.B, Category = ComboCategory.Seasonal,
                    Chips = 140, Mult = 2.5f,
                    Description = "8월, 9월, 10월 카드 4장 이상"
                });
            }

            // =====================
            // Tier C 콤보
            // =====================

            // 장삥: 1월 + 10월
            if (distinctMonths.Contains(CardMonth.January) && distinctMonths.Contains(CardMonth.October))
            {
                allCombos.Add(new ComboResult
                {
                    Id = "jangpping", NameKR = "장삥", NameEN = "Jang-pping",
                    Tier = ComboTier.C, Category = ComboCategory.Seotda,
                    Chips = 80, Mult = 2f,
                    Description = "1월 + 10월"
                });
            }

            // 장사: 4월 + 10월
            if (distinctMonths.Contains(CardMonth.April) && distinctMonths.Contains(CardMonth.October))
            {
                allCombos.Add(new ComboResult
                {
                    Id = "jangsa", NameKR = "장사", NameEN = "Jang-sa",
                    Tier = ComboTier.C, Category = ComboCategory.Seotda,
                    Chips = 75, Mult = 1.9f,
                    Description = "4월 + 10월"
                });
            }

            // 세륙: 4월 + 6월
            if (distinctMonths.Contains(CardMonth.April) && distinctMonths.Contains(CardMonth.June))
            {
                allCombos.Add(new ComboResult
                {
                    Id = "seryuk", NameKR = "세륙", NameEN = "Se-ryuk",
                    Tier = ComboTier.C, Category = ComboCategory.Seotda,
                    Chips = 70, Mult = 1.8f,
                    Description = "4월 + 6월"
                });
            }

            // 띠 5장: 띠 카드 5장 이상
            if (ttiCards.Count >= 5)
            {
                allCombos.Add(new ComboResult
                {
                    Id = "tti5", NameKR = "띠5장", NameEN = "5 Ribbons",
                    Tier = ComboTier.C, Category = ComboCategory.Collection,
                    Chips = 80, Mult = 2f,
                    Description = "띠 5장 이상"
                });
            }

            // 열끗 5장: 열끗 5장 이상
            if (yeolkkeutCards.Count >= 5)
            {
                allCombos.Add(new ComboResult
                {
                    Id = "yeolkkeut5", NameKR = "열끗5장", NameEN = "5 Animals",
                    Tier = ComboTier.C, Category = ComboCategory.Collection,
                    Chips = 80, Mult = 2f,
                    Description = "열끗 5장 이상"
                });
            }

            // 피 10장 (가치 합계)
            if (totalPiValue >= 10)
            {
                allCombos.Add(new ComboResult
                {
                    Id = "pi10", NameKR = "피10장", NameEN = "10 Junk",
                    Tier = ComboTier.C, Category = ComboCategory.Collection,
                    Chips = 60, Mult = 1.5f,
                    Description = "피 가치 합계 10 이상"
                });
            }

            // 월하독작: 8월 광 + 9월 열끗
            if (gwangCards.Any(c => c.Month == CardMonth.August) &&
                yeolkkeutCards.Any(c => c.Month == CardMonth.September))
            {
                allCombos.Add(new ComboResult
                {
                    Id = "wolha_dokjak", NameKR = "월하독작", NameEN = "Moonlit Drink",
                    Tier = ComboTier.C, Category = ComboCategory.Jeoseung,
                    Chips = 90, Mult = 2f,
                    Description = "8월 광 + 9월 열끗 (회복 +1)",
                    HealAmount = 1, HealRequiresHold = true
                });
            }

            // 끗 9~5: 선택된 카드 월 합 끝자리
            int kkeut = monthSum % 10;

            if (kkeut >= 5 && kkeut <= 9 && cardCount >= 2)
            {
                allCombos.Add(new ComboResult
                {
                    Id = $"kkeut{kkeut}", NameKR = $"끗{kkeut}", NameEN = $"{kkeut}-Kkeut",
                    Tier = ComboTier.C, Category = ComboCategory.Seotda,
                    Chips = 30 + kkeut * 5, Mult = 1f + kkeut * 0.1f,
                    Description = $"월 합 끝자리 {kkeut}"
                });
            }

            // 월합: 같은 월 2장
            foreach (var kv in monthCounts)
            {
                if (kv.Value == 2)
                {
                    allCombos.Add(new ComboResult
                    {
                        Id = $"wolhap_{(int)kv.Key}", NameKR = $"월합({(int)kv.Key}월)",
                        NameEN = $"Month Pair ({(int)kv.Key})",
                        Tier = ComboTier.C, Category = ComboCategory.MonthPair,
                        Chips = 40, Mult = 1.5f,
                        Description = $"{(int)kv.Key}월 패 2장"
                    });
                }
            }

            // 월삼: 같은 월 3장
            foreach (var kv in monthCounts)
            {
                if (kv.Value == 3)
                {
                    allCombos.Add(new ComboResult
                    {
                        Id = $"wolsam_{(int)kv.Key}", NameKR = $"월삼({(int)kv.Key}월)",
                        NameEN = $"Month Triple ({(int)kv.Key})",
                        Tier = ComboTier.C, Category = ComboCategory.MonthPair,
                        Chips = 70, Mult = 2f,
                        Description = $"{(int)kv.Key}월 패 3장"
                    });
                }
            }

            // 여름 시즌: 6,7,8월 카드 3장+
            int summerCount = months.Count(m => m == CardMonth.June || m == CardMonth.July || m == CardMonth.August);
            if (summerCount >= 3 && distinctMonths.Contains(CardMonth.June) &&
                distinctMonths.Contains(CardMonth.July) && distinctMonths.Contains(CardMonth.August))
            {
                allCombos.Add(new ComboResult
                {
                    Id = "summer", NameKR = "여름바람", NameEN = "Summer Breeze",
                    Tier = ComboTier.C, Category = ComboCategory.Seasonal,
                    Chips = 60, Mult = 1.5f,
                    Description = "6월, 7월, 8월 카드"
                });
            }

            // 겨울 시즌: 11,12월
            if (distinctMonths.Contains(CardMonth.November) && distinctMonths.Contains(CardMonth.December))
            {
                allCombos.Add(new ComboResult
                {
                    Id = "winter", NameKR = "겨울한파", NameEN = "Winter Chill",
                    Tier = ComboTier.C, Category = ComboCategory.Seasonal,
                    Chips = 50, Mult = 1.5f,
                    Description = "11월 + 12월"
                });
            }

            // =====================
            // Tier C: 저승 오리지널 (나머지)
            // =====================

            // 염라의심판: 1월 광 + 11월 광
            if (gwangCards.Any(c => c.Month == CardMonth.January) &&
                gwangCards.Any(c => c.Month == CardMonth.November))
            {
                allCombos.Add(new ComboResult
                {
                    Id = "yeomra_simpan", NameKR = "염라의심판", NameEN = "Yeomra's Judgment",
                    Tier = ComboTier.C, Category = ComboCategory.Jeoseung,
                    Chips = 100, Mult = 2.2f,
                    Description = "1월 광 + 11월 광"
                });
            }

            // 저승길: 12월 + 11월 + 아무 피
            if (distinctMonths.Contains(CardMonth.December) &&
                distinctMonths.Contains(CardMonth.November) &&
                piCards.Count >= 1)
            {
                allCombos.Add(new ComboResult
                {
                    Id = "jeoseung_gil", NameKR = "저승길", NameEN = "Path to Underworld",
                    Tier = ComboTier.C, Category = ComboCategory.Jeoseung,
                    Chips = 70, Mult = 1.8f,
                    Description = "11월 + 12월 + 피"
                });
            }

            // 귀화: 12월 비 광 + 1월 광
            if (selectedCards.Any(c => c.IsRainGwang) &&
                gwangCards.Any(c => c.Month == CardMonth.January))
            {
                allCombos.Add(new ComboResult
                {
                    Id = "gwihwa", NameKR = "귀화", NameEN = "Naturalization",
                    Tier = ComboTier.C, Category = ComboCategory.Jeoseung,
                    Chips = 90, Mult = 2f,
                    Description = "비광 + 1월 광"
                });
            }

            // 혼백분리: 광 1장 + 피 3장 이상
            if (gwangCards.Count == 1 && piCards.Count >= 3)
            {
                allCombos.Add(new ComboResult
                {
                    Id = "honbaek_bunri", NameKR = "혼백분리", NameEN = "Soul Separation",
                    Tier = ComboTier.C, Category = ComboCategory.Jeoseung,
                    Chips = 60, Mult = 1.8f,
                    Description = "광 1장 + 피 3장"
                });
            }

            // 업경대: 3장 이상, 모든 카드 다른 타입
            if (cardCount >= 3)
            {
                var distinctTypes = new HashSet<CardType>(types);
                if (distinctTypes.Count >= 3)
                {
                    allCombos.Add(new ComboResult
                    {
                        Id = "eopgyeongdae", NameKR = "업경대", NameEN = "Karma Mirror",
                        Tier = ComboTier.C, Category = ComboCategory.Jeoseung,
                        Chips = 50, Mult = 1.6f,
                        Description = "3가지 이상 다른 타입의 카드"
                    });
                }
            }

            // 도깨비방망이: 열끗 3장 이상
            if (yeolkkeutCards.Count >= 3)
            {
                allCombos.Add(new ComboResult
                {
                    Id = "dokkaebi_bangmangi", NameKR = "도깨비방망이", NameEN = "Dokkaebi Club",
                    Tier = ComboTier.C, Category = ComboCategory.Jeoseung,
                    Chips = 80, Mult = 1.8f,
                    Description = "열끗 3장 이상"
                });
            }

            // 피바다: 피 5장 이상
            if (piCards.Count >= 5)
            {
                allCombos.Add(new ComboResult
                {
                    Id = "pibada", NameKR = "피바다", NameEN = "Sea of Blood",
                    Tier = ComboTier.C, Category = ComboCategory.Jeoseung,
                    Chips = 70, Mult = 1.7f,
                    Description = "피 5장 이상"
                });
            }

            // 무상: 모든 카드 다른 월 (3장+)
            if (cardCount >= 3 && distinctMonths.Count == cardCount)
            {
                allCombos.Add(new ComboResult
                {
                    Id = "musang", NameKR = "무상", NameEN = "Impermanence",
                    Tier = ComboTier.C, Category = ComboCategory.Jeoseung,
                    Chips = 50, Mult = 1.5f,
                    Description = "모든 카드 다른 월"
                });
            }

            // 꽃비: 띠 2장 + 피 2장 이상
            if (ttiCards.Count >= 2 && piCards.Count >= 2)
            {
                allCombos.Add(new ComboResult
                {
                    Id = "kkotbi", NameKR = "꽃비", NameEN = "Flower Rain",
                    Tier = ComboTier.C, Category = ComboCategory.Jeoseung,
                    Chips = 50, Mult = 1.5f,
                    Description = "띠 2장 + 피 2장 (회복 +1)",
                    HealAmount = 1, HealRequiresHold = true
                });
            }

            // 귀문관: 12월 카드 2장 이상
            if (monthCounts.ContainsKey(CardMonth.December) && monthCounts[CardMonth.December] >= 2)
            {
                allCombos.Add(new ComboResult
                {
                    Id = "gwimungwan", NameKR = "귀문관", NameEN = "Ghost Gate",
                    Tier = ComboTier.C, Category = ComboCategory.Jeoseung,
                    Chips = 60, Mult = 1.6f,
                    Description = "12월 패 2장 이상"
                });
            }

            // =====================
            // Tier D 콤보
            // =====================

            // 끗 4~1
            if (kkeut >= 1 && kkeut <= 4 && cardCount >= 2)
            {
                allCombos.Add(new ComboResult
                {
                    Id = $"kkeut{kkeut}_low", NameKR = $"끗{kkeut}", NameEN = $"{kkeut}-Kkeut",
                    Tier = ComboTier.D, Category = ComboCategory.Seotda,
                    Chips = 15 + kkeut * 3, Mult = 1f + kkeut * 0.05f,
                    Description = $"월 합 끝자리 {kkeut}"
                });
            }

            // 망통: 합 끝자리 0
            if (kkeut == 0 && cardCount >= 2)
            {
                allCombos.Add(new ComboResult
                {
                    Id = "mangtong", NameKR = "망통", NameEN = "Mang-tong",
                    Tier = ComboTier.D, Category = ComboCategory.Seotda,
                    Chips = 10, Mult = 0.5f,
                    Description = "월 합 끝자리 0 (최악)"
                });
            }

            // 단일패: 1장만 선택
            if (cardCount == 1)
            {
                allCombos.Add(new ComboResult
                {
                    Id = "single", NameKR = "단일패", NameEN = "Single Card",
                    Tier = ComboTier.D, Category = ComboCategory.Fallback,
                    Chips = selectedCards[0].BasePoints, Mult = 1f,
                    Description = "카드 1장 (콤보 없음)"
                });
            }

            // 피짝: 피만 있고 다른 콤보 없음
            if (piCards.Count == cardCount && cardCount >= 2)
            {
                // 다른 콤보가 없는지는 나중에 필터로 확인
                allCombos.Add(new ComboResult
                {
                    Id = "pijjak", NameKR = "피짝", NameEN = "Junk Only",
                    Tier = ComboTier.D, Category = ComboCategory.Fallback,
                    Chips = totalPiValue * 3, Mult = 1f,
                    Description = "피만으로 구성"
                });
            }

            // =====================
            // Seotda 카테고리 최고 1개만 남기기
            // =====================
            allCombos = FilterBestSeotda(allCombos);

            // 티어순 정렬 (S > A > B > C > D)
            allCombos.Sort((a, b) =>
            {
                int tierComp = a.Tier.CompareTo(b.Tier);
                if (tierComp != 0) return tierComp;
                // 같은 티어 내에서는 Chips * Mult 역순
                float scoreA = a.Chips * a.Mult;
                float scoreB = b.Chips * b.Mult;
                return scoreB.CompareTo(scoreA);
            });

            return allCombos;
        }

        /// <summary>
        /// 모든 콤보의 칩/멀트 합산
        /// 칩은 합산, 멀트는 곱산
        /// </summary>
        public static (int totalChips, float totalMult) GetTotalScore(List<ComboResult> combos)
        {
            if (combos == null || combos.Count == 0)
                return (0, 1f);

            int totalChips = 0;
            float totalMult = 1f;

            foreach (var combo in combos)
            {
                totalChips += combo.Chips;
                totalMult *= combo.Mult;
            }

            return (totalChips, totalMult);
        }

        /// <summary>
        /// Seotda 카테고리 내 최고 등급 1개만 남기고 나머지 Seotda 제거
        /// </summary>
        private static List<ComboResult> FilterBestSeotda(List<ComboResult> combos)
        {
            var seotdaCombos = combos.Where(c => c.Category == ComboCategory.Seotda).ToList();
            if (seotdaCombos.Count <= 1) return combos;

            // 최고 Seotda 찾기 (티어 → 칩*멀트 순)
            ComboResult best = null;
            float bestScore = -1f;
            foreach (var s in seotdaCombos)
            {
                int tierValue = s.Tier switch
                {
                    ComboTier.S => 10000,
                    ComboTier.A => 1000,
                    ComboTier.B => 100,
                    ComboTier.C => 10,
                    _ => 1
                };
                float score = tierValue + s.Chips * s.Mult;
                if (score > bestScore)
                {
                    bestScore = score;
                    best = s;
                }
            }

            // best 외 Seotda 제거
            var result = new List<ComboResult>();
            foreach (var c in combos)
            {
                if (c.Category == ComboCategory.Seotda && c != best)
                    continue;
                result.Add(c);
            }

            return result;
        }

        /// <summary>
        /// 시너지 미리보기: 현재 선택된 카드 기반으로 "이런 카드를 추가하면 이런 시너지 가능" 힌트 반환.
        /// UI에서 카드 선택 중 실시간으로 호출하여 표시.
        /// </summary>
        public static List<SynergyHint> PreviewSynergies(List<CardInstance> selectedCards, List<CardInstance> remainingHand)
        {
            var hints = new List<SynergyHint>();
            if (selectedCards == null || selectedCards.Count == 0 || remainingHand == null)
                return hints;

            // 현재 선택 상태 분석
            var currentMonths = new HashSet<CardMonth>(selectedCards.Select(c => c.Month));
            var currentGwang = selectedCards.Where(c => c.Type == CardType.Gwang).ToList();
            var currentTti = selectedCards.Where(c => c.Type == CardType.Tti).ToList();
            var currentYeol = selectedCards.Where(c => c.Type == CardType.Yeolkkeut).ToList();
            var currentPi = selectedCards.Where(c => c.Type == CardType.Pi).ToList();

            // 현재 완성된 콤보 ID 목록 (이미 완성된 건 힌트 불필요)
            var currentCombos = Evaluate(selectedCards);
            var completedIds = new HashSet<string>(currentCombos.Select(c => c.Id));

            // === 광 시너지 힌트 ===
            if (currentGwang.Count >= 1 && currentGwang.Count < 3)
            {
                var missingGwang = remainingHand.Where(c => c.Type == CardType.Gwang && !selectedCards.Contains(c)).ToList();
                if (missingGwang.Count > 0 && currentGwang.Count + missingGwang.Count >= 3)
                {
                    var neededMonths = string.Join(", ", missingGwang.Select(c => $"{(int)c.Month}월"));
                    hints.Add(new SynergyHint
                    {
                        ComboNameKR = currentGwang.Count == 2 ? "삼광" : "쌍광 → 삼광",
                        ComboNameEN = "Three Brights",
                        Tier = ComboTier.B,
                        Condition = $"광 추가 가능: {neededMonths}",
                        EstimatedChips = 200, EstimatedMult = 3f
                    });
                }
            }

            // 38광땡 힌트
            if (!completedIds.Contains("38gwangttaeng"))
            {
                bool has3 = currentGwang.Any(c => c.Month == CardMonth.March);
                bool has8 = currentGwang.Any(c => c.Month == CardMonth.August);
                if (has3 && !has8 && remainingHand.Any(c => c.Type == CardType.Gwang && c.Month == CardMonth.August))
                {
                    hints.Add(new SynergyHint
                    {
                        ComboNameKR = "38광땡", ComboNameEN = "3-8 Bright Pair",
                        Tier = ComboTier.S, Condition = "8월 광 추가 시",
                        EstimatedChips = 400, EstimatedMult = 6f
                    });
                }
                else if (has8 && !has3 && remainingHand.Any(c => c.Type == CardType.Gwang && c.Month == CardMonth.March))
                {
                    hints.Add(new SynergyHint
                    {
                        ComboNameKR = "38광땡", ComboNameEN = "3-8 Bright Pair",
                        Tier = ComboTier.S, Condition = "3월 광 추가 시",
                        EstimatedChips = 400, EstimatedMult = 6f
                    });
                }
            }

            // === 띠 시너지 힌트 ===
            CheckRibbonHint(hints, currentTti, remainingHand, selectedCards,
                RibbonType.HongDan, new[] { CardMonth.January, CardMonth.February, CardMonth.March },
                "홍단", "Red Ribbons", completedIds.Contains("hongdan"));
            CheckRibbonHint(hints, currentTti, remainingHand, selectedCards,
                RibbonType.CheongDan, new[] { CardMonth.June, CardMonth.September, CardMonth.October },
                "청단", "Blue Ribbons", completedIds.Contains("cheongdan"));
            CheckRibbonHint(hints, currentTti, remainingHand, selectedCards,
                RibbonType.ChoDan, new[] { CardMonth.April, CardMonth.May, CardMonth.July },
                "초단", "Plain Ribbons", completedIds.Contains("chodan"));

            // === 고도리 힌트 ===
            if (!completedIds.Contains("godori"))
            {
                var godoriMonths = new[] { CardMonth.February, CardMonth.April, CardMonth.August };
                int godoriHave = godoriMonths.Count(m => currentYeol.Any(c => c.Month == m));
                if (godoriHave >= 1 && godoriHave < 3)
                {
                    var missing = godoriMonths.Where(m => !currentYeol.Any(c => c.Month == m))
                        .Where(m => remainingHand.Any(c => c.Type == CardType.Yeolkkeut && c.Month == m && !selectedCards.Contains(c)));
                    if (missing.Any())
                    {
                        var neededStr = string.Join(", ", missing.Select(m => $"{(int)m}월 열끗"));
                        hints.Add(new SynergyHint
                        {
                            ComboNameKR = "고도리", ComboNameEN = "Go-Dori",
                            Tier = ComboTier.B, Condition = $"{neededStr} 추가 시",
                            EstimatedChips = 150, EstimatedMult = 3f
                        });
                    }
                }
            }

            // === 땡 힌트 ===
            var monthCounts = new Dictionary<CardMonth, int>();
            foreach (var c in selectedCards)
            {
                if (!monthCounts.ContainsKey(c.Month)) monthCounts[c.Month] = 0;
                monthCounts[c.Month]++;
            }
            foreach (var kv in monthCounts)
            {
                if (kv.Value == 1) // 같은 월 1장 → 1장 더 있으면 땡
                {
                    var pairCandidate = remainingHand.FirstOrDefault(c => c.Month == kv.Key && !selectedCards.Contains(c));
                    if (pairCandidate != null)
                    {
                        int m = (int)kv.Key;
                        string name = m == 10 ? "장땡" : $"{m}땡";
                        ComboTier tier = m >= 8 ? ComboTier.A : ComboTier.B;
                        hints.Add(new SynergyHint
                        {
                            ComboNameKR = name, ComboNameEN = $"{m}-ttaeng",
                            Tier = tier, Condition = $"{m}월 패 추가 시",
                            EstimatedChips = m >= 8 ? 210 + (m - 8) * 20 : 100 + m * 10,
                            EstimatedMult = m >= 8 ? 3.8f + (m - 8) * 0.35f : 2f + m * 0.2f
                        });
                    }
                }
            }

            // === 사계 힌트 ===
            if (!completedIds.Contains("sagye"))
            {
                var sagyeMonths = new[] { CardMonth.March, CardMonth.June, CardMonth.September, CardMonth.December };
                int sagyeHave = sagyeMonths.Count(m => currentMonths.Contains(m));
                if (sagyeHave >= 2 && sagyeHave < 4)
                {
                    var missing = sagyeMonths.Where(m => !currentMonths.Contains(m))
                        .Where(m => remainingHand.Any(c => c.Month == m && !selectedCards.Contains(c)));
                    if (missing.Count() + sagyeHave >= 4)
                    {
                        var neededStr = string.Join(", ", missing.Select(m => $"{(int)m}월"));
                        hints.Add(new SynergyHint
                        {
                            ComboNameKR = "사계", ComboNameEN = "Four Seasons",
                            Tier = ComboTier.B, Condition = $"{neededStr} 추가 시",
                            EstimatedChips = 150, EstimatedMult = 3f
                        });
                    }
                }
            }

            // === 월하독작 힌트 ===
            if (!completedIds.Contains("wolha_dokjak"))
            {
                bool has8Gwang = currentGwang.Any(c => c.Month == CardMonth.August);
                bool has9Yeol = currentYeol.Any(c => c.Month == CardMonth.September);
                if (has8Gwang && !has9Yeol && remainingHand.Any(c => c.Type == CardType.Yeolkkeut && c.Month == CardMonth.September && !selectedCards.Contains(c)))
                {
                    hints.Add(new SynergyHint
                    {
                        ComboNameKR = "월하독작", ComboNameEN = "Moonlit Drink",
                        Tier = ComboTier.C, Condition = "9월 열끗 추가 시 (회복 +1)",
                        EstimatedChips = 90, EstimatedMult = 2f
                    });
                }
                else if (has9Yeol && !has8Gwang && remainingHand.Any(c => c.Type == CardType.Gwang && c.Month == CardMonth.August && !selectedCards.Contains(c)))
                {
                    hints.Add(new SynergyHint
                    {
                        ComboNameKR = "월하독작", ComboNameEN = "Moonlit Drink",
                        Tier = ComboTier.C, Condition = "8월 광 추가 시 (회복 +1)",
                        EstimatedChips = 90, EstimatedMult = 2f
                    });
                }
            }

            // === 삼도천 힌트 ===
            if (!completedIds.Contains("samdocheon"))
            {
                var samdoMonths = new[] { CardMonth.March, CardMonth.June, CardMonth.September };
                int samdoHave = samdoMonths.Count(m => currentMonths.Contains(m));
                if (samdoHave >= 1 && samdoHave < 3)
                {
                    var missing = samdoMonths.Where(m => !currentMonths.Contains(m))
                        .Where(m => remainingHand.Any(c => c.Month == m && !selectedCards.Contains(c)));
                    if (missing.Count() + samdoHave >= 3)
                    {
                        var neededStr = string.Join(", ", missing.Select(m => $"{(int)m}월"));
                        hints.Add(new SynergyHint
                        {
                            ComboNameKR = "삼도천", ComboNameEN = "Three-River Crossing",
                            Tier = ComboTier.A, Condition = $"{neededStr} 추가 시",
                            EstimatedChips = 180, EstimatedMult = 3.5f
                        });
                    }
                }
            }

            // 티어순 정렬 (높은 것 먼저)
            hints.Sort((a, b) => a.Tier.CompareTo(b.Tier));

            return hints;
        }

        /// <summary>
        /// 띠 세트 힌트 체크 헬퍼
        /// </summary>
        private static void CheckRibbonHint(List<SynergyHint> hints,
            List<CardInstance> currentTti, List<CardInstance> remainingHand,
            List<CardInstance> selectedCards,
            RibbonType ribbonType, CardMonth[] requiredMonths,
            string nameKR, string nameEN, bool alreadyCompleted)
        {
            if (alreadyCompleted) return;

            int have = requiredMonths.Count(m => currentTti.Any(c => c.Ribbon == ribbonType && c.Month == m));
            if (have == 0) return;

            var missing = requiredMonths.Where(m => !currentTti.Any(c => c.Ribbon == ribbonType && c.Month == m))
                .Where(m => remainingHand.Any(c => c.Ribbon == ribbonType && c.Month == m && !selectedCards.Contains(c)));

            if (have + missing.Count() >= requiredMonths.Length)
            {
                var neededStr = string.Join(", ", missing.Select(m => $"{(int)m}월 {ribbonType}"));
                hints.Add(new SynergyHint
                {
                    ComboNameKR = nameKR, ComboNameEN = nameEN,
                    Tier = ComboTier.B, Condition = $"{neededStr} 추가 시",
                    EstimatedChips = 150, EstimatedMult = 3f
                });
            }
        }

        private static bool HasRibbonSet(List<CardInstance> ttiCards, RibbonType type, params CardMonth[] months)
        {
            foreach (var m in months)
            {
                if (!ttiCards.Any(c => c.Ribbon == type && c.Month == m))
                    return false;
            }
            return true;
        }
    }
}

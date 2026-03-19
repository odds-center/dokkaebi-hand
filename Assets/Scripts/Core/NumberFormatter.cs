namespace DokkaebiHand.Core
{
    /// <summary>
    /// 큰 숫자 단축 표기.
    /// 1,234 → "1,234"
    /// 12,345 → "12.3K"
    /// 1,234,567 → "1.23M"
    /// 1,234,567,890 → "1.23B"
    ///
    /// 과학적 표기:
    /// 12,345 → "1.23e4"
    /// </summary>
    public static class NumberFormatter
    {
        /// <summary>
        /// 기본 단축 표기 (K/M/B)
        /// </summary>
        public static string Format(long number)
        {
            if (number < 0) return "-" + Format(-number);

            if (number < 10_000)
                return number.ToString("N0");

            if (number < 1_000_000)
                return (number / 1000f).ToString("0.#") + "K";

            if (number < 1_000_000_000)
                return (number / 1_000_000f).ToString("0.##") + "M";

            if (number < 1_000_000_000_000L)
                return (number / 1_000_000_000f).ToString("0.##") + "B";

            return (number / 1_000_000_000_000f).ToString("0.##") + "T";
        }

        /// <summary>
        /// int 오버로드
        /// </summary>
        public static string Format(int number)
        {
            return Format((long)number);
        }

        /// <summary>
        /// 과학적 표기 (e 표기법)
        /// 12345 → "1.23e4"
        /// </summary>
        public static string FormatScientific(long number)
        {
            if (number < 0) return "-" + FormatScientific(-number);
            if (number < 10_000) return number.ToString("N0");

            int exponent = 0;
            double mantissa = number;
            while (mantissa >= 10)
            {
                mantissa /= 10;
                exponent++;
            }

            return $"{mantissa:0.00}e{exponent}";
        }

        /// <summary>
        /// 점수용 표기: 작은 수는 그대로, 큰 수는 단축
        /// 350 → "350"
        /// 1,440 → "1,440"
        /// 42,000 → "42K"
        /// 1,200,000 → "1.2M"
        /// </summary>
        public static string FormatScore(int score)
        {
            if (score < 100_000)
                return score.ToString("N0");
            return Format(score);
        }

        /// <summary>
        /// 배수 표기: ×2, ×10, ×1.5K
        /// </summary>
        public static string FormatMult(int mult)
        {
            if (mult < 10_000)
                return $"×{mult:N0}";
            return $"×{Format(mult)}";
        }

        /// <summary>
        /// 엽전/영혼 표기
        /// </summary>
        public static string FormatCurrency(int amount)
        {
            return Format(amount);
        }
    }
}

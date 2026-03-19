namespace DokkaebiHand.Core
{
    /// <summary>
    /// 런 종료 시 영혼 조각 보상 계산
    /// </summary>
    public static class SoulFragmentCalculator
    {
        /// <summary>
        /// 보스 격파 시 영혼 조각
        /// </summary>
        public static int ForBossDefeat(int absoluteRealm, int partsCount, bool hasSetBonus)
        {
            int baseReward = absoluteRealm <= 10 ? 10 + absoluteRealm * 2 : 20 + absoluteRealm;
            float partsMultiplier = 1f + partsCount * 0.25f;
            if (hasSetBonus) partsMultiplier += 0.5f;
            return (int)(baseReward * partsMultiplier);
        }

        /// <summary>
        /// Go 3회 성공 보너스
        /// </summary>
        public static int ForTripleGo()
        {
            return 50;
        }

        /// <summary>
        /// 나선 완료 보너스
        /// </summary>
        public static int ForSpiralComplete(int spiralNumber)
        {
            if (spiralNumber == 1) return 100;
            return 50 + spiralNumber * 20;
        }

        /// <summary>
        /// 런 실패 시 감소 (70% 유지)
        /// </summary>
        public static int ApplyDeathPenalty(int totalEarned)
        {
            return (int)(totalEarned * 0.7f);
        }
    }
}

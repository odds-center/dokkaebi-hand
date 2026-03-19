using DokkaebiHand.Core;

namespace DokkaebiHand.Cards
{
    /// <summary>
    /// Go/Stop 선택 로직 및 리스크 적용
    /// </summary>
    public class GoStopDecision
    {
        private readonly ScoringEngine _scoringEngine;

        public struct GoRisk
        {
            public int MultiplierBonus;     // 배수 보너스
            public float NextTargetMult;    // 다음 라운드 목표 점수 배율
            public int HandPenalty;         // 다음 라운드 손패 감소
            public bool InstantDeathOnFail; // 실패 시 즉사
            public bool LegendaryReward;    // 전설 부적 보상
        }

        public GoStopDecision(ScoringEngine scoringEngine)
        {
            _scoringEngine = scoringEngine;
        }

        /// <summary>
        /// 현재 Go 횟수에 따른 리스크 정보
        /// </summary>
        public GoRisk GetGoRisk(int currentGoCount)
        {
            int nextGo = currentGoCount + 1;
            return nextGo switch
            {
                1 => new GoRisk
                {
                    MultiplierBonus = 2,
                    NextTargetMult = 1.5f,
                    HandPenalty = 0,
                    InstantDeathOnFail = false,
                    LegendaryReward = false
                },
                2 => new GoRisk
                {
                    MultiplierBonus = 4,
                    NextTargetMult = 1.0f,
                    HandPenalty = 1,
                    InstantDeathOnFail = false,
                    LegendaryReward = false
                },
                _ => new GoRisk
                {
                    MultiplierBonus = 10,
                    NextTargetMult = 1.0f,
                    HandPenalty = 0,
                    InstantDeathOnFail = true,
                    LegendaryReward = true
                }
            };
        }

        /// <summary>
        /// Go 선택 실행
        /// </summary>
        public void ExecuteGo(PlayerState player)
        {
            player.GoCount++;
        }

        /// <summary>
        /// Stop 선택 → 최종 점수 확정
        /// </summary>
        public ScoringEngine.ScoreResult ExecuteStop(PlayerState player)
        {
            return _scoringEngine.CalculateScore(player);
        }

        /// <summary>
        /// 현재 점수가 기본 Go 가능 점수(7점 이상)를 넘었는지
        /// </summary>
        public bool CanGoOrStop(PlayerState player)
        {
            var score = _scoringEngine.CalculateScore(player);
            return score.FinalScore > 0;
        }
    }
}

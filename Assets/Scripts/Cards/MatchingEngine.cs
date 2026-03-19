using System;
using System.Collections.Generic;

namespace DokkaebiHand.Cards
{
    /// <summary>
    /// 패 매칭 엔진: 같은 월 매칭 판정
    /// </summary>
    public enum MatchResult
    {
        NoMatch,        // 바닥에 같은 월 없음 → 카드를 바닥에 놓음
        SingleMatch,    // 바닥에 같은 월 1장 → 가져감
        DoubleMatch,    // 바닥에 같은 월 2장 → 하나 선택
        TripleMatch     // 바닥에 같은 월 3장 → 전부 가져감 (뻑 = 쓸)
    }

    public class MatchingEngine
    {
        private readonly DeckManager _deckManager;

        // 이벤트: 부적/시스템 연동용
        public event Action<CardInstance, List<CardInstance>> OnMatchSuccess;
        public event Action<CardInstance> OnMatchFail;

        public MatchingEngine(DeckManager deckManager)
        {
            _deckManager = deckManager;
        }

        /// <summary>
        /// 손패에서 낸 카드의 매칭 결과 판정
        /// </summary>
        public MatchResult EvaluateMatch(CardInstance playedCard)
        {
            var fieldMatches = _deckManager.GetFieldCardsByMonth(playedCard.Month);

            switch (fieldMatches.Count)
            {
                case 0: return MatchResult.NoMatch;
                case 1: return MatchResult.SingleMatch;
                case 2: return MatchResult.DoubleMatch;
                case 3: return MatchResult.TripleMatch;
                default: return MatchResult.NoMatch;
            }
        }

        /// <summary>
        /// 매칭 실행: 카드 내기 → 바닥 매칭 → 획득
        /// NoMatch: 바닥에 놓기
        /// SingleMatch: 해당 카드와 함께 획득
        /// TripleMatch: 3장 모두 획득
        /// DoubleMatch: selectedMatch로 지정된 카드와 획득 (플레이어 선택 필요)
        /// </summary>
        public List<CardInstance> ExecuteMatch(CardInstance playedCard, CardInstance selectedMatch = null)
        {
            var captured = new List<CardInstance>();
            var fieldMatches = _deckManager.GetFieldCardsByMonth(playedCard.Month);

            switch (fieldMatches.Count)
            {
                case 0:
                    // 바닥에 놓기
                    _deckManager.AddToField(playedCard);
                    break;

                case 1:
                    // 1장 매칭 → 둘 다 획득
                    captured.Add(playedCard);
                    captured.Add(fieldMatches[0]);
                    _deckManager.RemoveFromField(fieldMatches[0]);
                    break;

                case 2:
                    // 2장 매칭 → 플레이어가 선택한 1장과 획득
                    if (selectedMatch != null && fieldMatches.Contains(selectedMatch))
                    {
                        captured.Add(playedCard);
                        captured.Add(selectedMatch);
                        _deckManager.RemoveFromField(selectedMatch);
                    }
                    else
                    {
                        // 선택이 없으면 첫 번째 매칭 카드
                        captured.Add(playedCard);
                        captured.Add(fieldMatches[0]);
                        _deckManager.RemoveFromField(fieldMatches[0]);
                    }
                    break;

                case 3:
                    // 3장 매칭 (쓸) → 전부 획득
                    captured.Add(playedCard);
                    foreach (var fc in fieldMatches)
                    {
                        captured.Add(fc);
                        _deckManager.RemoveFromField(fc);
                    }
                    break;
            }

            // 이벤트 발생
            if (captured.Count > 0)
                OnMatchSuccess?.Invoke(playedCard, captured);
            else
                OnMatchFail?.Invoke(playedCard);

            return captured;
        }

        /// <summary>
        /// 뽑기패 매칭 (뒤집기 매칭)
        /// 뽑기패에서 1장 뒤집어 바닥과 매칭
        /// </summary>
        public List<CardInstance> ExecuteDrawMatch(CardInstance drawnCard, CardInstance selectedMatch = null)
        {
            return ExecuteMatch(drawnCard, selectedMatch);
        }
    }
}

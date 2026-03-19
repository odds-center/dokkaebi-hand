using System;
using System.Collections.Generic;
using DokkaebiHand.Cards;

namespace DokkaebiHand.Combat
{
    /// <summary>
    /// 섯다 승부: 매 판 시작 전 2장으로 보스와 대결
    ///
    /// 흐름:
    /// 1. 더미에서 2장 뽑음 (플레이어 패)
    /// 2. 보스도 2장 뽑음 (보스 패)
    /// 3. 섯다 족보 비교 → 이기면 이번 판 버프, 지면 디버프
    ///
    /// 이건 고스톱과 완전 별개. 섯다 끝나면 2장은 더미로 돌아가고
    /// 고스톱 판이 정상 진행됨.
    /// </summary>
    public class SeotdaChallenge
    {
        public CardInstance PlayerCard1 { get; private set; }
        public CardInstance PlayerCard2 { get; private set; }
        public CardInstance BossCard1 { get; private set; }
        public CardInstance BossCard2 { get; private set; }

        public SeotdaResult PlayerHand { get; private set; }
        public SeotdaResult BossHand { get; private set; }
        public bool PlayerWon { get; private set; }

        // 승부 결과 버프/디버프
        public int BonusChips { get; private set; }     // 이번 판 추가 점
        public int BonusMult { get; private set; }      // 이번 판 추가 배
        public int ChipPenalty { get; private set; }    // 졌을 때 점 감소
        public int HandPenalty { get; private set; }    // 졌을 때 손패 감소

        public event Action<string> OnMessage;

        /// <summary>
        /// 섯다 승부 실행
        /// </summary>
        public void Execute(DeckManager deck)
        {
            // 더미에서 4장 뽑기 (플레이어 2 + 보스 2)
            PlayerCard1 = deck.DrawFromPile();
            PlayerCard2 = deck.DrawFromPile();
            BossCard1 = deck.DrawFromPile();
            BossCard2 = deck.DrawFromPile();

            if (PlayerCard1 == null || PlayerCard2 == null ||
                BossCard1 == null || BossCard2 == null)
            {
                // 카드 부족 → 섯다 스킵
                PlayerWon = false;
                return;
            }

            // 족보 판정
            PlayerHand = Evaluate(PlayerCard1, PlayerCard2);
            BossHand = Evaluate(BossCard1, BossCard2);

            PlayerWon = PlayerHand.Rank > BossHand.Rank;
            bool draw = PlayerHand.Rank == BossHand.Rank;

            // 결과 적용
            if (PlayerWon)
            {
                BonusChips = 20 + PlayerHand.Rank / 2;
                BonusMult = PlayerHand.Rank >= 80 ? 2 : (PlayerHand.Rank >= 70 ? 1 : 0);
                ChipPenalty = 0;
                HandPenalty = 0;
                OnMessage?.Invoke($"섯다 승리! {PlayerHand.Name} vs {BossHand.Name} → 점+{BonusChips}, 배+{BonusMult}");
            }
            else if (draw)
            {
                BonusChips = 0;
                BonusMult = 0;
                ChipPenalty = 0;
                HandPenalty = 0;
                OnMessage?.Invoke($"섯다 무승부! {PlayerHand.Name} vs {BossHand.Name}");
            }
            else
            {
                BonusChips = 0;
                BonusMult = 0;
                ChipPenalty = 10 + BossHand.Rank / 3;
                HandPenalty = BossHand.Rank >= 80 ? 1 : 0;
                OnMessage?.Invoke($"섯다 패배! {PlayerHand.Name} vs {BossHand.Name} → 점-{ChipPenalty}, 손패-{HandPenalty}");
            }

            // 4장을 더미 맨 아래로 반납 (고스톱 판에는 포함 안 됨)
            deck.ReturnToPile(PlayerCard1);
            deck.ReturnToPile(PlayerCard2);
            deck.ReturnToPile(BossCard1);
            deck.ReturnToPile(BossCard2);
        }

        /// <summary>
        /// 섯다 2장 족보 판정
        /// </summary>
        public static SeotdaResult Evaluate(CardInstance a, CardInstance b)
        {
            int mA = (int)a.Month;
            int mB = (int)b.Month;
            bool aGwang = a.Type == CardType.Gwang;
            bool bGwang = b.Type == CardType.Gwang;

            // 광땡 (두 장 모두 광)
            if (aGwang && bGwang)
            {
                if ((mA == 3 && mB == 8) || (mA == 8 && mB == 3))
                    return new SeotdaResult("38광땡", 100);
                if ((mA == 1 && mB == 8) || (mA == 8 && mB == 1))
                    return new SeotdaResult("18광땡", 99);
                if ((mA == 1 && mB == 3) || (mA == 3 && mB == 1))
                    return new SeotdaResult("13광땡", 98);
                return new SeotdaResult("광땡", 95);
            }

            // 땡 (같은 월)
            if (mA == mB)
            {
                int val = mA > 10 ? 10 : mA;
                string name = val == 10 ? "장땡" : $"{val}땡";
                return new SeotdaResult(name, 80 + val);
            }

            // 특수 조합
            int small = Math.Min(mA, mB);
            int big = Math.Max(mA, mB);

            if (small == 1 && big == 2) return new SeotdaResult("알리", 75);
            if (small == 1 && big == 4) return new SeotdaResult("독사", 74);
            if (small == 1 && big == 9) return new SeotdaResult("구삥", 73);
            if (small == 1 && (big >= 10)) return new SeotdaResult("장삥", 72);
            if (small == 4 && (big >= 10)) return new SeotdaResult("장사", 71);
            if (small == 4 && big == 6) return new SeotdaResult("세륙", 70);

            // 끗
            int kkeut = (mA + mB) % 10;
            if (kkeut == 0) return new SeotdaResult("갑오", 10);
            return new SeotdaResult($"{kkeut}끗", kkeut);
        }

        /// <summary>
        /// UI 표시용: 섯다 결과 텍스트
        /// </summary>
        public string GetResultDisplay()
        {
            string vs = $"{PlayerHand.Name} vs {BossHand.Name}";
            if (PlayerWon)
                return $"섯다 승리! [{vs}]\n이번 판 점+{BonusChips} 배+{BonusMult}";
            else if (PlayerHand.Rank == BossHand.Rank)
                return $"섯다 무승부! [{vs}]";
            else
                return $"섯다 패배... [{vs}]\n이번 판 점-{ChipPenalty}";
        }
    }

    public class SeotdaResult
    {
        public string Name;
        public int Rank; // 높을수록 강함

        public SeotdaResult(string name, int rank)
        {
            Name = name;
            Rank = rank;
        }
    }
}

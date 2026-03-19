using System;
using System.Collections.Generic;
using DokkaebiHand.Cards;
using DokkaebiHand.Core;

namespace DokkaebiHand.Talismans
{
    /// <summary>
    /// 부적 관리: 슬롯, 트리거 발동, 효과 적용
    /// 효과 적용 순서: 가산(+) → 승산(x) → 특수효과
    /// </summary>
    public class TalismanManager
    {
        public event Action<TalismanInstance, string> OnTalismanTriggered;

        /// <summary>
        /// 점수 정산 시 부적 효과 적용
        /// </summary>
        public ScoringEngine.ScoreResult ApplyTalismanEffects(
            PlayerState player,
            ScoringEngine.ScoreResult baseScore,
            TalismanTrigger currentTrigger)
        {
            var result = baseScore;

            // 부적 효과 배율 (공허 축복, 웨이브 강화 등)
            float effectMult = 1f + player.WaveTalismanEffectBonus;

            // Phase 1: 가산 효과 (+)
            foreach (var talisman in player.Talismans)
            {
                if (!talisman.IsActive || talisman.Data.Trigger != currentTrigger)
                    continue;

                if (!CheckTriggerChance(talisman))
                    continue;

                switch (talisman.Data.EffectType)
                {
                    case TalismanEffectType.AddChips:
                        int addedChips = (int)(talisman.Data.EffectValue * effectMult);
                        result.Chips += addedChips;
                        OnTalismanTriggered?.Invoke(talisman, $"+{addedChips} 칩");
                        break;

                    case TalismanEffectType.AddMult:
                        int addedMult = (int)(talisman.Data.EffectValue * effectMult);
                        result.Mult += addedMult;
                        OnTalismanTriggered?.Invoke(talisman, $"+{addedMult} 배수");
                        break;
                }
            }

            // Phase 2: 승산 효과 (x)
            foreach (var talisman in player.Talismans)
            {
                if (!talisman.IsActive || talisman.Data.Trigger != currentTrigger)
                    continue;

                if (!CheckTriggerChance(talisman))
                    continue;

                if (talisman.Data.EffectType == TalismanEffectType.MultiplyMult)
                {
                    int multiplied = (int)(result.Mult * talisman.Data.EffectValue);
                    OnTalismanTriggered?.Invoke(talisman, $"배수 x{talisman.Data.EffectValue}");
                    result.Mult = multiplied;
                }
            }

            result.FinalScore = result.Chips * result.Mult;
            return result;
        }

        /// <summary>
        /// 목표 점수 감소 부적 적용
        /// </summary>
        public int ApplyTargetReduction(PlayerState player, int baseTarget)
        {
            float reduction = 0f;

            foreach (var talisman in player.Talismans)
            {
                if (!talisman.IsActive) continue;
                if (talisman.Data.EffectType != TalismanEffectType.ReduceTarget) continue;
                reduction += talisman.Data.EffectValue;
            }

            if (reduction > 0)
            {
                int reduced = (int)(baseTarget * (1f - reduction / 100f));
                return Math.Max(reduced, 1);
            }

            return baseTarget;
        }

        /// <summary>
        /// 비점수 트리거 알림 (OnTurnStart, OnTurnEnd, OnCardPlayed, OnMatchSuccess, OnMatchFail 등)
        /// </summary>
        public void NotifyTrigger(PlayerState player, TalismanTrigger trigger, CardInstance contextCard)
        {
            foreach (var talisman in player.Talismans)
            {
                if (!talisman.IsActive || talisman.Data.Trigger != trigger)
                    continue;

                if (!CheckTriggerChance(talisman))
                    continue;

                switch (talisman.Data.EffectType)
                {
                    case TalismanEffectType.DestroyCard:
                        // 흉살: 매 턴 피 1장 소멸
                        if (player.CapturedPi.Count > 0)
                        {
                            var destroyed = player.CapturedPi[player.CapturedPi.Count - 1];
                            player.CapturedPi.RemoveAt(player.CapturedPi.Count - 1);
                            OnTalismanTriggered?.Invoke(talisman, $"흉살: {destroyed.NameKR} 소멸");
                        }
                        break;

                    case TalismanEffectType.WildCard:
                        // 달빛 여우: 매칭 실패 시 와일드카드
                        if (trigger == TalismanTrigger.OnMatchFail)
                        {
                            player.WildCardNextMatch = true;
                            OnTalismanTriggered?.Invoke(talisman, "달빛 여우: 와일드카드 활성!");
                        }
                        break;

                    case TalismanEffectType.TransmuteCard:
                        // 광기의 광: 광 패 사용 시 랜덤 변이
                        if (trigger == TalismanTrigger.OnCardPlayed &&
                            contextCard != null && contextCard.Type == CardType.Gwang)
                        {
                            OnTalismanTriggered?.Invoke(talisman, "광기의 광: 카드 변이!");
                        }
                        break;

                    case TalismanEffectType.AddChips:
                        // 홍살문: 족보 완성 시 칩 보너스 (OnYokboComplete)
                        if (trigger == TalismanTrigger.OnYokboComplete)
                        {
                            OnTalismanTriggered?.Invoke(talisman, $"+{(int)talisman.Data.EffectValue} 칩");
                        }
                        break;

                    default:
                        OnTalismanTriggered?.Invoke(talisman, talisman.Data.DescriptionKR);
                        break;
                }
            }
        }

        private bool CheckTriggerChance(TalismanInstance talisman)
        {
            if (talisman.Data.TriggerChance >= 1f) return true;
            return new Random().NextDouble() < talisman.Data.TriggerChance;
        }
    }
}

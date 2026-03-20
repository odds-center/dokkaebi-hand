using System.Collections.Generic;
using DokkaebiHand.Cards;
using DokkaebiHand.Talismans;

namespace DokkaebiHand.Core
{
    /// <summary>
    /// 플레이어 상태 관리: 손패, 소모된 카드, 점수, 엽전, 체력, 부적
    ///
    /// Balatro 스타일 전투:
    /// - 손패에서 카드를 선택하여 "내기" → 시너지 판정 → 카드 소모
    /// - CapturedXxx 리스트는 하위 호환용으로 유지 (BattleSystem, ScoringEngine 등)
    /// - 새 시스템에서는 ConsumedCards로 소모된 카드 추적
    /// </summary>
    public class PlayerState
    {
        // 손패
        public List<CardInstance> Hand { get; private set; } = new List<CardInstance>();

        // 소모된 카드 (시너지 페이즈에서 "내기"로 소모한 카드 추적)
        public List<CardInstance> ConsumedCards { get; private set; } = new List<CardInstance>();

        // 획득한 카드 (종류별) — 하위 호환용 유지 (BattleSystem, ScoringEngine 등에서 참조)
        public List<CardInstance> CapturedGwang { get; private set; } = new List<CardInstance>();
        public List<CardInstance> CapturedTti { get; private set; } = new List<CardInstance>();
        public List<CardInstance> CapturedYeolkkeut { get; private set; } = new List<CardInstance>();
        public List<CardInstance> CapturedPi { get; private set; } = new List<CardInstance>();

        // 자원
        public int Yeop { get; set; }     // 엽전 (currency)
        public int Lives { get; set; }     // 체력 (최대 10칸)
        public const int MaxLives = 10;
        public int CurrentFloor { get; set; } // 현재 층

        // 회복 족보 보류 (다음 턴까지 유지하면 회복)
        public string PendingHealCombo { get; set; }  // 회복 대기 족보 ID
        public int PendingHealAmount { get; set; }     // 회복량

        // Go 카운트
        public int GoCount { get; set; }

        // 다음 라운드 손패 보너스 (소모품 card_pack 등)
        public int NextRoundHandBonus { get; set; }

        // 와일드카드 플래그 (여우 도깨비 스킬)
        public bool WildCardNextMatch { get; set; }

        // 런 내 웨이브 강화 버프
        public int WaveChipBonus { get; set; }
        public int WaveMultBonus { get; set; }
        public int WaveTalismanSlotBonus { get; set; }
        public float WaveTalismanEffectBonus { get; set; }
        public float WaveTargetReduction { get; set; }

        // 영구 강화 부적 슬롯 보너스
        public int PermanentTalismanSlotBonus { get; set; }

        // 부적 슬롯
        public List<TalismanInstance> Talismans { get; private set; } = new List<TalismanInstance>();
        public const int MaxTalismanSlots = 5;

        public PlayerState()
        {
            Lives = MaxLives; // 체력 10칸
            Yeop = 100;
            CurrentFloor = 1;
            GoCount = 0;
        }

        /// <summary>
        /// 카드를 소모 목록에 추가 (Balatro 스타일 시너지 페이즈에서 사용)
        /// </summary>
        public void ConsumeCard(CardInstance card)
        {
            ConsumedCards.Add(card);
        }

        /// <summary>
        /// 하위 호환: 카드 캡처 (BattleSystem, ScoringEngine 등에서 사용)
        /// </summary>
        public void CaptureCard(CardInstance card)
        {
            switch (card.Type)
            {
                case CardType.Gwang:
                    CapturedGwang.Add(card);
                    break;
                case CardType.Tti:
                    CapturedTti.Add(card);
                    break;
                case CardType.Yeolkkeut:
                    CapturedYeolkkeut.Add(card);
                    break;
                case CardType.Pi:
                    CapturedPi.Add(card);
                    break;
            }
        }

        public int GetTotalPiCount()
        {
            int count = 0;
            foreach (var card in CapturedPi)
                count += card.GetPiValue();
            return count;
        }

        public void ResetForNewRound()
        {
            Hand.Clear();
            ConsumedCards.Clear();
            CapturedGwang.Clear();
            CapturedTti.Clear();
            CapturedYeolkkeut.Clear();
            CapturedPi.Clear();
            GoCount = 0;
        }

        public const int AbsoluteMaxTalismanSlots = 10;

        public bool CanEquipTalisman()
        {
            int maxSlots = System.Math.Min(
                MaxTalismanSlots + PermanentTalismanSlotBonus + WaveTalismanSlotBonus,
                AbsoluteMaxTalismanSlots);
            return Talismans.Count < maxSlots;
        }

        public bool EquipTalisman(TalismanInstance talisman)
        {
            if (!CanEquipTalisman() && !talisman.Data.IsCurse)
                return false;

            Talismans.Add(talisman);
            return true;
        }
    }
}

using System.Collections.Generic;
using DokkaebiHand.Cards;
using DokkaebiHand.Talismans;

namespace DokkaebiHand.Core
{
    /// <summary>
    /// 플레이어 상태 관리: 손패, 획득패, 점수, 엽전, 체력, 부적
    /// </summary>
    public class PlayerState
    {
        // 손패
        public List<CardInstance> Hand { get; private set; } = new List<CardInstance>();

        // 획득한 카드 (종류별)
        public List<CardInstance> CapturedGwang { get; private set; } = new List<CardInstance>();
        public List<CardInstance> CapturedTti { get; private set; } = new List<CardInstance>();
        public List<CardInstance> CapturedYeolkkeut { get; private set; } = new List<CardInstance>();
        public List<CardInstance> CapturedPi { get; private set; } = new List<CardInstance>();

        // 자원
        public int Yeop { get; set; }     // 엽전 (currency)
        public int Lives { get; set; }     // 목숨
        public int CurrentFloor { get; set; } // 현재 층

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
            Lives = 3;
            Yeop = 100;
            CurrentFloor = 1;
            GoCount = 0;
        }

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
            CapturedGwang.Clear();
            CapturedTti.Clear();
            CapturedYeolkkeut.Clear();
            CapturedPi.Clear();
            GoCount = 0;
        }

        public bool CanEquipTalisman()
        {
            return Talismans.Count < MaxTalismanSlots + PermanentTalismanSlotBonus + WaveTalismanSlotBonus;
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

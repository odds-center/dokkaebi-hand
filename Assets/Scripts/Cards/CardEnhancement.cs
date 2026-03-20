using System;
using System.Collections.Generic;

namespace DokkaebiHand.Cards
{
    /// <summary>
    /// 카드 강화 등급: 기본 → 연마 → 신통 → 전설 → 해탈
    /// </summary>
    public enum EnhancementTier
    {
        Base = 0,       // ★
        Refined = 1,    // ★★ 연마
        Divine = 2,     // ★★★ 신통
        Legendary = 3,  // ★★★★ 전설
        Nirvana = 4     // ★★★★★ 해탈
    }

    /// <summary>
    /// 카드별 강화 상태를 관리
    /// </summary>
    public class CardEnhancement
    {
        public int CardId { get; private set; }
        public EnhancementTier Tier { get; private set; }

        // 변이 정보
        public CardMonth? MutatedMonth { get; private set; }
        public CardType? MutatedType { get; private set; }

        // 도깨비 각인 (최대 2개)
        public List<string> Seals { get; private set; } = new List<string>();
        public const int MaxSeals = 2;

        public CardEnhancement(int cardId)
        {
            CardId = cardId;
            Tier = EnhancementTier.Base;
        }

        /// <summary>
        /// 다음 등급으로 강화
        /// </summary>
        public bool Upgrade()
        {
            if (Tier >= EnhancementTier.Nirvana) return false;
            Tier = (EnhancementTier)((int)Tier + 1);
            return true;
        }

        /// <summary>
        /// 등급별 칩 보너스
        /// </summary>
        public int GetChipBonus(CardType originalType)
        {
            return Tier switch
            {
                EnhancementTier.Refined => originalType == CardType.Gwang ? 10 : 5,
                EnhancementTier.Divine => originalType == CardType.Gwang ? 20 : 10,
                EnhancementTier.Legendary => originalType == CardType.Gwang ? 40 : 20,
                EnhancementTier.Nirvana => originalType == CardType.Gwang ? 80 : 40,
                _ => 0
            };
        }

        /// <summary>
        /// 등급별 배수 보너스 (신통 이상)
        /// </summary>
        public int GetMultBonus(CardType originalType)
        {
            return Tier switch
            {
                EnhancementTier.Divine => 1,
                EnhancementTier.Legendary => 2,
                EnhancementTier.Nirvana => 4,
                _ => 0
            };
        }

        /// <summary>
        /// 신통(★★★) 특수 능력 활성 여부
        /// </summary>
        public bool HasSpecialAbility => Tier >= EnhancementTier.Divine;

        /// <summary>
        /// 전설(★★★★) 고유 이펙트 활성 여부
        /// </summary>
        public bool HasUniqueEffect => Tier >= EnhancementTier.Legendary;

        /// <summary>
        /// 월 변이 적용
        /// </summary>
        public void MutateMonth(CardMonth newMonth)
        {
            MutatedMonth = newMonth;
        }

        /// <summary>
        /// 타입 변이 적용 (하향 변이 금지: 광→피 불가)
        /// </summary>
        public bool MutateType(CardType originalType, CardType newType)
        {
            if (newType > originalType) return false; // 하향 금지 (Gwang=0 < Tti=1 < Pi=3, 큰 값 = 하위 타입)
            MutatedType = newType;
            return true;
        }

        /// <summary>
        /// 도깨비 각인 추가
        /// </summary>
        public bool AddSeal(string sealId)
        {
            if (Seals.Count >= MaxSeals) return false;
            if (Seals.Contains(sealId)) return false;
            Seals.Add(sealId);
            return true;
        }

        public bool RemoveSeal(string sealId)
        {
            return Seals.Remove(sealId);
        }

        /// <summary>
        /// 변이/강화 초기화
        /// </summary>
        public void Reset()
        {
            Tier = EnhancementTier.Base;
            MutatedMonth = null;
            MutatedType = null;
            Seals.Clear();
        }
    }

    /// <summary>
    /// 전체 덱의 강화 상태 관리 (영구 저장)
    /// </summary>
    public class CardEnhancementManager
    {
        private Dictionary<int, CardEnhancement> _enhancements = new Dictionary<int, CardEnhancement>();

        public CardEnhancement GetEnhancement(int cardId)
        {
            if (!_enhancements.ContainsKey(cardId))
                _enhancements[cardId] = new CardEnhancement(cardId);
            return _enhancements[cardId];
        }

        /// <summary>
        /// 카드 인스턴스에 강화 효과 적용
        /// </summary>
        public void ApplyToCard(CardInstance card)
        {
            var enh = GetEnhancement(card.Id);
            // 변이 적용은 CardInstance 생성 시 처리
            // 칩/배수 보너스는 ScoringEngine에서 조회
        }

        /// <summary>
        /// 윤회 시 등급 1단계 하락
        /// </summary>
        public void OnReincarnation()
        {
            foreach (var enh in _enhancements.Values)
            {
                if (enh.Tier > EnhancementTier.Base)
                {
                    // Tier를 1 내림 (직접 세팅 불가하므로 리셋 후 재강화)
                    var targetTier = (EnhancementTier)Math.Max(0, (int)enh.Tier - 1);
                    enh.Reset();
                    for (int i = 0; i < (int)targetTier; i++)
                        enh.Upgrade();
                }
            }
        }

        public int GetTotalEnhancedCards()
        {
            int count = 0;
            foreach (var enh in _enhancements.Values)
                if (enh.Tier > EnhancementTier.Base) count++;
            return count;
        }

        /// <summary>
        /// 강화 비용 계산: 연마 50, 신통 100, 전설 200, 해탈 500
        /// </summary>
        public static int GetUpgradeCost(EnhancementTier currentTier)
        {
            return currentTier switch
            {
                EnhancementTier.Base => 50,
                EnhancementTier.Refined => 100,
                EnhancementTier.Divine => 200,
                EnhancementTier.Legendary => 500,
                _ => -1 // 해탈은 더 이상 강화 불가
            };
        }

        /// <summary>
        /// 전체 카드 강화 상태 조회 (UI용)
        /// </summary>
        public Dictionary<int, CardEnhancement> GetAllEnhancements()
        {
            return new Dictionary<int, CardEnhancement>(_enhancements);
        }
    }
}

using System;
using System.Collections.Generic;
using DokkaebiHand.Core;

namespace DokkaebiHand.Cards
{
    /// <summary>
    /// 덱 관리: 셔플, 패 분배, 바닥패/손패/뽑기패 관리
    /// </summary>
    public class DeckManager
    {
        private List<CardInstance> _drawPile = new List<CardInstance>();
        private List<CardInstance> _fieldCards = new List<CardInstance>();
        private Random _rng;

        public IReadOnlyList<CardInstance> DrawPile => _drawPile;
        public IReadOnlyList<CardInstance> FieldCards => _fieldCards;

        public DeckManager(int? seed = null)
        {
            _rng = seed.HasValue ? new Random(seed.Value) : new Random();
        }

        /// <summary>
        /// 48장 전체 덱을 생성하고 셔플
        /// </summary>
        public void InitializeDeck()
        {
            _drawPile.Clear();
            _fieldCards.Clear();

            var allCards = HwaTuCardDatabase.AllCards;
            for (int i = 0; i < allCards.Count; i++)
            {
                _drawPile.Add(new CardInstance(i, allCards[i]));
            }

            Shuffle(_drawPile);
        }

        /// <summary>
        /// 2인용 고스톱 기준으로 패 분배
        /// 플레이어 손패 10장, 바닥패 8장, 나머지는 뽑기패
        /// </summary>
        public void DealCards(PlayerState player, int handSize = 10, int fieldSize = 8)
        {
            player.Hand.Clear();
            _fieldCards.Clear();

            for (int i = 0; i < handSize && _drawPile.Count > 0; i++)
            {
                player.Hand.Add(DrawFromPile());
            }

            for (int i = 0; i < fieldSize && _drawPile.Count > 0; i++)
            {
                _fieldCards.Add(DrawFromPile());
            }
        }

        /// <summary>
        /// 뽑기패에서 1장 드로우
        /// </summary>
        public CardInstance DrawFromPile()
        {
            if (_drawPile.Count == 0) return null;

            var card = _drawPile[_drawPile.Count - 1];
            _drawPile.RemoveAt(_drawPile.Count - 1);
            return card;
        }

        /// <summary>
        /// 바닥에 카드 추가
        /// </summary>
        public void AddToField(CardInstance card)
        {
            _fieldCards.Add(card);
        }

        /// <summary>
        /// 바닥에서 카드 제거 (매칭 시)
        /// </summary>
        public bool RemoveFromField(CardInstance card)
        {
            return _fieldCards.Remove(card);
        }

        /// <summary>
        /// 바닥에서 특정 월의 카드들 찾기
        /// </summary>
        public List<CardInstance> GetFieldCardsByMonth(CardMonth month)
        {
            var result = new List<CardInstance>();
            foreach (var card in _fieldCards)
            {
                if (card.Month == month)
                    result.Add(card);
            }
            return result;
        }

        /// <summary>
        /// 카드를 더미 맨 아래로 반납 (섯다 승부 후)
        /// </summary>
        public void ReturnToPile(CardInstance card)
        {
            if (card != null)
                _drawPile.Insert(0, card);
        }

        public bool IsDrawPileEmpty()
        {
            return _drawPile.Count == 0;
        }

        private void Shuffle(List<CardInstance> list)
        {
            for (int i = list.Count - 1; i > 0; i--)
            {
                int j = _rng.Next(i + 1);
                var temp = list[i];
                list[i] = list[j];
                list[j] = temp;
            }
        }
    }
}

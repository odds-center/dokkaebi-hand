using System.Collections.Generic;
using UnityEngine;

namespace DokkaebiHand.Cards
{
    /// <summary>
    /// 48장 화투패 전체를 코드로 정의하는 정적 데이터베이스.
    /// ScriptableObject 에셋 없이도 동작하도록 런타임 생성 지원.
    /// </summary>
    public static class HwaTuCardDatabase
    {
        public struct CardDefinition
        {
            public string Name;
            public string NameKR;
            public CardMonth Month;
            public CardType Type;
            public RibbonType Ribbon;
            public int BasePoints;
            public bool IsRainGwang;
            public bool IsDoublePi;
        }

        private static List<CardDefinition> _allCards;

        public static List<CardDefinition> AllCards
        {
            get
            {
                if (_allCards == null)
                    Initialize();
                return _allCards;
            }
        }

        private static void Initialize()
        {
            _allCards = new List<CardDefinition>(48);

            // === 1월: 송학 (Pine) ===
            Add("Pine Crane", "송학 광", CardMonth.January, CardType.Gwang, 20);
            Add("Pine Red Poetry", "송학 홍단", CardMonth.January, CardType.Tti, 10, ribbon: RibbonType.HongDan);
            Add("Pine Junk 1", "송학 피1", CardMonth.January, CardType.Pi, 1);
            Add("Pine Junk 2", "송학 피2", CardMonth.January, CardType.Pi, 1);

            // === 2월: 매조 (Plum Blossom) ===
            Add("Plum Warbler", "매조 열끗", CardMonth.February, CardType.Yeolkkeut, 10);
            Add("Plum Red Poetry", "매조 홍단", CardMonth.February, CardType.Tti, 10, ribbon: RibbonType.HongDan);
            Add("Plum Junk 1", "매조 피1", CardMonth.February, CardType.Pi, 1);
            Add("Plum Junk 2", "매조 피2", CardMonth.February, CardType.Pi, 1);

            // === 3월: 벚꽃 (Cherry Blossom) ===
            Add("Cherry Curtain", "벚꽃 광", CardMonth.March, CardType.Gwang, 20);
            Add("Cherry Red Poetry", "벚꽃 홍단", CardMonth.March, CardType.Tti, 10, ribbon: RibbonType.HongDan);
            Add("Cherry Junk 1", "벚꽃 피1", CardMonth.March, CardType.Pi, 1);
            Add("Cherry Junk 2", "벚꽃 피2", CardMonth.March, CardType.Pi, 1);

            // === 4월: 흑싸리 (Wisteria) ===
            Add("Wisteria Cuckoo", "흑싸리 열끗", CardMonth.April, CardType.Yeolkkeut, 10);
            Add("Wisteria Plain", "흑싸리 초단", CardMonth.April, CardType.Tti, 10, ribbon: RibbonType.ChoDan);
            Add("Wisteria Junk 1", "흑싸리 피1", CardMonth.April, CardType.Pi, 1);
            Add("Wisteria Junk 2", "흑싸리 피2", CardMonth.April, CardType.Pi, 1);

            // === 5월: 난초 (Orchid) ===
            Add("Orchid Bridge", "난초 열끗", CardMonth.May, CardType.Yeolkkeut, 10);
            Add("Orchid Plain", "난초 초단", CardMonth.May, CardType.Tti, 10, ribbon: RibbonType.ChoDan);
            Add("Orchid Junk 1", "난초 피1", CardMonth.May, CardType.Pi, 1);
            Add("Orchid Junk 2", "난초 피2", CardMonth.May, CardType.Pi, 1);

            // === 6월: 모란 (Peony) ===
            Add("Peony Butterfly", "모란 열끗", CardMonth.June, CardType.Yeolkkeut, 10);
            Add("Peony Blue", "모란 청단", CardMonth.June, CardType.Tti, 10, ribbon: RibbonType.CheongDan);
            Add("Peony Junk 1", "모란 피1", CardMonth.June, CardType.Pi, 1);
            Add("Peony Junk 2", "모란 피2", CardMonth.June, CardType.Pi, 1);

            // === 7월: 홍싸리 (Bush Clover) ===
            Add("Clover Boar", "홍싸리 열끗", CardMonth.July, CardType.Yeolkkeut, 10);
            Add("Clover Plain", "홍싸리 초단", CardMonth.July, CardType.Tti, 10, ribbon: RibbonType.ChoDan);
            Add("Clover Junk 1", "홍싸리 피1", CardMonth.July, CardType.Pi, 1);
            Add("Clover Junk 2", "홍싸리 피2", CardMonth.July, CardType.Pi, 1);

            // === 8월: 공산 (Susuki Grass / Moon) ===
            Add("Moon Bright", "공산 광", CardMonth.August, CardType.Gwang, 20);
            Add("Moon Geese", "공산 열끗", CardMonth.August, CardType.Yeolkkeut, 10);
            Add("Moon Junk 1", "공산 피1", CardMonth.August, CardType.Pi, 1);
            Add("Moon Junk 2", "공산 피2", CardMonth.August, CardType.Pi, 1);

            // === 9월: 국진 (Chrysanthemum) ===
            Add("Chrysanthemum Cup", "국진 열끗", CardMonth.September, CardType.Yeolkkeut, 10);
            Add("Chrysanthemum Blue", "국진 청단", CardMonth.September, CardType.Tti, 10, ribbon: RibbonType.CheongDan);
            Add("Chrysanthemum Junk 1", "국진 피1", CardMonth.September, CardType.Pi, 1);
            Add("Chrysanthemum Junk 2", "국진 피2", CardMonth.September, CardType.Pi, 1);

            // === 10월: 단풍 (Maple) ===
            Add("Maple Deer", "단풍 열끗", CardMonth.October, CardType.Yeolkkeut, 10);
            Add("Maple Blue", "단풍 청단", CardMonth.October, CardType.Tti, 10, ribbon: RibbonType.CheongDan);
            Add("Maple Junk 1", "단풍 피1", CardMonth.October, CardType.Pi, 1);
            Add("Maple Junk 2", "단풍 피2", CardMonth.October, CardType.Pi, 1);

            // === 11월: 오동 (Paulownia) ===
            Add("Paulownia Phoenix", "오동 광", CardMonth.November, CardType.Gwang, 20);
            Add("Paulownia Junk 1", "오동 피1", CardMonth.November, CardType.Pi, 1);
            Add("Paulownia Junk 2", "오동 피2", CardMonth.November, CardType.Pi, 1);
            Add("Paulownia Double Junk", "오동 쌍피", CardMonth.November, CardType.Pi, 1, isDoublePi: true);

            // === 12월: 비 (Rain) ===
            Add("Rain Man", "비 광", CardMonth.December, CardType.Gwang, 20, isRainGwang: true);
            Add("Rain Swallow", "비 열끗", CardMonth.December, CardType.Yeolkkeut, 10);
            Add("Rain Red Poetry", "비 홍단", CardMonth.December, CardType.Tti, 10, ribbon: RibbonType.HongDan);
            Add("Rain Double Junk", "비 쌍피", CardMonth.December, CardType.Pi, 1, isDoublePi: true);
        }

        private static void Add(string name, string nameKR, CardMonth month, CardType type, int points,
            RibbonType ribbon = RibbonType.None, bool isRainGwang = false, bool isDoublePi = false)
        {
            _allCards.Add(new CardDefinition
            {
                Name = name,
                NameKR = nameKR,
                Month = month,
                Type = type,
                Ribbon = ribbon,
                BasePoints = points,
                IsRainGwang = isRainGwang,
                IsDoublePi = isDoublePi
            });
        }
    }
}

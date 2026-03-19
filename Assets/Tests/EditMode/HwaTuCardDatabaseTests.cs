using NUnit.Framework;
using DokkaebiHand.Cards;
using System.Linq;

namespace DokkaebiHand.Tests
{
    [TestFixture]
    public class HwaTuCardDatabaseTests
    {
        [Test]
        public void Database_Has_48_Cards()
        {
            var cards = HwaTuCardDatabase.AllCards;
            Assert.AreEqual(48, cards.Count, "화투 덱은 정확히 48장이어야 합니다");
        }

        [Test]
        public void Each_Month_Has_4_Cards()
        {
            var cards = HwaTuCardDatabase.AllCards;
            for (int month = 1; month <= 12; month++)
            {
                var monthCards = cards.Where(c => (int)c.Month == month).ToList();
                Assert.AreEqual(4, monthCards.Count, $"{month}월은 4장이어야 합니다");
            }
        }

        [Test]
        public void Has_5_Gwang_Cards()
        {
            var gwangCount = HwaTuCardDatabase.AllCards.Count(c => c.Type == CardType.Gwang);
            Assert.AreEqual(5, gwangCount, "광은 5장이어야 합니다");
        }

        [Test]
        public void Gwang_Months_Are_Correct()
        {
            var gwangMonths = HwaTuCardDatabase.AllCards
                .Where(c => c.Type == CardType.Gwang)
                .Select(c => c.Month)
                .OrderBy(m => m)
                .ToList();

            Assert.Contains(CardMonth.January, gwangMonths);
            Assert.Contains(CardMonth.March, gwangMonths);
            Assert.Contains(CardMonth.August, gwangMonths);
            Assert.Contains(CardMonth.November, gwangMonths);
            Assert.Contains(CardMonth.December, gwangMonths);
        }

        [Test]
        public void Has_Correct_Ribbon_Types()
        {
            var cards = HwaTuCardDatabase.AllCards;

            // 홍단: 1, 2, 3, 12월 (비 홍단 포함 = 4장)
            var hongDan = cards.Count(c => c.Ribbon == RibbonType.HongDan);
            Assert.AreEqual(4, hongDan, "홍단은 4장");

            // 청단: 6, 9, 10월 = 3장
            var cheongDan = cards.Count(c => c.Ribbon == RibbonType.CheongDan);
            Assert.AreEqual(3, cheongDan, "청단은 3장");

            // 초단: 4, 5, 7월 = 3장
            var choDan = cards.Count(c => c.Ribbon == RibbonType.ChoDan);
            Assert.AreEqual(3, choDan, "초단은 3장");
        }

        [Test]
        public void Rain_Gwang_Is_December()
        {
            var rainGwang = HwaTuCardDatabase.AllCards
                .FirstOrDefault(c => c.IsRainGwang);

            Assert.IsNotNull(rainGwang, "비광이 존재해야 합니다");
            Assert.AreEqual(CardMonth.December, rainGwang.Month);
            Assert.AreEqual(CardType.Gwang, rainGwang.Type);
        }

        [Test]
        public void Double_Pi_Cards_Exist()
        {
            var doublePi = HwaTuCardDatabase.AllCards.Where(c => c.IsDoublePi).ToList();
            Assert.AreEqual(2, doublePi.Count, "쌍피는 2장 (오동, 비)");
        }
    }
}

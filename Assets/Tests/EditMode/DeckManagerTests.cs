using NUnit.Framework;
using DokkaebiHand.Cards;
using DokkaebiHand.Core;

namespace DokkaebiHand.Tests
{
    [TestFixture]
    public class DeckManagerTests
    {
        [Test]
        public void InitializeDeck_Creates_48_Cards()
        {
            var deck = new DeckManager(42);
            deck.InitializeDeck();

            Assert.AreEqual(48, deck.DrawPile.Count);
        }

        [Test]
        public void DealCards_Distributes_Correctly()
        {
            var deck = new DeckManager(42);
            deck.InitializeDeck();
            var player = new PlayerState();

            deck.DealCards(player, handSize: 10, fieldSize: 8);

            Assert.AreEqual(10, player.Hand.Count, "손패 10장");
            Assert.AreEqual(8, deck.FieldCards.Count, "바닥패 8장");
            Assert.AreEqual(30, deck.DrawPile.Count, "뽑기패 30장");
        }

        [Test]
        public void DrawFromPile_Reduces_Count()
        {
            var deck = new DeckManager(42);
            deck.InitializeDeck();

            int before = deck.DrawPile.Count;
            var card = deck.DrawFromPile();

            Assert.IsNotNull(card);
            Assert.AreEqual(before - 1, deck.DrawPile.Count);
        }

        [Test]
        public void Shuffle_Produces_Different_Orders()
        {
            var deck1 = new DeckManager(1);
            deck1.InitializeDeck();

            var deck2 = new DeckManager(2);
            deck2.InitializeDeck();

            bool anyDifferent = false;
            for (int i = 0; i < deck1.DrawPile.Count; i++)
            {
                if (deck1.DrawPile[i].Id != deck2.DrawPile[i].Id)
                {
                    anyDifferent = true;
                    break;
                }
            }

            Assert.IsTrue(anyDifferent, "다른 시드는 다른 순서를 만들어야 합니다");
        }

        [Test]
        public void GetFieldCardsByMonth_Returns_Correct_Cards()
        {
            var deck = new DeckManager(42);
            deck.InitializeDeck();
            var player = new PlayerState();
            deck.DealCards(player);

            // 바닥에서 아무 월이나 찾기
            if (deck.FieldCards.Count > 0)
            {
                var firstMonth = deck.FieldCards[0].Month;
                var matches = deck.GetFieldCardsByMonth(firstMonth);
                Assert.IsTrue(matches.Count >= 1);
                foreach (var m in matches)
                    Assert.AreEqual(firstMonth, m.Month);
            }
        }
    }
}

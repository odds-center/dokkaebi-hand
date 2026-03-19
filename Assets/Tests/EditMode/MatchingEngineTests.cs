using NUnit.Framework;
using DokkaebiHand.Cards;
using DokkaebiHand.Core;

namespace DokkaebiHand.Tests
{
    [TestFixture]
    public class MatchingEngineTests
    {
        private DeckManager _deck;
        private MatchingEngine _engine;

        [SetUp]
        public void SetUp()
        {
            _deck = new DeckManager(42);
            _engine = new MatchingEngine(_deck);
        }

        [Test]
        public void NoMatch_When_No_Same_Month_On_Field()
        {
            _deck.InitializeDeck();

            // 바닥 비우고 특정 카드만 배치
            var player = new PlayerState();
            _deck.DealCards(player, handSize: 0, fieldSize: 0);

            // 1월 카드를 바닥에 놓기
            var janCard = CreateTestCard(0, CardMonth.January);
            _deck.AddToField(janCard);

            // 2월 카드로 매칭 시도
            var febCard = CreateTestCard(1, CardMonth.February);
            var result = _engine.EvaluateMatch(febCard);

            Assert.AreEqual(MatchResult.NoMatch, result);
        }

        [Test]
        public void SingleMatch_When_One_Same_Month()
        {
            _deck.InitializeDeck();
            var player = new PlayerState();
            _deck.DealCards(player, handSize: 0, fieldSize: 0);

            var fieldCard = CreateTestCard(0, CardMonth.January);
            _deck.AddToField(fieldCard);

            var playCard = CreateTestCard(1, CardMonth.January);
            var result = _engine.EvaluateMatch(playCard);

            Assert.AreEqual(MatchResult.SingleMatch, result);
        }

        [Test]
        public void DoubleMatch_When_Two_Same_Month()
        {
            _deck.InitializeDeck();
            var player = new PlayerState();
            _deck.DealCards(player, handSize: 0, fieldSize: 0);

            _deck.AddToField(CreateTestCard(0, CardMonth.March));
            _deck.AddToField(CreateTestCard(1, CardMonth.March));

            var playCard = CreateTestCard(2, CardMonth.March);
            var result = _engine.EvaluateMatch(playCard);

            Assert.AreEqual(MatchResult.DoubleMatch, result);
        }

        [Test]
        public void TripleMatch_When_Three_Same_Month()
        {
            _deck.InitializeDeck();
            var player = new PlayerState();
            _deck.DealCards(player, handSize: 0, fieldSize: 0);

            _deck.AddToField(CreateTestCard(0, CardMonth.May));
            _deck.AddToField(CreateTestCard(1, CardMonth.May));
            _deck.AddToField(CreateTestCard(2, CardMonth.May));

            var playCard = CreateTestCard(3, CardMonth.May);
            var result = _engine.EvaluateMatch(playCard);

            Assert.AreEqual(MatchResult.TripleMatch, result);
        }

        [Test]
        public void ExecuteMatch_SingleMatch_Captures_Two_Cards()
        {
            _deck.InitializeDeck();
            var player = new PlayerState();
            _deck.DealCards(player, handSize: 0, fieldSize: 0);

            var fieldCard = CreateTestCard(0, CardMonth.January);
            _deck.AddToField(fieldCard);

            var playCard = CreateTestCard(1, CardMonth.January);
            var captured = _engine.ExecuteMatch(playCard);

            Assert.AreEqual(2, captured.Count);
            Assert.AreEqual(0, _deck.FieldCards.Count);
        }

        [Test]
        public void ExecuteMatch_NoMatch_Adds_To_Field()
        {
            _deck.InitializeDeck();
            var player = new PlayerState();
            _deck.DealCards(player, handSize: 0, fieldSize: 0);

            var playCard = CreateTestCard(0, CardMonth.January);
            var captured = _engine.ExecuteMatch(playCard);

            Assert.AreEqual(0, captured.Count);
            Assert.AreEqual(1, _deck.FieldCards.Count);
        }

        [Test]
        public void ExecuteMatch_TripleMatch_Captures_All_Four()
        {
            _deck.InitializeDeck();
            var player = new PlayerState();
            _deck.DealCards(player, handSize: 0, fieldSize: 0);

            _deck.AddToField(CreateTestCard(0, CardMonth.July));
            _deck.AddToField(CreateTestCard(1, CardMonth.July));
            _deck.AddToField(CreateTestCard(2, CardMonth.July));

            var playCard = CreateTestCard(3, CardMonth.July);
            var captured = _engine.ExecuteMatch(playCard);

            Assert.AreEqual(4, captured.Count);
            Assert.AreEqual(0, _deck.FieldCards.Count);
        }

        private CardInstance CreateTestCard(int id, CardMonth month,
            CardType type = CardType.Pi)
        {
            return new CardInstance(id, new HwaTuCardDatabase.CardDefinition
            {
                Name = $"Test {month}",
                NameKR = $"테스트 {month}",
                Month = month,
                Type = type,
                BasePoints = 1
            });
        }
    }
}

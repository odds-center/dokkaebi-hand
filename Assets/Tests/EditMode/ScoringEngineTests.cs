using NUnit.Framework;
using DokkaebiHand.Cards;
using DokkaebiHand.Core;
using System.Linq;

namespace DokkaebiHand.Tests
{
    [TestFixture]
    public class ScoringEngineTests
    {
        private ScoringEngine _engine;
        private PlayerState _player;

        [SetUp]
        public void SetUp()
        {
            _engine = new ScoringEngine();
            _player = new PlayerState();
        }

        // === 광 족보 ===

        [Test]
        public void ThreeGwang_Without_Rain_Scores_Samgwang()
        {
            AddGwang(CardMonth.January);
            AddGwang(CardMonth.March);
            AddGwang(CardMonth.August);

            var result = _engine.CalculateScore(_player);

            // 삼광 150칩 + 월명(8월 단독) 20칩 + 봄빛(1+3월) 은 3광에선 미적용
            Assert.IsTrue(result.CompletedYokbo.Any(y => y.Contains("삼광")));
            Assert.GreaterOrEqual(result.Chips, 150);
            Assert.GreaterOrEqual(result.Mult, 3); // 1(base) + 2(삼광)
        }

        [Test]
        public void ThreeGwang_With_Rain_Scores_BiGwang()
        {
            AddGwang(CardMonth.January);
            AddGwang(CardMonth.March);
            AddGwang(CardMonth.December, isRain: true);

            var result = _engine.CalculateScore(_player);

            Assert.IsTrue(result.CompletedYokbo.Any(y => y.Contains("비광")));
            Assert.GreaterOrEqual(result.Chips, 100);
        }

        [Test]
        public void FiveGwang_Scores_Ogwang()
        {
            AddGwang(CardMonth.January);
            AddGwang(CardMonth.March);
            AddGwang(CardMonth.August);
            AddGwang(CardMonth.November);
            AddGwang(CardMonth.December, isRain: true);

            var result = _engine.CalculateScore(_player);

            Assert.IsTrue(result.CompletedYokbo.Any(y => y.Contains("오광")));
            Assert.GreaterOrEqual(result.Chips, 300);
            Assert.GreaterOrEqual(result.Mult, 6); // 1 + 5
        }

        [Test]
        public void FourGwang_Without_Rain_Scores_Sagwang()
        {
            AddGwang(CardMonth.January);
            AddGwang(CardMonth.March);
            AddGwang(CardMonth.August);
            AddGwang(CardMonth.November);

            var result = _engine.CalculateScore(_player);

            Assert.IsTrue(result.CompletedYokbo.Any(y => y.Contains("사광")));
            Assert.GreaterOrEqual(result.Chips, 200);
        }

        // === 띠 족보 ===

        [Test]
        public void HongDan_Complete()
        {
            AddTti(CardMonth.January, RibbonType.HongDan);
            AddTti(CardMonth.February, RibbonType.HongDan);
            AddTti(CardMonth.March, RibbonType.HongDan);

            var result = _engine.CalculateScore(_player);

            Assert.IsTrue(result.CompletedYokbo.Any(y => y.Contains("홍단")));
            Assert.GreaterOrEqual(result.Chips, 120);
        }

        [Test]
        public void CheongDan_Complete()
        {
            AddTti(CardMonth.June, RibbonType.CheongDan);
            AddTti(CardMonth.September, RibbonType.CheongDan);
            AddTti(CardMonth.October, RibbonType.CheongDan);

            var result = _engine.CalculateScore(_player);

            Assert.IsTrue(result.CompletedYokbo.Any(y => y.Contains("청단")));
        }

        [Test]
        public void SamDanTong_All_Three_Dan()
        {
            // 삼단통: 홍단 + 청단 + 초단 모두 완성
            AddTti(CardMonth.January, RibbonType.HongDan);
            AddTti(CardMonth.February, RibbonType.HongDan);
            AddTti(CardMonth.March, RibbonType.HongDan);
            AddTti(CardMonth.June, RibbonType.CheongDan);
            AddTti(CardMonth.September, RibbonType.CheongDan);
            AddTti(CardMonth.October, RibbonType.CheongDan);
            AddTti(CardMonth.April, RibbonType.ChoDan);
            AddTti(CardMonth.May, RibbonType.ChoDan);
            AddTti(CardMonth.July, RibbonType.ChoDan);

            var result = _engine.CalculateScore(_player);

            Assert.IsTrue(result.CompletedYokbo.Any(y => y.Contains("삼단통")));
            // 홍120 + 청120 + 초120 + 삼단통200 + 띠9장보너스 = 640+
            Assert.GreaterOrEqual(result.Chips, 600);
        }

        // === 고도리 ===

        [Test]
        public void Godori_FebAprAug()
        {
            AddYeolkkeut(CardMonth.February);
            AddYeolkkeut(CardMonth.April);
            AddYeolkkeut(CardMonth.August);

            var result = _engine.CalculateScore(_player);

            Assert.IsTrue(result.CompletedYokbo.Any(y => y.Contains("고도리")));
            Assert.GreaterOrEqual(result.Chips, 100);
        }

        [Test]
        public void Jodori_JunJulOct()
        {
            AddYeolkkeut(CardMonth.June);
            AddYeolkkeut(CardMonth.July);
            AddYeolkkeut(CardMonth.October);

            var result = _engine.CalculateScore(_player);

            Assert.IsTrue(result.CompletedYokbo.Any(y => y.Contains("저도리")));
        }

        // === 피 족보 ===

        [Test]
        public void Pi_10_Scores_Plus_Sipjang()
        {
            for (int i = 0; i < 10; i++)
                AddPi(false);

            var result = _engine.CalculateScore(_player);

            Assert.GreaterOrEqual(result.Chips, 30);
            Assert.IsTrue(result.CompletedYokbo.Any(y => y.Contains("십장")));
        }

        [Test]
        public void DoublePi_Counts_As_Two()
        {
            for (int i = 0; i < 8; i++)
                AddPi(false);
            AddPi(true);

            Assert.AreEqual(10, _player.GetTotalPiCount());
        }

        // === 총통 ===

        [Test]
        public void Chongtong_Four_Same_Month()
        {
            // 1월 4장 전부 획득
            AddGwang(CardMonth.January);
            AddTti(CardMonth.January, RibbonType.HongDan);
            AddPiWithMonth(CardMonth.January);
            AddPiWithMonth(CardMonth.January);

            var result = _engine.CalculateScore(_player);

            Assert.IsTrue(result.CompletedYokbo.Any(y => y.Contains("총통")));
        }

        // === 고유 족보 ===

        [Test]
        public void Sagye_FourSeasons()
        {
            // 3,6,9,12월
            AddTti(CardMonth.March, RibbonType.HongDan);
            AddTti(CardMonth.June, RibbonType.CheongDan);
            AddTti(CardMonth.September, RibbonType.CheongDan);
            AddGwang(CardMonth.December, isRain: true);

            var result = _engine.CalculateScore(_player);

            Assert.IsTrue(result.CompletedYokbo.Any(y => y.Contains("사계")));
        }

        [Test]
        public void Wolha_MoonAndCup()
        {
            AddGwang(CardMonth.August);
            AddYeolkkeut(CardMonth.September);

            var result = _engine.CalculateScore(_player);

            Assert.IsTrue(result.CompletedYokbo.Any(y => y.Contains("월하독작")));
        }

        [Test]
        public void SunHu_JanAndDecGwang()
        {
            AddGwang(CardMonth.January);
            AddGwang(CardMonth.December, isRain: true);

            var result = _engine.CalculateScore(_player);

            Assert.IsTrue(result.CompletedYokbo.Any(y => y.Contains("선후착")));
        }

        [Test]
        public void DokkaebiFire_OneGwangSevenPi()
        {
            AddGwang(CardMonth.August);
            for (int i = 0; i < 7; i++)
                AddPi(false);

            var result = _engine.CalculateScore(_player);

            Assert.IsTrue(result.CompletedYokbo.Any(y => y.Contains("도깨비불")));
        }

        // === Go(탐) 배수 ===

        [Test]
        public void Go_1_Doubles_Mult()
        {
            AddGwang(CardMonth.January);
            AddGwang(CardMonth.March);
            AddGwang(CardMonth.August);
            _player.GoCount = 1;

            var result = _engine.CalculateScore(_player);

            Assert.IsTrue(result.CompletedYokbo.Any(y => y.Contains("탐 1회")));
        }

        [Test]
        public void Go_3_Gives_10x()
        {
            AddGwang(CardMonth.January);
            AddGwang(CardMonth.March);
            AddGwang(CardMonth.August);
            _player.GoCount = 3;

            var result = _engine.CalculateScore(_player);

            Assert.IsTrue(result.CompletedYokbo.Any(y => y.Contains("탐 3회")));
        }

        // === 섯다 족보 ===

        [Test]
        public void Seotda_38GwangTtaeng()
        {
            // 3월 광 + 8월 광 = 38광땡 (섯다 최강)
            AddGwang(CardMonth.March);
            AddGwang(CardMonth.August);

            var result = _engine.CalculateScore(_player);

            // 삼광은 아님 (2광), 38광땡이 발동
            Assert.IsTrue(result.CompletedYokbo.Any(y => y.Contains("38광땡")));
            Assert.GreaterOrEqual(result.Chips, 200); // 38광땡 200점
        }

        [Test]
        public void Seotda_Ttaeng_SameMonth()
        {
            // 같은 월 2장 = 땡
            AddPiWithMonth(CardMonth.October);
            AddYeolkkeut(CardMonth.October);

            var result = _engine.CalculateScore(_player);

            Assert.IsTrue(result.CompletedYokbo.Any(y => y.Contains("땡") || y.Contains("장땡")));
        }

        [Test]
        public void Seotda_Ali()
        {
            // 1월 + 2월 = 알리
            AddPiWithMonth(CardMonth.January);
            AddPiWithMonth(CardMonth.February);

            var result = _engine.CalculateScore(_player);

            Assert.IsTrue(result.CompletedYokbo.Any(y => y.Contains("알리")));
        }

        [Test]
        public void Seotda_Doksa()
        {
            // 1월 + 4월 = 독사
            AddPiWithMonth(CardMonth.January);
            AddPiWithMonth(CardMonth.April);

            var result = _engine.CalculateScore(_player);

            Assert.IsTrue(result.CompletedYokbo.Any(y => y.Contains("독사")));
        }

        [Test]
        public void No_Yokbo_Returns_Zero()
        {
            var result = _engine.CalculateScore(_player);

            Assert.AreEqual(0, result.Chips);
            Assert.AreEqual(1, result.Mult);
            Assert.AreEqual(0, result.FinalScore);
        }

        [Test]
        public void Combined_Yokbo_Stacks()
        {
            // 삼광 + 홍단 + 고도리
            AddGwang(CardMonth.January);
            AddGwang(CardMonth.March);
            AddGwang(CardMonth.August);

            AddTti(CardMonth.January, RibbonType.HongDan);
            AddTti(CardMonth.February, RibbonType.HongDan);
            AddTti(CardMonth.March, RibbonType.HongDan);

            AddYeolkkeut(CardMonth.February);
            AddYeolkkeut(CardMonth.April);
            AddYeolkkeut(CardMonth.August);

            var result = _engine.CalculateScore(_player);

            // 다수의 족보가 동시에 발동해야 함
            Assert.GreaterOrEqual(result.CompletedYokbo.Count, 3);
            Assert.Greater(result.FinalScore, 0);
        }

        #region Helpers

        private void AddGwang(CardMonth month, bool isRain = false)
        {
            _player.CaptureCard(new CardInstance(_player.CapturedGwang.Count, new HwaTuCardDatabase.CardDefinition
            {
                Month = month, Type = CardType.Gwang, IsRainGwang = isRain,
                BasePoints = 20, Name = "Test Gwang", NameKR = "테스트 광"
            }));
        }

        private void AddTti(CardMonth month, RibbonType ribbon)
        {
            _player.CaptureCard(new CardInstance(100 + _player.CapturedTti.Count, new HwaTuCardDatabase.CardDefinition
            {
                Month = month, Type = CardType.Tti, Ribbon = ribbon,
                BasePoints = 10, Name = "Test Tti", NameKR = "테스트 띠"
            }));
        }

        private void AddYeolkkeut(CardMonth month = CardMonth.February)
        {
            _player.CaptureCard(new CardInstance(200 + _player.CapturedYeolkkeut.Count, new HwaTuCardDatabase.CardDefinition
            {
                Month = month, Type = CardType.Yeolkkeut,
                BasePoints = 10, Name = "Test Yeolkkeut", NameKR = "테스트 열끗"
            }));
        }

        private void AddPi(bool isDouble)
        {
            _player.CaptureCard(new CardInstance(300 + _player.CapturedPi.Count, new HwaTuCardDatabase.CardDefinition
            {
                Month = CardMonth.January, Type = CardType.Pi, IsDoublePi = isDouble,
                BasePoints = 1, Name = "Test Pi", NameKR = "테스트 피"
            }));
        }

        private void AddPiWithMonth(CardMonth month)
        {
            _player.CaptureCard(new CardInstance(300 + _player.CapturedPi.Count, new HwaTuCardDatabase.CardDefinition
            {
                Month = month, Type = CardType.Pi,
                BasePoints = 1, Name = "Test Pi", NameKR = "테스트 피"
            }));
        }

        #endregion
    }
}

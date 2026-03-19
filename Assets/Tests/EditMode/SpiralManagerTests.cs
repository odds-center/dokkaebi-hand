using NUnit.Framework;
using DokkaebiHand.Core;

namespace DokkaebiHand.Tests
{
    [TestFixture]
    public class SpiralManagerTests
    {
        private SpiralManager _spiral;

        [SetUp]
        public void SetUp()
        {
            _spiral = new SpiralManager();
        }

        [Test]
        public void Starts_At_Spiral_1_Realm_1()
        {
            Assert.AreEqual(1, _spiral.CurrentSpiral);
            Assert.AreEqual(1, _spiral.CurrentRealm);
            Assert.AreEqual(1, _spiral.AbsoluteRealm);
        }

        [Test]
        public void AdvanceRealm_Increments_Realm()
        {
            bool gateAppeared = _spiral.AdvanceRealm();
            Assert.IsFalse(gateAppeared);
            Assert.AreEqual(2, _spiral.CurrentRealm);
        }

        [Test]
        public void AdvanceRealm_10_Triggers_Gate()
        {
            for (int i = 0; i < 9; i++)
                _spiral.AdvanceRealm();

            bool gateAppeared = _spiral.AdvanceRealm();
            Assert.IsTrue(gateAppeared, "10영역 클리어 시 이승의 문이 나타나야 함");
        }

        [Test]
        public void ContinueToNextSpiral_Increments_Spiral()
        {
            for (int i = 0; i < 10; i++)
                _spiral.AdvanceRealm();

            _spiral.ContinueToNextSpiral();

            Assert.AreEqual(2, _spiral.CurrentSpiral);
            Assert.AreEqual(1, _spiral.CurrentRealm);
        }

        [Test]
        public void AbsoluteRealm_Calculates_Correctly()
        {
            // Spiral 1, Realm 5
            for (int i = 0; i < 4; i++) _spiral.AdvanceRealm();
            Assert.AreEqual(5, _spiral.AbsoluteRealm);

            // Complete spiral 1 and go to spiral 2
            for (int i = 0; i < 6; i++) _spiral.AdvanceRealm();
            _spiral.ContinueToNextSpiral();

            // Spiral 2, Realm 1 = Absolute 11
            Assert.AreEqual(11, _spiral.AbsoluteRealm);
        }

        [Test]
        public void GetTargetScore_Scales_Linearly()
        {
            int base200 = _spiral.GetTargetScore(200);
            Assert.AreEqual(200, base200); // realm 1: 1 + 0.12*(1-1) = 1.0

            for (int i = 0; i < 9; i++) _spiral.AdvanceRealm();
            int realm10 = _spiral.GetTargetScore(200);
            // 1 + 0.12 * 9 = 2.08 → 200 * 2.08 = 416
            Assert.AreEqual(416, realm10);
        }

        [Test]
        public void GetPartsCount_Returns_0_For_Spiral_1()
        {
            Assert.AreEqual(0, _spiral.GetPartsCount());
        }

        [Test]
        public void GetPartsCount_Increases_With_Spiral()
        {
            // Go to spiral 2
            for (int i = 0; i < 10; i++) _spiral.AdvanceRealm();
            _spiral.ContinueToNextSpiral();
            Assert.AreEqual(1, _spiral.GetPartsCount());

            // Go to spiral 3
            for (int i = 0; i < 10; i++) _spiral.AdvanceRealm();
            _spiral.ContinueToNextSpiral();
            Assert.AreEqual(2, _spiral.GetPartsCount());

            // Go to spiral 4
            for (int i = 0; i < 10; i++) _spiral.AdvanceRealm();
            _spiral.ContinueToNextSpiral();
            Assert.AreEqual(3, _spiral.GetPartsCount());
        }

        [Test]
        public void TotalRealmsCleared_Tracks_Correctly()
        {
            for (int i = 0; i < 10; i++) _spiral.AdvanceRealm();
            Assert.AreEqual(10, _spiral.TotalRealmsCleared);

            _spiral.ContinueToNextSpiral();
            for (int i = 0; i < 5; i++) _spiral.AdvanceRealm();
            Assert.AreEqual(15, _spiral.TotalRealmsCleared);
        }
    }
}

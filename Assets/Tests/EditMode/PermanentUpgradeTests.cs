using NUnit.Framework;
using DokkaebiHand.Core;

namespace DokkaebiHand.Tests
{
    [TestFixture]
    public class PermanentUpgradeTests
    {
        private PermanentUpgradeManager _mgr;

        [SetUp]
        public void SetUp()
        {
            _mgr = new PermanentUpgradeManager();
        }

        [Test]
        public void Starts_With_0_Soul_Fragments()
        {
            Assert.AreEqual(0, _mgr.SoulFragments);
        }

        [Test]
        public void AddSoulFragments_Increases_Total()
        {
            _mgr.AddSoulFragments(100);
            Assert.AreEqual(100, _mgr.SoulFragments);
        }

        [Test]
        public void All_Upgrades_Start_At_Level_0()
        {
            Assert.AreEqual(0, _mgr.GetLevel("base_chips"));
            Assert.AreEqual(0, _mgr.GetLevel("max_lives"));
        }

        [Test]
        public void Purchase_Deducts_Fragments_And_Levels_Up()
        {
            _mgr.AddSoulFragments(100);
            bool purchased = _mgr.Purchase("base_chips"); // cost: 20

            Assert.IsTrue(purchased);
            Assert.AreEqual(1, _mgr.GetLevel("base_chips"));
            Assert.AreEqual(80, _mgr.SoulFragments);
        }

        [Test]
        public void Cannot_Purchase_Without_Enough_Fragments()
        {
            _mgr.AddSoulFragments(10);
            bool purchased = _mgr.Purchase("base_chips"); // cost: 20

            Assert.IsFalse(purchased);
            Assert.AreEqual(0, _mgr.GetLevel("base_chips"));
        }

        [Test]
        public void Cannot_Exceed_Max_Level()
        {
            _mgr.AddSoulFragments(100000);
            for (int i = 0; i < 10; i++) _mgr.Purchase("base_chips");

            bool extra = _mgr.Purchase("base_chips");
            Assert.IsFalse(extra);
            Assert.AreEqual(10, _mgr.GetLevel("base_chips"));
        }

        [Test]
        public void GetBonusChips_Reflects_Level()
        {
            _mgr.AddSoulFragments(10000);
            _mgr.Purchase("base_chips"); // level 1
            _mgr.Purchase("base_chips"); // level 2

            Assert.AreEqual(10, _mgr.GetBonusChips()); // 2 * 5
        }

        [Test]
        public void GetExtraLives_Reflects_Level()
        {
            _mgr.AddSoulFragments(10000);
            _mgr.Purchase("max_lives");

            Assert.AreEqual(1, _mgr.GetExtraLives());
        }

        [Test]
        public void HasRevive_Is_False_By_Default()
        {
            Assert.IsFalse(_mgr.HasRevive());
        }

        [Test]
        public void HasRevive_After_Purchase()
        {
            _mgr.AddSoulFragments(2000);
            _mgr.Purchase("revive");

            Assert.IsTrue(_mgr.HasRevive());
        }
    }
}

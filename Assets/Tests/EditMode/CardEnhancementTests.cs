using NUnit.Framework;
using DokkaebiHand.Cards;

namespace DokkaebiHand.Tests
{
    [TestFixture]
    public class CardEnhancementTests
    {
        [Test]
        public void New_Enhancement_Starts_At_Base()
        {
            var enh = new CardEnhancement(0);
            Assert.AreEqual(EnhancementTier.Base, enh.Tier);
        }

        [Test]
        public void Upgrade_Increases_Tier()
        {
            var enh = new CardEnhancement(0);
            Assert.IsTrue(enh.Upgrade());
            Assert.AreEqual(EnhancementTier.Refined, enh.Tier);
            Assert.IsTrue(enh.Upgrade());
            Assert.AreEqual(EnhancementTier.Divine, enh.Tier);
        }

        [Test]
        public void Cannot_Upgrade_Past_Nirvana()
        {
            var enh = new CardEnhancement(0);
            for (int i = 0; i < 4; i++) enh.Upgrade();
            Assert.AreEqual(EnhancementTier.Nirvana, enh.Tier);
            Assert.IsFalse(enh.Upgrade());
        }

        [Test]
        public void ChipBonus_Increases_With_Tier()
        {
            var enh = new CardEnhancement(0);
            Assert.AreEqual(0, enh.GetChipBonus(CardType.Gwang));

            enh.Upgrade(); // Refined
            Assert.AreEqual(10, enh.GetChipBonus(CardType.Gwang));
            Assert.AreEqual(5, enh.GetChipBonus(CardType.Pi));
        }

        [Test]
        public void MultBonus_Starts_At_Divine()
        {
            var enh = new CardEnhancement(0);
            Assert.AreEqual(0, enh.GetMultBonus(CardType.Gwang));

            enh.Upgrade(); // Refined
            Assert.AreEqual(0, enh.GetMultBonus(CardType.Gwang));

            enh.Upgrade(); // Divine
            Assert.AreEqual(1, enh.GetMultBonus(CardType.Gwang));
        }

        [Test]
        public void HasSpecialAbility_From_Divine()
        {
            var enh = new CardEnhancement(0);
            Assert.IsFalse(enh.HasSpecialAbility);

            enh.Upgrade(); // Refined
            Assert.IsFalse(enh.HasSpecialAbility);

            enh.Upgrade(); // Divine
            Assert.IsTrue(enh.HasSpecialAbility);
        }

        [Test]
        public void Max_Two_Seals()
        {
            var enh = new CardEnhancement(0);
            Assert.IsTrue(enh.AddSeal("seal_a"));
            Assert.IsTrue(enh.AddSeal("seal_b"));
            Assert.IsFalse(enh.AddSeal("seal_c"));
        }

        [Test]
        public void Cannot_Add_Duplicate_Seal()
        {
            var enh = new CardEnhancement(0);
            Assert.IsTrue(enh.AddSeal("seal_a"));
            Assert.IsFalse(enh.AddSeal("seal_a"));
        }

        [Test]
        public void MutateMonth_Changes_Month()
        {
            var enh = new CardEnhancement(0);
            Assert.IsNull(enh.MutatedMonth);

            enh.MutateMonth(CardMonth.August);
            Assert.AreEqual(CardMonth.August, enh.MutatedMonth);
        }

        [Test]
        public void Reset_Clears_Everything()
        {
            var enh = new CardEnhancement(0);
            enh.Upgrade();
            enh.Upgrade();
            enh.MutateMonth(CardMonth.March);
            enh.AddSeal("test");

            enh.Reset();

            Assert.AreEqual(EnhancementTier.Base, enh.Tier);
            Assert.IsNull(enh.MutatedMonth);
            Assert.AreEqual(0, enh.Seals.Count);
        }
    }
}

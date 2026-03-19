using NUnit.Framework;
using DokkaebiHand.Core;

namespace DokkaebiHand.Tests
{
    [TestFixture]
    public class WaveUpgradeManagerTests
    {
        private WaveUpgradeManager _waveManager;

        [SetUp]
        public void SetUp()
        {
            _waveManager = new WaveUpgradeManager();
        }

        [Test]
        public void GenerateChoices_Returns_Three_Choices()
        {
            _waveManager.GenerateChoices(1);
            Assert.AreEqual(3, _waveManager.CurrentChoices.Count);
        }

        [Test]
        public void GenerateChoices_HighRealm_May_Include_MegaMult()
        {
            // 10+ 영역에서는 극한 배수가 풀에 추가됨
            bool foundMegaMult = false;
            for (int i = 0; i < 100; i++)
            {
                _waveManager.GenerateChoices(15);
                foreach (var c in _waveManager.CurrentChoices)
                {
                    if (c.Id == "wave_mega_mult")
                    {
                        foundMegaMult = true;
                        break;
                    }
                }
                if (foundMegaMult) break;
            }
            Assert.IsTrue(foundMegaMult, "고렙 영역에서 극한 배수가 나와야 함");
        }

        [Test]
        public void ApplyChoice_Heal_Restores_Lives()
        {
            _waveManager.GenerateChoices(1);

            // 치유 강화를 직접 테스트
            var player = new PlayerState();
            player.Lives = 2;
            var game = new GameManager();

            var healUpgrade = new WaveUpgrade
            {
                Id = "test_heal",
                Apply = (p, g) => p.Lives = System.Math.Min(p.Lives + 2, 6)
            };
            _waveManager.CurrentChoices.Clear();
            _waveManager.CurrentChoices.Add(healUpgrade);

            _waveManager.ApplyChoice(player, game, 0);
            Assert.AreEqual(4, player.Lives);
        }

        [Test]
        public void ApplyChoice_Clears_Choices()
        {
            _waveManager.GenerateChoices(1);
            Assert.AreEqual(3, _waveManager.CurrentChoices.Count);

            var player = new PlayerState();
            var game = new GameManager();
            _waveManager.ApplyChoice(player, game, 0);

            Assert.AreEqual(0, _waveManager.CurrentChoices.Count);
        }

        [Test]
        public void ApplyChoice_Invalid_Index_Returns_False()
        {
            _waveManager.GenerateChoices(1);
            var player = new PlayerState();
            var game = new GameManager();

            Assert.IsFalse(_waveManager.ApplyChoice(player, game, -1));
            Assert.IsFalse(_waveManager.ApplyChoice(player, game, 10));
        }

        [Test]
        public void WaveChipBonus_Accumulates()
        {
            var player = new PlayerState();
            player.WaveChipBonus += 20;
            player.WaveChipBonus += 20;
            Assert.AreEqual(40, player.WaveChipBonus);
        }

        [Test]
        public void WaveMultBonus_Accumulates()
        {
            var player = new PlayerState();
            player.WaveMultBonus += 1;
            player.WaveMultBonus += 3;
            Assert.AreEqual(4, player.WaveMultBonus);
        }

        [Test]
        public void WaveTalismanSlotBonus_Expands_Capacity()
        {
            var player = new PlayerState();
            // 기본 5슬롯
            for (int i = 0; i < 5; i++)
                player.EquipTalisman(new Talismans.TalismanInstance(
                    Talismans.TalismanDatabase.AllTalismans[0]));

            Assert.IsFalse(player.CanEquipTalisman());

            player.WaveTalismanSlotBonus = 1;
            Assert.IsTrue(player.CanEquipTalisman());
        }
    }
}

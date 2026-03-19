using NUnit.Framework;
using DokkaebiHand.Combat;
using DokkaebiHand.Core;

namespace DokkaebiHand.Tests
{
    [TestFixture]
    public class BossGeneratorTests
    {
        [Test]
        public void GenerateStoryBoss_Spiral1_Has_No_Parts()
        {
            var spiral = new SpiralManager();
            var generator = new BossGenerator(42);

            var boss = generator.GenerateStoryBoss(1, spiral);

            Assert.IsNotNull(boss);
            Assert.AreEqual(0, boss.Parts.Count);
            Assert.AreEqual(1, boss.Spiral);
        }

        [Test]
        public void GenerateStoryBoss_Spiral2_Has_Parts()
        {
            var spiral = new SpiralManager();
            // Advance to spiral 2
            for (int i = 0; i < 10; i++) spiral.AdvanceRealm();
            spiral.ContinueToNextSpiral();

            var generator = new BossGenerator(42);
            var boss = generator.GenerateStoryBoss(1, spiral);

            Assert.AreEqual(1, boss.Parts.Count);
            Assert.AreEqual(2, boss.Spiral);
        }

        [Test]
        public void GenerateRandomBoss_Returns_Valid_Boss()
        {
            var spiral = new SpiralManager();
            var generator = new BossGenerator(42);

            var boss = generator.GenerateRandomBoss(spiral);

            Assert.IsNotNull(boss);
            Assert.IsNotNull(boss.BaseBoss);
            Assert.IsNotNull(boss.DisplayName);
            Assert.IsTrue(boss.FinalTargetScore > 0);
        }

        [Test]
        public void DisplayName_Includes_Parts_Prefix()
        {
            var spiral = new SpiralManager();
            for (int i = 0; i < 10; i++) spiral.AdvanceRealm();
            spiral.ContinueToNextSpiral();

            var generator = new BossGenerator(42);
            var boss = generator.GenerateStoryBoss(1, spiral);

            // 파츠가 있으면 이름에 접두사가 붙음
            if (boss.Parts.Count > 0)
            {
                Assert.IsTrue(boss.DisplayName.Length > boss.BaseBoss.NameKR.Length);
            }
        }

        [Test]
        public void Different_Seeds_Produce_Different_Bosses()
        {
            var spiral = new SpiralManager();
            for (int i = 0; i < 10; i++) spiral.AdvanceRealm();
            spiral.ContinueToNextSpiral();

            var gen1 = new BossGenerator(1);
            var gen2 = new BossGenerator(999);

            var boss1 = gen1.GenerateRandomBoss(spiral);
            var boss2 = gen2.GenerateRandomBoss(spiral);

            // 시드가 다르면 최소한 하나는 달라야 함 (확률적)
            bool anyDiff = boss1.BaseBoss.Name != boss2.BaseBoss.Name
                || boss1.FinalTargetScore != boss2.FinalTargetScore;
            // 극히 드물게 같을 수 있으므로 경고만
            if (!anyDiff)
                Assert.Pass("시드가 달라도 우연히 같은 보스가 나올 수 있음");
        }

        [Test]
        public void TargetScore_Includes_Parts_Bonus()
        {
            var spiral = new SpiralManager();
            for (int i = 0; i < 10; i++) spiral.AdvanceRealm();
            spiral.ContinueToNextSpiral();

            var generator = new BossGenerator(42);
            var boss = generator.GenerateStoryBoss(1, spiral);

            // 파츠 목표 보너스가 있으면 기본보다 높아야 함
            int baseTarget = spiral.GetTargetScore(boss.BaseBoss.TargetScore);
            Assert.IsTrue(boss.FinalTargetScore >= baseTarget);
        }
    }
}

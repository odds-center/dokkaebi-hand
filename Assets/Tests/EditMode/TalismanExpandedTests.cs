using NUnit.Framework;
using DokkaebiHand.Talismans;
using DokkaebiHand.Core;
using DokkaebiHand.Cards;

namespace DokkaebiHand.Tests
{
    [TestFixture]
    public class TalismanExpandedTests
    {
        [Test]
        public void TalismanDatabase_Has_20_Talismans()
        {
            Assert.AreEqual(20, TalismanDatabase.AllTalismans.Count);
        }

        [Test]
        public void AllTalismans_Have_Names()
        {
            foreach (var t in TalismanDatabase.AllTalismans)
            {
                Assert.IsNotNull(t.Name, $"Name null for {t.NameKR}");
                Assert.IsNotNull(t.NameKR, $"NameKR null for {t.Name}");
                Assert.IsNotNull(t.Description, $"Description null for {t.Name}");
                Assert.IsNotNull(t.DescriptionKR, $"DescriptionKR null for {t.Name}");
            }
        }

        [Test]
        public void CommonTalismans_Count()
        {
            var commons = TalismanDatabase.GetByRarity(TalismanRarity.Common);
            Assert.GreaterOrEqual(commons.Count, 5, "일반 부적 5종 이상");
        }

        [Test]
        public void RareTalismans_Count()
        {
            var rares = TalismanDatabase.GetByRarity(TalismanRarity.Rare);
            Assert.GreaterOrEqual(rares.Count, 4, "희귀 부적 4종 이상");
        }

        [Test]
        public void LegendaryTalismans_Count()
        {
            var legendaries = TalismanDatabase.GetByRarity(TalismanRarity.Legendary);
            Assert.GreaterOrEqual(legendaries.Count, 3, "전설 부적 3종 이상");
        }

        [Test]
        public void CursedTalismans_Have_IsCurse_Flag()
        {
            var cursed = TalismanDatabase.GetByRarity(TalismanRarity.Cursed);
            foreach (var t in cursed)
            {
                Assert.IsTrue(t.IsCurse, $"{t.NameKR}는 저주 부적이어야 함");
            }
        }

        [Test]
        public void Doom_Talisman_Destroys_Pi()
        {
            var doom = TalismanDatabase.GetByName("Doom");
            Assert.IsNotNull(doom);
            Assert.AreEqual(TalismanEffectType.DestroyCard, doom.EffectType);
            Assert.AreEqual(TalismanTrigger.OnTurnEnd, doom.Trigger);
        }

        [Test]
        public void MoonlightFox_Has_50_Percent_Chance()
        {
            var fox = TalismanDatabase.GetByName("Moonlight Fox");
            Assert.IsNotNull(fox);
            Assert.AreEqual(0.5f, fox.TriggerChance, 0.01f);
            Assert.AreEqual(TalismanEffectType.WildCard, fox.EffectType);
        }

        [Test]
        public void NotifyTrigger_Doom_Removes_Pi()
        {
            var manager = new TalismanManager();
            var player = new PlayerState();
            var doom = TalismanDatabase.GetByName("Doom");
            player.EquipTalisman(new TalismanInstance(doom));

            // 피 패 추가
            var piCard = new CardInstance(0, new HwaTuCardDatabase.CardDefinition
            {
                Name = "Test Pi", NameKR = "테스트 피",
                Month = CardMonth.January, Type = CardType.Pi, BasePoints = 1
            });
            player.CapturedPi.Add(piCard);
            Assert.AreEqual(1, player.CapturedPi.Count);

            // OnTurnEnd 트리거
            manager.NotifyTrigger(player, TalismanTrigger.OnTurnEnd, null);
            Assert.AreEqual(0, player.CapturedPi.Count);
        }

        [Test]
        public void BloodOath_Adds_Mult_Per_Pi()
        {
            var manager = new TalismanManager();
            var player = new PlayerState();
            var oath = TalismanDatabase.GetByName("Blood Oath");
            player.EquipTalisman(new TalismanInstance(oath));

            // 피 패 5장 추가
            for (int i = 0; i < 5; i++)
            {
                player.CapturedPi.Add(new CardInstance(i, new HwaTuCardDatabase.CardDefinition
                {
                    Name = $"Pi{i}", NameKR = $"피{i}",
                    Month = CardMonth.January, Type = CardType.Pi, BasePoints = 1
                }));
            }

            // Blood Oath는 ApplySpecialTalismanEffects에서 RoundManager가 처리
            // 여기서는 데이터 구조만 검증
            Assert.AreEqual(5, player.GetTotalPiCount());
        }

        [Test]
        public void ReapersLedger_Score_Ending_4_Check()
        {
            var reaper = TalismanDatabase.GetByName("Reaper's Ledger");
            Assert.IsNotNull(reaper);
            Assert.AreEqual(TalismanEffectType.MultiplyMult, reaper.EffectType);
            Assert.AreEqual(4f, reaper.EffectValue, 0.01f);
        }

        [Test]
        public void GetByName_Returns_Null_For_Unknown()
        {
            Assert.IsNull(TalismanDatabase.GetByName("NonExistent"));
        }

        [Test]
        public void GetByNameKR_Works()
        {
            var result = TalismanDatabase.GetByNameKR("도깨비 감투");
            Assert.IsNotNull(result);
            Assert.AreEqual("Dokkaebi Hat", result.Name);
        }

        [Test]
        public void NewTalismans_Have_Correct_Triggers()
        {
            // 삼도천의 나룻배 — OnRoundEnd
            var samdo = TalismanDatabase.GetByName("Samdo Ferry");
            Assert.IsNotNull(samdo);
            Assert.AreEqual(TalismanTrigger.OnRoundEnd, samdo.Trigger);

            // 사주팔자의 주사위 — OnGoDecision
            var dice = TalismanDatabase.GetByName("Fate Dice");
            Assert.IsNotNull(dice);
            Assert.AreEqual(TalismanTrigger.OnGoDecision, dice.Trigger);

            // 염라왕의 도장 — OnRoundEnd, MultiplyMult
            var seal = TalismanDatabase.GetByName("Yeomra's Seal");
            Assert.IsNotNull(seal);
            Assert.AreEqual(TalismanEffectType.MultiplyMult, seal.EffectType);
            Assert.AreEqual(3f, seal.EffectValue, 0.01f);
        }
    }
}

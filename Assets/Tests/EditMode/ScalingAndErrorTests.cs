using System;
using System.Collections.Generic;
using System.Linq;
using NUnit.Framework;
using DokkaebiHand.Cards;
using DokkaebiHand.Combat;
using DokkaebiHand.Core;
using DokkaebiHand.Talismans;

namespace DokkaebiHand.Tests
{
    /// <summary>
    /// 스케일링 + 에러 스트레스 테스트.
    /// 모든 성장 시스템이 실제 데미지에 반영되는지, 그리고
    /// 극한/비정상 입력에서 크래시 없이 동작하는지 검증.
    /// </summary>
    [TestFixture]
    public class ScalingAndErrorTests
    {
        // =============================================
        // 스케일링 검증: 웨이브 강화가 데미지에 반영되는가
        // =============================================

        [Test]
        public void WaveChipBonus_Increases_Damage()
        {
            // 웨이브 칩 보너스 없이
            var dmg1 = MeasureDamage(waveChips: 0, waveMult: 0);
            // 웨이브 칩 +50
            var dmg2 = MeasureDamage(waveChips: 50, waveMult: 0);

            Assert.IsTrue(dmg2 > dmg1,
                $"WaveChipBonus +50 → 데미지 증가해야 함. 없이:{dmg1}, 있음:{dmg2}");
        }

        [Test]
        public void WaveMultBonus_Increases_Damage()
        {
            var dmg1 = MeasureDamage(waveChips: 0, waveMult: 0);
            var dmg2 = MeasureDamage(waveChips: 0, waveMult: 3);

            Assert.IsTrue(dmg2 > dmg1,
                $"WaveMultBonus +3 → 데미지 증가해야 함. 없이:{dmg1}, 있음:{dmg2}");
        }

        [Test]
        public void PermanentChips_Increases_Damage()
        {
            // 영구강화 칩 레벨 0
            var dmg1 = MeasureDamageWithUpgrade("base_chips", 0);
            // 영구강화 칩 레벨 5 (= +25칩)
            var dmg2 = MeasureDamageWithUpgrade("base_chips", 5);

            Assert.IsTrue(dmg2 > dmg1,
                $"PermanentChips Lv5 → 데미지 증가해야 함. Lv0:{dmg1}, Lv5:{dmg2}");
        }

        [Test]
        public void PermanentMult_Increases_Damage()
        {
            var dmg1 = MeasureDamageWithUpgrade("base_mult", 0);
            var dmg2 = MeasureDamageWithUpgrade("base_mult", 3);

            Assert.IsTrue(dmg2 > dmg1,
                $"PermanentMult Lv3 → 데미지 증가해야 함. Lv0:{dmg1}, Lv3:{dmg2}");
        }

        [Test]
        public void Combined_Scaling_Stacks()
        {
            var dmgBase = MeasureDamage(0, 0);
            var dmgWave = MeasureDamage(30, 2);

            // 영구+웨이브 동시
            var player = new PlayerState();
            player.WaveChipBonus = 30;
            player.WaveMultBonus = 2;
            var deck = new DeckManager(42);
            var tm = new TalismanManager();
            var upgrades = new PermanentUpgradeManager();
            upgrades.SetLevel("base_chips", 3);  // +15칩
            upgrades.SetLevel("base_mult", 2);   // +2배수

            var rm = new RoundManager(player, deck, tm, null, null, upgrades);
            rm.StartRound();

            Assert.IsTrue(rm.AccumulatedChips >= 30 + 15,
                $"AccumulatedChips에 웨이브(30)+영구(15) 반영. 실제:{rm.AccumulatedChips}");
            Assert.IsTrue(rm.AccumulatedMult >= 1f + 2 + 2,
                $"AccumulatedMult에 웨이브(2)+영구(2) 반영. 실제:{rm.AccumulatedMult}");
        }

        [Test]
        public void BossHP_Scales_With_Spiral()
        {
            var boss = BossDatabase.GetBoss(0); // 먹보
            var hp1 = new BossBattle(boss, 1).BossMaxHP;
            var hp2 = new BossBattle(boss, 2).BossMaxHP;
            var hp3 = new BossBattle(boss, 3).BossMaxHP;
            var hp5 = new BossBattle(boss, 5).BossMaxHP;

            Assert.IsTrue(hp2 > hp1, $"나선2({hp2}) > 나선1({hp1})");
            Assert.IsTrue(hp3 > hp2, $"나선3({hp3}) > 나선2({hp2})");
            Assert.IsTrue(hp5 > hp3, $"나선5({hp5}) > 나선3({hp3})");

            // 1.8배 성장 확인
            float ratio = (float)hp2 / hp1;
            Assert.IsTrue(ratio >= 1.7f && ratio <= 1.9f,
                $"나선 2/1 비율은 ~1.8이어야 함. 실제:{ratio:F2}");
        }

        // =============================================
        // 에러/크래시 테스트: 비정상 입력
        // =============================================

        [Test]
        public void Attack_With_Null_Cards_NoCrash()
        {
            var gm = new GameManager();
            gm.StartNewGame();
            gm.BeginSpiralWithBlessing(null);

            var result = gm.SeotdaAttack(null, null);
            Assert.AreEqual(0, result.FinalDamage);
            Assert.IsTrue(gm.Player.Lives >= 0);
        }

        [Test]
        public void Attack_With_Same_Card_NoCrash()
        {
            var gm = new GameManager();
            gm.StartNewGame();
            gm.BeginSpiralWithBlessing(null);

            var rm = gm.RoundManager;
            rm.SubmitCards(new List<CardInstance> { rm.HandCards[0] });
            if (rm.CurrentPhase == RoundManager.Phase.GoStopChoice) rm.SelectStop();

            if (rm.CurrentPhase == RoundManager.Phase.AttackSelect && rm.HandCards.Count >= 1)
            {
                var card = rm.HandCards[0];
                var result = gm.SeotdaAttack(card, card); // 같은 카드!
                Assert.AreEqual(0, result.FinalDamage);
            }
        }

        [Test]
        public void Submit_Empty_Cards_NoCrash()
        {
            var gm = new GameManager();
            gm.StartNewGame();
            gm.BeginSpiralWithBlessing(null);

            var rm = gm.RoundManager;
            var result = rm.SubmitCards(new List<CardInstance>());
            Assert.AreEqual(0, result.Count);
            Assert.AreEqual(RoundManager.Phase.SelectCards, rm.CurrentPhase);
        }

        [Test]
        public void Submit_Null_NoCrash()
        {
            var gm = new GameManager();
            gm.StartNewGame();
            gm.BeginSpiralWithBlessing(null);

            var rm = gm.RoundManager;
            var result = rm.SubmitCards(null);
            Assert.AreEqual(0, result.Count);
        }

        [Test]
        public void Submit_More_Cards_Than_Hand_Minus_2_Blocked()
        {
            var gm = new GameManager();
            gm.StartNewGame();
            gm.BeginSpiralWithBlessing(null);

            var rm = gm.RoundManager;
            // 손패 전부 제출 시도 (공격용 2장 미확보)
            var allCards = new List<CardInstance>(rm.HandCards);
            var result = rm.SubmitCards(allCards);
            Assert.AreEqual(0, result.Count, "공격용 2장 미확보 시 차단");
        }

        [Test]
        public void Go_In_Wrong_Phase_NoCrash()
        {
            var gm = new GameManager();
            gm.StartNewGame();
            gm.BeginSpiralWithBlessing(null);

            // SelectCards 상태에서 Go 시도
            int dmg = gm.RoundManager.SelectGo();
            Assert.AreEqual(0, dmg, "잘못된 페이즈에서 Go → 0");
        }

        [Test]
        public void Stop_In_Wrong_Phase_NoCrash()
        {
            var gm = new GameManager();
            gm.StartNewGame();
            gm.BeginSpiralWithBlessing(null);

            // SelectCards 상태에서 Stop 시도
            gm.RoundManager.SelectStop();
            Assert.AreEqual(RoundManager.Phase.SelectCards, gm.RoundManager.CurrentPhase);
        }

        [Test]
        public void Attack_In_Wrong_Phase_NoCrash()
        {
            var gm = new GameManager();
            gm.StartNewGame();
            gm.BeginSpiralWithBlessing(null);

            var rm = gm.RoundManager;
            // SelectCards 상태에서 공격 시도
            var result = rm.ExecuteAttack(rm.HandCards[0], rm.HandCards[1]);
            Assert.AreEqual(0, result.FinalDamage, "잘못된 페이즈에서 공격 → 0");
        }

        [Test]
        public void SubmitCards_With_FakeCard_NotInHand_Blocked()
        {
            var gm = new GameManager();
            gm.StartNewGame();
            gm.BeginSpiralWithBlessing(null);

            var fakeCard = new CardInstance(999, new HwaTuCardDatabase.CardDefinition
            {
                Name = "fake", NameKR = "가짜", Month = CardMonth.January,
                Type = CardType.Pi, BasePoints = 1
            });

            var rm = gm.RoundManager;
            var result = rm.SubmitCards(new List<CardInstance> { fakeCard });
            Assert.AreEqual(0, result.Count, "손패에 없는 카드 제출 차단");
        }

        [Test]
        public void ShopPurchase_WithoutEnoughYeop_Fails()
        {
            var gm = new GameManager();
            gm.StartNewGame();
            gm.BeginSpiralWithBlessing(null);
            gm.Player.Yeop = 0; // 엽전 0

            gm.OpenShop();
            bool bought = gm.ShopPurchase(0);
            Assert.IsFalse(bought, "엽전 부족 시 구매 실패");
        }

        [Test]
        public void ShopPurchase_InvalidIndex_NoCrash()
        {
            var gm = new GameManager();
            gm.StartNewGame();
            gm.BeginSpiralWithBlessing(null);

            gm.OpenShop();
            bool bought = gm.ShopPurchase(999);
            Assert.IsFalse(bought, "범위 초과 인덱스 → 실패");
        }

        [Test]
        public void EventChoice_InvalidIndex_NoCrash()
        {
            var gm = new GameManager();
            gm.StartNewGame();
            gm.BeginSpiralWithBlessing(null);

            gm.Events.GenerateEvent(1);
            string result = gm.ExecuteEventChoice(999);
            Assert.AreEqual("", result, "범위 초과 이벤트 선택 → 빈 문자열");
        }

        [Test]
        public void EventChoice_NegativeIndex_NoCrash()
        {
            var gm = new GameManager();
            gm.StartNewGame();
            gm.BeginSpiralWithBlessing(null);

            gm.Events.GenerateEvent(1);
            string result = gm.ExecuteEventChoice(-1);
            Assert.AreEqual("", result);
        }

        [Test]
        public void Lives_Zero_Triggers_GameOver()
        {
            var gm = new GameManager();
            gm.StartNewGame();
            gm.BeginSpiralWithBlessing(null);

            gm.Player.Lives = 1;
            // 패배로 FinishRound
            gm.RoundManager.FinishRound(false);

            Assert.AreEqual(0, gm.Player.Lives);
            Assert.AreEqual(GameState.GameOver, gm.CurrentState);
        }

        [Test]
        public void DoubleFinishRound_NoCrash()
        {
            var gm = new GameManager();
            gm.StartNewGame();
            gm.BeginSpiralWithBlessing(null);

            gm.RoundManager.FinishRound(true);
            // 두 번째 FinishRound — 크래시 안 되어야 함
            gm.RoundManager.FinishRound(true);

            Assert.IsTrue(gm.Player.Lives >= 0);
        }

        [Test]
        public void WaveUpgrade_InvalidIndex_NoCrash()
        {
            var gm = new GameManager();
            gm.StartNewGame();
            gm.BeginSpiralWithBlessing(null);

            gm.WaveUpgrades.GenerateChoices(1);
            bool applied = gm.WaveUpgrades.ApplyChoice(gm.Player, gm, 999);
            Assert.IsFalse(applied, "범위 초과 강화 선택 → 실패");
        }

        [Test]
        public void EquipTalisman_BeyondMaxSlots_Blocked()
        {
            var player = new PlayerState();
            player.PermanentTalismanSlotBonus = 0;
            player.WaveTalismanSlotBonus = 0;

            var tData = TalismanDatabase.AllTalismans[0];
            // MaxTalismanSlots = 5
            for (int i = 0; i < 5; i++)
                player.EquipTalisman(new TalismanInstance(tData));

            // 6번째 → 차단
            bool result = player.EquipTalisman(new TalismanInstance(tData));
            Assert.IsFalse(result, "슬롯 초과 시 장착 차단");
            Assert.AreEqual(5, player.Talismans.Count);
        }

        [Test]
        public void CurseTalisman_BypassesSlotLimit()
        {
            var player = new PlayerState();
            for (int i = 0; i < 5; i++)
                player.EquipTalisman(new TalismanInstance(TalismanDatabase.AllTalismans[0]));

            // 저주 부적은 슬롯 무시
            var curse = new TalismanData
            {
                Name = "TestCurse", NameKR = "테스트 저주",
                IsCurse = true, EffectType = TalismanEffectType.AddChips, EffectValue = -10
            };
            bool result = player.EquipTalisman(new TalismanInstance(curse));
            Assert.IsTrue(result, "저주 부적은 슬롯 무시");
            Assert.AreEqual(6, player.Talismans.Count);
        }

        [Test]
        public void Rapid_Go3_Stress_NoCrash()
        {
            // Go 3를 연속 시도 — 즉사 판정 스트레스
            for (int seed = 0; seed < 20; seed++)
            {
                var gm = new GameManager();
                gm.StartNewGame();
                gm.BeginSpiralWithBlessing(null);

                var rm = gm.RoundManager;
                for (int go = 0; go < 5; go++)
                {
                    if (rm.CurrentPhase == RoundManager.Phase.SelectCards && rm.HandCards.Count >= 3)
                    {
                        rm.SubmitCards(new List<CardInstance> { rm.HandCards[0] });
                    }
                    if (rm.CurrentPhase == RoundManager.Phase.GoStopChoice)
                    {
                        int bossDmg = rm.SelectGo();
                        gm.ApplyGoDamage(bossDmg);
                    }
                    if (gm.CurrentState == GameState.GameOver) break;
                }
                // 크래시 없이 도달
                Assert.IsTrue(gm.Player.Lives >= 0);
            }
        }

        [Test]
        public void Full10Realms_AllStatesReached()
        {
            var gm = new GameManager();
            var states = new HashSet<GameState>();
            gm.OnGameStateChanged += s => states.Add(s);

            gm.StartNewGame();
            gm.BeginSpiralWithBlessing(null);

            // 10관문 즉사 클리어
            for (int i = 0; i < 10; i++)
            {
                if (gm.CurrentState != GameState.InRound) break;
                if (gm.CurrentBattle != null)
                    gm.CurrentBattle.DealDamage(new ScoringEngine.ScoreResult
                    { FinalScore = gm.CurrentBattle.BossMaxHP });

                var rm = gm.RoundManager;
                if (rm != null && rm.HandCards.Count >= 3)
                {
                    rm.SubmitCards(new List<CardInstance> { rm.HandCards[0] });
                    if (rm.CurrentPhase == RoundManager.Phase.GoStopChoice) rm.SelectStop();
                    if (rm.CurrentPhase == RoundManager.Phase.AttackSelect && rm.HandCards.Count >= 2)
                        gm.SeotdaAttack(rm.HandCards[0], rm.HandCards[1]);
                }

                if (gm.CurrentState == GameState.PostRound) gm.SkipWaveUpgrade();
                if (gm.CurrentState == GameState.Shop) gm.LeaveShop();
                if (gm.CurrentState == GameState.Event)
                {
                    gm.ExecuteEventChoice(0);
                    if (gm.CurrentState == GameState.Event) gm.LeaveEvent();
                }
                if (gm.CurrentState == GameState.Gate) break;
            }

            Assert.IsTrue(states.Contains(GameState.SpiralStart), "SpiralStart 도달");
            Assert.IsTrue(states.Contains(GameState.InRound), "InRound 도달");
            Assert.IsTrue(states.Contains(GameState.PostRound), "PostRound 도달");
        }

        // =============================================
        // Helper
        // =============================================

        private int MeasureDamage(int waveChips, int waveMult)
        {
            var player = new PlayerState();
            player.WaveChipBonus = waveChips;
            player.WaveMultBonus = waveMult;
            var deck = new DeckManager(42);
            var tm = new TalismanManager();
            var rm = new RoundManager(player, deck, tm);
            rm.StartRound();

            // 1장 내기
            rm.SubmitCards(new List<CardInstance> { rm.HandCards[0] });
            if (rm.CurrentPhase == RoundManager.Phase.GoStopChoice) rm.SelectStop();

            if (rm.CurrentPhase == RoundManager.Phase.AttackSelect && rm.HandCards.Count >= 2)
            {
                var result = rm.ExecuteAttack(rm.HandCards[0], rm.HandCards[1]);
                return result.FinalDamage;
            }
            return 0;
        }

        private int MeasureDamageWithUpgrade(string upgradeId, int level)
        {
            var player = new PlayerState();
            var deck = new DeckManager(42);
            var tm = new TalismanManager();
            var upgrades = new PermanentUpgradeManager();
            upgrades.SetLevel(upgradeId, level);
            var rm = new RoundManager(player, deck, tm, null, null, upgrades);
            rm.StartRound();

            rm.SubmitCards(new List<CardInstance> { rm.HandCards[0] });
            if (rm.CurrentPhase == RoundManager.Phase.GoStopChoice) rm.SelectStop();

            if (rm.CurrentPhase == RoundManager.Phase.AttackSelect && rm.HandCards.Count >= 2)
            {
                var result = rm.ExecuteAttack(rm.HandCards[0], rm.HandCards[1]);
                return result.FinalDamage;
            }
            return 0;
        }
    }
}

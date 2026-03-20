using System.Collections.Generic;
using NUnit.Framework;
using DokkaebiHand.Cards;
using DokkaebiHand.Combat;
using DokkaebiHand.Core;
using DokkaebiHand.Talismans;

namespace DokkaebiHand.Tests
{
    [TestFixture]
    public class CombatFlowTests
    {
        // === Helper: CardInstance 생성 ===
        private static CardInstance MakeCard(int id, CardMonth month, CardType type,
            RibbonType ribbon = RibbonType.None, bool isRainGwang = false, bool isDoublePi = false)
        {
            var def = new HwaTuCardDatabase.CardDefinition
            {
                Name = $"Test_{id}",
                NameKR = $"테스트_{id}",
                Month = month,
                Type = type,
                Ribbon = ribbon,
                BasePoints = type == CardType.Gwang ? 20 : (type == CardType.Pi ? 1 : 10),
                IsRainGwang = isRainGwang,
                IsDoublePi = isDoublePi
            };
            return new CardInstance(id, def);
        }

        private static RoundManager CreateRoundManager(PlayerState player = null, DeckManager deck = null)
        {
            player = player ?? new PlayerState();
            deck = deck ?? new DeckManager(42);
            var talismanMgr = new TalismanManager();
            return new RoundManager(player, deck, talismanMgr);
        }

        // =============================================
        // Phase Transition Tests
        // =============================================

        [Test]
        public void StartRound_Sets_Phase_To_SelectCards()
        {
            var player = new PlayerState();
            var deck = new DeckManager(42);
            var rm = CreateRoundManager(player, deck);

            rm.StartRound();

            Assert.AreEqual(RoundManager.Phase.SelectCards, rm.CurrentPhase);
        }

        [Test]
        public void StartRound_Deals_10_Cards_To_Hand()
        {
            var player = new PlayerState();
            var deck = new DeckManager(42);
            var rm = CreateRoundManager(player, deck);

            rm.StartRound();

            Assert.AreEqual(10, rm.HandCards.Count);
        }

        [Test]
        public void StartRound_Resets_Accumulation()
        {
            var player = new PlayerState();
            var deck = new DeckManager(42);
            var rm = CreateRoundManager(player, deck);

            rm.StartRound();

            Assert.AreEqual(0, rm.AccumulatedChips);
            Assert.AreEqual(1f, rm.AccumulatedMult);
            Assert.AreEqual(0, rm.GoCount);
            Assert.AreEqual(0, rm.PlaysUsed);
            Assert.AreEqual(0, rm.AccumulatedCombos.Count);
        }

        [Test]
        public void SubmitCards_Transitions_To_GoStopChoice()
        {
            var player = new PlayerState();
            var deck = new DeckManager(42);
            var rm = CreateRoundManager(player, deck);
            rm.StartRound();

            // 1장 선택하여 제출
            var selected = new List<CardInstance> { rm.HandCards[0] };
            rm.SubmitCards(selected);

            Assert.AreEqual(RoundManager.Phase.GoStopChoice, rm.CurrentPhase);
        }

        [Test]
        public void SubmitCards_Removes_Selected_From_Hand()
        {
            var player = new PlayerState();
            var deck = new DeckManager(42);
            var rm = CreateRoundManager(player, deck);
            rm.StartRound();

            var card = rm.HandCards[0];
            var selected = new List<CardInstance> { card };
            rm.SubmitCards(selected);

            Assert.IsFalse(rm.HandCards.Contains(card));
            Assert.AreEqual(9, rm.HandCards.Count);
        }

        [Test]
        public void SubmitCards_Increments_PlaysUsed()
        {
            var player = new PlayerState();
            var deck = new DeckManager(42);
            var rm = CreateRoundManager(player, deck);
            rm.StartRound();

            var selected = new List<CardInstance> { rm.HandCards[0] };
            rm.SubmitCards(selected);

            Assert.AreEqual(1, rm.PlaysUsed);
        }

        [Test]
        public void SubmitCards_MaxPlays_Forces_AttackSelect()
        {
            var player = new PlayerState();
            var deck = new DeckManager(42);
            var rm = CreateRoundManager(player, deck);
            rm.MaxPlays = 2;
            rm.StartRound();

            // Play 1
            rm.SubmitCards(new List<CardInstance> { rm.HandCards[0] });
            Assert.AreEqual(RoundManager.Phase.GoStopChoice, rm.CurrentPhase);

            // Stop
            rm.SelectStop();

            // Play 2 (last play) -> forced to AttackSelect
            rm.SubmitCards(new List<CardInstance> { rm.HandCards[0] });
            Assert.AreEqual(RoundManager.Phase.AttackSelect, rm.CurrentPhase);
        }

        [Test]
        public void SubmitCards_Wrong_Phase_Returns_Empty()
        {
            var player = new PlayerState();
            var deck = new DeckManager(42);
            var rm = CreateRoundManager(player, deck);
            rm.StartRound();

            // Submit once -> GoStopChoice
            rm.SubmitCards(new List<CardInstance> { rm.HandCards[0] });
            Assert.AreEqual(RoundManager.Phase.GoStopChoice, rm.CurrentPhase);

            // Try submit again in GoStopChoice -> should return empty
            var result = rm.SubmitCards(new List<CardInstance> { rm.HandCards[0] });
            Assert.AreEqual(0, result.Count);
        }

        [Test]
        public void SubmitCards_Empty_Selection_Returns_Empty()
        {
            var rm = CreateRoundManager();
            rm.StartRound();

            var result = rm.SubmitCards(new List<CardInstance>());
            Assert.AreEqual(0, result.Count);
        }

        [Test]
        public void SubmitCards_Over5_Returns_Empty()
        {
            var rm = CreateRoundManager();
            rm.StartRound();

            // Try to submit 6 cards
            var selected = new List<CardInstance>();
            for (int i = 0; i < 6 && i < rm.HandCards.Count; i++)
                selected.Add(rm.HandCards[i]);

            var result = rm.SubmitCards(selected);
            Assert.AreEqual(0, result.Count);
        }

        // =============================================
        // Go Mechanics Tests
        // =============================================

        [Test]
        public void SelectGo_Returns_To_SelectCards()
        {
            var rm = CreateRoundManager();
            rm.StartRound();

            rm.SubmitCards(new List<CardInstance> { rm.HandCards[0] });
            Assert.AreEqual(RoundManager.Phase.GoStopChoice, rm.CurrentPhase);

            rm.SelectGo();
            Assert.AreEqual(RoundManager.Phase.SelectCards, rm.CurrentPhase);
        }

        [Test]
        public void SelectGo_Increments_GoCount()
        {
            var rm = CreateRoundManager();
            rm.StartRound();

            rm.SubmitCards(new List<CardInstance> { rm.HandCards[0] });
            rm.SelectGo();

            Assert.AreEqual(1, rm.GoCount);
        }

        [Test]
        public void SelectGo_Draws_Cards()
        {
            var rm = CreateRoundManager();
            rm.StartRound();
            int handBefore = rm.HandCards.Count;

            rm.SubmitCards(new List<CardInstance> { rm.HandCards[0] });
            int handAfterSubmit = rm.HandCards.Count;

            rm.SelectGo(); // Go 1: +3 cards
            int handAfterGo = rm.HandCards.Count;

            Assert.AreEqual(handBefore - 1, handAfterSubmit, "Submit removes 1 card");
            Assert.AreEqual(handAfterSubmit + 3, handAfterGo, "Go 1 draws 3 cards");
        }

        [Test]
        public void SelectGo_Returns_BossDamage()
        {
            var rm = CreateRoundManager();
            rm.StartRound();

            rm.SubmitCards(new List<CardInstance> { rm.HandCards[0] });
            int dmg1 = rm.SelectGo();
            Assert.AreEqual(5, dmg1, "Go 1: 5 damage");

            rm.SubmitCards(new List<CardInstance> { rm.HandCards[0] });
            int dmg2 = rm.SelectGo();
            Assert.AreEqual(15, dmg2, "Go 2: 15 damage");

            rm.SubmitCards(new List<CardInstance> { rm.HandCards[0] });
            int dmg3 = rm.SelectGo();
            Assert.AreEqual(30, dmg3, "Go 3: 30 damage");
        }

        [Test]
        public void SelectGo_Wrong_Phase_Returns_Zero()
        {
            var rm = CreateRoundManager();
            rm.StartRound();

            // Phase is SelectCards, not GoStopChoice
            int dmg = rm.SelectGo();
            Assert.AreEqual(0, dmg);
        }

        // =============================================
        // Stop Mechanics Tests
        // =============================================

        [Test]
        public void SelectStop_Transitions_To_AttackSelect()
        {
            var rm = CreateRoundManager();
            rm.StartRound();

            rm.SubmitCards(new List<CardInstance> { rm.HandCards[0] });
            rm.SelectStop();

            Assert.AreEqual(RoundManager.Phase.AttackSelect, rm.CurrentPhase);
        }

        [Test]
        public void SelectStop_Wrong_Phase_Does_Nothing()
        {
            var rm = CreateRoundManager();
            rm.StartRound();

            // Phase is SelectCards
            rm.SelectStop();
            Assert.AreEqual(RoundManager.Phase.SelectCards, rm.CurrentPhase);
        }

        // =============================================
        // Attack / Damage Tests
        // =============================================

        [Test]
        public void ExecuteAttack_Calculates_Damage()
        {
            var rm = CreateRoundManager();
            rm.StartRound();

            // Submit a card to accumulate some synergy
            rm.SubmitCards(new List<CardInstance> { rm.HandCards[0] });
            rm.SelectStop();

            Assert.AreEqual(RoundManager.Phase.AttackSelect, rm.CurrentPhase);

            // Select 2 cards for attack
            var card1 = rm.HandCards[0];
            var card2 = rm.HandCards[1];
            var result = rm.ExecuteAttack(card1, card2);

            Assert.IsTrue(result.FinalDamage > 0, "Damage should be positive");
            Assert.IsNotNull(result.SeotdaName);
        }

        [Test]
        public void ExecuteAttack_Removes_Cards_From_Hand()
        {
            var rm = CreateRoundManager();
            rm.StartRound();

            rm.SubmitCards(new List<CardInstance> { rm.HandCards[0] });
            rm.SelectStop();

            var card1 = rm.HandCards[0];
            var card2 = rm.HandCards[1];
            int handBefore = rm.HandCards.Count;

            rm.ExecuteAttack(card1, card2);

            Assert.AreEqual(handBefore - 2, rm.HandCards.Count);
            Assert.IsFalse(rm.HandCards.Contains(card1));
            Assert.IsFalse(rm.HandCards.Contains(card2));
        }

        [Test]
        public void ExecuteAttack_Wrong_Phase_Returns_Zero()
        {
            var rm = CreateRoundManager();
            rm.StartRound();

            // Phase is SelectCards, not AttackSelect
            var card1 = rm.HandCards[0];
            var card2 = rm.HandCards[1];
            var result = rm.ExecuteAttack(card1, card2);

            Assert.AreEqual(0, result.FinalDamage);
        }

        [Test]
        public void ExecuteAttack_Same_Card_Returns_Zero()
        {
            var rm = CreateRoundManager();
            rm.StartRound();

            rm.SubmitCards(new List<CardInstance> { rm.HandCards[0] });
            rm.SelectStop();

            var card1 = rm.HandCards[0];
            var result = rm.ExecuteAttack(card1, card1);

            Assert.AreEqual(0, result.FinalDamage);
        }

        [Test]
        public void ExecuteAttack_GoMultiplier_Applied()
        {
            var player = new PlayerState();
            var deck = new DeckManager(42);
            var rm = CreateRoundManager(player, deck);
            rm.StartRound();

            // Submit -> Go -> Submit -> Stop
            rm.SubmitCards(new List<CardInstance> { rm.HandCards[0] });
            rm.SelectGo();
            rm.SubmitCards(new List<CardInstance> { rm.HandCards[0] });
            rm.SelectStop();

            Assert.AreEqual(1, rm.GoCount, "Go count should be 1");

            var card1 = rm.HandCards[0];
            var card2 = rm.HandCards[1];
            var result = rm.ExecuteAttack(card1, card2);

            Assert.AreEqual(2f, result.GoMult, "Go 1 multiplier should be 2x");
        }

        // =============================================
        // FinishRound Tests
        // =============================================

        [Test]
        public void FinishRound_Sets_Phase_RoundEnd()
        {
            var rm = CreateRoundManager();
            rm.StartRound();

            rm.FinishRound(true);

            Assert.AreEqual(RoundManager.Phase.RoundEnd, rm.CurrentPhase);
        }

        [Test]
        public void FinishRound_Fires_OnRoundEnded_Event()
        {
            var rm = CreateRoundManager();
            rm.StartRound();

            bool eventFired = false;
            bool eventWon = false;
            rm.OnRoundEnded += won =>
            {
                eventFired = true;
                eventWon = won;
            };

            rm.FinishRound(true);

            Assert.IsTrue(eventFired);
            Assert.IsTrue(eventWon);
        }

        // =============================================
        // Boss HP Tests
        // =============================================

        [Test]
        public void BossBattle_DealDamage_Reduces_HP()
        {
            var boss = new BossDefinition
            {
                Id = "test_boss",
                Name = "TestBoss",
                NameKR = "테스트 보스",
                TargetScore = 100,
                Rounds = 3,
                Gimmick = BossGimmick.None,
                IntroDialogue = "test",
                DefeatDialogue = "test",
                VictoryDialogue = "test",
                YeopReward = 50
            };
            var battle = new BossBattle(boss, 1);
            int maxHP = battle.BossMaxHP;

            Assert.IsTrue(maxHP > 0, "Boss should have HP");
            Assert.IsFalse(battle.IsBossDefeated);

            battle.DealDamage(new ScoringEngine.ScoreResult { FinalScore = 100 });

            Assert.AreEqual(maxHP - 100, battle.BossCurrentHP);
            Assert.IsFalse(battle.IsBossDefeated);
        }

        [Test]
        public void BossBattle_DealDamage_Boss_Defeated_At_Zero()
        {
            var boss = new BossDefinition
            {
                Id = "test_boss",
                Name = "TestBoss",
                NameKR = "테스트 보스",
                TargetScore = 100,
                Rounds = 3,
                Gimmick = BossGimmick.None,
                IntroDialogue = "test",
                DefeatDialogue = "test",
                VictoryDialogue = "test",
                YeopReward = 50
            };
            var battle = new BossBattle(boss, 1);

            // Deal enough damage to kill
            battle.DealDamage(new ScoringEngine.ScoreResult { FinalScore = battle.BossMaxHP + 100 });

            Assert.IsTrue(battle.IsBossDefeated);
            Assert.AreEqual(0, battle.BossCurrentHP);
        }

        [Test]
        public void BossBattle_DefeatedEvent_Fires()
        {
            var boss = new BossDefinition
            {
                Id = "test_boss",
                Name = "TestBoss",
                NameKR = "테스트 보스",
                TargetScore = 100,
                Rounds = 3,
                Gimmick = BossGimmick.None,
                IntroDialogue = "test",
                DefeatDialogue = "test",
                VictoryDialogue = "test",
                YeopReward = 50
            };
            var battle = new BossBattle(boss, 1);

            bool defeated = false;
            battle.OnBossDefeated += () => defeated = true;

            battle.DealDamage(new ScoringEngine.ScoreResult { FinalScore = battle.BossMaxHP });

            Assert.IsTrue(defeated);
        }

        // =============================================
        // HandEvaluator Tests
        // =============================================

        [Test]
        public void HandEvaluator_SingleCard_Returns_SingleCombo()
        {
            var card = MakeCard(0, CardMonth.January, CardType.Gwang);
            var combos = HandEvaluator.Evaluate(new List<CardInstance> { card });

            Assert.IsTrue(combos.Count > 0, "Single card should return at least one combo");
            Assert.IsTrue(combos.Exists(c => c.Id == "single"), "Should have 'single' combo");
        }

        [Test]
        public void HandEvaluator_MonthPair_Detected()
        {
            var card1 = MakeCard(0, CardMonth.January, CardType.Gwang);
            var card2 = MakeCard(1, CardMonth.January, CardType.Pi);
            var combos = HandEvaluator.Evaluate(new List<CardInstance> { card1, card2 });

            // Should detect month pair (1월 2장) and possibly 1땡
            bool hasMonthPair = combos.Exists(c =>
                c.Category == ComboCategory.MonthPair || c.Category == ComboCategory.Seotda);
            Assert.IsTrue(hasMonthPair, "Two cards of same month should trigger month pair or ttaeng");
        }

        [Test]
        public void HandEvaluator_38GwangTtaeng_Detected()
        {
            var card1 = MakeCard(0, CardMonth.March, CardType.Gwang);
            var card2 = MakeCard(1, CardMonth.August, CardType.Gwang);
            var combos = HandEvaluator.Evaluate(new List<CardInstance> { card1, card2 });

            Assert.IsTrue(combos.Exists(c => c.Id == "38gwangttaeng"),
                "March + August gwang should trigger 38광땡");
        }

        [Test]
        public void HandEvaluator_HongDan_Detected()
        {
            var card1 = MakeCard(0, CardMonth.January, CardType.Tti, RibbonType.HongDan);
            var card2 = MakeCard(1, CardMonth.February, CardType.Tti, RibbonType.HongDan);
            var card3 = MakeCard(2, CardMonth.March, CardType.Tti, RibbonType.HongDan);
            var combos = HandEvaluator.Evaluate(new List<CardInstance> { card1, card2, card3 });

            Assert.IsTrue(combos.Exists(c => c.Id == "hongdan"), "Should detect 홍단");
        }

        [Test]
        public void HandEvaluator_Kkeut_Calculated_Correctly()
        {
            // 3월 + 4월 = 7끗
            var card1 = MakeCard(0, CardMonth.March, CardType.Pi);
            var card2 = MakeCard(1, CardMonth.April, CardType.Pi);
            var combos = HandEvaluator.Evaluate(new List<CardInstance> { card1, card2 });

            Assert.IsTrue(combos.Exists(c => c.Id == "kkeut7"),
                "March(3) + April(4) = 7끗");
        }

        [Test]
        public void HandEvaluator_Mangtong_Detected()
        {
            // 2월 + 8월 = 10 -> 0끗 -> 망통 (different months to avoid ttaeng)
            var card1 = MakeCard(0, CardMonth.February, CardType.Pi);
            var card2 = MakeCard(1, CardMonth.August, CardType.Pi);
            var combos = HandEvaluator.Evaluate(new List<CardInstance> { card1, card2 });

            Assert.IsTrue(combos.Exists(c => c.Id == "mangtong"),
                "Feb(2)+Aug(8)=10, kkeut=0 should be 망통");
        }

        [Test]
        public void HandEvaluator_Seotda_Best_Only()
        {
            // 1월 + 2월 → 알리(Seotda) + 끗3(Seotda) -- only best kept
            var card1 = MakeCard(0, CardMonth.January, CardType.Pi);
            var card2 = MakeCard(1, CardMonth.February, CardType.Pi);
            var combos = HandEvaluator.Evaluate(new List<CardInstance> { card1, card2 });

            int seotdaCount = 0;
            foreach (var c in combos)
                if (c.Category == ComboCategory.Seotda) seotdaCount++;

            Assert.AreEqual(1, seotdaCount, "Only best Seotda combo should remain");
            Assert.IsTrue(combos.Exists(c => c.Id == "ali"), "알리 should be the best Seotda");
        }

        [Test]
        public void HandEvaluator_GetTotalScore_Chips_Sum_Mult_Product()
        {
            var combos = new List<ComboResult>
            {
                new ComboResult { Chips = 100, Mult = 2f },
                new ComboResult { Chips = 50, Mult = 1.5f }
            };

            var (chips, mult) = HandEvaluator.GetTotalScore(combos);

            Assert.AreEqual(150, chips);
            Assert.AreEqual(3f, mult, 0.01f);
        }

        [Test]
        public void HandEvaluator_Empty_Returns_Empty()
        {
            var combos = HandEvaluator.Evaluate(new List<CardInstance>());
            Assert.AreEqual(0, combos.Count);

            combos = HandEvaluator.Evaluate(null);
            Assert.AreEqual(0, combos.Count);
        }

        // =============================================
        // SeotdaChallenge Tests
        // =============================================

        [Test]
        public void SeotdaChallenge_38GwangTtaeng_Rank100()
        {
            var card1 = MakeCard(0, CardMonth.March, CardType.Gwang);
            var card2 = MakeCard(1, CardMonth.August, CardType.Gwang);

            var result = SeotdaChallenge.Evaluate(card1, card2);

            Assert.AreEqual("38광땡", result.Name);
            Assert.AreEqual(100, result.Rank);
        }

        [Test]
        public void SeotdaChallenge_JangTtaeng_Rank90()
        {
            var card1 = MakeCard(0, CardMonth.October, CardType.Yeolkkeut);
            var card2 = MakeCard(1, CardMonth.October, CardType.Tti, RibbonType.CheongDan);

            var result = SeotdaChallenge.Evaluate(card1, card2);

            Assert.AreEqual("장땡", result.Name);
            Assert.AreEqual(90, result.Rank);
        }

        [Test]
        public void SeotdaChallenge_Ali_Rank75()
        {
            var card1 = MakeCard(0, CardMonth.January, CardType.Pi);
            var card2 = MakeCard(1, CardMonth.February, CardType.Pi);

            var result = SeotdaChallenge.Evaluate(card1, card2);

            Assert.AreEqual("알리", result.Name);
            Assert.AreEqual(75, result.Rank);
        }

        [Test]
        public void SeotdaChallenge_GapO_Rank0()
        {
            // 5월 + 5월 = 10 -> 0끗 -> 갑오
            var card1 = MakeCard(0, CardMonth.May, CardType.Pi);
            var card2 = MakeCard(1, CardMonth.May, CardType.Pi);

            var result = SeotdaChallenge.Evaluate(card1, card2);

            // Same month -> ttaeng, not GapO
            // Use 2+8=10 for GapO
            var c1 = MakeCard(0, CardMonth.February, CardType.Pi);
            var c2 = MakeCard(1, CardMonth.August, CardType.Pi);
            result = SeotdaChallenge.Evaluate(c1, c2);

            Assert.AreEqual("갑오", result.Name);
            Assert.AreEqual(0, result.Rank);
        }

        [Test]
        public void SeotdaChallenge_JangPping_Only_Month10()
        {
            // 1월 + 10월 = 장삥
            var card1 = MakeCard(0, CardMonth.January, CardType.Pi);
            var card2 = MakeCard(1, CardMonth.October, CardType.Pi);
            var result = SeotdaChallenge.Evaluate(card1, card2);
            Assert.AreEqual("장삥", result.Name);

            // 1월 + 11월 = should NOT be 장삥 (should be kkeut or something else)
            var card3 = MakeCard(2, CardMonth.January, CardType.Pi);
            var card4 = MakeCard(3, CardMonth.November, CardType.Pi);
            var result2 = SeotdaChallenge.Evaluate(card3, card4);
            Assert.AreNotEqual("장삥", result2.Name, "Month 11 should not trigger 장삥");
        }

        [Test]
        public void SeotdaChallenge_JangSa_Only_Month10()
        {
            // 4월 + 10월 = 장사
            var card1 = MakeCard(0, CardMonth.April, CardType.Pi);
            var card2 = MakeCard(1, CardMonth.October, CardType.Pi);
            var result = SeotdaChallenge.Evaluate(card1, card2);
            Assert.AreEqual("장사", result.Name);

            // 4월 + 12월 = should NOT be 장사
            var card3 = MakeCard(2, CardMonth.April, CardType.Pi);
            var card4 = MakeCard(3, CardMonth.December, CardType.Pi);
            var result2 = SeotdaChallenge.Evaluate(card3, card4);
            Assert.AreNotEqual("장사", result2.Name, "Month 12 should not trigger 장사");
        }

        [Test]
        public void SeotdaChallenge_GapO_Loses_To_Everything()
        {
            // 갑오 (rank 0) should lose to 1끗 (rank 1)
            var gapO1 = MakeCard(0, CardMonth.February, CardType.Pi);  // 2+8=10 -> 갑오
            var gapO2 = MakeCard(1, CardMonth.August, CardType.Pi);
            var gapO = SeotdaChallenge.Evaluate(gapO1, gapO2);

            var kkeut1_a = MakeCard(2, CardMonth.February, CardType.Pi); // 2+9=11 -> 1끗
            var kkeut1_b = MakeCard(3, CardMonth.September, CardType.Pi);
            var kkeut1 = SeotdaChallenge.Evaluate(kkeut1_a, kkeut1_b);

            Assert.IsTrue(kkeut1.Rank > gapO.Rank, "1끗 should beat 갑오");
        }

        // =============================================
        // Full Round Flow Test
        // =============================================

        [Test]
        public void FullRound_Submit_Stop_Attack_Completes()
        {
            var rm = CreateRoundManager();
            rm.StartRound();

            // Phase tracking
            var phases = new List<RoundManager.Phase>();
            rm.OnPhaseChanged += p => phases.Add(p);

            // Submit 2 cards
            var selected = new List<CardInstance> { rm.HandCards[0], rm.HandCards[1] };
            rm.SubmitCards(selected);
            Assert.AreEqual(RoundManager.Phase.GoStopChoice, rm.CurrentPhase);

            // Stop
            rm.SelectStop();
            Assert.AreEqual(RoundManager.Phase.AttackSelect, rm.CurrentPhase);

            // Attack
            var card1 = rm.HandCards[0];
            var card2 = rm.HandCards[1];
            var result = rm.ExecuteAttack(card1, card2);
            Assert.IsTrue(result.FinalDamage > 0);

            // Finish round
            rm.FinishRound(true);
            Assert.AreEqual(RoundManager.Phase.RoundEnd, rm.CurrentPhase);

            // Phase transitions: SelectCards(start) -> GoStopChoice -> AttackSelect -> RoundEnd
            Assert.IsTrue(phases.Contains(RoundManager.Phase.SelectCards));
            Assert.IsTrue(phases.Contains(RoundManager.Phase.GoStopChoice));
            Assert.IsTrue(phases.Contains(RoundManager.Phase.AttackSelect));
            Assert.IsTrue(phases.Contains(RoundManager.Phase.RoundEnd));
        }

        [Test]
        public void FullRound_Submit_Go_Submit_Stop_Attack()
        {
            var rm = CreateRoundManager();
            rm.StartRound();

            // Submit 1 card
            rm.SubmitCards(new List<CardInstance> { rm.HandCards[0] });
            Assert.AreEqual(RoundManager.Phase.GoStopChoice, rm.CurrentPhase);
            int chipsAfterFirst = rm.AccumulatedChips;

            // Go
            int goDmg = rm.SelectGo();
            Assert.AreEqual(5, goDmg);
            Assert.AreEqual(1, rm.GoCount);
            Assert.AreEqual(RoundManager.Phase.SelectCards, rm.CurrentPhase);

            // Submit 1 more card
            rm.SubmitCards(new List<CardInstance> { rm.HandCards[0] });
            Assert.AreEqual(2, rm.PlaysUsed);
            int chipsAfterSecond = rm.AccumulatedChips;
            Assert.IsTrue(chipsAfterSecond >= chipsAfterFirst,
                "Accumulated chips should not decrease after second submit");

            // Stop
            rm.SelectStop();
            Assert.AreEqual(RoundManager.Phase.AttackSelect, rm.CurrentPhase);

            // Attack with Go multiplier
            var result = rm.ExecuteAttack(rm.HandCards[0], rm.HandCards[1]);
            Assert.AreEqual(2f, result.GoMult);
            Assert.IsTrue(result.FinalDamage > 0);
        }

        // =============================================
        // Accumulation Tests
        // =============================================

        [Test]
        public void Synergy_Accumulates_Across_Submits()
        {
            var rm = CreateRoundManager();
            rm.StartRound();

            // First submit
            rm.SubmitCards(new List<CardInstance> { rm.HandCards[0] });
            int chips1 = rm.AccumulatedChips;
            float mult1 = rm.AccumulatedMult;

            rm.SelectGo();

            // Second submit
            rm.SubmitCards(new List<CardInstance> { rm.HandCards[0] });
            int chips2 = rm.AccumulatedChips;
            float mult2 = rm.AccumulatedMult;

            Assert.IsTrue(chips2 >= chips1, "Chips should accumulate");
            Assert.IsTrue(rm.AccumulatedCombos.Count >= 1, "Should have accumulated combos");
        }

        // =============================================
        // GoRiskInfo Tests
        // =============================================

        [Test]
        public void GetCurrentGoRisk_Returns_Correct_Info()
        {
            var rm = CreateRoundManager();
            rm.StartRound();

            var risk1 = rm.GetCurrentGoRisk();
            Assert.AreEqual(3, risk1.DrawCards, "Go 1: 3 cards");
            Assert.AreEqual(5, risk1.BossDamage, "Go 1: 5 damage");
            Assert.IsFalse(risk1.InstantDeathRisk);

            // After Go 1
            rm.SubmitCards(new List<CardInstance> { rm.HandCards[0] });
            rm.SelectGo();

            var risk2 = rm.GetCurrentGoRisk();
            Assert.AreEqual(2, risk2.DrawCards, "Go 2: 2 cards");
            Assert.AreEqual(15, risk2.BossDamage, "Go 2: 15 damage");
            Assert.IsFalse(risk2.InstantDeathRisk);

            // After Go 2
            rm.SubmitCards(new List<CardInstance> { rm.HandCards[0] });
            rm.SelectGo();

            var risk3 = rm.GetCurrentGoRisk();
            Assert.AreEqual(1, risk3.DrawCards, "Go 3: 1 card");
            Assert.AreEqual(30, risk3.BossDamage, "Go 3: 30 damage");
            Assert.IsTrue(risk3.InstantDeathRisk);
        }
    }
}

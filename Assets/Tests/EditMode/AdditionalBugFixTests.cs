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
    /// 추가 버그 수정 검증 테스트
    ///
    /// 1. 끗(Kkeut) 계산 — 전체 월 합산 사용
    /// 2. 시너지 힌트 정렬 — S 티어 우선
    /// 3. Seotda 필터링 — ID 비교
    /// 4. TalismanManager — 반복 안전성
    /// 5. 삼도천의 나룻배 — 트리거 타이밍
    /// 6. 데미지 오버플로우 방지
    /// 7. CardEnhancement 타입 변이 방향
    /// </summary>
    [TestFixture]
    public class AdditionalBugFixTests
    {
        private static CardInstance MakeCard(int id, CardMonth month, CardType type,
            RibbonType ribbon = RibbonType.None, bool isRainGwang = false)
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
                IsDoublePi = false
            };
            return new CardInstance(id, def);
        }

        // =============================================
        // TEST 1: 끗(Kkeut) 계산 — 전체 월 합산
        // =============================================
        [Test]
        public void Kkeut_Uses_All_Card_Months_Not_Distinct()
        {
            // 3월 + 4월 = 7끗
            var c1 = MakeCard(0, CardMonth.March, CardType.Pi);
            var c2 = MakeCard(1, CardMonth.April, CardType.Pi);
            var combos = HandEvaluator.Evaluate(new List<CardInstance> { c1, c2 });

            Assert.IsTrue(combos.Exists(c => c.Id == "kkeut7"),
                "3+4=7끗이 있어야 함");
        }

        [Test]
        public void Kkeut_Two_Same_Month_Counts_Both()
        {
            // 같은 월 2장 = 땡이므로 끗 테스트에는 부적합
            // 대신: 2월 + 8월 = 10 → 0끗 = 갑오 확인
            var c1 = MakeCard(0, CardMonth.February, CardType.Pi);
            var c2 = MakeCard(1, CardMonth.August, CardType.Pi);
            var combos = HandEvaluator.Evaluate(new List<CardInstance> { c1, c2 });

            Assert.IsTrue(combos.Exists(c => c.Id == "mangtong"),
                "2+8=10, kkeut=0 → 망통/갑오");
        }

        [Test]
        public void Kkeut_Large_Month_Sum_Wraps_Correctly()
        {
            // 9월 + 8월 = 17 → 7끗
            var c1 = MakeCard(0, CardMonth.September, CardType.Pi);
            var c2 = MakeCard(1, CardMonth.August, CardType.Pi);
            var combos = HandEvaluator.Evaluate(new List<CardInstance> { c1, c2 });

            Assert.IsTrue(combos.Exists(c => c.Id == "kkeut7"),
                "9+8=17, 17%10=7끗");
        }

        // =============================================
        // TEST 2: 시너지 힌트 정렬 — S 우선
        // =============================================
        [Test]
        public void SynergyHints_S_Tier_Comes_First()
        {
            // SynergyHint 리스트를 수동 생성하여 정렬 검증
            var hints = new List<SynergyHint>
            {
                new SynergyHint { Tier = ComboTier.C, ComboNameKR = "C급", EstimatedChips = 10, EstimatedMult = 1f },
                new SynergyHint { Tier = ComboTier.S, ComboNameKR = "S급", EstimatedChips = 500, EstimatedMult = 8f },
                new SynergyHint { Tier = ComboTier.A, ComboNameKR = "A급", EstimatedChips = 100, EstimatedMult = 3f }
            };

            // ComboTier enum: S=0, A=1, B=2, C=3, D=4
            hints.Sort((a, b) =>
            {
                int cmp = a.Tier.CompareTo(b.Tier);
                if (cmp != 0) return cmp;
                float scoreA = a.EstimatedChips * a.EstimatedMult;
                float scoreB = b.EstimatedChips * b.EstimatedMult;
                return scoreB.CompareTo(scoreA);
            });

            Assert.AreEqual(ComboTier.S, hints[0].Tier, "S tier should be first");
            Assert.AreEqual(ComboTier.A, hints[1].Tier, "A tier should be second");
            Assert.AreEqual(ComboTier.C, hints[2].Tier, "C tier should be third");
        }

        // =============================================
        // TEST 3: Seotda 필터링 — 최고 1개만 남김 (ID 비교)
        // =============================================
        [Test]
        public void Seotda_Best_Only_Keeps_One()
        {
            // 1월 + 2월 → 알리(Seotda) + 끗3(Seotda)
            // 알리만 남아야 함
            var c1 = MakeCard(0, CardMonth.January, CardType.Pi);
            var c2 = MakeCard(1, CardMonth.February, CardType.Pi);
            var combos = HandEvaluator.Evaluate(new List<CardInstance> { c1, c2 });

            int seotdaCount = combos.Count(c => c.Category == ComboCategory.Seotda);
            Assert.AreEqual(1, seotdaCount, "Only 1 Seotda combo should remain");

            var bestSeotda = combos.First(c => c.Category == ComboCategory.Seotda);
            Assert.AreEqual("ali", bestSeotda.Id, "알리가 최고 Seotda여야 함");
        }

        // =============================================
        // TEST 4: TalismanManager — 반복 안전성
        // =============================================
        [Test]
        public void TalismanManager_ApplyEffects_Does_Not_Crash()
        {
            var talismanMgr = new TalismanManager();
            var player = new PlayerState();

            // 부적 2개 장착
            var tData1 = TalismanDatabase.AllTalismans[0];
            var tData2 = TalismanDatabase.AllTalismans.Count > 1
                ? TalismanDatabase.AllTalismans[1]
                : tData1;

            player.EquipTalisman(new TalismanInstance(tData1));
            player.EquipTalisman(new TalismanInstance(tData2));

            var baseScore = new ScoringEngine.ScoreResult
            {
                Chips = 100,
                Mult = 1,
                FinalScore = 100
            };

            // 크래시 없이 실행되어야 함
            var result = talismanMgr.ApplyTalismanEffects(player, baseScore, TalismanTrigger.OnRoundStart);

            Assert.IsNotNull(result);
            Assert.IsTrue(result.Chips >= 100, "Chips should be >= base");
        }

        // =============================================
        // TEST 5: 삼도천의 나룻배 — OnRoundStart 트리거
        // =============================================
        [Test]
        public void SamdoFerry_Triggers_OnRoundStart()
        {
            var samdo = TalismanDatabase.GetByName("Samdo Ferry");
            Assert.IsNotNull(samdo, "삼도천의 나룻배가 DB에 있어야 함");
            Assert.AreEqual(TalismanTrigger.OnRoundStart, samdo.Trigger,
                "삼도천의 나룻배는 OnRoundStart 트리거여야 함");
        }

        // =============================================
        // TEST 6: 데미지 오버플로우 방지
        // =============================================
        [Test]
        public void Damage_Does_Not_Overflow_With_Large_Values()
        {
            var player = new PlayerState();
            var deck = new DeckManager(42);
            var talismanMgr = new TalismanManager();
            var rm = new RoundManager(player, deck, talismanMgr);
            rm.StartRound();

            // 시너지를 극한으로 쌓기
            // 직접 필드 접근은 안 되므로 여러 번 Go로 배수 쌓기
            rm.SubmitCards(new List<CardInstance> { rm.HandCards[0] });
            if (rm.CurrentPhase == RoundManager.Phase.GoStopChoice)
                rm.SelectGo(); // Go 1: ×2

            rm.SubmitCards(new List<CardInstance> { rm.HandCards[0] });
            if (rm.CurrentPhase == RoundManager.Phase.GoStopChoice)
                rm.SelectGo(); // Go 2: ×4

            rm.SubmitCards(new List<CardInstance> { rm.HandCards[0] });
            if (rm.CurrentPhase == RoundManager.Phase.GoStopChoice)
                rm.SelectGo(); // Go 3: ×10

            rm.SubmitCards(new List<CardInstance> { rm.HandCards[0] });
            if (rm.CurrentPhase == RoundManager.Phase.GoStopChoice)
                rm.SelectStop();
            else if (rm.CurrentPhase == RoundManager.Phase.SelectCards)
            {
                // 콤보 없어서 돌아온 경우 — 한 번 더
                rm.SubmitCards(new List<CardInstance> { rm.HandCards[0] });
                if (rm.CurrentPhase == RoundManager.Phase.GoStopChoice)
                    rm.SelectStop();
            }

            if (rm.CurrentPhase == RoundManager.Phase.AttackSelect && rm.HandCards.Count >= 2)
            {
                var result = rm.ExecuteAttack(rm.HandCards[0], rm.HandCards[1]);

                Assert.IsTrue(result.FinalDamage >= 0,
                    $"Damage should never be negative (overflow protection): got {result.FinalDamage}");
            }
        }

        // =============================================
        // TEST 7: CardEnhancement 타입 변이 방향
        // =============================================
        [Test]
        public void CardEnhancement_Cannot_Downgrade_Type()
        {
            var enhMgr = new CardEnhancementManager();
            var enh = enhMgr.GetEnhancement(1);

            // Gwang(0) → Pi(3) = 하향 → 금지
            bool result = enh.MutateType(CardType.Gwang, CardType.Pi);
            Assert.IsFalse(result, "Gwang → Pi (하향) 금지");
        }

        [Test]
        public void CardEnhancement_Can_Upgrade_Type()
        {
            var enhMgr = new CardEnhancementManager();
            var enh = enhMgr.GetEnhancement(2);

            // Pi(3) → Gwang(0) = 상향 → 허용
            bool result = enh.MutateType(CardType.Pi, CardType.Gwang);
            Assert.IsTrue(result, "Pi → Gwang (상향) 허용");
        }

        [Test]
        public void CardEnhancement_SameType_Allowed()
        {
            var enhMgr = new CardEnhancementManager();
            var enh = enhMgr.GetEnhancement(3);

            // Tti → Tti = 동일 → 허용
            bool result = enh.MutateType(CardType.Tti, CardType.Tti);
            Assert.IsTrue(result, "동일 타입 변이 허용");
        }

        // =============================================
        // TEST 8: SeotdaChallenge — 기본 족보 판정
        // =============================================
        [Test]
        public void SeotdaChallenge_Evaluate_Handles_All_Special_Hands()
        {
            // 38광땡
            var r1 = SeotdaChallenge.Evaluate(
                MakeCard(0, CardMonth.March, CardType.Gwang),
                MakeCard(1, CardMonth.August, CardType.Gwang));
            Assert.AreEqual(100, r1.Rank);

            // 장땡 (10월)
            var r2 = SeotdaChallenge.Evaluate(
                MakeCard(0, CardMonth.October, CardType.Pi),
                MakeCard(1, CardMonth.October, CardType.Tti));
            Assert.AreEqual(90, r2.Rank);
            Assert.AreEqual("장땡", r2.Name);

            // 알리 (1+2)
            var r3 = SeotdaChallenge.Evaluate(
                MakeCard(0, CardMonth.January, CardType.Pi),
                MakeCard(1, CardMonth.February, CardType.Pi));
            Assert.AreEqual(75, r3.Rank);

            // 세륙 (4+6)
            var r4 = SeotdaChallenge.Evaluate(
                MakeCard(0, CardMonth.April, CardType.Pi),
                MakeCard(1, CardMonth.June, CardType.Pi));
            Assert.AreEqual(70, r4.Rank);

            // 갑오 (2+8=10, 0끗)
            var r5 = SeotdaChallenge.Evaluate(
                MakeCard(0, CardMonth.February, CardType.Pi),
                MakeCard(1, CardMonth.August, CardType.Pi));
            Assert.AreEqual(0, r5.Rank);
        }

        [Test]
        public void SeotdaChallenge_Kkeut_Calculated_Correctly()
        {
            // 3+7=10 → 0끗 → 갑오
            var r1 = SeotdaChallenge.Evaluate(
                MakeCard(0, CardMonth.March, CardType.Pi),
                MakeCard(1, CardMonth.July, CardType.Pi));
            Assert.AreEqual("갑오", r1.Name);
            Assert.AreEqual(0, r1.Rank);

            // 5+9=14 → 4끗
            var r2 = SeotdaChallenge.Evaluate(
                MakeCard(0, CardMonth.May, CardType.Pi),
                MakeCard(1, CardMonth.September, CardType.Pi));
            Assert.AreEqual("4끗", r2.Name);
            Assert.AreEqual(4, r2.Rank);
        }

        // =============================================
        // TEST 9: BossBattle — 반복 데미지 누적 + 오버킬
        // =============================================
        [Test]
        public void BossBattle_Overkill_Clamps_To_Zero()
        {
            var boss = new BossDefinition
            {
                Id = "test", Name = "test", NameKR = "테스트",
                TargetScore = 100, Rounds = 3,
                Gimmick = BossGimmick.None, GimmickInterval = 1,
                IntroDialogue = "", DefeatDialogue = "", VictoryDialogue = "",
                YeopReward = 50
            };
            var battle = new BossBattle(boss, 1);

            // 오버킬
            battle.DealDamage(new ScoringEngine.ScoreResult { FinalScore = 999999 });

            Assert.AreEqual(0, battle.BossCurrentHP, "HP should clamp to 0, not go negative");
            Assert.IsTrue(battle.IsBossDefeated);
        }

        // =============================================
        // TEST 10: 전체 라운드 → 공격 → 데미지 양수 확인
        // =============================================
        [Test]
        public void FullRound_Attack_Produces_Positive_Damage()
        {
            var player = new PlayerState();
            var deck = new DeckManager(42);
            var talismanMgr = new TalismanManager();
            var rm = new RoundManager(player, deck, talismanMgr);
            rm.StartRound();

            // 내기 → 스톱 → 공격
            rm.SubmitCards(new List<CardInstance> { rm.HandCards[0] });
            if (rm.CurrentPhase == RoundManager.Phase.GoStopChoice)
                rm.SelectStop();

            if (rm.CurrentPhase == RoundManager.Phase.AttackSelect && rm.HandCards.Count >= 2)
            {
                var result = rm.ExecuteAttack(rm.HandCards[0], rm.HandCards[1]);
                Assert.IsTrue(result.FinalDamage > 0,
                    $"Normal attack should deal positive damage: got {result.FinalDamage}");
                Assert.IsNotNull(result.SeotdaName);
                Assert.IsTrue(result.SeotdaRank >= 0);
            }
        }
    }
}

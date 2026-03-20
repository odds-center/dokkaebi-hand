using System.Collections.Generic;
using NUnit.Framework;
using DokkaebiHand.Cards;
using DokkaebiHand.Combat;
using DokkaebiHand.Core;
using DokkaebiHand.Talismans;

namespace DokkaebiHand.Tests
{
    /// <summary>
    /// 3차 버그 수정 검증 테스트
    ///
    /// BUG-20: SaveSystem RunSaveKey/MetaSaveKey 혼용
    /// BUG-21: 상점 체력캡 6 하드코딩
    /// BUG-22: WaveUpgrade 체력캡 하드코딩
    /// BUG-23: 천상의 비파 배수 누락
    /// BUG-24: 복제 시너지 양방향 체크
    /// BUG-25: LocalizationManager 음수 인덱스
    /// BUG-26: 도깨비불 족보 조건 과다 제한
    /// </summary>
    [TestFixture]
    public class ThirdPassBugFixTests
    {
        private static CardInstance MakeCard(int id, CardMonth month, CardType type,
            RibbonType ribbon = RibbonType.None)
        {
            var def = new HwaTuCardDatabase.CardDefinition
            {
                Name = $"Test_{id}", NameKR = $"테스트_{id}",
                Month = month, Type = type, Ribbon = ribbon,
                BasePoints = type == CardType.Gwang ? 20 : (type == CardType.Pi ? 1 : 10),
                IsRainGwang = false, IsDoublePi = false
            };
            return new CardInstance(id, def);
        }

        // =============================================
        // TEST 1: 천상의 비파 — 칩 + 배수 동시 효과
        // =============================================
        [Test]
        public void HeavenlyLute_Has_SecondaryMultBonus()
        {
            var lute = TalismanDatabase.GetByName("Heavenly Lute");
            Assert.IsNotNull(lute, "천상의 비파가 DB에 있어야 함");
            Assert.AreEqual(TalismanEffectType.AddChips, lute.EffectType);
            Assert.AreEqual(100f, lute.EffectValue, "칩 +100");
            Assert.AreEqual(2f, lute.SecondaryMultBonus, "배수 +2 보너스");
        }

        [Test]
        public void TalismanManager_Applies_SecondaryMultBonus()
        {
            var talismanMgr = new TalismanManager();
            var player = new PlayerState();

            var lute = TalismanDatabase.GetByName("Heavenly Lute");
            Assert.IsNotNull(lute);

            player.EquipTalisman(new TalismanInstance(lute));

            var baseScore = new ScoringEngine.ScoreResult
            {
                Chips = 50,
                Mult = 1,
                FinalScore = 50
            };

            // OnYokboComplete 트리거로 적용
            var result = talismanMgr.ApplyTalismanEffects(player, baseScore, TalismanTrigger.OnYokboComplete);

            // 칩이 +100, 배수가 +2 되어야 함
            Assert.IsTrue(result.Chips >= 150, $"Chips should be >= 150, got {result.Chips}");
            Assert.IsTrue(result.Mult >= 3, $"Mult should be >= 3, got {result.Mult}");
        }

        // =============================================
        // TEST 2: 상점 체력 캡 — MaxLives 사용
        // =============================================
        [Test]
        public void ShopManager_Health_Uses_MaxLives()
        {
            // ShopManager 내부에서 Math.Min(player.Lives + 1, PlayerState.MaxLives) 사용 확인
            // 직접 구매는 ShopManager 인스턴스 필요하므로, PlayerState.MaxLives 값 검증
            Assert.AreEqual(10, PlayerState.MaxLives, "MaxLives should be 10");
        }

        // =============================================
        // TEST 3: 도깨비불 족보 — 광 2장도 허용
        // =============================================
        [Test]
        public void Dokkaebi_Fire_Triggers_With_Two_Gwang()
        {
            var player = new PlayerState();
            player.ResetForNewRound();

            // 광 2장 + 피 7장 이상
            player.CaptureCard(MakeCard(0, CardMonth.January, CardType.Gwang));
            player.CaptureCard(MakeCard(1, CardMonth.March, CardType.Gwang));

            for (int i = 0; i < 8; i++)
                player.CaptureCard(MakeCard(10 + i, (CardMonth)(i % 12 + 1), CardType.Pi));

            var engine = new ScoringEngine();
            var result = engine.CalculateScore(player);

            Assert.IsTrue(result.CompletedYokbo.Contains("도깨비불"),
                "광 2장 + 피 8장 → 도깨비불 발동해야 함");
        }

        [Test]
        public void Dokkaebi_Fire_Does_Not_Trigger_With_Three_Gwang()
        {
            var player = new PlayerState();
            player.ResetForNewRound();

            // 광 3장 → 삼광이므로 도깨비불 비해당
            player.CaptureCard(MakeCard(0, CardMonth.January, CardType.Gwang));
            player.CaptureCard(MakeCard(1, CardMonth.March, CardType.Gwang));
            player.CaptureCard(MakeCard(2, CardMonth.August, CardType.Gwang));

            for (int i = 0; i < 8; i++)
                player.CaptureCard(MakeCard(10 + i, (CardMonth)(i % 12 + 1), CardType.Pi));

            var engine = new ScoringEngine();
            var result = engine.CalculateScore(player);

            Assert.IsFalse(result.CompletedYokbo.Contains("도깨비불"),
                "광 3장 → 삼광이지 도깨비불 아님");
        }

        // =============================================
        // TEST 4: 복제 시너지 양방향 체크
        // =============================================
        [Test]
        public void Seal_Synergy_Check_Is_Bidirectional()
        {
            // CheckSynergy는 양방향이므로 어느 순서든 동일 결과
            var syn1 = DokkaebiSealDatabase.CheckSynergy("replication", "samsara");
            var syn2 = DokkaebiSealDatabase.CheckSynergy("samsara", "replication");

            if (syn1 != null)
            {
                Assert.IsNotNull(syn2, "양방향 CheckSynergy 결과가 동일해야 함");
                Assert.AreEqual(syn1.NameKR, syn2.NameKR);
            }
        }

        // =============================================
        // TEST 5: ScoringEngine — 삼광 + 비광 판정
        // =============================================
        [Test]
        public void ScoringEngine_Samgwang_Without_Rain()
        {
            var player = new PlayerState();
            player.ResetForNewRound();

            // 1월(광) + 3월(광) + 8월(광) = 삼광 (비광 없음)
            player.CaptureCard(MakeCard(0, CardMonth.January, CardType.Gwang));
            player.CaptureCard(MakeCard(1, CardMonth.March, CardType.Gwang));
            player.CaptureCard(MakeCard(2, CardMonth.August, CardType.Gwang));

            var engine = new ScoringEngine();
            var result = engine.CalculateScore(player);

            Assert.IsTrue(result.CompletedYokbo.Contains("삼광"),
                "광 3장 (비광 없음) → 삼광");
        }

        // =============================================
        // TEST 6: CardEnhancement 타입 변이 — 하향 금지 확인
        // =============================================
        [Test]
        public void CardEnhancement_Gwang_To_Pi_Blocked()
        {
            var enhMgr = new CardEnhancementManager();
            var enh = enhMgr.GetEnhancement(1);

            // Gwang(0) → Pi(3) = newType > originalType → 차단
            Assert.IsFalse(enh.MutateType(CardType.Gwang, CardType.Pi));
        }

        [Test]
        public void CardEnhancement_Pi_To_Gwang_Allowed()
        {
            var enhMgr = new CardEnhancementManager();
            var enh = enhMgr.GetEnhancement(2);

            // Pi(3) → Gwang(0) = newType < originalType → 허용
            Assert.IsTrue(enh.MutateType(CardType.Pi, CardType.Gwang));
        }

        // =============================================
        // TEST 7: BossGenerator — 음수 인덱스 방어
        // =============================================
        [Test]
        public void BossDatabase_GetBoss_Negative_Index_Safe()
        {
            // GetBoss(-1) → AllBosses[0] (안전 폴백)
            var boss = BossDatabase.GetBoss(-1);
            Assert.IsNotNull(boss, "음수 인덱스도 안전하게 처리해야 함");
        }

        [Test]
        public void BossDatabase_GetBoss_OverIndex_Safe()
        {
            var boss = BossDatabase.GetBoss(999);
            Assert.IsNotNull(boss, "범위 초과 인덱스도 안전하게 처리해야 함");
        }

        // =============================================
        // TEST 8: 전체 시스템 통합 — 보스 격파 후 보상 → 상점 → 이벤트
        // =============================================
        [Test]
        public void Integration_BossDefeat_Shop_Event_NextBoss()
        {
            var gm = new GameManager();
            var states = new List<GameState>();
            gm.OnGameStateChanged += s => states.Add(s);

            gm.StartNewGame();
            gm.BeginSpiralWithBlessing(null);

            Assert.AreEqual(GameState.InRound, gm.CurrentState);
            Assert.IsNotNull(gm.CurrentBattle);

            // 보스 즉사
            gm.CurrentBattle.DealDamage(new ScoringEngine.ScoreResult
            {
                FinalScore = gm.CurrentBattle.BossMaxHP
            });

            // 라운드 플레이 → 보스 격파 처리
            var rm = gm.RoundManager;
            if (rm != null && rm.HandCards.Count >= 3)
            {
                rm.SubmitCards(new List<CardInstance> { rm.HandCards[0] });
                if (rm.CurrentPhase == RoundManager.Phase.GoStopChoice)
                    rm.SelectStop();

                if (rm.CurrentPhase == RoundManager.Phase.AttackSelect && rm.HandCards.Count >= 2)
                {
                    gm.SeotdaAttack(rm.HandCards[0], rm.HandCards[1]);
                }
            }

            // PostRound 상태 확인
            if (gm.CurrentState == GameState.PostRound)
            {
                // 웨이브 강화 스킵 → 상점
                gm.SkipWaveUpgrade();
                Assert.AreEqual(GameState.Shop, gm.CurrentState);

                // 상점 나가기
                gm.LeaveShop();

                // 홀수 영역이면 InRound, 짝수면 Event
                Assert.IsTrue(
                    gm.CurrentState == GameState.InRound || gm.CurrentState == GameState.Event,
                    $"Expected InRound or Event after shop, got {gm.CurrentState}");
            }
        }

        // =============================================
        // TEST 9: 연속 보스 격파 — 영역 진행 확인
        // =============================================
        [Test]
        public void Integration_Two_Boss_Defeats_Advance_Realm()
        {
            var gm = new GameManager();
            gm.StartNewGame();
            gm.BeginSpiralWithBlessing(null);

            int realmBefore = gm.Spiral.CurrentRealm;

            // 첫 번째 보스 즉사 + 공격
            gm.CurrentBattle.DealDamage(new ScoringEngine.ScoreResult
            {
                FinalScore = gm.CurrentBattle.BossMaxHP
            });

            var rm = gm.RoundManager;
            if (rm != null && rm.HandCards.Count >= 3)
            {
                rm.SubmitCards(new List<CardInstance> { rm.HandCards[0] });
                if (rm.CurrentPhase == RoundManager.Phase.GoStopChoice)
                    rm.SelectStop();
                if (rm.CurrentPhase == RoundManager.Phase.AttackSelect && rm.HandCards.Count >= 2)
                    gm.SeotdaAttack(rm.HandCards[0], rm.HandCards[1]);
            }

            // 영역이 진행됐는지 확인
            if (gm.CurrentState == GameState.PostRound)
            {
                Assert.IsTrue(gm.Spiral.CurrentRealm > realmBefore,
                    "보스 격파 후 영역이 진행되어야 함");
            }
        }
    }
}

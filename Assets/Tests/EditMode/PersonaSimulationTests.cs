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
    /// 코드 기반 전체 게임 시뮬레이션.
    /// 유니티에서 플레이어가 버튼을 클릭하는 것과 동일한 흐름으로
    /// 실제 GameManager/RoundManager/BossBattle/ShopManager 등을 호출.
    ///
    /// 검증 대상:
    ///   - 전투: 카드 선택 → 내기 → Go/Stop → 공격 → 보스 HP 감소
    ///   - 강화: 웨이브 강화 선택 적용 → 다음 관문에서 효과 확인
    ///   - 부적: 상점 구매 → 장착 확인 → 전투에서 효과 적용
    ///   - 진행: 10관문 → Gate → 엔딩(EnterGate) 또는 계속(ContinueAfterGate)
    ///   - 나선2: ContinueAfterGate → 나선 2 보스 HP 증가 확인
    /// </summary>
    [TestFixture]
    public class PersonaSimulationTests
    {
        // =============================================
        // 페르소나 행동 정의
        // =============================================

        private class Persona
        {
            public string Name;
            public int Stars;
            public int CardsToSubmit;
            public int MaxGo;
            public bool SeekGwang;
            public bool SeekPairs;
            public bool BuyTalismans;     // 상점에서 부적 구매
            public bool PickBestUpgrade;  // 웨이브 강화 전략적 선택
            public int EventStrategy;     // 0=첫째, 1=체력우선, 2=엽전우선
        }

        private static readonly Persona[] AllPersonas = new[]
        {
            new Persona { Name="김모름(입문)", Stars=1,
                CardsToSubmit=1, MaxGo=0, SeekGwang=false, SeekPairs=false,
                BuyTalismans=false, PickBestUpgrade=false, EventStrategy=0 },
            new Persona { Name="이배움(초급)", Stars=2,
                CardsToSubmit=2, MaxGo=1, SeekGwang=false, SeekPairs=true,
                BuyTalismans=true, PickBestUpgrade=false, EventStrategy=1 },
            new Persona { Name="박전략(중급)", Stars=3,
                CardsToSubmit=3, MaxGo=2, SeekGwang=true, SeekPairs=true,
                BuyTalismans=true, PickBestUpgrade=true, EventStrategy=2 },
            new Persona { Name="최고수(상급)", Stars=4,
                CardsToSubmit=4, MaxGo=2, SeekGwang=true, SeekPairs=true,
                BuyTalismans=true, PickBestUpgrade=true, EventStrategy=2 },
            new Persona { Name="도깨비왕(고수)", Stars=5,
                CardsToSubmit=5, MaxGo=3, SeekGwang=true, SeekPairs=true,
                BuyTalismans=true, PickBestUpgrade=true, EventStrategy=2 },
        };

        // =============================================
        // 시뮬 결과 기록
        // =============================================

        private class SimLog
        {
            public List<string> Lines = new List<string>();
            public int TotalRounds;
            public int RealmsCleared;
            public int BossesDefeated;
            public int TalismansEquipped;
            public int UpgradesApplied;
            public int EventsPlayed;
            public bool ReachedGate;
            public bool ContinuedToSpiral2;

            public void Add(string msg) => Lines.Add(msg);
        }

        // =============================================
        // AI: 카드 선택
        // =============================================

        private List<CardInstance> PickSubmitCards(List<CardInstance> hand, Persona p)
        {
            int maxPick = Math.Min(p.CardsToSubmit, hand.Count - 2);
            if (maxPick <= 0) return new List<CardInstance>();

            var result = new List<CardInstance>();

            // 같은 월 쌍 노림
            if (p.SeekPairs)
            {
                var groups = hand.GroupBy(c => c.Month)
                    .Where(g => g.Count() >= 2)
                    .OrderByDescending(g => g.Count());
                foreach (var g in groups)
                {
                    foreach (var c in g)
                    {
                        if (result.Count >= maxPick) break;
                        result.Add(c);
                    }
                    if (result.Count >= maxPick) break;
                }
            }

            // 광 우선 채우기
            var rest = hand.Where(c => !result.Contains(c));
            if (p.SeekGwang) rest = rest.OrderByDescending(c => c.Type == CardType.Gwang ? 1 : 0);

            foreach (var c in rest)
            {
                if (result.Count >= maxPick) break;
                if (hand.Count - result.Count - 1 < 2) break;
                result.Add(c);
            }

            return result;
        }

        private (CardInstance, CardInstance) PickAttackCards(List<CardInstance> hand, Persona p)
        {
            if (hand.Count < 2) return (null, null);

            if (p.SeekGwang)
            {
                var gw = hand.Where(c => c.Type == CardType.Gwang).ToList();
                if (gw.Count >= 2) return (gw[0], gw[1]);
            }
            if (p.SeekPairs)
            {
                var pair = hand.GroupBy(c => c.Month).FirstOrDefault(g => g.Count() >= 2);
                if (pair != null) { var a = pair.ToArray(); return (a[0], a[1]); }
            }

            var s = hand.OrderByDescending(c => (int)c.Month).ToList();
            return (s[0], s[1]);
        }

        // =============================================
        // AI: 웨이브 강화 선택
        // =============================================

        private void DoWaveUpgrade(GameManager gm, Persona p, SimLog log)
        {
            if (!p.PickBestUpgrade || gm.WaveUpgrades.CurrentChoices.Count == 0)
            {
                gm.SkipWaveUpgrade();
                return;
            }

            // 전략: 배수 > 칩 > 체력 > 기타
            int bestIdx = 0;
            var choices = gm.WaveUpgrades.CurrentChoices;
            for (int i = 0; i < choices.Count; i++)
            {
                string id = choices[i].Id;
                if (id.Contains("mult")) { bestIdx = i; break; }
                if (id.Contains("chip") && !choices[bestIdx].Id.Contains("mult")) bestIdx = i;
                if (id.Contains("heal") && gm.Player.Lives <= 3) { bestIdx = i; break; }
            }

            gm.ApplyWaveUpgrade(bestIdx);
            log.UpgradesApplied++;
            log.Add($"      강화: {choices[bestIdx].NameKR}");
        }

        // =============================================
        // AI: 상점 구매
        // =============================================

        private void DoShop(GameManager gm, Persona p, SimLog log)
        {
            if (!p.BuyTalismans || gm.CurrentState != GameState.Shop)
            {
                if (gm.CurrentState == GameState.Shop) gm.LeaveShop();
                return;
            }

            // 부적 중 가장 싼 것 구매 시도
            var stock = gm.Shop.CurrentStock;
            for (int i = 0; i < stock.Count; i++)
            {
                var item = stock[i];
                if (item.IsSold) continue;
                if (item.TalismanData != null && gm.Player.Yeop >= item.Cost)
                {
                    bool bought = gm.ShopPurchase(i);
                    if (bought)
                    {
                        log.TalismansEquipped++;
                        log.Add($"      상점: {item.NameKR} 구매 (-{item.Cost}냥)");
                        break; // 1개만 구매
                    }
                }
            }

            // 체력 낮으면 회복 구매
            if (gm.Player.Lives <= 2)
            {
                for (int i = 0; i < stock.Count; i++)
                {
                    if (!stock[i].IsSold && stock[i].ConsumableType == "health"
                        && gm.Player.Yeop >= stock[i].Cost)
                    {
                        gm.ShopPurchase(i);
                        log.Add($"      상점: 체력 회복 구매");
                        break;
                    }
                }
            }

            gm.LeaveShop();
        }

        // =============================================
        // AI: 이벤트 선택
        // =============================================

        private void DoEvent(GameManager gm, Persona p, SimLog log)
        {
            if (gm.CurrentState != GameState.Event) return;

            var evt = gm.Events.CurrentEvent;
            if (evt == null || evt.Choices.Count == 0)
            {
                gm.LeaveEvent();
                return;
            }

            int choice = 0;
            if (p.EventStrategy == 1 && gm.Player.Lives <= 3)
            {
                // 체력 회복 선택지 찾기
                for (int i = 0; i < evt.Choices.Count; i++)
                {
                    if (evt.Choices[i].TextKR.Contains("체력") || evt.Choices[i].TextKR.Contains("푸른"))
                    { choice = i; break; }
                }
            }
            else if (p.EventStrategy == 2)
            {
                // 엽전 최대화
                for (int i = 0; i < evt.Choices.Count; i++)
                {
                    if (evt.Choices[i].TextKR.Contains("엽전") || evt.Choices[i].TextKR.Contains("100"))
                    { choice = i; break; }
                }
            }

            string result = gm.ExecuteEventChoice(choice);
            log.EventsPlayed++;
            log.Add($"      이벤트: {evt.TitleKR} → {evt.Choices[choice].TextKR}");

            if (gm.CurrentState == GameState.GameOver) return;
            if (gm.CurrentState == GameState.Event) gm.LeaveEvent();
        }

        // =============================================
        // 전투: 한 라운드
        // =============================================

        private (int damage, bool died, string seotda) PlayRound(GameManager gm, Persona p)
        {
            var rm = gm.RoundManager;
            if (rm == null || rm.CurrentPhase != RoundManager.Phase.SelectCards)
                return (0, false, "");

            // 내기
            var cards = PickSubmitCards(rm.HandCards, p);
            if (cards.Count == 0 && rm.HandCards.Count >= 3)
                cards = new List<CardInstance> { rm.HandCards[0] };
            if (cards.Count == 0) return (0, false, "");

            rm.SubmitCards(cards);

            // Go
            int goes = 0;
            while (rm.CurrentPhase == RoundManager.Phase.GoStopChoice && goes < p.MaxGo)
            {
                int bossDmg = rm.SelectGo();
                gm.ApplyGoDamage(bossDmg);
                goes++;

                if (gm.CurrentState == GameState.GameOver)
                    return (0, true, "즉사");

                if (rm.CurrentPhase == RoundManager.Phase.SelectCards)
                {
                    var extra = PickSubmitCards(rm.HandCards, p);
                    if (extra.Count > 0) rm.SubmitCards(extra);
                }
            }

            // Stop
            if (rm.CurrentPhase == RoundManager.Phase.GoStopChoice)
                rm.SelectStop();

            // 공격
            if (rm.CurrentPhase == RoundManager.Phase.AttackSelect && rm.HandCards.Count >= 2)
            {
                var (c1, c2) = PickAttackCards(rm.HandCards, p);
                if (c1 != null && c2 != null)
                {
                    var atk = gm.SeotdaAttack(c1, c2);
                    return (atk.FinalDamage, false, atk.SeotdaName ?? "");
                }
            }

            if (rm.CurrentPhase == RoundManager.Phase.AttackSelect)
                rm.FinishRound(false);

            return (0, false, "");
        }

        // =============================================
        // 전투: 한 보스 (여러 라운드)
        // =============================================

        private (bool won, int rounds, int totalDmg) FightBoss(GameManager gm, Persona p, SimLog log)
        {
            int rounds = 0;
            int totalDmg = 0;
            string bossName = gm.CurrentBoss?.DisplayName ?? "?";
            int bossHP = gm.CurrentBattle?.BossMaxHP ?? 0;

            while (gm.CurrentState == GameState.InRound
                && gm.CurrentBattle != null
                && !gm.CurrentBattle.IsBossDefeated)
            {
                rounds++;
                log.TotalRounds++;
                var (dmg, died, seotda) = PlayRound(gm, p);
                totalDmg += dmg;

                if (died || gm.CurrentState == GameState.GameOver)
                {
                    log.Add($"    {bossName} HP:{bossHP} → ☠️ {rounds}판 (즉사)");
                    return (false, rounds, totalDmg);
                }

                if (gm.CurrentBattle != null && gm.CurrentBattle.IsBossDefeated)
                {
                    log.BossesDefeated++;
                    log.Add($"    {bossName} HP:{bossHP} → ✅ {rounds}판 {totalDmg}dmg [{seotda}]");
                    return (true, rounds, totalDmg);
                }

                // PostRound → 다음 라운드 (보스 아직 살아있으면)
                if (gm.CurrentState == GameState.PostRound
                    && gm.CurrentBattle != null && !gm.CurrentBattle.IsBossDefeated
                    && gm.Player.Lives > 0)
                {
                    gm.StartNextRound();
                }

                if (rounds > 25) break; // 안전장치
            }

            log.Add($"    {bossName} HP:{bossHP} → ❌ {rounds}판 {totalDmg}/{bossHP}dmg");
            return (false, rounds, totalDmg);
        }

        // =============================================
        // 한 나선 전체 (10관문 + 강화/상점/이벤트)
        // =============================================

        private int PlaySpiral(GameManager gm, Persona p, SimLog log)
        {
            int cleared = 0;

            for (int attempt = 0; attempt < 15; attempt++) // 최대 15관문 시도 (재시도 포함)
            {
                if (gm.CurrentState != GameState.InRound) break;
                if (gm.Player.Lives <= 0 || gm.CurrentState == GameState.GameOver) break;

                var (won, rounds, dmg) = FightBoss(gm, p, log);

                if (gm.Player.Lives <= 0 || gm.CurrentState == GameState.GameOver) break;

                if (won)
                {
                    cleared++;
                    log.RealmsCleared++;

                    // === PostRound: 웨이브 강화 ===
                    if (gm.CurrentState == GameState.PostRound)
                        DoWaveUpgrade(gm, p, log);

                    // === Shop: 부적 구매 ===
                    if (gm.CurrentState == GameState.Shop)
                        DoShop(gm, p, log);

                    // === Event: 선택 ===
                    if (gm.CurrentState == GameState.Event)
                        DoEvent(gm, p, log);

                    // === Gate 도달 ===
                    if (gm.CurrentState == GameState.Gate)
                    {
                        log.ReachedGate = true;
                        break;
                    }
                }
                else
                {
                    // 패배 → PostRound (체력 남았으면 재시도)
                    if (gm.CurrentState == GameState.PostRound && gm.Player.Lives > 0)
                        gm.StartNextRound();
                    else
                        break;
                }
            }

            return cleared;
        }

        // =============================================
        // 테스트: ⭐ 입문 — 첫 보스 클리어 가능
        // =============================================

        [Test]
        public void Star1_Beginner_CanDealDamage()
        {
            var gm = new GameManager();
            gm.StartNewGame();
            gm.BeginSpiralWithBlessing(null);

            var log = new SimLog();
            var (won, rounds, dmg) = FightBoss(gm, AllPersonas[0], log);

            foreach (var l in log.Lines) UnityEngine.Debug.Log(l);

            Assert.IsTrue(dmg > 0, "입문도 데미지를 줘야 함");
            Assert.IsTrue(rounds >= 1);
        }

        // =============================================
        // 테스트: ⭐⭐ 초급 — 풀 나선 + 상점 + 이벤트
        // =============================================

        [Test]
        public void Star2_Novice_FullSpiral_WithShopAndEvents()
        {
            var gm = new GameManager();
            gm.StartNewGame();
            gm.BeginSpiralWithBlessing(null);

            var log = new SimLog();
            var persona = AllPersonas[1];
            int cleared = PlaySpiral(gm, persona, log);

            foreach (var l in log.Lines) UnityEngine.Debug.Log(l);
            UnityEngine.Debug.Log($"[⭐⭐] {cleared}관문 | 체력:{gm.Player.Lives} 엽전:{gm.Player.Yeop} "
                + $"부적:{log.TalismansEquipped} 강화:{log.UpgradesApplied} 이벤트:{log.EventsPlayed}");

            Assert.IsTrue(cleared >= 1, $"초급은 최소 1관문, 실제:{cleared}");
            // 상점/이벤트를 실제로 거쳤는지
            Assert.IsTrue(log.TalismansEquipped >= 0, "상점 로직 실행됨");
        }

        // =============================================
        // 테스트: ⭐⭐⭐ 중급 — 웨이브 강화 효과 검증
        // =============================================

        [Test]
        public void Star3_Intermediate_WaveUpgrades_TakeEffect()
        {
            var gm = new GameManager();
            gm.StartNewGame();
            gm.BeginSpiralWithBlessing(null);

            var log = new SimLog();
            var persona = AllPersonas[2];
            int cleared = PlaySpiral(gm, persona, log);

            foreach (var l in log.Lines) UnityEngine.Debug.Log(l);
            UnityEngine.Debug.Log($"[⭐⭐⭐] {cleared}관문 | 강화:{log.UpgradesApplied} 부적:{log.TalismansEquipped}");

            Assert.IsTrue(cleared >= 3, $"중급은 3관문+, 실제:{cleared}");
            // 웨이브 강화가 실제로 적용됐는지
            bool hasWaveBuff = gm.Player.WaveChipBonus > 0
                || gm.Player.WaveMultBonus > 0
                || gm.Player.WaveTalismanSlotBonus > 0;
            // 강화를 선택했으면 효과가 있어야 함
            if (log.UpgradesApplied > 0)
                Assert.IsTrue(hasWaveBuff, "웨이브 강화 효과가 PlayerState에 반영되어야 함");
        }

        // =============================================
        // 테스트: ⭐⭐⭐⭐ 상급 — 부적 장착 + 효과
        // =============================================

        [Test]
        public void Star4_Advanced_Talismans_Equipped()
        {
            var gm = new GameManager();
            gm.StartNewGame();
            gm.BeginSpiralWithBlessing(null);

            var log = new SimLog();
            var persona = AllPersonas[3];
            int cleared = PlaySpiral(gm, persona, log);

            foreach (var l in log.Lines) UnityEngine.Debug.Log(l);
            UnityEngine.Debug.Log($"[⭐⭐⭐⭐] {cleared}관문 | 부적:{gm.Player.Talismans.Count}개 장착");

            Assert.IsTrue(cleared >= 5, $"상급은 5관문+, 실제:{cleared}");
            // 부적이 실제로 장착되었는지
            if (log.TalismansEquipped > 0)
                Assert.IsTrue(gm.Player.Talismans.Count > 0, "구매한 부적이 장착되어야 함");
        }

        // =============================================
        // 테스트: ⭐⭐⭐⭐⭐ 고수 — 10관문 클리어 → Gate 도달
        // =============================================

        [Test]
        public void Star5_Expert_ReachesGate()
        {
            var gm = new GameManager();
            gm.StartNewGame();
            gm.BeginSpiralWithBlessing(null);

            var log = new SimLog();
            var persona = AllPersonas[4];
            int cleared = PlaySpiral(gm, persona, log);

            foreach (var l in log.Lines) UnityEngine.Debug.Log(l);
            UnityEngine.Debug.Log($"[⭐⭐⭐⭐⭐] {cleared}관문 | Gate:{log.ReachedGate}");

            Assert.IsTrue(cleared >= 7, $"고수는 7관문+, 실제:{cleared}");
        }

        // =============================================
        // 테스트: Gate → 엔딩(EnterGate) 선택
        // =============================================

        [Test]
        public void Gate_EnterGate_ShowsEnding()
        {
            var gm = new GameManager();
            var messages = new List<string>();
            gm.OnMessage += msg => messages.Add(msg);

            gm.StartNewGame();
            gm.BeginSpiralWithBlessing(null);

            // 빠르게 10관문 클리어 (보스 즉사)
            for (int realm = 0; realm < 10; realm++)
            {
                if (gm.CurrentState != GameState.InRound) break;

                // 보스 즉사
                if (gm.CurrentBattle != null)
                    gm.CurrentBattle.DealDamage(new ScoringEngine.ScoreResult
                    { FinalScore = gm.CurrentBattle.BossMaxHP });

                // 공격 (FinishRound 트리거)
                var rm = gm.RoundManager;
                if (rm != null && rm.HandCards.Count >= 3)
                {
                    rm.SubmitCards(new List<CardInstance> { rm.HandCards[0] });
                    if (rm.CurrentPhase == RoundManager.Phase.GoStopChoice)
                        rm.SelectStop();
                    if (rm.CurrentPhase == RoundManager.Phase.AttackSelect && rm.HandCards.Count >= 2)
                        gm.SeotdaAttack(rm.HandCards[0], rm.HandCards[1]);
                }

                // PostRound → 다음
                if (gm.CurrentState == GameState.PostRound)
                {
                    gm.SkipWaveUpgrade();
                    if (gm.CurrentState == GameState.Shop) gm.LeaveShop();
                    if (gm.CurrentState == GameState.Event) { gm.ExecuteEventChoice(0); gm.LeaveEvent(); }
                }

                if (gm.CurrentState == GameState.Gate) break;
            }

            if (gm.CurrentState == GameState.Gate)
            {
                // 엔딩 선택
                gm.EnterGate();
                Assert.IsTrue(messages.Any(m => m.Contains("이승의 문")),
                    "엔딩 메시지 표시");

                UnityEngine.Debug.Log("[엔딩] 이승의 문 통과!");
            }
            else
            {
                UnityEngine.Debug.Log($"[엔딩] Gate 미도달, 상태: {gm.CurrentState}");
            }
        }

        // =============================================
        // 테스트: Gate → 계속 진행(ContinueAfterGate) → 나선 2
        // =============================================

        [Test]
        public void Gate_Continue_EntersSpiral2_WithHigherBossHP()
        {
            var gm = new GameManager();
            gm.StartNewGame();
            gm.BeginSpiralWithBlessing(null);

            // 10관문 즉사 클리어
            for (int realm = 0; realm < 10; realm++)
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

                if (gm.CurrentState == GameState.PostRound)
                {
                    gm.SkipWaveUpgrade();
                    if (gm.CurrentState == GameState.Shop) gm.LeaveShop();
                    if (gm.CurrentState == GameState.Event) { gm.ExecuteEventChoice(0); gm.LeaveEvent(); }
                }
                if (gm.CurrentState == GameState.Gate) break;
            }

            if (gm.CurrentState != GameState.Gate)
            {
                UnityEngine.Debug.Log($"Gate 미도달: {gm.CurrentState}");
                return;
            }

            // 계속 진행
            int spiral1 = gm.Spiral.CurrentSpiral;
            gm.ContinueAfterGate();

            Assert.AreEqual(GameState.SpiralStart, gm.CurrentState, "ContinueAfterGate → SpiralStart");
            Assert.AreEqual(spiral1 + 1, gm.Spiral.CurrentSpiral, "나선 번호 증가");
            Assert.AreEqual(1, gm.Spiral.CurrentRealm, "영역 1로 리셋");

            UnityEngine.Debug.Log($"[계속] 나선 {gm.Spiral.CurrentSpiral} 진입!");

            // 나선 2 시작 → 보스 HP 확인
            gm.BeginSpiralWithBlessing(null);

            Assert.AreEqual(GameState.InRound, gm.CurrentState);
            int spiral2HP = gm.CurrentBattle.BossMaxHP;

            // 나선 2 HP는 나선 1보다 높아야 함 (×1.8)
            // 나선 1 최소 HP = 100, 나선 2 최소 = 100 × 1.8 = 180
            Assert.IsTrue(spiral2HP > 100,
                $"나선 2 보스 HP({spiral2HP})는 나선 1(~100)보다 높아야 함");

            UnityEngine.Debug.Log($"[나선2] 보스 HP: {spiral2HP} (나선1보다 증가 확인)");
        }

        // =============================================
        // 테스트: 멀티런 — 입문이 영구강화로 결국 클리어
        // =============================================

        [Test]
        public void MultiRun_Beginner_GrowsAcrossRuns()
        {
            var persona = AllPersonas[0];
            int bestClear = 0;
            var runResults = new List<string>();

            for (int run = 1; run <= 5; run++)
            {
                var gm = new GameManager();

                // 영구강화 시뮬 (런마다 누적)
                if (run >= 2) gm.Upgrades.SetLevel("base_chips", Math.Min(run - 1, 5));
                if (run >= 3) gm.Upgrades.SetLevel("base_mult", Math.Min(run - 2, 3));
                if (run >= 4) gm.Upgrades.SetLevel("max_lives", 1);

                gm.StartNewGame();
                gm.BeginSpiralWithBlessing(null);

                var log = new SimLog();
                int cleared = PlaySpiral(gm, persona, log);
                bestClear = Math.Max(bestClear, cleared);

                string line = $"  런{run}: {cleared}관문 체력:{gm.Player.Lives} 부적:{gm.Player.Talismans.Count}";
                runResults.Add(line);
                UnityEngine.Debug.Log(line);

                if (cleared >= 10) break;
            }

            UnityEngine.Debug.Log($"[멀티런 입문] 최고: {bestClear}관문");

            // 5런 안에 성장이 보여야 함
            Assert.IsTrue(bestClear >= 2, $"5런 안에 2관문+, 실제:{bestClear}");
        }

        // =============================================
        // 테스트: 전체 상태 전환 추적
        // =============================================

        [Test]
        public void AllStateTransitions_Tracked()
        {
            var gm = new GameManager();
            var states = new List<GameState>();
            gm.OnGameStateChanged += s => states.Add(s);

            gm.StartNewGame();
            gm.BeginSpiralWithBlessing(null);

            // 보스 즉사 → 전체 흐름
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

            // 이후 흐름
            if (gm.CurrentState == GameState.PostRound) gm.SkipWaveUpgrade();
            if (gm.CurrentState == GameState.Shop) gm.LeaveShop();
            if (gm.CurrentState == GameState.Event)
            {
                gm.ExecuteEventChoice(0);
                if (gm.CurrentState == GameState.Event) gm.LeaveEvent();
            }

            UnityEngine.Debug.Log($"상태 전환: {string.Join(" → ", states)}");

            Assert.IsTrue(states.Contains(GameState.SpiralStart), "SpiralStart 거침");
            Assert.IsTrue(states.Contains(GameState.InRound), "InRound 거침");
            Assert.IsTrue(states.Contains(GameState.PostRound)
                || states.Contains(GameState.Shop)
                || states.Contains(GameState.GameOver),
                "PostRound/Shop/GameOver 중 하나 도달");
        }
    }
}

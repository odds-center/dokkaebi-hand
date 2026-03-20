using System;
using System.Collections.Generic;
using System.Linq;
using DokkaebiHand.Cards;
using DokkaebiHand.Core;
using DokkaebiHand.Talismans;

namespace DokkaebiHand.Combat
{
    /// <summary>
    /// Balatro 스타일 라운드 진행 관리
    ///
    /// [패 분배 10장] → [시너지 페이즈: 1~5장 선택 → "내기!" → 콤보 판정 → 스택]
    ///   → [고/스톱 선택]
    ///     → 고: 추가 드로우 + 보스 반격
    ///     → 스톱: 공격 페이즈로
    ///   → [공격 페이즈: 남은 손패에서 2장 → 섯다 판정 → 최종 데미지]
    /// </summary>
    public class RoundManager
    {
        public enum Phase
        {
            SelectCards,   // 시너지 페이즈: 1~5장 선택
            GoStopChoice,  // 고/스톱 선택
            AttackSelect,  // 공격 페이즈: 2장 선택
            RoundEnd       // 라운드 종료
        }

        // === 현재 상태 ===
        public Phase CurrentPhase { get; private set; }
        public List<CardInstance> HandCards { get; private set; } = new List<CardInstance>();
        public List<ComboResult> AccumulatedCombos { get; private set; } = new List<ComboResult>();
        public float AccumulatedMult { get; private set; } = 1f;
        public int AccumulatedChips { get; private set; }
        public int GoCount { get; private set; }
        public int MaxPlays { get; set; } = 5;
        public int PlaysUsed { get; private set; }

        // === 외부 접근 ===
        public DeckManager Deck => _deckManager;

        // === 의존성 ===
        private readonly DeckManager _deckManager;
        private readonly TalismanManager _talismanManager;
        private readonly PlayerState _player;
        private readonly BossManager _bossManager;
        private readonly CardEnhancementManager _cardEnhancements;
        private readonly PermanentUpgradeManager _upgrades;

        // === 축복 효과 ===
        public int BlessingHandPenalty { get; set; }
        public float BlessingChipBonus { get; set; }
        public float BlessingMultBonus { get; set; }

        // === 이벤트 ===
        public event Action<Phase> OnPhaseChanged;
        public event Action<List<ComboResult>> OnCombosEvaluated;
        public event Action<List<SynergyHint>> OnSynergyHintsUpdated;
        public event Action<bool> OnRoundEnded;
        public event Action<string> OnMessage;

        public RoundManager(PlayerState player, DeckManager deckManager,
            TalismanManager talismanManager, BossManager bossManager = null,
            CardEnhancementManager cardEnhancements = null,
            PermanentUpgradeManager upgrades = null)
        {
            _player = player;
            _deckManager = deckManager;
            _talismanManager = talismanManager;
            _bossManager = bossManager;
            _cardEnhancements = cardEnhancements;
            _upgrades = upgrades;
        }

        /// <summary>
        /// 라운드 시작: 덱 초기화 → 손패 분배
        /// </summary>
        public void StartRound(int targetScore = 0)
        {
            GoCount = 0;
            PlaysUsed = 0;
            AccumulatedCombos.Clear();

            // 기본값에 영구강화 + 웨이브 강화 반영
            int permChips = _upgrades != null ? _upgrades.GetBonusChips() : 0;
            int permMult = _upgrades != null ? _upgrades.GetBonusMult() : 0;
            AccumulatedChips = permChips + _player.WaveChipBonus;
            AccumulatedMult = 1f + permMult + _player.WaveMultBonus;

            _player.ResetForNewRound();
            _deckManager.InitializeDeck();

            // 손패 크기 결정
            int handSize = 10;
            if (_upgrades != null)
                handSize += _upgrades.GetBonusHandSize();
            if (_player.NextRoundHandBonus > 0)
            {
                handSize += _player.NextRoundHandBonus;
                _player.NextRoundHandBonus = 0;
            }
            if (BlessingHandPenalty > 0)
                handSize = Math.Max(5, handSize - BlessingHandPenalty);

            // 새 시스템: 바닥패 없이 손패만 분배
            _deckManager.DealCards(_player, handSize, fieldSize: 0);

            // 손패를 로컬 참조에 복사 (player.Hand와 동기화)
            HandCards = _player.Hand;

            // 부적 트리거: 라운드 시작
            _talismanManager.NotifyTrigger(_player, TalismanTrigger.OnRoundStart, null);

            // 보스 기믹: 라운드 시작 시
            if (_bossManager != null)
                _bossManager.OnTurnStart(_player, _deckManager);

            OnMessage?.Invoke($"손패 {HandCards.Count}장 배분! 카드를 선택하여 '내기!'");
            SetPhase(Phase.SelectCards);
        }

        /// <summary>
        /// 시너지 페이즈: 카드 선택 → "내기!" → 콤보 판정 → 스택
        /// 선택한 카드는 손패에서 소모됨. (최소 1장, 손패 범위 내)
        /// </summary>
        public List<ComboResult> SubmitCards(List<CardInstance> selected)
        {
            if (CurrentPhase != Phase.SelectCards)
                return new List<ComboResult>();

            if (selected == null || selected.Count == 0)
                return new List<ComboResult>();

            // 공격용 2장은 남겨야 함
            if (HandCards.Count - selected.Count < 2)
            {
                OnMessage?.Invoke("공격용 카드 2장은 남겨야 한다!");
                return new List<ComboResult>();
            }

            // 선택된 카드가 모두 손패에 있는지 확인
            foreach (var card in selected)
            {
                if (!HandCards.Contains(card))
                    return new List<ComboResult>();
            }

            // 콤보 판정
            var combos = HandEvaluator.Evaluate(selected);

            // 광 무효화 기믹: 광 관련 콤보 제거 (염라대왕)
            if (_bossManager != null && _bossManager.IsGwangDisabled())
            {
                combos.RemoveAll(c => c.Id != null && (
                    c.Id.Contains("gwang") || c.Id == "ogwang" || c.Id == "samgwang" ||
                    c.Id == "bigwang" || c.Id == "38gwangttaeng" || c.Id == "18gwangttaeng" ||
                    c.Id == "13gwangttaeng"));
                if (combos.Count == 0)
                    OnMessage?.Invoke("염라대왕의 기세에 광 족보가 봉인되었다!");
            }

            // 축복 보너스 적용
            if (BlessingChipBonus > 0 || BlessingMultBonus > 0)
            {
                foreach (var combo in combos)
                {
                    combo.Chips += (int)(combo.Chips * BlessingChipBonus);
                    combo.Mult *= (1f + BlessingMultBonus);
                }
            }

            // 카드 강화 보너스 적용
            if (_cardEnhancements != null)
            {
                int enhChips = 0;
                int enhMult = 0;
                foreach (var card in selected)
                {
                    var enh = _cardEnhancements.GetEnhancement(card.Id);
                    enhChips += enh.GetChipBonus(card.Type);
                    enhMult += enh.GetMultBonus(card.Type);
                }
                if (enhChips > 0 || enhMult > 0)
                {
                    combos.Add(new ComboResult
                    {
                        Id = "card_enhancement",
                        NameKR = "카드 강화",
                        NameEN = "Card Enhancement",
                        Tier = ComboTier.D,
                        Category = ComboCategory.Fallback,
                        Chips = enhChips,
                        Mult = 1f + enhMult * 0.1f,
                        Description = $"강화 보너스 +{enhChips}칩, +{enhMult * 10}%배"
                    });
                }
            }

            // 이전 턴의 보류 회복 적용 (다음 내기까지 유지했으므로 회복!)
            if (_player.PendingHealCombo != null && _player.PendingHealAmount > 0)
            {
                int heal = _player.PendingHealAmount;
                _player.Lives = System.Math.Min(_player.Lives + heal, PlayerState.MaxLives);
                OnMessage?.Invoke($"[{_player.PendingHealCombo}] 유지 성공! 체력 +{heal} 회복! ({_player.Lives}/{PlayerState.MaxLives})");
                _player.PendingHealCombo = null;
                _player.PendingHealAmount = 0;
            }

            // 누적
            AccumulatedCombos.AddRange(combos);
            var (chips, mult) = HandEvaluator.GetTotalScore(combos);
            AccumulatedChips += chips;
            AccumulatedMult *= mult;

            // 회복 족보 대기 등록 (이번 턴에 회복 족보가 있으면 다음 턴까지 유지해야 회복)
            foreach (var combo in combos)
            {
                if (combo.HealAmount > 0 && combo.HealRequiresHold)
                {
                    _player.PendingHealCombo = combo.NameKR;
                    _player.PendingHealAmount = combo.HealAmount;
                    OnMessage?.Invoke($"[{combo.NameKR}] 다음 내기까지 유지하면 체력 +{combo.HealAmount} 회복!");
                    break; // 회복 족보는 한 번에 하나만
                }
            }

            // 선택한 카드 소모
            foreach (var card in selected)
                HandCards.Remove(card);

            PlaysUsed++;

            // 부적 트리거
            _talismanManager.NotifyTrigger(_player, TalismanTrigger.OnCardPlayed, selected.FirstOrDefault());
            if (combos.Count > 0)
                _talismanManager.NotifyTrigger(_player, TalismanTrigger.OnYokboComplete, selected.FirstOrDefault());

            // 메시지
            if (combos.Count > 0)
            {
                var comboNames = string.Join(" + ", combos.Select(c => c.NameKR));
                OnMessage?.Invoke($"내기! → {comboNames}");
                OnMessage?.Invoke($"  누적: 칩 {AccumulatedChips} × 배수 {AccumulatedMult:F1}");
            }
            else
            {
                OnMessage?.Invoke("내기! → 콤보 없음...");
            }

            OnCombosEvaluated?.Invoke(combos);

            // 시너지 힌트: 남은 손패로 추가 시너지 가능한 조합 표시
            if (HandCards.Count >= 3) // 공격 2장 + 최소 1장 여유
            {
                // 빈 선택 상태에서 남은 손패 전체를 대상으로 힌트 생성
                var emptySelection = new List<CardInstance>();
                var synHints = HandEvaluator.PreviewSynergies(emptySelection, HandCards);
                if (synHints.Count > 0)
                {
                    OnSynergyHintsUpdated?.Invoke(synHints);
                    var topHint = synHints[0];
                    OnMessage?.Invoke($"  💡 시너지 힌트: {topHint.ComboNameKR} — {topHint.Condition}");
                }
            }

            // 다음 상태 결정
            if (HandCards.Count < 2)
            {
                // 공격용 카드 부족 → 공격 없이 판 종료 (시너지는 유지, 패배 아님)
                OnMessage?.Invoke("손패 부족! 공격 없이 판이 끝난다!");
                SetPhase(Phase.AttackSelect);
            }
            else if (PlaysUsed >= MaxPlays)
            {
                // 최대 내기 횟수 도달 → 공격 페이즈
                OnMessage?.Invoke("내기 완료! 공격할 2장을 골라라!");
                SetPhase(Phase.AttackSelect);
            }
            else if (AccumulatedCombos.Count > 0)
            {
                // 콤보가 하나라도 있으면 Go/Stop 선택 가능
                SetPhase(Phase.GoStopChoice);
            }
            else
            {
                // 콤보 없음 → 추가 내기 계속 (Go/Stop 불가)
                OnMessage?.Invoke("콤보 없음... 카드를 더 선택하여 내기!");
                SetPhase(Phase.SelectCards);
            }

            return combos;
        }

        /// <summary>
        /// "고!" 선택: 추가 드로우 + 보스 반격 데미지 반환
        ///
        /// Go 1: +3장, 보스 경공격
        /// Go 2: +2장, 보스 강공격
        /// Go 3: +1장, 보스 필살기 + 즉사 위험
        /// </summary>
        public int SelectGo()
        {
            if (CurrentPhase != Phase.GoStopChoice)
                return 0;

            GoCount++;
            _player.GoCount = GoCount;

            // 추가 드로우
            int drawCount;
            int bossDamage;
            string goMessage;

            switch (GoCount)
            {
                case 1:
                    drawCount = 3;
                    bossDamage = 0;
                    goMessage = "고 1회! +3장, 배수 ×1.5!";
                    break;
                case 2:
                    drawCount = 2;
                    bossDamage = 5;
                    goMessage = "고 2회! +2장, 배수 ×2! 보스 반격!";
                    break;
                default: // 3+
                    drawCount = 1;
                    bossDamage = 10;
                    goMessage = "고 3회! +1장, 배수 ×3! 즉사 위험!";
                    break;
            }

            // 드로우
            for (int i = 0; i < drawCount; i++)
            {
                var drawn = _deckManager.DrawFromPile();
                if (drawn != null)
                    HandCards.Add(drawn);
            }

            // 부적 트리거
            _talismanManager.NotifyTrigger(_player, TalismanTrigger.OnGoDecision, null);

            OnMessage?.Invoke(goMessage);
            OnMessage?.Invoke($"  손패: {HandCards.Count}장");

            // 시너지 페이즈로 복귀
            SetPhase(Phase.SelectCards);

            return bossDamage;
        }

        /// <summary>
        /// "스톱!" 선택: 공격 페이즈로 전환
        /// </summary>
        public void SelectStop()
        {
            if (CurrentPhase != Phase.GoStopChoice)
                return;

            // 부적 트리거
            _talismanManager.NotifyTrigger(_player, TalismanTrigger.OnStopDecision, null);

            OnMessage?.Invoke("스톱! 공격할 2장을 골라라!");
            OnMessage?.Invoke($"  누적 시너지: 칩 {AccumulatedChips} × 배수 {AccumulatedMult:F1}");

            SetPhase(Phase.AttackSelect);
        }

        /// <summary>
        /// 공격 페이즈: 남은 손패에서 2장 선택 → 섯다 판정 → 최종 데미지
        /// </summary>
        public SeotdaAttackResult ExecuteAttack(CardInstance card1, CardInstance card2)
        {
            if (CurrentPhase != Phase.AttackSelect)
                return new SeotdaAttackResult { FinalDamage = 0 };

            if (card1 == null || card2 == null)
                return new SeotdaAttackResult { FinalDamage = 0 };

            if (!HandCards.Contains(card1) || !HandCards.Contains(card2))
                return new SeotdaAttackResult { FinalDamage = 0 };

            if (card1 == card2)
                return new SeotdaAttackResult { FinalDamage = 0 };

            // 광 무효화 기믹 체크 (염라대왕)
            if (_bossManager != null && _bossManager.IsGwangDisabled())
            {
                if (card1.Type == CardType.Gwang || card2.Type == CardType.Gwang)
                {
                    OnMessage?.Invoke("염라대왕의 기세에 광이 봉인되었다! 광 카드로 공격 불가!");
                    return new SeotdaAttackResult { FinalDamage = 0 };
                }
            }

            // 섯다 족보 판정
            var seotda = SeotdaChallenge.Evaluate(card1, card2);

            // 섯다 기본 데미지
            int baseDamage = CalculateSeotdaBaseDamage(seotda);

            // 고 배수
            float goMult = GoCount switch
            {
                1 => 1.5f,
                2 => 2f,
                >= 3 => 3f,
                _ => 1f
            };

            // 부적 효과: 공격 시 칩/배수 보너스
            int talismanChips = 0;
            float talismanMult = 1f;
            if (_talismanManager != null)
            {
                var talismanResult = _talismanManager.ApplyTalismanEffects(
                    _player,
                    new ScoringEngine.ScoreResult { Chips = 0, Mult = 1, FinalScore = 0 },
                    TalismanTrigger.OnStopDecision);
                talismanChips = talismanResult.Chips;
                if (talismanResult.Mult > 1)
                    talismanMult = talismanResult.Mult;
            }

            // 최종 데미지 = (섯다 기본 + 누적 칩 + 부적 칩) × 누적 배수 × 부적 배수 × 고 배수
            long rawDamage = (long)((baseDamage + AccumulatedChips + talismanChips)
                * AccumulatedMult * talismanMult * goMult);
            int finalDamage = (int)System.Math.Min(rawDamage, int.MaxValue);

            // 카드 소모 (원자적 처리: 두 장 모두 제거 가능한지 먼저 확인)
            int idx1 = HandCards.IndexOf(card1);
            int idx2 = HandCards.IndexOf(card2);
            if (idx1 < 0 || idx2 < 0)
                return new SeotdaAttackResult { FinalDamage = 0 };

            // 큰 인덱스부터 제거하여 인덱스 밀림 방지
            if (idx1 > idx2)
            {
                HandCards.RemoveAt(idx1);
                HandCards.RemoveAt(idx2);
            }
            else
            {
                HandCards.RemoveAt(idx2);
                HandCards.RemoveAt(idx1);
            }

            var result = new SeotdaAttackResult
            {
                SeotdaName = seotda.Name,
                SeotdaRank = seotda.Rank,
                BaseDamage = baseDamage,
                AccumulatedChips = AccumulatedChips,
                AccumulatedMult = AccumulatedMult,
                GoMult = goMult,
                FinalDamage = finalDamage,
                Combos = new List<string>(AccumulatedCombos.Select(c => c.NameKR))
            };

            OnMessage?.Invoke($"[{seotda.Name}] 기본 {baseDamage} + 칩 {AccumulatedChips}");
            OnMessage?.Invoke($"  × 시너지 {AccumulatedMult:F1} × 고 {goMult:F0} = {finalDamage} 타격!");

            return result;
        }

        /// <summary>
        /// 라운드 종료 처리 (GameManager에서 호출)
        /// </summary>
        public void FinishRound(bool won)
        {
            // 부적 트리거: 라운드 종료
            _talismanManager.NotifyTrigger(_player, TalismanTrigger.OnRoundEnd, null);

            SetPhase(Phase.RoundEnd);
            OnRoundEnded?.Invoke(won);
        }

        /// <summary>
        /// 현재 Go 리스크 정보 (UI 표시용)
        /// </summary>
        public GoRiskInfo GetCurrentGoRisk()
        {
            int nextGo = GoCount + 1;
            return nextGo switch
            {
                1 => new GoRiskInfo
                {
                    DrawCards = 3, BossDamage = 0,
                    Description = "고 1: +3장 드로우, 배수 ×1.5",
                    InstantDeathRisk = false
                },
                2 => new GoRiskInfo
                {
                    DrawCards = 2, BossDamage = 5,
                    Description = "고 2: +2장 드로우, 배수 ×2, 보스 반격!",
                    InstantDeathRisk = false
                },
                _ => new GoRiskInfo
                {
                    DrawCards = 1, BossDamage = 10,
                    Description = "고 3: +1장 드로우, 배수 ×3, 즉사 위험!",
                    InstantDeathRisk = true
                }
            };
        }

        /// <summary>
        /// 불꽃 도깨비: 시너지 배수 보너스
        /// </summary>
        public void ApplyFlameBonus()
        {
            OnMessage?.Invoke("불꽃 도깨비: 시너지 배수 +0.5!");
            AccumulatedMult += 0.5f;
        }

        /// <summary>
        /// 그림자 도깨비: 목표 점수 -15% (AccumulatedChips 보너스로 대체)
        /// </summary>
        public void ApplyShadowReduction()
        {
            int bonus = (int)(AccumulatedChips * 0.15f);
            if (bonus < 10) bonus = 10;
            AccumulatedChips += bonus;
            OnMessage?.Invoke($"그림자 도깨비: 잠식! 칩 +{bonus} (목표 약화)");
        }

        /// <summary>
        /// 뱃사공: 마지막 내기 되감기 (간소화: 배수 +0.3)
        /// </summary>
        public void ApplyBoatmanUndo()
        {
            AccumulatedMult += 0.3f;
            OnMessage?.Invoke("뱃사공: 항해! 시너지 배수 +0.3!");
        }

        /// <summary>
        /// 동료 도깨비 스킬: 손패 1장 교체 (뽑기패에서 1장 드로우)
        /// </summary>
        public bool CompanionSwapCard(CardInstance handCard)
        {
            if (!HandCards.Contains(handCard)) return false;
            var drawn = _deckManager.DrawFromPile();
            if (drawn == null) return false;

            HandCards.Remove(handCard);
            _deckManager.ReturnToPile(handCard);
            HandCards.Add(drawn);
            OnMessage?.Invoke($"교환: {handCard.NameKR} → {drawn.NameKR}");
            return true;
        }

        /// <summary>
        /// 여우 도깨비 스킬: 다음 내기 와일드카드
        /// </summary>
        public void SetWildCardNext()
        {
            _player.WildCardNextMatch = true;
            OnMessage?.Invoke("다음 내기는 와일드카드!");
        }

        /// <summary>
        /// 시너지 미리보기: 현재 선택된 카드 기반으로 가능한 시너지 힌트 반환.
        /// UI에서 카드 선택 중 실시간 호출.
        /// </summary>
        public List<SynergyHint> PreviewSynergies(List<CardInstance> selectedCards)
        {
            if (CurrentPhase != Phase.SelectCards)
                return new List<SynergyHint>();

            var remaining = new List<CardInstance>();
            foreach (var card in HandCards)
            {
                if (!selectedCards.Contains(card))
                    remaining.Add(card);
            }

            return HandEvaluator.PreviewSynergies(selectedCards, remaining);
        }

        /// <summary>
        /// 섯다 기본 데미지 테이블
        /// </summary>
        private int CalculateSeotdaBaseDamage(SeotdaResult seotda)
        {
            // 깔끔한 숫자. 시너지 없이도 한 판에 30~80 데미지.
            // 1관문 보스(HP 300)를 4~5판이면 잡을 수 있는 수준.
            return seotda.Rank switch
            {
                100 => 80,      // 38광땡 — 대박!
                99 => 70,       // 18광땡
                98 => 65,       // 13광땡
                95 => 60,       // 기타 광땡
                >= 90 => 50,    // 장땡
                >= 80 => 25 + (seotda.Rank - 80) * 2, // N땡 (25~45)
                75 => 35,       // 알리
                74 => 32,       // 독사
                73 => 30,       // 구삥
                72 => 28,       // 장삥
                71 => 25,       // 장사
                70 => 22,       // 세륙
                >= 7 => 12 + seotda.Rank, // 7~9끗 (19~21)
                >= 1 => 8 + seotda.Rank,  // 1~6끗 (9~14)
                0 => 5,         // 갑오(0끗)
                _ => 5
            };
        }

        private void SetPhase(Phase phase)
        {
            CurrentPhase = phase;
            OnPhaseChanged?.Invoke(phase);
        }
    }

    /// <summary>
    /// 섯다 공격 결과
    /// </summary>
    public class SeotdaAttackResult
    {
        public string SeotdaName;
        public int SeotdaRank;
        public int BaseDamage;
        public int AccumulatedChips;
        public float AccumulatedMult;
        public float GoMult;
        public int FinalDamage;
        public List<string> Combos;
    }

    /// <summary>
    /// Go 선택 리스크 정보 (UI 표시용)
    /// </summary>
    public class GoRiskInfo
    {
        public int DrawCards;
        public int BossDamage;
        public string Description;
        public bool InstantDeathRisk;
    }
}

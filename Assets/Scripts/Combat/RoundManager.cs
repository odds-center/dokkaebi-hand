using System;
using System.Collections.Generic;
using DokkaebiHand.Cards;
using DokkaebiHand.Core;
using DokkaebiHand.Talismans;

namespace DokkaebiHand.Combat
{
    /// <summary>
    /// 라운드 진행 관리
    /// [패 분배] → [보스 기믹] → [턴: 손패 선택 → 바닥 매칭 → 뒤집기 매칭]
    ///     → [족보 체크] → [Go/Stop 선택] → [점수 정산]
    /// </summary>
    public class RoundManager
    {
        public enum RoundPhase
        {
            Dealing,
            PlayerTurn,
            HandMatch,
            DrawFlip,
            DrawMatch,
            YokboCheck,
            GoStopChoice,
            Scoring,
            RoundEnd
        }

        private readonly DeckManager _deckManager;
        private readonly MatchingEngine _matchingEngine;
        private readonly ScoringEngine _scoringEngine;
        private readonly GoStopDecision _goStopDecision;
        private readonly TalismanManager _talismanManager;
        private readonly PlayerState _player;
        private readonly BossManager _bossManager;
        private readonly CardEnhancementManager _cardEnhancements;
        private readonly PermanentUpgradeManager _upgrades;

        public RoundPhase CurrentPhase { get; private set; }
        public int TurnNumber { get; private set; }
        public int TargetScore { get; set; }
        public ScoringEngine.ScoreResult LastScoreResult { get; private set; }

        /// <summary>
        /// UI에서 바닥패에 접근하기 위한 공개 프로퍼티
        /// </summary>
        public IReadOnlyList<CardInstance> FieldCards => _deckManager.FieldCards;
        public IReadOnlyList<CardInstance> DrawPile => _deckManager.DrawPile;

        private CardInstance _currentHandCard;
        private CardInstance _currentDrawnCard;

        // Events
        public event Action<RoundPhase> OnPhaseChanged;
        public event Action<List<CardInstance>> OnCardsMatched;
        public event Action<ScoringEngine.ScoreResult> OnScoreCalculated;
        public event Action<bool> OnRoundEnded;
        public event Action<string> OnMessage;

        public RoundManager(PlayerState player, DeckManager deckManager,
            TalismanManager talismanManager, BossManager bossManager = null,
            CardEnhancementManager cardEnhancements = null,
            PermanentUpgradeManager upgrades = null)
        {
            _player = player;
            _deckManager = deckManager;
            _matchingEngine = new MatchingEngine(deckManager);
            _scoringEngine = new ScoringEngine();
            _goStopDecision = new GoStopDecision(_scoringEngine);
            _talismanManager = talismanManager;
            _bossManager = bossManager;
            _cardEnhancements = cardEnhancements;
            _upgrades = upgrades;
        }

        // 쓸 배수 누적 (라운드 내)
        private int _sweepMultBonus;

        // 축복 핸드 패널티
        public int BlessingHandPenalty { get; set; }
        // 축복 칩/배수 보너스
        public float BlessingChipBonus { get; set; }
        public float BlessingMultBonus { get; set; }

        // 섯다 승부 결과 버프
        public int SeotdaBonusChips { get; set; }
        public int SeotdaBonusMult { get; set; }
        public int SeotdaChipPenalty { get; set; }

        // 이번 판 섯다 결과
        public SeotdaChallenge LastSeotda { get; private set; }

        /// <summary>
        /// 라운드 시작
        /// </summary>
        public void StartRound(int targetScore)
        {
            TargetScore = targetScore;
            TurnNumber = 0;
            _sweepMultBonus = 0;

            _player.ResetForNewRound();
            _deckManager.InitializeDeck();

            // === 섯다 승부 (판 시작 전 2장 대결) ===
            LastSeotda = new SeotdaChallenge();
            LastSeotda.OnMessage += msg => OnMessage?.Invoke(msg);
            LastSeotda.Execute(_deckManager);
            SeotdaBonusChips = LastSeotda.BonusChips;
            SeotdaBonusMult = LastSeotda.BonusMult;
            SeotdaChipPenalty = LastSeotda.ChipPenalty;

            // 영구 강화: 시작 손패 보너스
            int handSize = 10;
            if (_upgrades != null)
                handSize += _upgrades.GetBonusHandSize();

            // 소모품(패 팩) 보너스 반영
            if (_player.NextRoundHandBonus > 0)
            {
                handSize += _player.NextRoundHandBonus;
                _player.NextRoundHandBonus = 0;
            }

            // 축복 빙결: 손패 -1
            if (BlessingHandPenalty > 0)
                handSize = System.Math.Max(5, handSize - BlessingHandPenalty);

            _deckManager.DealCards(_player, handSize);

            // 부적 목표 감소
            TargetScore = _talismanManager.ApplyTargetReduction(_player, TargetScore);

            SetPhase(RoundPhase.PlayerTurn);
        }

        /// <summary>
        /// 손패에서 카드 선택
        /// </summary>
        public MatchResult PlayHandCard(CardInstance card)
        {
            if (CurrentPhase != RoundPhase.PlayerTurn) return MatchResult.NoMatch;
            if (!_player.Hand.Contains(card)) return MatchResult.NoMatch;

            _currentHandCard = card;
            _player.Hand.Remove(card);

            // 보스 기믹: 턴 시작 시 발동
            if (_bossManager != null)
                _bossManager.OnTurnStart(_player, _deckManager);

            // 부적 트리거: OnTurnStart
            _talismanManager.NotifyTrigger(_player, TalismanTrigger.OnTurnStart, card);

            var matchResult = _matchingEngine.EvaluateMatch(card);

            // 매칭 실패 시 부적 트리거
            if (matchResult == MatchResult.NoMatch)
                _talismanManager.NotifyTrigger(_player, TalismanTrigger.OnMatchFail, card);

            SetPhase(RoundPhase.HandMatch);
            return matchResult;
        }

        /// <summary>
        /// 손패 매칭 실행
        /// </summary>
        public List<CardInstance> ExecuteHandMatch(CardInstance selectedMatch = null)
        {
            if (CurrentPhase != RoundPhase.HandMatch) return new List<CardInstance>();

            var captured = _matchingEngine.ExecuteMatch(_currentHandCard, selectedMatch);

            foreach (var card in captured)
                _player.CaptureCard(card);

            OnCardsMatched?.Invoke(captured);

            // 쓸 보너스 체크 (영구 강화)
            if (captured.Count >= 4 && _upgrades != null)
            {
                int sweepBonus = _upgrades.GetLevel("sweep_bonus");
                if (sweepBonus > 0)
                {
                    _sweepMultBonus += sweepBonus;
                    OnMessage?.Invoke($"쓸! 배수 +{sweepBonus} (영구 강화)");
                }
            }

            // 부적 트리거: OnMatchSuccess
            if (captured.Count > 0)
                _talismanManager.NotifyTrigger(_player, TalismanTrigger.OnMatchSuccess, _currentHandCard);

            // 부적 트리거: OnCardPlayed
            _talismanManager.NotifyTrigger(_player, TalismanTrigger.OnCardPlayed, _currentHandCard);

            SetPhase(RoundPhase.DrawFlip);
            return captured;
        }

        public CardInstance FlipDrawCard()
        {
            if (CurrentPhase != RoundPhase.DrawFlip) return null;

            _currentDrawnCard = _deckManager.DrawFromPile();
            if (_currentDrawnCard == null)
            {
                EndTurn();
                return null;
            }

            SetPhase(RoundPhase.DrawMatch);
            return _currentDrawnCard;
        }

        public List<CardInstance> ExecuteDrawMatch(CardInstance selectedMatch = null)
        {
            if (CurrentPhase != RoundPhase.DrawMatch) return new List<CardInstance>();

            var captured = _matchingEngine.ExecuteDrawMatch(_currentDrawnCard, selectedMatch);

            foreach (var card in captured)
                _player.CaptureCard(card);

            OnCardsMatched?.Invoke(captured);
            EndTurn();
            return captured;
        }

        public GoStopDecision.GoRisk SelectGo()
        {
            if (CurrentPhase != RoundPhase.GoStopChoice) return default;

            var risk = _goStopDecision.GetGoRisk(_player.GoCount);
            _goStopDecision.ExecuteGo(_player);

            SetPhase(RoundPhase.PlayerTurn);
            return risk;
        }

        /// <summary>
        /// Go 리스크 정보 조회 (UI 표시용)
        /// </summary>
        public GoStopDecision.GoRisk GetCurrentGoRisk()
        {
            return _goStopDecision.GetGoRisk(_player.GoCount);
        }

        /// <summary>
        /// 스톱 선택 → 공격 페이즈로 전환
        /// 이제 직접 데미지를 계산하지 않음.
        /// UI에서 "공격할 2장 선택" 화면을 보여주고,
        /// GameManager.SeotdaAttack()을 호출해야 함.
        /// </summary>
        public ScoringEngine.ScoreResult SelectStop()
        {
            if (CurrentPhase != RoundPhase.GoStopChoice) return default;

            // 현재 시너지 상태 계산 (UI 표시용)
            var result = _scoringEngine.CalculateScore(_player);
            LastScoreResult = result;
            OnScoreCalculated?.Invoke(result);

            OnMessage?.Invoke("스톱! 공격할 2장을 골라라!");

            // 공격 페이즈로 전환 (RoundEnd가 아님!)
            SetPhase(RoundPhase.Scoring);
            return result;
        }

        /// <summary>
        /// 공격 완료 후 라운드 종료 (GameManager에서 호출)
        /// </summary>
        public void FinishRound(bool won)
        {
            SetPhase(RoundPhase.RoundEnd);
            OnRoundEnded?.Invoke(won);
        }

        /// <summary>
        /// 동료 도깨비 스킬: 바닥패 1장 제거
        /// </summary>
        public bool CompanionRemoveFieldCard(int fieldIndex)
        {
            if (fieldIndex < 0 || fieldIndex >= _deckManager.FieldCards.Count) return false;
            var card = _deckManager.FieldCards[fieldIndex];
            _deckManager.RemoveFromField(card);
            OnMessage?.Invoke($"동료 스킬: {card.NameKR} 제거!");
            return true;
        }

        /// <summary>
        /// 동료 도깨비 스킬: 손패 1장 ↔ 바닥패 1장 교환
        /// </summary>
        public bool CompanionSwapCards(CardInstance handCard, int fieldIndex)
        {
            if (!_player.Hand.Contains(handCard)) return false;
            if (fieldIndex < 0 || fieldIndex >= _deckManager.FieldCards.Count) return false;

            var fieldCard = _deckManager.FieldCards[fieldIndex];
            _deckManager.RemoveFromField(fieldCard);
            _player.Hand.Remove(handCard);
            _deckManager.AddToField(handCard);
            _player.Hand.Add(fieldCard);
            OnMessage?.Invoke($"교환: {handCard.NameKR} ↔ {fieldCard.NameKR}");
            return true;
        }

        /// <summary>
        /// 여우 도깨비 스킬: 다음 매칭 와일드카드
        /// </summary>
        public void SetWildCardNext()
        {
            _player.WildCardNextMatch = true;
            OnMessage?.Invoke("다음 매칭은 와일드카드!");
        }

        /// <summary>
        /// 동료 도깨비 스킬: 바닥패 전체 리셋
        /// </summary>
        public bool CompanionResetField()
        {
            int fieldCount = _deckManager.FieldCards.Count;
            if (fieldCount == 0) return false;

            // 바닥패 모두 뽑기패로 되돌리기
            var fieldCopy = new List<CardInstance>(_deckManager.FieldCards);
            foreach (var c in fieldCopy)
                _deckManager.RemoveFromField(c);

            // 뽑기패에서 새로 바닥에 배치
            int newFieldSize = System.Math.Min(fieldCount, _deckManager.DrawPile.Count);
            for (int i = 0; i < newFieldSize; i++)
            {
                var drawn = _deckManager.DrawFromPile();
                if (drawn != null) _deckManager.AddToField(drawn);
            }

            OnMessage?.Invoke($"바닥패 리셋! {newFieldSize}장 새로 배치!");
            return true;
        }

        /// <summary>
        /// 그림자 도깨비: 목표 점수 -15%
        /// </summary>
        public void ApplyShadowReduction()
        {
            TargetScore = (int)(TargetScore * 0.85f);
            OnMessage?.Invoke($"그림자 도깨비: 목표 → {TargetScore}");
        }

        private void EndTurn()
        {
            TurnNumber++;

            // 부적 트리거: OnTurnEnd (흉살 등)
            _talismanManager.NotifyTrigger(_player, TalismanTrigger.OnTurnEnd, null);

            var currentScore = _scoringEngine.CalculateScore(_player);

            if (currentScore.CompletedYokbo.Count > 0 && currentScore.FinalScore > 0)
            {
                LastScoreResult = currentScore;
                OnScoreCalculated?.Invoke(currentScore);
                SetPhase(RoundPhase.GoStopChoice);
            }
            else if (_player.Hand.Count == 0 || _deckManager.IsDrawPileEmpty())
            {
                // 패 소진 → 강제로 공격 페이즈 진입
                LastScoreResult = currentScore;
                OnMessage?.Invoke("패 소진! 모은 패로 공격하라!");

                // 먹은 패가 2장 이상이면 공격 가능, 아니면 패배
                var totalCaptured = _player.CapturedGwang.Count + _player.CapturedTti.Count +
                    _player.CapturedYeolkkeut.Count + _player.CapturedPi.Count;
                if (totalCaptured >= 2)
                {
                    SetPhase(RoundPhase.Scoring); // 공격 페이즈
                }
                else
                {
                    SetPhase(RoundPhase.RoundEnd);
                    OnRoundEnded?.Invoke(false); // 공격 불가 → 패배
                }
            }
            else
            {
                SetPhase(RoundPhase.PlayerTurn);
            }
        }

        /// <summary>
        /// 카드 강화 보너스를 점수에 적용
        /// </summary>
        private void ApplyCardEnhancementBonuses(ref ScoringEngine.ScoreResult result)
        {
            int totalChipBonus = 0;
            int totalMultBonus = 0;

            // 획득한 모든 카드의 강화 보너스 합산
            void AddBonuses(List<CardInstance> cards)
            {
                foreach (var card in cards)
                {
                    var enh = _cardEnhancements.GetEnhancement(card.Id);
                    totalChipBonus += enh.GetChipBonus(card.Type);
                    totalMultBonus += enh.GetMultBonus(card.Type);
                }
            }

            AddBonuses(_player.CapturedGwang);
            AddBonuses(_player.CapturedTti);
            AddBonuses(_player.CapturedYeolkkeut);
            AddBonuses(_player.CapturedPi);

            if (totalChipBonus > 0)
            {
                result.Chips += totalChipBonus;
                result.CompletedYokbo.Add($"카드 강화 (+{totalChipBonus} 칩)");
            }
            if (totalMultBonus > 0)
            {
                result.Mult += totalMultBonus;
                result.CompletedYokbo.Add($"카드 강화 (+{totalMultBonus} 배수)");
            }
        }

        private void ApplySpecialTalismanEffects(ref ScoringEngine.ScoreResult result)
        {
            foreach (var talisman in _player.Talismans)
            {
                if (!talisman.IsActive) continue;

                if (talisman.Data.Name == "Blood Oath")
                {
                    int piCount = _player.GetTotalPiCount();
                    int piBonus = piCount / 2; // 2장당 배+1 (밸런스 조정)
                    result.Mult += piBonus;
                    if (piBonus > 0)
                        result.CompletedYokbo.Add($"피의 맹세 (+{piBonus} 배)");
                }

                if (talisman.Data.Name == "Reaper's Ledger")
                {
                    int tempScore = result.Chips * result.Mult;
                    if (tempScore % 10 == 4)
                    {
                        result.Mult *= 4;
                        result.CompletedYokbo.Add("저승사자의 명부 (끝자리 4 → x4)");
                    }
                }
            }

            result.FinalScore = result.Chips * result.Mult;
        }

        private void SetPhase(RoundPhase phase)
        {
            CurrentPhase = phase;
            OnPhaseChanged?.Invoke(phase);
        }
    }
}

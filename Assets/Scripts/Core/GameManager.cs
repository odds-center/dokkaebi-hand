using System;
using System.Collections.Generic;
using DokkaebiHand.Cards;
using DokkaebiHand.Combat;
using DokkaebiHand.Talismans;

namespace DokkaebiHand.Core
{
    /// <summary>
    /// 게임 루프 총괄: 라운드 연결, 층 진행, 승패 처리
    /// </summary>
    public enum GameState
    {
        MainMenu,
        SpiralStart,    // 나선 시작 (축복 선택)
        PreRound,       // 라운드 시작 전 (보스 소개)
        InRound,        // 라운드 진행 중
        PostRound,      // 라운드 종료 (결과 + 강화 선택)
        Shop,           // 상점
        Event,          // 이벤트
        Gate,           // 이승의 문 (선택적 엔딩)
        GameOver        // 게임 오버 (죽음)
    }

    public class GameManager
    {
        private readonly PlayerState _player;
        private readonly DeckManager _deckManager;
        private readonly TalismanManager _talismanManager;
        private readonly BossManager _bossManager;
        private readonly SpiralManager _spiral;
        private readonly BossGenerator _bossGenerator;
        private readonly PermanentUpgradeManager _upgrades;
        private readonly AchievementManager _achievements;
        private readonly CompanionManager _companions;
        private readonly CardEnhancementManager _cardEnhancements;
        private readonly ShopManager _shop;
        private readonly EventManager _events;
        private readonly DestinySystem _destiny;
        private readonly GreedScale _greedScale;
        private readonly SealEffectManager _sealEffects;
        private readonly BattleSystem _battleSystem;
        private RoundManager _roundManager;

        public GameState CurrentState { get; private set; }
        public PlayerState Player => _player;
        public RoundManager RoundManager => _roundManager;
        public BossManager BossManager => _bossManager;
        public SpiralManager Spiral => _spiral;
        public PermanentUpgradeManager Upgrades => _upgrades;
        public AchievementManager Achievements => _achievements;
        public CompanionManager Companions => _companions;
        public CardEnhancementManager CardEnhancements => _cardEnhancements;
        public ShopManager Shop => _shop;
        public EventManager Events => _events;
        public DestinySystem Destiny => _destiny;
        public GreedScale GreedScale => _greedScale;
        public SealEffectManager SealEffects => _sealEffects;
        public BattleSystem Battle => _battleSystem;

        public int CurrentRoundInRealm { get; private set; }
        public int TotalRoundsInRealm { get; private set; }
        public GeneratedBoss CurrentBoss { get; private set; }
        public BossBattle CurrentBattle { get; private set; }

        // 런 내 통계
        private int _runSoulFragments;
        private float _goTargetMultiplier = 1f;
        private int _goHandPenalty = 0;

        // Events
        public event Action<GameState> OnGameStateChanged;
        public event Action<string> OnMessage;
        public event Action<GeneratedBoss> OnBossGenerated;
        public event Action OnGateAppeared;
        public event Action OnWaveUpgradeReady;

        public GameManager()
        {
            _player = new PlayerState();
            _deckManager = new DeckManager();
            _talismanManager = new TalismanManager();
            _bossManager = new BossManager();
            _spiral = new SpiralManager();
            _bossGenerator = new BossGenerator();
            _upgrades = new PermanentUpgradeManager();
            _achievements = new AchievementManager();
            _companions = new CompanionManager();
            _cardEnhancements = new CardEnhancementManager();
            _shop = new ShopManager();
            _events = new EventManager();
            _destiny = new DestinySystem();
            _greedScale = new GreedScale();
            _sealEffects = new SealEffectManager();
            _battleSystem = new BattleSystem();

            // 이벤트 연결
            _spiral.OnGateAppeared += () => SetState(GameState.Gate);
            _achievements.OnAchievementUnlocked += def =>
            {
                _upgrades.AddSoulFragments(def.SoulReward);
                OnMessage?.Invoke($"업적 달성: {def.NameKR} (+{def.SoulReward} 영혼)");
            };

            CurrentState = GameState.MainMenu;
        }

        /// <summary>
        /// 새 게임 시작 (영구 강화 반영)
        /// </summary>
        public void StartNewGame()
        {
            // 사주팔자 생성
            _destiny.GenerateDestiny();

            _player.Lives = 3 + _upgrades.GetExtraLives();
            _player.Yeop = 100 + _upgrades.GetBonusStartYeop() + _destiny.GetStartYeopBonus();
            _player.CurrentFloor = 1;
            _goTargetMultiplier = 1f;
            _goHandPenalty = 0;
            _runSoulFragments = 0;

            // 영구 강화 반영
            _player.PermanentTalismanSlotBonus = _upgrades.GetExtraTalismanSlots()
                - _destiny.GetTalismanSlotPenalty(); // 사주 공 시: -1

            // 런 내 버프 초기화
            _player.WaveChipBonus = 0;
            _player.WaveMultBonus = 0;
            _player.WaveTalismanSlotBonus = 0;
            _player.WaveTalismanEffectBonus = 0f;
            _player.WaveTargetReduction = 0f;
            _player.NextRoundHandBonus = 0;
            _player.WildCardNextMatch = false;
            _player.Talismans.Clear();

            SetState(GameState.SpiralStart);
        }

        // 웨이브 강화 매니저
        private WaveUpgradeManager _waveUpgrades;
        public WaveUpgradeManager WaveUpgrades => _waveUpgrades ??= new WaveUpgradeManager();

        // 튜토리얼 플래그
        public bool IsTutorialMode { get; set; }

        /// <summary>
        /// 나선 시작: SpiralStart 상태로 전환하여 축복 선택 UI 표시.
        /// UI에서 축복 선택 후 BeginSpiralWithBlessing() 호출해야 실제 시작.
        /// </summary>
        public void BeginSpiral()
        {
            SetState(GameState.SpiralStart);
            // UI가 ShowBlessingSelectionUI()를 표시하고
            // 선택 후 BeginSpiralWithBlessing() 호출
        }

        /// <summary>
        /// 축복 선택 후 나선 시작 (UI에서 호출)
        /// </summary>
        public void BeginSpiralWithBlessing(SpiralBlessing blessing)
        {
            if (blessing != null)
            {
                _spiral.SelectBlessing(blessing);
                ApplyBlessingToRound();

                // 공허: 부적 슬롯 감소
                if (blessing.TalismanSlotPenalty > 0)
                    _player.PermanentTalismanSlotBonus = System.Math.Max(0,
                        _player.PermanentTalismanSlotBonus - blessing.TalismanSlotPenalty);

                // 공허: 부적 효과 배율
                if (blessing.TalismanEffectMult > 0)
                    _player.WaveTalismanEffectBonus += (blessing.TalismanEffectMult - 1f);
            }
            StartNextRealm();
        }

        private void ApplyBlessingToRound()
        {
            var b = _spiral.ActiveBlessing;
            if (b == null) return;

            // 축복 효과는 RoundManager 생성 시 적용
            OnMessage?.Invoke($"축복 선택: {b.NameKR} — {b.BonusDesc} / {b.PenaltyDesc}");
        }

        /// <summary>
        /// 다음 영역 시작: 보스 생성 + 라운드 시작
        /// </summary>
        public void StartNextRealm()
        {
            // 재앙 보스 체크 (나선 3/5/8/10 마지막 영역)
            var calamityBoss = BossDatabase.GetCalamityBoss(_spiral.CurrentSpiral);
            bool isCalamityRealm = calamityBoss != null && _spiral.CurrentRealm == 10;

            // 보스 생성 — 항상 무작위 (재앙 보스 제외)
            if (isCalamityRealm)
            {
                // 재앙 보스 (나선 3/5/8/10)
                CurrentBoss = new GeneratedBoss
                {
                    BaseBoss = calamityBoss,
                    Parts = new System.Collections.Generic.List<BossPartData>(),
                    FinalTargetScore = _spiral.GetTargetScore(calamityBoss.TargetScore),
                    DisplayName = calamityBoss.NameKR,
                    Spiral = _spiral.CurrentSpiral,
                    AbsoluteRealm = _spiral.AbsoluteRealm
                };
            }
            else
            {
                // 모든 영역에서 랜덤 보스 생성 (파츠 조합으로 매번 다른 보스)
                CurrentBoss = _bossGenerator.GenerateRandomBoss(_spiral);
            }

            _bossManager.SetBoss(CurrentBoss.BaseBoss);
            TotalRoundsInRealm = CurrentBoss.BaseBoss.Rounds;
            CurrentRoundInRealm = 0;

            // HP 기반 전투 생성
            CurrentBattle = new BossBattle(CurrentBoss.BaseBoss, _spiral.CurrentSpiral);
            CurrentBattle.OnBossDamaged += dmg =>
                OnMessage?.Invoke($"{CurrentBoss.DisplayName}에게 {dmg} 타격!");
            CurrentBattle.OnBossDefeated += () =>
                OnMessage?.Invoke($"{CurrentBoss.DisplayName} 격파!");
            CurrentBattle.OnBossCounterAttack += msg =>
                OnMessage?.Invoke(msg);

            OnBossGenerated?.Invoke(CurrentBoss);
            OnMessage?.Invoke($"{CurrentBoss.DisplayName}이(가) 판을 깔았다! (HP: {CurrentBattle.GetHPDisplay()})");
            OnMessage?.Invoke(CurrentBoss.BaseBoss.IntroDialogue);

            StartNextRound();
        }

        /// <summary>
        /// 다음 라운드 시작
        /// </summary>
        public void StartNextRound()
        {
            CurrentRoundInRealm++;

            _roundManager = new RoundManager(_player, _deckManager, _talismanManager,
                _bossManager, _cardEnhancements, _upgrades);
            _roundManager.OnRoundEnded += HandleRoundEnded;
            _roundManager.OnScoreCalculated += score =>
                OnMessage?.Invoke(score.ToString());
            _roundManager.OnMessage += msg => OnMessage?.Invoke(msg);

            // 축복 효과 전달
            var blessing = _spiral.ActiveBlessing;
            if (blessing != null)
            {
                if (blessing.HandPenalty > 0)
                    _roundManager.BlessingHandPenalty = blessing.HandPenalty;
                if (blessing.ChipBonus > 0)
                    _roundManager.BlessingChipBonus = blessing.ChipBonus;
                if (blessing.MultBonus > 0)
                    _roundManager.BlessingMultBonus = blessing.MultBonus;
            }

            int targetScore = (int)(CurrentBoss.FinalTargetScore * _goTargetMultiplier);

            // 영구 강화: 목표 감소
            float targetReduction = _upgrades.GetTargetReduction();
            if (targetReduction > 0)
                targetScore = (int)(targetScore * (1f - targetReduction));

            // 웨이브 강화: 목표 감소
            if (_player.WaveTargetReduction > 0)
                targetScore = (int)(targetScore * (1f - _player.WaveTargetReduction));

            _roundManager.StartRound(targetScore);

            // Go 패널티 적용
            if (_goHandPenalty > 0)
            {
                for (int i = 0; i < _goHandPenalty && _player.Hand.Count > 0; i++)
                    _player.Hand.RemoveAt(_player.Hand.Count - 1);
                _goHandPenalty = 0;
            }

            // 동료 도깨비 쿨다운
            _companions.TickAllCooldowns();

            SetState(GameState.InRound);
        }

        public void ApplyGoRisk(GoStopDecision.GoRisk risk)
        {
            _goTargetMultiplier *= risk.NextTargetMult;
            _goHandPenalty += risk.HandPenalty;
        }

        /// <summary>
        /// 이승의 문: 엔딩 감상 → 다음 나선으로 계속
        /// </summary>
        public void EnterGate()
        {
            OnMessage?.Invoke("이승의 문을 통과합니다...");
            // 엔딩 시퀀스는 UI에서 처리
            // 이후 ContinueAfterGate() 호출로 게임 계속
        }

        /// <summary>
        /// 이승의 문 거부 or 엔딩 후 계속 → 다음 나선
        /// </summary>
        public void ContinueAfterGate()
        {
            int spiralBonus = SoulFragmentCalculator.ForSpiralComplete(_spiral.CurrentSpiral);
            _runSoulFragments += spiralBonus;
            _upgrades.AddSoulFragments(spiralBonus);

            _spiral.ContinueToNextSpiral();
            OnMessage?.Invoke($"나선 {_spiral.CurrentSpiral} 진입! 더 깊은 저승으로...");

            SetState(GameState.SpiralStart);
        }

        public bool BuyTalisman(TalismanData data, int cost)
        {
            float discount = _upgrades.GetShopDiscount();
            int finalCost = (int)(cost * (1f - discount));

            if (_player.Yeop < finalCost) return false;
            if (!_player.CanEquipTalisman()) return false;

            _player.Yeop -= finalCost;
            _player.EquipTalisman(new TalismanInstance(data));
            return true;
        }

        /// <summary>
        /// 상점 열기: 재고 생성
        /// </summary>
        public void OpenShop()
        {
            _shop.GenerateStock(_spiral.CurrentSpiral, _upgrades.GetShopDiscount());
            SetState(GameState.Shop);
        }

        /// <summary>
        /// 상점 아이템 구매
        /// </summary>
        public bool ShopPurchase(int itemIndex)
        {
            return _shop.Purchase(_player, itemIndex);
        }

        /// <summary>
        /// 상점 → 이벤트 또는 다음 영역
        /// </summary>
        public void LeaveShop()
        {
            // 짝수 영역 후에만 이벤트 (1, 3, 5, 7, 9영역 클리어 후)
            if (_spiral.CurrentRealm % 2 == 0)
            {
                _events.GenerateEvent(_spiral.CurrentSpiral);
                SetState(GameState.Event);
            }
            else
            {
                StartNextRealm();
            }
        }

        /// <summary>
        /// 이벤트 선택지 실행 → 다음 영역
        /// </summary>
        public string ExecuteEventChoice(int choiceIndex)
        {
            string result = _events.ExecuteChoice(_player, choiceIndex);
            OnMessage?.Invoke(result);
            return result;
        }

        /// <summary>
        /// 이벤트 후 다음 영역으로
        /// </summary>
        public void LeaveEvent()
        {
            StartNextRealm();
        }

        private void HandleRoundEnded(bool won)
        {
            SetState(GameState.PostRound);

            if (won && CurrentBattle != null)
            {
                // 섯다 공격은 SeotdaAttack()에서 이미 처리됨
                // 여기서는 보스 반격 + 격파 체크만

                // 보스 반격 (아직 살아있으면)
                if (!CurrentBattle.IsBossDefeated)
                {
                    string counter = CurrentBattle.BossCounterAttack(_player);
                }

                _goTargetMultiplier = 1f;
                _greedScale.Reset();

                if (CurrentBattle.IsBossDefeated)
                {
                    // 보스 격파!
                    int soulReward = SoulFragmentCalculator.ForBossDefeat(
                        _spiral.AbsoluteRealm,
                        CurrentBoss.Parts.Count,
                        CurrentBoss.HasSetBonus());
                    _runSoulFragments += soulReward;
                    _upgrades.AddSoulFragments(soulReward);

                    _player.Yeop += CurrentBoss.BaseBoss.YeopReward;
                    OnMessage?.Invoke(CurrentBoss.BaseBoss.DefeatDialogue);
                    OnMessage?.Invoke($"+{soulReward} 넋");

                    // 업적 체크
                    _achievements.CheckProgress(
                        _spiral.CurrentSpiral,
                        _spiral.TotalRealmsCleared + 1,
                        0);

                    // 동료 도깨비 해금 체크
                    if (CurrentBoss.BaseBoss.Id != null)
                        _companions.UnlockCompanion(CurrentBoss.BaseBoss.Id);

                    // 나선 끝? → 이승의 문
                    bool gateAppeared = _spiral.AdvanceRealm();
                    if (gateAppeared)
                    {
                        OnGateAppeared?.Invoke();
                        SetState(GameState.Gate);
                    }
                    else
                    {
                        // 웨이브 강화 선택지 생성 → PostRound 상태 유지
                        // UI가 wave upgrade 표시 → 선택 → FinishWaveUpgrade() → 상점
                        WaveUpgrades.GenerateChoices(_spiral.AbsoluteRealm);
                        OnWaveUpgradeReady?.Invoke();
                        // OpenShop은 FinishWaveUpgrade()에서 호출
                    }
                }
                // 같은 영역 내 다음 라운드는 UI에서 StartNextRound() 호출
            }
            else
            {
                // 패배
                if (_player.GoCount >= 3)
                {
                    bool insured = false;
                    float insuranceChance = _upgrades.GetGoInsuranceChance();
                    if (insuranceChance > 0 && new Random().NextDouble() < insuranceChance)
                    {
                        insured = true;
                        OnMessage?.Invoke("Go 보험 발동! 즉사를 면했다!");
                    }

                    if (!insured)
                    {
                        if (_upgrades.HasRevive())
                        {
                            OnMessage?.Invoke("부활! 한 번 더 기회를...");
                            _player.Lives = 1;
                        }
                        else
                        {
                            _player.Lives = 0;
                            OnMessage?.Invoke("욕심이 너를 삼켰다...");
                            _achievements.CheckGo(3, false);
                        }
                    }
                }
                else
                {
                    _player.Lives--;
                    OnMessage?.Invoke(CurrentBoss.BaseBoss.VictoryDialogue);
                }

                if (_player.Lives <= 0)
                {
                    // 사망 → 넋 70% 유지 (이미 AddSoulFragments로 추가됨)
                    SetState(GameState.GameOver);
                    OnMessage?.Invoke("저승의 어둠이 너를 집어삼킨다...");
                }
                else
                {
                    CurrentRoundInRealm--;
                }
            }
        }

        /// <summary>
        /// 섯다 공격: 모은 패 중 2장을 골라 보스에게 타격
        /// </summary>
        /// <summary>
        /// 섯다 공격: 모은 패 중 2장을 골라 보스에게 타격
        /// 공격 후 라운드 종료 → HandleRoundEnded
        /// </summary>
        public AttackResult SeotdaAttack(CardInstance card1, CardInstance card2)
        {
            // 시너지 판정 (공격 전)
            _battleSystem.EvaluateSynergies(_player);

            // 섯다 공격 실행
            var result = _battleSystem.ExecuteSeotdaAttack(_player, card1, card2);

            // 고 배수 적용
            if (_player.GoCount > 0)
            {
                int goMult = _player.GoCount switch { 1 => 2, 2 => 4, _ => 10 };
                result.FinalDamage *= goMult;
            }

            // 보스 HP 차감
            if (CurrentBattle != null)
            {
                CurrentBattle.DealDamage(new ScoringEngine.ScoreResult { FinalScore = result.FinalDamage });
                OnMessage?.Invoke($"[{result.SeotdaName}] {result.FinalDamage} 타격!");

                if (result.SynergyMult > 1f)
                    OnMessage?.Invoke($"  시너지: ×{result.SynergyMult:F1} ({string.Join("+", result.SynergiesAfter)})");
            }

            // 공격 완료 → 라운드 종료
            bool won = result.FinalDamage > 0;
            _roundManager?.FinishRound(won);

            return result;
        }

        /// <summary>
        /// 웨이브 강화 선택 적용 후 상점으로
        /// </summary>
        public void ApplyWaveUpgrade(int choiceIndex)
        {
            WaveUpgrades.ApplyChoice(_player, this, choiceIndex);
            OpenShop();
        }

        /// <summary>
        /// 웨이브 강화 스킵 → 바로 상점
        /// </summary>
        public void SkipWaveUpgrade()
        {
            WaveUpgrades.CurrentChoices.Clear();
            OpenShop();
        }

        /// <summary>
        /// 카드 강화 (대장간)
        /// </summary>
        public bool UpgradeCard(int cardId, int cost)
        {
            if (_player.Yeop < cost) return false;
            var enh = _cardEnhancements.GetEnhancement(cardId);
            if (!enh.Upgrade()) return false;
            _player.Yeop -= cost;
            OnMessage?.Invoke($"카드 강화! → {enh.Tier}");
            return true;
        }

        /// <summary>
        /// 세이브 데이터로부터 게임 복원
        /// </summary>
        public void LoadFromSave(SaveData data)
        {
            if (data == null) return;

            // 나선 상태
            _spiral.LoadFromSave(data.Spiral);

            // 플레이어 상태
            _player.Lives = data.Lives;
            _player.Yeop = data.Yeop;
            _player.GoCount = data.GoCount;

            // 런 내 웨이브 버프
            _player.WaveChipBonus = data.WaveChipBonus;
            _player.WaveMultBonus = data.WaveMultBonus;
            _player.WaveTalismanSlotBonus = data.WaveTalismanSlotBonus;
            _player.WaveTalismanEffectBonus = data.WaveTalismanEffectBonus;
            _player.WaveTargetReduction = data.WaveTargetReduction;
            _player.NextRoundHandBonus = data.NextRoundHandBonus;

            // 부적
            _player.Talismans.Clear();
            foreach (var tName in data.EquippedTalismans)
            {
                var tData = Talismans.TalismanDatabase.GetByName(tName);
                if (tData != null)
                    _player.EquipTalisman(new Talismans.TalismanInstance(tData));
            }

            // 동료
            if (data.UnlockedCompanions != null)
                _companions.LoadUnlocked(data.UnlockedCompanions);
            foreach (var cId in data.EquippedCompanions)
                _companions.Equip(cId);

            // 넋 + 업그레이드 (비용 없이 직접 설정)
            _upgrades.SetSoulFragments(data.SoulFragments);
            foreach (var entry in data.UpgradeLevels)
                _upgrades.SetLevel(entry.Id, entry.Level);

            // 업적
            _achievements.LoadUnlocked(data.UnlockedAchievements);

            _goTargetMultiplier = 1f;
            _goHandPenalty = 0;
            _runSoulFragments = 0;

            OnMessage?.Invoke($"세이브 로드 완료: 나선 {_spiral.CurrentSpiral} 영역 {_spiral.CurrentRealm}");
        }

        private void SetState(GameState state)
        {
            CurrentState = state;
            OnGameStateChanged?.Invoke(state);
        }
    }
}

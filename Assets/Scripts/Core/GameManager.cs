using System;
using System.Collections.Generic;
using DokkaebiHand.Cards;
using DokkaebiHand.Combat;
using DokkaebiHand.Talismans;

namespace DokkaebiHand.Core
{
    /// <summary>
    /// 게임 루프 총괄: 라운드 연결, 층 진행, 승패 처리
    /// Balatro 스타일 전투: 시너지 페이즈 → 고/스톱 → 섯다 공격
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
        private readonly Random _rng = new Random();
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

            // 보스 기믹 즉사 이벤트 연결 (BUG-01)
            _bossManager.OnPlayerKilled += HandlePlayerKilled;

            CurrentState = GameState.MainMenu;
        }

        private void HandlePlayerKilled()
        {
            if (_player.Lives <= 0)
            {
                SetState(GameState.GameOver);
                OnMessage?.Invoke("저승의 어둠이 너를 집어삼킨다...");
            }
        }

        /// <summary>
        /// 새 게임 시작 (영구 강화 반영)
        /// </summary>
        public void StartNewGame()
        {
            // 사주팔자 생성
            _destiny.GenerateDestiny();

            _player.Lives = 5 + _upgrades.GetExtraLives();
            _player.Yeop = 50 + _upgrades.GetBonusStartYeop() + _destiny.GetStartYeopBonus();
            _player.CurrentFloor = 1;
            _runSoulFragments = 0;

            // 영구 강화 반영
            _player.PermanentTalismanSlotBonus = _upgrades.GetExtraTalismanSlots()
                - _destiny.GetTalismanSlotPenalty();

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
        /// </summary>
        public void BeginSpiral()
        {
            SetState(GameState.SpiralStart);
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

                if (blessing.TalismanSlotPenalty > 0)
                    _player.PermanentTalismanSlotBonus = Math.Max(0,
                        _player.PermanentTalismanSlotBonus - blessing.TalismanSlotPenalty);

                if (blessing.TalismanEffectMult > 0)
                    _player.WaveTalismanEffectBonus += (blessing.TalismanEffectMult - 1f);
            }
            StartNextRealm();
        }

        private void ApplyBlessingToRound()
        {
            var b = _spiral.ActiveBlessing;
            if (b == null) return;
            OnMessage?.Invoke($"축복 선택: {b.NameKR} — {b.BonusDesc} / {b.PenaltyDesc}");
        }

        /// <summary>
        /// 다음 영역 시작: 보스 생성 + 라운드 시작
        /// </summary>
        public void StartNextRealm()
        {
            var calamityBoss = BossDatabase.GetCalamityBoss(_spiral.CurrentSpiral);
            bool isCalamityRealm = calamityBoss != null && _spiral.CurrentRealm == 10;

            if (isCalamityRealm)
            {
                CurrentBoss = new GeneratedBoss
                {
                    BaseBoss = calamityBoss,
                    Parts = new List<BossPartData>(),
                    FinalTargetScore = _spiral.GetTargetScore(calamityBoss.TargetScore),
                    DisplayName = calamityBoss.NameKR,
                    Spiral = _spiral.CurrentSpiral,
                    AbsoluteRealm = _spiral.AbsoluteRealm
                };
            }
            else
            {
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
            CurrentBattle.OnPlayerKilled += HandlePlayerKilled;

            OnBossGenerated?.Invoke(CurrentBoss);
            OnMessage?.Invoke($"{CurrentBoss.DisplayName}이(가) 판을 깔았다! (HP: {CurrentBattle.GetHPDisplay()})");
            OnMessage?.Invoke(CurrentBoss.BaseBoss.IntroDialogue);

            StartNextRound();
        }

        /// <summary>
        /// 다음 라운드 시작 (Balatro 스타일)
        /// </summary>
        public void StartNextRound()
        {
            CurrentRoundInRealm++;

            // 라운드 수 초과 시 보스 미격파 → 패배 처리
            if (CurrentRoundInRealm > TotalRoundsInRealm && CurrentBattle != null && !CurrentBattle.IsBossDefeated)
            {
                _player.Lives--;
                OnMessage?.Invoke("판이 다 끝났다! 도깨비에게 밀렸다...");
                if (_player.Lives <= 0)
                {
                    SetState(GameState.GameOver);
                    OnMessage?.Invoke("저승의 어둠이 너를 집어삼킨다...");
                }
                else
                {
                    CurrentRoundInRealm--;
                    SetState(GameState.PostRound);
                }
                return;
            }

            _roundManager = new RoundManager(_player, _deckManager, _talismanManager,
                _bossManager, _cardEnhancements, _upgrades);
            _roundManager.OnRoundEnded += HandleRoundEnded;
            _roundManager.OnCombosEvaluated += combos =>
            {
                var names = new List<string>();
                foreach (var c in combos) names.Add(c.NameKR);
                if (names.Count > 0)
                    OnMessage?.Invoke($"콤보: {string.Join(", ", names)}");
            };
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

            _roundManager.StartRound();

            // 보스 반격 패널티 적용 (이전 판에서 발생한 패널티)
            if (CurrentBattle != null)
            {
                if (CurrentBattle.CounterHandPenalty > 0)
                {
                    int penalty = CurrentBattle.CounterHandPenalty;
                    for (int i = 0; i < penalty && _roundManager.HandCards.Count > 2; i++)
                    {
                        _roundManager.HandCards.RemoveAt(_roundManager.HandCards.Count - 1);
                    }
                    OnMessage?.Invoke($"보스 반격 여파! 손패 -{penalty}장!");
                }
                if (CurrentBattle.CounterChipPenalty > 0)
                {
                    _roundManager.BlessingChipBonus -= CurrentBattle.CounterChipPenalty * 0.01f;
                    OnMessage?.Invoke($"보스 반격 여파! 칩 -{CurrentBattle.CounterChipPenalty}%!");
                }
            }

            // 동료 도깨비 쿨다운
            _companions.TickAllCooldowns();

            SetState(GameState.InRound);
        }

        /// <summary>
        /// 섯다 공격: 남은 손패 중 2장을 골라 보스에게 타격
        /// 시너지 페이즈에서 쌓은 칩/배수가 적용됨
        /// </summary>
        public SeotdaAttackResult SeotdaAttack(CardInstance card1, CardInstance card2)
        {
            if (_roundManager == null)
                return new SeotdaAttackResult { FinalDamage = 0 };

            // 섯다 공격 실행 (RoundManager가 누적 시너지 적용)
            var result = _roundManager.ExecuteAttack(card1, card2);

            // 잘못된 공격 (페이즈 오류, 카드 누락 등) → 패배 처리하여 교착 방지
            if (result.FinalDamage <= 0)
            {
                _roundManager.FinishRound(false);
                return result;
            }

            // 보스 HP 차감
            if (CurrentBattle != null)
            {
                CurrentBattle.DealDamage(new ScoringEngine.ScoreResult
                {
                    FinalScore = result.FinalDamage
                });
            }

            // 공격 완료 → 라운드 종료 (공격 성공 = won)
            _roundManager.FinishRound(true);

            return result;
        }

        /// <summary>
        /// 고 선택 시 보스 반격 데미지 적용
        /// UI에서 RoundManager.SelectGo() 호출 후 이 메서드 호출
        /// </summary>
        public void ApplyGoDamage(int bossDamage)
        {
            if (bossDamage <= 0) return;

            // 보스 반격으로 플레이어 피해 (엽전 감소 등)
            int yeopLoss = bossDamage;
            _player.Yeop = Math.Max(0, _player.Yeop - yeopLoss);
            OnMessage?.Invoke($"보스 반격! 엽전 -{yeopLoss}냥");

            // Go 3 즉사 판정
            if (_roundManager.GoCount >= 3)
            {
                float deathChance = 0.1f; // 10% (초보 친화적)
                float insuranceChance = _upgrades.GetGoInsuranceChance();

                if (_rng.NextDouble() < deathChance)
                {
                    // 즉사 판정 발동 → 보험 체크
                    if (insuranceChance > 0 && _rng.NextDouble() < insuranceChance)
                    {
                        OnMessage?.Invoke("Go 보험 발동! 즉사를 면했다!");
                    }
                    else
                    {
                        _player.Lives--;
                        OnMessage?.Invoke("즉사! 도깨비의 일격!");
                        if (_player.Lives <= 0)
                        {
                            SetState(GameState.GameOver);
                            OnMessage?.Invoke("저승의 어둠이 너를 집어삼킨다...");
                        }
                    }
                }
                else if (insuranceChance > 0)
                {
                    // 즉사 미발동이어도 보험 보유 알림 (UX)
                    OnMessage?.Invoke("위험했지만... 무사히 넘겼다!");
                }
            }
        }

        /// <summary>
        /// 이승의 문: 엔딩 감상 → 다음 나선으로 계속
        /// </summary>
        public void EnterGate()
        {
            OnMessage?.Invoke("이승의 문을 통과합니다...");
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

            // 이벤트 효과로 체력 0 이하 → 게임오버
            if (_player.Lives <= 0)
            {
                SetState(GameState.GameOver);
                OnMessage?.Invoke("저승의 어둠이 너를 집어삼킨다...");
            }

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
            if (won && CurrentBattle != null)
            {
                // 보스 반격 (아직 살아있으면)
                if (!CurrentBattle.IsBossDefeated)
                {
                    string counter = CurrentBattle.BossCounterAttack(_player);
                }

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
                        return;
                    }
                    else
                    {
                        // 웨이브 강화 선택지 생성
                        WaveUpgrades.GenerateChoices(_spiral.AbsoluteRealm);
                        OnWaveUpgradeReady?.Invoke();
                    }
                }

                // 보스 살아있거나 격파 후 웨이브 강화 → PostRound
                SetState(GameState.PostRound);
            }
            else
            {
                // 패배
                if (_roundManager != null && _roundManager.GoCount >= 3)
                {
                    bool insured = false;
                    float insuranceChance = _upgrades.GetGoInsuranceChance();
                    if (insuranceChance > 0 && _rng.NextDouble() < insuranceChance)
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
                    OnMessage?.Invoke(CurrentBoss?.BaseBoss?.VictoryDialogue ?? "도깨비가 승리했다...");
                }

                if (_player.Lives <= 0)
                {
                    SetState(GameState.GameOver);
                    OnMessage?.Invoke("저승의 어둠이 너를 집어삼킨다...");
                }
                else
                {
                    CurrentRoundInRealm--;
                    SetState(GameState.PostRound);
                }
            }
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

            _spiral.LoadFromSave(data.Spiral);

            _player.Lives = data.Lives;
            _player.Yeop = data.Yeop;
            _player.GoCount = data.GoCount;

            _player.WaveChipBonus = data.WaveChipBonus;
            _player.WaveMultBonus = data.WaveMultBonus;
            _player.WaveTalismanSlotBonus = data.WaveTalismanSlotBonus;
            _player.WaveTalismanEffectBonus = data.WaveTalismanEffectBonus;
            _player.WaveTargetReduction = data.WaveTargetReduction;
            _player.NextRoundHandBonus = data.NextRoundHandBonus;

            _player.Talismans.Clear();
            foreach (var tName in data.EquippedTalismans)
            {
                var tData = Talismans.TalismanDatabase.GetByName(tName);
                if (tData != null)
                    _player.EquipTalisman(new Talismans.TalismanInstance(tData));
            }

            if (data.UnlockedCompanions != null)
                _companions.LoadUnlocked(data.UnlockedCompanions);
            foreach (var cId in data.EquippedCompanions)
                _companions.Equip(cId);

            _upgrades.SetSoulFragments(data.SoulFragments);
            foreach (var entry in data.UpgradeLevels)
                _upgrades.SetLevel(entry.Id, entry.Level);

            _achievements.LoadUnlocked(data.UnlockedAchievements);

            _runSoulFragments = 0;

            // 보스 전투 상태 복원
            if (!string.IsNullOrEmpty(data.CurrentBossId) && data.BossMaxHP > 0)
            {
                var bossDef = BossDatabase.GetById(data.CurrentBossId);
                if (bossDef != null)
                {
                    CurrentBoss = _bossGenerator.GenerateRandomBoss(_spiral);
                    CurrentBoss.BaseBoss = bossDef;

                    CurrentBattle = new BossBattle(bossDef, _spiral.CurrentSpiral);
                    // HP 복원: MaxHP에서 이미 받은 데미지를 차감
                    int damageTaken = data.BossMaxHP - data.BossCurrentHP;
                    if (damageTaken > 0)
                        CurrentBattle.DealDamage(new ScoringEngine.ScoreResult { FinalScore = damageTaken });

                    CurrentBattle.OnBossDamaged += dmg =>
                        OnMessage?.Invoke($"{CurrentBoss.DisplayName}에게 {dmg} 타격!");
                    CurrentBattle.OnBossDefeated += () =>
                        OnMessage?.Invoke($"{CurrentBoss.DisplayName} 격파!");
                    CurrentBattle.OnBossCounterAttack += msg =>
                        OnMessage?.Invoke(msg);
                    CurrentBattle.OnPlayerKilled += HandlePlayerKilled;

                    _bossManager.SetBoss(bossDef);
                    TotalRoundsInRealm = bossDef.Rounds;
                    CurrentRoundInRealm = data.CurrentRoundInRealm;
                }
            }

            OnMessage?.Invoke($"세이브 로드 완료: 나선 {_spiral.CurrentSpiral} 영역 {_spiral.CurrentRealm}");
        }

        private void SetState(GameState state)
        {
            CurrentState = state;
            OnGameStateChanged?.Invoke(state);
        }
    }
}

using UnityEngine;
using UnityEngine.UI;
using TMPro;
using DokkaebiHand.Core;
using DokkaebiHand.Cards;
using DokkaebiHand.Combat;

namespace DokkaebiHand.UI
{
    /// <summary>
    /// 목업 씬 빌더: 런타임에 전체 UI를 프로그래매틱으로 생성.
    /// Unity 에디터에서 빈 씬에 이 컴포넌트만 붙이면 전체 프로토타입 동작.
    /// </summary>
    public class MockupSceneBuilder : MonoBehaviour
    {
        private GameManager _game;
        private Canvas _canvas;
        private MockupGameView _gameView;
        private GameEffects _effects;

        private void Awake()
        {
            // 카메라
            var cam = Camera.main;
            if (cam == null)
            {
                var camObj = new GameObject("Main Camera");
                cam = camObj.AddComponent<Camera>();
                cam.tag = "MainCamera";
            }
            cam.backgroundColor = new Color(0.06f, 0.06f, 0.12f);
            cam.orthographic = true;

            // Canvas
            var canvasObj = new GameObject("Canvas");
            _canvas = canvasObj.AddComponent<Canvas>();
            _canvas.renderMode = RenderMode.ScreenSpaceOverlay;
            _canvas.sortingOrder = 0;

            var scaler = canvasObj.AddComponent<CanvasScaler>();
            scaler.uiScaleMode = CanvasScaler.ScaleMode.ScaleWithScreenSize;
            scaler.referenceResolution = new Vector2(1920, 1080);
            scaler.matchWidthOrHeight = 0.5f;

            canvasObj.AddComponent<GraphicRaycaster>();

            // EventSystem
            if (FindObjectOfType<UnityEngine.EventSystems.EventSystem>() == null)
            {
                var esObj = new GameObject("EventSystem");
                esObj.AddComponent<UnityEngine.EventSystems.EventSystem>();
                esObj.AddComponent<UnityEngine.EventSystems.StandaloneInputModule>();
            }

            // 게임 매니저
            _game = new GameManager();

            // 이펙트 시스템
            _effects = gameObject.AddComponent<GameEffects>();
            _effects.Initialize(_canvas);

            // 게임 뷰 생성
            _gameView = new MockupGameView(_canvas.transform, _game, _effects);
            _gameView.BuildMainMenu();
        }

        private void Update()
        {
            if (_gameView != null)
                _gameView.HandleInput();
        }
    }

    /// <summary>
    /// 목업 게임 뷰: 모든 화면을 코드로 구성
    /// </summary>
    public class MockupGameView
    {
        private readonly Transform _root;
        private readonly GameManager _game;

        // UI 참조
        private GameObject _mainMenuPanel;
        private GameObject _gamePanel;
        private GameObject _goStopPanel;
        private GameObject _resultPanel;
        private GameObject _gatePanel;

        // 신규 시스템
        private TutorialManager _tutorial;
        private GameObject _tutorialOverlay;
        private GameObject _companionPanel;
        private GameEffects _effects;
        private TextMeshProUGUI _greedText;
        private TextMeshProUGUI _destinyText;

        // 게임 플레이 UI
        private Transform _handArea;
        private Transform _fieldArea;
        private TextMeshProUGUI _scoreText;
        private TextMeshProUGUI _multText;
        private TextMeshProUGUI _targetText;
        private TextMeshProUGUI _yokboText;
        private TextMeshProUGUI _bossText;
        private TextMeshProUGUI _infoText;
        private TextMeshProUGUI _messageText;
        private TextMeshProUGUI _spiralText;

        public MockupGameView(Transform root, GameManager game, GameEffects effects = null)
        {
            _root = root;
            _game = game;
            _effects = effects;

            _game.OnGameStateChanged += HandleStateChange;
            _game.OnMessage += ShowMessage;

            // 업적 토스트
            _game.Achievements.OnAchievementUnlocked += def =>
            {
                ShowMessage($"{L.Get("achievement_unlocked")} {def.NameKR} (+{def.SoulReward} {L.Get("soul_fragment")})");
            };

            // 웨이브 강화 표시
            _game.OnWaveUpgradeReady += () =>
            {
                if (_game.WaveUpgrades.CurrentChoices.Count > 0)
                    ShowWaveUpgradeUI();
            };

            // 보스 등장 이펙트
            _game.OnBossGenerated += boss =>
            {
                if (_effects != null)
                    _effects.PlayBossEntrance(boss.DisplayName, new Vector2(0, 400));
            };

            // 보스 기믹 이펙트
            if (_game.BossManager != null)
            {
                _game.BossManager.OnBossGimmickTriggered += msg =>
                {
                    if (_effects != null)
                        _effects.PlayBossGimmickEffect(new Vector2(0, 300));
                    ShowMessage(msg);
                };
            }

            // 욕망의 저울: 3 Go 연출 트리거
            _game.GreedScale.OnGoMoment += () =>
            {
                ShowMessage("!! 욕심이 너를 삼키려 한다 !!");
            };
        }

        #region 메인 메뉴

        public void BuildMainMenu()
        {
            ClearAll();
            _mainMenuPanel = CreatePanel("MainMenu", _root, Color.clear);

            // 타이틀
            CreateText(_mainMenuPanel.transform, L.Get("title"), 48,
                new Vector2(0, 200), new Color(1f, 0.84f, 0f));
            CreateText(_mainMenuPanel.transform, "Dokkaebi's Hand", 24,
                new Vector2(0, 140), new Color(0.7f, 0.7f, 0.7f));
            CreateText(_mainMenuPanel.transform, L.Get("subtitle"), 18,
                new Vector2(0, 100), new Color(0.5f, 0.5f, 0.6f));

            // 새 게임 버튼
            CreateButton(_mainMenuPanel.transform, L.Get("new_game"), new Vector2(0, 20), () =>
            {
                _game.StartNewGame();
                // 튜토리얼 체크
                if (!PlayerPrefs.HasKey("tutorial_done"))
                {
                    _tutorial = new TutorialManager();
                    _tutorial.Start();
                    _game.IsTutorialMode = true;
                }
                // SpiralStart 상태에서 축복 선택 UI 표시
            });

            // 이어하기 버튼 (세이브 있을 때만 활성)
            bool hasSave = GameBootstrap.LoadedSave != null;
            var continueBtn = CreateButton(_mainMenuPanel.transform,
                hasSave ? L.Get("continue") : L.Get("no_save"),
                new Vector2(0, -40), () =>
            {
                if (GameBootstrap.LoadedSave != null)
                {
                    _game.LoadFromSave(GameBootstrap.LoadedSave);
                    _game.StartNextRealm();
                }
            }, hasSave ? new Color(0.15f, 0.5f, 0.15f) : new Color(0.3f, 0.3f, 0.3f));
            if (!hasSave) continueBtn.interactable = false;

            // 영구 강화 버튼
            CreateButton(_mainMenuPanel.transform, L.Get("permanent_upgrade"), new Vector2(0, -100), () =>
            {
                ShowUpgradeTreeUI();
            }, new Color(0.4f, 0.2f, 0.6f));

            // 도감 버튼
            CreateButton(_mainMenuPanel.transform, L.Get("collection"), new Vector2(0, -160), () =>
            {
                ShowCollectionUI();
            }, new Color(0.2f, 0.4f, 0.5f));

            // 언어 선택 버튼
            CreateButton(_mainMenuPanel.transform, L.Get("language") + ": 한/EN/日/中", new Vector2(0, -220), () =>
            {
                var mgr = LocalizationManager.Instance;
                int next = ((int)mgr.CurrentLanguage + 1) % 4;
                mgr.SetLanguage((Language)next);
                BuildMainMenu();
            }, new Color(0.25f, 0.25f, 0.35f));

            CreateButton(_mainMenuPanel.transform, L.Get("quit"), new Vector2(0, -280), () =>
            {
#if UNITY_EDITOR
                UnityEditor.EditorApplication.isPlaying = false;
#else
                Application.Quit();
#endif
            });

            // 조작법
            CreateText(_mainMenuPanel.transform, L.Get("input_hint"), 14,
                new Vector2(0, -370), new Color(0.4f, 0.4f, 0.5f));
        }

        #endregion

        #region 게임 플레이 화면

        public void BuildGameScreen()
        {
            ClearAll();
            _gamePanel = CreatePanel("Game", _root, new Color(0.06f, 0.06f, 0.12f, 0.95f));

            var rt = _gamePanel.GetComponent<RectTransform>();
            rt.anchorMin = Vector2.zero;
            rt.anchorMax = Vector2.one;
            rt.offsetMin = Vector2.zero;
            rt.offsetMax = Vector2.zero;

            // 상단 바: 나선/영역 정보
            _spiralText = CreateText(_gamePanel.transform, "", 16,
                new Vector2(-400, 490), new Color(0.6f, 0.6f, 0.8f));

            _infoText = CreateText(_gamePanel.transform, "", 16,
                new Vector2(400, 490), Color.white);

            // 보스 영역
            _bossText = CreateText(_gamePanel.transform, "", 22,
                new Vector2(0, 400), new Color(1f, 0.3f, 0.3f));

            _targetText = CreateText(_gamePanel.transform, "", 20,
                new Vector2(0, 360), new Color(1f, 0.6f, 0.2f));

            // 바닥패 영역
            var fieldBg = CreatePanel("FieldArea", _gamePanel.transform,
                new Color(0.35f, 0.08f, 0.08f, 0.3f));
            var fieldRt = fieldBg.GetComponent<RectTransform>();
            fieldRt.anchoredPosition = new Vector2(0, 180);
            fieldRt.sizeDelta = new Vector2(900, 150);

            _fieldArea = fieldBg.transform;
            var fieldLayout = fieldBg.AddComponent<HorizontalLayoutGroup>();
            fieldLayout.spacing = 10;
            fieldLayout.childAlignment = TextAnchor.MiddleCenter;
            fieldLayout.childForceExpandWidth = false;
            fieldLayout.childForceExpandHeight = false;

            CreateText(_gamePanel.transform, $"▲ {L.Get("field")} ▲", 14,
                new Vector2(0, 265), new Color(0.5f, 0.5f, 0.5f));

            // 점수 표시
            _scoreText = CreateText(_gamePanel.transform, "칩: 0", 28,
                new Vector2(-150, 40), Color.white);
            _multText = CreateText(_gamePanel.transform, "× 배수: 1", 28,
                new Vector2(150, 40), new Color(0f, 0.8f, 1f));

            // 족보 목록
            _yokboText = CreateText(_gamePanel.transform, "", 16,
                new Vector2(0, -10), new Color(1f, 0.84f, 0f));

            // 손패 영역
            var handBg = CreatePanel("HandArea", _gamePanel.transform,
                new Color(0.1f, 0.1f, 0.2f, 0.3f));
            var handRt = handBg.GetComponent<RectTransform>();
            handRt.anchoredPosition = new Vector2(0, -180);
            handRt.sizeDelta = new Vector2(900, 150);

            _handArea = handBg.transform;
            var handLayout = handBg.AddComponent<HorizontalLayoutGroup>();
            handLayout.spacing = 10;
            handLayout.childAlignment = TextAnchor.MiddleCenter;
            handLayout.childForceExpandWidth = false;
            handLayout.childForceExpandHeight = false;

            CreateText(_gamePanel.transform, $"▼ {L.Get("hand")} ▼", 14,
                new Vector2(0, -95), new Color(0.5f, 0.5f, 0.5f));

            // 메시지
            _messageText = CreateText(_gamePanel.transform, "", 18,
                new Vector2(0, -330), new Color(0.8f, 0.8f, 0.6f));

            // 부적 슬롯 표시
            CreateText(_gamePanel.transform, "", 14,
                new Vector2(-350, -420), new Color(0.5f, 0.8f, 0.5f));

            // 사주팔자 표시
            if (_game.Destiny.CurrentDestiny != null)
            {
                _destinyText = CreateText(_gamePanel.transform,
                    $"[{_game.Destiny.CurrentDestiny.GetNameKR()}]", 13,
                    new Vector2(0, 510), new Color(0.7f, 0.5f, 1f));
            }

            // 욕망의 저울 표시 영역
            _greedText = CreateText(_gamePanel.transform, "", 14,
                new Vector2(350, -420), new Color(1f, 0.4f, 0.2f));

            // Go/Stop 패널 (숨김 상태)
            BuildGoStopPanel();
            _goStopPanel.SetActive(false);

            // 결과 패널 (숨김)
            _resultPanel = CreatePanel("Result", _gamePanel.transform, new Color(0, 0, 0, 0.8f));
            _resultPanel.SetActive(false);

            // 이승의 문 패널 (숨김)
            BuildGatePanel();
            _gatePanel.SetActive(false);

            // 동료 도깨비 아이콘
            ShowCompanionIcons();

            RefreshGameUI();
        }

        private void BuildGoStopPanel()
        {
            _goStopPanel = CreatePanel("GoStop", _gamePanel.transform, new Color(0, 0, 0, 0.85f));
            var rt = _goStopPanel.GetComponent<RectTransform>();
            rt.anchorMin = new Vector2(0.2f, 0.3f);
            rt.anchorMax = new Vector2(0.8f, 0.7f);
            rt.offsetMin = Vector2.zero;
            rt.offsetMax = Vector2.zero;

            CreateText(_goStopPanel.transform, L.Get("go_or_stop"), 32,
                new Vector2(0, 100), Color.white);

            // 현재 점수 표시
            if (_game.RoundManager != null)
            {
                var sc = _game.RoundManager.LastScoreResult;
                CreateText(_goStopPanel.transform,
                    $"{NumberFormatter.FormatScore(sc.FinalScore)} {L.Get("score")}", 22,
                    new Vector2(0, 60), new Color(0.2f, 0.9f, 0.2f));

                // Go 리스크 정보
                var risk = _game.RoundManager.GetCurrentGoRisk();
                string riskInfo = $"{L.Get("mult")} ×{risk.MultiplierBonus}";
                if (risk.InstantDeathOnFail)
                    riskInfo += $"\n{L.Get("greed_kills")}!";
                else if (risk.HandPenalty > 0)
                    riskInfo += $"\n{L.Get("hand")} -{risk.HandPenalty}";

                CreateText(_goStopPanel.transform, riskInfo, 16,
                    new Vector2(-120, 10), new Color(1f, 0.5f, 0.5f));
            }

            // 욕망의 저울 표시
            var greedStatus = _game.GreedScale.GetStatusText();
            if (!string.IsNullOrEmpty(greedStatus))
            {
                CreateText(_goStopPanel.transform, greedStatus, 14,
                    new Vector2(0, -15), new Color(1f, 0.3f, 0.3f, 0.8f));
                CreateText(_goStopPanel.transform, _game.GreedScale.GetScaleVisual(), 18,
                    new Vector2(0, -35), new Color(1f, 0.5f, 0f));
            }

            CreateButton(_goStopPanel.transform, L.Get("go") + "!", new Vector2(-120, -70), () =>
            {
                if (_game.RoundManager == null) return;
                var risk = _game.RoundManager.SelectGo();
                _game.ApplyGoRisk(risk);
                _game.GreedScale.OnGo();

                // Go 이펙트
                if (_effects != null)
                {
                    _effects.PlayGoEffect(_game.Player.GoCount, new Vector2(0, 50));
                    _effects.SetGreedTint(_game.GreedScale.RedTint);

                    // 3 Go 특수 연출
                    if (_game.Player.GoCount >= 3)
                    {
                        _effects.PlayTripleGoSequence(() =>
                        {
                            _goStopPanel.SetActive(false);
                            RefreshGameUI();
                        });
                        return;
                    }
                }

                _goStopPanel.SetActive(false);
                RefreshGameUI();
            }, new Color(0.8f, 0.15f, 0.15f));

            CreateButton(_goStopPanel.transform, L.Get("stop"), new Vector2(120, -70), () =>
            {
                if (_game.RoundManager == null) return;
                _game.RoundManager.SelectStop();
                _game.GreedScale.OnStop();

                if (_effects != null)
                    _effects.ClearTint();

                _goStopPanel.SetActive(false);

                // → 공격 페이즈 UI 표시 (2장 선택)
                ShowAttackPhaseUI();
            }, new Color(0.3f, 0.3f, 0.7f));
        }

        private void BuildGatePanel()
        {
            _gatePanel = CreatePanel("Gate", _gamePanel.transform, new Color(0, 0, 0, 0.9f));
            var rt = _gatePanel.GetComponent<RectTransform>();
            rt.anchorMin = Vector2.zero;
            rt.anchorMax = Vector2.one;
            rt.offsetMin = Vector2.zero;
            rt.offsetMax = Vector2.zero;

            CreateText(_gatePanel.transform, L.Get("gate_title"), 36,
                new Vector2(0, 150), new Color(1f, 0.84f, 0f));
            CreateText(_gatePanel.transform, L.Get("gate_desc"), 20,
                new Vector2(0, 60), new Color(0.8f, 0.8f, 0.8f));

            CreateButton(_gatePanel.transform, L.Get("gate_enter"), new Vector2(0, -40), () =>
            {
                _gatePanel.SetActive(false);
                ShowMessage(L.Get("story_ending_light"));
                _game.ContinueAfterGate();
            }, new Color(1f, 0.84f, 0f));

            CreateButton(_gatePanel.transform, L.Get("gate_refuse"), new Vector2(0, -120), () =>
            {
                _gatePanel.SetActive(false);
                _game.ContinueAfterGate();
            }, new Color(0.5f, 0.15f, 0.15f));
        }

        #endregion

        #region UI 갱신

        public void RefreshGameUI()
        {
            if (_gamePanel == null) return;

            // 나선/영역 정보
            if (_spiralText != null)
            {
                _spiralText.text = L.Get("spiral_info", _game.Spiral.CurrentSpiral, _game.Spiral.CurrentRealm)
                    + " | " + L.Get("total_cleared", _game.Spiral.TotalRealmsCleared);
            }

            // 플레이어 정보
            if (_infoText != null)
            {
                _infoText.text = $"{L.Get("lives")}: {new string('♥', _game.Player.Lives)} | " +
                    L.Get("yeop_display", _game.Player.Yeop) + " | " +
                    L.Get("soul_display", _game.Upgrades.SoulFragments);
            }

            // 보스 정보 + HP 바
            if (_bossText != null && _game.CurrentBoss != null)
            {
                string partsInfo = _game.CurrentBoss.Parts.Count > 0
                    ? $" [{L.Get("boss_parts", _game.CurrentBoss.Parts.Count)}]" : "";
                string hpBar = "";
                if (_game.CurrentBattle != null)
                {
                    float ratio = _game.CurrentBattle.GetHPRatio();
                    int filled = (int)(ratio * 20);
                    hpBar = $"\n[{"".PadLeft(filled, '█')}{"".PadLeft(20 - filled, '░')}] {_game.CurrentBattle.GetHPDisplay()}";
                }
                _bossText.text = $"{_game.CurrentBoss.DisplayName}{partsInfo}{hpBar}";
            }

            if (_targetText != null && _game.RoundManager != null)
            {
                _targetText.text = $"{L.Get("round")} {_game.CurrentRoundInRealm}/{_game.TotalRoundsInRealm}";
            }

            // 점수 (큰 숫자는 단축 표기)
            if (_game.RoundManager != null)
            {
                var score = _game.RoundManager.LastScoreResult;
                if (_scoreText != null)
                    _scoreText.text = $"{L.Get("chips")}: {NumberFormatter.FormatScore(score.Chips)}";
                if (_multText != null)
                    _multText.text = NumberFormatter.FormatMult(score.Mult);
                if (_yokboText != null && score.CompletedYokbo != null)
                    _yokboText.text = string.Join("  |  ", score.CompletedYokbo);
            }

            // 욕망의 저울 갱신
            if (_greedText != null && _game.GreedScale != null)
            {
                var gl = _game.GreedScale;
                _greedText.text = gl.Level != Core.GreedLevel.Safe
                    ? $"{gl.GetScaleVisual()}\n{gl.GetStatusText()}" : "";
            }

            // 손패 갱신
            RefreshCards(_handArea, _game.Player.Hand, true);

            // 바닥패 갱신
            if (_game.RoundManager != null)
            {
                var fieldCards = _game.RoundManager.FieldCards;
                RefreshFieldCards(_fieldArea, fieldCards);
            }
        }

        private void RefreshFieldCards(Transform parent, System.Collections.Generic.IReadOnlyList<CardInstance> cards)
        {
            if (parent == null) return;

            for (int i = parent.childCount - 1; i >= 0; i--)
                Object.Destroy(parent.GetChild(i).gameObject);

            if (cards == null) return;

            foreach (var card in cards)
                CreateCardObject(parent, card);
        }

        private void RefreshCards(Transform parent, System.Collections.Generic.List<CardInstance> cards, bool interactive)
        {
            if (parent == null) return;

            // 기존 카드 제거
            for (int i = parent.childCount - 1; i >= 0; i--)
                Object.Destroy(parent.GetChild(i).gameObject);

            if (cards == null) return;

            foreach (var card in cards)
            {
                var cardObj = CreateCardObject(parent, card);
                if (interactive)
                {
                    var btn = cardObj.AddComponent<Button>();
                    var capturedCard = card;
                    btn.onClick.AddListener(() => OnCardClicked(capturedCard));

                    // 호버 색상
                    var colors = btn.colors;
                    colors.highlightedColor = new Color(1f, 1f, 0.8f);
                    colors.pressedColor = new Color(0.8f, 0.8f, 0.5f);
                    btn.colors = colors;
                }
            }
        }

        private GameObject CreateCardObject(Transform parent, CardInstance card)
        {
            var obj = new GameObject(card.NameKR);
            obj.transform.SetParent(parent, false);

            // 배경 이미지
            var img = obj.AddComponent<Image>();
            var tex = MockupSpriteFactory.CreateCardFace(card.Month, card.Type, card.Ribbon);
            img.sprite = MockupSpriteFactory.TextureToSprite(tex);

            var rt = obj.GetComponent<RectTransform>();
            rt.sizeDelta = new Vector2(MockupSpriteFactory.CardWidth, MockupSpriteFactory.CardHeight);

            // 월 텍스트
            var monthObj = new GameObject("Month");
            monthObj.transform.SetParent(obj.transform, false);
            var monthText = monthObj.AddComponent<TextMeshProUGUI>();
            monthText.text = $"{(int)card.Month}월";
            monthText.fontSize = 14;
            monthText.alignment = TextAlignmentOptions.Center;
            monthText.color = Color.white;
            var monthRt = monthObj.GetComponent<RectTransform>();
            monthRt.anchoredPosition = new Vector2(0, 38);
            monthRt.sizeDelta = new Vector2(70, 20);

            // 타입 텍스트
            var typeObj = new GameObject("Type");
            typeObj.transform.SetParent(obj.transform, false);
            var typeText = typeObj.AddComponent<TextMeshProUGUI>();
            typeText.text = card.Type switch
            {
                CardType.Gwang => "★광",
                CardType.Tti => card.Ribbon switch
                {
                    RibbonType.HongDan => "홍",
                    RibbonType.CheongDan => "청",
                    RibbonType.ChoDan => "초",
                    _ => "띠"
                },
                CardType.Yeolkkeut => "◆열",
                CardType.Pi => card.IsDoublePi ? "쌍피" : "●피",
                _ => "?"
            };
            typeText.fontSize = 16;
            typeText.fontStyle = FontStyles.Bold;
            typeText.alignment = TextAlignmentOptions.Center;
            typeText.color = new Color(0.15f, 0.15f, 0.15f);
            var typeRt = typeObj.GetComponent<RectTransform>();
            typeRt.anchoredPosition = new Vector2(0, 0);
            typeRt.sizeDelta = new Vector2(70, 25);

            // 점수 텍스트
            var ptObj = new GameObject("Points");
            ptObj.transform.SetParent(obj.transform, false);
            var ptText = ptObj.AddComponent<TextMeshProUGUI>();
            ptText.text = $"{card.BasePoints}";
            ptText.fontSize = 12;
            ptText.alignment = TextAlignmentOptions.Center;
            ptText.color = new Color(0.3f, 0.3f, 0.3f);
            var ptRt = ptObj.GetComponent<RectTransform>();
            ptRt.anchoredPosition = new Vector2(0, -42);
            ptRt.sizeDelta = new Vector2(70, 18);

            return obj;
        }

        #endregion

        #region 인터랙션

        private void OnCardClicked(CardInstance card)
        {
            if (_game.CurrentState != GameState.InRound) return;
            if (_game.RoundManager == null) return;
            if (_game.RoundManager.CurrentPhase != Combat.RoundManager.RoundPhase.PlayerTurn) return;

            // 카드 플레이
            var matchResult = _game.RoundManager.PlayHandCard(card);
            ShowMessage($"{card.NameKR} → {matchResult}");

            // 매칭 실행
            var captured = _game.RoundManager.ExecuteHandMatch();

            // 임팩트 이펙트
            if (_effects != null)
            {
                bool isSweep = captured.Count >= 4;
                if (captured.Count > 0)
                    _effects.PlayMatchEffect(new Vector2(0, 180), isSweep);
            }

            // 뒤집기
            var drawn = _game.RoundManager.FlipDrawCard();
            if (drawn != null)
            {
                var drawCaptured = _game.RoundManager.ExecuteDrawMatch();
                ShowMessage($"뒤집기: {drawn.NameKR}");

                if (_effects != null && drawCaptured.Count >= 4)
                    _effects.PlayMatchEffect(new Vector2(0, 180), true);
            }

            RefreshGameUI();

            // Go/Stop 체크
            if (_game.RoundManager.CurrentPhase == RoundManager.RoundPhase.GoStopChoice)
            {
                if (_goStopPanel != null) Object.Destroy(_goStopPanel);
                BuildGoStopPanel();
                _goStopPanel.SetActive(true);
            }
            // 패 소진 → 공격 페이즈
            else if (_game.RoundManager.CurrentPhase == RoundManager.RoundPhase.Scoring)
            {
                ShowAttackPhaseUI();
            }
        }

        public void HandleInput()
        {
            // 키보드 입력 없음. 모든 조작은 마우스/터치 버튼으로 처리.
        }

        // 라운드 종료 후 액션 버튼
        private GameObject _actionButtonsPanel;

        private void ClearActionButtons()
        {
            if (_actionButtonsPanel != null)
                Object.Destroy(_actionButtonsPanel);
            _actionButtonsPanel = null;
        }

        private void ShowPostRoundButtons()
        {
            ClearActionButtons();
            _actionButtonsPanel = CreatePanel("ActionButtons", _gamePanel.transform, Color.clear);
            var rt = _actionButtonsPanel.GetComponent<RectTransform>();
            rt.anchoredPosition = new Vector2(0, -420);
            rt.sizeDelta = new Vector2(600, 80);

            bool dealt = _game.RoundManager != null && _game.RoundManager.LastScoreResult.FinalScore > 0;
            bool bossAlive = _game.CurrentBattle != null && !_game.CurrentBattle.IsBossDefeated;
            bool hasMoreRounds = _game.CurrentRoundInRealm < _game.TotalRoundsInRealm;

            if (dealt && bossAlive && hasMoreRounds)
            {
                // 타격 성공, 보스 아직 살아있음 → 다음 판
                string hpInfo = _game.CurrentBattle != null ? _game.CurrentBattle.GetHPDisplay() : "";
                ShowMessage($"타격! 보스 {hpInfo} | 다음 판 준비...");

                CreateButton(_actionButtonsPanel.transform, L.Get("next_round"), new Vector2(0, 0), () =>
                {
                    ClearActionButtons();
                    _game.StartNextRound();
                    RefreshGameUI();
                }, new Color(0.15f, 0.5f, 0.15f));
            }
            else if (!dealt && _game.Player.Lives > 0)
            {
                // 족보 없이 패 소진 → 데미지 0 → 판 낭비
                ShowMessage("족보 없이 끝났다... 다시 치자!");

                CreateButton(_actionButtonsPanel.transform, L.Get("retry"), new Vector2(0, 0), () =>
                {
                    ClearActionButtons();
                    _game.StartNextRound();
                    RefreshGameUI();
                }, new Color(0.6f, 0.3f, 0.15f));
            }
            // 보스 격파 or 게임오버는 HandleRoundEnded에서 직접 상태 전환
        }

        private void ShowShopUI()
        {
            ClearActionButtons();
            _actionButtonsPanel = CreatePanel("ShopPanel", _gamePanel.transform, new Color(0, 0, 0, 0.7f));
            var rt = _actionButtonsPanel.GetComponent<RectTransform>();
            rt.anchorMin = new Vector2(0.1f, 0.15f);
            rt.anchorMax = new Vector2(0.9f, 0.85f);
            rt.offsetMin = Vector2.zero;
            rt.offsetMax = Vector2.zero;

            CreateText(_actionButtonsPanel.transform, L.Get("shop"), 28,
                new Vector2(0, 220), new Color(1f, 0.84f, 0f));
            CreateText(_actionButtonsPanel.transform, L.Get("shop_greeting"), 16,
                new Vector2(0, 180), new Color(0.7f, 0.7f, 0.7f));
            CreateText(_actionButtonsPanel.transform, L.Get("yeop_display", _game.Player.Yeop), 18,
                new Vector2(0, 145), Color.white);

            // 상점 아이템 버튼
            var stock = _game.Shop.CurrentStock;
            for (int i = 0; i < stock.Count; i++)
            {
                var item = stock[i];
                int idx = i;
                string label = item.IsSold ? $"[{L.Get("buy")}완료]" :
                    $"{item.NameKR}  ({item.Cost} {L.Get("yeop")})";
                float yPos = 80 - i * 55;

                Color btnColor = item.IsSold ? new Color(0.3f, 0.3f, 0.3f) :
                    (item.TalismanData != null ? new Color(0.2f, 0.35f, 0.5f) : new Color(0.3f, 0.4f, 0.3f));

                CreateButton(_actionButtonsPanel.transform, label, new Vector2(0, yPos), () =>
                {
                    if (_game.ShopPurchase(idx))
                    {
                        ShowMessage($"{stock[idx].NameKR} 구매!");
                        ShowShopUI(); // 새로고침
                    }
                    else
                    {
                        ShowMessage("구매 불가!");
                    }
                }, btnColor);
            }

            // 대장간 버튼
            CreateButton(_actionButtonsPanel.transform, L.Get("forge"), new Vector2(-150, -200), () =>
            {
                ShowForgeUI();
            }, new Color(0.5f, 0.3f, 0.1f));

            // 나가기 버튼
            CreateButton(_actionButtonsPanel.transform, L.Get("next_realm") + " ▶", new Vector2(150, -200), () =>
            {
                ClearActionButtons();
                _game.LeaveShop();
            }, new Color(0.15f, 0.5f, 0.15f));
        }

        private void ShowEventUI()
        {
            ClearActionButtons();
            var evt = _game.Events.CurrentEvent;
            if (evt == null)
            {
                _game.LeaveEvent();
                return;
            }

            _actionButtonsPanel = CreatePanel("EventPanel", _gamePanel.transform, new Color(0, 0, 0, 0.8f));
            var rt = _actionButtonsPanel.GetComponent<RectTransform>();
            rt.anchorMin = new Vector2(0.1f, 0.1f);
            rt.anchorMax = new Vector2(0.9f, 0.9f);
            rt.offsetMin = Vector2.zero;
            rt.offsetMax = Vector2.zero;

            CreateText(_actionButtonsPanel.transform, evt.TitleKR, 30,
                new Vector2(0, 250), new Color(1f, 0.84f, 0f));
            CreateText(_actionButtonsPanel.transform, evt.DescriptionKR, 18,
                new Vector2(0, 160), new Color(0.85f, 0.85f, 0.85f));

            for (int i = 0; i < evt.Choices.Count; i++)
            {
                var choice = evt.Choices[i];
                int idx = i;
                float yPos = 40 - i * 60;

                CreateButton(_actionButtonsPanel.transform, choice.TextKR, new Vector2(0, yPos), () =>
                {
                    string result = _game.ExecuteEventChoice(idx);
                    ShowMessage(result);
                    ClearActionButtons();

                    // 결과 표시 후 다음 영역 버튼
                    _actionButtonsPanel = CreatePanel("EventResult", _gamePanel.transform, Color.clear);
                    var resultRt = _actionButtonsPanel.GetComponent<RectTransform>();
                    resultRt.anchoredPosition = new Vector2(0, -420);
                    resultRt.sizeDelta = new Vector2(600, 60);

                    CreateButton(_actionButtonsPanel.transform, L.Get("next_realm") + " ▶", new Vector2(0, 0), () =>
                    {
                        ClearActionButtons();
                        _game.LeaveEvent();
                    }, new Color(0.15f, 0.5f, 0.15f));
                }, new Color(0.25f, 0.25f, 0.4f));
            }
        }

        private void ShowGameOverButtons()
        {
            ClearActionButtons();
            _actionButtonsPanel = CreatePanel("ActionButtons", _gamePanel.transform, new Color(0, 0, 0, 0.85f));
            var rt = _actionButtonsPanel.GetComponent<RectTransform>();
            rt.anchorMin = new Vector2(0.15f, 0.2f);
            rt.anchorMax = new Vector2(0.85f, 0.8f);
            rt.offsetMin = Vector2.zero;
            rt.offsetMax = Vector2.zero;

            CreateText(_actionButtonsPanel.transform, L.Get("game_over"), 36,
                new Vector2(0, 180), new Color(1f, 0.3f, 0.3f));
            CreateText(_actionButtonsPanel.transform, L.Get("soul_display", _game.Upgrades.SoulFragments), 22,
                new Vector2(0, 120), Color.white);
            CreateText(_actionButtonsPanel.transform,
                L.Get("total_cleared", _game.Spiral.TotalRealmsCleared), 18,
                new Vector2(0, 80), new Color(0.7f, 0.7f, 0.7f));

            // 영구 강화 버튼
            CreateButton(_actionButtonsPanel.transform, L.Get("permanent_upgrade"), new Vector2(0, 10), () =>
            {
                ClearActionButtons();
                ShowUpgradeTreeUI();
            }, new Color(0.4f, 0.2f, 0.6f));

            // 다시 도전
            CreateButton(_actionButtonsPanel.transform, L.Get("retry"), new Vector2(0, -60), () =>
            {
                ClearActionButtons();
                _game.StartNewGame();
                // SpiralStart에서 축복 선택 UI 표시됨
            }, new Color(0.6f, 0.15f, 0.15f));

            // 메인 메뉴
            CreateButton(_actionButtonsPanel.transform, L.Get("main_menu"), new Vector2(0, -130), () =>
            {
                ClearActionButtons();
                BuildMainMenu();
            }, new Color(0.2f, 0.2f, 0.3f));
        }

        #endregion

        #region 상태 처리

        private void HandleStateChange(GameState state)
        {
            switch (state)
            {
                case GameState.MainMenu:
                    BuildMainMenu();
                    break;

                case GameState.SpiralStart:
                    if (_gamePanel == null) BuildGameScreen();
                    _goStopPanel?.SetActive(false);
                    _gatePanel?.SetActive(false);
                    ShowBlessingSelectionUI();
                    break;

                case GameState.PreRound:
                case GameState.InRound:
                    if (_gamePanel == null) BuildGameScreen();
                    _goStopPanel?.SetActive(false);
                    _gatePanel?.SetActive(false);
                    RefreshGameUI();
                    // 섯다 결과 표시
                    if (_game.RoundManager?.LastSeotda != null)
                    {
                        ShowMessage(_game.RoundManager.LastSeotda.GetResultDisplay());
                        if (_effects != null && _game.RoundManager.LastSeotda.PlayerWon)
                            _effects.Flash(new Color(1f, 0.84f, 0f), 0.2f);
                    }
                    // 튜토리얼 오버레이
                    if (_tutorial != null && _tutorial.IsActive)
                        ShowTutorialOverlay();
                    break;

                case GameState.PostRound:
                    RefreshGameUI();
                    // 보스 격파 시에는 wave upgrade/shop/gate로 넘어가므로 PostRound 버튼 불필요
                    // 같은 영역 내 라운드 승리 or 패배(목숨 남음) 시에만 버튼 표시
                    if (_game.CurrentRoundInRealm < _game.TotalRoundsInRealm ||
                        (_game.Player.Lives > 0 && _game.RoundManager != null &&
                         _game.RoundManager.LastScoreResult.FinalScore < _game.RoundManager.TargetScore))
                    {
                        ShowPostRoundButtons();
                    }
                    break;

                case GameState.Shop:
                    ShowShopUI();
                    break;

                case GameState.Event:
                    ShowEventUI();
                    break;

                case GameState.Gate:
                    _gatePanel?.SetActive(true);
                    break;

                case GameState.GameOver:
                    ShowGameOverButtons();
                    break;
            }
        }

        #endregion

        #region 공격 페이즈 UI (섯다 2장 선택)

        private CardInstance _selectedAttackCard1;
        private CardInstance _selectedAttackCard2;

        private void ShowAttackPhaseUI()
        {
            ClearActionButtons();
            _selectedAttackCard1 = null;
            _selectedAttackCard2 = null;

            _actionButtonsPanel = CreatePanel("AttackPhase", _gamePanel.transform, new Color(0, 0, 0, 0.85f));
            var rt = _actionButtonsPanel.GetComponent<RectTransform>();
            rt.anchorMin = Vector2.zero;
            rt.anchorMax = Vector2.one;
            rt.offsetMin = Vector2.zero;
            rt.offsetMax = Vector2.zero;

            // 타이틀
            CreateText(_actionButtonsPanel.transform, "공격할 2장을 골라라!", 28,
                new Vector2(0, 420), new Color(1f, 0.3f, 0.2f));

            // 현재 시너지 표시
            _game.Battle.EvaluateSynergies(_game.Player);
            string synergyText = "";
            foreach (var s in _game.Battle.ActiveSynergies)
                synergyText += $"[{s.Name}: {s.Description}] ";
            if (synergyText.Length > 0)
                CreateText(_actionButtonsPanel.transform, $"시너지: {synergyText}", 14,
                    new Vector2(0, 380), new Color(0.3f, 1f, 0.5f));
            else
                CreateText(_actionButtonsPanel.transform, "(시너지 없음)", 14,
                    new Vector2(0, 380), new Color(0.5f, 0.5f, 0.5f));

            // 보스 HP 표시
            if (_game.CurrentBattle != null)
                CreateText(_actionButtonsPanel.transform, $"보스 {_game.CurrentBattle.GetHPDisplay()}", 20,
                    new Vector2(0, 350), new Color(1f, 0.4f, 0.4f));

            // 먹은 패 전부 표시 (클릭으로 선택)
            var allCaptured = new System.Collections.Generic.List<CardInstance>();
            allCaptured.AddRange(_game.Player.CapturedGwang);
            allCaptured.AddRange(_game.Player.CapturedTti);
            allCaptured.AddRange(_game.Player.CapturedYeolkkeut);
            allCaptured.AddRange(_game.Player.CapturedPi);

            // 그리드 배치
            int cols = 10;
            float startX = -360;
            float startY = 250;
            float cardW = 75;
            float cardH = 110;
            float gapX = 5;
            float gapY = 5;

            var _selectedText = CreateText(_actionButtonsPanel.transform, "선택: (없음) + (없음)", 20,
                new Vector2(0, -200), Color.white);

            var _previewText = CreateText(_actionButtonsPanel.transform, "", 18,
                new Vector2(0, -240), new Color(1f, 0.84f, 0f));

            Button _attackBtn = null;

            for (int i = 0; i < allCaptured.Count; i++)
            {
                var card = allCaptured[i];
                int col = i % cols;
                int row = i / cols;
                float x = startX + col * (cardW + gapX);
                float y = startY - row * (cardH + gapY);

                var cardObj = CreateCardObject(_actionButtonsPanel.transform, card);
                var cardRt = cardObj.GetComponent<RectTransform>();
                cardRt.anchoredPosition = new Vector2(x, y);

                var btn = cardObj.AddComponent<Button>();
                var capturedCard = card;
                var selText = _selectedText;
                var prevText = _previewText;
                var atkBtn = _attackBtn;

                btn.onClick.AddListener(() =>
                {
                    if (_selectedAttackCard1 == null)
                    {
                        _selectedAttackCard1 = capturedCard;
                        selText.text = $"선택: [{capturedCard.NameKR}] + (없음)";
                    }
                    else if (_selectedAttackCard2 == null && capturedCard != _selectedAttackCard1)
                    {
                        _selectedAttackCard2 = capturedCard;
                        selText.text = $"선택: [{_selectedAttackCard1.NameKR}] + [{_selectedAttackCard2.NameKR}]";

                        // 섯다 미리보기
                        var preview = SeotdaChallenge.Evaluate(_selectedAttackCard1, _selectedAttackCard2);
                        prevText.text = $"→ {preview.Name} (예상 데미지: {GetPreviewDamage(preview)})";
                    }
                    else
                    {
                        // 재선택
                        _selectedAttackCard1 = capturedCard;
                        _selectedAttackCard2 = null;
                        selText.text = $"선택: [{capturedCard.NameKR}] + (없음)";
                        prevText.text = "";
                    }
                });
            }

            if (allCaptured.Count == 0)
            {
                CreateText(_actionButtonsPanel.transform, "먹은 패가 없다... 공격 불가!", 20,
                    new Vector2(0, 0), new Color(1f, 0.3f, 0.3f));
            }

            // 공격! 버튼
            CreateButton(_actionButtonsPanel.transform, "공격!", new Vector2(0, -300), () =>
            {
                if (_selectedAttackCard1 == null || _selectedAttackCard2 == null)
                {
                    ShowMessage("2장을 선택해야 한다!");
                    return;
                }

                var result = _game.SeotdaAttack(_selectedAttackCard1, _selectedAttackCard2);

                // 공격 이펙트
                if (_effects != null)
                {
                    _effects.PlayStopEffect(result.FinalDamage, new Vector2(0, 0));
                    if (result.FinalDamage >= 200)
                        _effects.ScreenShake(10f, 0.4f);
                    else
                        _effects.ScreenShake(5f, 0.2f);
                }

                ClearActionButtons();
                RefreshGameUI();
            }, new Color(0.8f, 0.15f, 0.1f));
        }

        private int GetPreviewDamage(Combat.SeotdaResult seotda)
        {
            _game.Battle.EvaluateSynergies(_game.Player);
            int baseDmg = seotda.Rank switch
            {
                100 => 300, 99 => 250, 98 => 230, 95 => 200,
                >= 90 => 150, >= 80 => 80 + (seotda.Rank - 80) * 7,
                75 => 100, 74 => 90, 73 => 80, 72 => 70, 71 => 60, 70 => 50,
                >= 7 => seotda.Rank * 5, >= 1 => seotda.Rank * 3, _ => 5
            };
            int goMult = _game.Player.GoCount switch { 1 => 2, 2 => 4, >= 3 => 10, _ => 1 };
            return (int)((baseDmg + _game.Battle.TotalSynergyBonus) * _game.Battle.TotalSynergyMult) * goMult;
        }

        #endregion

        #region 축복 선택 UI

        private void ShowBlessingSelectionUI()
        {
            ClearActionButtons();
            _actionButtonsPanel = CreatePanel("BlessingPanel", _gamePanel != null ? _gamePanel.transform : _root,
                new Color(0, 0, 0, 0.9f));
            var rt = _actionButtonsPanel.GetComponent<RectTransform>();
            rt.anchorMin = Vector2.zero;
            rt.anchorMax = Vector2.one;
            rt.offsetMin = Vector2.zero;
            rt.offsetMax = Vector2.zero;

            CreateText(_actionButtonsPanel.transform, L.Get("blessing_title"), 32,
                new Vector2(0, 280), new Color(1f, 0.84f, 0f));
            CreateText(_actionButtonsPanel.transform,
                $"{L.Get("spiral")} {_game.Spiral.CurrentSpiral}", 20,
                new Vector2(0, 230), new Color(0.7f, 0.7f, 0.8f));

            var blessings = SpiralBlessing.GetAll();
            for (int i = 0; i < blessings.Count; i++)
            {
                var b = blessings[i];
                float yPos = 130 - i * 90;
                string label = $"{b.NameKR}\n{b.BonusDesc} / {b.PenaltyDesc}";

                Color btnColor = b.Id switch
                {
                    "fire" => new Color(0.6f, 0.15f, 0.1f),
                    "ice" => new Color(0.1f, 0.3f, 0.6f),
                    "void" => new Color(0.3f, 0.1f, 0.5f),
                    "chaos" => new Color(0.5f, 0.4f, 0.1f),
                    _ => new Color(0.3f, 0.3f, 0.3f)
                };

                var blessingRef = b;
                var btn = CreateButton(_actionButtonsPanel.transform, label, new Vector2(0, yPos), () =>
                {
                    ClearActionButtons();
                    if (_gamePanel == null) BuildGameScreen();
                    _game.BeginSpiralWithBlessing(blessingRef);
                }, btnColor);
                btn.GetComponent<RectTransform>().sizeDelta = new Vector2(500, 70);
            }

            // 거부 버튼
            CreateButton(_actionButtonsPanel.transform, L.Get("blessing_skip"), new Vector2(0, -250), () =>
            {
                ClearActionButtons();
                if (_gamePanel == null) BuildGameScreen();
                _game.BeginSpiralWithBlessing(null);
            }, new Color(0.3f, 0.3f, 0.3f));
        }

        #endregion

        #region 영구 강화 UI

        private void ShowUpgradeTreeUI()
        {
            ClearActionButtons();
            _actionButtonsPanel = CreatePanel("UpgradeTree", _mainMenuPanel != null ? _mainMenuPanel.transform : _root,
                new Color(0, 0, 0, 0.92f));
            var rt = _actionButtonsPanel.GetComponent<RectTransform>();
            rt.anchorMin = Vector2.zero;
            rt.anchorMax = Vector2.one;
            rt.offsetMin = Vector2.zero;
            rt.offsetMax = Vector2.zero;

            CreateText(_actionButtonsPanel.transform, L.Get("permanent_upgrade"), 30,
                new Vector2(0, 350), new Color(1f, 0.84f, 0f));
            CreateText(_actionButtonsPanel.transform, L.Get("soul_display", _game.Upgrades.SoulFragments), 20,
                new Vector2(0, 310), Color.white);

            // 3갈래 트리 타이틀
            CreateText(_actionButtonsPanel.transform, L.Get("path_card"), 20,
                new Vector2(-350, 260), new Color(0.3f, 0.7f, 1f));
            CreateText(_actionButtonsPanel.transform, L.Get("path_talisman"), 20,
                new Vector2(0, 260), new Color(0.7f, 0.3f, 1f));
            CreateText(_actionButtonsPanel.transform, L.Get("path_survival"), 20,
                new Vector2(350, 260), new Color(0.3f, 1f, 0.5f));

            // 강화 목록
            int cardY = 200, talY = 200, survY = 200;
            foreach (var upg in _game.Upgrades.AllUpgrades)
            {
                int level = _game.Upgrades.GetLevel(upg.Id);
                int cost = upg.GetCost(level);
                bool canBuy = _game.Upgrades.CanUpgrade(upg.Id);
                bool maxed = level >= upg.MaxLevel;

                string label = maxed
                    ? $"{upg.NameKR} MAX"
                    : $"{upg.NameKR} {L.Get("upgrade_level", level, upg.MaxLevel)}\n{L.Get("upgrade_cost", cost)}";

                float xPos;
                int yPos;
                switch (upg.Path)
                {
                    case UpgradePath.Card:
                        xPos = -350; yPos = cardY; cardY -= 50;
                        break;
                    case UpgradePath.Talisman:
                        xPos = 0; yPos = talY; talY -= 50;
                        break;
                    default:
                        xPos = 350; yPos = survY; survY -= 50;
                        break;
                }

                Color btnColor = maxed ? new Color(0.2f, 0.2f, 0.2f) :
                    (canBuy ? new Color(0.2f, 0.4f, 0.5f) : new Color(0.15f, 0.15f, 0.2f));

                var upgId = upg.Id;
                var btn = CreateButton(_actionButtonsPanel.transform, label, new Vector2(xPos, yPos), () =>
                {
                    if (_game.Upgrades.Purchase(upgId))
                    {
                        ShowMessage($"{upg.NameKR} 강화!");
                        ShowUpgradeTreeUI(); // 새로고침
                    }
                }, btnColor);
                btn.GetComponent<RectTransform>().sizeDelta = new Vector2(280, 45);
                var labelTmp = btn.GetComponentInChildren<TextMeshProUGUI>();
                if (labelTmp != null) labelTmp.fontSize = 14;
            }

            // 돌아가기 버튼
            CreateButton(_actionButtonsPanel.transform, L.Get("main_menu"), new Vector2(0, -380), () =>
            {
                ClearActionButtons();
                if (_game.CurrentState == GameState.GameOver)
                    ShowGameOverButtons();
                else
                    BuildMainMenu();
            }, new Color(0.3f, 0.3f, 0.4f));
        }

        #endregion

        #region 웨이브 강화 UI

        private void ShowWaveUpgradeUI()
        {
            ClearActionButtons();
            _actionButtonsPanel = CreatePanel("WaveUpgrade", _gamePanel.transform, new Color(0, 0, 0, 0.88f));
            var rt = _actionButtonsPanel.GetComponent<RectTransform>();
            rt.anchorMin = new Vector2(0.05f, 0.1f);
            rt.anchorMax = new Vector2(0.95f, 0.9f);
            rt.offsetMin = Vector2.zero;
            rt.offsetMax = Vector2.zero;

            CreateText(_actionButtonsPanel.transform, L.Get("wave_upgrade_title"), 30,
                new Vector2(0, 250), new Color(1f, 0.84f, 0f));

            var choices = _game.WaveUpgrades.CurrentChoices;
            for (int i = 0; i < choices.Count; i++)
            {
                var c = choices[i];
                int idx = i;
                float xPos = (i - 1) * 280; // -280, 0, 280

                Color cardColor = c.Category switch
                {
                    "card" => new Color(0.2f, 0.35f, 0.6f),
                    "talisman" => new Color(0.5f, 0.2f, 0.6f),
                    "survival" => new Color(0.2f, 0.5f, 0.3f),
                    _ => new Color(0.5f, 0.4f, 0.2f)
                };

                // 카드 형태 버튼
                var cardPanel = CreatePanel($"Choice_{i}", _actionButtonsPanel.transform, cardColor);
                var cardRt = cardPanel.GetComponent<RectTransform>();
                cardRt.anchorMin = new Vector2(0.5f, 0.5f);
                cardRt.anchorMax = new Vector2(0.5f, 0.5f);
                cardRt.anchoredPosition = new Vector2(xPos, 0);
                cardRt.sizeDelta = new Vector2(240, 300);

                CreateText(cardPanel.transform, c.NameKR, 22, new Vector2(0, 100), Color.white);
                CreateText(cardPanel.transform, c.DescKR, 16, new Vector2(0, 30), new Color(0.85f, 0.85f, 0.85f));

                var btn = cardPanel.AddComponent<Button>();
                btn.onClick.AddListener(() =>
                {
                    _game.ApplyWaveUpgrade(idx);
                    ShowMessage($"{c.NameKR} 선택!");
                    ClearActionButtons();
                    ShowCompanionIcons();
                    // ApplyWaveUpgrade가 OpenShop()을 호출 → ShowShopUI 자동 트리거
                });
            }
        }

        #endregion

        #region 대장간 UI

        private void ShowForgeUI()
        {
            ClearActionButtons();
            _actionButtonsPanel = CreatePanel("ForgePanel", _gamePanel.transform, new Color(0, 0, 0, 0.85f));
            var rt = _actionButtonsPanel.GetComponent<RectTransform>();
            rt.anchorMin = new Vector2(0.1f, 0.1f);
            rt.anchorMax = new Vector2(0.9f, 0.9f);
            rt.offsetMin = Vector2.zero;
            rt.offsetMax = Vector2.zero;

            CreateText(_actionButtonsPanel.transform, L.Get("forge"), 28,
                new Vector2(0, 300), new Color(1f, 0.6f, 0.2f));
            CreateText(_actionButtonsPanel.transform, L.Get("forge_desc"), 16,
                new Vector2(0, 260), new Color(0.7f, 0.7f, 0.7f));
            CreateText(_actionButtonsPanel.transform, L.Get("yeop_display", _game.Player.Yeop), 18,
                new Vector2(0, 225), Color.white);

            // 강화 가능한 카드 표시 (획득한 카드 중 처음 8장)
            var allCards = new System.Collections.Generic.List<CardInstance>();
            allCards.AddRange(_game.Player.CapturedGwang);
            allCards.AddRange(_game.Player.CapturedTti);
            allCards.AddRange(_game.Player.CapturedYeolkkeut);

            int yPos = 160;
            int count = 0;
            foreach (var card in allCards)
            {
                if (count >= 8) break;
                var enh = _game.CardEnhancements.GetEnhancement(card.Id);
                int cost = CardEnhancementManager.GetUpgradeCost(enh.Tier);
                bool maxed = cost < 0;

                string tierName = enh.Tier switch
                {
                    EnhancementTier.Base => L.Get("tier_base"),
                    EnhancementTier.Refined => L.Get("tier_refined"),
                    EnhancementTier.Divine => L.Get("tier_divine"),
                    EnhancementTier.Legendary => L.Get("tier_legendary"),
                    EnhancementTier.Nirvana => L.Get("tier_nirvana"),
                    _ => "?"
                };

                string label = maxed
                    ? $"{card.NameKR} [{tierName}] {L.Get("forge_max")}"
                    : $"{card.NameKR} [{tierName}] → {L.Get("forge_cost", cost)}";

                Color btnColor = maxed ? new Color(0.2f, 0.2f, 0.2f) :
                    (_game.Player.Yeop >= cost ? new Color(0.4f, 0.3f, 0.15f) : new Color(0.2f, 0.2f, 0.2f));

                int cardId = card.Id;
                int cardCost = cost;
                CreateButton(_actionButtonsPanel.transform, label, new Vector2(0, yPos), () =>
                {
                    if (_game.UpgradeCard(cardId, cardCost))
                    {
                        ShowMessage(L.Get("forge_success"));
                        ShowForgeUI(); // 새로고침
                    }
                }, btnColor);

                yPos -= 50;
                count++;
            }

            if (allCards.Count == 0)
            {
                CreateText(_actionButtonsPanel.transform, "강화할 카드가 없습니다", 16,
                    new Vector2(0, 50), new Color(0.5f, 0.5f, 0.5f));
            }

            // 돌아가기
            CreateButton(_actionButtonsPanel.transform, L.Get("shop") + " ▶", new Vector2(0, -300), () =>
            {
                ShowShopUI();
            }, new Color(0.3f, 0.3f, 0.4f));
        }

        #endregion

        #region 동료 도깨비 UI

        private void ShowCompanionIcons()
        {
            if (_companionPanel != null) Object.Destroy(_companionPanel);
            if (_gamePanel == null) return;

            var companions = _game.Companions.ActiveCompanions;
            if (companions.Count == 0) return;

            _companionPanel = CreatePanel("CompanionIcons", _gamePanel.transform, Color.clear);
            var rt = _companionPanel.GetComponent<RectTransform>();
            rt.anchorMin = new Vector2(0, 0);
            rt.anchorMax = new Vector2(0.2f, 0.15f);
            rt.offsetMin = new Vector2(10, 10);
            rt.offsetMax = new Vector2(-10, -10);

            for (int i = 0; i < companions.Count; i++)
            {
                var comp = companions[i];
                int slotIdx = i;
                string label = comp.IsReady
                    ? $"{comp.Data.NameKR}\n{L.Get("skill_ready")}"
                    : $"{comp.Data.NameKR}\n{L.Get("skill_cooldown", comp.CurrentCooldown)}";

                Color btnColor = comp.IsReady
                    ? new Color(0.15f, 0.5f, 0.4f)
                    : new Color(0.3f, 0.3f, 0.3f);

                var btn = CreateButton(_companionPanel.transform, label,
                    new Vector2(i * 130, 0), () =>
                {
                    if (_game.Companions.ExecuteAbility(slotIdx, _game.RoundManager,
                        _game.Player, _game.BossManager))
                    {
                        ShowMessage($"{comp.Data.AbilityNameKR} 발동!");
                        RefreshGameUI();
                        ShowCompanionIcons();
                    }
                    else
                    {
                        ShowMessage(L.Get("skill_cooldown", comp.CurrentCooldown));
                    }
                }, btnColor);
                btn.GetComponent<RectTransform>().sizeDelta = new Vector2(120, 60);
                var labelTmp = btn.GetComponentInChildren<TextMeshProUGUI>();
                if (labelTmp != null) labelTmp.fontSize = 12;
            }
        }

        #endregion

        #region 도감/업적 UI

        private void ShowCollectionUI()
        {
            ClearActionButtons();
            var parent = _mainMenuPanel != null ? _mainMenuPanel.transform : _root;
            _actionButtonsPanel = CreatePanel("CollectionPanel", parent, new Color(0, 0, 0, 0.92f));
            var rt = _actionButtonsPanel.GetComponent<RectTransform>();
            rt.anchorMin = Vector2.zero;
            rt.anchorMax = Vector2.one;
            rt.offsetMin = Vector2.zero;
            rt.offsetMax = Vector2.zero;

            CreateText(_actionButtonsPanel.transform, L.Get("collection_title"), 30,
                new Vector2(0, 350), new Color(1f, 0.84f, 0f));

            // 업적 진행
            CreateText(_actionButtonsPanel.transform,
                L.Get("achievement_progress",
                    _game.Achievements.GetUnlockedCount(),
                    _game.Achievements.GetTotalCount()),
                20, new Vector2(0, 300), Color.white);

            int yPos = 240;
            foreach (var ach in _game.Achievements.AllAchievements)
            {
                bool unlocked = _game.Achievements.IsUnlocked(ach.Id);
                string display = ach.IsHidden && !unlocked
                    ? "??? — ???"
                    : $"{(unlocked ? "V " : "  ")}{ach.NameKR} — {ach.DescriptionKR} (+{ach.SoulReward})";

                Color col = unlocked ? new Color(0.3f, 1f, 0.5f) : new Color(0.5f, 0.5f, 0.5f);
                CreateText(_actionButtonsPanel.transform, display, 14,
                    new Vector2(0, yPos), col);
                yPos -= 25;
            }

            // 돌아가기
            CreateButton(_actionButtonsPanel.transform, L.Get("main_menu"), new Vector2(0, -380), () =>
            {
                ClearActionButtons();
                BuildMainMenu();
            }, new Color(0.3f, 0.3f, 0.4f));
        }

        #endregion

        #region 튜토리얼 UI

        private void ShowTutorialOverlay()
        {
            if (_tutorialOverlay != null) Object.Destroy(_tutorialOverlay);
            if (_tutorial == null || !_tutorial.IsActive) return;

            _tutorialOverlay = CreatePanel("TutorialOverlay", _gamePanel.transform, new Color(0, 0, 0, 0.6f));
            var rt = _tutorialOverlay.GetComponent<RectTransform>();
            rt.anchorMin = new Vector2(0, 0.7f);
            rt.anchorMax = new Vector2(1, 1);
            rt.offsetMin = Vector2.zero;
            rt.offsetMax = Vector2.zero;

            // 뱃사공 대사
            CreateText(_tutorialOverlay.transform, L.Get("tutorial_boatman"), 14,
                new Vector2(-300, 60), new Color(0.5f, 0.8f, 1f));

            CreateText(_tutorialOverlay.transform, L.Get(_tutorial.CurrentDialogue), 18,
                new Vector2(0, 30), new Color(0.9f, 0.9f, 0.8f));

            // 힌트
            CreateText(_tutorialOverlay.transform, L.Get(_tutorial.CurrentHint), 16,
                new Vector2(0, -30), new Color(1f, 0.84f, 0f));

            // 다음 / 스킵 버튼
            CreateButton(_tutorialOverlay.transform, L.Get("tutorial_next"), new Vector2(200, -60), () =>
            {
                _tutorial.AdvanceStep();
                if (_tutorial.CurrentStep == TutorialManager.TutorialStep.Complete)
                {
                    PlayerPrefs.SetInt("tutorial_done", 1);
                    _game.IsTutorialMode = false;
                    if (_tutorialOverlay != null) Object.Destroy(_tutorialOverlay);
                }
                else
                {
                    ShowTutorialOverlay();
                }
            }, new Color(0.15f, 0.5f, 0.15f));

            CreateButton(_tutorialOverlay.transform, L.Get("tutorial_skip"), new Vector2(-200, -60), () =>
            {
                _tutorial.Skip();
                PlayerPrefs.SetInt("tutorial_done", 1);
                _game.IsTutorialMode = false;
                if (_tutorialOverlay != null) Object.Destroy(_tutorialOverlay);
            }, new Color(0.4f, 0.15f, 0.15f));
        }

        #endregion

        #region 유틸리티

        private void ShowMessage(string msg)
        {
            if (_messageText != null)
                _messageText.text = msg;
            Debug.Log($"[도깨비] {msg}");
        }

        private void ClearAll()
        {
            if (_mainMenuPanel != null) Object.Destroy(_mainMenuPanel);
            if (_gamePanel != null) Object.Destroy(_gamePanel);
            if (_actionButtonsPanel != null) Object.Destroy(_actionButtonsPanel);
            if (_tutorialOverlay != null) Object.Destroy(_tutorialOverlay);
            if (_companionPanel != null) Object.Destroy(_companionPanel);
            _mainMenuPanel = null;
            _gamePanel = null;
            _goStopPanel = null;
            _resultPanel = null;
            _gatePanel = null;
            _actionButtonsPanel = null;
            _tutorialOverlay = null;
            _companionPanel = null;
        }

        private GameObject CreatePanel(string name, Transform parent, Color bgColor)
        {
            var obj = new GameObject(name);
            obj.transform.SetParent(parent, false);

            var rt = obj.AddComponent<RectTransform>();
            rt.anchorMin = Vector2.zero;
            rt.anchorMax = Vector2.one;
            rt.offsetMin = Vector2.zero;
            rt.offsetMax = Vector2.zero;

            if (bgColor.a > 0)
            {
                var img = obj.AddComponent<Image>();
                img.color = bgColor;
            }

            return obj;
        }

        private TextMeshProUGUI CreateText(Transform parent, string text, int fontSize,
            Vector2 position, Color color)
        {
            var obj = new GameObject("Text");
            obj.transform.SetParent(parent, false);

            var tmp = obj.AddComponent<TextMeshProUGUI>();
            tmp.text = text;
            tmp.fontSize = fontSize;
            tmp.color = color;
            tmp.alignment = TextAlignmentOptions.Center;
            tmp.enableWordWrapping = true;

            var rt = obj.GetComponent<RectTransform>();
            rt.anchoredPosition = position;
            rt.sizeDelta = new Vector2(800, fontSize + 10);

            return tmp;
        }

        private Button CreateButton(Transform parent, string label, Vector2 position,
            UnityEngine.Events.UnityAction onClick, Color? bgColor = null)
        {
            var obj = new GameObject($"Btn_{label}");
            obj.transform.SetParent(parent, false);

            var img = obj.AddComponent<Image>();
            img.color = bgColor ?? new Color(0.2f, 0.2f, 0.3f);

            var btn = obj.AddComponent<Button>();
            btn.onClick.AddListener(onClick);

            var rt = obj.GetComponent<RectTransform>();
            rt.anchoredPosition = position;
            rt.sizeDelta = new Vector2(250, 50);

            // 라벨
            var textObj = new GameObject("Label");
            textObj.transform.SetParent(obj.transform, false);
            var tmp = textObj.AddComponent<TextMeshProUGUI>();
            tmp.text = label;
            tmp.fontSize = 20;
            tmp.color = Color.white;
            tmp.alignment = TextAlignmentOptions.Center;

            var textRt = textObj.GetComponent<RectTransform>();
            textRt.anchorMin = Vector2.zero;
            textRt.anchorMax = Vector2.one;
            textRt.offsetMin = Vector2.zero;
            textRt.offsetMax = Vector2.zero;

            return btn;
        }

        #endregion
    }
}

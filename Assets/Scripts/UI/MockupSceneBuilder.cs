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
        private static TMP_FontAsset _koreanFont;
        private static bool _fallbackLinked;

        public static TMP_FontAsset GetKoreanFont()
        {
            if (_koreanFont == null)
                _koreanFont = Resources.Load<TMP_FontAsset>("Fonts/Pretendard-Regular SDF");
            if (_koreanFont == null)
            {
                var all = Resources.FindObjectsOfTypeAll<TMP_FontAsset>();
                foreach (var f in all)
                    if (f.name.Contains("Pretendard")) { _koreanFont = f; break; }
            }

            // CJK Fallback 폰트 자동 연결 (한자/일본어/중국어)
            if (_koreanFont != null && !_fallbackLinked)
            {
                _fallbackLinked = true;
                TMP_FontAsset cjk = Resources.Load<TMP_FontAsset>("Fonts/NotoSansCJKkr-Regular SDF");
                if (cjk == null)
                {
                    var all = Resources.FindObjectsOfTypeAll<TMP_FontAsset>();
                    foreach (var f in all)
                        if (f.name.Contains("NotoSansCJK")) { cjk = f; break; }
                }
                if (cjk != null)
                {
                    // fallbackFontAssetTable이 null이면 새로 생성
                    if (_koreanFont.fallbackFontAssetTable == null)
                        _koreanFont.fallbackFontAssetTable = new System.Collections.Generic.List<TMP_FontAsset>();
                    if (!_koreanFont.fallbackFontAssetTable.Contains(cjk))
                    {
                        _koreanFont.fallbackFontAssetTable.Add(cjk);
                        Debug.Log("[Font] CJK Fallback 폰트 연결 완료: " + cjk.name);
                    }

                    // Fix CJK font material to prevent white background
                    if (cjk.material != null && _koreanFont.material != null)
                    {
                        cjk.material.shader = _koreanFont.material.shader;
                    }

                    // TMP 글로벌 Fallback에도 등록
                    var globalFallbacks = TMP_Settings.fallbackFontAssets;
                    if (globalFallbacks == null)
                    {
                        // TMP_Settings 접근 불가 시 무시
                    }
                    else if (!globalFallbacks.Contains(cjk))
                    {
                        globalFallbacks.Add(cjk);
                        Debug.Log("[Font] TMP 글로벌 Fallback에도 등록 완료");
                    }
                }
                else
                {
                    Debug.LogWarning("[Font] CJK 폰트를 찾을 수 없습니다!");
                }
            }

            return _koreanFont;
        }

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
            cam.backgroundColor = new Color(0.04f, 0.04f, 0.10f);
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
        private TextMeshProUGUI _scoreText;
        private TextMeshProUGUI _multText;
        private TextMeshProUGUI _targetText;
        private TextMeshProUGUI _synergyText;
        private TextMeshProUGUI _playsText;
        private TextMeshProUGUI _bossText;
        private TextMeshProUGUI _infoText;
        private TextMeshProUGUI _messageText;
        private TextMeshProUGUI _spiralText;

        // 카드 선택 시스템 (Balatro 스타일)
        private System.Collections.Generic.List<CardInstance> _selectedCards = new System.Collections.Generic.List<CardInstance>();
        private System.Collections.Generic.List<GameObject> _handCardObjects = new System.Collections.Generic.List<GameObject>();
        private TextMeshProUGUI _selectionCountText;

        // === COLOR PALETTE ===
        private static readonly Color ColBackground = new Color(0.04f, 0.04f, 0.10f);
        private static readonly Color ColPanelBg = new Color(0.08f, 0.08f, 0.16f, 0.95f);
        private static readonly Color ColGold = new Color(1f, 0.84f, 0f);
        private static readonly Color ColLightGold = new Color(1f, 0.91f, 0.5f);
        private static readonly Color ColCrimson = new Color(0.7f, 0.1f, 0.1f);
        private static readonly Color ColBloodRed = new Color(0.5f, 0.05f, 0.05f);
        private static readonly Color ColCyan = new Color(0f, 0.85f, 1f);
        private static readonly Color ColSoftWhite = new Color(0.9f, 0.88f, 0.82f);
        private static readonly Color ColDim = new Color(0.45f, 0.43f, 0.5f);
        private static readonly Color ColPurple = new Color(0.5f, 0.2f, 0.7f);
        private static readonly Color ColTeal = new Color(0.1f, 0.5f, 0.5f);

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
            _mainMenuPanel = CreatePanel("MainMenu", _root, ColBackground);

            // 타이틀
            CreateText(_mainMenuPanel.transform, L.Get("title"), 56,
                new Vector2(0, 240), ColGold);
            CreateText(_mainMenuPanel.transform, "Dokkaebi's Hand", 24,
                new Vector2(0, 170), ColLightGold);
            CreateText(_mainMenuPanel.transform, L.Get("subtitle"), 18,
                new Vector2(0, 130), ColDim);

            // 장식 구분선
            var separatorObj = new GameObject("Separator");
            separatorObj.transform.SetParent(_mainMenuPanel.transform, false);
            var sepImg = separatorObj.AddComponent<Image>();
            sepImg.color = new Color(ColGold.r, ColGold.g, ColGold.b, 0.3f);
            sepImg.raycastTarget = false;
            var sepRt = separatorObj.GetComponent<RectTransform>();
            sepRt.anchoredPosition = new Vector2(0, 90);
            sepRt.sizeDelta = new Vector2(400, 2);

            // 새 게임 버튼
            CreateButton(_mainMenuPanel.transform, L.Get("new_game"), new Vector2(0, 30), () =>
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
            }, new Color(0.5f, 0.05f, 0.05f));

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
            }, hasSave ? new Color(0.08f, 0.35f, 0.08f) : new Color(0.2f, 0.2f, 0.2f));
            if (!hasSave) continueBtn.interactable = false;

            // 영구 강화 버튼
            CreateButton(_mainMenuPanel.transform, L.Get("permanent_upgrade"), new Vector2(0, -110), () =>
            {
                ShowUpgradeTreeUI();
            }, new Color(0.35f, 0.1f, 0.5f));

            // 도감 버튼
            CreateButton(_mainMenuPanel.transform, L.Get("collection"), new Vector2(0, -180), () =>
            {
                ShowCollectionUI();
            }, ColTeal);

            // 언어 선택 버튼
            CreateButton(_mainMenuPanel.transform, L.Get("language") + ": 한/EN", new Vector2(0, -250), () =>
            {
                var mgr = LocalizationManager.Instance;
                int next = ((int)mgr.CurrentLanguage + 1) % 4;
                mgr.SetLanguage((Language)next);
                BuildMainMenu();
            }, new Color(0.18f, 0.18f, 0.25f));

            CreateButton(_mainMenuPanel.transform, L.Get("quit"), new Vector2(0, -320), () =>
            {
#if UNITY_EDITOR
                UnityEditor.EditorApplication.isPlaying = false;
#else
                Application.Quit();
#endif
            }, new Color(0.12f, 0.12f, 0.15f));

            // 조작법
            CreateText(_mainMenuPanel.transform, L.Get("input_hint"), 14,
                new Vector2(0, -400), ColDim);

            // 버전/크레딧
            CreateText(_mainMenuPanel.transform, "v0.1  |  Dokkaebi Studio", 12,
                new Vector2(0, -460), new Color(0.3f, 0.28f, 0.35f));
        }

        #endregion

        #region 게임 플레이 화면

        public void BuildGameScreen()
        {
            ClearAll();
            _selectedCards.Clear();
            _gamePanel = CreatePanel("Game", _root, ColPanelBg);

            var rt = _gamePanel.GetComponent<RectTransform>();
            rt.anchorMin = Vector2.zero;
            rt.anchorMax = Vector2.one;
            rt.offsetMin = Vector2.zero;
            rt.offsetMax = Vector2.zero;

            // ========================================
            // 최상단: 윤회/관문 정보 + 목숨/엽전
            // ========================================
            var topBar = CreatePanel("TopBar", _gamePanel.transform, new Color(0.03f, 0.03f, 0.08f, 0.9f));
            var topBarRt = topBar.GetComponent<RectTransform>();
            topBarRt.anchorMin = new Vector2(0, 1);
            topBarRt.anchorMax = new Vector2(1, 1);
            topBarRt.pivot = new Vector2(0.5f, 1);
            topBarRt.sizeDelta = new Vector2(0, 40);

            _spiralText = CreateText(topBar.transform, "", 15,
                new Vector2(-350, 0), new Color(0.5f, 0.5f, 0.75f));
            _infoText = CreateText(topBar.transform, "", 15,
                new Vector2(350, 0), ColSoftWhite);

            // 사주팔자 표시
            if (_game.Destiny.CurrentDestiny != null)
            {
                _destinyText = CreateText(topBar.transform,
                    $"[{_game.Destiny.CurrentDestiny.GetNameKR()}]", 12,
                    new Vector2(0, 0), ColPurple);
            }

            // ========================================
            // 보스 영역 (상단)
            // ========================================
            var bossPanel = CreatePanel("BossArea", _gamePanel.transform, new Color(0.06f, 0.03f, 0.03f, 0.8f));
            var bossPanelRt = bossPanel.GetComponent<RectTransform>();
            bossPanelRt.anchorMin = new Vector2(0.5f, 0.5f);
            bossPanelRt.anchorMax = new Vector2(0.5f, 0.5f);
            bossPanelRt.anchoredPosition = new Vector2(0, 390);
            bossPanelRt.sizeDelta = new Vector2(800, 160);

            // 보스 이미지 (Mock 실루엣)
            var bossImgObj = new GameObject("BossImage");
            bossImgObj.transform.SetParent(bossPanel.transform, false);
            var bossImg = bossImgObj.AddComponent<Image>();
            var bossTex = MockupSpriteFactory.CreateBossSilhouette();
            bossImg.sprite = MockupSpriteFactory.TextureToSprite(bossTex);
            bossImg.preserveAspect = true;
            bossImg.raycastTarget = false;
            var bossImgRt = bossImgObj.GetComponent<RectTransform>();
            bossImgRt.anchorMin = new Vector2(0.5f, 0.5f);
            bossImgRt.anchorMax = new Vector2(0.5f, 0.5f);
            bossImgRt.anchoredPosition = new Vector2(0, 20);
            bossImgRt.sizeDelta = new Vector2(90, 90);

            // 보스 이름
            _bossText = CreateText(bossPanel.transform, "", 22,
                new Vector2(0, -65), ColCrimson);

            // HP 바 배경
            var hpBarBg = new GameObject("HPBarBg");
            hpBarBg.transform.SetParent(bossPanel.transform, false);
            var hpBarBgImg = hpBarBg.AddComponent<Image>();
            hpBarBgImg.color = new Color(0.15f, 0.05f, 0.05f);
            hpBarBgImg.raycastTarget = false;
            var hpBarBgRt = hpBarBg.GetComponent<RectTransform>();
            hpBarBgRt.anchorMin = new Vector2(0.5f, 0.5f);
            hpBarBgRt.anchorMax = new Vector2(0.5f, 0.5f);
            hpBarBgRt.anchoredPosition = new Vector2(0, -85);
            hpBarBgRt.sizeDelta = new Vector2(500, 18);

            // HP 바 (라운드 정보 겸용)
            _targetText = CreateText(bossPanel.transform, "", 14,
                new Vector2(0, -85), ColSoftWhite);

            // ========================================
            // 시너지 패널 (중앙) — 누적 콤보 + 칩 x 배수
            // ========================================
            var synergyBg = CreatePanel("SynergyBg", _gamePanel.transform, new Color(0.04f, 0.04f, 0.1f, 0.85f));
            var synergyBgRt = synergyBg.GetComponent<RectTransform>();
            synergyBgRt.anchorMin = new Vector2(0.5f, 0.5f);
            synergyBgRt.anchorMax = new Vector2(0.5f, 0.5f);
            synergyBgRt.anchoredPosition = new Vector2(0, 210);
            synergyBgRt.sizeDelta = new Vector2(800, 80);

            _scoreText = CreateText(synergyBg.transform, "칩: 0", 28,
                new Vector2(-200, 18), ColSoftWhite);
            _multText = CreateText(synergyBg.transform, "x 배수: 1.0", 28,
                new Vector2(200, 18), ColCyan);
            _synergyText = CreateText(synergyBg.transform, "", 14,
                new Vector2(0, -18), ColGold);
            _playsText = CreateText(synergyBg.transform, "", 15,
                new Vector2(0, -35), ColDim);

            // ========================================
            // 내 패 — 클릭으로 선택/해제
            // ========================================
            CreateText(_gamePanel.transform, "내 패 — 카드를 클릭하여 선택 후 '내기!'", 15,
                new Vector2(0, 130), ColDim);

            _selectionCountText = CreateText(_gamePanel.transform, "선택: 0/5장", 16,
                new Vector2(0, 108), ColLightGold);

            var handBg = CreatePanel("HandArea", _gamePanel.transform,
                new Color(0.04f, 0.04f, 0.14f, 0.5f));
            var handRt = handBg.GetComponent<RectTransform>();
            handRt.anchorMin = new Vector2(0.5f, 0.5f);
            handRt.anchorMax = new Vector2(0.5f, 0.5f);
            handRt.anchoredPosition = new Vector2(0, -10);
            handRt.sizeDelta = new Vector2(1200, 200);

            _handArea = handBg.transform;
            var handLayout = handBg.AddComponent<HorizontalLayoutGroup>();
            handLayout.spacing = 6;
            handLayout.childAlignment = TextAnchor.MiddleCenter;
            handLayout.childForceExpandWidth = false;
            handLayout.childForceExpandHeight = false;
            handLayout.padding = new RectOffset(10, 10, 10, 10);

            // ========================================
            // 메시지 (하단)
            // ========================================
            var msgBg = CreatePanel("MsgBg", _gamePanel.transform, new Color(0.04f, 0.04f, 0.1f, 0.7f));
            var msgBgRt = msgBg.GetComponent<RectTransform>();
            msgBgRt.anchorMin = new Vector2(0.5f, 0.5f);
            msgBgRt.anchorMax = new Vector2(0.5f, 0.5f);
            msgBgRt.anchoredPosition = new Vector2(0, -160);
            msgBgRt.sizeDelta = new Vector2(800, 40);

            _messageText = CreateText(_gamePanel.transform, "", 18,
                new Vector2(0, -160), ColLightGold);

            // 욕망의 저울 표시 영역
            _greedText = CreateText(_gamePanel.transform, "", 14,
                new Vector2(350, -210), new Color(1f, 0.4f, 0.2f));

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
            _goStopPanel = CreatePanel("GoStop", _gamePanel.transform, new Color(0.03f, 0.03f, 0.08f, 0.92f));
            var rt = _goStopPanel.GetComponent<RectTransform>();
            rt.anchorMin = new Vector2(0.15f, 0.25f);
            rt.anchorMax = new Vector2(0.85f, 0.75f);
            rt.offsetMin = Vector2.zero;
            rt.offsetMax = Vector2.zero;

            // Decorative border
            AddPanelBorder(_goStopPanel, ColGold, 2);

            CreateText(_goStopPanel.transform, L.Get("go_or_stop"), 36,
                new Vector2(0, 150), ColGold);

            // 현재 누적 시너지 표시
            if (_game.RoundManager != null)
            {
                var rm = _game.RoundManager;
                CreateText(_goStopPanel.transform,
                    $"누적 시너지: 칩 {rm.AccumulatedChips} x 배수 {rm.AccumulatedMult:F1}", 22,
                    new Vector2(0, 100), new Color(0.2f, 1f, 0.3f));

                // 누적 콤보 목록
                string comboList = "";
                foreach (var c in rm.AccumulatedCombos)
                    comboList += $"[{c.NameKR}] ";
                if (comboList.Length > 0)
                    CreateText(_goStopPanel.transform, comboList, 14,
                        new Vector2(0, 65), ColGold);

                // Go 리스크 정보
                var risk = rm.GetCurrentGoRisk();
                string riskInfo = $"고 하면: +{risk.DrawCards}장, 보스 반격 {risk.BossDamage} 데미지";
                if (risk.InstantDeathRisk)
                    riskInfo += "\n즉사 위험!";

                CreateText(_goStopPanel.transform, riskInfo, 17,
                    new Vector2(0, 20), new Color(1f, 0.4f, 0.4f));
            }

            // 욕망의 저울 표시
            var greedStatus = _game.GreedScale.GetStatusText();
            if (!string.IsNullOrEmpty(greedStatus))
            {
                CreateText(_goStopPanel.transform, greedStatus, 15,
                    new Vector2(0, -15), new Color(1f, 0.3f, 0.3f, 0.8f));
                CreateText(_goStopPanel.transform, _game.GreedScale.GetScaleVisual(), 20,
                    new Vector2(0, -40), new Color(1f, 0.5f, 0f));
            }

            CreateButton(_goStopPanel.transform, L.Get("go") + "!", new Vector2(-140, -80), () =>
            {
                if (_game.RoundManager == null) return;
                int bossDamage = _game.RoundManager.SelectGo();
                _game.ApplyGoDamage(bossDamage);
                _game.GreedScale.OnGo();

                // 즉사 체크: Go 중 사망 시 게임오버 UI로 전환
                if (_game.CurrentState == GameState.GameOver)
                {
                    _goStopPanel.SetActive(false);
                    return; // HandleStateChange(GameOver)가 이미 처리
                }

                // Go 이펙트
                if (_effects != null)
                {
                    _effects.PlayGoEffect(_game.RoundManager.GoCount, new Vector2(0, 50));
                    _effects.SetGreedTint(_game.GreedScale.RedTint);

                    // 3 Go 특수 연출
                    if (_game.RoundManager.GoCount >= 3)
                    {
                        _effects.PlayTripleGoSequence(() =>
                        {
                            _goStopPanel.SetActive(false);
                            _selectedCards.Clear();
                            RefreshGameUI();
                        });
                        return;
                    }
                }

                _goStopPanel.SetActive(false);
                _selectedCards.Clear();
                RefreshGameUI();
            }, new Color(0.8f, 0f, 0f));

            // Make Go button larger
            var goBtnRt = _goStopPanel.transform.Find("Btn_" + L.Get("go") + "!");
            if (goBtnRt != null)
                goBtnRt.GetComponent<RectTransform>().sizeDelta = new Vector2(200, 60);

            CreateButton(_goStopPanel.transform, L.Get("stop"), new Vector2(140, -80), () =>
            {
                if (_game.RoundManager == null) return;
                _game.RoundManager.SelectStop();
                _game.GreedScale.OnStop();

                if (_effects != null)
                    _effects.ClearTint();

                _goStopPanel.SetActive(false);

                // → 공격 페이즈 UI 표시 (남은 손패에서 2장 선택)
                _selectedCards.Clear();
                ShowAttackPhaseUI();
            }, new Color(0f, 0f, 0.67f));

            // Make Stop button larger
            var stopBtnRt = _goStopPanel.transform.Find("Btn_" + L.Get("stop"));
            if (stopBtnRt != null)
                stopBtnRt.GetComponent<RectTransform>().sizeDelta = new Vector2(200, 60);
        }

        private void BuildGatePanel()
        {
            _gatePanel = CreatePanel("Gate", _gamePanel.transform, new Color(0.02f, 0.02f, 0.06f, 0.95f));
            var rt = _gatePanel.GetComponent<RectTransform>();
            rt.anchorMin = Vector2.zero;
            rt.anchorMax = Vector2.one;
            rt.offsetMin = Vector2.zero;
            rt.offsetMax = Vector2.zero;

            CreateText(_gatePanel.transform, L.Get("gate_title"), 40,
                new Vector2(0, 150), ColGold);
            CreateText(_gatePanel.transform, L.Get("gate_desc"), 20,
                new Vector2(0, 60), ColSoftWhite);

            CreateButton(_gatePanel.transform, L.Get("gate_enter"), new Vector2(0, -40), () =>
            {
                _gatePanel.SetActive(false);
                ShowMessage(L.Get("story_ending_light"));
                _game.ContinueAfterGate();
            }, new Color(0.7f, 0.6f, 0f));

            CreateButton(_gatePanel.transform, L.Get("gate_refuse"), new Vector2(0, -120), () =>
            {
                _gatePanel.SetActive(false);
                _game.ContinueAfterGate();
            }, ColBloodRed);
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
                int hp = _game.Player.Lives;
                int maxHp = PlayerState.MaxLives;
                string hpBar = "[";
                for (int i = 0; i < maxHp; i++)
                    hpBar += i < hp ? "|" : " ";
                hpBar += $"] {hp}/{maxHp}";
                _infoText.text = $"HP {hpBar} | " +
                    L.Get("yeop_display", _game.Player.Yeop) + " | " +
                    L.Get("soul_display", _game.Upgrades.SoulFragments);
            }

            // 보스 정보
            if (_bossText != null && _game.CurrentBoss != null)
            {
                string partsInfo = _game.CurrentBoss.Parts.Count > 0
                    ? $" [{L.Get("boss_parts", _game.CurrentBoss.Parts.Count)}]" : "";
                _bossText.text = $"{_game.CurrentBoss.DisplayName}{partsInfo}";
            }

            // HP 바 + 라운드 정보
            if (_targetText != null)
            {
                string hpInfo = "";
                if (_game.CurrentBattle != null)
                    hpInfo = $"HP: {_game.CurrentBattle.GetHPDisplay()}  ";
                string roundInfo = _game.RoundManager != null
                    ? $"{L.Get("round")} {_game.CurrentRoundInRealm}/{_game.TotalRoundsInRealm}" : "";
                _targetText.text = $"{hpInfo}{roundInfo}";
            }

            // 시너지 패널 갱신 (Balatro 스타일 누적)
            if (_game.RoundManager != null)
            {
                var rm = _game.RoundManager;
                if (_scoreText != null)
                    _scoreText.text = $"칩: {NumberFormatter.FormatScore(rm.AccumulatedChips)}";
                if (_multText != null)
                    _multText.text = $"x {rm.AccumulatedMult:F1}";

                // 누적 콤보 표시
                if (_synergyText != null)
                {
                    if (rm.AccumulatedCombos.Count > 0)
                    {
                        var comboNames = new System.Collections.Generic.List<string>();
                        foreach (var c in rm.AccumulatedCombos) comboNames.Add(c.NameKR);
                        _synergyText.text = string.Join("  |  ", comboNames);
                    }
                    else
                    {
                        _synergyText.text = "(콤보 없음)";
                    }
                }

                // 내기 횟수 / 고 횟수
                if (_playsText != null)
                {
                    string goInfo = rm.GoCount > 0 ? $"  |  고: {rm.GoCount}회" : "";
                    _playsText.text = $"내기 횟수: {rm.PlaysUsed}/{rm.MaxPlays}{goInfo}";
                }
            }

            // 선택 카운트 갱신 (단계에 따라 최대 수 다름)
            if (_selectionCountText != null)
            {
                bool isAttack = _game.RoundManager != null && _game.RoundManager.CurrentPhase == RoundManager.Phase.AttackSelect;
                int maxSelect = isAttack ? 2 : 5;
                string phaseLabel = isAttack ? "공격 카드" : "선택";
                _selectionCountText.text = $"{phaseLabel}: {_selectedCards.Count}/{maxSelect}장";
            }

            // 욕망의 저울 갱신
            if (_greedText != null && _game.GreedScale != null)
            {
                var gl = _game.GreedScale;
                _greedText.text = gl.Level != Core.GreedLevel.Safe
                    ? $"{gl.GetScaleVisual()}\n{gl.GetStatusText()}" : "";
            }

            // 손패 갱신 (선택 상태 반영)
            RefreshHandCards();

            // 페이즈별 액션 버튼 갱신
            RefreshPhaseButtons();
        }

        private void RefreshHandCards()
        {
            if (_handArea == null) return;

            // 기존 카드 제거
            for (int i = _handArea.childCount - 1; i >= 0; i--)
                Object.Destroy(_handArea.GetChild(i).gameObject);
            _handCardObjects.Clear();

            if (_game.RoundManager == null) return;
            var handCards = _game.RoundManager.HandCards;
            if (handCards == null) return;

            foreach (var card in handCards)
            {
                var cardObj = CreateCardObject(_handArea, card);
                _handCardObjects.Add(cardObj);

                bool isSelected = _selectedCards.Contains(card);

                // 선택된 카드 시각적 표시: 위로 올리고 밝게
                if (isSelected)
                {
                    var cardRt = cardObj.GetComponent<RectTransform>();
                    cardRt.anchoredPosition = new Vector2(0, 15); // 위로 올림

                    // 밝은 테두리 추가
                    var selBorder = new GameObject("SelectBorder");
                    selBorder.transform.SetParent(cardObj.transform, false);
                    var selImg = selBorder.AddComponent<Image>();
                    selImg.color = new Color(1f, 0.84f, 0f, 0.7f);
                    selImg.raycastTarget = false;
                    var selRt = selBorder.GetComponent<RectTransform>();
                    selRt.anchorMin = Vector2.zero;
                    selRt.anchorMax = Vector2.one;
                    selRt.offsetMin = new Vector2(-3, -3);
                    selRt.offsetMax = new Vector2(3, 3);
                    selBorder.transform.SetAsFirstSibling();
                }

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

        /// <summary>
        /// 현재 페이즈에 맞는 액션 버튼을 표시
        /// </summary>
        private void RefreshPhaseButtons()
        {
            if (_game.RoundManager == null) return;
            var phase = _game.RoundManager.CurrentPhase;

            // 기존 페이즈 버튼 제거
            ClearActionButtons();

            if (phase == RoundManager.Phase.SelectCards)
            {
                // "내기!" 버튼
                _actionButtonsPanel = CreatePanel("PhaseButtons", _gamePanel.transform, Color.clear);
                var rt = _actionButtonsPanel.GetComponent<RectTransform>();
                rt.anchoredPosition = new Vector2(0, -220);
                rt.sizeDelta = new Vector2(600, 70);

                var submitBtn = CreateButton(_actionButtonsPanel.transform, "내기!", new Vector2(0, 0), () =>
                {
                    SubmitSelectedCards();
                }, new Color(0.7f, 0.15f, 0.05f));
                submitBtn.GetComponent<RectTransform>().sizeDelta = new Vector2(200, 60);
            }
            // GoStopChoice와 AttackSelect는 별도 패널로 표시됨
        }

        private GameObject CreateCardObject(Transform parent, CardInstance card)
        {
            var obj = new GameObject(card.NameKR);
            obj.transform.SetParent(parent, false);

            // 카드 배경 (MockupSpriteFactory.CreateCardFace 사용)
            var img = obj.AddComponent<Image>();
            var cardTex = MockupSpriteFactory.CreateCardFace(card.Month, card.Type, card.Ribbon);
            img.sprite = MockupSpriteFactory.TextureToSprite(cardTex);
            img.preserveAspect = false;

            var rt = obj.GetComponent<RectTransform>();
            rt.sizeDelta = new Vector2(110, 160);

            // 타입별 상단 바 색상
            Color headerColor = card.Type switch
            {
                CardType.Gwang => new Color(1f, 0.84f, 0f),
                CardType.Tti => card.Ribbon switch
                {
                    RibbonType.HongDan => new Color(0.85f, 0.15f, 0.15f),
                    RibbonType.CheongDan => new Color(0.15f, 0.4f, 0.85f),
                    RibbonType.ChoDan => new Color(0.2f, 0.7f, 0.2f),
                    _ => new Color(0.85f, 0.15f, 0.15f)
                },
                CardType.Yeolkkeut => new Color(0.3f, 0.7f, 0.9f),
                _ => new Color(0.55f, 0.55f, 0.55f)
            };

            // 상단 색상 바 (월 표시 헤더)
            var headerObj = new GameObject("Header");
            headerObj.transform.SetParent(obj.transform, false);
            var headerImg = headerObj.AddComponent<Image>();
            headerImg.color = headerColor;
            headerImg.raycastTarget = false;
            var headerRt = headerObj.GetComponent<RectTransform>();
            headerRt.anchorMin = new Vector2(0, 1);
            headerRt.anchorMax = new Vector2(1, 1);
            headerRt.pivot = new Vector2(0.5f, 1);
            headerRt.anchoredPosition = Vector2.zero;
            headerRt.sizeDelta = new Vector2(0, 32);

            // 월 텍스트 (헤더 위)
            var monthObj = new GameObject("Month");
            monthObj.transform.SetParent(headerObj.transform, false);
            var monthText = monthObj.AddComponent<TextMeshProUGUI>();
            var kf1 = MockupSceneBuilder.GetKoreanFont();
            if (kf1 != null) monthText.font = kf1;
            monthText.text = $"{(int)card.Month}월";
            monthText.fontSize = 18;
            monthText.fontStyle = FontStyles.Bold;
            monthText.alignment = TextAlignmentOptions.Center;
            monthText.color = card.Type == CardType.Gwang ? new Color(0.15f, 0.1f, 0f) : Color.white;
            monthText.raycastTarget = false;
            var monthRt = monthObj.GetComponent<RectTransform>();
            monthRt.anchorMin = Vector2.zero;
            monthRt.anchorMax = Vector2.one;
            monthRt.offsetMin = Vector2.zero;
            monthRt.offsetMax = Vector2.zero;

            // 타입 배지 (중앙 — 색상 배경 + 텍스트)
            string typeLabel = card.Type switch
            {
                CardType.Gwang => "광",
                CardType.Tti => card.Ribbon switch
                {
                    RibbonType.HongDan => "홍",
                    RibbonType.CheongDan => "청",
                    RibbonType.ChoDan => "초",
                    _ => "띠"
                },
                CardType.Yeolkkeut => "열",
                CardType.Pi => card.IsDoublePi ? "쌍피" : "피",
                _ => "?"
            };

            // 배지 배경
            var badgeObj = new GameObject("Badge");
            badgeObj.transform.SetParent(obj.transform, false);
            var badgeImg = badgeObj.AddComponent<Image>();
            badgeImg.color = new Color(headerColor.r, headerColor.g, headerColor.b, 0.85f);
            badgeImg.raycastTarget = false;
            var badgeRt = badgeObj.GetComponent<RectTransform>();
            badgeRt.anchoredPosition = new Vector2(0, -8);
            badgeRt.sizeDelta = new Vector2(60, 32);

            // 배지 텍스트
            var typeObj = new GameObject("Type");
            typeObj.transform.SetParent(badgeObj.transform, false);
            var typeText = typeObj.AddComponent<TextMeshProUGUI>();
            var kf2 = MockupSceneBuilder.GetKoreanFont();
            if (kf2 != null) typeText.font = kf2;
            typeText.text = typeLabel;
            typeText.fontSize = 18;
            typeText.fontStyle = FontStyles.Bold;
            typeText.alignment = TextAlignmentOptions.Center;
            typeText.color = card.Type == CardType.Gwang ? new Color(0.15f, 0.1f, 0f) : Color.white;
            typeText.raycastTarget = false;
            var typeRt = typeObj.GetComponent<RectTransform>();
            typeRt.anchorMin = Vector2.zero;
            typeRt.anchorMax = Vector2.one;
            typeRt.offsetMin = Vector2.zero;
            typeRt.offsetMax = Vector2.zero;

            // 점수 텍스트 (하단)
            var ptObj = new GameObject("Points");
            ptObj.transform.SetParent(obj.transform, false);
            var ptText = ptObj.AddComponent<TextMeshProUGUI>();
            var kf3 = MockupSceneBuilder.GetKoreanFont();
            if (kf3 != null) ptText.font = kf3;
            ptText.text = $"{card.BasePoints}";
            ptText.fontSize = 16;
            ptText.fontStyle = FontStyles.Bold;
            ptText.alignment = TextAlignmentOptions.Center;
            ptText.color = new Color(0.35f, 0.3f, 0.25f);
            ptText.raycastTarget = false;
            var ptRt = ptObj.GetComponent<RectTransform>();
            ptRt.anchoredPosition = new Vector2(0, -55);
            ptRt.sizeDelta = new Vector2(90, 25);

            return obj;
        }

        #endregion

        #region 인터랙션

        private void OnCardClicked(CardInstance card)
        {
            if (_game.CurrentState != GameState.InRound) return;
            if (_game.RoundManager == null) return;

            var phase = _game.RoundManager.CurrentPhase;

            if (phase == RoundManager.Phase.SelectCards)
            {
                // 시너지 페이즈: 카드 선택/해제 토글 (최대 5장)
                if (_selectedCards.Contains(card))
                {
                    _selectedCards.Remove(card);
                }
                else if (_selectedCards.Count < 5)
                {
                    _selectedCards.Add(card);
                }
                else
                {
                    ShowMessage("최대 5장까지 선택 가능!");
                    return;
                }
                RefreshGameUI();
            }
            else if (phase == RoundManager.Phase.AttackSelect)
            {
                // 공격 페이즈: 2장 선택 토글
                if (_selectedCards.Contains(card))
                {
                    _selectedCards.Remove(card);
                }
                else if (_selectedCards.Count < 2)
                {
                    _selectedCards.Add(card);
                }
                else
                {
                    // 2장 이미 선택 → 첫 번째를 교체
                    _selectedCards.RemoveAt(0);
                    _selectedCards.Add(card);
                }

                // 2장 선택 시 섯다 미리보기
                if (_selectedCards.Count == 2)
                {
                    var preview = SeotdaChallenge.Evaluate(_selectedCards[0], _selectedCards[1]);
                    var rm = _game.RoundManager;
                    float goMult = rm.GoCount switch { 1 => 2f, 2 => 4f, >= 3 => 10f, _ => 1f };
                    int baseDmg = preview.Rank switch
                    {
                        100 => 80, 99 => 70, 98 => 65, 95 => 60,
                        >= 90 => 50, >= 80 => 30 + (preview.Rank - 80) * 2,
                        75 => 35, 74 => 30, 73 => 28, 72 => 25, 71 => 22, 70 => 20,
                        >= 7 => 10 + preview.Rank, >= 1 => 5 + preview.Rank,
                        0 => 3, _ => 3
                    };
                    int finalDmg = (int)((baseDmg + rm.AccumulatedChips) * rm.AccumulatedMult * goMult);
                    ShowMessage($"[{preview.Name}] 기본 {baseDmg} + 칩 {rm.AccumulatedChips} x {rm.AccumulatedMult:F1} x 고 {goMult:F0} = {finalDmg}");
                }
                RefreshGameUI();
            }
        }

        /// <summary>
        /// "내기!" 실행: 선택한 카드를 RoundManager에 제출
        /// </summary>
        private void SubmitSelectedCards()
        {
            if (_game.RoundManager == null) return;
            if (_selectedCards.Count == 0)
            {
                ShowMessage("카드를 1장 이상 선택해야 한다!");
                return;
            }

            var combos = _game.RoundManager.SubmitCards(new System.Collections.Generic.List<CardInstance>(_selectedCards));
            _selectedCards.Clear();

            // 콤보 결과 표시
            if (combos.Count > 0)
            {
                string comboDisplay = "";
                foreach (var c in combos)
                    comboDisplay += $"{c.NameKR} -- 칩 +{c.Chips}, 배수 x{c.Mult:F1}\n";
                ShowMessage(comboDisplay.TrimEnd());

                // 콤보 이펙트
                if (_effects != null)
                    _effects.PlayMatchEffect(new Vector2(0, 180), combos.Count >= 2);
            }
            else
            {
                ShowMessage("콤보 없음...");
            }

            // 페이즈 체크 후 UI 갱신
            var phase = _game.RoundManager.CurrentPhase;
            if (phase == RoundManager.Phase.GoStopChoice)
            {
                // Go/Stop 패널 재빌드 및 표시
                if (_goStopPanel != null) Object.Destroy(_goStopPanel);
                BuildGoStopPanel();
                _goStopPanel.SetActive(true);
            }
            else if (phase == RoundManager.Phase.AttackSelect)
            {
                // 강제 스톱 → 공격 페이즈
                ShowAttackPhaseUI();
            }

            RefreshGameUI();
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

            // 보스 생존 여부 판단
            bool dealt = _game.CurrentBattle != null && _game.CurrentBattle.BossCurrentHP < _game.CurrentBattle.BossMaxHP;
            bool bossAlive = _game.CurrentBattle != null && !_game.CurrentBattle.IsBossDefeated;
            bool hasMoreRounds = _game.CurrentRoundInRealm < _game.TotalRoundsInRealm;

            if (bossAlive && hasMoreRounds)
            {
                if (dealt)
                {
                    // 타격 성공, 보스 아직 살아있음 → 다음 판
                    string hpInfo = _game.CurrentBattle != null ? _game.CurrentBattle.GetHPDisplay() : "";
                    ShowMessage($"타격! 보스 {hpInfo} | 다음 판 준비...");
                }
                else
                {
                    // 타격 실패했지만 라운드 남음
                    ShowMessage("다시 치자! 다음 판 준비...");
                }

                CreateButton(_actionButtonsPanel.transform, L.Get("next_round"), new Vector2(0, 0), () =>
                {
                    ClearActionButtons();
                    _game.StartNextRound();
                    RefreshGameUI();
                }, dealt ? new Color(0.08f, 0.4f, 0.08f) : new Color(0.55f, 0.25f, 0.08f));
            }
            else if (bossAlive && !hasMoreRounds && _game.Player.Lives > 0)
            {
                // 라운드 다 소진했지만 목숨 남음 → 재도전
                ShowMessage("마지막 기회다... 다시 도전!");

                CreateButton(_actionButtonsPanel.transform, L.Get("retry"), new Vector2(0, 0), () =>
                {
                    ClearActionButtons();
                    _game.StartNextRound();
                    RefreshGameUI();
                }, new Color(0.55f, 0.25f, 0.08f));
            }
            // 보스 격파 or 게임오버는 HandleRoundEnded에서 직접 상태 전환
        }

        private void ShowShopUI()
        {
            ClearActionButtons();
            _actionButtonsPanel = CreatePanel("ShopPanel", _gamePanel.transform, new Color(0.03f, 0.03f, 0.08f, 0.92f));
            var rt = _actionButtonsPanel.GetComponent<RectTransform>();
            rt.anchorMin = new Vector2(0.1f, 0.15f);
            rt.anchorMax = new Vector2(0.9f, 0.85f);
            rt.offsetMin = Vector2.zero;
            rt.offsetMax = Vector2.zero;

            CreateText(_actionButtonsPanel.transform, L.Get("shop"), 30,
                new Vector2(0, 230), ColGold);

            // Decorative separator under title
            var shopSep = new GameObject("ShopSep");
            shopSep.transform.SetParent(_actionButtonsPanel.transform, false);
            var shopSepImg = shopSep.AddComponent<Image>();
            shopSepImg.color = new Color(ColGold.r, ColGold.g, ColGold.b, 0.25f);
            shopSepImg.raycastTarget = false;
            var shopSepRt = shopSep.GetComponent<RectTransform>();
            shopSepRt.anchoredPosition = new Vector2(0, 205);
            shopSepRt.sizeDelta = new Vector2(350, 2);

            CreateText(_actionButtonsPanel.transform, L.Get("shop_greeting"), 16,
                new Vector2(0, 185), ColDim);
            CreateText(_actionButtonsPanel.transform, L.Get("yeop_display", _game.Player.Yeop), 18,
                new Vector2(0, 155), ColSoftWhite);

            // 상점 아이템 버튼 - alternating backgrounds
            var stock = _game.Shop.CurrentStock;
            for (int i = 0; i < stock.Count; i++)
            {
                var item = stock[i];
                int idx = i;
                string label = item.IsSold ? $"[{L.Get("buy")}완료]" :
                    $"{item.NameKR}  ({item.Cost} {L.Get("yeop")})";
                float yPos = 80 - i * 55;

                Color btnColor = item.IsSold ? new Color(0.15f, 0.15f, 0.18f) :
                    (item.TalismanData != null ? new Color(0.15f, 0.25f, 0.45f) : new Color(0.2f, 0.35f, 0.2f));

                // Alternate slightly for visual distinction
                if (!item.IsSold && i % 2 == 1)
                    btnColor = new Color(btnColor.r + 0.04f, btnColor.g + 0.04f, btnColor.b + 0.04f);

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
            }, new Color(0.45f, 0.25f, 0.05f));

            // 나가기 버튼
            CreateButton(_actionButtonsPanel.transform, L.Get("next_realm") + " ▶", new Vector2(150, -200), () =>
            {
                ClearActionButtons();
                _game.LeaveShop();
            }, new Color(0.08f, 0.4f, 0.08f));
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

            _actionButtonsPanel = CreatePanel("EventPanel", _gamePanel.transform, new Color(0.03f, 0.03f, 0.08f, 0.92f));
            var rt = _actionButtonsPanel.GetComponent<RectTransform>();
            rt.anchorMin = new Vector2(0.1f, 0.1f);
            rt.anchorMax = new Vector2(0.9f, 0.9f);
            rt.offsetMin = Vector2.zero;
            rt.offsetMax = Vector2.zero;

            CreateText(_actionButtonsPanel.transform, evt.TitleKR, 32,
                new Vector2(0, 250), ColGold);
            CreateText(_actionButtonsPanel.transform, evt.DescriptionKR, 18,
                new Vector2(0, 160), ColSoftWhite);

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
                    }, new Color(0.08f, 0.4f, 0.08f));
                }, new Color(0.18f, 0.18f, 0.35f));
            }
        }

        private void ShowGameOverButtons()
        {
            ClearActionButtons();
            _actionButtonsPanel = CreatePanel("ActionButtons", _gamePanel.transform, new Color(0.03f, 0.02f, 0.05f, 0.95f));
            var rt = _actionButtonsPanel.GetComponent<RectTransform>();
            rt.anchorMin = new Vector2(0.15f, 0.15f);
            rt.anchorMax = new Vector2(0.85f, 0.85f);
            rt.offsetMin = Vector2.zero;
            rt.offsetMax = Vector2.zero;

            // Dark background panel behind title
            var gameOverBg = CreatePanel("GameOverTitleBg", _actionButtonsPanel.transform,
                new Color(ColBloodRed.r, ColBloodRed.g, ColBloodRed.b, 0.4f));
            var goBgRt = gameOverBg.GetComponent<RectTransform>();
            goBgRt.anchorMin = new Vector2(0.5f, 0.5f);
            goBgRt.anchorMax = new Vector2(0.5f, 0.5f);
            goBgRt.anchoredPosition = new Vector2(0, 190);
            goBgRt.sizeDelta = new Vector2(500, 60);

            CreateText(_actionButtonsPanel.transform, L.Get("game_over"), 40,
                new Vector2(0, 190), ColCrimson);
            CreateText(_actionButtonsPanel.transform, L.Get("soul_display", _game.Upgrades.SoulFragments), 24,
                new Vector2(0, 120), ColSoftWhite);
            CreateText(_actionButtonsPanel.transform,
                L.Get("total_cleared", _game.Spiral.TotalRealmsCleared), 20,
                new Vector2(0, 80), ColDim);

            // 영구 강화 버튼
            CreateButton(_actionButtonsPanel.transform, L.Get("permanent_upgrade"), new Vector2(0, 10), () =>
            {
                ClearActionButtons();
                ShowUpgradeTreeUI();
            }, new Color(0.35f, 0.1f, 0.5f));

            // 다시 도전
            CreateButton(_actionButtonsPanel.transform, L.Get("retry"), new Vector2(0, -70), () =>
            {
                ClearActionButtons();
                _game.StartNewGame();
                // SpiralStart에서 축복 선택 UI 표시됨
            }, ColCrimson);

            // 메인 메뉴
            CreateButton(_actionButtonsPanel.transform, L.Get("main_menu"), new Vector2(0, -150), () =>
            {
                ClearActionButtons();
                BuildMainMenu();
            }, new Color(0.15f, 0.15f, 0.22f));
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
                    _selectedCards.Clear();
                    RefreshGameUI();
                    // 튜토리얼 오버레이
                    if (_tutorial != null && _tutorial.IsActive)
                        ShowTutorialOverlay();
                    break;

                case GameState.PostRound:
                    RefreshGameUI();
                    {
                        bool bossDefeated = _game.CurrentBattle != null && _game.CurrentBattle.IsBossDefeated;
                        bool playerAlive = _game.Player.Lives > 0;

                        if (bossDefeated)
                        {
                            // 보스 격파! → 웨이브 강화 UI 또는 상점으로
                            if (_game.WaveUpgrades.CurrentChoices.Count > 0)
                                ShowWaveUpgradeUI();
                            // Gate 상태는 HandleStateChange(Gate)에서 처리
                        }
                        else if (playerAlive)
                        {
                            // 보스 살아있음 → 다음 판 버튼
                            ShowPostRoundButtons();
                        }
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

        private void ShowAttackPhaseUI()
        {
            _selectedCards.Clear();

            // 메시지
            ShowMessage("공격할 2장을 손패에서 골라라!");

            // 선택 카운트 라벨 업데이트
            if (_selectionCountText != null)
                _selectionCountText.text = "공격 카드: 0/2장";

            // 손패를 공격 모드로 갱신
            RefreshHandCards();

            // 공격 패널 표시
            ClearActionButtons();
            _actionButtonsPanel = CreatePanel("AttackPanel", _gamePanel.transform, new Color(0.04f, 0.03f, 0.08f, 0.9f));
            var rt = _actionButtonsPanel.GetComponent<RectTransform>();
            rt.anchorMin = new Vector2(0.1f, 0.35f);
            rt.anchorMax = new Vector2(0.9f, 0.65f);
            rt.offsetMin = Vector2.zero;
            rt.offsetMax = Vector2.zero;

            CreateText(_actionButtonsPanel.transform, "섯다 공격 — 2장을 선택하세요", 26,
                new Vector2(0, 100), ColGold);

            // 누적 시너지 표시
            if (_game.RoundManager != null)
            {
                var rm = _game.RoundManager;
                CreateText(_actionButtonsPanel.transform,
                    $"누적 시너지: 칩 {rm.AccumulatedChips} x 배수 {rm.AccumulatedMult:F1}", 18,
                    new Vector2(0, 60), new Color(0.3f, 1f, 0.5f));
            }

            // 보스 HP 표시
            if (_game.CurrentBattle != null)
                CreateText(_actionButtonsPanel.transform, $"보스 {_game.CurrentBattle.GetHPDisplay()}", 18,
                    new Vector2(0, 30), ColCrimson);

            var attackBtn = CreateButton(_actionButtonsPanel.transform, "공격!", new Vector2(0, -50), () =>
            {
                if (_selectedCards.Count != 2)
                {
                    ShowMessage("정확히 2장을 선택해야 한다!");
                    return;
                }

                var result = _game.SeotdaAttack(_selectedCards[0], _selectedCards[1]);
                _selectedCards.Clear();

                // 공격 결과 표시
                ShowMessage($"[{result.SeotdaName}] 기본 {result.BaseDamage} + 칩 {result.AccumulatedChips} " +
                    $"x {result.AccumulatedMult:F1} x 고 {result.GoMult:F0} = {result.FinalDamage} 타격!");

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

                // 공격 후 상태에 따라 UI 분기
                bool bossIsDead = _game.CurrentBattle != null && _game.CurrentBattle.IsBossDefeated;

                if (bossIsDead)
                {
                    // 보스 격파 이펙트
                    if (_effects != null)
                        _effects.PlayBossDefeatEffect(
                            _game.CurrentBoss?.DisplayName ?? "보스", new Vector2(0, 300));
                    ShowMessage($"{_game.CurrentBoss?.DisplayName} 격파!");

                    // 상태에 따라 다음 화면 결정
                    if (_game.CurrentState == GameState.Gate)
                    {
                        _gatePanel?.SetActive(true);
                    }
                    else if (_game.CurrentState == GameState.Shop)
                    {
                        ShowShopUI();
                    }
                    else
                    {
                        if (_game.WaveUpgrades.CurrentChoices.Count > 0)
                        {
                            ShowWaveUpgradeUI();
                        }
                        else
                        {
                            ClearActionButtons();
                            _actionButtonsPanel = CreatePanel("BossDefeated", _gamePanel.transform, new Color(0, 0, 0, 0.85f));
                            var defeatRt = _actionButtonsPanel.GetComponent<RectTransform>();
                            defeatRt.anchorMin = new Vector2(0.2f, 0.3f);
                            defeatRt.anchorMax = new Vector2(0.8f, 0.7f);
                            defeatRt.offsetMin = Vector2.zero;
                            defeatRt.offsetMax = Vector2.zero;

                            CreateText(_actionButtonsPanel.transform, "관문 돌파!", 36,
                                new Vector2(0, 80), ColGold);
                            CreateText(_actionButtonsPanel.transform,
                                $"{_game.CurrentBoss?.DisplayName} 격파", 20,
                                new Vector2(0, 30), ColSoftWhite);

                            CreateButton(_actionButtonsPanel.transform, "다음으로", new Vector2(0, -60), () =>
                            {
                                ClearActionButtons();
                                _game.OpenShop();
                            }, new Color(0.15f, 0.5f, 0.15f));
                        }
                    }
                }
                else if (_game.CurrentState == GameState.PostRound)
                {
                    ShowPostRoundButtons();
                }
                else if (_game.CurrentState == GameState.GameOver)
                {
                    ShowGameOverButtons();
                }
            }, new Color(0.8f, 0.1f, 0.05f));
            attackBtn.GetComponent<RectTransform>().sizeDelta = new Vector2(200, 60);

            if (_game.RoundManager != null && _game.RoundManager.HandCards.Count < 2)
            {
                CreateText(_actionButtonsPanel.transform, "손패가 부족하다... 시너지만으로 종료!", 18,
                    new Vector2(0, -55), ColCrimson);

                // 공격 불가 시 시너지만으로 라운드 종료 버튼
                CreateButton(_actionButtonsPanel.transform, "판 마무리", new Vector2(0, -100), () =>
                {
                    // 시너지 칩/멀트로만 데미지 계산
                    var rm = _game.RoundManager;
                    int synergyDamage = (int)(rm.AccumulatedChips * rm.AccumulatedMult);
                    if (synergyDamage > 0 && _game.CurrentBattle != null)
                    {
                        _game.CurrentBattle.DealDamage(new ScoringEngine.ScoreResult
                        {
                            FinalScore = synergyDamage
                        });
                        ShowMessage($"시너지만으로 {synergyDamage} 타격!");
                    }
                    else
                    {
                        ShowMessage("타격 없이 판 종료...");
                    }
                    rm.FinishRound(synergyDamage > 0);
                    ClearActionButtons();
                    RefreshGameUI();

                    // 결과에 따라 UI 분기
                    if (_game.CurrentState == GameState.PostRound)
                        ShowPostRoundButtons();
                    else if (_game.CurrentState == GameState.GameOver)
                        ShowGameOverButtons();
                    else if (_game.CurrentState == GameState.Gate)
                        _gatePanel?.SetActive(true);
                }, new Color(0.5f, 0.35f, 0.05f));
            }
        }

        #endregion

        #region 축복 선택 UI

        private void ShowBlessingSelectionUI()
        {
            ClearActionButtons();
            _actionButtonsPanel = CreatePanel("BlessingPanel", _gamePanel != null ? _gamePanel.transform : _root,
                new Color(0.03f, 0.03f, 0.08f, 0.95f));
            var rt = _actionButtonsPanel.GetComponent<RectTransform>();
            rt.anchorMin = Vector2.zero;
            rt.anchorMax = Vector2.one;
            rt.offsetMin = Vector2.zero;
            rt.offsetMax = Vector2.zero;

            CreateText(_actionButtonsPanel.transform, L.Get("blessing_title"), 34,
                new Vector2(0, 300), ColGold);
            CreateText(_actionButtonsPanel.transform,
                $"{L.Get("spiral")} {_game.Spiral.CurrentSpiral}", 22,
                new Vector2(0, 250), new Color(0.6f, 0.6f, 0.75f));

            var blessings = SpiralBlessing.GetAll();
            for (int i = 0; i < blessings.Count; i++)
            {
                var b = blessings[i];
                float yPos = 140 - i * 95;
                string label = $"{b.NameKR}\n{b.BonusDesc} / {b.PenaltyDesc}";

                Color btnColor = b.Id switch
                {
                    "fire" => new Color(0.55f, 0.1f, 0.05f),
                    "ice" => new Color(0.05f, 0.2f, 0.55f),
                    "void" => new Color(0.3f, 0.08f, 0.5f),
                    "chaos" => new Color(0.5f, 0.38f, 0.05f),
                    _ => new Color(0.2f, 0.2f, 0.25f)
                };

                Color borderColor = b.Id switch
                {
                    "fire" => new Color(1f, 0.3f, 0.1f),
                    "ice" => new Color(0.3f, 0.6f, 1f),
                    "void" => new Color(0.7f, 0.3f, 1f),
                    "chaos" => new Color(1f, 0.8f, 0.2f),
                    _ => ColDim
                };

                var blessingRef = b;
                var btn = CreateButton(_actionButtonsPanel.transform, label, new Vector2(0, yPos), () =>
                {
                    ClearActionButtons();
                    if (_gamePanel == null) BuildGameScreen();
                    _game.BeginSpiralWithBlessing(blessingRef);
                }, btnColor);
                btn.GetComponent<RectTransform>().sizeDelta = new Vector2(550, 80);

                // Add thin colored left border to blessing card
                AddLeftBorder(btn.gameObject, borderColor, 5);
            }

            // 거부 버튼
            CreateButton(_actionButtonsPanel.transform, L.Get("blessing_skip"), new Vector2(0, -260), () =>
            {
                ClearActionButtons();
                if (_gamePanel == null) BuildGameScreen();
                _game.BeginSpiralWithBlessing(null);
            }, new Color(0.2f, 0.2f, 0.25f));
        }

        #endregion

        #region 영구 강화 UI

        private void ShowUpgradeTreeUI()
        {
            ClearActionButtons();
            _actionButtonsPanel = CreatePanel("UpgradeTree", _mainMenuPanel != null ? _mainMenuPanel.transform : _root,
                new Color(0.03f, 0.03f, 0.08f, 0.95f));
            var rt = _actionButtonsPanel.GetComponent<RectTransform>();
            rt.anchorMin = Vector2.zero;
            rt.anchorMax = Vector2.one;
            rt.offsetMin = Vector2.zero;
            rt.offsetMax = Vector2.zero;

            CreateText(_actionButtonsPanel.transform, L.Get("permanent_upgrade"), 32,
                new Vector2(0, 360), ColGold);
            CreateText(_actionButtonsPanel.transform, L.Get("soul_display", _game.Upgrades.SoulFragments), 22,
                new Vector2(0, 315), ColSoftWhite);

            // 3갈래 트리 타이틀
            CreateText(_actionButtonsPanel.transform, L.Get("path_card"), 21,
                new Vector2(-350, 270), ColCyan);
            CreateText(_actionButtonsPanel.transform, L.Get("path_talisman"), 21,
                new Vector2(0, 270), ColPurple);
            CreateText(_actionButtonsPanel.transform, L.Get("path_survival"), 21,
                new Vector2(350, 270), new Color(0.3f, 0.9f, 0.5f));

            // 강화 목록
            int cardY = 210, talY = 210, survY = 210;
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
                        xPos = -350; yPos = cardY; cardY -= 55;
                        break;
                    case UpgradePath.Talisman:
                        xPos = 0; yPos = talY; talY -= 55;
                        break;
                    default:
                        xPos = 350; yPos = survY; survY -= 55;
                        break;
                }

                Color btnColor = maxed ? new Color(0.15f, 0.15f, 0.18f) :
                    (canBuy ? new Color(0.15f, 0.35f, 0.45f) : new Color(0.1f, 0.1f, 0.15f));

                var upgId = upg.Id;
                var btn = CreateButton(_actionButtonsPanel.transform, label, new Vector2(xPos, yPos), () =>
                {
                    if (_game.Upgrades.Purchase(upgId))
                    {
                        ShowMessage($"{upg.NameKR} 강화!");
                        ShowUpgradeTreeUI(); // 새로고침
                    }
                }, btnColor);
                btn.GetComponent<RectTransform>().sizeDelta = new Vector2(300, 48);
                var labelTmp = btn.GetComponentInChildren<TextMeshProUGUI>();
                if (labelTmp != null) labelTmp.fontSize = 15;
            }

            // 돌아가기 버튼
            CreateButton(_actionButtonsPanel.transform, L.Get("main_menu"), new Vector2(0, -380), () =>
            {
                ClearActionButtons();
                if (_game.CurrentState == GameState.GameOver)
                    ShowGameOverButtons();
                else
                    BuildMainMenu();
            }, new Color(0.2f, 0.2f, 0.3f));
        }

        #endregion

        #region 웨이브 강화 UI

        private void ShowWaveUpgradeUI()
        {
            ClearActionButtons();
            _actionButtonsPanel = CreatePanel("WaveUpgrade", _gamePanel.transform, new Color(0.03f, 0.03f, 0.08f, 0.93f));
            var rt = _actionButtonsPanel.GetComponent<RectTransform>();
            rt.anchorMin = new Vector2(0.05f, 0.1f);
            rt.anchorMax = new Vector2(0.95f, 0.9f);
            rt.offsetMin = Vector2.zero;
            rt.offsetMax = Vector2.zero;

            CreateText(_actionButtonsPanel.transform, L.Get("wave_upgrade_title"), 32,
                new Vector2(0, 260), ColGold);

            var choices = _game.WaveUpgrades.CurrentChoices;
            for (int i = 0; i < choices.Count; i++)
            {
                var c = choices[i];
                int idx = i;
                float xPos = (i - 1) * 280; // -280, 0, 280

                Color cardColor = c.Category switch
                {
                    "card" => new Color(0.12f, 0.25f, 0.5f),
                    "talisman" => new Color(0.4f, 0.12f, 0.55f),
                    "survival" => new Color(0.12f, 0.4f, 0.2f),
                    _ => new Color(0.4f, 0.3f, 0.1f)
                };

                // 카드 형태 버튼
                var cardPanel = CreatePanel($"Choice_{i}", _actionButtonsPanel.transform, cardColor);
                var cardRt = cardPanel.GetComponent<RectTransform>();
                cardRt.anchorMin = new Vector2(0.5f, 0.5f);
                cardRt.anchorMax = new Vector2(0.5f, 0.5f);
                cardRt.anchoredPosition = new Vector2(xPos, 0);
                cardRt.sizeDelta = new Vector2(240, 300);

                CreateText(cardPanel.transform, c.NameKR, 24, new Vector2(0, 100), ColGold);
                CreateText(cardPanel.transform, c.DescKR, 16, new Vector2(0, 30), ColSoftWhite);

                var btn = cardPanel.AddComponent<Button>();
                var cardImg = cardPanel.GetComponent<Image>();
                if (cardImg != null) cardImg.raycastTarget = true; // 클릭 가능하게
                btn.targetGraphic = cardImg;
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
            _actionButtonsPanel = CreatePanel("ForgePanel", _gamePanel.transform, new Color(0.03f, 0.03f, 0.08f, 0.93f));
            var rt = _actionButtonsPanel.GetComponent<RectTransform>();
            rt.anchorMin = new Vector2(0.1f, 0.1f);
            rt.anchorMax = new Vector2(0.9f, 0.9f);
            rt.offsetMin = Vector2.zero;
            rt.offsetMax = Vector2.zero;

            CreateText(_actionButtonsPanel.transform, L.Get("forge"), 30,
                new Vector2(0, 300), new Color(1f, 0.55f, 0.15f));
            CreateText(_actionButtonsPanel.transform, L.Get("forge_desc"), 16,
                new Vector2(0, 260), ColDim);
            CreateText(_actionButtonsPanel.transform, L.Get("yeop_display", _game.Player.Yeop), 18,
                new Vector2(0, 230), ColSoftWhite);

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

                Color btnColor = maxed ? new Color(0.15f, 0.15f, 0.18f) :
                    (_game.Player.Yeop >= cost ? new Color(0.4f, 0.25f, 0.08f) : new Color(0.15f, 0.15f, 0.18f));

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
                    new Vector2(0, 50), ColDim);
            }

            // 돌아가기
            CreateButton(_actionButtonsPanel.transform, L.Get("shop") + " ▶", new Vector2(0, -300), () =>
            {
                ShowShopUI();
            }, new Color(0.2f, 0.2f, 0.3f));
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
                    ? new Color(0.1f, 0.4f, 0.35f)
                    : new Color(0.2f, 0.2f, 0.25f);

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
            _actionButtonsPanel = CreatePanel("CollectionPanel", parent, new Color(0.03f, 0.03f, 0.08f, 0.95f));
            var rt = _actionButtonsPanel.GetComponent<RectTransform>();
            rt.anchorMin = Vector2.zero;
            rt.anchorMax = Vector2.one;
            rt.offsetMin = Vector2.zero;
            rt.offsetMax = Vector2.zero;

            CreateText(_actionButtonsPanel.transform, L.Get("collection_title"), 32,
                new Vector2(0, 360), ColGold);

            // 업적 진행
            CreateText(_actionButtonsPanel.transform,
                L.Get("achievement_progress",
                    _game.Achievements.GetUnlockedCount(),
                    _game.Achievements.GetTotalCount()),
                22, new Vector2(0, 310), ColSoftWhite);

            int yPos = 250;
            foreach (var ach in _game.Achievements.AllAchievements)
            {
                bool unlocked = _game.Achievements.IsUnlocked(ach.Id);
                string display = ach.IsHidden && !unlocked
                    ? "??? — ???"
                    : $"{(unlocked ? "V " : "  ")}{ach.NameKR} — {ach.DescriptionKR} (+{ach.SoulReward})";

                Color col = unlocked ? new Color(0.3f, 1f, 0.5f) : ColDim;
                CreateText(_actionButtonsPanel.transform, display, 15,
                    new Vector2(0, yPos), col);
                yPos -= 28;
            }

            // 돌아가기
            CreateButton(_actionButtonsPanel.transform, L.Get("main_menu"), new Vector2(0, -380), () =>
            {
                ClearActionButtons();
                BuildMainMenu();
            }, new Color(0.2f, 0.2f, 0.3f));
        }

        #endregion

        #region 튜토리얼 UI

        private void ShowTutorialOverlay()
        {
            if (_tutorialOverlay != null) Object.Destroy(_tutorialOverlay);
            if (_tutorial == null || !_tutorial.IsActive) return;

            _tutorialOverlay = CreatePanel("TutorialOverlay", _gamePanel.transform, new Color(0.03f, 0.03f, 0.08f, 0.75f));
            var rt = _tutorialOverlay.GetComponent<RectTransform>();
            rt.anchorMin = new Vector2(0, 0.7f);
            rt.anchorMax = new Vector2(1, 1);
            rt.offsetMin = Vector2.zero;
            rt.offsetMax = Vector2.zero;

            // 뱃사공 대사
            CreateText(_tutorialOverlay.transform, L.Get("tutorial_boatman"), 14,
                new Vector2(-300, 60), ColCyan);

            CreateText(_tutorialOverlay.transform, L.Get(_tutorial.CurrentDialogue), 18,
                new Vector2(0, 30), ColSoftWhite);

            // 힌트
            CreateText(_tutorialOverlay.transform, L.Get(_tutorial.CurrentHint), 16,
                new Vector2(0, -30), ColGold);

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
            }, new Color(0.08f, 0.4f, 0.08f));

            CreateButton(_tutorialOverlay.transform, L.Get("tutorial_skip"), new Vector2(-200, -60), () =>
            {
                _tutorial.Skip();
                PlayerPrefs.SetInt("tutorial_done", 1);
                _game.IsTutorialMode = false;
                if (_tutorialOverlay != null) Object.Destroy(_tutorialOverlay);
            }, ColBloodRed);
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
                img.type = Image.Type.Sliced;
                img.sprite = MockupSpriteFactory.GetPanelSprite();
                img.color = new Color(
                    bgColor.r / 0.08f * 1f,
                    bgColor.g / 0.08f * 1f,
                    bgColor.b / 0.16f * 1f,
                    bgColor.a);
                // 보정: 스프라이트 색이 곱해지므로 원하는 색에 맞게 조정
                img.color = bgColor;
                img.raycastTarget = false; // 패널 배경이 하위 버튼 클릭을 방해하지 않도록
            }

            return obj;
        }

        /// <summary>
        /// Adds a colored left border strip to a panel for visual distinction.
        /// </summary>
        private void AddLeftBorder(GameObject target, Color borderColor, float width = 4f)
        {
            var borderObj = new GameObject("LeftBorder");
            borderObj.transform.SetParent(target.transform, false);
            var borderImg = borderObj.AddComponent<Image>();
            borderImg.color = borderColor;
            borderImg.raycastTarget = false;
            var borderRt = borderObj.GetComponent<RectTransform>();
            borderRt.anchorMin = new Vector2(0, 0);
            borderRt.anchorMax = new Vector2(0, 1);
            borderRt.pivot = new Vector2(0, 0.5f);
            borderRt.offsetMin = Vector2.zero;
            borderRt.offsetMax = Vector2.zero;
            borderRt.sizeDelta = new Vector2(width, 0);
        }

        /// <summary>
        /// Adds a thin border around a panel.
        /// </summary>
        private void AddPanelBorder(GameObject panel, Color borderColor, float thickness = 2f)
        {
            // Top
            var topObj = new GameObject("BorderTop");
            topObj.transform.SetParent(panel.transform, false);
            var topImg = topObj.AddComponent<Image>();
            topImg.color = new Color(borderColor.r, borderColor.g, borderColor.b, 0.4f);
            topImg.raycastTarget = false;
            var topRt = topObj.GetComponent<RectTransform>();
            topRt.anchorMin = new Vector2(0, 1);
            topRt.anchorMax = new Vector2(1, 1);
            topRt.pivot = new Vector2(0.5f, 1);
            topRt.sizeDelta = new Vector2(0, thickness);
            topRt.offsetMin = new Vector2(0, 0);
            topRt.offsetMax = new Vector2(0, 0);

            // Bottom
            var botObj = new GameObject("BorderBot");
            botObj.transform.SetParent(panel.transform, false);
            var botImg = botObj.AddComponent<Image>();
            botImg.color = new Color(borderColor.r, borderColor.g, borderColor.b, 0.4f);
            botImg.raycastTarget = false;
            var botRt = botObj.GetComponent<RectTransform>();
            botRt.anchorMin = new Vector2(0, 0);
            botRt.anchorMax = new Vector2(1, 0);
            botRt.pivot = new Vector2(0.5f, 0);
            botRt.sizeDelta = new Vector2(0, thickness);
            botRt.offsetMin = new Vector2(0, 0);
            botRt.offsetMax = new Vector2(0, 0);

            // Left
            var leftObj = new GameObject("BorderLeft");
            leftObj.transform.SetParent(panel.transform, false);
            var leftImg = leftObj.AddComponent<Image>();
            leftImg.color = new Color(borderColor.r, borderColor.g, borderColor.b, 0.3f);
            leftImg.raycastTarget = false;
            var leftRt = leftObj.GetComponent<RectTransform>();
            leftRt.anchorMin = new Vector2(0, 0);
            leftRt.anchorMax = new Vector2(0, 1);
            leftRt.pivot = new Vector2(0, 0.5f);
            leftRt.sizeDelta = new Vector2(thickness, 0);
            leftRt.offsetMin = new Vector2(0, 0);
            leftRt.offsetMax = new Vector2(0, 0);

            // Right
            var rightObj = new GameObject("BorderRight");
            rightObj.transform.SetParent(panel.transform, false);
            var rightImg = rightObj.AddComponent<Image>();
            rightImg.color = new Color(borderColor.r, borderColor.g, borderColor.b, 0.3f);
            rightImg.raycastTarget = false;
            var rightRt = rightObj.GetComponent<RectTransform>();
            rightRt.anchorMin = new Vector2(1, 0);
            rightRt.anchorMax = new Vector2(1, 1);
            rightRt.pivot = new Vector2(1, 0.5f);
            rightRt.sizeDelta = new Vector2(thickness, 0);
            rightRt.offsetMin = new Vector2(0, 0);
            rightRt.offsetMax = new Vector2(0, 0);
        }

        private TextMeshProUGUI CreateText(Transform parent, string text, int fontSize,
            Vector2 position, Color color)
        {
            var obj = new GameObject("Text");
            obj.transform.SetParent(parent, false);

            var tmp = obj.AddComponent<TextMeshProUGUI>();
            var kFont = MockupSceneBuilder.GetKoreanFont();
            if (kFont != null) tmp.font = kFont;
            tmp.text = text;
            tmp.fontSize = fontSize;
            tmp.color = color;
            tmp.alignment = TextAlignmentOptions.Center;
            tmp.enableWordWrapping = true;
            tmp.raycastTarget = false; // 버튼 클릭 방해 방지

            var rt = obj.GetComponent<RectTransform>();
            rt.anchoredPosition = position;
            rt.sizeDelta = new Vector2(1000, fontSize + 14);

            return tmp;
        }

        private Button CreateButton(Transform parent, string label, Vector2 position,
            UnityEngine.Events.UnityAction onClick, Color? bgColor = null)
        {
            var baseColor = bgColor ?? new Color(0.12f, 0.12f, 0.2f);
            Color borderCol = new Color(
                Mathf.Min(baseColor.r + 0.2f, 1f),
                Mathf.Min(baseColor.g + 0.2f, 1f),
                Mathf.Min(baseColor.b + 0.2f, 1f),
                Mathf.Max(baseColor.a, 0.9f));

            var outerObj = new GameObject($"Btn_{label}");
            outerObj.transform.SetParent(parent, false);

            var outerImg = outerObj.AddComponent<Image>();
            outerImg.sprite = MockupSpriteFactory.GetButtonSprite(baseColor, borderCol);
            outerImg.type = Image.Type.Sliced;
            outerImg.color = Color.white; // 스프라이트 자체에 색이 있으므로 white

            var outerRt = outerObj.GetComponent<RectTransform>();
            outerRt.anchoredPosition = position;
            outerRt.sizeDelta = new Vector2(300, 55);

            var btn = outerObj.AddComponent<Button>();
            btn.targetGraphic = outerImg;
            btn.onClick.AddListener(onClick);

            // Color transitions for hover/press
            var colors = btn.colors;
            colors.normalColor = Color.white;
            colors.highlightedColor = new Color(1.15f, 1.15f, 1.2f);
            colors.pressedColor = new Color(0.75f, 0.75f, 0.8f);
            colors.selectedColor = Color.white;
            btn.colors = colors;

            // 라벨
            var textObj = new GameObject("Label");
            textObj.transform.SetParent(outerObj.transform, false);
            var tmp = textObj.AddComponent<TextMeshProUGUI>();
            var kFont = MockupSceneBuilder.GetKoreanFont();
            if (kFont != null) tmp.font = kFont;
            tmp.text = label;
            tmp.fontSize = 22;
            tmp.color = ColSoftWhite;
            tmp.alignment = TextAlignmentOptions.Center;
            tmp.raycastTarget = false; // 버튼 클릭 방해 방지

            var textRt = textObj.GetComponent<RectTransform>();
            textRt.anchorMin = Vector2.zero;
            textRt.anchorMax = Vector2.one;
            textRt.offsetMin = new Vector2(8, 4);
            textRt.offsetMax = new Vector2(-8, -4);

            return btn;
        }

        #endregion
    }
}

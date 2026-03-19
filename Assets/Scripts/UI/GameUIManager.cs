using UnityEngine;
using UnityEngine.UI;
using System.Collections.Generic;
using DokkaebiHand.Cards;
using DokkaebiHand.Combat;
using DokkaebiHand.Core;
using DokkaebiHand.Talismans;
using TMPro;

namespace DokkaebiHand.UI
{
    /// <summary>
    /// 게임 UI 총괄 매니저
    /// 손패/바닥패 표시, 점수 HUD, Go/Stop 버튼, 보스 HP바
    /// </summary>
    public class GameUIManager : MonoBehaviour
    {
        [Header("패널")]
        [SerializeField] private Transform _handPanel;
        [SerializeField] private Transform _fieldPanel;
        [SerializeField] private Transform _capturedPanel;
        [SerializeField] private GameObject _goStopPanel;
        [SerializeField] private GameObject _resultPanel;
        [SerializeField] private GameObject _bossIntroPanel;

        [Header("점수 HUD")]
        [SerializeField] private TextMeshProUGUI _scoreText;
        [SerializeField] private TextMeshProUGUI _multText;
        [SerializeField] private TextMeshProUGUI _targetScoreText;
        [SerializeField] private TextMeshProUGUI _yokboListText;

        [Header("보스")]
        [SerializeField] private TextMeshProUGUI _bossNameText;
        [SerializeField] private Slider _bossProgressBar;
        [SerializeField] private TextMeshProUGUI _bossDialogueText;

        [Header("플레이어 정보")]
        [SerializeField] private TextMeshProUGUI _livesText;
        [SerializeField] private TextMeshProUGUI _yeopText;
        [SerializeField] private TextMeshProUGUI _floorText;

        [Header("부적 슬롯")]
        [SerializeField] private Transform _talismanSlotPanel;

        [Header("메시지")]
        [SerializeField] private TextMeshProUGUI _messageText;
        [SerializeField] private TextMeshProUGUI _gimmickText;

        [Header("프리팹")]
        [SerializeField] private GameObject _cardPrefab;
        [SerializeField] private GameObject _talismanSlotPrefab;

        [Header("Go/Stop")]
        [SerializeField] private Button _goButton;
        [SerializeField] private Button _stopButton;
        [SerializeField] private TextMeshProUGUI _goRiskText;

        // 참조
        private GameManager _gameManager;
        private CardInstance _selectedHandCard;

        private void Awake()
        {
            if (_goButton != null)
                _goButton.onClick.AddListener(OnGoClicked);
            if (_stopButton != null)
                _stopButton.onClick.AddListener(OnStopClicked);
        }

        public void Initialize(GameManager gameManager)
        {
            _gameManager = gameManager;

            _gameManager.OnGameStateChanged += HandleGameStateChanged;
            _gameManager.OnMessage += ShowMessage;
            _gameManager.BossManager.OnBossGimmickTriggered += ShowGimmickMessage;
        }

        #region UI 업데이트

        public void RefreshAll()
        {
            if (_gameManager == null) return;

            RefreshHand();
            RefreshField();
            RefreshScoreHUD();
            RefreshPlayerInfo();
            RefreshTalismanSlots();
            RefreshBossInfo();
        }

        public void RefreshHand()
        {
            if (_handPanel == null) return;

            ClearChildren(_handPanel);

            foreach (var card in _gameManager.Player.Hand)
            {
                var cardObj = CreateCardUI(card, _handPanel);
                var button = cardObj.GetComponent<Button>();
                if (button != null)
                {
                    var capturedCard = card;
                    button.onClick.AddListener(() => OnHandCardClicked(capturedCard));
                }
            }
        }

        public void RefreshField()
        {
            if (_fieldPanel == null) return;

            ClearChildren(_fieldPanel);

            var roundManager = _gameManager.RoundManager;
            if (roundManager == null) return;

            // DeckManager의 FieldCards는 RoundManager를 통해 접근
            // 여기서는 간접적으로 표시
        }

        public void RefreshScoreHUD()
        {
            if (_gameManager.RoundManager == null) return;

            var score = _gameManager.RoundManager.LastScoreResult;
            if (_scoreText != null)
                _scoreText.text = $"칩: {score.Chips}";
            if (_multText != null)
                _multText.text = $"배수: x{score.Mult}";
            if (_targetScoreText != null)
                _targetScoreText.text = $"목표: {_gameManager.RoundManager.TargetScore}";
            if (_yokboListText != null && score.CompletedYokbo != null)
                _yokboListText.text = string.Join("\n", score.CompletedYokbo);
        }

        public void RefreshPlayerInfo()
        {
            var player = _gameManager.Player;
            if (_livesText != null)
                _livesText.text = $"목숨: {player.Lives}";
            if (_yeopText != null)
                _yeopText.text = $"엽전: {player.Yeop}";
            if (_floorText != null)
                _floorText.text = $"{player.CurrentFloor}층";
        }

        public void RefreshBossInfo()
        {
            var boss = _gameManager.BossManager.CurrentBoss;
            if (boss == null) return;

            if (_bossNameText != null)
                _bossNameText.text = boss.NameKR;
        }

        public void RefreshTalismanSlots()
        {
            if (_talismanSlotPanel == null) return;

            ClearChildren(_talismanSlotPanel);

            foreach (var talisman in _gameManager.Player.Talismans)
            {
                if (_talismanSlotPrefab != null)
                {
                    var slot = Instantiate(_talismanSlotPrefab, _talismanSlotPanel);
                    var text = slot.GetComponentInChildren<TextMeshProUGUI>();
                    if (text != null)
                    {
                        text.text = talisman.Data.NameKR;
                        if (!talisman.IsActive)
                            text.color = Color.gray;
                    }
                }
            }
        }

        #endregion

        #region 카드 인터랙션

        private void OnHandCardClicked(CardInstance card)
        {
            if (_gameManager.RoundManager == null) return;
            if (_gameManager.RoundManager.CurrentPhase != RoundManager.RoundPhase.PlayerTurn)
                return;

            _selectedHandCard = card;

            var matchResult = _gameManager.RoundManager.PlayHandCard(card);

            if (matchResult == MatchResult.DoubleMatch)
            {
                // 2장 매칭 → 선택 UI 표시 (간소화: 자동 선택)
                _gameManager.RoundManager.ExecuteHandMatch();
            }
            else
            {
                _gameManager.RoundManager.ExecuteHandMatch();
            }

            // 뒤집기
            var drawn = _gameManager.RoundManager.FlipDrawCard();
            if (drawn != null)
            {
                _gameManager.RoundManager.ExecuteDrawMatch();
            }

            RefreshAll();
        }

        private void OnGoClicked()
        {
            if (_gameManager.RoundManager == null) return;

            var risk = _gameManager.RoundManager.SelectGo();
            _gameManager.ApplyGoRisk(risk);

            if (_goStopPanel != null)
                _goStopPanel.SetActive(false);

            RefreshAll();
        }

        private void OnStopClicked()
        {
            if (_gameManager.RoundManager == null) return;

            var result = _gameManager.RoundManager.SelectStop();

            if (_goStopPanel != null)
                _goStopPanel.SetActive(false);

            ShowResult(result);
            RefreshAll();
        }

        #endregion

        #region 상태 처리

        private void HandleGameStateChanged(GameState state)
        {
            switch (state)
            {
                case GameState.PreRound:
                    if (_bossIntroPanel != null) _bossIntroPanel.SetActive(true);
                    break;

                case GameState.InRound:
                    if (_bossIntroPanel != null) _bossIntroPanel.SetActive(false);
                    if (_goStopPanel != null) _goStopPanel.SetActive(false);
                    if (_resultPanel != null) _resultPanel.SetActive(false);
                    RefreshAll();
                    break;

                case GameState.PostRound:
                    break;

                case GameState.GameOver:
                    ShowMessage("게임 오버 — 저승에서 영원히...");
                    break;

                case GameState.Victory:
                    ShowMessage("축하합니다! 이승으로 돌아갑니다!");
                    break;
            }
        }

        #endregion

        #region 유틸

        private GameObject CreateCardUI(CardInstance card, Transform parent)
        {
            if (_cardPrefab != null)
            {
                var obj = Instantiate(_cardPrefab, parent);
                var text = obj.GetComponentInChildren<TextMeshProUGUI>();
                if (text != null)
                    text.text = $"{(int)card.Month}월\n{card.Type}";
                return obj;
            }

            // 프리팹 없으면 빈 오브젝트
            var fallback = new GameObject(card.NameKR);
            fallback.transform.SetParent(parent);
            return fallback;
        }

        private void ShowResult(ScoringEngine.ScoreResult result)
        {
            if (_resultPanel != null)
                _resultPanel.SetActive(true);

            ShowMessage(result.ToString());
        }

        public void ShowGoStopChoice(ScoringEngine.ScoreResult currentScore, int goCount)
        {
            if (_goStopPanel != null)
                _goStopPanel.SetActive(true);

            if (_goRiskText != null)
            {
                var decision = new GoStopDecision(new ScoringEngine());
                var risk = decision.GetGoRisk(goCount);
                _goRiskText.text = $"Go → 배수 x{risk.MultiplierBonus}" +
                    (risk.InstantDeathOnFail ? "\n실패 시 즉사!" : "");
            }
        }

        private void ShowMessage(string msg)
        {
            if (_messageText != null)
                _messageText.text = msg;
            Debug.Log($"[DokkaebiHand] {msg}");
        }

        private void ShowGimmickMessage(string msg)
        {
            if (_gimmickText != null)
                _gimmickText.text = msg;
            Debug.Log($"[보스 기믹] {msg}");
        }

        private void ClearChildren(Transform parent)
        {
            for (int i = parent.childCount - 1; i >= 0; i--)
                Destroy(parent.GetChild(i).gameObject);
        }

        #endregion
    }
}

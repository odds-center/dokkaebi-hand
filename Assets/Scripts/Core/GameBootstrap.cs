using UnityEngine;
using DokkaebiHand.UI;

namespace DokkaebiHand.Core
{
    /// <summary>
    /// 게임 진입점.
    ///
    /// 사용법 (목업 프로토타입):
    ///   1. Unity에서 빈 씬 생성
    ///   2. 빈 GameObject 생성 → "GameBootstrap" 이름
    ///   3. 이 컴포넌트(GameBootstrap) 붙이기
    ///   4. useMockup = true (기본값)
    ///   5. 플레이!
    ///
    /// 모든 조작: 마우스/터치. 키보드 불필요.
    /// 네트워크 불필요. 세이브는 로컬 파일 + Steam 클라우드 이중 저장.
    /// </summary>
    public class GameBootstrap : MonoBehaviour
    {
        [Header("목업 모드 (아트 에셋 없이 프로토타입)")]
        [SerializeField] private bool useMockup = true;

        [Header("실제 UI (목업 모드 OFF 시 사용)")]
        [SerializeField] private GameUIManager _uiManager;

        private GameManager _gameManager;
        private SaveManager _saveManager;
        private float _playTimeAccumulator;

        public static SaveManager SharedSaveManager { get; private set; }
        public static SaveData LoadedSave { get; private set; }

        private void Start()
        {
            Application.targetFrameRate = 60;
            _saveManager = new SaveManager();
            SharedSaveManager = _saveManager;

            // 세이브 로드 시도
            if (_saveManager.HasSave())
            {
                LoadedSave = _saveManager.Load();
                Debug.Log("[GameBootstrap] 기존 세이브 발견.");
            }

            if (useMockup)
            {
                gameObject.AddComponent<MockupSceneBuilder>();
                Debug.Log("[GameBootstrap] 목업 모드. 모든 조작은 마우스/터치.");
            }
            else
            {
                _gameManager = new GameManager();

                if (_uiManager != null)
                    _uiManager.Initialize(_gameManager);

                // 자동 저장 이벤트 연결
                _gameManager.OnGameStateChanged += OnStateChangedForSave;

                if (LoadedSave != null)
                {
                    _gameManager.LoadFromSave(LoadedSave);
                    _gameManager.StartNextRealm();
                }
                else
                {
                    _gameManager.StartNewGame();
                    _gameManager.BeginSpiral();
                }
            }
        }

        /// <summary>
        /// 상태 전환 시 자동 세이브
        /// </summary>
        private void OnStateChangedForSave(GameState state)
        {
            if (_gameManager == null || _saveManager == null) return;

            // 영역 클리어, 상점, 이승의 문, 게임오버 시 자동 저장
            switch (state)
            {
                case GameState.PostRound:
                case GameState.Shop:
                case GameState.Gate:
                case GameState.GameOver:
                    _saveManager.AutoSave(_gameManager);
                    break;
            }
        }

        /// <summary>
        /// 앱 종료 시 자동 세이브
        /// </summary>
        private void OnApplicationQuit()
        {
            if (_gameManager != null && _saveManager != null)
            {
                _saveManager.AutoSave(_gameManager);
                Debug.Log("[GameBootstrap] 종료 시 자동 저장 완료.");
            }
        }

        /// <summary>
        /// 앱 백그라운드 진입 시 자동 세이브 (모바일/Steam Deck)
        /// </summary>
        private void OnApplicationPause(bool pause)
        {
            if (pause && _gameManager != null && _saveManager != null)
            {
                _saveManager.AutoSave(_gameManager);
                Debug.Log("[GameBootstrap] 백그라운드 진입 시 자동 저장.");
            }
        }
    }
}

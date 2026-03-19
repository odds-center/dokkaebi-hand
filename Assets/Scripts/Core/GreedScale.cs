using System;

namespace DokkaebiHand.Core
{
    /// <summary>
    /// 욕망의 저울: Go/Stop 리스크의 시각적 피드백 시스템
    /// 안전(왼쪽) ↔ 탐욕(오른쪽) 기울기로 현재 리스크 상태 표시
    /// </summary>
    public enum GreedLevel
    {
        Safe,       // Go 0회 — 저울 수평, 평화
        Tempted,    // Go 1회 — 약간 기울어짐, 도깨비불 깜빡
        Greedy,     // Go 2회 — 크게 기울어짐, 붉은 기운
        Consumed    // Go 3회 — 극한, 화면 진동, 사이렌
    }

    public class GreedScale
    {
        public int GoCount { get; private set; }
        public GreedLevel Level { get; private set; } = GreedLevel.Safe;

        /// <summary>
        /// 저울 기울기 (0.0 = 수평, 1.0 = 극한)
        /// </summary>
        public float TiltAmount { get; private set; }

        /// <summary>
        /// 도깨비불 강도 (0.0 ~ 1.0)
        /// </summary>
        public float FireIntensity { get; private set; }

        /// <summary>
        /// 화면 붉기 (0.0 ~ 1.0)
        /// </summary>
        public float RedTint { get; private set; }

        /// <summary>
        /// BGM BPM (기본 80)
        /// </summary>
        public int BPM { get; private set; } = 80;

        /// <summary>
        /// 화면 흔들림 강도
        /// </summary>
        public float ScreenShake { get; private set; }

        public event Action<GreedLevel> OnGreedLevelChanged;
        public event Action OnGoMoment; // 3 Go 시 특수 연출 트리거

        /// <summary>
        /// 라운드 시작 시 리셋
        /// </summary>
        public void Reset()
        {
            GoCount = 0;
            UpdateLevel();
        }

        /// <summary>
        /// Go 선택 시 호출
        /// </summary>
        public void OnGo()
        {
            GoCount++;
            UpdateLevel();

            if (GoCount >= 3)
                OnGoMoment?.Invoke();
        }

        /// <summary>
        /// Stop 선택 시 호출
        /// </summary>
        public void OnStop()
        {
            // 레벨은 유지 (점수 표시용), 다음 라운드에서 리셋
        }

        private void UpdateLevel()
        {
            var prevLevel = Level;

            Level = GoCount switch
            {
                0 => GreedLevel.Safe,
                1 => GreedLevel.Tempted,
                2 => GreedLevel.Greedy,
                _ => GreedLevel.Consumed
            };

            TiltAmount = GoCount switch
            {
                0 => 0f,
                1 => 0.3f,
                2 => 0.65f,
                _ => 1.0f
            };

            FireIntensity = GoCount switch
            {
                0 => 0.1f,
                1 => 0.4f,
                2 => 0.7f,
                _ => 1.0f
            };

            RedTint = GoCount switch
            {
                0 => 0f,
                1 => 0.1f,
                2 => 0.35f,
                _ => 0.7f
            };

            BPM = GoCount switch
            {
                0 => 80,
                1 => 100,
                2 => 120,
                _ => 140
            };

            ScreenShake = GoCount switch
            {
                0 => 0f,
                1 => 0f,
                2 => 2f,
                _ => 8f
            };

            if (Level != prevLevel)
                OnGreedLevelChanged?.Invoke(Level);
        }

        /// <summary>
        /// UI 표시용: 현재 상태 텍스트
        /// </summary>
        public string GetStatusText()
        {
            return Level switch
            {
                GreedLevel.Safe => "",
                GreedLevel.Tempted => "... 욕심이 고개를 든다",
                GreedLevel.Greedy => "...! 저울이 기울어진다!",
                GreedLevel.Consumed => "!! 욕심이 너를 삼키려 한다 !!",
                _ => ""
            };
        }

        /// <summary>
        /// UI 표시용: 저울 시각적 문자열
        /// </summary>
        public string GetScaleVisual()
        {
            return GoCount switch
            {
                0 => "    ◇━━━━━◇    ",
                1 => "   ◇━━━━━━◇   ",
                2 => "  ◇━━━━━━━◇  ",
                _ => " ◇━━━━━━━━◇ "
            };
        }
    }
}

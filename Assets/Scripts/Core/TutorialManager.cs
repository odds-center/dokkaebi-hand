using System;
using System.Collections.Generic;
using DokkaebiHand.Cards;
using DokkaebiHand.Combat;

namespace DokkaebiHand.Core
{
    /// <summary>
    /// 4단계 인터랙티브 튜토리얼 (첫 플레이 시 자동 실행, 스킵 가능)
    /// 1단계: 패 내기와 매칭
    /// 2단계: 족보와 점수
    /// 3단계: Go/Stop 선택
    /// 4단계: 보스와 전략
    /// </summary>
    public class TutorialManager
    {
        public enum TutorialStep
        {
            NotStarted,
            Step1_Matching,     // 패 내기와 매칭
            Step2_Yokbo,        // 족보와 점수
            Step3_GoStop,       // Go/Stop 선택
            Step4_Strategy,     // 보스와 전략
            Complete
        }

        public TutorialStep CurrentStep { get; private set; } = TutorialStep.NotStarted;
        public bool IsActive => CurrentStep != TutorialStep.NotStarted && CurrentStep != TutorialStep.Complete;
        public string CurrentDialogue { get; private set; }
        public string CurrentHint { get; private set; }

        public event Action<TutorialStep> OnStepChanged;
        public event Action<string> OnDialogue;

        public void Start()
        {
            CurrentStep = TutorialStep.Step1_Matching;
            ShowStepDialogue();
        }

        public void Skip()
        {
            CurrentStep = TutorialStep.Complete;
            OnStepChanged?.Invoke(CurrentStep);
        }

        public void AdvanceStep()
        {
            if (CurrentStep == TutorialStep.Complete) return;

            CurrentStep = CurrentStep switch
            {
                TutorialStep.Step1_Matching => TutorialStep.Step2_Yokbo,
                TutorialStep.Step2_Yokbo => TutorialStep.Step3_GoStop,
                TutorialStep.Step3_GoStop => TutorialStep.Step4_Strategy,
                TutorialStep.Step4_Strategy => TutorialStep.Complete,
                _ => TutorialStep.Complete
            };

            ShowStepDialogue();
            OnStepChanged?.Invoke(CurrentStep);
        }

        private void ShowStepDialogue()
        {
            switch (CurrentStep)
            {
                case TutorialStep.Step1_Matching:
                    CurrentDialogue = "tutorial_step1_dialogue";
                    CurrentHint = "tutorial_step1_hint";
                    break;
                case TutorialStep.Step2_Yokbo:
                    CurrentDialogue = "tutorial_step2_dialogue";
                    CurrentHint = "tutorial_step2_hint";
                    break;
                case TutorialStep.Step3_GoStop:
                    CurrentDialogue = "tutorial_step3_dialogue";
                    CurrentHint = "tutorial_step3_hint";
                    break;
                case TutorialStep.Step4_Strategy:
                    CurrentDialogue = "tutorial_step4_dialogue";
                    CurrentHint = "tutorial_step4_hint";
                    break;
                case TutorialStep.Complete:
                    CurrentDialogue = "tutorial_complete";
                    CurrentHint = "";
                    break;
            }

            OnDialogue?.Invoke(CurrentDialogue);
        }

        /// <summary>
        /// 튜토리얼용 고정 라운드 프리셋 (손패/바닥 고정 배치)
        /// </summary>
        public static TutorialPreset GetPreset(TutorialStep step)
        {
            return step switch
            {
                TutorialStep.Step1_Matching => new TutorialPreset
                {
                    Description = "1월 송학 광과 1월 카드 매칭 연습",
                    TargetScore = 50
                },
                TutorialStep.Step2_Yokbo => new TutorialPreset
                {
                    Description = "홍단 족보 완성 유도",
                    TargetScore = 100
                },
                TutorialStep.Step3_GoStop => new TutorialPreset
                {
                    Description = "Go 선택 시 리스크 체험",
                    TargetScore = 150
                },
                TutorialStep.Step4_Strategy => new TutorialPreset
                {
                    Description = "보스 기믹 대응 연습",
                    TargetScore = 200
                },
                _ => new TutorialPreset { TargetScore = 100 }
            };
        }
    }

    public class TutorialPreset
    {
        public string Description;
        public int TargetScore;
    }
}
